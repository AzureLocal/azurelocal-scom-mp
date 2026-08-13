# ADR 0023 — Hyper-V Azure Monitor through Arc-enabled SCVMM

**Status:** Accepted — constrained go

**Date:** 2026-08-13
**Decision gate:** Arc-enabled SCVMM inventory and telemetry proof-of-concept research

## Context

Azure Arc-enabled SCVMM can project private-cloud inventory into Azure and can support guest
management for eligible virtual machines. That does not by itself establish that Azure Monitor
Health Models can observe enough supported Hyper-V infrastructure signals to deliver a useful,
supportable product.

The project needs evidence for the ARM resource graph, guest-management path, telemetry sources,
Health Models entity design, identity and RBAC model, network requirements, preview constraints,
latency, cost, scale, and lifecycle operations.

## Decision

Proceed with a constrained development track. Arc-enabled SCVMM is mandatory for management-plane
inventory, but it is not sufficient for host-fabric monitoring. Every Hyper-V host included in
health evaluation must also be represented as an Arc-enabled Server, have Azure Monitor Agent, and
be associated with the solution's evidence-backed Data Collection Rule.

The supported development boundary is:

- Arc-enabled SCVMM supplies the VMM server, cloud, network, template, and VM inventory projection;
- Arc-enabled Server plus AMA/DCR supplies guest-OS telemetry from the Hyper-V hosts;
- the first Health Model covers management connectivity, host heartbeat and CPU, selected
  Failover Clustering events, and telemetry coverage;
- storage, virtual-switch, Network ATC, SDN, Replica, and full cluster-state parity remain research
  gaps until supported telemetry is proven;
- VM guest/workload health is outside the Hyper-V infrastructure product even when inventory is
  available; and
- Health Models API `2025-05-03-preview` remains a preview dependency.

Release still requires:

- supported Azure and Arc-enabled SCVMM regions;
- identity, RBAC, network, scale, cost, upgrade, and removal contracts; and
- lab fault-injection, telemetry latency, state propagation, recovery, and teardown evidence.

## Current constraints

- Azure Arc-enabled SCVMM inventory and Azure Arc-enabled Servers guest management are distinct
  capabilities and must be evaluated separately.
- Undocumented APIs or unsupported scraping are not acceptable product dependencies.
- An SCVMM inventory object does not prove that a corresponding health signal exists.
- A development baseline may proceed; it must not be described as feature-parity or production-ready.

## References

- [Azure Arc-enabled SCVMM overview](https://learn.microsoft.com/en-us/azure/azure-arc/system-center-virtual-machine-manager/overview)
- [Choose the right Azure Arc service for machines](https://learn.microsoft.com/en-us/azure/azure-arc/choose-service)
- [Connected Machine Agent deployment options](https://learn.microsoft.com/en-us/azure/azure-arc/servers/deployment-options)
- [Azure Monitor Agent overview](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [Health models in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/overview)
