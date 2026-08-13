---
title: Azure Local SCOM Management Pack
description: SCOM Management Pack for Azure Local infrastructure.
---

# Azure Local SCOM Management Pack

> **Azure Local / SCOM** — the committed SCOM delivery surface for Azure Local.

This section covers **how the Azure Local design is implemented** as a SCOM Management Pack. Read
the [Azure Local SCOM design lane](../design/azure-local/scom-mp.md) first. Shared principles do not
make this platform's entity model, signals, or discoveries applicable to the Hyper-V MP.

::: warning Development baseline, not a production release
Five independent MP artifacts, the platform-owned DA, monitoring workflows, operator views,
customer override templates, and offline tests are implemented. Microsoft VSAE/SDK verification,
ordered transient test sealing, and strong-name verification pass for the complete suite against
the installed SCOM 2022 dependencies. Governed release signing and SCOM lab certification are
still required before release.
:::

Looking for the other SCOM product? See the independent
[Hyper-V SCOM Management Pack](../hyper-v/scom-mp.md).

## Implemented product

| Area | Development baseline |
|---|---|
| Packaging | Library, Discovery, Monitoring, Presentation, and optional Reporting artifacts |
| Model | 17 public classes and 28 public relationships, with stable deployment and storage identities |
| Discovery | Lightweight Azure Local qualification followed by full local topology discovery |
| Health | 14 unit monitors, six domain aggregates, and explicit monitoring-pipeline state |
| DA | One deployment service, six components, and 12 dependency rollups |
| Telemetry | 12 performance rules and four high-confidence Failover Clustering event-alert rules |
| Operations | 14 views, a read-only diagnostic task, and operational knowledge |
| Tuning | Separate customer-owned Discovery and Monitoring override MPs with provisional Lab, Standard, and Strict starters |

## Documentation

- [Architecture](../design/azure-local/architecture.md)
- [Management Pack structure](../design/azure-local/management-pack-structure.md)
- [Class and relationship model](../design/azure-local/class-and-relationship-model.md)
- [Discovery and workflow architecture](../design/azure-local/discovery-and-workflow-architecture.md)
- [Health and alert architecture](../design/azure-local/health-and-alert-architecture.md)
- [Override and tuning architecture](../design/azure-local/override-and-tuning-architecture.md)
- [Validation and release gates](../design/azure-local/validation-and-release.md)
- [Monitoring research](monitoring-research.md) and [catalog](monitoring-catalog.md)
- [Management Pack administration guide](management-pack-guide.md)

## Where to start

1. [Azure Local SCOM design](../design/azure-local/scom-mp.md) — the governing design lane
2. [Architecture](../design/azure-local/architecture.md) — the product and runtime boundary
3. [Monitoring catalog](monitoring-catalog.md) — what is monitored, collected, or deferred
4. [Management Pack guide](management-pack-guide.md) — build, import, tune, upgrade, and remove
5. [Validation and release](../design/azure-local/validation-and-release.md) — completed authoring
   evidence and remaining lab/release gates

## Track-specific upstream references

- [Brian Wren / MPAuthor video series (SC 2012 R2 — Operations Manager Management Packs)](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/)
- [Kevin Holman — SCOM Management Pack Fragment Library](https://kevinholman.com/2017/02/05/scom-management-pack-fragment-library/)
- [Silect MP Author](https://www.silect.com/mp-author/) (free authoring tool)
- See full reference list in [REFERENCES.md](https://github.com/Hybrid-Solutions-Cloud/hybrid-health-monitoring/blob/main/REFERENCES.md).
