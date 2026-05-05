# Signal Catalog

> The master list of every signal that drives a health state. Each row is a contract:
> the signal name, source, threshold tier, dimension, and how it's implemented in each track.

> **Status:** Drafted in Phase 2. Final values land at Phase 2 sign-off. Thresholds shown
> are **Standard tier** defaults — see [Customization](customization.md) for Lab/Strict tiers.

## Naming convention

Every signal has a stable cross-track name. See [ADR 0007](decisions/0007-naming-convention.md):

- **Logical name** (track-agnostic, used in this catalog): `Volume.FreeSpace.WarnPercent`
- **SCOM override property**: `Volume.FreeSpace.WarnPercent`
- **Azure Monitor Bicep param**: `volumeFreeSpaceWarningThresholdPct`

## Layer 1 — On-prem signals

### Cluster

| Logical name | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|
| `Cluster.Service.State` | Availability | Running | — | Stopped/Degraded | `Get-ClusterResource "Cluster Name"` | DCMA metric `cluster_status` |
| `Cluster.Quorum.State` | Availability | Normal | NoWitness | Failed | `Get-ClusterQuorum` | KQL `MicrosoftHCI_Cluster_Quorum` |
| `Cluster.Validation.Warnings` | Configuration | 0 | ≤ 5 | > 5 | `Test-Cluster -List Inventory` | KQL on Event log |
| `Cluster.NodeCount.Live` | Availability | All | n-1 | < n-1 | `Get-ClusterNode` | DCMA metric `cluster_node_count` |

### Node

| Logical name | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|
| `Node.Up.State` | Availability | Up | — | Down/Paused | `Get-ClusterNode \| .State` | Resource Health on `HybridCompute/machines` |
| `Node.CPU.Percent` | Performance | < 70 | 70–85 | > 85 | Perf counter `\Processor(_Total)\% Processor Time` | DCMA `node_cpu_usage_percentage` |
| `Node.Memory.Percent` | Performance | < 75 | 75–90 | > 90 | Perf counter `\Memory\% Committed Bytes In Use` | DCMA `node_memory_usage_percentage` |
| `Node.OS.UptimeDays` | Configuration | < 60 | 60–90 | > 90 | WMI `Win32_OperatingSystem.LastBootUpTime` | KQL `Heartbeat` |
| `Node.PendingReboot` | Configuration | False | — | True | Registry probe | KQL `Event` from AMA |
| `Node.BMC.Alerts` | Availability | 0 | ≤ 2 | > 2 | OEM-specific (Dell APEX / HPE / Lenovo) | KQL on hardware event channel |
| `Node.Arc.AgentConnected` | Availability | Connected | Stale (< 1h) | Disconnected | n/a (cross-references L3) | Resource Health on `HybridCompute/machines` |

### Storage Pool

| Logical name | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|
| `StoragePool.HealthStatus` | Availability | Healthy | Warning | Unhealthy | `Get-StoragePool` | DCMA `storagepool_health` |
| `StoragePool.OperationalStatus` | Availability | OK | Degraded | Failed | `Get-StoragePool` | DCMA `storagepool_operational_status` |
| `StoragePool.Capacity.Percent` | Performance | < 70 | 70–85 | > 85 | `Get-StoragePool` | DCMA `storagepool_capacity_used_percentage` |
| `StoragePool.Size.TiB` | Configuration | > 0 | — | Unexpected shrink | `(Get-StoragePool).Size / 1TB` | DCMA |
| `StoragePool.AllocatedSize.Percent` | Performance | < 70 | 70–85 | > 85 | `(Get-StoragePool).AllocatedSize / .Size * 100` | DCMA |
| `StoragePool.FreeSpace.TiB` | Performance | > 20% of .Size | 10–20% | < 10% | `(Get-StoragePool).RemainingCapacity / 1TB` | DCMA |
| `StoragePool.RetiredCapacity.TiB` | Configuration | 0 | > 0 | > 5% of total | `(Get-PhysicalDisk -Usage Retired \| Measure-Object Size -Sum).Sum / 1TB` | DCMA |
| `StoragePool.Reserve.Policy` | Configuration | Configured | — | Missing | `(Get-StoragePool).RetireMissingPhysicalDisks` | KQL |
| `StoragePool.RepairJobs.Active` | Performance | 0 | 1–2 | > 2 active for > 24h | `Get-StorageJob` | KQL on Storage event log |
| `StoragePool.PhysicalDisks.Failed` | Availability | 0 | 1 (within fault tolerance) | > 1 | `Get-PhysicalDisk` | DCMA `storagepool_failed_disks` |

### Volume / CSV

| Logical name | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|
| `Volume.HealthStatus` | Availability | Healthy | Warning | Unhealthy | `Get-Volume` | DCMA `volume_health` |
| `Volume.OperationalStatus` | Availability | OK | Degraded | Unknown/Failed | `Get-Volume` | DCMA `volume_operational_status` |
| `Volume.FreeSpace.Percent` | Performance | > 25 | 10–25 | < 10 | `Get-Volume` | DCMA `volume_free_space_percentage` |
| `Volume.Size.TiB` | Configuration | > 0 | — | Unexpected shrink | `(Get-Volume).Size / 1TB` | DCMA |
| `Volume.AllocatedSize.TiB` | Performance | < 80% of .Size | 80–90% | > 90% | `(Get-Volume).SizeRemaining / .Size` | DCMA |
| `Volume.IOPS.Latency.ms` | Performance | < 20 | 20–50 | > 50 | Perf counter `\Cluster CSV File System(*)\Avg sec/Read` | DCMA `volume_latency_ms` |
| `Volume.IOPS.Latency.Write.ms` | Performance | < 20 | 20–50 | > 50 | Perf counter `\Cluster CSV File System(*)\Avg sec/Write` | DCMA |
| `Volume.RedirectedIO.Active` | Performance | False | True < 1h | True > 1h | `Get-ClusterSharedVolume` | KQL on cluster event |
| `Volume.Dedup.SavedPercent` | Configuration | Match baseline | — | Unexpectedly low (dedup configured) | `Get-DedupVolume` | KQL |

### Storage Tier (cache)

| Logical name | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|
| `StorageTier.Cache.HitRatio` | Performance | > 80 | 60–80 | < 60 | `Get-StorageTier` perf counters | DCMA `cache_hit_ratio` |
| `StorageTier.Cache.State` | Availability | Bound | Unbinding | Failed | `Get-StorageTier` | DCMA |

### Physical Disk

> Physical disks are **not** separate SCOM class instances in the default model (see
> [scope-topology](scope-topology.md)). Their health aggregates into `AzureLocal.StoragePool`
> and `AzureLocal.StorageTier`. All signals below target `AzureLocal.StoragePool`.

| Logical name | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|
| `StoragePool.PhysicalDisk.Failed.Count` | Availability | 0 | 1 (within fault tolerance) | > 1 or exceeds tolerance | `Get-PhysicalDisk \| Where HealthStatus -ne 'Healthy'` | DCMA `storagepool_failed_disks` |
| `StoragePool.PhysicalDisk.Warning.Count` | Availability | 0 | ≥ 1 | — | `Get-PhysicalDisk \| Where HealthStatus -eq 'Warning'` | DCMA |
| `StoragePool.PhysicalDisk.Retired.Count` | Configuration | 0 | ≥ 1 | — | `Get-PhysicalDisk \| Where Usage -eq 'Retired'` | DCMA |
| `StoragePool.PhysicalDisk.Lost.Count` | Availability | 0 | — | ≥ 1 | `Get-PhysicalDisk \| Where OperationalStatus -eq 'Lost Communication'` | DCMA |
| `StoragePool.PhysicalDisk.PredictiveFailure` | Availability | 0 | ≥ 1 | — | `Get-PhysicalDisk \| Where OperationalStatus -like '*Predictive*'` | DCMA |
| `StoragePool.Reserve.Policy` | Configuration | HotSpare ≥ 1 | HotSpare = 0 (2-node) | HotSpare = 0 (≥ 3 nodes) | `Get-StoragePool \| .RetireMissingPhysicalDisks` | KQL |
| `StoragePool.RetiredCapacity.Percent` | Performance | < 5 | 5–15 | > 15 | `(Get-PhysicalDisk -Usage Retired \| Measure-Object Size -Sum).Sum / Pool.Size` | DCMA |
| `StoragePool.FaultDomain.Count` | Configuration | ≥ 2 | — | < 2 (pool degraded) | `Get-StorageFaultDomain` | KQL |
| `StorageTier.Cache.DriveCount.Expected` | Configuration | Match | — | Mismatch (drive removed from tier) | `(Get-StorageTier -MediaType NVMe \| Get-PhysicalDisk).Count` | KQL |
| `StorageTier.Capacity.DriveCount.Expected` | Configuration | Match | — | Mismatch | `(Get-StorageTier -MediaType HDD \| Get-PhysicalDisk).Count` | KQL |

### Network Intent

> Network Intent signals cover the Network ATC intent state. Physical NIC and RDMA adapter
> signals are in the **[Physical NIC & RDMA](#physical-nic--rdma)** subsection below.

| Logical name | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|
| `NetIntent.State` | Availability | Success | InProgress > 1h | Failed | `Get-NetIntentStatus` | KQL on `Microsoft-Windows-SDDC-Management/Operational` |
| `NetIntent.RDMA.OpStatus` | Availability | Operational | Degraded | NonOperational | `Get-NetIntentStatus` | KQL |
| `NetIntent.vSwitch.Health` | Availability | Up | — | Down | `Get-VMSwitch` | KQL |
| `NetIntent.Adapter.LinkSpeed` | Performance | At expected | Below expected | Disconnected | `Get-NetAdapter` | DCMA `nic_link_speed` |
| `NetIntent.MTU.Drift` | Configuration | Match | Drift on 1 NIC | Drift > 1 NIC | `Get-NetAdapterAdvancedProperty` | KQL |
| `NetIntent.VLAN.Drift` | Configuration | Match | Drift on 1 NIC | Drift > 1 NIC | `Get-NetAdapterAdvancedProperty -RegistryKeyword VlanID` | KQL |
| `NetIntent.AdapterCount.Expected` | Configuration | Match | — | Missing adapter in intent | `(Get-NetIntentStatus).Adapters.Count` vs discovered | KQL |

### Physical NIC & RDMA

> Per-NIC signals collected on every node. Target class: `AzureLocal.Node`. Individual
> NIC health rolls up into `NetIntent.RDMA.OpStatus` and `NetIntent.State`.
> Source: `Get-NetAdapter`, `Get-NetAdapterRdma`, `Get-NetAdapterAdvancedProperty`.

| Logical name | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|
| `NIC.Physical.Status` | Availability | Up | — | Down / Not Present | `Get-NetAdapter \| .Status` | DCMA `nic_status` |
| `NIC.RDMA.Enabled` | Configuration | True (for storage-intent NICs) | — | False | `Get-NetAdapterRdma \| .Enabled` | KQL |
| `NIC.RDMA.OperationalStatus` | Availability | Operational | Degraded | NonOperational | `Get-NetAdapterRdma` | DCMA `rdma_operational_status` |
| `NIC.LinkSpeed.Gbps` | Performance | At expected tier (10/25/100) | Below expected | 0 / Down | `Get-NetAdapter \| .LinkSpeed` | DCMA `nic_link_speed` |
| `NIC.DriverVersion.Current` | Configuration | Current | One minor behind | Major version behind | `Get-NetAdapter \| .DriverVersion` vs HCI validated driver matrix | KQL |
| `NIC.RSS.Enabled` | Configuration | True (storage NICs) | — | False | `Get-NetAdapterRss` | KQL |
| `NIC.PFC.Enabled` | Configuration | True (RDMA NICs) | — | False | `Get-NetAdapterQos` | KQL |
| `NIC.ETS.Enabled` | Configuration | True (RDMA NICs) | — | False | `Get-NetAdapterQos` | KQL |
| `Cluster.Network.State` | Availability | Up | PartiallyUp | Down | `Get-ClusterNetwork` | KQL |
| `Cluster.LiveMigration.Network.Available` | Configuration | ≥ 1 | — | 0 (no LM network) | `Get-ClusterNetwork \| Where Role -like '*LiveMigration*'` | KQL |

### Storage Replica

| Logical name | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|
| `StorageReplica.Status` | Availability | ContinuouslyReplicating | WaitingForLogReplay | Failed/Suspended | `Get-SRPartnership` | KQL on SR event log |
| `StorageReplica.LagSeconds` | Performance | < 30 | 30–300 | > 300 | `Get-SRGroup` | KQL |

### Update / LCM

| Logical name | Dimension | Healthy | Warning | Critical | SCOM source | Azure Monitor source |
|---|---|---|---|---|---|---|
| `Update.LastResult` | Configuration | Succeeded | InProgress | Failed | `Get-SolutionUpdate` | ARM property + KQL |
| `Update.Available.Days` | Configuration | < 30 | 30–60 | > 60 | `Get-SolutionUpdate` | ARM property |
| `Update.Solution.VersionDrift` | Configuration | Aligned | One node behind | Multiple nodes behind | `Get-SolutionUpdateEnvironment` | KQL |

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
