# ADR 0034 — Azure Local object, discovery, and Distributed Application architecture

- **Status**: Accepted
- **Date**: 2026-08-13
- **Deciders**: Hybrid Solutions Cloud maintainers

## Context

Azure Local needs stable cluster identity, useful storage diagnostics, predictable multi-node
discovery, and a deployment-level service view. The original coarse model intentionally omitted
physical-disk classes, but a comprehensive operator product needs drive identity and location for
Health Service remediation without making every drive a separate pager.

## Decision

The first development model has 17 classes and 28 typed relationships.

- NodeRole is hosted by its SCOM-managed Windows computer.
- Deployment is unhosted and keyed by the failover-cluster identifier.
- Storage pools, volumes, physical disks, and solution updates are unhosted and keyed by deployment
  plus their stable product identifier.
- Network ATC, Arc integration, resource-bridge presence, and pipeline instances are node-hosted.
- Cluster-scoped objects use identical keys when contributed by multiple nodes so SCOM reconciles
  them as one logical topology.
- Physical disks are first-class inventory and Health Explorer objects, but individual disk state
  is state-only by default; Health Service root-cause faults own default paging.
- Two staged discoveries separate inexpensive role detection from full topology.
- HybridSolutionsCloud.AzureLocal.Service derives from the Service Designer service class and
  owns Compute, Storage, Network, Azure Integration, Lifecycle, and Monitoring Pipeline components.
- Membership is discovered from typed relationships. Customers do not hand-maintain the DA.

This decision supersedes the Azure Local class and physical-disk granularity portions of ADRs 0001,
0004, and 0005. It refines ADRs 0018 and 0026.

## Consequences

- Drive faults retain serial number and physical-location context.
- VM and guest workload monitoring remains out of scope.
- Multi-node contribution, stale-object grooming, and failover behavior require SCOM lab evidence.
- A future cloud extension can attach Azure-side health without changing the local class keys.

## References

- [Operations Manager Distributed Applications](https://learn.microsoft.com/en-us/system-center/scom/manage-using-authoring-workspace?view=sc-om-2025)
- [Azure Local Health Service faults](https://learn.microsoft.com/en-us/azure/azure-local/manage/health-service-faults)
