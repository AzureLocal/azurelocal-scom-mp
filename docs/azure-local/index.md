---
title: Azure Local
description: Azure Local health monitoring through SCOM and Azure Monitor.
---

# Azure Local

Azure Local is a first-class platform track with two committed delivery surfaces:

| Delivery surface | Scope | Status |
|---|---|---|
| **SCOM Management Pack** | Azure Local classes, discoveries, monitors, rules, health rollups, overrides, views, packaging, and operator guidance | Functional development baseline; certification pending |
| **Azure Monitor Health Models** | Entities, relationships, signals, health objectives, alerts, workbooks, and Bicep deployment | Preview development baseline; live validation pending |

Both surfaces implement the Azure Local topology documented in the
[Azure Local design](../design/azure-local/index.md) section. They use the same logical entities,
health dimensions, rollup rules, and signal names where the delivery surfaces expose equivalent
data.

::: info Two independent solutions
The SCOM Management Pack and Azure Monitor Health Models have separate design, source, deployment,
testing, and release boundaries.
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

1. Choose the [Azure Local SCOM design](../design/azure-local/scom-mp.md) or
   [Azure Monitor Health Models design](../design/azure-local/azure-monitor.md).
2. Read [Scope and topology](../design/scope-topology.md).
3. Explore the [Azure Local SCOM Management Pack](../scom-mp/index.md).
4. Review the [Azure Local Azure Monitor Health Model](../azure-monitor/index.md) and its
   [prerequisites](../azure-monitor/prerequisites.md).
5. Follow delivery status on the [Roadmap](../project/roadmap.md).
