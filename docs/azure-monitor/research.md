---
title: Azure Local Azure Monitor research
description: Current Health Models APIs, Azure Local signal evidence, constraints, and remaining validation spikes.
---

# Azure Local Azure Monitor research

Research was revalidated on August 13, 2026 against current Microsoft documentation. Azure Monitor
Health Models remains a preview service. The current resource graph uses
`Microsoft.Monitor/accounts/healthmodels` and child resources at API `2025-05-03-preview`.

## Confirmed platform contract

| Area | Evidence | Design result |
|---|---|---|
| Health model | Root entity, Azure-resource and generic entities, relationships, health states, signals, and state alerts | Use a domain hierarchy with worst-of dependencies |
| IaC | Health model, authentication setting, entity, relationship, discovery-rule, and signal-definition resources | Bicep is the source of truth |
| Identity | Managed identity authentication settings are supported | Use system-assigned identity; grant least privilege outside the template when source scopes vary |
| Signals | Azure resource metrics, Log Analytics queries, Prometheus queries, Resource Health, and external health reports are product concepts | Enable only sources proven in the target environment |
| Azure Local metrics | More than 60 documented compute, storage, network, VM, VHD, and GPU metrics from the telemetry extension | Start with low-cardinality cluster signals; keep high-cardinality series out of default health |
| Collection | Health Models evaluates existing telemetry and does not collect it | Prerequisite checks must fail before deployment when telemetry is absent |

## Initial signal curation

| Signal | Source | Initial use | Rationale |
|---|---|---|---|
| Percentage CPU | Azure Local platform metric | Health signal, parameterized thresholds | Documented, low-cardinality when evaluated at cluster scope; duration and threshold need lab tuning |
| Cluster node Storage Degraded | Azure Local platform metric | Health signal, parameterized thresholds | Directly describes failed or missing drives; validate unit and aggregation behavior in the lab |
| Network throughput/RDMA | Azure Local platform metrics | Workbook only | Workload-dependent; no universal health threshold |
| Volume/drive/VHD latency | Azure Local platform metrics | Workbook first | Requires per-hardware and per-workload baselines |
| VM metrics | Azure Local platform metrics | Excluded from infrastructure health v1 | Guest/workload scope and high cardinality |
| Health Service faults | Local PowerShell today | Future Log Analytics or external-health-report spike | Do not invent a cloud table or unsupported ingestion path |
| Registration, update, Network ATC | Local APIs today | Future evidence spike | Add only after a supported Azure signal is demonstrated |
| Telemetry freshness | Azure Monitor data source | Required before release | A stale model must become Unknown or unhealthy, not remain silently green |

The initial thresholds are development defaults, not universal best practices. CPU health must use
sustained evaluation; memory health should prefer available memory and pressure rather than a single
percentage-used value; capacity, latency, and failure thresholds must reflect redundancy and
recovery time.

## Remaining spikes

1. Enumerate the live metric definitions for representative Azure Local releases and capture the
   exact namespace, names, dimensions, units, and aggregation behavior.
2. Inventory Log Analytics tables and schemas created by Insights, AMA/DCR, and Telemetry and
   Diagnostics; save repeatable schema queries and negative results.
3. Validate Health Models supported regions, provider registration, identity token acquisition,
   RBAC, cross-subscription resource access, and Service Group discovery.
4. Inject compute, storage, network, registration, lifecycle, and telemetry-pipeline faults and
   record signal latency, state, alert, recovery, and Unknown behavior.
5. Measure evaluation, alert, Log Analytics ingestion/query, workbook, and retention costs at
   small, medium, and large deployment sizes.
6. Raise successor ADRs for any material API or signal-model changes.

## Primary references

- [Health models overview](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/overview)
- [Health model concepts](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/concepts)
- [Health Model signals](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/signals)
- [Microsoft.Monitor Health Model resource types](https://learn.microsoft.com/en-us/azure/templates/microsoft.monitor/allversions)
- [Azure Local monitoring overview](https://learn.microsoft.com/en-us/azure/azure-local/concepts/monitoring-overview)
- [Azure Local platform metrics](https://learn.microsoft.com/en-us/azure/azure-local/manage/monitor-cluster-with-metrics)
