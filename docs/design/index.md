# Design

> The cross-cutting architectural foundation that governs **both** delivery tracks.

This section is *track-agnostic*. Everything here applies equally to the SCOM Management Pack
and the Azure Monitor Health Model — the two tracks are different *implementations* of the
same conceptual design.

If you're new to the project, read this section first, in order:

1. **[Scope & Topology](scope-topology.md)** — what we monitor and at what granularity. The
   3-layer, ~25-entity infrastructure model. Workloads are explicitly out of scope.
2. **[Health Model](health-model.md)** — how health is structured (dimensions, states, rollup
   policy, impact, suppression).
3. **[Signal Catalog](signal-catalog.md)** — the master list of every signal that drives a
   health state, with source, threshold, and parity across both tracks.
4. **[Customization](customization.md)** — how operators tune thresholds without forking the
   product. Sealed MP + override pack tiers (SCOM); Bicep params + tier files (Azure Monitor).
5. **[Concept Mapping (SCOM ↔ AzMon)](concept-mapping.md)** — side-by-side translation of every
   architectural concept across the two tracks. The dual-track Rosetta Stone.
6. **[Decisions (ADRs)](decisions/index.md)** — the ten Architecture Decision Records that
   lock down each of the choices above.

## Why a separate Design section?

Three failure modes this section prevents:

- **Track drift** — without a single source of truth for "what does healthy mean", the SCOM
  and Azure Monitor implementations would diverge over time. Every threshold and signal in
  this section has a single canonical name and value, mapped 1:1 across both tracks.
- **Buried decisions** — ADRs that live only in a `decisions/` folder on disk are invisible
  to readers who only see the rendered docs. Putting them in the navigation makes the
  reasoning behind every architectural choice discoverable.
- **Customization as a bolt-on** — treating customization as a documentation afterthought
  produces forked deployments. By making it a first-class design topic with cross-track
  parity guaranteed by [ADR 0007](decisions/0007-naming-convention.md) and
  [ADR 0008](decisions/0008-customization-strategy.md), customization becomes a *product
  feature*.

## Design principles

The choices in this section are guided by five principles:

1. **One model, two tracks** — the SCOM MP and Azure Monitor Health Model are different
   surfaces over the same underlying entity graph, signal catalog, and rollup policy.
2. **Infrastructure only** — workloads (VMs, AKS pods, applications) are deferred to
   companion MPs. See [ADR 0001](decisions/0001-scope-and-topology.md).
3. **Customization without forking** — every threshold and behavior is parameterized.
   Customers ship overrides, not rebuilt MPs.
4. **Cross-track parity is a hard requirement** — `Volume.FreeSpace.WarnPercent` (SCOM)
   and `volumeFreeSpaceWarningThresholdPct` (Azure Monitor) are guaranteed to mean the
   same thing. See [ADR 0007](decisions/0007-naming-convention.md).
5. **Cite first-party sources** — every signal, threshold, and prerequisite is traced back
   to Microsoft Learn, Azure Local product docs, or a named upstream reference. The
   [REFERENCES](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/REFERENCES.md)
   file is the bibliography.

## Status

| Layer | Phase 2 status |
|---|---|
| Scope & topology (ADR 0001) | Proposed — locks 3 layers, ~25 entities, infra-only |
| Health model (ADR 0003) | Proposed — worst-state rollup with documented exceptions |
| Signal catalog | Drafted — ~60 signals across 3 layers |
| Customization (ADR 0008) | Proposed — three tiers (Lab / Standard / Strict) |
| Cross-track parity (ADR 0007) | Proposed — naming convention locked |
| Decisions 0002–0010 | Proposed — see [Decisions index](decisions/index.md) |

When all ten ADRs move from **Proposed** to **Accepted** the project enters Phase 3 (SCOM
authoring) and Phase 4 (Azure Monitor authoring) in parallel.
