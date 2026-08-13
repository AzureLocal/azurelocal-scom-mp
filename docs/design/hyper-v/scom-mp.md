---
title: Hyper-V SCOM design
description: Active topology, signal, threshold, workflow, and packaging research for the Hyper-V SCOM Management Pack.
---

# Hyper-V SCOM Management Pack design

This is the active first delivery lane. The Management Pack is committed, but its product-specific
design remains research-gated.

## Current design baseline

| Concern | Current authority |
|---|---|
| Support matrix and topology | [AB#7343](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7343) |
| Raw Windows Server, Hyper-V, cluster, storage, and network inventories | AB#7344–AB#7348 |
| Prior Microsoft MP research | [AB#7349](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7349), research input only with no dependency |
| SCOM workflow mapping | [AB#7350](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7350) |
| Threshold and tuning policy | [AB#7351](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7351) |
| Lab and fault validation | [AB#7352](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7352) |
| Curated default catalog | [AB#7353](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7353) |
| Packaging | [ADR 0022](../decisions/0022-scom-management-pack-packaging-boundaries.md), proposed |

Network ATC is the preferred networking baseline for eligible Windows Server 2025 Datacenter
failover clusters unless SCVMM/SDN is the selected authority. Manual and older non-ATC networking
remain explicit research variants.

The Microsoft Hyper-V 2019 MP is evidence only. The new MP will not import, extend, override,
require, or take a runtime dependency on it.

## Research and implementation pages

- [Phase-one research plan](../../hyper-v/monitoring-research.md)
- [Monitoring catalog and threshold policy](../../hyper-v/monitoring-catalog.md)
- [Hyper-V SCOM product page](../../hyper-v/scom-mp.md)

Successor Hyper-V scope/topology, discovery, and signal/rollup ADRs will be added after the research
provides defensible decisions.
