#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi

set -euo pipefail

if ! command -v az >/dev/null 2>&1; then
    echo "Error: Azure CLI ('az') is not installed or not in PATH." >&2
    exit 1
fi

if ! az account show --output none >/dev/null 2>&1; then
    echo "Error: You are not logged into Azure CLI. Run 'az login' first." >&2
    exit 1
fi

readonly DATA_ZONE_SKU="DataZoneStandard"
readonly MODEL_QUERY="[?model.lifecycleStatus!='Deprecated' && length(model.skus[?name=='${DATA_ZONE_SKU}']) > \`0\`].[model.name, model.version]"

declare -A seen_models=()
declare -A model_versions=()
declare -A model_regions=()
declare -a ordered_keys=()

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

    while IFS=$'\t' read -r model_name model_version; do
        if [[ -z "$model_name" || -z "$model_version" ]]; then
            continue
        fi

        key="${model_name}|||${model_version}"

        if [[ -z "${seen_models[$key]+x}" ]]; then
            seen_models["$key"]=1
            ordered_keys+=("$key")
            model_versions["$key"]="$model_version"
            model_regions["$key"]="$region"
        else
            model_regions["$key"]+=", ${region}"
        fi
    done <<< "$region_results"
done

echo "---------------------------------------------------------------------"

if (( ${#ordered_keys[@]} == 0 )); then
    echo "No matching models found with ${DATA_ZONE_SKU} in the checked EU regions."
    exit 0
fi

printf '%-30s %-15s %s\n' "Model" "Version" "Regions"
printf '%-30s %-15s %s\n' "------------------------------" "---------------" "------------------------------"

for key in "${ordered_keys[@]}"; do
    model_name=${key%%|||*}
    regions=$(dedupe_csv_list "${model_regions[$key]}")
    printf '%-30s %-15s %s\n' "$model_name" "${model_versions[$key]}" "$regions"
done

echo
echo "Execution completed successfully. Use these exact model names and versions for your Bicep or ARM deployments."