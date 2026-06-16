#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/.." && pwd)
cd "$REPO_ROOT"

if ! command -v az >/dev/null 2>&1; then
    echo "Error: Azure CLI ('az') is not installed or not in PATH." >&2
    exit 1
fi

if ! az account show --output none >/dev/null 2>&1; then
    echo "Error: You are not logged into Azure CLI. Run 'az login' first." >&2
    exit 1
fi

readonly DATA_ZONE_SKU="DataZoneStandard"
readonly MODEL_QUERY="[?model.lifecycleStatus!='Deprecated' && length(model.skus[?name=='${DATA_ZONE_SKU}']) > \`0\`].[model.name, model.version, model.deprecation.inference || model.deprecation.fineTune || (model.skus[?name=='${DATA_ZONE_SKU}'].deprecationDate | [0]) || '']"
readonly OUTPUT_MARKDOWN_PATH="${OUTPUT_MARKDOWN_PATH:-docs/eu-compliant-models.md}"
readonly README_PATH="${README_PATH:-README.md}"
readonly UPDATE_README="${UPDATE_README:-true}"
readonly GENERATED_AT="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

table_file=$(mktemp)
readme_table_file=$(mktemp)
readme_tmp_file=$(mktemp)
trap 'rm -f "$table_file" "$readme_table_file" "$readme_tmp_file"' EXIT

declare -A seen_models=()
declare -A model_versions=()
declare -A model_deprecation_dates=()
declare -A model_regions=()
declare -a ordered_keys=()

markdown_escape() {
    local value=$1
    value=${value//\\/\\\\}
    value=${value//|/\\|}
    printf '%s' "$value"
}

write_readme_table() {
    {
        echo "_Last updated: ${GENERATED_AT}._"
        echo
        echo "[Full generated output](${OUTPUT_MARKDOWN_PATH})"
        echo
        cat "$table_file"
    } > "$readme_table_file"
}

update_readme() {
    if [[ "${UPDATE_README,,}" != "true" ]]; then
        return
    fi

    if [[ ! -f "$README_PATH" ]]; then
        echo "Error: README file '${README_PATH}' does not exist." >&2
        exit 1
    fi

    if ! grep -q '<!-- START_TABLE -->' "$README_PATH" || ! grep -q '<!-- END_TABLE -->' "$README_PATH"; then
        echo "Error: README file '${README_PATH}' does not contain the expected table delimiters." >&2
        exit 1
    fi

    awk -v replacement_file="$readme_table_file" '
        BEGIN {
            while ((getline line < replacement_file) > 0) {
                replacement = replacement line ORS
            }
            close(replacement_file)
        }
        /<!-- START_TABLE -->/ {
            print
            print ""
            printf "%s", replacement
            in_generated_block = 1
            next
        }
        /<!-- END_TABLE -->/ {
            in_generated_block = 0
            print
            next
        }
        !in_generated_block {
            print
        }
    ' "$README_PATH" > "$readme_tmp_file"

    mv "$readme_tmp_file" "$README_PATH"
}

write_markdown_output() {
    mkdir -p "$(dirname "$OUTPUT_MARKDOWN_PATH")"

    {
        echo "# EU-Compliant Azure AI Foundry Models"
        echo
        echo "Generated on ${GENERATED_AT}."
        echo
        cat "$table_file"
    } > "$OUTPUT_MARKDOWN_PATH"

    write_readme_table
    update_readme

    echo "Markdown results written to ${OUTPUT_MARKDOWN_PATH}."
    if [[ "${UPDATE_README,,}" == "true" ]]; then
        echo "README table updated in ${README_PATH}."
    fi
}

mapfile -t EU_REGIONS < <(
    az account list-locations \
        --query "[?metadata.geographyGroup=='Europe'].name" \
        --output tsv \
    | sort -u
)

if (( ${#EU_REGIONS[@]} == 0 )); then
    echo "Error: Azure CLI did not return any Europe regions." >&2
    exit 1
fi

dedupe_csv_list() {
    printf '%s\n' "$1" \
        | tr ',' '\n' \
        | awk '
            {
                gsub(/^ +| +$/, "", $0)
                if ($0 != "" && !seen[$0]++) {
                    if (output == "") {
                        output = $0
                    } else {
                        output = output ", " $0
                    }
                }
            }
            END {
                print output
            }
        '
}

echo "====================================================================="
echo " Fetching models that support ${DATA_ZONE_SKU} in EU regions"
echo "====================================================================="
echo "Scanning target Azure regions..."

for region in "${EU_REGIONS[@]}"; do
    echo " -> Querying region: ${region}..."

    if ! region_results=$(az cognitiveservices model list \
        --location "$region" \
        --only-show-errors \
        --query "$MODEL_QUERY" \
        --output tsv 2>/dev/null); then
        echo "    Warning: skipping region '${region}' because the Azure CLI query failed." >&2
        continue
    fi

    if [[ -z "$region_results" ]]; then
        echo "    No matching models found in ${region}."
        continue
    fi

    while IFS=$'\t' read -r model_name model_version deprecation_date; do
        if [[ -z "$model_name" || -z "$model_version" ]]; then
            continue
        fi

        deprecation_date=${deprecation_date:-N/A}

        key="${model_name}|||${model_version}"

        if [[ -z "${seen_models[$key]+x}" ]]; then
            seen_models["$key"]=1
            ordered_keys+=("$key")
            model_versions["$key"]="$model_version"
            model_deprecation_dates["$key"]="$deprecation_date"
            model_regions["$key"]="$region"
        else
            if [[ "${model_deprecation_dates[$key]}" == "N/A" && "$deprecation_date" != "N/A" ]]; then
                model_deprecation_dates["$key"]="$deprecation_date"
            fi

            model_regions["$key"]+=", ${region}"
        fi
    done <<< "$region_results"
done

echo "---------------------------------------------------------------------"

if (( ${#ordered_keys[@]} == 0 )); then
    echo "No matching models found with ${DATA_ZONE_SKU} in the checked EU regions."
    echo "No matching models found with ${DATA_ZONE_SKU} in the checked EU regions." > "$table_file"
    write_markdown_output
    exit 0
fi

{
    echo "| Model | Version | Deprecation Date | Regions |"
    echo "| --- | --- | --- | --- |"
} > "$table_file"

printf '%-30s %-15s %-20s %s\n' "Model" "Version" "Deprecation Date" "Regions"
printf '%-30s %-15s %-20s %s\n' "------------------------------" "---------------" "--------------------" "------------------------------"

for key in "${ordered_keys[@]}"; do
    model_name=${key%%|||*}
    regions=$(dedupe_csv_list "${model_regions[$key]}")
    printf '%-30s %-15s %-20s %s\n' "$model_name" "${model_versions[$key]}" "${model_deprecation_dates[$key]}" "$regions"
    printf '| %s | %s | %s | %s |\n' \
        "$(markdown_escape "$model_name")" \
        "$(markdown_escape "${model_versions[$key]}")" \
        "$(markdown_escape "${model_deprecation_dates[$key]}")" \
        "$(markdown_escape "$regions")" >> "$table_file"
done

write_markdown_output

echo
echo "Execution completed successfully. Use these exact model names and versions for your Bicep or ARM deployments."