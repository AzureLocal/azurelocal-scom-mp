# ADR 0028 — Hyper-V object and discovery architecture

**Status:** Proposed

**Date:** 2026-08-13

**Decision owners:** Repository owner and maintainers

## Context

Hyper-V objects have different lifecycle and placement behavior. Host-local adapters and switches
belong to one computer, while VMs and clustered roles can move between nodes. Incorrect hosting or
keys can delete and recreate objects during migration, lose health continuity, misplace workflows,
and break DA membership. Discovery must also avoid repeated expensive provider queries and must not
interpret access denied or timeout as object absence.

## Proposed decision

Use staged discovery beginning with a cheap Hyper-V role seed, followed by role/version, topology
classification, selected network authority, approved child entities, relationships/DA membership,
and monitoring-freshness stages.

Key mobile objects within the stable failover-cluster or standalone-host deployment boundary.
Specifically, key VMs by Hyper-V VM GUID and represent current host placement with a reference
relationship, not a hosting relationship. Host only objects that truly cease to exist with one host.
Prefer native event, service, performance, registry, and CIM providers; use PowerShell when it is
the best supported authoritative topology source. Use shared module types and proven cookdown for
expensive multi-instance acquisition.

Exact classes, base classes, keys, discovery providers, execution locations, schedules, and script
runtime remain provisional until the topology, workflow, and lab research confirms them.

## Options considered

### Stable boundary identity with staged discovery

| Dimension | Assessment |
|---|---|
| VM migration | Preserves object identity and history |
| Workflow placement | Explicit by class and relationship |
| Discovery cost | Supports staged targeting and cookdown |
| Complexity | Requires careful relationship reconciliation |

### Host every object under its current node

| Dimension | Assessment |
|---|---|
| VM migration | Recreates identity when placement changes |
| Workflow placement | Simple local execution |
| Discovery cost | Repeated per-host topology work |
| Complexity | Appears simple but creates lifecycle defects |

### Management-server-only remote discovery

| Dimension | Assessment |
|---|---|
| VM migration | Can maintain stable identity |
| Workflow placement | Centralized remote credential and availability dependency |
| Discovery cost | Management-server fan-out and scale risk |
| Complexity | High security and control-plane coupling |

## Trade-off analysis

Stable boundary identity requires more relationship design but is the only option that preserves VM
health and customization through migration. Agent-local acquisition is preferred for local signals;
cluster-wide or management-plane workflows use a proven centralized execution point only where the
provider requires one.

## Consequences

- VM placement is modeled separately from VM identity.
- Every discovery needs explicit stale, error, deletion, and reconciliation behavior.
- Access denied or malformed data raises monitoring-pipeline health and does not delete topology.
- High-cardinality child classes require scale evidence before default discovery.
- The PowerShell runtime question must be resolved without violating the governed script standard.

## Acceptance gates

1. Topology research proves stable source identifiers and topology behavior.
2. Workflow research maps every approved candidate to a target, module, execution point, and cookdown group.
3. Lab validation proves rename, move, drain, failover, access-denied, stale, and recovery behavior.
4. Maximum-scale discovery converges within the approved budget.

## Related design

- [Class and relationship model](../hyper-v/class-and-relationship-model.md)
- [Discovery and workflow architecture](../hyper-v/discovery-and-workflow-architecture.md)
- [ADR 0025 — Hyper-V network-management authority](0025-hyper-v-network-management-authority.md)
