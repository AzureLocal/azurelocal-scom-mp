# Signal Catalog

> The master list of every signal that drives a health state or collects data in this
> Management Pack. Each row is a contract: signal name, default state, source, threshold,
> and dimension.
>
> **Default column key:**
> - **ON** — monitor enabled by default; impacts health state
> - **OFF** — monitor is authored but ships disabled (`Enabled=false`); operator enables via override pack
> - **Rule** — data collection rule (perf/event collection only, no health-state change); always active

> **Status:** Drafted in Phase 2. Final values land at Phase 2 sign-off. Thresholds shown
> are **Standard tier** defaults — see [Customization](customization.md) for Lab/Strict tiers.

## Naming convention

Every signal has a stable cross-track name. See [ADR 0007](decisions/0007-naming-convention.md):

- **Logical name** (track-agnostic, used in this catalog): `Volume.FreeSpace.WarnPercent`
- **SCOM override property**: `Volume.FreeSpace.WarnPercent`
- **Azure Monitor Bicep param**: `volumeFreeSpaceWarningThresholdPct`

---

## Layer 1 — On-prem signals

### Cluster

| Logical name | Default | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|---|
| `Cluster.Service.State` | ON | Availability | Running | — | Stopped/Degraded | `Get-ClusterResource "Cluster Name"` | DCMA `cluster_status` |
| `Cluster.Quorum.State` | ON | Availability | Normal | NoWitness | Failed | `Get-ClusterQuorum` | KQL `MicrosoftHCI_Cluster_Quorum` |
| `Cluster.Quorum.Witness.Reachable` | ON | Availability | Reachable | — | Unreachable | `Get-ClusterQuorum` witness type + `Test-NetConnection` to witness endpoint | KQL on cluster event log |
| `Cluster.Quorum.WitnessType` | OFF | Configuration | CloudWitness or FileShare | — | None (no witness configured) | `Get-ClusterQuorum \| .WitnessType` | KQL |
| `Cluster.NodeCount.Live` | ON | Availability | All | n-1 | < n-1 | `Get-ClusterNode` | DCMA `cluster_node_count` |
| `Cluster.FunctionalLevel.Current` | OFF | Configuration | Matches OS | — | Below OS version (upgrade pending) | `(Get-Cluster).ClusterFunctionalLevel` vs `(Get-Cluster).ClusterUpgradeVersion` | KQL |
| `Cluster.Validation.Warnings` | OFF | Configuration | 0 | ≤ 5 | > 5 | `Test-Cluster -List Inventory` | KQL on Event log |
| `Cluster.EnvironmentChecker.Pass` | OFF | Configuration | All pass | ≥ 1 warning | ≥ 1 failure | `Invoke-AzureStackHCIEnvironmentChecker` | KQL on Health event log |
| `Cluster.DNS.Suffix.Configured` | OFF | Configuration | Present | — | Missing (DNS suffix required for cluster name resolution) | Registry `HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters` → `SearchList` | KQL |
| `Cluster.TimeSync.MaxOffsetSeconds` | OFF | Configuration | < 5 | 5–30 | > 30 | `w32tm /query /status` on each node (cookdown max) | KQL `Event` from W32TM |
| `Cluster.CSV.Ownership.Balance` | OFF | Configuration | Even (±1 node) | Imbalanced by 2 | All on 1 node | `Get-ClusterSharedVolume \| .OwnerNode` distribution | KQL |
| `Cluster.CSV.Paused.Count` | ON | Availability | 0 | ≥ 1 | — | `Get-ClusterSharedVolume \| Where State -eq 'Paused'` | KQL on cluster event |
| `Cluster.ResourceGroup.Failed.Count` | ON | Availability | 0 | — | ≥ 1 | `Get-ClusterGroup \| Where State -eq 'Failed'` | KQL |
| `Cluster.ResourceGroup.Offline.Count` | OFF | Availability | 0 | — | ≥ 1 unexpected | `Get-ClusterGroup \| Where State -eq 'Offline'` | KQL |
| `Cluster.Event.NodeLost` | ON | Availability | 0 | — | ≥ 1 | Event log `System` Event ID 1135 (cluster node lost) | KQL `Event` |
| `Cluster.Event.ResourceFailed` | ON | Availability | 0 | — | ≥ 1 | Event log `System` Event ID 1069 (resource failed) | KQL `Event` |
| `Cluster.Event.DriveRemoved` | ON | Availability | 0 | — | ≥ 1 | Event log `Microsoft-Windows-Health/Operational` (disk removed) | KQL `Event` |
| `LCM.Environment.Health` | ON | Availability | Healthy | — | Failed/Error | `Get-SolutionUpdateEnvironment` → `.State` | KQL |
| `LCM.Update.PendingCritical` | ON | Configuration | 0 | — | ≥ 1 | `Get-SolutionUpdate \| Where State -eq 'Failed'` | KQL |
| `LCM.Update.LastRunResult` | ON | Configuration | Succeeded | — | Failed | `Get-SolutionUpdate \| Sort InstalledDate -Desc \| Select -First 1` | KQL |
| `LCM.Update.Available.Days` | OFF | Configuration | < 30 | 30–60 | > 60 | `Get-SolutionUpdate \| Where State -eq 'Ready'` age | ARM property + KQL |
| `LCM.Update.NodeVersionDrift` | OFF | Configuration | Aligned | 1 node behind | > 1 node behind | `Get-SolutionUpdateEnvironment` per-node versions | KQL |
| `LCM.Update.PreCheckFailed` | ON | Configuration | Passed | — | Failed | `Get-SolutionUpdateEnvironment` → pre-check result | KQL |

### Node

| Logical name | Default | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|---|
| `Node.Up.State` | ON | Availability | Up | — | Down/Paused | `Get-ClusterNode \| .State` | Resource Health on `HybridCompute/machines` |
| `Node.CPU.Percent` | ON | Performance | < 70 | 70–85 | > 85 | Perf counter `\Processor(_Total)\% Processor Time` | DCMA `node_cpu_usage_percentage` |
| `Node.CPU.Queue.Length` | OFF | Performance | < 4 | 4–8 | > 8 | Perf counter `\System\Processor Queue Length` | DCMA |
| `Node.Memory.Percent` | ON | Performance | < 75 | 75–90 | > 90 | Perf counter `\Memory\% Committed Bytes In Use` | DCMA `node_memory_usage_percentage` |
| `Node.Memory.Available.GB` | OFF | Performance | > 8 | 4–8 | < 4 | Perf counter `\Memory\Available MBytes` | DCMA |
| `Node.Memory.NonPagedPool.MB` | OFF | Performance | < 2048 | 2048–3072 | > 3072 | Perf counter `\Memory\Pool Nonpaged Bytes` | KQL |
| `Node.Memory.PageFile.Percent` | OFF | Performance | < 50 | 50–80 | > 80 | Perf counter `\Paging File(_Total)\% Usage` | KQL |
| `Node.Memory.HardFaults.Sec` | OFF | Performance | 0 | > 0 | > 10 | Perf counter `\Memory\Page Faults/sec` | KQL |
| `Node.OS.UptimeDays` | ON | Configuration | < 60 | 60–90 | > 90 | WMI `Win32_OperatingSystem.LastBootUpTime` | KQL `Heartbeat` |
| `Node.PendingReboot` | OFF | Configuration | False | — | True | Registry `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending` | KQL `Event` |
| `Node.Maintenance.Mode` | ON | Availability | NotInMaintenance | InMaintenance > 4h | — | `Get-ClusterNode \| .NodeDrainStatus` | KQL |
| `Node.TimeSync.OffsetSeconds` | OFF | Configuration | < 5 | 5–30 | > 30 | `w32tm /query /status` → `Phase Offset` | KQL `Event` from `Microsoft-Windows-Time-Service/Operational` |
| `Node.TimeSync.Source.Reachable` | OFF | Availability | Reachable | — | Unreachable/Unsynchronized | `w32tm /query /status` → `Source` | KQL |
| `Node.SecureBoot.State` | OFF | Security | Enabled | — | Disabled | `Confirm-SecureBootUEFI` or `Get-SecureBootPolicy` | KQL |
| `Node.BitLocker.OSDrive.State` | OFF | Security | On | — | Off or Suspended | `Get-BitLockerVolume -MountPoint C` → `ProtectionStatus` | KQL |
| `Node.Defender.RealtimeProtection` | OFF | Security | Enabled | — | Disabled | `Get-MpComputerStatus` → `RealTimeProtectionEnabled` | KQL `Event` |
| `Node.Defender.SignatureAge.Days` | OFF | Security | < 3 | 3–7 | > 7 | `Get-MpComputerStatus` → `AntivirusSignatureAge` | KQL |
| `Node.Defender.ThreatDetection.Count` | OFF | Security | 0 | ≥ 1 | — | `Get-MpThreatDetection \| Measure-Object` | KQL `Event` |
| `Node.WindowsUpdate.PendingCritical` | OFF | Configuration | 0 | — | ≥ 1 | `Get-HotFix` + WSUS/WU query | KQL |
| `Node.BIOS.Firmware.Version` | OFF | Configuration | Current (vs. HCL matrix) | One version behind | Major version behind | WMI `Win32_BIOS.SMBIOSBIOSVersion` vs. validated matrix | KQL |
| `Node.Driver.NIC.Version` | OFF | Configuration | Current | One minor behind | Major behind | `Get-NetAdapter \| .DriverVersion` vs. HCI validated driver matrix | KQL |
| `Node.Driver.Storage.Version` | OFF | Configuration | Current | One minor behind | Major behind | `Get-StorageController \| .FirmwareVersion` vs. validated matrix | KQL |
| `Node.Disk.OS.FreeSpace.Percent` | ON | Performance | > 20 | 10–20 | < 10 | `Get-Volume -DriveLetter C` → `.SizeRemaining` | KQL |
| `Node.WinRM.State` | OFF | Availability | Running | — | Stopped | `Get-Service WinRM` | KQL |
| `Node.DNS.Azure.Resolution` | OFF | Availability | Resolves | — | Fails | `Resolve-DnsName management.azure.com` from node | KQL |
| `Node.DNS.Internal.Resolution` | OFF | Availability | Resolves | — | Fails | `Resolve-DnsName <cluster-fqdn>` from node | KQL |
| `Node.CrashDump.Configured` | OFF | Configuration | Enabled | — | Disabled or no space | Registry `HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl` | KQL |
| `Node.EventLog.System.Critical.Count` | OFF | Availability | 0 | — | ≥ 1 in last hour | Event log `System` Level=1 (Critical) count in window | KQL `Event` |
| `Node.EventLog.Application.Critical.Count` | OFF | Availability | 0 | — | ≥ 1 in last hour | Event log `Application` Level=1 (Critical) | KQL `Event` |
| `Node.WHEA.Error.Count` | OFF | Availability | 0 | ≥ 1 | ≥ 5 in 24h | Event log `Microsoft-Windows-WHEA-Logger/Operational` | KQL `Event` |
| `Node.WHEA.MemoryError.Count` | OFF | Availability | 0 | ≥ 1 | — | Event log `Microsoft-Windows-WHEA-Logger/Operational` ID 19 (memory) | KQL `Event` |
| `Node.BMC.Alerts` | OFF | Availability | 0 | ≤ 2 | > 2 | OEM-specific (Dell iDRAC APEX / HPE iLO / Lenovo XCC) | KQL on hardware event channel |
| `Node.Arc.AgentConnected` | ON | Availability | Connected | Stale (< 1h) | Disconnected | Registry proxy / local check (see Tier A below) | Resource Health on `HybridCompute/machines` |
| `Node.Certificate.Deployment.ExpiryDays` | OFF | Security | > 30 | 7–30 | < 7 | `Get-ChildItem Cert:\LocalMachine\My` filtered for deployment certs | KQL |
| `Node.Handles.Count` | OFF | Performance | < 50000 | 50000–80000 | > 80000 | Perf counter `\Process(_Total)\Handle Count` | KQL |
| `Node.LiveMigration.InProgress.Count` | Rule | Performance | — | — | — | `Get-VM \| Where State -eq 'Migrating'` | DCMA |
| `Node.SMB.Bandwidth.InboundMBps` | Rule | Performance | — | — | — | Perf counter `\SMB Client Shares(*)\Bytes Received/sec` | DCMA |
| `Node.SMB.Bandwidth.OutboundMBps` | Rule | Performance | — | — | — | Perf counter `\SMB Client Shares(*)\Bytes Sent/sec` | DCMA |

### Hyper-V Host

| Logical name | Default | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|---|
| `Node.HyperV.State` | ON | Availability | Running | — | Stopped/Degraded | `Get-VMHost` + Hyper-V VMMS service state | KQL on `Microsoft-Windows-Hyper-V-VMMS/Operational` |
| `Node.HyperV.vSwitch.Binding` | ON | Configuration | All NICs bound | — | vSwitch NIC binding missing | `Get-VMSwitch \| Get-VMSwitchTeam \| .NetAdapters` vs. `Get-NetIntent` | KQL |
| `Node.HyperV.VM.Running.Count` | Rule | Performance | — | — | — | `(Get-VM \| Where State -eq 'Running').Count` | DCMA |
| `Node.HyperV.vCPU.Overcommit.Ratio` | OFF | Performance | < 8:1 | 8–12:1 | > 12:1 | `(Get-VM \| Measure-Object -Sum ProcessorCount).Sum / (Get-VMHost).LogicalProcessorCount` | KQL |
| `Node.HyperV.Memory.Demand.Percent` | OFF | Performance | < 80 | 80–95 | > 95 | `(Get-VM \| Where State -eq 'Running' \| Measure-Object -Sum MemoryAssigned).Sum / (Get-VMHost).MemoryCapacity * 100` | DCMA |
| `Node.HyperV.Memory.Pressure.Index` | OFF | Performance | < 100 | 100–125 | > 125 | Perf counter `\Hyper-V Dynamic Memory Balancer\Average Pressure` | KQL |
| `Node.HyperV.VM.DynamicMemory.Pressure` | OFF | Performance | 0 VMs pressured | ≥ 1 | — | `Get-VMMemory \| Where DynamicMemoryEnabled -and Pressure -gt 100` | KQL |
| `Node.HyperV.Checkpoint.Count` | OFF | Configuration | 0 | ≥ 1 per VM | > 5 total | `Get-VMCheckpoint` count | KQL |
| `Node.HyperV.VM.StorageLatency.ms` | OFF | Performance | < 20 | 20–50 | > 50 | Perf counter `\Hyper-V Virtual Storage Device(*)\Read Latency` | DCMA |
| `Node.HyperV.Event.VMFailed` | ON | Availability | 0 | — | ≥ 1 | Event log `Microsoft-Windows-Hyper-V-VMMS/Operational` ID 18010 (VM failed) | KQL `Event` |
| `Node.HyperV.LiveMigration.Failed` | ON | Availability | 0 | — | ≥ 1 | Event log `Microsoft-Windows-Hyper-V-VMMS-Operational` IDs 20100/20101 | KQL `Event` |
| `Node.HyperV.VMQ.Adequacy` | OFF | Configuration | All VMs have VMQ | — | VMQ exhausted | `Get-VMNetworkAdapter \| Where VmqUsage -ne 'Enabled'` | KQL |
| `Node.HyperV.SRIOVActive` | OFF | Configuration | Enabled where expected | — | Not active (if SR-IOV configured in intent) | `Get-VMNetworkAdapter \| Where IovWeight -gt 0 \| .IovActive` | KQL |
| `Node.HyperV.Replica.State` | OFF | Availability | Enabled/Replicating | Warning | Critical/Error | `Get-VMReplication \| .State` | KQL on Hyper-V Replica event log |

### Storage Pool

| Logical name | Default | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|---|
| `StoragePool.HealthStatus` | ON | Availability | Healthy | Warning | Unhealthy | `Get-StoragePool` | DCMA `storagepool_health` |
| `StoragePool.OperationalStatus` | ON | Availability | OK | Degraded | Failed | `Get-StoragePool` | DCMA `storagepool_operational_status` |
| `StoragePool.Capacity.Percent` | ON | Performance | < 70 | 70–85 | > 85 | `Get-StoragePool` | DCMA `storagepool_capacity_used_percentage` |
| `StoragePool.Size.TiB` | Rule | Configuration | > 0 | — | Unexpected shrink | `(Get-StoragePool).Size / 1TB` | DCMA |
| `StoragePool.AllocatedSize.Percent` | OFF | Performance | < 70 | 70–85 | > 85 | `(Get-StoragePool).AllocatedSize / .Size * 100` | DCMA |
| `StoragePool.FreeSpace.TiB` | OFF | Performance | > 20% of .Size | 10–20% | < 10% | `(Get-StoragePool).RemainingCapacity / 1TB` | DCMA |
| `StoragePool.RetiredCapacity.TiB` | OFF | Configuration | 0 | > 0 | > 5% of total | `(Get-PhysicalDisk -Usage Retired \| Measure Size -Sum).Sum / 1TB` | DCMA |
| `StoragePool.Reserve.Policy` | ON | Configuration | Configured | — | Missing | `(Get-StoragePool).RetireMissingPhysicalDisks` | KQL |
| `StoragePool.ResiliencySetting` | OFF | Configuration | As expected (3-way/nested) | — | Downgraded | `Get-ResiliencySetting` | KQL |
| `StoragePool.ThinProvision.OverCommit.Percent` | OFF | Performance | < 100 | 100–120 | > 120 (over-provisioned) | `(Volumes.AllocatedSize.Sum) / StoragePool.Size * 100` | KQL |
| `StoragePool.RepairJobs.Active` | ON | Performance | 0 | 1–2 | > 2 active for > 24h | `Get-StorageJob` | KQL on Storage event log |
| `StoragePool.RebuildJob.PercentComplete` | ON | Performance | n/a (no job) | Running | Stalled (< 1% progress in 1h) | `Get-StorageJob \| Where JobState -eq 'Running' \| Select PercentComplete, ElapsedTime` | KQL |
| `StoragePool.RebuildJob.ETA.Hours` | OFF | Performance | n/a | < 8h | > 8h (extended exposure) | Derived from PercentComplete + ElapsedTime | KQL |
| `StoragePool.ScrubJob.LastRunAge.Days` | OFF | Configuration | < 14 | 14–30 | > 30 (scrub not running) | `Get-StoragePool \| .Version` + scrub event log | KQL `Event` |
| `StoragePool.ScrubJob.ErrorsFound` | OFF | Availability | 0 | ≥ 1 | — | Event log `Microsoft-Windows-StorageSpaces/Operational` | KQL `Event` |
| `StoragePool.PhysicalDisks.Failed` | ON | Availability | 0 | 1 (within fault tolerance) | > 1 | `Get-PhysicalDisk \| Where HealthStatus -ne Healthy` | DCMA `storagepool_failed_disks` |
| `StoragePool.FaultDomain.Count` | ON | Configuration | ≥ 2 | — | < 2 (pool degraded) | `Get-StorageFaultDomain` | KQL |
| `StoragePool.Read.Throughput.MBps` | Rule | Performance | — | — | — | Perf counter `\Storage Spaces Drt(*)\Read Bytes/sec` | DCMA |
| `StoragePool.Write.Throughput.MBps` | Rule | Performance | — | — | — | Perf counter `\Storage Spaces Drt(*)\Write Bytes/sec` | DCMA |
| `StoragePool.Read.IOPS` | Rule | Performance | — | — | — | Perf counter `\Storage Spaces Drt(*)\Read I/O Operations/sec` | DCMA |
| `StoragePool.Write.IOPS` | Rule | Performance | — | — | — | Perf counter `\Storage Spaces Drt(*)\Write I/O Operations/sec` | DCMA |
| `StoragePool.Read.Latency.ms` | OFF | Performance | < 20 | 20–50 | > 50 | Perf counter `\Storage Spaces Drt(*)\Read Latency` | DCMA |
| `StoragePool.Write.Latency.ms` | OFF | Performance | < 20 | 20–50 | > 50 | Perf counter `\Storage Spaces Drt(*)\Write Latency` | DCMA |

### Volume / CSV

| Logical name | Default | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|---|
| `Volume.HealthStatus` | ON | Availability | Healthy | Warning | Unhealthy | `Get-Volume` | DCMA `volume_health` |
| `Volume.OperationalStatus` | ON | Availability | OK | Degraded | Unknown/Failed | `Get-Volume` | DCMA `volume_operational_status` |
| `Volume.FreeSpace.Percent` | ON | Performance | > 25 | 10–25 | < 10 | `Get-Volume` | DCMA `volume_free_space_percentage` |
| `Volume.Size.TiB` | Rule | Configuration | > 0 | — | Unexpected shrink | `(Get-Volume).Size / 1TB` | DCMA |
| `Volume.AllocatedSize.TiB` | OFF | Performance | < 80% of .Size | 80–90% | > 90% | `(Get-Volume).SizeRemaining / .Size` | DCMA |
| `Volume.RedirectedIO.Active` | ON | Performance | False | True < 1h | True > 1h | `Get-ClusterSharedVolume` | KQL on cluster event |
| `Volume.RedirectedIO.Percent` | OFF | Performance | < 5 | 5–25 | > 25 | Perf counter `\Cluster CSV File System(*)\% Redirected Reads` | DCMA |
| `Volume.CSV.InMaintenance` | OFF | Configuration | False | — | True | `(Get-ClusterSharedVolume).SharedVolumeInfo.MaintenanceMode` | KQL |
| `Volume.IOPS.Read.Sec` | Rule | Performance | — | — | — | Perf counter `\Cluster CSV File System(*)\Reads/sec` | DCMA |
| `Volume.IOPS.Write.Sec` | Rule | Performance | — | — | — | Perf counter `\Cluster CSV File System(*)\Writes/sec` | DCMA |
| `Volume.Throughput.Read.MBps` | Rule | Performance | — | — | — | Perf counter `\Cluster CSV File System(*)\Read Bytes/sec` | DCMA |
| `Volume.Throughput.Write.MBps` | Rule | Performance | — | — | — | Perf counter `\Cluster CSV File System(*)\Write Bytes/sec` | DCMA |
| `Volume.Latency.Read.ms` | ON | Performance | < 20 | 20–50 | > 50 | Perf counter `\Cluster CSV File System(*)\Avg sec/Read` | DCMA `volume_latency_ms` |
| `Volume.Latency.Write.ms` | ON | Performance | < 20 | 20–50 | > 50 | Perf counter `\Cluster CSV File System(*)\Avg sec/Write` | DCMA |
| `Volume.QueueDepth` | OFF | Performance | < 64 | 64–256 | > 256 | Perf counter `\Cluster CSV File System(*)\Current Queue Length` | DCMA |
| `Volume.ReFS.IntegrityStream` | OFF | Configuration | Enabled (where expected) | — | Disabled | `Get-Item -Path <vol> \| Get-FileIntegrity` | KQL |
| `Volume.Dedup.Enabled` | Rule | Configuration | — | — | — | `Get-DedupVolume \| .Enabled` | KQL |
| `Volume.Dedup.SavedPercent` | OFF | Configuration | Match baseline | — | Unexpectedly low (dedup configured) | `Get-DedupVolume` → `.SavingsRate` | KQL |
| `Volume.Dedup.LastOptimizationAge.Days` | OFF | Configuration | < 3 | 3–7 | > 7 | `Get-DedupStatus` → `.LastOptimizationTime` | KQL |
| `Volume.ReFS.Compression.Enabled` | Rule | Configuration | — | — | — | `Get-Volume \| .FileSystemLabel` + `Get-Item` flag | KQL |
| `Volume.VSS.Writer.State` | OFF | Availability | Stable | — | Failed/waiting | `vssadmin list writers` → writer state | KQL `Event` from VSS |
| `Volume.Backup.LastSuccessAge.Days` | OFF | Configuration | < 1 | 1–3 | > 3 (backup missed) | Event log from backup solution or VSS | KQL |
| `Volume.Snapshot.Count` | OFF | Configuration | 0 | ≥ 1 | > 10 (snapshots accumulating) | `Get-VMCheckpoint` + VSS snapshot | KQL |

### Storage Tier (cache)

| Logical name | Default | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|---|
| `StorageTier.Cache.HitRatio` | ON | Performance | > 80 | 60–80 | < 60 | `Get-StorageTier` perf counters | DCMA `cache_hit_ratio` |
| `StorageTier.Cache.State` | ON | Availability | Bound | Unbinding | Failed | `Get-StorageTier` | DCMA |
| `StorageTier.Cache.DirtyPages.Percent` | ON | Performance | < 60 | 60–80 | > 80 | Perf counter `\Cluster Storage Cache Stores(*)\Cache Dirty Pages %` | DCMA |
| `StorageTier.Cache.MissRate` | OFF | Performance | < 20 | 20–40 | > 40 | Perf counter `\Cluster Storage Cache Stores(*)\Cache Miss Rate` | DCMA |
| `StorageTier.Cache.Read.Throughput.MBps` | Rule | Performance | — | — | — | Perf counter `\Cluster Storage Cache Stores(*)\Read Bytes From Cache/sec` | DCMA |
| `StorageTier.Cache.Write.Throughput.MBps` | Rule | Performance | — | — | — | Perf counter `\Cluster Storage Cache Stores(*)\Write Bytes to Cache/sec` | DCMA |
| `StorageTier.Cache.FlushRate.MBps` | OFF | Performance | < 80% capacity | — | At rated capacity sustained | Perf counter `\Cluster Storage Cache Stores(*)\Flush Bytes/sec` | DCMA |
| `StorageTier.Cache.DriveCount.Expected` | ON | Configuration | Match | — | Mismatch | `(Get-StorageTier -MediaType NVMe \| Get-PhysicalDisk).Count` | KQL |
| `StorageTier.Capacity.DriveCount.Expected` | ON | Configuration | Match | — | Mismatch | `(Get-StorageTier -MediaType HDD \| Get-PhysicalDisk).Count` | KQL |

### Physical Disk

| Logical name | Default | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|---|
| `PhysicalDisk.HealthStatus` | ON | Availability | Healthy | Warning | Unhealthy | `Get-PhysicalDisk \| .HealthStatus` | DCMA `storagepool_failed_disks` |
| `PhysicalDisk.OperationalStatus` | ON | Availability | OK | Degraded/Stale | Failed/Lost Communication | `Get-PhysicalDisk \| .OperationalStatus` | DCMA |
| `PhysicalDisk.Usage.Retired` | ON | Configuration | In use | — | Retired | `Get-PhysicalDisk \| .Usage` | DCMA |
| `PhysicalDisk.PredictiveFailure` | ON | Availability | False | — | True | `Get-PhysicalDisk \| .OperationalStatus -like '*Predictive*'` | DCMA |
| `PhysicalDisk.Wear.Percent` | OFF | Configuration | > 20 | 10–20 | < 10 (< 10% endurance remaining) | `Get-PhysicalDisk \| .VirtualDiskFootprint` + SMART attributes | KQL |
| `PhysicalDisk.ReadError.Count` | OFF | Availability | 0 | ≥ 1 | ≥ 10 | `Get-PhysicalDisk \| .ReadErrorCount` (Get-StorageReliabilityCounter) | KQL |
| `PhysicalDisk.WriteError.Count` | OFF | Availability | 0 | ≥ 1 | ≥ 10 | `Get-StorageReliabilityCounter \| .WriteErrorsTotal` | KQL |
| `PhysicalDisk.Temperature.Celsius` | OFF | Performance | < 60 | 60–70 | > 70 | `Get-StorageReliabilityCounter \| .Temperature` | KQL |
| `PhysicalDisk.PowerOnHours` | Rule | Configuration | — | — | — | `Get-StorageReliabilityCounter \| .PowerOnHours` | KQL |
| `PhysicalDisk.Firmware.Version` | OFF | Configuration | Current (vs. HCL matrix) | One version behind | Major behind | `Get-PhysicalDisk \| .FirmwareVersion` | KQL |
| `PhysicalDisk.MediaType.Mismatch` | OFF | Configuration | Consistent per fault domain | — | Mixed media types in same tier | `Get-PhysicalDisk \| Group-Object MediaType` per fault domain | KQL |
| `PhysicalDisk.Rebuild.PercentComplete` | OFF | Performance | n/a (no rebuild) | In progress | Stalled | `Get-StorageJob \| Where JobState -eq 'Running'` scoped to disk | KQL |
| `PhysicalDisk.Read.Latency.ms` | OFF | Performance | < 1 (NVMe) / < 5 (SSD) | Elevated | > 20 | Perf counter `\PhysicalDisk(*)\Avg. Disk sec/Read` | KQL |
| `PhysicalDisk.Write.Latency.ms` | OFF | Performance | < 1 (NVMe) / < 5 (SSD) | Elevated | > 20 | Perf counter `\PhysicalDisk(*)\Avg. Disk sec/Write` | KQL |
| `PhysicalDisk.BusType` | Rule | Configuration | — | — | — | `Get-PhysicalDisk \| .BusType` | KQL |
| `StoragePool.PhysicalDisk.Failed.Count` | ON | Availability | 0 | 1 (within fault tolerance) | > 1 | `Get-PhysicalDisk \| Where HealthStatus -ne 'Healthy'` | DCMA |
| `StoragePool.PhysicalDisk.Warning.Count` | ON | Availability | 0 | ≥ 1 | — | `Get-PhysicalDisk \| Where HealthStatus -eq 'Warning'` | DCMA |
| `StoragePool.PhysicalDisk.Retired.Count` | ON | Configuration | 0 | ≥ 1 | — | `Get-PhysicalDisk \| Where Usage -eq 'Retired'` | DCMA |
| `StoragePool.PhysicalDisk.Lost.Count` | ON | Availability | 0 | — | ≥ 1 | `Get-PhysicalDisk \| Where OperationalStatus -eq 'Lost Communication'` | DCMA |
| `StoragePool.RetiredCapacity.Percent` | OFF | Performance | < 5 | 5–15 | > 15 | `(Get-PhysicalDisk -Usage Retired \| Measure-Object Size -Sum).Sum / Pool.Size` | DCMA |

### Network Intent

| Logical name | Default | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|---|
| `NetIntent.State` | ON | Availability | Success | InProgress > 1h | Failed | `Get-NetIntentStatus` | KQL on `Microsoft-Windows-SDDC-Management/Operational` |
| `NetIntent.RDMA.OpStatus` | ON | Availability | Operational | Degraded | NonOperational | `Get-NetIntentStatus` | KQL |
| `NetIntent.vSwitch.Health` | ON | Availability | Up | — | Down | `Get-VMSwitch` | KQL |
| `NetIntent.Adapter.LinkSpeed` | ON | Performance | At expected | Below expected | Disconnected | `Get-NetAdapter` | DCMA `nic_link_speed` |
| `NetIntent.MTU.Drift` | ON | Configuration | Match | Drift on 1 NIC | Drift > 1 NIC | `Get-NetAdapterAdvancedProperty` | KQL |
| `NetIntent.VLAN.Drift` | OFF | Configuration | Match | Drift on 1 NIC | Drift > 1 NIC | `Get-NetAdapterAdvancedProperty -RegistryKeyword VlanID` | KQL |
| `NetIntent.AdapterCount.Expected` | ON | Configuration | Match | — | Missing adapter in intent | `(Get-NetIntentStatus).Adapters.Count` vs discovered | KQL |
| `NetIntent.Management.Gateway.Reachable` | OFF | Availability | Reachable | — | Unreachable | `Test-NetConnection <default-gateway> -Port 80` on management intent | KQL |
| `NetIntent.Management.SCOM.Server.Reachable` | OFF | Availability | Reachable | — | Unreachable | `Test-NetConnection <mgmt-server>` from node | KQL |
| `NetIntent.Storage.Bandwidth.Utilization.Percent` | OFF | Performance | < 70 | 70–90 | > 90 | SMB bandwidth / (NIC count × link speed) derived | DCMA |
| `NetIntent.Compute.vSwitch.PacketDrops` | OFF | Performance | 0 | > 0 | > 100/sec | Perf counter `\Hyper-V Virtual Switch(*)\Packets/sec` dropped | KQL |
| `NetIntent.Heartbeat.Network.Dedicated` | OFF | Configuration | Dedicated | — | Shared with management | `Get-ClusterNetwork \| Where Role -like '*Internal*'` isolation check | KQL |

### Physical NIC & RDMA

| Logical name | Default | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|---|
| `NIC.Physical.Status` | ON | Availability | Up | — | Down / Not Present | `Get-NetAdapter \| .Status` | DCMA `nic_status` |
| `NIC.RDMA.Enabled` | ON | Configuration | True (storage-intent NICs) | — | False | `Get-NetAdapterRdma \| .Enabled` | KQL |
| `NIC.RDMA.OperationalStatus` | ON | Availability | Operational | Degraded | NonOperational | `Get-NetAdapterRdma` | DCMA `rdma_operational_status` |
| `NIC.LinkSpeed.Gbps` | ON | Performance | At expected tier (10/25/100) | Below expected | 0 / Down | `Get-NetAdapter \| .LinkSpeed` | DCMA `nic_link_speed` |
| `NIC.Bandwidth.InboundUtilization.Percent` | OFF | Performance | < 70 | 70–90 | > 90 | Perf counter `\Network Interface(*)\Bytes Received/sec` / rated speed | DCMA |
| `NIC.Bandwidth.OutboundUtilization.Percent` | OFF | Performance | < 70 | 70–90 | > 90 | Perf counter `\Network Interface(*)\Bytes Sent/sec` / rated speed | DCMA |
| `NIC.Receive.BufferDrops.Sec` | OFF | Performance | 0 | > 0 | > 100/sec | Perf counter `\Network Interface(*)\Packets Received Discarded` | KQL |
| `NIC.Transmit.QueueDrops.Sec` | OFF | Performance | 0 | > 0 | > 100/sec | Perf counter `\Network Interface(*)\Packets Outbound Discarded` | KQL |
| `NIC.Receive.Errors.Sec` | OFF | Performance | 0 | > 0 | > 10/sec | Perf counter `\Network Interface(*)\Packets Received Errors` | KQL |
| `NIC.Transmit.Errors.Sec` | OFF | Performance | 0 | > 0 | > 10/sec | Perf counter `\Network Interface(*)\Packets Outbound Errors` | KQL |
| `NIC.RDMA.Inbound.MBps` | Rule | Performance | — | — | — | Perf counter `\RDMA Activity(*)\RDMA Inbound Bytes/sec` | DCMA |
| `NIC.RDMA.Outbound.MBps` | Rule | Performance | — | — | — | Perf counter `\RDMA Activity(*)\RDMA Outbound Bytes/sec` | DCMA |
| `NIC.RSS.Enabled` | ON | Configuration | True (storage NICs) | — | False | `Get-NetAdapterRss` | KQL |
| `NIC.RSS.QueueCount` | OFF | Configuration | ≥ (logical CPU count / NIC count) | Below recommended | 1 (RSS not scaling) | `(Get-NetAdapterRss).NumberOfReceiveQueues` | KQL |
| `NIC.PFC.Enabled` | ON | Configuration | True (RDMA NICs) | — | False | `Get-NetAdapterQos` | KQL |
| `NIC.ETS.Enabled` | ON | Configuration | True (RDMA NICs) | — | False | `Get-NetAdapterQos` | KQL |
| `NIC.QoS.Policy.Conformance` | OFF | Configuration | Conformant | Partial (1 NIC drift) | Non-conformant | `Get-NetQosPolicy` + `Get-NetQosFlowControl` + `Get-NetQosTrafficClass` | KQL |
| `NIC.DCBX.Willing` | OFF | Configuration | False (host override) | — | True (switch controls QoS) | `Get-NetAdapterQos \| .DcbxSetting` | KQL |
| `NIC.JumboFrame.Capable` | OFF | Configuration | Enabled (if required) | — | Disabled (if RDMA/storage) | `Get-NetAdapterAdvancedProperty -RegistryKeyword *JumboPacket*` | KQL |
| `NIC.DriverVersion.Current` | OFF | Configuration | Current | One minor behind | Major behind | `Get-NetAdapter \| .DriverVersion` vs. HCI validated matrix | KQL |
| `NIC.SMBMultichannel.PathCount` | OFF | Configuration | ≥ 2 (per storage volume) | 1 | 0 | `Get-SmbMultichannelConnection \| .NumChannels` | KQL |
| `Cluster.Network.State` | ON | Availability | Up | PartiallyUp | Down | `Get-ClusterNetwork` | KQL |
| `Cluster.LiveMigration.Network.Available` | ON | Configuration | ≥ 1 | — | 0 (no LM network) | `Get-ClusterNetwork \| Where Role -like '*LiveMigration*'` | KQL |
| `Cluster.Network.CrossNode.Latency.ms` | OFF | Performance | < 1 | 1–5 | > 5 | `Test-NetConnection` between node pairs on storage network | KQL |

### Storage Replica

| Logical name | Default | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|---|
| `StorageReplica.Status` | ON | Availability | ContinuouslyReplicating | WaitingForLogReplay | Failed/Suspended | `Get-SRPartnership` | KQL on SR event log |
| `StorageReplica.LagSeconds` | ON | Performance | < 30 | 30–300 | > 300 | `Get-SRGroup` | KQL |
| `StorageReplica.LagBytes` | OFF | Performance | < 1GB | 1–10GB | > 10GB | `Get-SRGroup \| .ReplicationLag` | KQL |
| `StorageReplica.LogVolume.FreeSpace.Percent` | ON | Performance | > 25 | 10–25 | < 10 | `Get-SRGroup \| .LogVolume` + `Get-Volume` | KQL |
| `StorageReplica.Bandwidth.MBps` | Rule | Performance | — | — | — | Perf counter `\Storage Replica Statistics(*)\Total Bytes Sent/sec` | KQL |
| `StorageReplica.SyncProgress.Percent` | OFF | Performance | 100 | < 100 (syncing) | Stalled | `Get-SRGroup \| .SyncPercentage` | KQL |
| `StorageReplica.LastSyncAge.Minutes` | OFF | Configuration | < 5 | 5–60 | > 60 | `Get-SRGroup \| .LastSyncTime` | KQL |
| `StorageReplica.Event.Error` | ON | Availability | 0 | — | ≥ 1 | Event log `Microsoft-Windows-StorageReplica/Operational` Errors | KQL `Event` |



## Layer 2 — Cluster-resident platform signals

### Arc Resource Bridge / MOC

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `ARB.VM.PowerState` | Availability | Running | — | Stopped/Failed | `Get-VM "Resource Bridge VM"` + Resource Health |
| `ARB.MOC.Service.State` | Availability | Running | — | Stopped | `Get-MocConfig` / service state |
| `ARB.ControlPlane.Reachable` | Availability | Reachable | Latency > 2s | Unreachable | `kubectl --kubeconfig` probe |
| `ARB.K8s.PodHealth` | Availability | All Running | 1 NotReady | > 1 NotReady | `kubectl get pods` |
| `ARB.K8s.NodeHealth` | Availability | All Ready | 1 NotReady | > 1 NotReady | `kubectl get nodes` |

### AKS Arc platform

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `AKSArc.HostPool.State` | Availability | Succeeded | Updating | Failed | ARM resource state |
| `AKSArc.ControlPlane.Reachable` | Availability | Reachable | Latency > 2s | Unreachable | API health probe |

### Arc agent — locally observable (ADR 0011 Tier A)

> These signals do **not** require the SCOM agent to call Azure. All data comes from local
> services, registry keys, and the `Microsoft-AzureArc-HybridAgent/Operational` event channel.
> Target class: `AzureLocal.Node`. See [ADR 0011](decisions/0011-l3-azure-scope-and-connectivity.md).

| Logical name | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|
| `ArcAgent.HIMDS.Service.State` | Availability | Running | — | Stopped | `Get-Service "HIMDS"` | KQL `Event` |
| `ArcAgent.GCArcService.State` | Availability | Running | — | Stopped | `Get-Service "GCArcService"` | KQL `Event` |
| `ArcAgent.ConnectionStatus.Local` | Availability | Connected | Stale | Disconnected | Registry `HKLM:\SOFTWARE\Microsoft\Azure Connected Machine Agent\Config` → `status` | KQL |
| `ArcAgent.Heartbeat.EventLog.AgeMin` | Availability | < 5 | 5–15 | > 15 or no event | Event log `Microsoft-AzureArc-HybridAgent/Operational` Event ID 50 / 70 | KQL `Event` |
| `ArcAgent.LastHeartbeat.RegistryAge` | Availability | < 5 | 5–60 | > 60 | Registry `HKLM:\SOFTWARE\Microsoft\Azure Connected Machine Agent\Config` → `lastHeartbeatTime` | KQL |
| `ArcAgent.ExtensionManager.Service.State` | Availability | Running | — | Stopped | `Get-Service "ExtensionService"` | KQL `Event` |
| `ArcAgent.GuestConfigAgent.State` | Availability | Running | — | Stopped | `Get-Service "GCService"` | KQL `Event` |

### Arc extensions — installation & health (ADR 0011 Tier A)

> Locally verified via registry and service state. No ARM call required.
> Required extensions for a supported Azure Local deployment.
> Target class: `AzureLocal.Node`.

| Logical name | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|
| `Extension.AMA.Installed` | Configuration | True | — | False | Registry `HKLM:\SOFTWARE\Microsoft\Azure Connected Machine Agent\Extensions\AzureMonitorWindowsAgent` → `Status` | KQL |
| `Extension.AMA.Service.State` | Availability | Running | — | Stopped | `Get-Service "AzureMonitorWindowsAgent"` | KQL `Event` from `Microsoft-AzureMonitorWindowsAgent/Operational` |
| `Extension.AMA.Version.Current` | Configuration | Current | One minor behind | Major behind | Registry version vs. HCI validated matrix | KQL |
| `Extension.DCMA.Installed` | Configuration | True | — | False | Registry `...\Extensions\AzureEdgeTelemetryAndDiagnostics` → `Status` | KQL |
| `Extension.DCMA.Service.State` | Availability | Running | — | Stopped | `Get-Service "AzHCSvc"` | KQL `Event` |
| `Extension.OsSettings.Installed` | Configuration | True | — | False | Registry `...\Extensions\WindowsOSSettings` → `Status` | KQL |
| `HCI.Registration.Status` | Configuration | Connected | Out-of-policy < 30d | Out-of-policy > 30d | Registry `HKLM:\SOFTWARE\Microsoft\AzureStackHCI` → `RegistrationStatus` | ARM `connectivityStatus` |
| `DCMA.LastUpload.RegistryAgeMin` | Availability | < 15 | 15–60 | > 60 | Registry `HKLM:\SOFTWARE\Microsoft\AzureStackHCI` → `LastConnectedTime` | KQL |

### Cloud Agent / DCMA (service health)

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `DCMA.Service.State` | Availability | Running | — | Stopped | Service state on each node |
| `DCMA.LastHeartbeat.Minutes` | Availability | < 5 | 5–15 | > 15 | Telemetry pipeline + KQL `Heartbeat` |
| `AMA.Service.State` | Availability | Running | — | Stopped | `AzureMonitorWindowsAgent` extension state |

### HCI registration

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `HCI.Registration.Status` | Configuration | Connected | Out-of-policy < 30d | Out-of-policy > 30d | ARM property `connectivityStatus` |
| `HCI.LastConnected.Minutes` | Availability | < 15 | 15–60 | > 60 | ARM `lastBillingMeterUpload` |

## Layer 3 — Azure-side signals

> All L3 signals leverage **Resource Health** (free) + **Activity Log** (free) +
> **Resource Graph** queries. See [Prerequisites](../azure-monitor/prerequisites.md).

### HCI Cluster resource

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `HCICluster.ProvisioningState` | Configuration | Succeeded | Updating | Failed | ARM |
| `HCICluster.ConnectionStatus` | Availability | Connected | NotYetRegistered | Disconnected | ARM |
| `HCICluster.ResourceHealth` | Availability | Available | Degraded | Unavailable | Resource Health |

### Arc-enabled Server (per node)

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `ArcServer.Status` | Availability | Connected | Stale (< 1h) | Disconnected | ARM `status` |
| `ArcServer.LastStatusChange.Minutes` | Availability | < 5 | 5–60 | > 60 | ARM |

### Custom Location

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `CustomLocation.ProvisioningState` | Configuration | Succeeded | — | Failed | ARM |
| `CustomLocation.NamespacePresent` | Configuration | True | — | False | ARM |

### Logical Networks

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `LogicalNetwork.ProvisioningState` | Configuration | Succeeded | — | Failed | ARM |
| `LogicalNetwork.IPPool.UsedPct` | Performance | < 70 | 70–90 | > 90 | ARM `ipAllocations` |

### Identities (MI + SPN)

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `MI.Exists` | Configuration | True | — | False | Microsoft Graph + ARM |
| `MI.RoleAssignments.Required` | Configuration | All present | 1 missing | > 1 missing | ARM Authorization |
| `SPN.Exists` | Configuration | True | — | False | Microsoft Graph |
| `SPN.Credential.ExpiryDays` | Configuration | > 30 | 7–30 | < 7 | Microsoft Graph |
| `SPN.RoleAssignments.Required` | Configuration | All present | 1 missing | > 1 missing | ARM Authorization |

### Key Vault

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `KeyVault.ResourceHealth` | Availability | Available | Degraded | Unavailable | Resource Health |
| `KeyVault.Reachable` | Availability | Reachable | Latency > 2s | Unreachable | KQL on `KeyVaultProperties` |
| `KeyVault.Secret.ExpiryDays` *(per required secret)* | Configuration | > 30 | 7–30 | < 7 | Key Vault data plane (with permission) |
| `KeyVault.AccessPolicy.Drift` | Security | None | Drift on 1 principal | Drift > 1 principal | ARM |

### Storage Account

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `StorageAccount.ResourceHealth` | Availability | Available | Degraded | Unavailable | Resource Health |
| `StorageAccount.Redundancy` | Configuration | As expected | — | Drift | ARM SKU |
| `StorageAccount.NetworkACL.Drift` | Security | None | Drift | Public | ARM `networkAcls` |

### RBAC / role assignments

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `RBAC.RequiredAssignments` | Configuration | All present | 1 missing | > 1 missing | ARM Authorization |
| `RBAC.UnexpectedAssignments` | Security | 0 | ≤ 2 | > 2 | ARM Authorization |

### Update Manager linkage

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `UpdateManager.Linkage` | Configuration | Linked | — | Missing | ARM |
| `UpdateManager.LastAssessment.Days` | Configuration | < 7 | 7–30 | > 30 | ARM |

### Data Collection Rules

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `DCR.Exists` | Configuration | True | — | False | ARM |
| `DCR.Associated` | Configuration | All nodes | Some | None | ARM `dataCollectionRuleAssociations` |
| `DCR.UnexpectedReplacement` | Configuration | False | — | True | ARM property + Insights doc warning |

### Log Analytics Workspace linkage

| Logical name | Dimension | Healthy | Warning | Critical | Source |
|---|---|---|---|---|---|
| `LAW.Reachable` | Availability | Reachable | — | Unreachable | KQL `Heartbeat` from AMA |
| `LAW.Ingestion.LatencyMin` | Performance | < 5 | 5–30 | > 30 | KQL `_TimeReceived - TimeGenerated` |
| `LAW.RetentionDays` | Configuration | As expected | — | Drift | ARM |

## Free signals — Resource Health & Activity Log

For **every** Azure resource in the model, two signals are available with no extra setup:

| Source | Use as | Notes |
|---|---|---|
| **Resource Health** | Per-resource Availability | Available / Degraded / Unavailable / Unknown — auto-mapped to model state |
| **Activity Log** | Per-resource Configuration adverse events | Filtered for adverse events; surfaces ARM operation failures |

These should be wired up *first* on every L3 entity before more expensive signals.

## Customization tier overlays

Default values shown above are **Standard tier**. Lab and Strict tiers shift thresholds — see
[Customization](customization.md) for the full tier files. Example for `Volume.FreeSpace`:

| Tier | Warning at | Critical at | Reasoning |
|---|---|---|---|
| **Lab** | < 5% | < 1% | Don't page on lab clusters |
| **Standard** | < 25% | < 10% | Default — operational headroom |
| **Strict** | < 30% | < 15% | High-density / latency-sensitive workloads |

## References

- [Brian Wren, "Designing a Health Model" (SC 2012 R2 module 16)](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/)
- [Brian Wren, "Unit Monitors" (module 17)](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/)
- [Brian Wren, "Rules" (module 18)](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/)
- [Azure Local — Telemetry & Diagnostics agent (DCMA) metrics](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later)
- [Azure Local — Network ATC overview](https://learn.microsoft.com/en-us/azure/azure-local/concepts/network-atc-overview?view=azloc-2604)
- [Storage Spaces Direct — health and operational states](https://learn.microsoft.com/en-us/windows-server/storage/storage-spaces/storage-spaces-states)
- [Storage Spaces Direct — fault tolerance and storage efficiency](https://learn.microsoft.com/en-us/azure-stack/hci/concepts/fault-tolerance)
- [Azure Local monitoring overview](https://learn.microsoft.com/en-us/azure/azure-local/concepts/monitoring-overview?view=azloc-2604)
- [Resource Health — list of resource types](https://learn.microsoft.com/en-us/azure/service-health/resource-health-checks-resource-types)
- [Azure Arc-enabled servers overview](https://learn.microsoft.com/en-us/azure/azure-arc/servers/overview)
- [Azure Monitor Agent overview](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [Azure Local — firewall requirements](https://learn.microsoft.com/en-us/azure/azure-local/concepts/firewall-requirements?view=azloc-2604)
- ADR 0011 — [L3 Azure-side scope: agent-local checks vs. management server ARM probes](decisions/0011-l3-azure-scope-and-connectivity.md)
