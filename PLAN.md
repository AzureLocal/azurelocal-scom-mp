# Implementation plan — Hybrid Infrastructure Health Monitoring

> Last updated: August 13, 2026
>
> Status: Azure Local and Hyper-V functional SCOM MPs and Distributed Applications authored;
> release certification requires SDK dependencies, sealing/signing, and representative SCOM lab
> validation. Azure Monitor research and implementation are next.
> Published roadmap: <https://labs.hybridsolutions.cloud/hybrid-health-monitoring/project/roadmap>

## Objective

Deliver infrastructure health monitoring for **Hyper-V** and **Azure Local**, organized by
platform first and monitoring surface second:

| Platform | SCOM Management Pack | Azure Monitor Health Models |
|---|---|---|
| **Azure Local** | Committed | Committed |
| **Hyper-V** | Committed | Constrained development through Azure Arc-enabled SCVMM and Arc-enabled Servers |

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
| [0023](docs/design/decisions/0023-hyper-v-azure-monitor-through-arc-enabled-scvmm.md) | Accepted — constrained go | Require SCVMM inventory plus Arc-enabled host telemetry and explicit parity gaps | Live inventory and telemetry validation |
| Hyper-V scope and topology | Planned after spike | Lock supported topology, entity inventory, exclusions, and version matrix | Support and topology research |
| Hyper-V SCOM discovery strategy | Planned after spike | Select supported discovery providers and hosting relationships | Workflow research |
| Hyper-V signal and rollup policy | Planned after spike | Lock signal catalog, thresholds, defaults, and exceptions | Signal, threshold, and lab research |
| [0026](docs/design/decisions/0026-platform-owned-scom-distributed-applications.md) | Accepted | Require a separate platform-owned DA in each SCOM product | Repository-owner decision; refined through platform authoring/research |
| [0027](docs/design/decisions/0027-hyper-v-scom-management-pack-decomposition.md) | Accepted | Define modular sealed Hyper-V MPs, separate customer Discovery/Monitoring overrides, and optional tuning templates | Implemented; packaging certification pending |
| [0028](docs/design/decisions/0028-hyper-v-object-and-discovery-architecture.md) | Accepted | Define stable identities, relationships, staged discovery, execution, and cookdown | Implemented; lab lifecycle validation pending |
| [0029](docs/design/decisions/0029-hyper-v-health-alert-and-da-rollup.md) | Accepted | Define evidence-driven health, alerting, monitoring freshness, and DA rollup | Implemented; threshold and DA lab validation pending |
| [0032](docs/design/decisions/0032-azure-local-scom-local-runtime-boundary.md) | Accepted | Keep the core Azure Local SCOM product useful without Azure connectivity | Implemented; outage validation pending |
| [0033](docs/design/decisions/0033-azure-local-scom-management-pack-decomposition.md) | Accepted | Define five Azure Local product artifacts and separate customer override MPs | Implemented; SDK and sealing gates pending |
| [0034](docs/design/decisions/0034-azure-local-object-discovery-and-da-architecture.md) | Accepted | Define Azure Local objects, staged discovery, relationships, and six-branch DA | Implemented; lab reconciliation pending |
| [0035](docs/design/decisions/0035-azure-local-health-alert-and-rollup-architecture.md) | Accepted | Define local health, curated alerts, performance/events, and domain rollup | Implemented; threshold and fault validation pending |
| [0036](docs/design/decisions/0036-azure-local-azure-monitor-health-model-v1.md) | Accepted | Define the current Azure Local preview Health Model baseline | Implemented; live validation pending |
| [0037](docs/design/decisions/0037-hyper-v-azure-monitor-health-model-architecture.md) | Accepted | Define the constrained SCVMM inventory plus Arc-enabled host Health Model | Implemented; live validation and parity review pending |

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

1. Apply the independent product boundary in ADR 0022. **Complete.**
2. Author the Azure Local library, relationships, discoveries, DA classes, and dynamic membership.
   **Functional development baseline complete.**
3. Author monitors, rules, DA rollups, operator views, reporting surface, operational knowledge,
   diagnostics, and override tiers. **Functional development baseline complete.**
4. Run offline contract and Pester tests, then verify against the Microsoft SDK after the official
   sealed dependency MPs are supplied. **Contract tests complete; remaining gates pending.**
5. Validate with a pre-production SCOM management group, including DA
   population, state propagation, coexistence, upgrade, and removal.
6. Seal, sign, version, package, document, and release independently.

### Azure Local Azure Monitor

1. Revalidate current APIs, limits, prerequisites, and signals. **Initial desk research complete.**
2. Author entities, relationships, health objectives, documented metrics, and research KQL.
   **Preview development baseline complete.**
3. Implement Bicep modules, parameter tiers, state alerts, identity, and workbook.
   **Preview development baseline complete and compiling.**
4. Validate live metric definitions, Log Analytics schemas, Service Group discovery, lint, what-if,
   deployment, identity/RBAC, fault propagation, scale, cost, and teardown.
5. Version, document, and release with preview limitations stated explicitly.

### Hyper-V SCOM Management Pack

1. Continue topology/support evidence, including per-cluster and per-standalone-host DA boundaries,
   and raise successor ADRs if lab results invalidate accepted ADRs 0027–0029.
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

ADR 0023 records a constrained go and the first Bicep-compiling development baseline is complete.
Arc-enabled SCVMM supplies management-plane inventory; Arc-enabled Server, AMA, and the solution DCR
supply participating host telemetry. The next work is live inventory/schema, DCR association,
identity, fault/recovery, scale, cost, and teardown validation. The solution must not promise SCOM
parity where supported Azure telemetry does not exist.

### SCOM to ServiceNow integration

1. Research the ServiceNow SCOM Events/Metrics connector split, MID Server prerequisites, supported
   SCOM versions, lifecycle behavior, security, and SCOM product-connector filtering. **Complete.**
2. Accept the connector-neutral MP boundary and initial unidirectional lifecycle policy in ADR
   0038. **Complete.**
3. Define separate Azure Local and Hyper-V allow-list profiles plus a common event, identity,
   severity, CI, correlation, and lifecycle contract. **Development baseline complete.**
4. Validate both authored MPs for auto-resolving monitor alerts, localized event alerts, and
   suppression keys. **Offline contract complete.**
5. In a ServiceNow/SCOM lab, validate installed-release licensing/version support, MID Server and
   assemblies, least privilege, connector filters, CMDB binding, deduplication, maintenance,
   outage/replay, close/reopen/ticket behavior, upgrade, rollback, and removal.
6. Keep the separate SCOM Metrics connector disabled unless Metric Intelligence licensing, Data
   Warehouse access, value, cost, and scale are explicitly approved.

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
├── hyper-v/
    ├── scom-mp/
    └── azure-monitor/      # Constrained SCVMM + Arc-enabled host development solution
└── integrations/
    └── servicenow/scom/    # Optional secret-free connector profiles, mappings, and validation

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

The functional development baselines are authored sequentially. Release capacity now focuses on
dependency, SDK, lab, identity, telemetry, fault, cost, and lifecycle evidence for each independent
solution.

## Out of scope

- application and guest-workload monitoring;
- production deployment into customer environments;
- unsupported or undocumented telemetry collection;
- a guarantee of Azure Monitor parity for Hyper-V;
- renaming the GitHub repository or Azure DevOps project before dependency and release impacts are
  understood; and
- claiming Hyper-V Azure Monitor parity before the remaining supported telemetry gaps are closed.
