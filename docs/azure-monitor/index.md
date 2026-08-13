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

::: warning Preview development baseline
The Health Model resource graph, identity, entities, relationships, two documented Azure Local
metric signals, parameter files, research KQL, workbook, and compile-time contract test are
implemented. The service and APIs remain preview. Live deployment and fault evidence are required
before release.
:::

Hyper-V has a separate, conditional [Azure Monitor roadmap track](../hyper-v/azure-monitor.md)
through Arc-enabled SCVMM. It is not covered by the Azure Local prerequisites on this page.

## What lives here

| Page | Content |
|---|---|
| [Prerequisites](prerequisites.md) | Cloud-side setup contract (HCI Insights, AMA, DCMA, RBAC, networking) |
| [Architecture](../design/azure-local/azure-monitor-architecture.md) | Current resource, entity, signal, identity, and validation architecture |
| [Research](research.md) | Revalidated API/signal evidence and remaining spikes |
| Entities | Deployment, six domain entities, cluster Azure-resource entity, and dependency relationships |
| Signals | Two documented Azure Local metric definitions; KQL remains research-only until schemas are proven |
| Alerts | Parameterized deployment-level Degraded and Unhealthy state alerts |
| Bicep modules | Azure Monitor account, Health Model, authentication, signals, entities, and relationships |
| Workbook | Starter Azure Local investigation workbook |
| Diagrams | Entity graph (Mermaid + draw.io), health propagation flow |

## Where to start

1. **[Prerequisites](prerequisites.md)** — make sure your cloud side is wired up
2. [Azure Local Azure Monitor design](../design/azure-local/azure-monitor.md) — the governing lane
3. [Azure Monitor entity model ADR](../design/decisions/0006-azmon-entity-model.md)
4. [Cloud prerequisites contract ADR](../design/decisions/0010-cloud-prerequisites-contract.md)
5. [Customization](../design/customization.md) — how operators tune the Azure Monitor track

## Development and release boundary

- Bicep build and repository contract checks run without an Azure subscription.
- Service Group discovery remains a research item; the initial model uses explicit entities.
- Customer resource IDs and Action Groups are parameters, never committed values.
- Live what-if, deployment, RBAC, signal evaluation, fault/recovery, cost, and teardown are mandatory
  pre-release evidence.
