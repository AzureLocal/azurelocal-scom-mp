---
title: Azure Local Azure Monitor Health Models
description: Azure Monitor Health Models for Azure Local infrastructure.
---

# Azure Monitor health models for Azure Local

> **Azure Local / Azure Monitor** — the committed Azure Monitor delivery surface for Azure Local.

This section covers **how the Azure Local design is implemented** as an Azure Monitor Health Model.
Read the [Azure Local Azure Monitor design lane](../design/azure-local/azure-monitor.md) first. Its
entity graph, DCMA signals, cloud prerequisites, and deployment model do not govern Hyper-V.

::: tip Start with the prerequisites
Before building or deploying the health model, work through the [prerequisites](prerequisites.md).
The model itself collects nothing; it consumes signals from HCI Insights, Azure Monitor Agent,
Telemetry and Diagnostics, and Resource Health.
:::

::: info Implementation has not started
The Azure Local design baseline is accepted. Current APIs and signal contracts will be revalidated
before implementation begins. See the
[implementation plan](https://github.com/Hybrid-Solutions-Cloud/hybrid-health-monitoring/blob/main/PLAN.md).
:::

Hyper-V has a separate, conditional [Azure Monitor roadmap track](../hyper-v/azure-monitor.md)
through Arc-enabled SCVMM. It is not covered by the Azure Local prerequisites on this page.

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
2. [Azure Local Azure Monitor design](../design/azure-local/azure-monitor.md) — the governing lane
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
