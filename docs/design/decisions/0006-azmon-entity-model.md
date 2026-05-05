# ADR 0006 — Azure Monitor entity model alignment (mirrors SCOM 1:1)

- **Status**: Proposed
- **Date**: 2026-05-05
- **Deciders**: @AzureLocal/azurelocal-scom-mp-maintainers

## Context

[ADR 0005](0005-scom-class-hierarchy.md) defines the SCOM class graph. The Azure Monitor
Health Models track has its own entity model — but if we don't make explicit choices about
how the two relate, they will drift over time and the cross-track parity guarantee
([ADR 0007](0007-naming-convention.md)) becomes impossible to maintain.

Azure Monitor Health Models entity types ([Microsoft Learn — Health Models overview](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/)):

- **Azure Resource Entity** — bound to a single ARM resource ID; inherits Resource
  Health automatically; signals via metrics, KQL on logs/Activity Log
- **Logical Entity** — abstract; not bound to an ARM resource; signals via KQL or model
  expressions
- **Group Entity** — collection of other entities (used for the model root and for
  groupings like "all nodes")

Azure Monitor relationships are simpler than SCOM:

- **Parent / child** with an `impact` setting (`Standard` / `Limited` / `Suppressed`)
- No hosting vs. containment vs. reference distinction — one relationship type, semantics
  configured by impact

The Service Group ([Microsoft Learn — Azure Service Groups](https://learn.microsoft.com/en-us/azure/governance/service-groups/overview))
acts as the *membership boundary* — only resources in the Service Group can be Azure
Resource Entities in the model. So Service Group composition is itself an architectural
decision.

## Decision

The Azure Monitor entity model **mirrors the SCOM class hierarchy 1:1**, with three
mechanical translation rules:

### Rule 1 — entity type follows ARM resource availability

| If the entity… | Use Azure Monitor entity type |
|---|---|
| Maps to a single ARM resource | **Azure Resource Entity** (bound to the ARM ID) |
| Has no ARM resource (purely on-prem concept like Volume, NetworkIntent) | **Logical Entity** with KQL/DCMA-metric signals |
| Is a roll-up grouping (Deployment root, "all nodes") | **Group Entity** |

### Rule 2 — relationships use Standard impact unless ADR 0003 says otherwise

[ADR 0003](0003-health-rollup-policy.md) is the rollup policy. The mechanical translation:

| SCOM relationship | Azure Monitor impact |
|---|---|
| Hosting / containment + Worst-of dependency | **Standard** |
| Reference relationship | **Standard** (still rolls up — they're real parts of the deployment) |
| Documented exception (e.g., Storage Replica DR partner unreachable) | **Suppressed** |
| `Update.LastResult` | **Limited** (max severity Warning) |

### Rule 3 — Service Group membership = the entity inventory

The Azure Service Group for an Azure Local deployment **must** include exactly the L3
entities from [ADR 0001](0001-scope-and-topology.md):

- `Microsoft.AzureStackHCI/clusters` (the cluster resource)
- `Microsoft.HybridCompute/machines` (each node)
- `Microsoft.AzureStackHCI/logicalNetworks`
- `Microsoft.ResourceConnector/appliances` (Resource Bridge)
- `Microsoft.ExtendedLocation/customLocations`
- `Microsoft.KeyVault/vaults` (the deployment Key Vault)
- `Microsoft.Storage/storageAccounts` (the deployment Storage Account)
- `Microsoft.ManagedIdentity/userAssignedIdentities`
- `Microsoft.Insights/dataCollectionRules`
- `Microsoft.OperationalInsights/workspaces` (linked LAW)

Logical entities (Volume, NetworkIntent, StoragePool, etc.) are added to the model but
not to the Service Group (Service Groups can only contain ARM resources).

### Entity-level signal sources

Per [ADR 0002](0002-signal-source.md):

| Entity layer | First signal | Second signal | Notes |
|---|---|---|---|
| **L3 Azure Resource Entity** | Resource Health | Activity Log adverse events | Free; both auto-emit |
| **L1 Logical Entity** | DCMA metric (`AzureStackHCI/clusters` namespace) | KQL on `Event` from AMA | DCMA preferred for time-series; KQL for state |
| **Cross-resource (e.g., RBAC drift)** | Resource Graph KQL | n/a | Run on a schedule via DCR or alert rule |

### Health Objectives

Each entity has up to four Health Objectives, matching the four health dimensions
locked by the [Health Model](../health-model.md):

- Availability
- Performance
- Configuration
- Security (L3 only)

Each objective has its own signal set and rolls up via worst-of within the entity.

## Consequences

- **Positive**: 1:1 alignment makes cross-track parity tractable. Every SCOM class has
  an Azure Monitor entity counterpart with the same signals (translated per
  [ADR 0007](0007-naming-convention.md)).
- **Positive**: Bound Azure Resource Entities inherit Resource Health for free — the
  baseline signal on every L3 entity is built in.
- **Positive**: Service Group composition is explicit and enforceable — a Bicep template
  can stamp out the Service Group with the exact required members.
- **Positive**: Logical Entities for L1 mean we can model on-prem-only concepts (Volume,
  StoragePool, NetIntent) cleanly, without having to invent fake ARM resources.
- **Negative**: Logical Entities don't inherit Resource Health — every signal on them is
  custom KQL or DCMA. More authoring cost, but unavoidable for on-prem-only entities.
- **Negative**: Service Group membership has to be maintained — adding a new resource to
  a deployment requires adding it to the Service Group too. Mitigated by the Bicep
  module ([ADR 0008](0008-customization-strategy.md)) which always emits the full set.
- **Affected**: Phase 4 Azure Monitor authoring derives every entity, every relationship,
  and the Service Group definition from this ADR.

## Alternatives considered

- **Don't mirror SCOM — design Azure Monitor model independently** — rejected: defeats
  the cross-track parity story; doubles authoring cost; creates two different mental
  models.
- **Make every L1 entity a fake ARM resource** — rejected: not supported by ARM and
  pollutes the resource graph.
- **One mega-Logical Entity for the whole cluster** — rejected: collapses the rollup
  signal; operators can't drill into a specific volume's health.

## References

- ADR 0001 — [Scope & topology](0001-scope-and-topology.md)
- ADR 0002 — [Primary signal source](0002-signal-source.md)
- ADR 0003 — [Health rollup policy](0003-health-rollup-policy.md)
- ADR 0005 — [SCOM class hierarchy](0005-scom-class-hierarchy.md)
- ADR 0007 — [Naming convention](0007-naming-convention.md)
- [Azure Monitor Health Models — overview](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/)
- [Azure Service Groups — overview](https://learn.microsoft.com/en-us/azure/governance/service-groups/overview)
- [Resource Health — list of supported resource types](https://learn.microsoft.com/en-us/azure/service-health/resource-health-checks-resource-types)
- [Azure Local — monitoring overview](https://learn.microsoft.com/en-us/azure/azure-local/concepts/monitoring-overview?view=azloc-2604)
