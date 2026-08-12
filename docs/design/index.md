# Design

> The cross-cutting architectural foundation for the Azure Local and Hyper-V platform tracks.

This section contains shared health-model rules plus the existing Azure Local design baseline.
Shared rules apply across platforms; Azure Local-specific topology and signals do not become
Hyper-V requirements merely because both products use SCOM.

If you're new to the project, read this section first, in order:

1. **[Scope & Topology](scope-topology.md)** — the completed three-layer Azure Local baseline and
   the research gate for the Hyper-V topology.
2. **[Health Model](health-model.md)** — how health is structured (dimensions, states, rollup
   policy, impact, suppression).
3. **[Signal Catalog](signal-catalog.md)** — the Azure Local signal baseline plus the naming and
   evidence contract future Hyper-V signals must follow.
4. **[Customization](customization.md)** — how operators tune thresholds without forking the
   product. Sealed MP + override pack tiers (SCOM); Bicep params + tier files (Azure Monitor).
5. **[Concept Mapping (SCOM ↔ AzMon)](concept-mapping.md)** — delivery-surface translation for
   the Azure Local baseline and future supported platform mappings.
6. **[Research Spikes](research-spikes.md)** — evidence required before packaging, Hyper-V scope,
   and the conditional Arc-enabled SCVMM track can be decided.
7. **[Decisions (ADRs)](decisions/index.md)** — accepted decisions and proposed delivery gates.

## Why a separate Design section?

Three failure modes this section prevents:

- **Track drift** — without shared health semantics, platform and delivery implementations would
  diverge. Equivalent signals use stable logical names, while unsupported parity is documented
  instead of fabricated.
- **Buried decisions** — ADRs that live only in a `decisions/` folder on disk are invisible
  to readers who only see the rendered docs. Putting them in the navigation makes the
  reasoning behind every architectural choice discoverable.
- **Customization as a bolt-on** — treating customization as a documentation afterthought
  produces forked deployments. By making it a first-class design topic with equivalent-signal
  semantics governed by [ADR 0007](decisions/0007-naming-convention.md) and
  [ADR 0008](decisions/0008-customization-strategy.md), customization becomes a *product
  feature*.

## Design principles

The choices in this section are guided by five principles:

1. **Platform first, delivery surface second** — Azure Local and Hyper-V own separate topology and
   support contracts; SCOM and Azure Monitor are delivery surfaces within those platforms.
2. **Share semantics, prove implementation parity** — reuse health and authoring patterns, but
   require evidence before claiming that topology or signals map 1:1.
3. **Customization without forking** — every threshold and behavior is parameterized.
   Customers ship overrides, not rebuilt MPs.
4. **Equivalent signals preserve meaning** — when a platform supports a signal on both surfaces,
   `Volume.FreeSpace.WarnPercent` and its Azure Monitor parameter retain the same semantics.
5. **Cite first-party sources** — every signal, threshold, and prerequisite is traced back
   to Microsoft Learn, Azure Local product docs, or a named upstream reference. The
   [REFERENCES](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/REFERENCES.md)
   file is the bibliography.

## Status

| Layer | Phase 2 status |
|---|---|
| Azure Local scope & topology (ADR 0001) | Accepted — locks 3 layers, ~25 entities, infra-only |
| Health model (ADR 0003) | Accepted — worst-state rollup with documented exceptions |
| Signal catalog | Complete — ~60 signals across 3 layers |
| Customization (ADR 0008) | Accepted — three tiers (Lab / Standard / Strict) |
| Cross-track parity (ADR 0007) | Accepted — naming convention locked |
| Platform split (ADR 0021) | Accepted — Azure Local and Hyper-V Epics with surface Features |
| SCOM packaging (ADR 0022) | Proposed — gated by AB#7319 |
| Hyper-V Azure Monitor (ADR 0023) | Proposed — gated by AB#7331 and AB#7332 |

The Azure Local baseline is complete. Shared packaging, Hyper-V topology, and Arc-enabled SCVMM
feasibility research are the next gates; product authoring has not started.
