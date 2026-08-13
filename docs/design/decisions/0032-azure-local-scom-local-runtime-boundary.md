# ADR 0032 — Azure Local SCOM local runtime boundary

- **Status**: Accepted
- **Date**: 2026-08-13
- **Deciders**: Hybrid Solutions Cloud maintainers

## Context

The original Azure Local model combined on-cluster state with Azure Resource Manager checks. That
describes the whole product, but it creates a poor core SCOM dependency: a local infrastructure
monitor should continue to discover and evaluate the deployment when Azure identity, networking,
or the Azure control plane is unavailable.

Azure Local already exposes authoritative local interfaces for cluster state, Storage Spaces
Direct Health Service faults, storage inventory, Network ATC, solution updates, registration, and
platform services. SCOM agents can execute those interfaces in the monitored-node context without
an interactive sign-in or a customer secret in the Management Pack.

## Decision

The sealed Azure Local SCOM core is a **local-runtime product**.

- Role seed and topology discovery run on SCOM-managed Azure Local nodes.
- Local workflows use Failover Clustering, Storage, Health Service, Network ATC,
  Get-AzureStackHCI, solution-update cmdlets, service state, events, and performance counters.
- The core never calls Connect-AzAccount, stores a cloud credential, or requires an ARM token.
- Azure resource configuration and Resource Health are owned by the independent Azure Monitor
  health-model solution.
- A future optional SCOM Azure Extension MP may run credentialed ARM probes from a management-server
  resource pool. The local core cannot depend on that extension.
- Monitoring-pipeline failure is explicit health; missing data never becomes an implicit Healthy.

This decision supersedes the SCOM-runtime portions of ADRs 0001, 0002, and 0011 that made Azure-side
objects part of the core local MP. Their whole-deployment concepts remain valid for the Azure Monitor
solution.

## Consequences

- Local monitoring remains useful during Azure disconnection and identity failure.
- Secrets and interactive authentication are removed from node workflows.
- SCOM and Azure Monitor can correlate by stable deployment identity without sharing runtime files.
- Azure-side checks do not appear in the core DA until an optional extension exists and is healthy.
- Lab certification must prove each embedded provider script in the target SCOM and Azure Local
  version matrix.

## References

- [Azure Local Health Service faults](https://learn.microsoft.com/en-us/azure/azure-local/manage/health-service-faults)
- [Cluster performance history](https://learn.microsoft.com/en-us/azure/azure-local/manage/health-service-cluster-performance-history)
- [Get-NetIntentStatus](https://learn.microsoft.com/en-us/powershell/module/networkatc/get-netintentstatus)
- [Azure Local update phases](https://learn.microsoft.com/en-us/azure/azure-local/update/update-phases-23h2)
