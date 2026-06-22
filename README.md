# eu-azfoundry-scout 🇪🇺🔍

An automated DevOps utility designed to map the shifting compliance footprint of Azure AI Foundry. 

Because Azure's regional model availability and data residency configurations change constantly without real-time upstream visibility, this repository runs a weekly cron workflow against Azure geographies. It dynamically queries, filters, and cross-references active AI models to identify exactly which ones support EU data residency constraints (`DataZoneStandard` SKUs).

### Why this exists
When building enterprise-grade, GDPR-compliant architectures with Bicep, ARM, or Terraform, you cannot afford to guess which model versions are available in European regions. **eu-azfoundry-scout** ensures you always have an up-to-date, verifiable list of deployment targets.

## 📊 Current EU-Compliant Models (Updated Weekly)

<!-- START_TABLE -->

_Last updated: 2026-06-22 06:53:43 UTC._

[Full generated output](docs/eu-compliant-models.md)

| Model | Version | Deprecation Date | Regions |
| --- | --- | --- | --- |
| gpt-4o | 2024-05-13 | 2026-10-01T00:00:00Z | francecentral, germanywestcentral, polandcentral, spaincentral, swedencentral, westeurope |
| gpt-4o | 2024-08-06 | 2026-10-01T00:00:00Z | francecentral, germanywestcentral, polandcentral, spaincentral, swedencentral, westeurope |
| gpt-4o-mini | 2024-07-18 | 2026-10-01T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| gpt-4o | 2024-11-20 | 2026-10-01T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| text-embedding-ada-002 | 2 | 2027-04-15T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| text-embedding-3-small | 1 | 2027-04-15T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| text-embedding-3-large | 1 | 2027-04-15T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| o1 | 2024-12-17 | 2026-07-15T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| o3-mini | 2025-01-31 | 2026-08-02T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| o4-mini | 2025-04-16 | 2026-10-16T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| gpt-4.1 | 2025-04-14 | 2026-10-14T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| gpt-4.1-mini | 2025-04-14 | 2026-10-14T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| gpt-4.1-nano | 2025-04-14 | 2026-10-14T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| gpt-5 | 2025-08-07 | 2027-02-06T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| gpt-5-nano | 2025-08-07 | 2027-02-06T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| gpt-5-mini | 2025-08-07 | 2027-02-06T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| gpt-5.1 | 2025-11-13 | 2027-05-15T00:00:00Z | francecentral, swedencentral |
| gpt-5.4 | 2026-03-05 | 2027-03-05T00:00:00Z | francecentral, germanywestcentral, italynorth, norwayeast, polandcentral, spaincentral, swedencentral, switzerlandnorth, westeurope |
| gpt-5.5 | 2026-04-24 | 2027-04-24T00:00:00Z | francecentral, germanywestcentral, italynorth, norwayeast, polandcentral, spaincentral, swedencentral, switzerlandnorth, westeurope |
| Mistral-Large-3 | 1 | 2099-12-31T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| mistral-document-ai-2505 | 1 | 2099-12-31T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| FLUX-1.1-pro | 1 | 2099-12-31T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| FLUX.1-Kontext-pro | 1 | 2099-12-31T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| Cohere-rerank-v4.0-fast | 1 | 2099-12-31T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| Cohere-rerank-v4.0-pro | 1 | 2099-12-31T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| FLUX.2-pro | 1 | 2099-12-31T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| mistral-document-ai-2512 | 1 | 2099-12-31T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| mistral-ocr-4-0 | 1 | 2026-10-01T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| mistral-medium-3-5 | 1 | 2026-10-01T00:00:00Z | francecentral, germanywestcentral, italynorth, polandcentral, spaincentral, swedencentral, westeurope |
| gpt-image-1.5 | 2025-12-16 | 2026-12-16T00:00:00Z | polandcentral, swedencentral |
| model-router | 2025-05-19 | 2026-07-31T00:00:00Z | swedencentral |
| model-router | 2025-08-07 | 2026-07-31T00:00:00Z | swedencentral |
| model-router | 2025-11-18 | 2027-05-20T00:00:00Z | swedencentral |
<!-- END_TABLE -->
