# ADR 0008 — Customization strategy: sealed MP + override pack tiers; Bicep params + tiers

- **Status**: Proposed
- **Date**: 2026-05-05
- **Deciders**: @AzureLocal/azurelocal-scom-mp-maintainers

## Context

A monitoring product that can't be customized without forking is not deployable in
production. Real-world Azure Local deployments range from 2-node lab clusters to
multi-rack edge sites with strict latency SLAs. One set of default thresholds will be
wrong for at least one of those.

Failure modes if customization is treated as an afterthought:

1. **Forked MPs in the field** — customers download the sealed MP, edit it, sign with
   their own key, ship a parallel build. Upgrades become impossible.
2. **Drift between deployments** — every deployment has bespoke thresholds with no
   shared baseline.
3. **Cross-track incoherence** — an operator tunes the SCOM track but forgets the
   Azure Monitor track (or vice versa). One track says Cluster Healthy, the other
   says Degraded.

Reference patterns in the wild:

- **SCOM Microsoft pattern** — sealed MP + unsealed override pack
  ([Brian Wren, MPAuthor](https://learn.microsoft.com/en-us/archive/blogs/mpauthor/),
  Kevin Holman, every shipping vendor MP)
- **Azure Local deployment pattern** — Bicep parameter files
  ([Microsoft Learn — Bicep parameter files](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/parameter-files))
- **AzureLocal/platform standards** — `*.bicepparam` per-tier files for opinionated
  presets

## Decision

We adopt a **two-track customization strategy** with a **shared three-tier preset
catalog**:

### Track 1 — SCOM

Ship two MP files:

| File | Sealed? | Edited by | Purpose |
|---|---|---|---|
| `AzureLocal.HealthModel.mp` | ✅ Sealed | Project maintainers only | Classes, discoveries, monitors, rules, DA |
| `AzureLocal.HealthModel.Overrides.xml` | ❌ Unsealed | Customer | All threshold and behavior overrides; ships with sensible defaults |

Customers either:
- Edit the unsealed override pack we ship (preserves their changes across upgrades by
  their own diff/merge), **or** (recommended)
- Create a sibling override pack `Customer.AzureLocal.Overrides.xml` that references
  ours and adds their own overrides on top — completely upgrade-safe.

### Track 2 — Azure Monitor

Ship the health model as a Bicep module with a single `health-model.bicep`. Every
threshold is a `param` with a documented default. Ship three tier `*.bicepparam` files
that the customer chooses from:

- `lab.bicepparam` — relaxed thresholds for non-prod
- `standard.bicepparam` — production default
- `strict.bicepparam` — high-density / latency-sensitive

Customers can:
- Use a tier file as-is, **or**
- Use a tier file as the base and override individual params in their own
  `customer.bicepparam`, **or**
- Author a fully custom param file from scratch

### Three-tier preset catalog (cross-track)

The same three tiers exist in both tracks. Same name, same logical thresholds. Tier
choice is part of the deployment decision.

| Tier | Use for | Examples |
|---|---|---|
| **Lab** | Lab clusters, dev/test, non-prod | Volume free space critical at < 1% (you'll fill it intentionally) |
| **Standard** | Production default | Volume free space critical at < 10% |
| **Strict** | High-density, latency-sensitive, regulated | Volume free space critical at < 15% (more headroom) |

Tier files for both tracks live in the same directory and are validated for parity by
the linter from [ADR 0007](0007-naming-convention.md).

### Customizable surface (both tracks)

| Surface | SCOM mechanism | Azure Monitor mechanism |
|---|---|---|
| **Thresholds** | Override pack `<MonitorPropertyOverride>` | Bicep param |
| **Alert severity** | Override pack `<MonitorPropertyOverride>` for `Severity` | Bicep param routed to action group |
| **Disable a monitor** | Override pack `<MonitorPropertyOverride Property="Enabled" Value="false">` | Bicep param `enabledSignals` array |
| **Suppress a child entity** | Override pack disabling the dependency | Bicep param mapping entity to `Suppressed` impact |
| **Custom action group routing** | SCOM Notification subscription (out of MP) | Bicep param `actionGroupResourceIds` |
| **Maintenance windows** | SCOM Maintenance Mode (in console) | Bicep override or manual `Healthy` objective |
| **Replace a KQL signal** | n/a (PowerShell-based on SCOM) | Bicep param `signalQueryOverrides` |

### Upgrade safety contract

The project commits to:

1. **Threshold names are immutable.** A name in v1.x is the same name in v2.x. Renames
   require a deprecation alias for at least one major version.
2. **Default values may change between major versions.** The CHANGELOG records every
   default change. Customers' explicit overrides win regardless.
3. **New thresholds in a minor version ship with safe defaults.** Customers don't have
   to update overrides for a minor version bump.
4. **Removed thresholds in a major version ship with a deprecation pass first.** The
   linter warns when a customer's override file references a removed threshold.

## Consequences

- **Positive**: Customers can adapt thresholds without forking. Upgrade-safe by design.
- **Positive**: Three pre-built tiers give 80%+ of customers a one-decision deployment.
- **Positive**: Cross-track parity by construction — same logical names across both
  tracks (enforced by [ADR 0007](0007-naming-convention.md) linter).
- **Positive**: Tier files double as documentation of the threshold catalog.
- **Negative**: Maintaining three tiers triples the threshold-tuning work. Mitigated by
  the fact that Lab and Strict are simple multipliers off Standard.
- **Negative**: Documentation cost — every threshold has to be documented with its
  default, the values across tiers, and what it means.
- **Affected**: Phase 2 [Customization](../customization.md) page is the canonical
  reference; Phase 3 + 4 authoring derives override keys / Bicep params from this ADR
  and ADR 0007.

## Alternatives considered

- **No tiers, just a single default + per-customer overrides** — rejected: forces every
  customer to start from scratch with no guidance on what good looks like for
  lab/standard/strict scenarios.
- **One mega-bicepparam with environment branching inside** — rejected: harder to read,
  harder to validate, harder to lint.
- **Customization through GUI (SCOM Authoring Console / Azure portal Health Models
  editor)** — rejected as the primary mechanism: not version-controlled, not auditable,
  not consistent across deployments. Permitted as a *secondary* path for ad-hoc
  customization.

## References

- [Customization page](../customization.md) (the operational reference)
- ADR 0007 — [Naming convention](0007-naming-convention.md)
- [Brian Wren, "Management Pack Authoring Guide" (2010)](https://learn.microsoft.com/en-us/archive/blogs/mpauthor/management-pack-authoring-guide-complete)
- [Kevin Holman — Authoring overrides](https://kevinholman.com/2017/02/05/scom-management-pack-fragment-library/)
- [Microsoft Learn — Bicep parameter files](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/parameter-files)
- [Azure Monitor Health Models — overview](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/)
