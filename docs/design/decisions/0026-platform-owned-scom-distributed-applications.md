# ADR 0026 — Platform-owned SCOM Distributed Applications

**Status:** Accepted

**Date:** 2026-08-13

**Decision owners:** Repository owner and maintainers

## Context

A SCOM service model needs an operator-facing root that answers whether a monitored platform
deployment is healthy. Unit monitors establish entity health, aggregate monitors organize health
dimensions, and dependency monitors propagate health across relationships. Without a Distributed
Application, that topology lacks a first-class service-level object for consolidated health views,
alerts, reports, dashboards, and service-level objectives.

Azure Local already defines `AzureLocal.Deployment` in ADR 0005, but that decision was buried in a
class-hierarchy ADR and was not visible in the platform SCOM design page. Hyper-V had no explicit
Distributed Application contract.

ADR 0022 establishes that the two SCOM products have no shared runtime Management Pack dependency.
Their Distributed Applications must follow the same boundary.

## Decision

Each SCOM product must ship a platform-owned Distributed Application authored in its own XML and
namespace:

- Azure Local owns the Azure Local deployment DA defined by ADR 0005 and the monitoring-pipeline
  branch defined by ADR 0018.
- Hyper-V owns a separate DA for each supported standalone-host or failover-cluster monitoring
  boundary. Its final classes, component relationships, and membership rules are locked by the
  Hyper-V topology and discovery ADRs produced from AB#7327.

The DAs do not reference one another. Component membership is populated from discovered stable
keys and typed relationships; customer use of the SCOM Distributed Application Designer is not a
runtime prerequisite. Aggregate and dependency monitors perform health propagation. The DA is the
service-level root and presentation/SLO target, not a substitute for entity monitoring.

Each product must deliver and test:

- its DA root class and component-group classes;
- dynamic membership and relationship discoveries;
- availability, configuration, performance, and security aggregate behavior where applicable;
- dependency monitor algorithms, Unknown behavior, and documented rollup exceptions;
- Health Explorer, diagram, state, alert, dashboard, report, and SLO targeting;
- upgrade-safe overrides for eligible rollup behavior; and
- clean import, population, state transition, upgrade, coexistence, and removal behavior.

## Consequences

- Operators receive a clear platform-level health object in both SCOM products.
- A failure in one product cannot change the other product's DA through a shared class or monitor.
- The Azure Local documentation must surface the accepted DA design already present in ADR 0005.
- Hyper-V research must determine correct per-cluster and per-standalone-host membership before MP
  authoring begins.
- A future combined-fleet DA requires a separately packaged optional integration MP.

## Alternatives considered

### Use only class views and Health Explorer

Rejected because operators would lack a service-level root for consolidated health, reporting,
dashboards, and SLO tracking.

### Share one DA class across Azure Local and Hyper-V

Rejected because it violates the independent runtime and support boundary in ADR 0022.

### Use one estate-wide DA in each platform MP

Rejected as the required default because one failed deployment would make unrelated deployments
appear unhealthy. Fleet aggregation can be an optional presentation or integration layer.

### Require operators to build DAs in the console

Rejected because manually maintained membership is nondeterministic and cannot provide a tested,
upgradeable product contract.

## Related work

- [Azure Local Distributed Application design](../azure-local/distributed-application.md)
- [Hyper-V Distributed Application design](../hyper-v/distributed-application.md)
- [ADR 0005](0005-scom-class-hierarchy.md)
- [ADR 0018](0018-self-observability.md)
- [ADR 0022](0022-scom-management-pack-packaging-boundaries.md)
- Hyper-V topology research
  [AB#7327](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7327)
- [Microsoft Distributed Applications guidance](https://learn.microsoft.com/en-us/system-center/scom/manage-using-authoring-workspace?view=sc-om-2025)
- [Microsoft SLO guidance](https://learn.microsoft.com/en-us/system-center/scom/manage-monitor-sla-overview?view=sc-om-2025)
