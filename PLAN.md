# Implementation plan — Hybrid Infrastructure Health Monitoring

> Last updated: August 12, 2026
>
> Status: Platform split planned; research and architecture gates are next
> Published roadmap: <https://labs.hybridsolutions.cloud/hybrid-health-monitoring/project/roadmap>

## Objective

Deliver infrastructure health monitoring for **Hyper-V** and **Azure Local**, organized by
platform first and monitoring surface second:

| Platform | SCOM Management Pack | Azure Monitor Health Models |
|---|---|---|
| **Azure Local** | Committed | Committed |
| **Hyper-V** | Committed | Conditional future track through Azure Arc-enabled SCVMM |

The product shares health semantics and reusable engineering patterns across tracks. It does not
assume that platform topology, discoveries, signals, binaries, support matrices, or release cadence
are interchangeable.

## Product hierarchy

Azure DevOps is the delivery system of record:

```text
Epic AB#7313 — Deliver Azure Local health monitoring
├── Feature AB#7315 — Deliver the Azure Local SCOM Management Pack
│   ├── Story AB#7319 — Decide shared SCOM library and packaging boundaries
│   ├── Story AB#7320 — Author Azure Local SCOM classes and discoveries
│   ├── Story AB#7321 — Author Azure Local SCOM monitoring and overrides
│   └── Story AB#7322 — Validate, package, and document the release
└── Feature AB#7316 — Deliver Azure Monitor health models for Azure Local
    ├── Story AB#7323 — Validate APIs and signal contracts
    ├── Story AB#7324 — Author entities and signals
    ├── Story AB#7325 — Implement deployment, alerts, and workbooks
    └── Story AB#7326 — Validate and document the release

Epic AB#7314 — Deliver Hyper-V health monitoring
├── Feature AB#7317 — Deliver the Hyper-V SCOM Management Pack
│   ├── Story AB#7327 — Research and define the Hyper-V SCOM monitoring catalog
│   │   ├── Tasks AB#7343–AB#7349 — Scope, raw inventories, and incumbent MP gaps
│   │   ├── Tasks AB#7350–AB#7351 — SCOM workflow and threshold engineering
│   │   ├── Task AB#7352 — Lab and fault validation
│   │   └── Task AB#7353 — Curate the authoring-ready default catalog
│   ├── Story AB#7328 — Author Hyper-V SCOM classes and discoveries
│   ├── Story AB#7329 — Author Hyper-V SCOM monitoring and overrides
│   └── Story AB#7330 — Validate, package, and document the release
└── Feature AB#7318 — Evaluate Azure Monitor through Arc-enabled SCVMM
    ├── Story AB#7331 — Research inventory and guest management
    ├── Story AB#7332 — Prove telemetry and Health Models feasibility
    ├── Story AB#7333 — Decide go, defer, or no-go
    └── Story AB#7334 — Plan conditional implementation after a go decision
```

Parent-child and predecessor links in Azure DevOps enforce the research and implementation gates.

## Shared architecture

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

### Keep platform-specific

- entity and class inventory;
- discovery APIs and topology rules;
- signal sources, thresholds, and support evidence;
- product prerequisites and supported-version matrix;
- Azure resource and identity dependencies;
- artifacts and namespaces until ADR 0022 decides packaging; and
- release cadence where platform dependencies differ.

This distinction prevents a superficially convenient shared MP from creating incorrect discovery,
health rollup, upgrade, or support behavior.

## Architecture decision plan

| ADR | Status | Purpose | Gate |
|---|---|---|---|
| [0021](docs/design/decisions/0021-platform-and-delivery-track-architecture.md) | Accepted | Establish platform-first planning with separate delivery surfaces | Repository-owner decision |
| [0022](docs/design/decisions/0022-scom-management-pack-packaging-boundaries.md) | Proposed | Decide shared library versus separate platform MP dependencies | AB#7319 |
| [0023](docs/design/decisions/0023-hyper-v-azure-monitor-through-arc-enabled-scvmm.md) | Proposed | Decide whether the conditional Hyper-V Azure Monitor track proceeds | AB#7331 and AB#7332 |
| Hyper-V scope and topology | Planned after spike | Lock supported topology, entity inventory, exclusions, and version matrix | AB#7327 |
| Hyper-V SCOM discovery strategy | Planned after spike | Select supported discovery providers and hosting relationships | AB#7327 |
| Hyper-V signal and rollup policy | Planned after spike | Lock signal catalog, thresholds, defaults, and exceptions | AB#7327 |

Accepted ADRs 0001–0020 continue to govern the Azure Local baseline unless a successor ADR explicitly
supersedes one. They must not be silently generalized to Hyper-V.

## Research plan

All spikes follow the evidence contract in
[`docs/design/research-spikes.md`](docs/design/research-spikes.md).

### Spike A — SCOM packaging boundaries (AB#7319)

Deliver:

- class and relationship ownership matrix;
- dependency graphs for shared-library and separate-library options;
- import, upgrade, coexistence, and removal analysis;
- namespace, artifact, signing, and versioning recommendation; and
- updated ADR 0022.

### Spike B — Hyper-V SCOM monitoring catalog (AB#7327)

Deliver:

- Windows Server, Hyper-V, Failover Clustering, SCOM, and optional SCVMM support matrix;
- topology for standalone hosts, clusters, virtual switches, storage, replica, and VMs;
- supported PowerShell, CIM/WMI, event, service, and performance sources;
- lab fixtures and negative cases; and
- proposed scope, discovery, and signal ADRs.

AB#7327 is now an active umbrella Story with child research spikes AB#7343–AB#7353. The child work
first inventories everything observable, then maps acquisition and threshold behavior, validates it
in the lab, and finally classifies each candidate as Must monitor, Should monitor, Could monitor,
collect only, diagnostic, or excluded. The detailed contract is published in
[`docs/hyper-v/monitoring-research.md`](docs/hyper-v/monitoring-research.md).

### Spike C — Azure Local Health Models revalidation (AB#7323)

Deliver:

- current API versions and regional or preview limits;
- current Service Group, identity, RBAC, DCR, LAW/AMW, and Resource Graph contract;
- signal availability delta against the Azure Local catalog; and
- successor ADRs for any material change.

### Spike D — Arc-enabled SCVMM inventory and guest management (AB#7331)

Deliver:

- ARM resource map for SCVMM clouds, clusters, hosts, networks, and VMs;
- distinction between inventory projection and Arc-enabled Servers guest management;
- Arc Resource Bridge, agent, identity, RBAC, network, and version prerequisites; and
- repeatable lab onboarding and inventory evidence.

### Spike E — Hyper-V telemetry and Health Models feasibility (AB#7332)

Deliver:

- minimum viable Hyper-V entity graph;
- supported metric, log, Resource Graph, and Resource Health signals;
- AMA, DCR, LAW/AMW, Service Group, identity, and health-objective proof;
- fault-injection results;
- latency, cost, scale, lifecycle, and preview-risk assessment; and
- recommendation for ADR 0023.

## Delivery plan

### Azure Local SCOM Management Pack

1. Accept ADR 0022.
2. Author the approved library, relationships, and discoveries.
3. Author monitors, rules, rollups, views, and override tiers.
4. Validate with offline fixtures and a pre-production SCOM management group.
5. Seal, sign, version, package, document, and release.

### Azure Local Azure Monitor

1. Revalidate current APIs, limits, prerequisites, and signals.
2. Author Service Group membership, entities, relationships, health objectives, metrics, and KQL.
3. Implement Bicep modules, parameter tiers, alerts, action groups, DCR associations, and workbooks.
4. Validate lint, what-if, deployment, identity, fault propagation, scale, cost, and teardown.
5. Version, document, and release with preview limitations stated explicitly.

### Hyper-V SCOM Management Pack

1. Complete the topology/support spike and accept the resulting ADRs.
2. Accept ADR 0022.
3. Author approved classes, relationships, and discoveries for each supported topology variant.
4. Author monitors, rules, rollups, views, and override tiers using Hyper-V evidence.
5. Validate standalone, clustered, and approved SCVMM-managed configurations.
6. Seal, sign, version, package, document, and release independently or through the dependency
   structure selected by ADR 0022.

### Hyper-V Azure Monitor through Arc-enabled SCVMM

This work remains deferred. Only the two research spikes and go/no-go ADR are approved now.
Implementation starts only if ADR 0023 is accepted with a go decision. A go must identify exact
mandatory prerequisites and supported entity/signal coverage; it must not promise parity with SCOM
where supported Azure telemetry does not exist.

## Planned repository shape

The final source layout depends on ADR 0022. The intended separation is:

```text
docs/
├── design/                 # Shared principles, research, and ADRs
├── azure-local/            # Azure Local platform entry point
├── hyper-v/                # Hyper-V platform entry point
├── scom-mp/                # Existing Azure Local SCOM implementation docs
└── azure-monitor/          # Existing Azure Local Azure Monitor implementation docs

src/
├── shared/                 # Only if ADR 0022 approves shared source or artifacts
├── azure-local/
│   ├── scom-mp/
│   └── azure-monitor/
└── hyper-v/
    ├── scom-mp/
    └── azure-monitor/      # Created only after an ADR 0023 go decision
```

Moving current source placeholders into this shape is deferred until the packaging decision avoids
locking in the wrong dependency model.

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
