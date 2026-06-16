# eu-azfoundry-scout 🇪🇺🔍

An automated DevOps utility designed to map the shifting compliance footprint of Azure AI Foundry. 

Because Azure's regional model availability and data residency configurations change constantly without real-time upstream visibility, this repository runs a weekly cron workflow against Azure geographies. It dynamically queries, filters, and cross-references active AI models to identify exactly which ones support EU data residency constraints (`DataZoneStandard` SKUs).

### Why this exists
When building enterprise-grade, GDPR-compliant architectures with Bicep, ARM, or Terraform, you cannot afford to guess which model versions are available in European regions. **eu-azfoundry-scout** ensures you always have an up-to-date, verifiable list of deployment targets.

## 📊 Current EU-Compliant Models (Updated Weekly)

<!-- START_TABLE -->

<!-- END_TABLE -->
