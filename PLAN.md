# Implementation plan — Hybrid Infrastructure Health Monitoring

> Last updated: August 13, 2026
>
> Status: Independent SCOM packaging and platform-owned Distributed Applications accepted;
> Hyper-V research active
> Published roadmap: <https://labs.hybridsolutions.cloud/hybrid-health-monitoring/project/roadmap>

## Objective

Deliver infrastructure health monitoring for **Hyper-V** and **Azure Local**, organized by
platform first and monitoring surface second:

| Platform | SCOM Management Pack | Azure Monitor Health Models |
|---|---|---|
| **Azure Local** | Committed | Committed |
| **Hyper-V** | Committed | Conditional future track through Azure Arc-enabled SCVMM |

The product can reuse research, health terminology, authoring knowledge, and non-runtime engineering
tooling. Azure Local and Hyper-V remain completely independent SCOM runtime products; they do not
share classes, binaries, Distributed Applications, namespaces, dependencies, packages, versions,
or support lifecycles.

## Product hierarchy

Azure DevOps is the delivery system of record:

```text
Epic — Deliver Azure Local health monitoring
├── Feature — Deliver the Azure Local SCOM Management Pack
│   ├── Story — Define independent SCOM packaging and coexistence contract
│   ├── Story — Author Azure Local SCOM classes and discoveries
│   │   └── Task — Author Azure Local DA classes and membership
│   ├── Story — Author Azure Local SCOM monitoring and overrides
│   │   └── Task — Author Azure Local DA rollups and operator surfaces
│   └── Story — Validate, package, and document the release
└── Feature — Deliver Azure Monitor health models for Azure Local
    ├── Story — Validate APIs and signal contracts
    ├── Story — Author entities and signals
    ├── Story — Implement deployment, alerts, and workbooks
    └── Story — Validate and document the release

Epic — Deliver Hyper-V health monitoring
├── Feature — Deliver the Hyper-V SCOM Management Pack
│   ├── Story — Research and define the Hyper-V SCOM monitoring catalog
│   │   ├── Tasks — Scope, raw inventories, and prior-MP research inputs
│   │   ├── Tasks — SCOM workflow and threshold engineering
│   │   ├── Task — Lab and fault validation
│   │   ├── Task — Curate the authoring-ready default catalog
│   │   └── Task — Validate the comprehensive MP and DA architecture
│   ├── Story — Author Hyper-V SCOM classes and discoveries
│   │   └── Task — Author Hyper-V DA classes and membership
│   ├── Story — Author Hyper-V SCOM monitoring and separate Discovery/Monitoring overrides
│   │   └── Task — Author Hyper-V DA rollups and operator surfaces
│   └── Story — Validate, package, and document the release
└── Feature — Evaluate Azure Monitor through Arc-enabled SCVMM
    ├── Story — Research inventory and guest management
    ├── Story — Prove telemetry and Health Models feasibility
    ├── Story — Decide go, defer, or no-go
    └── Story — Plan conditional implementation after a go decision
```

Parent-child and predecessor links in Azure DevOps enforce the research and implementation gates.

## Reusable research and engineering practices

### Reuse across both platforms

- SCOM health dimensions and state semantics;
- unit, aggregate, and dependency monitor patterns;
- stable class-key and relationship principles;
- discovery cookdown, fixture, and test patterns;
- alert-versus-health-state separation;
- upgrade-safe override strategy and threshold tiers;
- signing, validation, packaging, and release gates;
- self-observability for the monitoring pipeline; and
- documentation and optional dashboard patterns.

These are design and engineering practices, not shared Management Pack runtime elements.

### Keep platform-specific

- entity and class inventory;
- discovery APIs and topology rules;
- signal sources, thresholds, and support evidence;
- product prerequisites and supported-version matrix;
- Azure resource and identity dependencies;
- artifacts, namespaces, sealed libraries, monitoring packs, override packs, Distributed
  Applications, signing identities, versions, and support lifecycles; and
- release cadence where platform dependencies differ.

Accepted [ADR 0022](docs/design/decisions/0022-scom-management-pack-packaging-boundaries.md)
prohibits cross-product runtime dependencies. Similar implementation source may exist in both
products when that is safer than coupling their public contracts.

## Architecture decision plan

| ADR | Status | Purpose | Gate |
|---|---|---|---|
| [0021](docs/design/decisions/0021-platform-and-delivery-track-architecture.md) | Accepted | Establish platform-first planning with separate delivery surfaces | Repository-owner decision |
| [0022](docs/design/decisions/0022-scom-management-pack-packaging-boundaries.md) | Accepted | Require independent Azure Local and Hyper-V SCOM runtime products | Packaging validation |
| [0023](docs/design/decisions/0023-hyper-v-azure-monitor-through-arc-enabled-scvmm.md) | Proposed | Decide whether the conditional Hyper-V Azure Monitor track proceeds | Inventory and telemetry research |
| Hyper-V scope and topology | Planned after spike | Lock supported topology, entity inventory, exclusions, and version matrix | Support and topology research |
| Hyper-V SCOM discovery strategy | Planned after spike | Select supported discovery providers and hosting relationships | Workflow research |
| Hyper-V signal and rollup policy | Planned after spike | Lock signal catalog, thresholds, defaults, and exceptions | Signal, threshold, and lab research |
| [0026](docs/design/decisions/0026-platform-owned-scom-distributed-applications.md) | Accepted | Require a separate platform-owned DA in each SCOM product | Repository-owner decision; refined through platform authoring/research |
| [0027](docs/design/decisions/0027-hyper-v-scom-management-pack-decomposition.md) | Proposed | Define modular sealed Hyper-V MPs, separate customer Discovery/Monitoring overrides, and optional tuning templates | Packaging and dependency research |
| [0028](docs/design/decisions/0028-hyper-v-object-and-discovery-architecture.md) | Proposed | Define stable identities, relationships, staged discovery, execution, and cookdown | Topology, workflow, and lab research |
| [0029](docs/design/decisions/0029-hyper-v-health-alert-and-da-rollup.md) | Proposed | Define evidence-driven health, alerting, monitoring freshness, and DA rollup | Threshold, catalog, lab, and DA validation |

Accepted ADRs 0001–0020 continue to govern the Azure Local baseline unless a successor ADR explicitly
supersedes one. They must not be silently generalized to Hyper-V.

## Research plan

All spikes follow the evidence contract in
[`docs/design/research-spikes.md`](docs/design/research-spikes.md).

### Spike A — Independent SCOM packaging contract

Deliver:

- independent class, relationship, namespace, artifact, signing, and version ownership;
- dependency graphs proving no cross-product runtime reference;
- side-by-side import, upgrade, coexistence, and removal analysis;
- allowed non-runtime research and tooling reuse; and
- evidence that each platform owns its Distributed Application and complete support contract.

### Spike B — Hyper-V SCOM monitoring catalog

Deliver:

- Windows Server, Hyper-V, Failover Clustering, SCOM, and optional SCVMM support matrix;
- topology for standalone hosts, clusters, virtual switches, storage, replica, and VMs;
- supported PowerShell, CIM/WMI, event, service, and performance sources;
- Network ATC as the preferred eligible-cluster baseline plus manual and SCVMM/SDN alternatives;
- useful signal and monitor concepts from the Microsoft Hyper-V 2019 MP, treated as research only
  with no package, class, or runtime dependency;
- lab fixtures and negative cases;
- stable standalone-host and cluster DA keys, component membership, and rollup inputs; and
- proposed scope, discovery, signal/rollup, and DA-refinement ADRs.

This is the active umbrella research workstream. Its bounded tasks cover source inventories,
workflow and threshold engineering, lab validation, catalog synthesis, and architecture review. The work
first inventories everything observable, then maps acquisition and threshold behavior, validates it
in the lab, and finally classifies each candidate as Must monitor, Should monitor, Could monitor,
collect only, diagnostic, or excluded. The detailed contract is published in
[`docs/hyper-v/monitoring-research.md`](docs/hyper-v/monitoring-research.md).

### Spike C — Azure Local Health Models revalidation

Deliver:

- current API versions and regional or preview limits;
- current Service Group, identity, RBAC, DCR, LAW/AMW, and Resource Graph contract;
- signal availability delta against the Azure Local catalog; and
- successor ADRs for any material change.

### Spike D — Arc-enabled SCVMM inventory and guest management

Deliver:

- ARM resource map for SCVMM clouds, clusters, hosts, networks, and VMs;
- distinction between inventory projection and Arc-enabled Servers guest management;
- Arc Resource Bridge, agent, identity, RBAC, network, and version prerequisites; and
- repeatable lab onboarding and inventory evidence.

### Spike E — Hyper-V telemetry and Health Models feasibility

Deliver:

- minimum viable Hyper-V entity graph;
- supported metric, log, Resource Graph, and Resource Health signals;
- AMA, DCR, LAW/AMW, Service Group, identity, and health-objective proof;
- fault-injection results;
- latency, cost, scale, lifecycle, and preview-risk assessment; and
- recommendation for ADR 0023.

## Delivery plan

### Azure Local SCOM Management Pack

1. Apply the independent product boundary in ADR 0022.
2. Author the Azure Local library, relationships, discoveries, DA classes, and dynamic membership.
3. Author monitors, rules, DA rollups, operator views, reports, SLO targets, and override tiers.
4. Validate with offline fixtures and a pre-production SCOM management group, including DA
   population, state propagation, coexistence, upgrade, and removal.
5. Seal, sign, version, package, document, and release independently.

### Azure Local Azure Monitor

1. Revalidate current APIs, limits, prerequisites, and signals.
2. Author Service Group membership, entities, relationships, health objectives, metrics, and KQL.
3. Implement Bicep modules, parameter tiers, alerts, action groups, DCR associations, and workbooks.
4. Validate lint, what-if, deployment, identity, fault propagation, scale, cost, and teardown.
5. Version, document, and release with preview limitations stated explicitly.

### Hyper-V SCOM Management Pack

1. Complete the topology/support spike, including per-cluster and per-standalone-host DA boundaries,
   and resolve proposed ADRs 0027–0029 using the research and lab evidence.
2. Apply the independent product boundary in ADR 0022.
3. Author approved classes, relationships, discoveries, DA classes, and dynamic membership for
   each supported topology variant.
4. Author monitors, rules, DA rollups, operator views, reports, SLO targets, separate Discovery and
   Monitoring override contracts, and optional Lab, Standard, and Strict starter templates using
   Hyper-V evidence.
5. Validate standalone, clustered, and approved SCVMM-managed configurations, including DA
   population, topology change, state propagation, coexistence, upgrade, and removal.
6. Seal, sign, version, package, publish the administration and override guide, and release
   independently.

### Hyper-V Azure Monitor through Arc-enabled SCVMM

This work remains deferred. Only the two research spikes and go/no-go ADR are approved now.
Implementation starts only if ADR 0023 is accepted with a go decision. A go must identify exact
mandatory prerequisites and supported entity/signal coverage; it must not promise parity with SCOM
where supported Azure telemetry does not exist.

## Planned repository shape

The source layout preserves the independent runtime boundary:

```text
docs/
├── design/                 # Shared principles, research, and ADRs
├── azure-local/            # Azure Local platform entry point
├── hyper-v/                # Hyper-V platform entry point
├── scom-mp/                # Existing Azure Local SCOM implementation docs
└── azure-monitor/          # Existing Azure Local Azure Monitor implementation docs

src/
├── azure-local/
│   ├── scom-mp/
│   └── azure-monitor/
└── hyper-v/
    ├── scom-mp/
    └── azure-monitor/      # Reserved now; deployable source only after an ADR 0023 go decision

tools/                      # Non-runtime build and validation automation only
```

Research remains in documentation and evidence artifacts. No shared Management Pack runtime source
tree or sealed library is planned. Accepted ADR 0030 is the current source-path authority.

## Validation gates

### Documentation

- `npm ci`
- `npm run docs:build`
- all navigation targets and internal links resolve;
- Mermaid diagrams render without syntax errors;
- published GitHub Pages workflow succeeds; and
- representative Azure Local, Hyper-V, ADR, and roadmap pages return HTTP 200.

### SCOM

- schema and Management Pack verification;
- best-practice analysis with reviewed warnings;
- Pester discovery and workflow fixtures;
- clean import, discovery, health-state transition, upgrade, and removal tests;
- deterministic DA population, relationship, rollup, view, report, and SLO tests;
- side-by-side installation with no cross-product classes, references, or dependencies;
- no unexpected Health Service Modules events; and
- signed artifacts and reproducible package contents.

### Azure Monitor

- Bicep lint, build, and what-if;
- clean lab deployment and teardown;
- least-privilege identity and RBAC verification;
- signal freshness and Unknown-state behavior;
- fault-injection and propagation tests;
- documented API, region, preview, cost, and scale constraints; and
- no credentials or tenant identifiers in source or artifacts.

## Sequencing and capacity

The immediate sequence is research and architecture, not parallel implementation of every track.
After the spikes, effort and lab requirements will determine whether the three committed Features
run sequentially or partially in parallel. The conditional Hyper-V Azure Monitor Feature does not
consume implementation capacity until its gate passes.

## Out of scope

- application and guest-workload monitoring;
- production deployment into customer environments;
- unsupported or undocumented telemetry collection;
- a guarantee of Azure Monitor parity for Hyper-V;
- renaming the GitHub repository or Azure DevOps project before dependency and release impacts are
  understood; and
- activating Hyper-V Azure Monitor implementation before ADR 0023 records a go decision.
