---
title: Hyper-V Azure Monitor research
description: Arc-enabled SCVMM inventory, Arc-enabled Server telemetry, Health Models feasibility, limitations, and remaining evidence.
---

# Hyper-V Azure Monitor research

The research gate produced a **constrained go**. Azure Arc-enabled SCVMM provides a supported Azure
representation for VMM servers, clouds, virtual networks, templates, availability sets, and virtual
machines. Its inventory API does not expose first-class Hyper-V host, failover-cluster, CSV, physical
disk, or virtual-switch resources suitable for a comprehensive fabric health graph.

## Capability boundary

| Capability | Supported source | Result |
|---|---|---|
| VMM management-plane identity | `Microsoft.ScVmm/vmmServers` | Include as a Health Model Azure-resource entity |
| Cloud, VM network, template, VM inventory | Arc-enabled SCVMM inventory and enabled resources | Useful for context; not proof of infrastructure health |
| Hyper-V host operating-system telemetry | Arc-enabled Server + Azure Monitor Agent + DCR | Mandatory for hosts participating in health evaluation |
| Host heartbeat | Log Analytics `Heartbeat` | Initial freshness signal |
| Host performance | DCR Windows performance counters to `Perf` | Initial CPU signal; expand only after counter validation |
| Cluster/Hyper-V events | DCR Windows Event Log to `Event` | Initial high-confidence event signal |
| Host/cluster/storage/network topology | No complete supported projection established | Remains a material parity gap with SCOM |
| VM guest monitoring | Arc-enabled Server/VM insights | Separate workload concern; excluded from platform health v1 |

Azure Arc-enabled SCVMM is a superset of Arc-enabled Servers for VM lifecycle and guest-management
onboarding, but AMA is still a separate agent and data collection still requires DCR associations.
Inventory alone is not telemetry.

## Initial health signals

- per-host Heartbeat freshness;
- per-host Hyper-V hypervisor logical-processor total run time;
- recent Failover Clustering critical/error events from participating hosts; and
- monitoring-pipeline coverage, expressed as reporting hosts versus expected hosts.

CPU is a development signal rather than a universal released threshold. A host can run at high CPU
without business impact, and a cluster may retain workload capacity after losing a node. Released
rollup must be validated against cluster size, reserve, drain/maintenance, event recovery, signal
delay, and intended workload placement.

## Remaining spikes

1. Enumerate the live Arc-enabled SCVMM Resource Graph and inventory payload for VMM 2019, 2022,
   and 2025; verify identity stability across refresh, move, reconnect, and upgrade.
2. Prove the host Arc-enabled Server linking/onboarding path and document whether every supported
   topology can meet the dual-registration prerequisite.
3. Validate all DCR counter paths, event channels, table schemas, `_ResourceId` values, ingestion
   latency, and disconnected-host behavior.
4. Determine supported, affordable collection for cluster membership, quorum, CSV/storage,
   virtual switches, Network ATC, Replica, and SCVMM/SDN health.
5. Test Health Model state, Unknown, dependency propagation, alert deduplication, maintenance,
   recovery, scale, API region, RBAC, network, cost, and teardown.
6. Narrow or expand the supported entity/signal catalog through successor ADRs.

## Primary references

- [Arc-enabled SCVMM overview](https://learn.microsoft.com/en-us/azure/azure-arc/system-center-virtual-machine-manager/overview)
- [Enable SCVMM inventory resources](https://learn.microsoft.com/en-us/azure/azure-arc/system-center-virtual-machine-manager/enable-scvmm-inventory-resources)
- [Microsoft.ScVmm resource types](https://learn.microsoft.com/en-us/azure/templates/microsoft.scvmm/allversions)
- [Connected Machine agent for Arc-enabled SCVMM](https://learn.microsoft.com/en-us/azure/azure-arc/system-center-virtual-machine-manager/agent-overview-scvmm)
- [Azure Monitor Agent overview](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [Health models in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/overview)
