---
title: SquaredUp Cloud
description: Optional SquaredUp Cloud visualization layer for the Azure Local Azure Monitor Health Model.
---

# SquaredUp Cloud (Azure Monitor track)

!!! info "Optional deliverable — Phase 4"
    The SquaredUp Cloud workspace is an optional deliverable that ships after the Azure Monitor
    Health Model reaches GA. Source lives in `src/squaredup/cloud/`. This page is a
    placeholder; content lands in Phase 4.

[SquaredUp Cloud](https://squaredup.com) is a SaaS dashboard platform with 80+ integrations.
For this project, two plugins are relevant:

| Plugin | Data streams | Ready-made dashboards |
|---|---|---|
| **Azure plugin** | 55 (Azure Monitor metrics, KQL, Cost, Sentinel, Resource Graph, Log Analytics, App Insights, Service Health) | 44 |
| **SCOM plugin** | 3 (Alerts, Health, Metrics) | 8 |

## Why SquaredUp Cloud for this project

- **Cross-subscription aggregation** — surface Azure Local health across multiple
  subscriptions in a single dashboard (critical for multi-site deployments).
- **KQL tile** — render the `kql/health-score.kql` WAF-pattern health score query as a
  live tile without building a full Azure Monitor Workbook.
- **Hybrid SCOM + Azure Monitor pane** — combine SCOM health states (via the SCOM plugin)
  with Azure Monitor signal data (via the Azure plugin) in one dashboard. This is the
  key value-add for organizations running both tracks in parallel.
- **Free tier** — 2 users, 3 data sources, 10 monitors, unlimited dashboards. Sufficient
  for a single-cluster proof-of-concept.

## Planned workspace (Phase 4)

A SquaredUp Cloud workspace export will ship in `src/squaredup/cloud/` covering:

| Dashboard | Contents |
|---|---|
| **Azure Local — Cluster Health** | Health model entity state, KQL health score tile, Resource Health feed |
| **Azure Local — Azure-side Resources** | L3 ARM resource states across subscriptions (Key Vault, SPN expiry, RBAC drift) |
| **Azure Local — Hybrid View** | SCOM track health (via SCOM plugin) + Azure Monitor signals side-by-side |
| **Azure Local — Alerts** | Azure Monitor alert rules from `alerts.bicep`, grouped by severity |

## Resources

- [SquaredUp Cloud product site](https://squaredup.com)
- [Azure plugin documentation](https://docs.squaredup.com/data-sources/azure-plugin)
- [SCOM plugin documentation](https://docs.squaredup.com/data-sources/scom-plugin)
- [SCOM MI reporting blog](https://squaredup.com/blog/scom-mi-reporting-new-squaredup-plugin/)
- [SquaredUp vs Grafana for Azure dashboarding](https://squaredup.com/blog/dashboarding-azure-squaredup-vs-grafana/)
