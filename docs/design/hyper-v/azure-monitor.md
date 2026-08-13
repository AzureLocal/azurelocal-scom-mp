---
title: Hyper-V Azure Monitor design
description: Constrained Azure Monitor Health Models development design for Hyper-V through Arc-enabled SCVMM and Arc-enabled Servers.
---

# Hyper-V Azure Monitor Health Models design

This lane now has a constrained development go. Arc-enabled SCVMM provides management inventory;
Arc-enabled Server, Azure Monitor Agent, and a Data Collection Rule provide telemetry from each
participating Hyper-V host. Inventory does not prove that a health signal exists.

## Current architecture

| Layer | Responsibility |
|---|---|
| Arc-enabled SCVMM | VMM server, cloud, network, template, availability-set, and VM management-plane inventory |
| Arc-enabled Server | Stable Azure identity for each participating Hyper-V host |
| AMA and Windows DCR | Host performance and selected Hyper-V/Failover Clustering events into Log Analytics |
| Azure Monitor Health Model | Deployment/domain/host entities, KQL signals, dependency rollup, and health-state alerts |
| Workbook | Investigation of host freshness, performance, events, and coverage |

The development baseline compiles with Bicep and includes VMM/host entities, a six-domain service
model, heartbeat, hypervisor CPU, cluster-event, and telemetry-coverage signals, a DCR, Lab
parameters, state alerts, research KQL, and a starter workbook.

## Known parity gaps

The current supported projection does not establish comprehensive host-cluster topology, quorum,
CSV/storage, virtual switch, Network ATC, SCVMM/SDN, Replica, or lifecycle health. These remain
research and lab gates. The solution must not be described as equivalent to the Hyper-V SCOM MP.

The Azure Local Azure Monitor entity graph, DCMA signals, prerequisites, and Bicep design are not
defaults for this lane. They can be used as comparison material only where the Hyper-V spikes prove
equivalent supported behavior.

Continue to the [product page](../../hyper-v/azure-monitor.md),
[research record](../../hyper-v/azure-monitor-research.md), and accepted
[architecture ADR](../decisions/0037-hyper-v-azure-monitor-health-model-architecture.md).
