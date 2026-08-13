# ADR 0022 — Independent SCOM Management Pack packaging

**Status:** Accepted

**Date:** 2026-08-13

**Decision owners:** Repository owner and maintainers

## Context

Azure Local and Hyper-V use SCOM, but they have different support contracts, topology, discovery,
signals, thresholds, Distributed Applications, and release risks. A shared sealed library would
create a permanent import, version, signing, upgrade, removal, and support dependency between two
products that must be independently installable and maintainable.

Research and engineering practices can be reused without putting shared runtime elements into a
customer management group.

## Decision

Package Azure Local and Hyper-V as completely independent SCOM Management Pack products. Neither
product may import, extend, override, or require an MP shipped by the other product. They must own
separate namespaces, sealed libraries, monitoring packs, presentation content, override guidance,
Distributed Applications, signing identities, packages, versions, and support lifecycles.

Source research, authoring knowledge, non-runtime templates, build automation, validation tooling,
and test methodology may be reused. Reuse must not introduce a compiled or sealed runtime
dependency between the products.

If a combined estate view is required later, implement it as a third optional integration MP that
explicitly references both products. Neither platform MP will depend on that integration MP.

## Consequences

- Azure Local and Hyper-V can be installed, upgraded, removed, and supported independently.
- Both products can coexist in one SCOM management group without sharing public classes or sealed
  dependencies.
- Each platform owns its complete class, relationship, discovery, monitor, rule, view, override,
  and Distributed Application contract.
- Similar runtime XML may exist in both products; avoiding cross-product coupling is more important
  than eliminating that duplication.
- Packaging validation confirms independent artifact names, reference graphs, signing, coexistence, upgrade,
  and removal behavior instead of choosing a shared-library option.

## Alternatives considered

### Shared sealed base library

Rejected because it couples release, import, upgrade, signing, and removal behavior across products.

### Hyper-V base library extended by Azure Local

Rejected because Azure Local is not an extension of the Hyper-V monitoring product and must not
inherit its support contract or type hierarchy.

### Source-generated shared runtime elements

Rejected as a product boundary because identical generated elements can still create namespace,
identity, ownership, and servicing ambiguity. Non-runtime templates and automation remain allowed.

## Related work

- Packaging contract validation
- [ADR 0021](0021-platform-and-delivery-track-architecture.md)
- [ADR 0026](0026-platform-owned-scom-distributed-applications.md)
