# ADR 0021 — Platform and delivery-track architecture

**Status:** Accepted  
**Date:** 2026-08-12  
**Decision owners:** Repository owner and maintainers

## Context

The original project described Azure Local through two implementation tracks: SCOM and Azure
Monitor. The product now needs to cover both Azure Local and Windows Server Hyper-V without
collapsing their different topologies and support contracts into a single ambiguous track.

Hyper-V and Azure Local share substantial SCOM architecture, but Azure Local adds platform-specific
storage, Network ATC, lifecycle, registration, Arc, and Azure-resource dependencies. Hyper-V also
needs to represent standalone hosts, general-purpose failover clusters, optional SCVMM management,
and environments with no Azure dependency.

## Decision

Organize planning and documentation by **platform first**, then by **delivery surface**:

1. **Azure Local monitoring**
   - Azure Local SCOM Management Pack — committed.
   - Azure Local Azure Monitor Health Models — committed.
2. **Hyper-V monitoring**
   - Hyper-V SCOM Management Pack — committed.
   - Hyper-V Azure Monitor through Arc-enabled SCVMM — conditional future roadmap item.

The two platform tracks share a conceptual health-model foundation: health dimensions, state
semantics, rollup principles, naming rules, customization goals, tests, and authoring patterns.
They do not automatically share classes, discoveries, signal implementations, binaries, release
cadence, or support matrices.

Azure DevOps represents the decision with one Epic per platform and one Feature per delivery
surface. Research, implementation, validation, packaging, and documentation are child Stories.

## Consequences

- Readers can enter through an Azure Local or Hyper-V platform page and see only applicable work.
- Azure Local design remains valid for that platform; it is no longer presented as the complete
  topology for every product in the repository.
- Hyper-V starts with a research-backed topology and signal catalog instead of cloning Azure Local.
- Shared SCOM packaging is unresolved and must be decided by ADR 0022.
- Hyper-V Azure Monitor implementation cannot begin until ADR 0023 is accepted with a go decision.
- The existing repository and ADO project names remain unchanged for continuity. A future rename
  can be evaluated after artifact boundaries and release implications are known.

## Alternatives considered

### Keep SCOM and Azure Monitor as the top-level tracks

Rejected because it hides important platform differences and makes Hyper-V appear to inherit Azure
Local signals and prerequisites.

### Create four unrelated products

Rejected because it would duplicate the shared SCOM and health-model foundation and encourage
semantic drift.

### Make Hyper-V Azure Monitor committed immediately

Rejected for now because Arc-enabled SCVMM inventory, guest management, telemetry, Health Models
fit, preview constraints, cost, and supportability still require lab evidence.

## Related work

- Azure Local Epic [AB#7313](https://dev.azure.com/hybridcloudsolutions/Azure%20Local%20SCOM%20MP/_workitems/edit/7313)
- Hyper-V Epic [AB#7314](https://dev.azure.com/hybridcloudsolutions/Azure%20Local%20SCOM%20MP/_workitems/edit/7314)
- [Research spikes](../research-spikes.md)
