---
title: Hyper-V Azure Monitor roadmap
description: Conditional Azure Monitor health-model research for Hyper-V through Azure Arc-enabled SCVMM.
---

# Azure Monitor for Hyper-V through Arc-enabled SCVMM

This is a **conditional future track**, not a committed implementation. It applies only to a
Hyper-V environment integrated with Azure Arc-enabled SCVMM and only if the research proves a
supportable entity, telemetry, identity, and operations model.

::: warning Research gate
Do not interpret Arc-enabled SCVMM inventory as proof that every host or VM has guest telemetry.
The research must distinguish SCVMM inventory projected through Arc Resource Bridge from machines
that also have Azure Arc-enabled Servers guest management, Azure Monitor Agent, and applicable
Data Collection Rules.
:::

## Required spikes

| Spike | Question |
|---|---|
| Arc-enabled SCVMM inventory and guest management | Which clusters, hosts, networks, and VMs become Azure resources, and when can guest management be enabled? |
| Telemetry and Health Models proof of concept | Can supported AMA, DCR, Resource Graph, metrics, logs, and health objectives produce a useful Hyper-V model? |
| Go/no-go decision | Is the result supportable and valuable enough to implement, defer, or reject? |

## Go criteria

Implementation can move out of the future backlog only when all of these are true:

- Microsoft-supported Arc-enabled SCVMM versions and topology are documented.
- A minimum viable entity graph can be identified with stable Azure resource identities.
- Supported telemetry covers meaningful host, cluster, VM, storage, and networking health.
- A lab fault changes the expected Azure Monitor health state within an acceptable window.
- Identity, RBAC, network, preview, regional, cost, scale, and lifecycle constraints are acceptable.
- Proposed [ADR 0023](../design/decisions/0023-hyper-v-azure-monitor-through-arc-enabled-scvmm.md)
  is accepted with a **go** decision.

Until then, the Hyper-V SCOM Management Pack remains the committed delivery path.

## Microsoft foundations to validate

- [Azure Arc-enabled SCVMM overview](https://learn.microsoft.com/en-us/azure/azure-arc/system-center-virtual-machine-manager/overview)
- [Choose the right Azure Arc service for machines](https://learn.microsoft.com/en-us/azure/azure-arc/choose-service)
- [Connected Machine Agent deployment options](https://learn.microsoft.com/en-us/azure/azure-arc/servers/deployment-options)
- [Azure Monitor Agent overview](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [Health models in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/overview)
