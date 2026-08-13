# ADR 0036 — Azure Local Azure Monitor Health Model v1

- **Status**: Accepted
- **Date**: 2026-08-13
- **Deciders**: Hybrid Solutions Cloud maintainers

## Context

Azure Monitor Health Models is a preview service with an infrastructure-as-code surface under
`Microsoft.Monitor/accounts`. Azure Local exposes documented platform metrics, Resource Health,
Insights data, and Log Analytics data, but a Health Model does not collect any of those signals.
It only evaluates telemetry that is already available and authorized.

The cloud solution must remain independent from the Azure Local SCOM Management Pack. It also must
not treat undocumented Log Analytics tables or guessed metric names as a supported product contract.

## Decision

The first Azure Local Azure Monitor development baseline will:

- deploy an Azure Monitor account and Health Model with API `2025-05-03-preview`;
- use a system-assigned managed identity and a named authentication setting;
- model one deployment with Compute, Storage, Network, Azure Integration, Lifecycle, and Monitoring
  Pipeline components beneath the Health Model root;
- represent the Azure Local cluster ARM resource as a child entity;
- begin with documented Azure Local platform-metric definitions for Percentage CPU and degraded
  storage count;
- use worst-of dependency propagation and health-state alerts only at the deployment entity;
- keep thresholds and alert action groups parameterized; and
- ship KQL and workbook assets separately from the Health Model resource graph.

Additional signals require observed metric-definition or table-schema evidence. Resource Health,
Logs, Service Group discovery, regional support, RBAC, fault behavior, and cost are deployment and
lab gates rather than inferred capabilities.

This decision refines ADRs 0006, 0010, 0012, and 0013 for the current preview API.

## Consequences

- The baseline can be compiled and reviewed without a customer subscription.
- Deployment requires a supported Health Models region and provider registration.
- The generated model is intentionally useful but incomplete until the Azure Local lab validates
  signal availability and adds evidence-backed definitions.
- Preview API changes can require a breaking source update before GA.
- SCOM and Azure Monitor may use comparable domain names, but they do not share runtime state.

## References

- [Health models in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/overview)
- [Health Model concepts](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/concepts)
- [Health Model Bicep resource types](https://learn.microsoft.com/en-us/azure/templates/microsoft.monitor/allversions)
- [Azure Local platform metrics](https://learn.microsoft.com/en-us/azure/azure-local/manage/monitor-cluster-with-metrics)
