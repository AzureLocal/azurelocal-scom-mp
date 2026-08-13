# ADR 0037 — Hyper-V Azure Monitor Health Model architecture

- **Status**: Accepted
- **Date**: 2026-08-13
- **Deciders**: Hybrid Solutions Cloud maintainers

## Context

ADR 0023 now permits a constrained Hyper-V Azure Monitor development track. The model needs clear
separation between SCVMM management-plane inventory, Arc-enabled Server guest telemetry from
Hyper-V hosts, Azure Monitor collection, and health evaluation. It must not imply that Arc-enabled
SCVMM natively exports every Hyper-V fabric signal.

## Decision

The first development baseline will:

- deploy a separate Azure Monitor account and Health Model at API `2025-05-03-preview`;
- model a Hyper-V service with Compute, Storage, Network, Virtualization Management, Lifecycle, and
  Monitoring Pipeline components;
- represent the Arc-enabled SCVMM server as an Azure-resource entity;
- represent each participating Hyper-V host by its `Microsoft.HybridCompute/machines` resource ID;
- use Log Analytics signals for per-host heartbeat and Hyper-V CPU, cluster critical/error event
  count, and fleet telemetry coverage;
- provide a Windows DCR that collects selected Hyper-V and Failover Clustering performance/event
  streams, while leaving host association as an explicit customer deployment step;
- alert only on deployment health-state changes; and
- keep storage, network, lifecycle, and richer cluster signals visibly incomplete until supported
  collection and lab behavior are proven.

## Consequences

- Arc-enabled SCVMM and Arc-enabled Server are both required for the intended product.
- The health model remains independent of the Hyper-V SCOM MP.
- Log Analytics query cost and delay are part of the health contract.
- Host-resource IDs are deployment parameters and are never committed customer values.
- A lab must validate DCR schemas, table routing, entity evaluation, unknown state, fault/recovery,
  and cleanup before release.

## References

- [Arc-enabled SCVMM overview](https://learn.microsoft.com/en-us/azure/azure-arc/system-center-virtual-machine-manager/overview)
- [Arc-enabled SCVMM inventory resources](https://learn.microsoft.com/en-us/azure/azure-arc/system-center-virtual-machine-manager/enable-scvmm-inventory-resources)
- [Azure Monitor Agent overview](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [Health models in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/overview)
