---
title: SCOM ↔ Azure Monitor Comparison
description: Side-by-side concept mapping between SCOM and Azure Monitor Health Models.
---

# SCOM ↔ Azure Monitor Comparison

> Side-by-side concept crosswalk between the two health monitoring tracks.

!!! info "Coming soon"
    Full comparison docs are planned for Phase 2. The concept mapping table is available in [REFERENCES.md](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/REFERENCES.md).

## Concept mapping (quick reference)

| SCOM | Azure Monitor |
|---|---|
| Management Pack | DCR + Alert Rules + Workbook (ARM/Bicep bundle) |
| Health Model (rollup tree) | Azure Monitor Health Model (preview) |
| Unit Monitor | Signal on an entity (metric or log query) |
| Aggregate Monitor | Generic entity aggregating child health |
| Dependency Monitor | Relationship with health propagation |
| Health State (Green/Yellow/Red) | Healthy / Degraded / Unhealthy |
| Distributed Application | Service Group + Health Model root entity |
| SLA Reporting | Azure Monitor SLI/SLO (public preview) |
| Discovery | Azure Resource Graph / Service Group auto-discovery |
| Override | Signal threshold / entity impact setting |
| Notification Subscription | Action Group |
| Data Warehouse | Log Analytics Workspace |
| Operations Console | Azure Portal + Workbooks + Grafana |
