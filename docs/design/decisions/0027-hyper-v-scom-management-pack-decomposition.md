# ADR 0027 — Hyper-V SCOM Management Pack decomposition

**Status:** Accepted

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

## Decision

Use the working namespace `HybridSolutionsCloud.HyperV` and decompose the product into sealed
Library, Discovery, Monitoring, and Presentation MPs, with Reporting as an optional sealed artifact.
Customers store changes in two organization-owned unsealed MPs: Discovery Overrides for the sealed
Discovery MP and Monitoring Overrides for the sealed Monitoring MP. The release may bundle sealed
artifacts in an `.mpb`, but their logical dependency direction remains:

`approved Microsoft libraries → Library → Discovery/Monitoring → Presentation/Reporting → corresponding customer overrides`.

The release can provide Lab, Standard, and Strict tuning templates as public examples. They are not
signed product dependencies or automatically imported policy. Customers review and copy selected
settings into their own unsealed override MPs, which remain customer-owned for their full lifecycle.
No product or customer setting is stored in the Default Management Pack.

Release-specific Microsoft dependency versions, Reporting packaging, language resources, and
signing identities remain open until the packaging and dependency research provides evidence.

## Options considered

### Modular sealed suite

| Dimension | Assessment |
|---|---|
| Compatibility | Stable Library contract isolates model changes |
| Servicing | Monitoring and presentation can evolve without redefining classes |
| Complexity | Moderate dependency and packaging overhead |
| Customer customization | Separate unsealed Discovery and Monitoring override boundaries |

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
- Discovery and Monitoring overrides remain separate, writable, customer-owned, and outside the
  signed product artifacts.
- Optional tuning templates require customer review and never become hidden active policy.
- The Default Management Pack is prohibited for product customization.

## Acceptance gates

1. Packaging validation confirms artifact names, reference graph, signing, coexistence, and lifecycle behavior.
2. Dependency research identifies required Microsoft library dependencies and versions.
3. A pre-production import proves the proposed graph and independent Discovery/Monitoring override
   lifecycle.
4. Override contract tests validate documented parameters, targeting, template manifests, upgrade,
   removal, and the prohibition on the Default Management Pack.
5. The repository owner accepts the final namespace and artifact set.

## Related design

- [Management Pack structure](../hyper-v/management-pack-structure.md)
- [Override and tuning architecture](../hyper-v/override-and-tuning-architecture.md)
- [ADR 0022 — Independent SCOM Management Pack packaging](0022-scom-management-pack-packaging-boundaries.md)
- [ADR 0031 — Hyper-V Management Pack authoring toolchain](0031-hyper-v-mp-authoring-toolchain.md)
