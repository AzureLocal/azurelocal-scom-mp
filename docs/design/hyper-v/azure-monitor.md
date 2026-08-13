---
title: Hyper-V Azure Monitor design
description: Conditional Azure Monitor Health Models design research for Hyper-V through Arc-enabled SCVMM.
---

# Hyper-V Azure Monitor Health Models design

This lane is conditional and is not part of phase-one implementation. Arc-enabled SCVMM inventory
does not by itself prove that Azure Monitor Agent telemetry, Data Collection Rules, Resource Graph,
or useful Health Model signals exist for every Hyper-V entity.

## Decision gate

| Evidence | Work item |
|---|---|
| Arc-enabled SCVMM resource inventory and guest-management boundary | [AB#7331](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7331) |
| Telemetry and Health Models proof | [AB#7332](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7332) |
| Go, defer, or no-go decision | [AB#7333](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7333) and [ADR 0023](../decisions/0023-hyper-v-azure-monitor-through-arc-enabled-scvmm.md) |

The Azure Local Azure Monitor entity graph, DCMA signals, prerequisites, and Bicep design are not
defaults for this lane. They can be used as comparison material only where the Hyper-V spikes prove
equivalent supported behavior.

Continue to the [conditional product roadmap page](../../hyper-v/azure-monitor.md) for the current
go criteria and Microsoft foundations to validate.
