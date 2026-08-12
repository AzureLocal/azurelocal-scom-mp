---
title: Azure Local
description: Azure Local health monitoring through SCOM and Azure Monitor.
---

# Azure Local

Azure Local is a first-class platform track with two committed delivery surfaces:

| Delivery surface | Scope | Status | ADO |
|---|---|---|---|
| **SCOM Management Pack** | Azure Local classes, discoveries, monitors, rules, health rollups, overrides, views, packaging, and operator guidance | Planned | [Feature AB#7315](https://dev.azure.com/hybridcloudsolutions/Azure%20Local%20SCOM%20MP/_workitems/edit/7315) |
| **Azure Monitor Health Models** | Service Groups, entities, signals, health objectives, alerts, workbooks, and Bicep deployment | Planned | [Feature AB#7316](https://dev.azure.com/hybridcloudsolutions/Azure%20Local%20SCOM%20MP/_workitems/edit/7316) |

Both surfaces implement the Azure Local topology already documented in the shared
[Design](../design/index.md) section. They use the same logical entities, health dimensions,
rollup rules, and signal names where the underlying platforms expose equivalent data.

::: info Azure Local delivery epic
Azure DevOps [Epic AB#7313](https://dev.azure.com/hybridcloudsolutions/Azure%20Local%20SCOM%20MP/_workitems/edit/7313)
owns this platform track and its two delivery Features.
:::

## Scope

The Azure Local track covers:

- the physical cluster, nodes, storage, networking, and lifecycle state;
- cluster-resident platform services such as Arc Resource Bridge, MOC, and the Azure Local agents;
- Azure-side resources provisioned or required by Azure Local; and
- the monitoring pipeline itself, including agent, ingestion, identity, and health-model state.

Application and guest-workload monitoring remains outside the infrastructure product. Future
companion packs can depend on this platform health model.

## Start here

1. Read [Scope and topology](../design/scope-topology.md).
2. Explore the [Azure Local SCOM Management Pack](../scom-mp/index.md).
3. Review the [Azure Local Azure Monitor Health Model](../azure-monitor/index.md) and its
   [prerequisites](../azure-monitor/prerequisites.md).
4. Follow delivery status on the [Roadmap](../project/roadmap.md).
