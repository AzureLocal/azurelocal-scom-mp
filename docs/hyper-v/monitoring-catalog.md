---
title: Hyper-V monitoring catalog policy
description: Research schema, prioritization policy, and threshold principles for the Hyper-V SCOM Management Pack.
---

# Hyper-V monitoring catalog policy

This page is the phase-one contract for building the Hyper-V signal catalog. It is not yet the
completed catalog. Candidate rows are promoted only after the applicable inventory, workflow,
threshold, and lab spikes provide evidence.

## Required coverage

| Domain | Candidate coverage |
|---|---|
| Platform and topology | OS and role version, host identity, standalone/cluster membership, VM ownership, entity keys, and relationships |
| Host availability | Computer/agent reachability, Hyper-V services, Cluster service where applicable, role and feature state, restart/reboot state |
| CPU and scheduler | Hypervisor logical/root/virtual processor runtime, guest/hypervisor split, dispatch/wait behavior, interrupts, DPC, NUMA, and allocation configuration |
| Memory | Host available memory, root reserve, committed memory, paging, dynamic-memory balancer state, VM assigned/demand/pressure, and NUMA compatibility |
| VM health | State, status, heartbeat/integration services, configuration, generation/version, automatic actions, checkpoints, uptime, and critical events |
| Failover Cluster | Cluster and node state, quorum/witness, groups, resources, clustered VM roles, ownership, failover behavior, networks, and validation findings |
| CSV | State, pause, redirected I/O, ownership, free space, I/O latency/throughput/errors, cache use, and relevant events |
| Storage | Physical/logical volumes, SMB/SAN/virtual FC where applicable, VHD/VHDX metadata, capacity, latency, queues, errors, fragmentation, QoS, and differencing chains |
| Networking | Network ATC intent/status/drift where supported; physical adapters, teams/SET where applicable, virtual switches, extensions, ports, VM adapters, VLAN/QoS, VMQ, vRSS, SR-IOV, bandwidth, queues, errors, and drops; SCVMM/SDN authority where selected |
| Mobility | Live migration, storage migration, drain, placement, compatibility, authentication, duration, throughput, and failure events |
| Replica and recovery | Replication state/health, lag, frequency, errors, relationship, last successful replication, and RPO policy |
| Configuration and reliability | Time synchronization, updates, pending reboot, driver/firmware facts exposed by Windows, unexpected role drift, and reliability events |
| Monitoring pipeline | Discovery and workflow failures, timeouts, script errors, stale data, agent health, cardinality, data volume, and duplicate-event behavior |

Guest application and workload health is excluded. Host-observable VM state and integration-service
health remain in scope because they describe whether the virtualization platform is delivering the
VM service.

## Raw inventory row

Every technically available candidate must record:

| Field | Meaning |
|---|---|
| Platform version | Windows Server, Hyper-V, SCOM, cluster level, and optional SCVMM version tested |
| Topology applicability | Standalone, clustered, shared-nothing, CSV, SMB, SAN, Replica, or other supported variant |
| Entity | Exact object the signal describes and the stable correlation key |
| Category | Metric, performance counter, event/log, state, service, configuration, capacity, relationship, or synthetic test |
| Source | Counter path, log/provider/event, PowerShell property, CIM/WMI class/property, registry value, or test |
| Semantics | Units, instance behavior, aggregation, reset/wrap behavior, missing-data meaning, and known caveats |
| Access and cost | Required privilege/Run As, interval, expected cardinality, agent cost, network volume, and database volume |
| Evidence | Source URL or MP element plus fixture, command, observed result, and capture date |
| Disposition | Unreviewed, candidate, duplicate, unsupported, unstable, too costly, or excluded |

## Curated monitoring row

Candidates that survive research add the authoring contract:

| Field | Required decision |
|---|---|
| Health dimension | Availability, Performance, Configuration, Security, or no health impact |
| SCOM implementation | Target class and discovery, unit/aggregate/dependency monitor, rule, task, or view |
| Default | ON monitor, OFF monitor, collection rule, diagnostic/on-demand, or excluded |
| Severity and rollup | Warning/Critical behavior, alert priority, parent impact, and dependency suppression |
| Condition | State/event expression or numeric/baseline condition with warning and critical bands |
| Time behavior | Sample interval, consecutive samples or duration, hysteresis, reset/recovery, and alert closure |
| Operational knowledge | Probable causes, validation steps, remediation, escalation, and related performance views |
| Confidence | High, medium, or low with the exact evidence that supports the decision |

## Selection classes

| Class | Default behavior | Use when |
|---|---|---|
| Must monitor | Enabled and health-impacting | A supported, actionable failure threatens availability, data integrity, or cluster/VM service delivery |
| Should monitor | Usually enabled; tuning may be expected | A sustained condition predicts material degradation and has a credible operator response |
| Could monitor | Authored disabled with overrides | Value depends heavily on topology, workload, hardware, or local policy |
| Collect only | Performance/event rule without health impact | Trend and diagnosis value is high but a universal alert threshold is not defensible |
| Diagnostic | On-demand task or troubleshooting view | Collection is expensive, high-volume, privileged, or useful only after another symptom |
| Excluded | No shipped workflow | The signal is unsupported, redundant, unactionable, application-specific, unstable, or too costly |

## Threshold policy

Thresholds are conditions over time, not isolated numbers. Each threshold decision includes the
counter semantics, entity, topology, warning and critical bands, sample interval, duration or
consecutive samples, recovery condition, hysteresis, dependency behavior, maintenance suppression,
and evidence confidence.

Microsoft's Hyper-V guidance supplies several useful starting points:

| Signal | Published guidance | Research use |
|---|---|---|
| Hypervisor logical processor total runtime | More than 90% indicates an overloaded host | Candidate critical threshold; duration and recovery require lab validation |
| Physical NIC throughput | At least 90% of capacity indicates a network bottleneck | Capacity-relative candidate; link speed and multi-NIC topology must be handled |
| Physical disk read/write latency | Consistently more than 50 ms indicates a storage bottleneck | Candidate critical band; storage class and aggregation must be considered |
| Host memory | Evaluate `Memory\Available MBytes` and `Hyper-V Dynamic Memory Balancer(*)\Available Memory` when memory is low | Use available/reserve and pressure evidence; no universal utilization percentage is supplied |
| SCOM consecutive performance samples | Two or three samples is typical | Starting noise-control pattern, not a universal requirement |
| SCOM performance sampling | Five to fifteen minutes is typical | Starting interval range; availability events may require much faster detection |

Current Veeam ONE documentation is retained as an external benchmark, not a Microsoft support
contract. Its Hyper-V defaults include 15-minute CPU bands of 75%/85%, host memory-pressure bands of
90%/100%, VM memory-pressure bands of 110%/125%, CSV or local-volume free-space bands of 10%/5%, and
storage-latency bands of 40/80 ms. Threshold research must reconcile those values with Microsoft semantics and
our own lab evidence before any become defaults.

::: warning Should host memory alert at 75%?
Not by itself. A host at 75% used memory can be healthy, while another host at a lower percentage can
be unable to satisfy VM demand or preserve the management partition. The default design should
combine available memory or host reserve, Hyper-V dynamic-memory pressure, paging evidence, and
sustained duration. A percentage may remain useful for capacity trending or an optional policy tier,
but it is not accepted as the sole phase-one health condition.
:::

## Microsoft Hyper-V 2019 MP boundary

The Microsoft System Center 2019 Management Pack for Hyper-V is a research source, not part of this
product's dependency model. Reference analysis may extract useful entity concepts, monitoring scenarios,
signals, thresholds, alert knowledge, and lessons from its guide and exported elements. Every reused
idea must be checked against current Windows Server behavior, current Microsoft documentation, and
our lab results.

The new Management Pack will not import, extend, override, or require the Microsoft Hyper-V 2019
MP. It will define and ship its own supported classes, discoveries, monitors, rules, knowledge, and
views. Research must document semantic provenance, but implementation must use this project's own
namespaces and independently validated workflows.

## Noise and recovery rules

- State and authoritative failure events can alert quickly; resource pressure generally must be
  sustained.
- Warning and Critical entry bands need lower recovery bands or another hysteresis mechanism.
- A parent dependency failure should suppress predictable child symptoms where SCOM targeting and
  health rollup permit it.
- Planned VM state, cluster maintenance, node drain, backup/checkpoint activity, and migration must
  not look like unplanned failure.
- Missing data must resolve to a documented state such as Unknown or monitoring failure, not silently
  to Healthy.
- High-cardinality counters can be diagnostic or collected selectively even when they are valuable.
- Percentage capacity thresholds should be paired with absolute reserve where scale makes percentage
  alone misleading.

## Initial authoritative sources

- [Microsoft: detecting bottlenecks in a virtualized environment](https://learn.microsoft.com/en-us/windows-server/administration/performance-tuning/role/hyper-v-server/detecting-virtualized-environment-bottlenecks)
- [Microsoft: Hyper-V memory performance](https://learn.microsoft.com/en-us/windows-server/administration/performance-tuning/role/hyper-v-server/memory-performance)
- [Microsoft: Hyper-V storage I/O performance](https://learn.microsoft.com/en-us/windows-server/administration/performance-tuning/role/hyper-v-server/storage-io-performance)
- [Microsoft: Hyper-V network I/O performance](https://learn.microsoft.com/en-us/windows-server/administration/performance-tuning/role/hyper-v-server/network-io-performance)
- [Microsoft: troubleshoot Hyper-V VM performance](https://learn.microsoft.com/en-us/troubleshoot/windows-server/virtualization/troubleshoot-hyper-v-virtual-machine-performance)
- [Microsoft: manage Cluster Shared Volumes](https://learn.microsoft.com/en-us/windows-server/failover-clustering/failover-cluster-manage-cluster-shared-volumes)
- [Microsoft: Operations Manager process-monitoring sample and interval behavior](https://learn.microsoft.com/en-us/system-center/scom/process-monitoring-template?view=sc-om-2025)
- [Microsoft: System Center 2019 Management Pack for Hyper-V](https://www.microsoft.com/en-us/download/details.aspx?id=101312)
- [Veeam ONE: Microsoft Hyper-V alarm catalog](https://helpcenter.veeam.com/docs/one/userguide/hyperv_alarms_events.html)
