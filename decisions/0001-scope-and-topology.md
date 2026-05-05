# ADR 0001 — Scope & topology: Azure Local infrastructure (3 layers, ~25 entities)

- **Status**: Proposed
- **Date**: 2026-05-05
- **Deciders**: @AzureLocal/azurelocal-scom-mp-maintainers

## Context

`azurelocal-scom-mp` delivers production-grade health monitoring for Azure Local in two
parallel tracks (SCOM Management Pack + Azure Monitor Health Model). Before any authoring
or modeling work begins we must lock down **what we monitor** and **at what granularity**.
Without an explicit scope decision two failure modes are likely:

1. **Scope creep into workloads** — every customer wants their VMs and AKS pods monitored,
   but workload-level monitoring belongs in companion MPs that *consume* this health model
   (see `docs/project/roadmap.md`). Mixing the two collapses the layering.
2. **Scope gaps in Azure-side resources** — an Azure Local "deployment" is not just the
   on-prem cluster. It includes managed identities, SPNs, Key Vault, Storage Account,
   Custom Locations, Arc-enabled servers, Resource Bridge, etc. Missing those leaves
   the customer with a partial picture.

We also need to decide **topology granularity** — how deep does the entity tree go?
Modeling every physical disk and individual NIC as separate classes inflates class count
beyond what's authorable in the project's timeline; under-modeling collapses important
distinctions (Network ATC intents, Storage Pools).

## Decision

This project monitors **Azure Local infrastructure only** — every component that is
deployed *as part of* an Azure Local deployment, modeled across **three layers**:

### Layer 1 — On-prem (the cluster box)

| Entity | Notes |
|---|---|
| Cluster | The Azure Local cluster itself (S2D + Failover Clustering) |
| Node | Each cluster member node |
| Storage Pool | The Storage Spaces Direct pool |
| Volume (CSV) | Each cluster shared volume |
| Storage Tier (cache) | Pool's cache tier |
| Network Intent (Network ATC) | Each named intent — Mgmt / Compute / Storage |
| Storage Replica | Replication relationship (if configured) |
| Update / LCM state | Solution-level update posture |

> **Granularity note:** Physical disks roll into the Storage Pool entity (not modeled as
> separate classes). Individual NICs roll into the Network Intent entity. This is the
> "standard" topology — pragmatic depth without exploding the class count.

### Layer 2 — Cluster-resident platform services

| Entity | Notes |
|---|---|
| Arc Resource Bridge / MOC | The Resource Bridge VM and its MOC components |
| AKS Arc platform | Only the AKS *platform* (host pool, control plane reachability) — **not** workload pods |
| Azure Local agent (Cloud Agent / DCMA) | The Microsoft-supplied management agents |
| HCI registration state | Registration / billing / license tier |

### Layer 3 — Azure-side infrastructure

| Entity | Notes |
|---|---|
| HCI Cluster resource | `Microsoft.AzureStackHCI/clusters` |
| Arc-enabled Server (per node) | `Microsoft.HybridCompute/machines` |
| Custom Location | The Custom Location Azure resource |
| Logical Networks | `Microsoft.AzureStackHCI/logicalNetworks` |
| Managed Identity | System-assigned + user-assigned MIs used by the deployment |
| Service Principal (deployment SPN) | The SPN that performs deployment / ongoing operations |
| Key Vault | The Key Vault used by the deployment (secrets, access policies, expiry) |
| Storage Account | The Storage Account used by the deployment |
| Storage Container / Blob path | Specific containers / paths required by the deployment |
| RBAC / Role Assignments | Required role assignments on cluster identity, deployment SPN, MI |
| Update Manager linkage | Azure Update Manager linkage for the cluster |
| Data Collection Rule(s) | Azure Monitor DCRs associated with the cluster |
| Log Analytics Workspace linkage | Workspace reachability + ingestion |
| Resource Health / Activity Log | Per-resource health stream |

**Total: ~25 entities across 3 layers.**

### Explicitly out of scope (deferred to companion MPs)

- Guest OS health inside HCI VMs
- Application services running inside VMs
- AKS Arc workload pods, deployments, ingress
- SQL MI / AVD / other workloads
- Customer applications and their dependencies

These are tracked in the [Roadmap](../docs/project/roadmap.md) as future companion MPs that
take a *dependency* on this health model.

## Consequences

- **Positive**: Clear, defensible scope boundary. The health story covers the *full Azure Local
  deployment* — both on-prem and Azure-side — without bleeding into workload monitoring.
  Class count stays around 25, which is authorable in the project's planned timeline.
- **Positive**: Companion-MP pattern is a clean extension model — workload MPs reference
  these entity IDs to inherit infrastructure health.
- **Negative**: Three-layer scope means three different signal-collection strategies (PowerShell
  on-cluster for L1+L2, ARM/Resource Graph for L3). Increases authoring complexity vs. an
  on-prem-only MP. Mitigated by ADR 0002 (signal source decision).
- **Negative**: Some customers will ask "why isn't my VM in here?" — requires clear comms in
  the docs and a roadmap commitment to workload companion MPs.
- **Neutral**: ~25 entities is a meaningful authoring effort but matches the depth of
  comparable vendor MPs (Dell HCI, HPE storage MPs).
- **Affected components / owners**: All Phase 3 (SCOM) and Phase 4 (Azure Monitor) authoring
  work derives from this entity list. ADRs 0005 and 0006 build the class hierarchy and entity
  graph from these entities. ADR 0008 (customization) parameterizes thresholds for each.

## Alternatives considered

- **On-prem only (Layer 1)** — rejected: customers care about Azure-side configuration
  drift (Key Vault expiry, missing role assignments) just as much as cluster health. Leaving
  Layer 3 out would ship a half-product.
- **Include workloads (VMs, AKS pods, applications)** — rejected: explodes scope, blurs
  ownership, and makes the project unfinishable. Companion MP pattern is the right answer.
- **Fine-grained topology (15+ classes including per-disk, per-NIC)** — rejected: 2–3× the
  authoring work for marginal diagnostic value. Storage Pool and Network Intent are the
  right rollup boundaries because they match how operators actually reason about the cluster.
- **Coarse topology (collapse Storage Pool into Cluster, drop Network Intent)** — rejected:
  loses the two most important Azure Local–specific abstractions. Operators expect to see
  Storage Pool and Network Intent health distinctly.
