# ADR 0027 — Hyper-V SCOM Management Pack decomposition

**Status:** Proposed

**Date:** 2026-08-13

**Decision owners:** Repository owner and maintainers

## Context

The Hyper-V SCOM product needs stable public model elements while discovery, monitoring,
presentation, and reporting evolve at different rates. A single monolithic MP is simple to import
but couples every change to the same artifact and makes model compatibility harder to review. Too
many small MPs create excessive dependencies and servicing overhead.

ADR 0022 already requires an independent Hyper-V runtime product with no dependency on Azure Local
or the Microsoft Hyper-V 2019 MP. Microsoft guidance recommends logically grouping custom elements,
sealing reusable MPs, and storing customer overrides separately.

## Proposed decision

Use the working namespace `HybridSolutionsCloud.HyperV` and decompose the product into sealed
Library, Discovery, Monitoring, and Presentation MPs, with Reporting as an optional sealed artifact.
Customers store changes in their own unsealed `HybridSolutionsCloud.HyperV.Overrides` MP. The
release may bundle sealed artifacts in an `.mpb`, but their logical dependency direction remains:

`approved Microsoft libraries → Library → Discovery/Monitoring → Presentation/Reporting → customer overrides`.

The final namespace, exact Microsoft dependencies, Reporting packaging, language resources, and
signing identities remain open until AB#7319 and AB#7327 provide validation evidence.

## Options considered

### Modular sealed suite

| Dimension | Assessment |
|---|---|
| Compatibility | Stable Library contract isolates model changes |
| Servicing | Monitoring and presentation can evolve without redefining classes |
| Complexity | Moderate dependency and packaging overhead |
| Customer customization | Clear unsealed override boundary |

### One monolithic sealed MP

| Dimension | Assessment |
|---|---|
| Compatibility | Every change touches the same public artifact |
| Servicing | Simple import but broad regression surface |
| Complexity | Low package count |
| Customer customization | Still requires a separate override MP |

### Many feature-specific MPs

| Dimension | Assessment |
|---|---|
| Compatibility | Fine-grained but large public reference graph |
| Servicing | Independent feature changes possible |
| Complexity | High import, dependency, testing, and documentation cost |
| Customer customization | Fragmented targeting and override ownership |

## Trade-off analysis

The modular suite adds packaging work but provides a more stable class/relationship contract and a
clear release graph. A monolith is attractive for an early prototype but increases long-term model
risk. Feature-specific MPs are not justified until independently optional capabilities have a real
support or release boundary.

## Consequences

- The Library becomes the most compatibility-sensitive artifact.
- Build and release automation must validate the complete reference graph.
- Every release must test clean import order, upgrade, customer overrides, removal order, and
  side-by-side coexistence.
- Reporting can remain optional without changing core monitoring.
- Customer overrides remain writable and outside the signed product artifacts.

## Acceptance gates

1. AB#7319 validates artifact names, reference graph, signing, coexistence, and lifecycle behavior.
2. AB#7327 identifies required Microsoft library dependencies and versions.
3. A pre-production import proves the proposed graph.
4. The repository owner accepts the final namespace and artifact set.

## Related design

- [Management Pack structure](../hyper-v/management-pack-structure.md)
- [ADR 0022 — Independent SCOM Management Pack packaging](0022-scom-management-pack-packaging-boundaries.md)
