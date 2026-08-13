---
title: Azure Local SCOM Management Pack
description: SCOM Management Pack for Azure Local infrastructure.
---

# Azure Local SCOM Management Pack

> **Azure Local / SCOM** — the committed SCOM delivery surface for Azure Local.

This section covers **how the Azure Local design is implemented** as a SCOM Management Pack. Read
the [Azure Local SCOM design lane](../design/azure-local/scom-mp.md) first. Shared principles do not
make this platform's entity model, signals, or discoveries applicable to the Hyper-V MP.

::: info Authoring has not started
The Azure Local design baseline is accepted. [ADR 0022](../design/decisions/0022-scom-management-pack-packaging-boundaries.md)
requires an independent Azure Local runtime product; AB#7319 validates its artifact, coexistence,
upgrade, and removal contract.
Delivery is tracked by [Feature AB#7315](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7315). See the
[implementation plan](https://github.com/Hybrid-Solutions-Cloud/hybrid-health-monitoring/blob/main/PLAN.md).
:::

Looking for the other SCOM product? See the planned
[Hyper-V SCOM Management Pack](../hyper-v/scom-mp.md).

## What lives here

| Page (planned) | Content |
|---|---|
| Health model XML overview | The sealed Azure Local product structure selected by ADR 0022 |
| Class hierarchy reference | Implementation of [ADR 0005](../design/decisions/0005-scom-class-hierarchy.md) |
| Discoveries reference | PowerShell discovery scripts per [ADR 0004](../design/decisions/0004-scom-discovery-strategy.md) |
| Monitor inventory | Unit / Aggregate / Dependency monitors mapping to the [Signal Catalog](../design/signal-catalog.md) |
| Distributed Application | `AzureLocal.Deployment`, component groups, dynamic membership, rollup, views, reports, dashboards, and SLO targets from the [DA design](../design/azure-local/distributed-application.md) |
| Override pack reference | Customer-facing overrides per [ADR 0008](../design/decisions/0008-customization-strategy.md) |
| Authoring guide | VSAE + Kevin Holman fragment library workflow |
| Lifecycle | Sealing, signing, import, update, retirement |
| Diagrams | Health rollup tree (Mermaid) + class hierarchy (draw.io) |

## Where to start

1. [Azure Local SCOM design](../design/azure-local/scom-mp.md) — the governing design lane
2. [SCOM class hierarchy ADR](../design/decisions/0005-scom-class-hierarchy.md)
3. [Azure Local Distributed Application](../design/azure-local/distributed-application.md)
4. [Discovery strategy ADR](../design/decisions/0004-scom-discovery-strategy.md)
5. [Customization](../design/customization.md) — how operators tune the SCOM track

## Track-specific upstream references

- [Brian Wren / MPAuthor video series (SC 2012 R2 — Operations Manager Management Packs)](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/)
- [Kevin Holman — SCOM Management Pack Fragment Library](https://kevinholman.com/2017/02/05/scom-management-pack-fragment-library/)
- [Silect MP Author](https://www.silect.com/mp-author/) (free authoring tool)
- See full reference list in [REFERENCES.md](https://github.com/Hybrid-Solutions-Cloud/hybrid-health-monitoring/blob/main/REFERENCES.md).
