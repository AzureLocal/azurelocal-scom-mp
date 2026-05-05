# ADR 0004 — SCOM discovery strategy: PowerShell Discovery (not WMI)

- **Status**: Accepted
- **Date**: 2026-05-05
- **Deciders**: @AzureLocal/azurelocal-scom-mp-maintainers

## Context

In SCOM, **discovery** is what populates a class's instances. Without discovery, classes
are empty and no monitors run. Brian Wren's authoring guide describes four standard
options:

1. **Registry discovery** — read registry keys, instantiate a class
2. **WMI discovery** — query a WMI namespace, instantiate one class instance per row
3. **Script discovery** (PowerShell or VBScript) — run a script, emit `<Discovery>` data
   via the SCOM scripting API
4. **Custom data source modules** — bespoke MP modules

For the Azure Local entity inventory locked by [ADR 0001](0001-scope-and-topology.md):

- L1 entities (Cluster, Node, Storage Pool, Volume, Storage Tier, Network Intent,
  Storage Replica, Update/LCM) — best surfaced through **the same PowerShell modules
  picked as primary signal source** in [ADR 0002](0002-signal-source.md):
  `FailoverClusters`, `Storage`, `NetworkATC`, `StorageReplica`.
- L2 entities (Resource Bridge, AKS Arc platform, DCMA) — surfaced through service
  state checks and ARM/MOC commands.
- L3 entities (HCI cluster, Arc-enabled servers, Custom Locations, etc.) — surfaced
  through ARM/Resource Graph.

Constraints:

- Discovery runs on every targeted agent every discovery interval (default 4 hours,
  often longer for expensive discoveries).
- Discovery cookdown ([Brian Wren, module 23](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/))
  matters when many monitors target the same data — pick a discovery method that the
  cookdown engine can fold across monitors.
- WMI's `MSCluster_*` and `MSFT_StoragePool` namespaces *exist* but expose a thinner
  shape than the equivalent PowerShell cmdlets, and several Azure Local concepts
  (NetIntent, Solution Update, MOC) have **no** WMI representation.

## Decision

**PowerShell Discovery is the project-wide default** for L1 and L2 SCOM classes. WMI
Discovery is permitted only as a fallback for individual properties where PowerShell is
unavailable.

L3 classes (Azure-side) are discovered via a **dedicated management server** running an
ARM/Resource Graph PowerShell discovery script — it is not run on each cluster node
because Azure-side state is shared across the deployment.

### Per-layer mapping

| Layer | Discovery host | Discovery method |
|---|---|---|
| **L1** (Cluster, Node, Storage, Network) | Each cluster node | PowerShell discovery using `FailoverClusters`, `Storage`, `NetworkATC`, `StorageReplica` modules |
| **L2** (Resource Bridge, AKS Arc, DCMA) | Each cluster node | PowerShell + service state checks |
| **L3** (Azure-side) | Designated SCOM management server | PowerShell using `Az` modules + Resource Graph |

### Discovery scripting conventions (per [Brian Wren module 11](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/) and [Kevin Holman fragments](https://kevinholman.com/2017/02/05/scom-management-pack-fragment-library/))

- Each discovery script is a separate `.ps1` co-located with the MP fragment that imports
  it (Kevin Holman pattern).
- All discoveries return the SCOM standard `Discovery` data shape via
  `$api.CreateDiscoveryData()`.
- Long-running discoveries (anything calling Azure ARM) target the management server,
  not every cluster node — explicit `Class="Microsoft.SystemCenter.ManagementServer"`.
- L1 cluster-level discovery runs on **only one node** (the cluster owner) — guarded by
  `Get-ClusterResource "Cluster Name" \| Where Owner -eq $env:COMPUTERNAME`. This
  prevents N copies of the same cluster from appearing.
- Per-node discoveries (`Node`, `NetworkAdapter`, `PendingReboot`) run on every node.
- All discovery scripts emit verbose `Write-DebugInfo` to a file under
  `%PROGRAMDATA%\AzureLocalMP\Discovery\` for troubleshooting.

### Cookdown alignment

Each PowerShell discovery script populates a single class. Property-bag-style
multi-class discoveries are avoided so cookdown stays predictable
([module 23](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/)).

### Frequency

| Discovery target | Frequency |
|---|---|
| Cluster, Node | 4h (SCOM default) |
| Storage Pool, Volume | 4h |
| Network Intent, Storage Replica | 8h (slower-churning) |
| L3 Azure-side | 1h (catches RBAC drift faster) |

## Consequences

- **Positive**: Single language across discovery and monitoring scripts (PowerShell)
  reduces context-switching for authors and operators.
- **Positive**: PowerShell modules are the same ones operators use day-to-day for Azure
  Local — debugging discovery failures is straightforward.
- **Positive**: L1 PowerShell modules cover Network ATC, Solution Updates, and Storage
  Replica — areas where WMI is sparse or non-existent.
- **Negative**: PowerShell discoveries are heavier than WMI by milliseconds per run.
  Negligible at 4h intervals; would matter at 5-minute intervals.
- **Negative**: L3 discovery requires `Az` PowerShell modules on the management server
  and a Run As account scoped to read Azure resources. Operational burden.
- **Affected**: All Phase 3 SCOM authoring derives from this — class-by-class discovery
  fragments, the management server class targeting, the Run As account model.

## Alternatives considered

- **WMI as primary** — rejected: thin coverage of Azure Local–specific concepts; Network
  ATC and Solution Updates effectively unmodelable.
- **Mixed PowerShell + WMI per class** — rejected: doubles the surface area without
  saving meaningful work. Pick one, cite exceptions.
- **Discovery via Resource Graph for everything** — rejected: ARM doesn't expose
  on-prem-only concepts (CSV redirection, NetIntent state, repair jobs).

## References

- ADR 0002 — [Primary signal source](0002-signal-source.md)
- [Brian Wren, "Intro to Discoveries" (SC 2012 R2 module 8)](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/)
- [Brian Wren, "Script Discoveries" (module 11)](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/)
- [Brian Wren, "Cookdown" (module 23)](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/)
- [Kevin Holman — SCOM Management Pack Fragment Library](https://kevinholman.com/2017/02/05/scom-management-pack-fragment-library/)
- [Azure Local — PowerShell modules](https://learn.microsoft.com/en-us/azure/azure-local/manage/powershell?view=azloc-2604)
