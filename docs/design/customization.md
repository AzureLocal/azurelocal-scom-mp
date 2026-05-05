---
title: Customization
description: How to customize thresholds, alerts, scope, and behavior of the Azure Local health monitoring.
---

# Customization

Both tracks of `azurelocal-scom-mp` are designed to be **customized without forking** the project. Every threshold,
every alert, every health rollup decision is parameterized so that operators can adapt the monitoring to local
operational reality without modifying the sealed MP or the canonical ARM/Bicep templates.

> **First principle:** customer customizations must survive an upgrade. If the customer overrides volume free-space
> from 10% to 20% and we ship a new MP version, their override stays. This is non-negotiable across both tracks.

---

## Track 1 — SCOM Management Pack

### Override pack pattern

We ship two MPs, not one:

| MP | Sealed? | Edited by | Purpose |
|---|---|---|---|
| `AzureLocal.HealthModel.mp` | ✅ Sealed | Project maintainers only | Classes, discoveries, monitors, rules, Distributed Application |
| `AzureLocal.HealthModel.Overrides.xml` | ❌ Unsealed | Customer | All threshold and behavior overrides; ships with sensible defaults |

This is the standard Microsoft pattern. The customer never edits the sealed MP. They edit the unsealed override pack
(or create their own sibling override pack referencing the sealed one).

### What can be overridden

Every monitor and rule in the sealed MP exposes the following override surface:

| Override type | What it controls | Typical use case |
|---|---|---|
| **Enabled/disabled** | Turn a monitor or rule on/off | Disable disk-temperature monitor in environments without sensor support |
| **Threshold parameters** | The numeric trigger value | Volume free-space threshold from 10% → 20% |
| **Interval / sync time** | How often a monitor runs | Reduce check frequency on resource-constrained nodes |
| **Alert severity / priority** | Critical vs Warning vs Information | Downgrade alerts that don't warrant on-call attention |
| **Alert auto-resolve** | Whether a state-recovery resolves the alert | Disable for compliance audit tracking |

### Override scope (from broadest to narrowest)

| Scope | Effect | Example |
|---|---|---|
| **For all objects of class** | Applies to every instance of `AzureLocal.Cluster.Volume` | Org-wide volume free-space threshold change |
| **For a group** | Applies to a SCOM group (e.g. "Production HCI Volumes") | Different thresholds per environment |
| **For a specific object** | Applies to one named instance | A specific volume known to run hot intentionally |

### Threshold tiers (shipped in the override pack)

The override pack ships with three pre-built threshold tiers that the customer can swap by enabling
the relevant override group:

| Tier | Intent | Example: volume free-space warn / crit |
|---|---|---|
| **`Lab`** | Generous thresholds, alerts only on serious issues | 5% / 2% |
| **`Standard`** *(default)* | Production defaults aligned with MS recommendations | 15% / 10% |
| **`Strict`** | Tight thresholds for compliance-heavy environments | 25% / 15% |

Operators pick a tier by enabling its override group; per-instance fine-tuning still works on top.

### Customer override pack pattern (recommended)

Operators are encouraged to create their **own** override pack that references the project's override pack.
This keeps customer-specific tuning visible and version-controlled separately from project defaults:

```text
AzureLocal.HealthModel.mp                  ← sealed, ships from us
AzureLocal.HealthModel.Overrides.xml        ← unsealed defaults, ships from us
Contoso.AzureLocal.Overrides.xml            ← customer-authored, references our override pack
```

---

## Track 2 — Azure Monitor Health Model

### Parameterization via Bicep

The health model and signals ship as Bicep modules with explicit parameters for every customizable value:

```bicep
param volumeFreeSpaceWarningThresholdPct int = 15
param volumeFreeSpaceCriticalThresholdPct int = 10
param storageJobLatencyWarnSeconds int = 30
param storageJobLatencyCritSeconds int = 90
param arcAgentHeartbeatStaleMinutes int = 15
// ... one parameter per threshold
```

Operators consume the modules from their own deployment with a `*.bicepparam` file:

```bicep
using './main.bicep'

param volumeFreeSpaceWarningThresholdPct = 25
param volumeFreeSpaceCriticalThresholdPct = 15
// keep all other defaults
```

### Customization tiers (parallel to SCOM)

The same `Lab` / `Standard` / `Strict` tiers ship as pre-built `*.bicepparam` files:

- `params/lab.bicepparam`
- `params/standard.bicepparam` *(default)*
- `params/strict.bicepparam`

### Custom KQL signal replacement

Every KQL-driven signal (e.g., Arc agent heartbeat freshness) is exposed as a named module input. Operators
can replace any signal's KQL query with their own without modifying the upstream module.

```bicep
param customArcHeartbeatKqlOverride string = ''
// If non-empty, the signal uses this KQL instead of the canonical query.
```

### Action groups and alert routing

The module accepts an array of action group resource IDs. Operators wire up their existing PagerDuty /
ServiceNow / email lists without touching the module:

```bicep
param actionGroupIds array = [
  '/subscriptions/.../actionGroups/contoso-oncall-tier1'
  '/subscriptions/.../actionGroups/contoso-storage-team'
]
```

### Service Group scoping

Customers control which Azure Local clusters the health model applies to via the Service Group resource
ID input. One health model can scope to a single cluster, all clusters in a subscription, or a curated set.

---

## Cross-track parity

Both tracks expose the **same threshold names** so the same numbers carry across:

| Logical threshold | SCOM override parameter | Azure Monitor Bicep parameter |
|---|---|---|
| Volume free-space (warn) | `Volume.FreeSpace.WarnPercent` | `volumeFreeSpaceWarningThresholdPct` |
| Volume free-space (crit) | `Volume.FreeSpace.CritPercent` | `volumeFreeSpaceCriticalThresholdPct` |
| Storage job latency (warn) | `StorageJob.Latency.WarnSeconds` | `storageJobLatencyWarnSeconds` |
| Storage job latency (crit) | `StorageJob.Latency.CritSeconds` | `storageJobLatencyCritSeconds` |
| Arc agent heartbeat stale | `ArcAgent.Heartbeat.StaleMinutes` | `arcAgentHeartbeatStaleMinutes` |
| ... (one row per threshold) | ... | ... |

This parity is a hard project requirement — see ADR 0007 (naming convention) and the upcoming ADR on
customization strategy.

## Upgrade safety

| Track | Upgrade safety mechanism |
|---|---|
| **SCOM** | Sealed MP version bumps don't touch the unsealed override pack. Customer's override pack references the sealed MP by ID; SCOM's MP versioning model preserves overrides across upgrades by design. |
| **Azure Monitor** | Bicep modules are versioned. Customer's `*.bicepparam` file is owned by them — module updates can't overwrite it. Module changes that rename parameters require a major version bump and migration notes. |

## Documentation per signal

Every signal documented in [SCOM MP — Monitors](../scom-mp/index.md) and [Azure Monitor — Signals](../azure-monitor/index.md)
includes:

- The shipped default threshold value
- Recommended values per environment tier (lab / standard / strict)
- Override parameter name (both tracks)
- Whether the signal is enabled by default
- Operational impact level (Standard / Limited / Suppressed)

This is the contract between this project and the operator — nothing about thresholds is hidden in code.
