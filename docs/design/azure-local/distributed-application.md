---
title: Azure Local Distributed Application
description: Azure Local SCOM Distributed Application membership, health rollup, presentation, and validation contract.
---

# Azure Local Distributed Application design

The Azure Local SCOM product ships its own Distributed Application. It does not reference the
Hyper-V MP or any shared runtime library.

The root class is **`AzureLocal.Deployment`**, as accepted in
[ADR 0005](../decisions/0005-scom-class-hierarchy.md#distributed-application). It extends
`Microsoft.SystemCenter.Service` and represents one monitored Azure Local deployment. Its purpose
is to answer one operator question: **Is this Azure Local deployment healthy?**

## Service model

| DA branch | Membership | Rollup intent |
|---|---|---|
| Infrastructure | Azure Local cluster, nodes, storage pools, volumes, physical infrastructure, Network ATC intents, and lifecycle state | Infrastructure health for the deployment; worst-state default with documented exceptions |
| Platform | Arc Resource Bridge/MOC, AKS Arc platform, DCMA/cloud agents, and registration services | Platform-service health; only deployed services participate |
| Azure services | Azure Local ARM resource, Arc machines, Custom Location, identity, Key Vault, storage, RBAC, DCR, workspace, and related Azure dependencies | Azure-side availability and configuration health |
| Monitoring pipeline | SCOM agents, management-server probes, discovery freshness, and required collection paths from ADR 0018 | Independent pipeline health so stale green infrastructure cannot hide failed monitoring |

The DA instance and component membership are authored in Management Pack XML and populated through
typed discoveries and stable relationship keys. Customers do not have to maintain membership in the
SCOM Distributed Application Designer.

## Health propagation

The DA organizes health; it does not replace entity monitoring.

| Layer | Responsibility |
|---|---|
| Unit monitors | Establish health for an Azure Local entity or signal |
| Aggregate monitors | Roll Availability, Configuration, Performance, and applicable Security state within an entity |
| Dependency monitors | Propagate health through discovered platform relationships and into each DA component group |
| DA root | Presents the deployment-level service state across the component groups |

[ADR 0003](../decisions/0003-health-rollup-policy.md) governs worst-state defaults and approved
exceptions. [ADR 0018](../decisions/0018-self-observability.md) requires the monitoring-pipeline
branch to participate directly at the root. Unknown, stale-data, maintenance-mode, and recovery
behavior must be validated rather than allowed to resolve silently to Healthy.

## Required product artifacts

- DA root and component-group class XML in the Azure Local sealed library;
- dynamic relationship and membership discoveries;
- aggregate and dependency monitors with upgrade-safe overrides where supported;
- Health Explorer, diagram, state, alert, and task views scoped to the deployment;
- report and service-level objective targeting for availability and selected performance rules;
- optional SquaredUp Dashboard Server views that target the Azure Local DA; and
- import, population, fault, recovery, upgrade, coexistence, and removal tests.

The [Azure Local health-rollup tree](../../scom-mp/diagrams/health-tree.md) is the current visual
reference. Authoring begins after the SCOM class, discovery, packaging, and validation contracts are
ready.

## Boundaries

- The DA monitors Azure Local infrastructure, not guest operating systems or applications.
- A deployment failure does not roll into a Hyper-V DA.
- A combined Azure Local and Hyper-V estate view requires a future optional integration MP.
- DA membership and rollup changes are public behavior and follow the product's versioning and
  upgrade contract.

## References

- [ADR 0026 — Platform-owned SCOM Distributed Applications](../decisions/0026-platform-owned-scom-distributed-applications.md)
- [Microsoft Operations Manager Distributed Applications](https://learn.microsoft.com/en-us/system-center/scom/manage-using-authoring-workspace?view=sc-om-2025)
- [Microsoft Operations Manager service-level objectives](https://learn.microsoft.com/en-us/system-center/scom/manage-monitor-sla-overview?view=sc-om-2025)
