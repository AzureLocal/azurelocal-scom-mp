# ADR 0007 — Naming convention: cross-track parity + SCOM element IDs

- **Status**: Accepted
- **Date**: 2026-05-05
- **Deciders**: @AzureLocal/azurelocal-scom-mp-maintainers

## Context

Two tracks (SCOM, Azure Monitor) implementing the same conceptual model means **every
threshold, every entity, every signal name exists twice** — once as a SCOM override key,
once as an Azure Monitor signal/Bicep parameter.

Without a project-wide convention three failure modes are likely:

1. **Drift** — a signal renamed in one track and not the other, breaking the parity
   guarantee from [ADR 0006](0006-azmon-entity-model.md).
2. **Customer confusion** — operators reading docs cannot mentally translate
   `volumeFreeSpaceWarningThresholdPct` to the SCOM override they need to apply.
3. **Untestable parity** — without a deterministic rule, we cannot lint for cross-track
   completeness.

Inputs to consider:

- **Primary reference:** Brian Wren, SC 2012 R2 Module 7 "Building Classes and
  Relationships" + the [SC 2012 OpsMgr Authoring PDF](https://download.microsoft.com/download/3/3/F/33F52373-3A75-422C-969B-61E05EEC5E72/SC2012_OpsMgr_Authoring.pdf).
  Brian Wren's convention: `Vendor.Product[.Version].Component` PascalCase for class
  and element IDs. Override property keys use dot-separated PascalCase matching the
  logical signal name.
- ARM/Bicep convention: camelCase parameter names (e.g.,
  `volumeFreeSpaceWarningThresholdPct`).
- Azure Monitor signal IDs are JSON properties — also camelCase.
- The [AzureLocal/platform standards](https://github.com/AzureLocal/platform) repo
  prescribes `kebab-case` for filenames and resource IDs.

## Decision

Two complementary conventions:
1. **SCOM internal element IDs** — all XML elements inside the MP (classes, monitors,
   rules, discoveries, relationships, the DA). Follows Brian Wren's authoring guide
   naming pattern. Covered in the first section below.
2. **Cross-track logical signal names** — the project-wide canonical name used both
   as SCOM override keys and as the source for Bicep parameter translation. Covered
   in the second section below.

---

## Part 1 — SCOM element IDs (internal MP names)

Per Brian Wren Module 7: every element in a management pack has an `ID=""` attribute that
is the **globally unique identifier** for that element. IDs must be unique across *all
management packs installed in the management group*, not just within this MP. The
convention prevents collisions.

### Pattern: `<Prefix>.<Type>.<Entity>[.<Qualifier>]`

| Segment | Value | Example |
|---|---|---|
| `<Prefix>` | `AzureLocal` (always) | `AzureLocal` |
| `<Type>` | element type (see table below) | `Monitor`, `Rule`, `Discovery`, `Class`, `Relationship` |
| `<Entity>` | short entity name from class hierarchy | `Cluster`, `Volume`, `StoragePool` |
| `<Qualifier>` | optional signal/discovery descriptor | `FreeSpace`, `HealthStatus`, `ServiceState` |

### Type prefixes

| Element | Type prefix | Example ID |
|---|---|---|
| Management pack identity | *(no type prefix — `AzureLocal.SCOM.<Area>`)* | `AzureLocal.SCOM.Library`, `AzureLocal.SCOM.Monitoring` |
| Class | `Class` | `AzureLocal.Class.Cluster` ← **exception: use just `AzureLocal.Cluster`** |
| Class (L3 Azure) | *(see below)* | `AzureLocal.Azure.HCICluster` |
| Monitor | `Monitor` | `AzureLocal.Monitor.Volume.FreeSpace` |
| Rule (perf collection) | `Rule` | `AzureLocal.Rule.Node.CPU.Percent` |
| Rule (event collection) | `Rule` | `AzureLocal.Rule.Node.EventLog.System.Critical` |
| Discovery | `Discovery` | `AzureLocal.Discovery.Cluster`, `AzureLocal.Discovery.Volume` |
| Relationship | `Relationship` | `AzureLocal.Relationship.Cluster.StoragePool` |
| Run As profile | `Profile` | `AzureLocal.Profile.ClusterNode`, `AzureLocal.Profile.AzureArm` |
| Distributed Application | `DA` | `AzureLocal.DA.Deployment` |
| Component group | `ComponentGroup` | `AzureLocal.ComponentGroup.Infrastructure` |
| View | `View` | `AzureLocal.View.Cluster.State`, `AzureLocal.View.Dashboard` |
| Task | `Task` | `AzureLocal.Task.Cluster.RecycleAgent` |
| Override | *(not named — live in the Override MP)* | — |

> **Class ID exception:** Brian Wren's authoring guide and the real-world Microsoft MPs
> (e.g., `Microsoft.Windows.Computer`, `Microsoft.SQLServer.2014.DBEngine`) omit the
> `Class.` type prefix from class IDs. Classes are the *nouns* of the system and their
> IDs are used everywhere as references — keeping them short reduces noise. This MP
> follows the same pattern: `AzureLocal.Cluster` not `AzureLocal.Class.Cluster`.

### Management pack file names and IDs

| File | MP identity ID | Purpose |
|---|---|---|
| `AzureLocal.SCOM.Library.mp` | `AzureLocal.SCOM.Library` | Classes, relationships, discoveries. **Sealed.** |
| `AzureLocal.SCOM.Monitoring.mp` | `AzureLocal.SCOM.Monitoring` | Monitors, rules, views, tasks. **Sealed.** |
| `AzureLocal.SCOM.Override.xml` | `AzureLocal.SCOM.Override` | Override pack for operator customization. **Unsealed.** |

The Library MP is sealed first; the Monitoring MP takes a `Reference` dependency on it.
This matches the pattern in real-world Microsoft MPs (library → monitoring → override).

### Display names (console-visible strings)

Per the authoring guide: display names are **separate from IDs**. They can contain
spaces and are defined in `<DisplayStrings>` elements. They are never used as references.

| Class ID | Display name |
|---|---|
| `AzureLocal.Cluster` | `Azure Local Cluster` |
| `AzureLocal.Node` | `Azure Local Node` |
| `AzureLocal.StoragePool` | `Azure Local Storage Pool (S2D)` |
| `AzureLocal.Volume` | `Azure Local Volume (CSV)` |
| `AzureLocal.StorageTier` | `Azure Local Storage Tier` |
| `AzureLocal.PhysicalDisk` | `Azure Local Physical Disk` |
| `AzureLocal.NetworkIntent` | `Azure Local Network Intent` |
| `AzureLocal.NetworkAdapter` | `Azure Local Network Adapter` |
| `AzureLocal.StorageReplica` | `Azure Local Storage Replica` |
| `AzureLocal.LCMState` | `Azure Local LCM State` |
| `AzureLocal.ArcResourceBridge` | `Azure Local Arc Resource Bridge` |
| `AzureLocal.AKSArcPlatform` | `Azure Local AKS Arc Platform` |
| `AzureLocal.DCMA` | `Azure Local Cloud Management Agent` |
| `AzureLocal.HCIRegistration` | `Azure Local HCI Registration` |
| `AzureLocal.Azure.HCICluster` | `Azure Local — HCI Cluster (ARM)` |
| `AzureLocal.Azure.ArcMachine` | `Azure Local — Arc Machine (ARM)` |
| `AzureLocal.DA.Deployment` | `Azure Local Deployment` |

---

## Part 2 — Cross-track logical signal names

We adopt a **mechanical translation rule** between a single canonical *logical name* and
each track's idiomatic surface form. The rule is reversible (round-trippable) so a linter
can verify parity at PR time.

### Logical name (canonical)

`<Entity>.<Property>.<Modifier>` in PascalCase, dot-separated.

Examples:
- `Volume.FreeSpace.WarnPercent`
- `Volume.FreeSpace.CritPercent`
- `Node.CPU.WarnPercent`
- `KeyVault.SecretExpiry.WarnDays`
- `NetIntent.RDMA.OpStatus.UnhealthyValue`

Rules:
- `Entity` is the SCOM class short-name (without `AzureLocal.` prefix). For L3 it's the
  short-name without the `Azure.` infix (`KeyVault`, not `Azure.KeyVault`).
- `Property` is the conceptual property (`FreeSpace`, `CPU`, `SecretExpiry`,
  `RDMA.OpStatus`).
- `Modifier` is the threshold tier (`WarnPercent`, `CritPercent`, `WarnDays`,
  `CritDays`, `UnhealthyValue`, `HealthyValue`).
- Multi-word components use PascalCase without separators inside the component.

### Translation rules

| Surface | Rule | Example |
|---|---|---|
| **SCOM override key** | identical to the logical name | `Volume.FreeSpace.WarnPercent` |
| **SCOM class name** | `AzureLocal.<Entity>` for L1+L2; `AzureLocal.Azure.<Entity>` for L3 | `AzureLocal.Volume`, `AzureLocal.Azure.KeyVault` |
| **Bicep parameter** | camelCase, dots elided, `Percent` → `Pct` | `volumeFreeSpaceWarningThresholdPct` |
| **Bicep variable** (internal) | same as parameter | `volumeFreeSpaceWarningThresholdPct` |
| **Azure Monitor signal ID** | `kebab-case-of-the-bicep-name` | `volume-free-space-warning-threshold-pct` |
| **Resource Graph property** | matches ARM resource type's native casing — not normalized | `properties.connectivityStatus` |
| **MP filename** | kebab-case | `azurelocal-volume.mp.xml` |
| **ADR filename** | `NNNN-kebab-case-title.md` | `0007-naming-convention.md` |
| **Doc page filename** | kebab-case | `signal-catalog.md` |
| **Mermaid node ID** | camelCase from logical name | `volumeFreeSpace` |

### Modifier translation

Bicep parameter modifiers expand abbreviated logical-name modifiers:

| Logical | Bicep |
|---|---|
| `WarnPercent` | `WarningThresholdPct` |
| `CritPercent` | `CriticalThresholdPct` |
| `WarnDays` | `WarningDays` |
| `CritDays` | `CriticalDays` |
| `WarnSeconds` | `WarningSeconds` |
| `CritSeconds` | `CriticalSeconds` |
| `HealthyValue` | `HealthyValue` |
| `UnhealthyValue` | `UnhealthyValue` |

### Worked examples

| Logical name | SCOM override | Bicep param |
|---|---|---|
| `Volume.FreeSpace.WarnPercent` | `Volume.FreeSpace.WarnPercent` | `volumeFreeSpaceWarningThresholdPct` |
| `Volume.FreeSpace.CritPercent` | `Volume.FreeSpace.CritPercent` | `volumeFreeSpaceCriticalThresholdPct` |
| `Node.CPU.WarnPercent` | `Node.CPU.WarnPercent` | `nodeCpuWarningThresholdPct` |
| `Node.CPU.CritPercent` | `Node.CPU.CritPercent` | `nodeCpuCriticalThresholdPct` |
| `KeyVault.SecretExpiry.WarnDays` | `KeyVault.SecretExpiry.WarnDays` | `keyVaultSecretExpiryWarningDays` |
| `KeyVault.SecretExpiry.CritDays` | `KeyVault.SecretExpiry.CritDays` | `keyVaultSecretExpiryCriticalDays` |
| `Volume.IOPS.Latency.WarnMs` | `Volume.IOPS.Latency.WarnMs` | `volumeIopsLatencyWarningMs` |

### Linter contract

A PR-time linter (planned for Phase 3) walks the customization tier files
([ADR 0008](0008-customization-strategy.md)) and verifies:

1. Every logical name appears exactly once per tier file
2. Every SCOM override key matches the logical name verbatim
3. Every Bicep parameter follows the mechanical translation
4. The set of logical names is identical across tracks (no track has a threshold the
   other doesn't)

## Consequences

- **Positive**: Round-trippable rule means the linter can guarantee parity at PR time —
  this is the only way to keep two tracks honest at scale.
- **Positive**: SCOM operators see the same property names they're used to; Bicep
  authors see camelCase parameters. Both groups happy without compromise.
- **Positive**: Doc generators can derive the Bicep param table and SCOM override table
  from a single source list.
- **Negative**: The first time someone wants to introduce a name that doesn't fit the
  rule, they have to either revise the rule or pick a name that does. Constraint, not
  freedom.
- **Negative**: Existing prototype names from earlier scratch work need to be
  rewritten — minor mechanical refactor.
- **Affected**: All Phase 3 + Phase 4 authoring (every override key, every Bicep param,
  every entity ID, every signal ID). Also the customization tier files.

## Alternatives considered

- **Snake_case canonical** — rejected: doesn't match SCOM idiom or ARM idiom.
- **Per-track-native names with no canonical** — rejected: can't lint parity; drift
  inevitable.
- **YAML schema as canonical, generate both surface forms** — defer-able to Phase 3+ as
  a tooling enhancement; mechanical translation rule is sufficient for now.

## References

- ADR 0006 — [Azure Monitor entity model alignment](0006-azmon-entity-model.md)
- ADR 0008 — [Customization strategy](0008-customization-strategy.md)
- **Brian Wren, Module 7 — "Building Classes and Relationships"** (primary — class ID naming, vendor prefix convention)
- **Brian Wren, Module 18 — "Rules"** (primary — rule ID naming pattern)
- [SC 2012 OpsMgr Authoring PDF](https://download.microsoft.com/download/3/3/F/33F52373-3A75-422C-969B-61E05EEC5E72/SC2012_OpsMgr_Authoring.pdf) — Management Pack Basics chapter (element IDs, display strings, file structure)
- [Brian Wren, "Management Pack Basics" (2010)](https://learn.microsoft.com/en-us/archive/blogs/mpauthor/management-pack-basics)
- [AzureLocal/platform — naming standards](https://github.com/AzureLocal/platform)
- [Bicep best practices — naming conventions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)
