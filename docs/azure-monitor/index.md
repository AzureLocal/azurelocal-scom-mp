---
title: Azure Monitor Health Models
description: Azure Monitor Health Models for Azure Local (HCI) — overview.
---

# Azure Monitor Health Models

> **Track 2** — Native Azure Monitor health monitoring for Azure Local clusters.

This section covers **how the design is implemented** as an Azure Monitor Health Model.
The *design itself* — entity model, signal catalog, rollup policy, customization — is
track-agnostic and lives in [Design](../design/index.md). Read that first.

::: tip Start with the prerequisites
Before building or deploying the health model, work through the [prerequisites](prerequisites.md).
The model itself collects nothing; it consumes signals from HCI Insights, Azure Monitor Agent,
Telemetry and Diagnostics, and Resource Health.
:::

::: info Phase 4 has not started
The shared design and its 20 architecture decisions are accepted. Azure Monitor implementation
is the Phase 4 deliverable. See the
[implementation plan](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/PLAN.md).
:::

## What lives here

| Page | Content |
|---|---|
| [Prerequisites](prerequisites.md) | Cloud-side setup contract (HCI Insights, AMA, DCMA, RBAC, networking) |
| Entities (planned) | Implementation of [ADR 0006](../design/decisions/0006-azmon-entity-model.md) — Service Group + per-entity definitions |
| Signals (planned) | DCMA metrics + KQL queries per [Signal Catalog](../design/signal-catalog.md) |
| Health Objectives (planned) | Per-entity Availability/Performance/Configuration/Security objectives |
| Alerts (planned) | Alert rules + action groups per [ADR 0009](../design/decisions/0009-alert-vs-health-state.md) |
| Bicep modules (planned) | `health-model.bicep`, `service-group.bicep`, `alerts.bicep` + tier files |
| Workbook (planned) | Azure Monitor Workbook for visualization |
| Diagrams | Entity graph (Mermaid + draw.io), health propagation flow |

## Where to start

1. **[Prerequisites](prerequisites.md)** — make sure your cloud side is wired up
2. [Design overview](../design/index.md) — the conceptual foundation
3. [Azure Monitor entity model ADR](../design/decisions/0006-azmon-entity-model.md)
4. [Cloud prerequisites contract ADR](../design/decisions/0010-cloud-prerequisites-contract.md)
5. [Customization](../design/customization.md) — how operators tune the Azure Monitor track

## What will be here

- Health model concepts (entities, signals, relationships)
- Azure Local entity hierarchy and signal inventory
- Service Group wiring and auto-discovery
- ARM / Bicep deployment templates
- KQL signal queries
- Alert rules and Action Group integration
- Azure portal designer walkthrough
