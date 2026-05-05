---
title: Prerequisites
description: What must be enabled, installed, and configured for the Azure Monitor health model of Azure Local infrastructure to receive signals.
---

# Prerequisites for the Azure Monitor Health Model

Authoritative prerequisites for building an Azure Monitor **Health Model** (preview) over an Azure Local
(formerly Azure Stack HCI) cluster. Every claim below cites a Microsoft Learn page; URLs are pinned to
`?view=azloc-2604` where the doc supports versioned views.

> **Scope.** This page covers the *Azure-side* enablement required for the health model to receive
> signals about Azure Local **infrastructure** — the cluster resource, its Arc-enabled machine nodes,
> the Arc Resource Bridge, and the related platform-side Azure resources (Key Vault, Storage Account,
> deployment SPN). It does **not** cover tenant VM workloads running on the cluster — those are the
> domain of future workload-companion MPs ([Roadmap](../project/roadmap.md)).

---

## Summary

| # | Prerequisite | Why it's needed | Blocking / Recommended | Reference |
|---|---|---|---|---|
| 1 | **Azure Local cluster registered with Azure Arc** (cluster + each node) | Cluster and nodes must be ARM resources before any Azure Monitor feature, Insights, or health model can target them. | Blocking | [Assign required permissions for Azure Local deployment](https://learn.microsoft.com/en-us/azure/azure-local/deploy/deployment-arc-register-server-permissions?view=azloc-2604) |
| 2 | **Resource providers registered** on subscription: `Microsoft.AzureStackHCI`, `Microsoft.HybridCompute`, `Microsoft.Insights`, `Microsoft.Management` (service groups), plus the Arc/Edge stack | Without `Microsoft.Insights`, deployment-time diagnostic account and Key Vault audit logging fails validation; without `Microsoft.HybridCompute` Arc nodes can't register; without `Microsoft.Management` service groups can't be created. | Blocking | [Azure prerequisites](https://learn.microsoft.com/en-us/azure/azure-local/deploy/deployment-arc-register-server-permissions?view=azloc-2604#azure-prerequisites) |
| 3 | **Log Analytics workspace** in the same tenant | Backing store for Insights, custom DCRs, log signals in the health model. | Blocking (for log-based signals) | [Monitor a single Azure Local system with Insights](https://learn.microsoft.com/en-us/azure/azure-local/manage/monitor-single-23h2?view=azloc-2604) |
| 4 | **Azure Local Insights enabled** on the cluster (portal → cluster → Capabilities → Insights) | Auto-installs AMA on every node, creates the `AzureStackHCI-…` DCR, enrolls the SDDC and Health event channels and the five required performance counters that everything else builds on. | Blocking (for cluster-health signals) | [Insights — Configure](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later#configure-insights-for-azure-stack-hci) |
| 5 | **Azure Monitor Agent (AMA)** on every node | The Arc/AMA extension is what writes data into the workspace per DCR. Insights installs and manages it. | Blocking | [Azure Monitor Agent overview](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview) |
| 6 | **Telemetry & Diagnostics (DCMA) Arc extension** on every node | Source of the >60 platform metrics (CPU, memory, IOPS, latency, throughput, VM perf) shown in `AzureStackHCI/clusters` Metrics Explorer. Distinct from AMA. | Blocking (for metric signals) | [Monitoring capabilities — Metrics](https://learn.microsoft.com/en-us/azure/azure-local/concepts/monitoring-overview?view=azloc-2604#metrics) |
| 7 | **Cluster managed identity** ("enhanced management") enabled | Insights "Get Started" button is disabled until cluster identity is on; AMA on each node uses *server* identity for log collection (mismatch is the #1 cause of empty workbooks). | Blocking | [Insights prerequisites](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later#prerequisites) |
| 8 | **Azure Service Group** scoped to the cluster's resources | Health models are built *on top of* a service group; entities are auto-discovered from members every 5 min. | Blocking | [Service Groups overview](https://learn.microsoft.com/en-us/azure/governance/service-groups/overview), [Create a health model](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/create) |
| 9 | **RBAC for health-model authoring** — Contributor on host RG, Service Group Contributor on the SG, Monitoring Contributor on the model | Required to create / edit / discover. | Blocking | [Permissions required](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/create#permissions-required) |
| 10 | **Managed identity for the health model** with Service Group Reader + Monitoring Reader on members + Monitoring Reader on workspace(s) | Identity the model uses to enumerate the SG and pull telemetry/log data. | Blocking | [Permissions required](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/create#permissions-required) |
| 11 | **Outbound 80/443** to required Azure URLs from every node and ARB; **no HTTPS inspection**; **no Arc Private Link Scopes** | Without it AMA, DCMA, Arc agent, and ARB cannot push data. | Blocking | [Firewall requirements for Azure Local](https://learn.microsoft.com/en-us/azure/azure-local/concepts/firewall-requirements?view=azloc-2604) |
| 12 | **VM Insights** for ARB and management VMs | Adds processes/dependency map and OS-level perf for the management plane VMs. | Recommended | [VM Insights overview](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-overview) |
| 13 | **Activity Log + Resource Health** (auto, no setup) | Free Azure-resource-level signals — useful as health-model signals on the cluster, Key Vault, Storage Account, etc. | Auto / no action | [Activity log](https://learn.microsoft.com/en-us/azure/azure-monitor/platform/activity-log) |
| 14 | **Azure Resource Graph access** (Reader on the SG/subscription) | The model's discovery and many operator queries (inventory of nodes, extensions, Arc state) rely on ARG. | Blocking for discovery queries | [Service Groups / Health Model discovery](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/concepts#azure-resource-entity) |
| 15 | **Azure Update Manager onboarding** for the cluster | Provides update-status signals (assessment age, missing critical updates) you can wire into the health model. | Recommended | [Monitoring capabilities](https://learn.microsoft.com/en-us/azure/azure-local/concepts/monitoring-overview?view=azloc-2604) |

---

## Per-prerequisite detail

### 1. Azure Local Insights (HCI Insights)

Insights is a portal-driven feature on the cluster's **Capabilities** blade. Selecting **Get Started** triggers the platform to:

1. Install the **`AzureMonitorWindowsAgent`** extension on every node via Arc.
2. Create (or reuse) a Data Collection Rule prefixed `AzureStackHCI-…`.
3. Enable the two required Windows event channels and five required performance counters.

The Get Started button is *gated on* the cluster managed identity being enabled.
([Configure Insights](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later#configure-insights-for-azure-stack-hci))

**Event channels collected** (drive the health/inventory workbooks; these are the tables the
health model should read for failure signals):

| Channel | Purpose |
|---|---|
| `Microsoft-Windows-Health/Operational` | OS Health Service faults — pool capacity, disk health, network adapter, QoS, etc. (>80 fault types) |
| `Microsoft-Windows-SDDC-Management/Operational` (Event IDs 3000–3004) | Inventory + state of servers, drives, volumes, VMs |

These ingest into the Log Analytics `Event` table (with the channel in `Channel`); the workbooks query
them via KQL. ([Insights — Event channel](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later#event-channel))

**Performance counters collected** (land in `Perf`):

- `Memory(*)\Available Bytes`
- `Network Interface(*)\Bytes Total/sec`
- `Processor(_Total)\% Processor Time`
- `RDMA Activity(*)\RDMA Inbound Bytes/sec`
- `RDMA Activity(*)\RDMA Outbound Bytes/sec`

([Performance counters](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later#performance-counters))

**Feature workbooks (additive signals):** ReFS dedup/compression and Dell APEX hardware events extend
the DCR with extra event channels and counters — see
[Monitor Azure Local features with Insights](https://learn.microsoft.com/en-us/azure/azure-local/manage/monitor-features?view=azloc-2604).

!!! warning "Do not replace the Insights DCR"
    The Insights doc explicitly warns: *"We strongly recommend that you don't create your own DCR.
    The DCR created by Insights includes a special data stream required for its operation."* You **can**
    edit it to add Windows/Syslog events, but don't replace it.
    ([Enable Insights](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later#enable-insights))

### 2. VM Insights (for the platform VMs)

VM Insights is **separate** from HCI Insights. It adds:

- Processes & Dependencies (Map view)
- The `InsightsMetrics` perf table (per-process CPU/memory/disk/network)
- Compatible with Arc-enabled servers and Azure VMs, so it works on the Arc Resource Bridge (ARB) VM
  and any management/jump VMs that are Arc-onboarded

It piggybacks on AMA + a VM Insights DCR. **Recommended** (not blocking) for the infrastructure model — it
gives the ARB its own health signals (process up/down, latency to dependencies). See
[VM Insights overview](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-overview)
and [Enable enhanced monitoring](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/monitor-vm#enable-enhanced-monitoring).

### 3. Agents on the nodes — AMA vs DCMA vs Connected Machine

Azure Local cluster nodes register as **Azure Arc-enabled servers** (`Microsoft.HybridCompute/machines`)
as part of cluster registration. ([Arc-enabled servers overview](https://learn.microsoft.com/en-us/azure/azure-arc/servers/overview))
That means each node is an ARM resource, but **the Arc Connected Machine agent does not include AMA by
default** — AMA is a separate extension installed by Insights.

| Agent | Resource type / extension | Installed by | Data plane | Required for |
|---|---|---|---|---|
| **Azure Connected Machine agent** (`azcmagent`) | Built-in to Azure Local registration | Cluster registration | Heartbeat, identity, extension dispatch | Arc-enabled status, Resource Health, Activity Log |
| **Azure Monitor Agent** (`AzureMonitorWindowsAgent` extension) | Arc extension | HCI Insights | Event Logs, Perf, custom log → Log Analytics via DCR | Insights workbooks, log signals |
| **Telemetry & Diagnostics** (DCMA / `AzureEdgeTelemetryAndDiagnostics` family) | Arc extension, deployed by Azure Local platform | Cluster deployment / lifecycle | >60 platform metrics, diagnostic logs | Cluster Metrics, recommended alerts |

DCMA is what the [Monitoring overview](https://learn.microsoft.com/en-us/azure/azure-local/concepts/monitoring-overview?view=azloc-2604#metrics)
calls *the Telemetry and Diagnostics Arc extension*. Its metric output is what powers the
`AzureStackHCI/clusters` resource type in Azure Monitor Metrics — those metrics are the natural source
for **metric-based health-model signals**.

!!! warning "Pre-November 2023 cluster gotcha"
    AMA was originally configured to use *cluster* identity instead of *node* identity; this breaks
    Arc-for-Servers, VM Insights, Defender, Sentinel data flow. Run `Register-AzStackHCI -RepairRegistration`,
    then reinstall AMA, then reconfigure Insights.
    ([Troubleshoot clusters registered before November 2023](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later#troubleshoot-clusters-registered-before-november-2023))

### 4. Data Collection Rules (DCRs)

| DCR | Created by | Contents | Tables targeted |
|---|---|---|---|
| `AzureStackHCI-<cluster>` | HCI Insights | Health + SDDC channels, 5 perf counters | `Event`, `Perf` |
| `MSVMI-…` (VM Insights) | VM Insights enable flow | InsightsMetrics, ServiceMap | `InsightsMetrics`, `VMComputer`, `VMProcess`, `VMConnection` |
| Custom DCRs (you create) | Operator | Add e.g. `System`, `Application`, Hyper-V `*-Operational`, `Microsoft-Windows-FailoverClustering`, syslog from ARB/AKS-on-HCI | `Event`, `Syslog`, custom logs |

Authoring guidance: [Data collection rules in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-overview),
[Best practices](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-best-practices).
Custom DCRs target the *node* (Arc machine) resource ID, not the cluster.

### 5. Log Analytics Workspace

- **Required** for any log-based signal in the health model.
- One workspace per cluster, **or** a shared regional workspace — both supported. Shared works well
  when authoring many health models off one set of tables.
- Recommended in the **same Azure region as the cluster's ARM record** to minimize cross-region egress
  and fit data-residency expectations.
- Required endpoints: [Define AMA network settings](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-data-collection-endpoint?tabs=PowerShellWindows).

### 6. Resource Health and Activity Log

Both stream automatically and at no cost for **every** Azure resource in the model:

- The cluster (`Microsoft.AzureStackHCI/clusters`)
- Each node (`Microsoft.HybridCompute/machines`)
- The Arc Resource Bridge (`Microsoft.ResourceConnector/appliances`)
- Deployment Key Vault, Storage Account, Custom Locations, ARM extensions

Use these as **free signals** in the health model:

- *Activity Log* → "Administrative" / "Service Health" categories — surfaces when someone deletes the
  workspace, rotates KV, or Microsoft posts a service issue.
- *Resource Health* → platform-emitted Available/Degraded/Unavailable; ideal as the baseline signal
  on the cluster and ARB entities.

References: [Azure Monitor activity log](https://learn.microsoft.com/en-us/azure/azure-monitor/platform/activity-log),
[Activity logs for VMs](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/monitor-vm#activity-logs).

### 7. Azure Resource Graph

The health-model designer enumerates service-group members through Azure Resource Manager + ARG.
To author the model you need at least:

- `Reader` on every subscription that contributes resources
- `Service Group Reader` on the service group

ARG is also the right place for your own **inventory KQL** that backs custom signals (e.g. count of
nodes with `properties.status != 'Connected'` on `Microsoft.HybridCompute/machines`).

### 8. Azure Monitor Health Models (preview)

From [Health models in Azure Monitor (preview)](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/overview)
and [Create](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/create):

- **Built on top of an Azure Service Group** — every entity is either the root, an Azure resource entity
  (auto-discovered from the SG, refreshed every 5 min), or a generic entity you add manually.
- A model is itself an ARM resource (lives in a resource group + region).
- Signals are pulled from already-collected data — **the model does not collect anything new**. So your
  DCRs / metrics / Resource Health must already be flowing.
- It can target metrics, log queries (Log Analytics workspace) and Azure Monitor workspace.
- Recommended signals are pre-shipped for common Azure resource types — choose **"Add recommended signals"**
  on the Discovery step.

**Authoring RBAC** (per [Permissions required](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/create#permissions-required)):

| Action | Role |
|---|---|
| Create a health model | `Contributor` on the host resource group (or subscription, if creating the RG) |
| Manage existing model | `Monitoring Contributor` on the model |
| View model | `Monitoring Reader` on the model + `Service Group Reader` on the SG |
| Add resources | `Contributor` on the SG (to add SG members) |

**Health-model managed identity** (system or user-assigned) needs:

- `Service Group Reader` on the SG
- `Monitoring Reader` on every member resource
- `Monitoring Reader` on the Log Analytics workspace and Azure Monitor workspace used in signals

### 9. Azure Service Groups

[Service Groups (preview)](https://learn.microsoft.com/en-us/azure/governance/service-groups/overview)
are tenant-level, parallel to the management-group hierarchy. To scope a SG to "all Azure Local
resources for cluster X," add as members:

- The cluster ARM resource (`Microsoft.AzureStackHCI/clusters/<name>`)
- Each node (`Microsoft.HybridCompute/machines/<node>`)
- The Arc Resource Bridge (`Microsoft.ResourceConnector/appliances/<arb>`)
- The deployment Key Vault and Storage Account
- The Log Analytics workspace and any Action Groups you want to display in the model
- Optionally each Arc extension resource (DCMA / AMA) — useful for surfacing "extension out of date" as a signal

Limits to plan around: 2,000 SG-member relationships per subscription; up to 10 levels of nesting; no
custom RBAC during preview.
([Important facts](https://learn.microsoft.com/en-us/azure/governance/service-groups/overview#important-facts-about-service-groups))

### 10. RBAC and identity prerequisites (cumulative)

For the **deployment** identity (one-time, already required to stand up the cluster):

- `Azure Stack HCI Administrator` + `Reader` on the subscription
- `Azure Connected Machine Onboarding` + `Azure Connected Machine Resource Administrator` on the deployment RG
- `Key Vault Data Access Administrator` + `Key Vault Secrets Officer` + `Key Vault Contributor` on the RG
- `Storage Account Contributor` on the RG

Source: [Assign Azure permissions for deployment](https://learn.microsoft.com/en-us/azure/azure-local/deploy/deployment-arc-register-server-permissions?view=azloc-2604#assign-azure-permissions-for-deployment).

For the **health-model author**: see §8 above.

For the **operator viewing** the model: `Reader` on the cluster + `Monitoring Reader` on the workspace +
`Service Group Reader` on the SG + `Monitoring Reader` on the model.

### 11. Network / firewall

From [Firewall requirements for Azure Local](https://learn.microsoft.com/en-us/azure/azure-local/concepts/firewall-requirements?view=azloc-2604):

- **Outbound TCP 80/443** from each node and the ARB to Azure
- **HTTPS inspection MUST be disabled** along the path; Entra ID Tenant Restrictions v1 is unsupported
  on the management network
- **Arc Private Link Scopes are NOT supported** for Azure Local — `*.his.arc.azure.com`,
  `*.guestconfiguration.azure.com`, `*.dp.kubernetesconfiguration.azure.com` must resolve to public IPs
  from nodes/ARB/proxy. (Other Azure PaaS private endpoints are fine if routed via ExpressRoute / S2S VPN.)
- AMA-specific endpoints (DCE, ingestion) are listed at
  [AMA firewall requirements](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-data-collection-endpoint?tabs=PowerShellWindows#firewall-requirements).
  If you use a proxy or DCE-only configuration, those FQDNs must be in the allowlist.
- Region-specific consolidated endpoint lists are linked from the firewall doc above.

### 12. Update Manager linkage

[Azure Update Manager for Azure Local](https://learn.microsoft.com/en-us/azure/azure-local/concepts/monitoring-overview?view=azloc-2604)
emits assessment and update-run results that surface in the cluster's `updates` and `updateRuns` ARM
child resources. Useful health-model signals derived from it:

- "Latest update assessment is older than X days."
- "Last `updateRuns` ended with `state != Succeeded`."

These are queryable via Azure Resource Graph and Activity Log without any extra agent.

---

## Common gotchas

| Symptom | Root cause | Fix |
|---|---|---|
| "I enabled Insights but workbooks are blank." | DCR association missing on the nodes; AMA still using cluster identity (pre-Nov 2023 reg). | [Repair cluster registration](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later#repair-cluster-registration), then [Repair AMA](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later#repair-ama-for-azure-stack-hci), then **Reconfigure Insights**. |
| "Get Started" button is greyed out. | Cluster managed identity not enabled OR cluster on pre-May-2023 22H2. | Enable [enhanced management / managed identity](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/azure-enhanced-management-managed-identity); patch to ≥ May 2023 CU. |
| Duplicate ingestion / 2× cost. | MMA + AMA both installed during migration. | Uninstall `MicrosoftMonitoringAgent` extension after verifying nothing else needs it. |
| Insights tile says **Needs update**. | A perf counter or event channel was deleted from the DCR, or the DCR itself was edited externally. | Open Insights and click **Update**. |
| ARB / management VMs absent from the model. | Service group only contains the cluster + nodes; ARB has its own ARM resource type. | Add `Microsoft.ResourceConnector/appliances` as a service group member. |
| Health-model "Unknown" everywhere. | Model managed identity lacks `Monitoring Reader` on workspace, or signal queries hit a workspace not in the SG. | Re-check identity assignments per §8. |
| `Microsoft.Insights` RP unregistered. | Validation passes Arc but fails Key Vault audit logging during deployment. | Run `Register-AzResourceProvider -ProviderNamespace "Microsoft.Insights"` in the subscription. |
| Outbound to Azure works for Arc but Insights data never appears. | HTTPS inspection / TLS break-and-inspect on the egress path, or Arc Private Link Scope misapplied. | Disable HTTPS inspection for the AzureMonitor / AzureResourceManager / GuestAndHybridManagement service tags. |
| Health model can't see a service-group member. | Member relationship was added but caller lacked `Microsoft.Relationship/write` on the resource at the time. | Re-add the member with appropriate permissions. |

---

## Pre-flight checklist

Run through this before pointing the health-model designer at your service group.

### Subscription / tenant level

- [ ] Resource providers registered: `Microsoft.AzureStackHCI`, `Microsoft.HybridCompute`,
  `Microsoft.GuestConfiguration`, `Microsoft.HybridConnectivity`, `Microsoft.Kubernetes`,
  `Microsoft.KubernetesConfiguration`, `Microsoft.ExtendedLocation`, `Microsoft.ResourceConnector`,
  `Microsoft.HybridContainerService`, `Microsoft.Attestation`, `Microsoft.Storage`, `Microsoft.Insights`,
  `Microsoft.KeyVault`, `Microsoft.Management` (service groups), `Microsoft.OperationalInsights`.
- [ ] Tenant Global Administrator has elevated access at least once if you need a Service Group at the tenant root.

### Cluster level

- [ ] Azure Local cluster registered with Arc; all nodes show as `Microsoft.HybridCompute/machines` in `Connected` state.
- [ ] Cluster on a supported version (≥ Azure Stack HCI 22H2 May 2023 CU, or any Azure Local 23H2 / 2411+ release).
- [ ] Cluster **managed identity** ("enhanced management") enabled.
- [ ] If cluster was registered before November 2023: registration repaired and AMA reset.
- [ ] Telemetry & Diagnostics (DCMA) extension healthy on every node.

### Monitoring data plane

- [ ] Log Analytics workspace exists in the chosen region.
- [ ] HCI **Insights** enabled — capability tile shows **Configured**.
- [ ] AMA extension reports `Succeeded` on every node.
- [ ] DCR `AzureStackHCI-…` exists, contains both `Microsoft-Windows-Health/Operational` and
  `Microsoft-Windows-SDDC-Management/Operational`, and the five required perf counters.
- [ ] Test KQL: `Event | where Channel == "Microsoft-Windows-Health/Operational" | take 5` returns rows.
- [ ] Test KQL: `Perf | where ObjectName == "Processor" and CounterName == "% Processor Time" | take 5` returns rows.
- [ ] (Optional) VM Insights enabled on the Arc Resource Bridge VM.
- [ ] (Optional) Update Manager assessment ran successfully against the cluster.

### Network

- [ ] Outbound 80/443 to Azure permitted from every node and the ARB.
- [ ] HTTPS inspection disabled along the path.
- [ ] No Arc Private Link Scope applied to the Azure Local nodes.
- [ ] Region-appropriate endpoint allowlist in place (Azure Local + Arc + ARB + AKS).

### Service Group

- [ ] Service Group created with all relevant members:
    - [ ] Cluster (`Microsoft.AzureStackHCI/clusters/<name>`)
    - [ ] Each node (`Microsoft.HybridCompute/machines/<node>`)
    - [ ] Arc Resource Bridge (`Microsoft.ResourceConnector/appliances/<arb>`)
    - [ ] Custom Locations (`Microsoft.ExtendedLocation/customLocations/<cl>`)
    - [ ] Deployment Key Vault and Storage Account
    - [ ] Log Analytics workspace
    - [ ] Action groups used for alerting
- [ ] Author has `Service Group Contributor` on the SG.

### RBAC for the model

- [ ] Author has `Contributor` on the resource group that will hold the health model.
- [ ] Health-model managed identity (system or user-assigned) decided.
- [ ] Identity has `Service Group Reader` on the SG.
- [ ] Identity has `Monitoring Reader` on each SG member resource.
- [ ] Identity has `Monitoring Reader` on the Log Analytics workspace.

### Final dry-run

- [ ] In the portal, open the SG → **Monitoring** → **Create a health model** → confirm every expected
  resource appears in the auto-discovery list.
- [ ] Choose **Add recommended signals**, save, and verify the entities exit `Unknown` state within ~15 minutes.
- [ ] If still `Unknown`, re-check the managed identity's data-plane permissions (Monitoring Reader on
  workspace) and that signals reference workspaces / metric namespaces actually in scope.

---

## References

- [What is Azure Local monitoring?](https://learn.microsoft.com/en-us/azure/azure-local/concepts/monitoring-overview?view=azloc-2604)
- [Monitor Azure Local features with Insights](https://learn.microsoft.com/en-us/azure/azure-local/manage/monitor-features?view=azloc-2604)
- [Monitor a single Azure Stack HCI cluster with Insights](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later)
- [Assign required permissions for Azure Local deployment](https://learn.microsoft.com/en-us/azure/azure-local/deploy/deployment-arc-register-server-permissions?view=azloc-2604)
- [Firewall requirements for Azure Local](https://learn.microsoft.com/en-us/azure/azure-local/concepts/firewall-requirements?view=azloc-2604)
- [Azure Monitor Agent overview](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [VM Insights overview](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-overview)
- [Health models in Azure Monitor (preview)](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/overview)
- [Azure Monitor health model concepts](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/concepts)
- [Create a new Azure Monitor health model](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/create)
- [What are Azure Service Groups?](https://learn.microsoft.com/en-us/azure/governance/service-groups/overview)
- [What is Azure Arc-enabled servers?](https://learn.microsoft.com/en-us/azure/azure-arc/servers/overview)
- [Data collection rules in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-overview)
