---
title: Hyper-V Azure Monitor Health Model
description: Constrained Hyper-V Azure Monitor Health Model through Arc-enabled SCVMM and Arc-enabled Servers.
---

# Azure Monitor for Hyper-V through Arc-enabled SCVMM

This is a **constrained development track**. It applies only to a Hyper-V environment integrated
with Azure Arc-enabled SCVMM where participating hosts are also Arc-enabled Servers with AMA and
the solution DCR.

::: warning Development baseline, not parity or a release
The source compiles and its repository contract passes. It does not yet have live deployment,
identity/RBAC, DCR association, schema, fault/recovery, cost, scale, upgrade, or teardown evidence.
:::

## Implemented baseline

| Area | Development content |
|---|---|
| Inventory | Arc-enabled SCVMM VMM server entity and explicit Arc-enabled host resource IDs |
| Collection | Windows DCR for selected Hyper-V performance counters and critical/error event channels |
| Signals | Host heartbeat, hypervisor CPU, Failover Clustering errors, and expected-host coverage |
| Health | Deployment plus six domain entities with worst-of dependency rollup |
| Alerts | Deployment Degraded and Unhealthy state transitions through customer Action Groups |
| Operations | Lab parameters, standalone KQL, starter workbook, Bicep compile and contract test |

## Go criteria

Release remains blocked until all of these are true:

- Microsoft-supported Arc-enabled SCVMM versions and topology are documented.
- A minimum viable entity graph can be identified with stable Azure resource identities.
- Supported telemetry coverage and explicit parity gaps are accepted.
- A lab fault changes the expected Azure Monitor health state within an acceptable window.
- Identity, RBAC, network, preview, regional, cost, scale, and lifecycle constraints are acceptable.
- [ADR 0023](../design/decisions/0023-hyper-v-azure-monitor-through-arc-enabled-scvmm.md)
  and [ADR 0037](../design/decisions/0037-hyper-v-azure-monitor-health-model-architecture.md)
  remain valid after lab evidence.

The Hyper-V SCOM Management Pack remains the comprehensive and independent delivery path.

See the [research record](azure-monitor-research.md) for evidence, gaps, and next spikes.

## Microsoft foundations to validate

- [Azure Arc-enabled SCVMM overview](https://learn.microsoft.com/en-us/azure/azure-arc/system-center-virtual-machine-manager/overview)
- [Choose the right Azure Arc service for machines](https://learn.microsoft.com/en-us/azure/azure-arc/choose-service)
- [Connected Machine Agent deployment options](https://learn.microsoft.com/en-us/azure/azure-arc/servers/deployment-options)
- [Azure Monitor Agent overview](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [Health models in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/overview)
