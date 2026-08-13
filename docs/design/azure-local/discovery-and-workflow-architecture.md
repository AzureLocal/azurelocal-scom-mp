---
title: Azure Local discovery and workflow architecture
description: Role seeding, topology acquisition, cookdown, targeting, and local provider behavior.
---

# Azure Local discovery and workflow architecture

## Discovery stages

1. The role-seed discovery targets Windows Server operating systems every four hours.
2. It requires Failover Clustering, a clustered storage subsystem, and Azure Local product or
   registration evidence.
3. The topology discovery runs every 30 minutes only on the discovered node role.
4. It contributes stable cluster-scoped objects, node-hosted objects, the DA, component instances,
   and typed membership relationships.

The seed deliberately does not treat the Hyper-V role alone as Azure Local.

## Local source map

| Source | Uses |
|---|---|
| FailoverClusters | Cluster identity, nodes, quorum, CSV owner/state/redirection, event correlation |
| Storage and Health Service | Pools, volumes, disks, active root-cause faults |
| NetworkATC | Intent identity, configuration status, provisioning status |
| Azure Local registration cmdlet | RegistrationStatus, ConnectionStatus, LastConnected |
| Solution update cmdlets | Environment version, update state, health, failed/attention states |
| Service Control Manager | Cluster, Arc, MOC, and VM-management service state |
| CIM and performance counters | Hardware facts, CPU, memory, disk, network, and capacity series |

## Cookdown contract

All 14 state monitors use the same data-source type and identical default acquisition configuration.
Changing one monitor configuration differently can split cookdown and increase script executions.
The administration guide therefore recommends group-scoped, profile-consistent overrides and
requires performance validation after interval changes.

## Failure semantics

- Seed failure logs an Operations Manager event and returns no new instance.
- Topology failure logs a separate event; it does not fabricate an empty healthy topology.
- Shared-probe failure sets every domain signal Critical and the pipeline branch Critical.
- Optional cmdlets are handled explicitly as Not Applicable, Warning, or Critical according to
  whether Azure Local requires that capability.
