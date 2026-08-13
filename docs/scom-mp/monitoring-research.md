---
title: Azure Local SCOM monitoring research
description: Exhaustive local signal inventory, evidence status, research spikes, and threshold questions for the Azure Local Management Pack.
---

# Azure Local SCOM monitoring research

This is the raw research inventory for the local Management Pack. It intentionally contains more
signals than the default product. **Collectable does not mean enabled, health-impacting, or
pageable.**

The current development implementation is documentation- and contract-validated. Command shape,
provider availability, counter names, event behavior, latency, recovery, and overhead still require
the representative Azure Local and SCOM lab.

## Research spikes

| Spike | Question | Required output |
|---|---|---|
| Support matrix | Which Azure Local, SCOM, node-count, stretched-cluster, and hardware combinations are supported? | Version matrix and tested fixture IDs |
| Local topology | Do stable keys reconcile across node contributions, owner change, restart, replacement, and grooming? | Object/relationship snapshots and lifecycle timing |
| Health Service | Which current fault types, severities, associations, and recovery timings appear in each target release? | Fault catalog, injected condition, observed state, recovery |
| Storage | Which pool, volume, CSV, disk, storage job, enclosure, cache, and repair signals are safe defaults? | Raw inventory, workflow mapping, cardinality, cost |
| Network ATC | Which intent properties and status values occur during deployment, convergence, drift, remediation, and failure? | State machine, events, fault injections |
| Registration/platform | Which local registration, Arc, MOC, resource-bridge, and extension states are stable and supported? | Local source contract and Microsoft-support boundaries |
| Lifecycle | Which solution update environment, update, run, step, and health states are actionable? | Update state machine and maintenance behavior |
| Performance | Which local counters and Cluster Performance History series exist by version/hardware? | Counter export, unit/instance mapping, collection cost |
| Events and logs | Which providers, channels, IDs, schemas, and correlation keys are stable? | Exported manifests, captured events, suppression keys |
| Threshold engineering | What duration, recovery, reserve, and topology context makes each candidate actionable? | Evidence worksheet and tuned profile proposal |
| SCOM runtime | Do embedded providers cook down and run under every target HealthService runtime? | Workflow traces, event log, agent CPU/memory |
| Release lifecycle | Do import, upgrade, override preservation, rollback, and removal behave safely? | Repeatable certification report |

## Authoritative local state sources

| Area | Candidate interfaces | Data |
|---|---|---|
| Cluster | Get-Cluster, Get-ClusterNode, Get-ClusterQuorum, Get-ClusterGroup, Get-ClusterResource | Identity, membership, votes, quorum/witness, roles, owners, state |
| CSV | Get-ClusterSharedVolume | Owner, path, online state, redirected access |
| Health Service | Get-HealthFault | Fault ID/type, severity, reason, recommendation, object, physical location, create/update/remove |
| Health actions | Get-HealthAction and storage jobs where available | Repair/remediation action, progress, duration, failure |
| Storage subsystem | Get-StorageSubSystem, Get-StoragePool, Get-VirtualDisk, Get-Volume | Health, operational state, capacity, resiliency, read-only, allocation |
| Physical storage | Get-PhysicalDisk, Get-StorageReliabilityCounter | Identity, serial, media/bus/usage, location, health, wear, temperature, errors |
| Network ATC | Get-NetIntent, Get-NetIntentStatus | Intent, traffic role, adapters, configuration/provisioning state, last update |
| Registration | Get-AzureStackHCI | Registration, connection, last connected, Azure resource name/URI, verification state |
| Lifecycle | Get-SolutionUpdateEnvironment, Get-SolutionUpdate, Get-SolutionUpdateRun | Current solution, package, readiness, health, progress, failed steps |
| Platform services | Get-Service plus product-specific diagnostics | Cluster, Arc, extension, MOC, VM-management service presence/state |
| Host | CIM and Windows counters | Hardware, OS, CPU, memory, network, disk |
| Pipeline | SCOM workflow state and product events | Last success, exception, duration, object count, freshness |

Microsoft documents that Health Service faults provide severity, reason, recommended action, affected
object, and physical location, and that root-cause analysis suppresses consequential noise. That is
why the default design pages on the root fault instead of every derived drive symptom:
[Health Service faults](https://learn.microsoft.com/en-us/azure/azure-local/manage/health-service-faults).

## Performance metric inventory

Microsoft currently publishes more than 60 Azure Local platform metrics through the telemetry and
diagnostics extension. The cloud list is also the cross-track parity checklist for local SCOM
research; each metric must be mapped to Cluster Performance History, a stable Windows counter, a
scripted provider, or an explicit unsupported result.

### Node and compute

- Percentage CPU; Percentage CPU Guest; Percentage CPU Host.
- Cluster node Memory Total, Available, and Used.
- Percentage Memory, Percentage Memory Guest, and Percentage Memory Host.
- Cluster node CSV cache Read Hit, Read Hit rate, and Read Miss.
- Cluster node Storage Degraded.
- Optional GPU: Percentage GPU, Percentage GPU Memory, GPU Temperature, GPU Graphics Clock Speed,
  and GPU Memory Clock Speed when supported GPU partitioning and drivers are present.

### Physical drives

- Read Operations/sec, Write Operations/sec, and combined Read and Write Operations/sec.
- Read Bytes/sec, Write Bytes/sec, and combined Read and Write throughput.
- Read latency, write latency, and average latency.
- Total capacity and used capacity.
- Reliability candidates: temperature, wear, read/write/uncorrectable errors, and power-on hours,
  subject to vendor exposure and lab validation.

### Network adapters

- Network In/sec, Network Out/sec, and Network Total/sec.
- RDMA inbound, outbound, and total bandwidth.
- Candidate diagnostics: link speed/state, errors/discards, RDMA operational state, SMB Direct
  connections, SET membership, and intent-to-adapter mapping.

### Volumes and CSVs

- Read Operations/sec, Write Operations/sec, and combined operations.
- Read Bytes/sec, Write Bytes/sec, and combined throughput.
- Read latency, write latency, and average latency.
- Total size and available size.
- Candidate state: health, operational status, owner, redirected access/reason, resiliency,
  repair progress, and free-capacity trend.

### VHD and VM series

The Azure platform exposes VHD operations, throughput, latency, current/max size and VM CPU, memory,
pressure, and virtual-network throughput. They remain raw research inputs only. The core Azure Local
MP monitors infrastructure, not customer guest workloads; these series are candidates for a future
workload companion or collection-only dashboard, not default infrastructure health.

See the current Microsoft metric names, units, aggregations, and dimensions:
[Monitor Azure Local with Azure Monitor Metrics](https://learn.microsoft.com/en-us/azure/azure-local/manage/monitor-cluster-with-metrics).

Cluster Performance History provides curated live cluster, server, and volume metrics through one
cmdlet. Microsoft documents those values as point-in-time when queried from PowerShell:
[Cluster Performance History](https://learn.microsoft.com/en-us/azure/azure-local/manage/health-service-cluster-performance-history).

## Events and logs

The default development MP uses four established System-log Failover Clustering conditions:

| Provider | Event | Meaning |
|---|---:|---|
| Microsoft-Windows-FailoverClustering | 1135 | Node removed from active cluster membership |
| Microsoft-Windows-FailoverClustering | 1069 / 1205 | Cluster resource or role failure |
| Microsoft-Windows-FailoverClustering | 5120 | CSV access failure |
| Microsoft-Windows-FailoverClustering | 5142 | CSV no longer accessible |

The lab spike must enumerate every available event channel and provider manifest on each target
version before adding more event IDs. Candidate families include Failover Clustering operational and
diagnostic channels, Storage Spaces Direct/Space Manager, Storage Health, Network ATC, Azure Local
registration, Arc agents, MOC, resource bridge, solution updates, and SCOM HealthService. Event
absence is never proof of Healthy; state-bearing signals require a current-state source.

## What should be monitored first

| Priority | Default decision | Examples |
|---|---|---|
| Must | Health-impacting and normally alertable | Cluster Service, node membership, quorum, root Health Service faults, unhealthy pool/volume, CSV inaccessible, failed Network ATC intent, registration failure, required platform service failure, failed update, pipeline failure |
| Should | Health-impacting but alert policy needs evidence | Single physical-disk degradation, repair duration, available capacity trend, Arc disconnection duration, update readiness warnings |
| Could | Useful diagnostics or optional collection | Enclosure detail, cache efficiency, storage jobs, RDMA bandwidth, GPU metrics, detailed reliability counters |
| Collection only | Time series without default health/page | CPU, memory, throughput, IOPS, latency, host/guest split |
| Excluded from core | Different ownership boundary | Guest OS, application, customer VM expected state, pod/deployment health, cloud ARM resource configuration |

## Threshold and duration questions

A threshold is not accepted because it is common or round. Each proposal must record source,
topology, unit, aggregation, sample interval, consecutive samples or duration, reset threshold,
maintenance behavior, alert severity, auto-resolution, missing-data state, and lab evidence.

- Memory: use available host memory, host/guest split, pressure, paging, failover reserve, and trend.
  Do not page solely because used memory reached 75 percent.
- CPU: distinguish host from guest demand, require sustained duration, and verify schedulability and
  workload impact.
- Volume: combine percentage and absolute free bytes for large and small volumes; validate growth
  rate and repair reserve.
- Latency: segment by media, operation, volume/disk, cache state, queue depth, and sustained duration.
- Physical disks: map the deployment fault-tolerance model and active repair before escalating a
  count.
- Registration: separate brief connectivity loss from sustained disconnection and distinguish local
  platform service failure from Azure service availability.
- Updates: available content is informational; failed preparation/install and blocked critical
  health checks are actionable.

## Current implementation boundary

The authored development baseline includes the Must state families, 12 conservative Windows
performance collections, the four event rules above, a diagnostic task, operator knowledge, DA
rollup, and override generation. Four high-cardinality or counter-availability-sensitive collections
begin disabled. No release default is called certified until the research spikes and lab matrix
produce evidence.
