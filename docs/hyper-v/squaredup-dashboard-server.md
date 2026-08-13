---
title: SquaredUp Dashboard Server for Hyper-V SCOM
description: Optional SquaredUp Dashboard Server deliverable owned by the Hyper-V SCOM Management Pack solution.
---

# SquaredUp Dashboard Server for Hyper-V SCOM

::: info Optional SCOM solution deliverable
This dashboard pack is planned only after the Hyper-V SCOM class, relationship, health, alert, and
Distributed Application contracts are validated. Its source belongs in
`src/hyper-v/scom-mp/squaredup/`.
:::

SquaredUp Dashboard Server is an optional presentation layer over the Hyper-V SCOM Management Pack.
It consumes SCOM SDK data and does not change MP discovery, monitoring, health, or packaging.

## Planned dashboards

| Dashboard | Intended content |
|---|---|
| Service overview | Hyper-V Distributed Application health, active alerts, and monitoring-pipeline state |
| Cluster overview | Cluster, node, VM, CSV, storage, and networking rollups |
| Standalone host overview | Host, VM, virtual switch, storage, and replication state |
| Capacity and performance | CPU, memory, storage, networking, VM pressure, and trend views |
| Alert operations | Actionable Hyper-V alerts grouped by service, component, severity, and owner |

Dashboard definitions must target only Hyper-V-owned classes and the
[Hyper-V Distributed Application](../design/hyper-v/distributed-application.md). They must not
depend on Azure Local MP classes or the conditional Hyper-V Azure Monitor solution.

## Gate

The dashboard pack remains post-MP and optional until architecture validation confirms the underlying
object model and operator surfaces.

## Resources

- [SquaredUp Dashboard Server](https://ds.squaredup.com)
- [Hyper-V SCOM solution design](../design/hyper-v/scom-mp.md)
