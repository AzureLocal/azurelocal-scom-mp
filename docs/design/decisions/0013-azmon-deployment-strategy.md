# ADR 0013 — Azure Monitor Health Model deployment strategy (Bicep-first, portal-bootstrap)

- **Status**: Accepted
- **Date**: 2026-05-05
- **Deciders**: @AzureLocal/azurelocal-scom-mp-maintainers

## Context

Unlike a SCOM Management Pack — where the artifact is a sealed `.mp` file imported
once into the management group — the Azure Monitor Health Model has **no equivalent
packaging format**. Every deployment requires provisioning a graph of ARM resources in
dependency order:

1. **Service Group** (`Microsoft.Management/serviceGroups`) — membership boundary;
   must exist before the health model can reference it
2. **Health Model** (`Microsoft.Monitor/healthModels`) — references the Service Group;
   contains entity + relationship definitions with embedded KQL signal queries
3. **Data Collection Rules** (`Microsoft.Insights/dataCollectionRules`) — DCMA/AMA
   metric routing; must exist before signal queries that reference them are live
4. **Alert Rules** (`microsoft.insights/scheduledQueryRules` or `metricAlerts`) —
   reference the model or underlying signals; authored separately per ADR 0009
5. **Action Groups** (`microsoft.insights/actionGroups`) — notification routing;
   referenced by alert rules

These resources must be deployed in order. Re-deploying an updated health model must
be idempotent — a second `az deployment` with the same parameters must converge to the
same state without destroying live alert subscriptions.

The Azure portal's Health Model designer is useful for **initial exploration and
validation**, but it produces no exportable artifact that could serve as source of
truth for repeatable deployments. Any portal-only workflow creates drift and makes
GitOps impossible.

[ADR 0008](0008-customization-strategy.md) already decided that the Azure Monitor track
uses **Bicep `param` with three pre-built `.bicepparam` tiers** (lab / standard / strict).
This ADR specifies how that Bicep is structured and how it is deployed.

## Decision

**Bicep is the source of truth. The portal is a bootstrap tool only.**

### Workflow

```
Portal designer (once, on first build)
  │
  └─ az health-model export / az bicep decompile
       │
       └─▶  src/azure-monitor/bicep/  ◀── source of truth (Git)
                  │
                  └─ az deployment sub create --template-file main.bicep
                       │
                       └─▶  dist/  (generated ARM JSON, gitignored from CI publish)
```

1. **Bootstrap** — build the initial health model interactively in the Azure portal to
   validate entity topology and signal queries against a real environment.
2. **Export** — export the portal-authored model to ARM JSON; decompile to Bicep with
   `az bicep decompile`. The result becomes the starting point for `src/azure-monitor/bicep/`.
3. **Modularize** — split the flat decompiled output into the module structure below.
   This is a one-time manual step.
4. **Source of truth** — from this point forward, all changes go through Bicep + PR
   review. The portal is read-only for inspection.
5. **Deploy** — operators run `Deploy-HealthModel.ps1` (a thin wrapper around
   `az deployment sub create`) with the appropriate `.bicepparam` file.

### Module structure

```
src/azure-monitor/bicep/
├── main.bicep                  # Orchestrator — deploys modules in dependency order
├── modules/
│   ├── service-group.bicep     # Microsoft.Management/serviceGroups
│   ├── health-model.bicep      # Microsoft.Monitor/healthModels (entities + relationships)
│   ├── entities.bicep          # Entity definitions + KQL signal wiring (included by health-model)
│   ├── alerts.bicep            # Scheduled query rules + metric alert rules
│   ├── action-groups.bicep     # Notification routing
│   └── dcr.bicep               # Data Collection Rules (DCMA/AMA)
└── parameters/
    ├── lab.bicepparam          # Relaxed thresholds, no paging action groups
    ├── standard.bicepparam     # Production defaults
    └── strict.bicepparam       # High-criticality: tighter thresholds, paging on warn
```

### KQL signals as standalone files

Every KQL signal query that is embedded in `entities.bicep` also exists as a standalone
`.kql` file in `src/azure-monitor/kql/signals/`. This allows:
- Independent linting / testing of queries outside the Bicep deployment pipeline
- Copy-paste into the portal designer during the bootstrap phase
- Validation against a live Log Analytics Workspace using the `az monitor log-analytics query` CLI

The `kql/health-score.kql` file is a separate WAF Mission-Critical-style layered health
score query — it is *not* embedded in the model; it runs as a standalone workbook query.

### Deployment wrapper

`scripts/Deploy-HealthModel.ps1` handles:
- Pre-flight: verify Az CLI login, subscription context, required resource providers registered
- `az deployment sub create` with the specified `.bicepparam` file
- Post-flight: confirm Service Group membership is populated, health model shows entities

### Generated output

`dist/` contains `bicep build` artifacts (ARM JSON). This directory is:
- **Not hand-edited** — treat as build output
- **Committed** for audit trail (operators can inspect the exact ARM being deployed)
- **Excluded from MkDocs** and from release artifacts (Bicep source is the release artifact)

## Consequences

- **Positive**: Deployments are repeatable, reviewable via PR, and idempotent. Three
  parameter tiers ship out of the box — operators pick one and deploy.
- **Positive**: KQL signals in `kql/signals/` can be tested independently before being
  embedded in the health model, catching query errors before a deployment.
- **Positive**: The `dist/` ARM JSON gives operators a human-readable view of exactly
  what will be deployed without needing Bicep tooling.
- **Negative**: The portal-bootstrap step requires a real Azure environment with Azure
  Local resources registered before the first export can happen. CI pipelines cannot
  fully validate the health model definition without a live LAW.
- **Neutral**: The portal is still useful for exploratory work — but any portal changes
  must be re-exported and diffed into the Bicep source before they're considered canonical.
- **Affected components**: Phase 4 implementation, `src/azure-monitor/bicep/`, `scripts/`,
  `kql/signals/`, MkDocs `azure-monitor/` section.

## Alternatives considered

- **Portal-only** — rejected: produces no artifact, no GitOps, no repeatability.
- **ARM JSON directly** — rejected: verbose, hard to parameterize, no module composition.
- **Terraform** — rejected: adds HashiCorp toolchain dependency for a Microsoft-native
  resource graph; Bicep has native ARM type safety and first-party `az bicep` tooling.
- **Ansible** — rejected: imperative config management; not idiomatic for ARM resource
  graph deployments that require dependency ordering.
- **PowerShell + Az module only** — rejected: no declarative state; re-run is not
  idempotent without significant defensive coding that Bicep provides for free.

## References

- ADR 0006 — [Azure Monitor entity model](0006-azmon-entity-model.md)
- ADR 0008 — [Customization strategy (Bicep params + tiers)](0008-customization-strategy.md)
- ADR 0009 — [Alert vs health-state separation](0009-alert-vs-health-state.md)
- ADR 0010 — [Cloud prerequisites contract](0010-cloud-prerequisites-contract.md)
- [Microsoft.Monitor/healthModels Bicep reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.monitor/healthmodels)
- [Microsoft.Management/serviceGroups Bicep reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.management/servicegroups)
- [Azure Bicep best practices — module design](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/best-practices)
- [WAF Mission-Critical — health modelling pattern](https://learn.microsoft.com/en-us/azure/well-architected/mission-critical/mission-critical-health-modeling)
