---
title: Azure Local design
description: Design map for the Azure Local SCOM Management Pack and Azure Monitor Health Models.
---

# Azure Local design

Azure Local has two committed delivery surfaces built from the accepted Azure Local infrastructure
baseline. The topology and signal evidence in ADRs 0001–0019 was developed for this platform.

| Design lane | Status | Start here |
|---|---|---|
| SCOM Management Pack | Committed; authoring planned | [Azure Local SCOM design](scom-mp.md) |
| Azure Monitor Health Models | Committed; current API revalidation next | [Azure Local Azure Monitor design](azure-monitor.md) |

## Platform baseline

- [Scope and topology](../scope-topology.md)
- [Health model](../health-model.md)
- [Signal catalog](../signal-catalog.md)
- [Customization](../customization.md)
- [SCOM and Azure Monitor concept mapping](../concept-mapping.md)

Network ATC is important to Azure Local, but it is not unique to Azure Local. Eligible Windows
Server 2025 Datacenter Hyper-V failover clusters can also use it. Azure Local remains distinct
because of its prescribed platform integration, lifecycle, registration, DCMA, and Azure resource
model—not merely because a Network ATC intent exists.

## Decision scope

Use the [ADR scope map](../decisions/index.md#design-lane-scope-map) to distinguish platform-wide
Azure Local decisions from SCOM-only and Azure Monitor-only decisions.
