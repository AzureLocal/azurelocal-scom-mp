# ADR 0023 — Hyper-V Azure Monitor through Arc-enabled SCVMM

**Status:** Proposed  
**Date:** 2026-08-12  
**Decision gate:** Arc-enabled SCVMM inventory and telemetry proof-of-concept research

## Context

Azure Arc-enabled SCVMM can project private-cloud inventory into Azure and can support guest
management for eligible virtual machines. That does not by itself establish that Azure Monitor
Health Models can observe enough supported Hyper-V infrastructure signals to deliver a useful,
supportable product.

The project needs evidence for the ARM resource graph, guest-management path, telemetry sources,
Health Models entity design, identity and RBAC model, network requirements, preview constraints,
latency, cost, scale, and lifecycle operations.

## Proposed decision

Keep the Hyper-V Azure Monitor Feature in the conditional future roadmap. Select **go**, **defer**,
or **no-go** only after the two spikes complete and the evidence is reviewed.

A go decision must define:

- mandatory SCVMM, Arc Resource Bridge, Connected Machine agent, AMA, and DCR prerequisites;
- supported host, cluster, network, storage, and VM entity coverage;
- the minimum viable signal catalog and known parity gaps with SCOM;
- supported Azure regions and Health Models API versions;
- identity, RBAC, network, scale, cost, upgrade, and removal contracts; and
- fault-injection and release validation gates.

## Current constraints

- Azure Arc-enabled SCVMM inventory and Azure Arc-enabled Servers guest management are distinct
  capabilities and must be evaluated separately.
- Undocumented APIs or unsupported scraping are not acceptable product dependencies.
- No implementation story may become active before this ADR is accepted with a go decision.

## References

- [Azure Arc-enabled SCVMM overview](https://learn.microsoft.com/en-us/azure/azure-arc/system-center-virtual-machine-manager/overview)
- [Choose the right Azure Arc service for machines](https://learn.microsoft.com/en-us/azure/azure-arc/choose-service)
- [Connected Machine Agent deployment options](https://learn.microsoft.com/en-us/azure/azure-arc/servers/deployment-options)
- [Azure Monitor Agent overview](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [Health models in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/overview)
