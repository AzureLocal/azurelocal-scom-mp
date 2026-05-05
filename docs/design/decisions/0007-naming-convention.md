# ADR 0007 — Naming convention: cross-track parity

- **Status**: Proposed
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

- SCOM convention (Brian Wren, Microsoft Operations Manager Authoring Guide):
  `Vendor.Product.Suffix` PascalCase (e.g., `AzureLocal.Cluster`, `Volume.FreeSpace`).
  Override property keys use dot-separated PascalCase.
- ARM/Bicep convention: camelCase parameter names (e.g.,
  `volumeFreeSpaceWarningThresholdPct`).
- Azure Monitor signal IDs are JSON properties — also camelCase.
- The [AzureLocal/platform standards](https://github.com/AzureLocal/platform) repo
  prescribes `kebab-case` for filenames and resource IDs.

## Decision

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
- [Brian Wren, "Management Pack Basics" (2010)](https://learn.microsoft.com/en-us/archive/blogs/mpauthor/management-pack-basics)
- [AzureLocal/platform — naming standards](https://github.com/AzureLocal/platform)
- [Bicep best practices — naming conventions](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)
