---
title: Roadmap
description: Phased delivery roadmap and future enhancements.
---

# Roadmap

## Current Phase Status

| Phase | Status | Description |
|---|---|---|
| Phase 0 — Research & Planning | ✅ Complete | Health model concepts, references, scope |
| Phase 1 — Documentation Scaffold | ✅ Complete | MkDocs site, platform compliance, diagram stubs, GitHub Pages live |
| Phase 2 — Health Model Design | 🚧 In progress | ADRs, full infra entity inventory, customization strategy, completed diagrams |
| Phase 3 — Track 1: SCOM MP Authoring | ⬜ Not started | VSAE project, classes, discoveries, monitors, rules, overrides |
| Phase 4 — Track 2: Azure Monitor Health Model | ⬜ Not started | Service Group, entities, signals, ARM/Bicep export, KQL |
| Phase 5 — Migration Guidance | ⬜ Not started | SCOM → Azure Monitor migration tool walkthrough |
| Phase 6 — Documentation Polish & Release | ⬜ Not started | v1.0.0 release |

The full task-level checklist lives in [`PLAN.md`](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/PLAN.md).

## Future Enhancements (post v1.0.0)

The first six phases focus exclusively on **Azure Local infrastructure**. Workloads
running on Azure Local are intentionally deferred — they belong in companion MPs
that **take a dependency on this health model**.

### Workload-monitoring companion MPs

Future Management Packs would consume this infrastructure health model so that workload
health correctly reflects underlying platform health. Some candidates:

| Companion MP | What it monitors | Why it depends on this MP |
|---|---|---|
| **azurelocal-vm-workload-mp** | Guest OS, application services, VM-level perf inside HCI VMs | If the underlying volume or storage pool is degraded, VM workload health should reflect that — not just "VM is up." |
| **azurelocal-aks-workload-mp** | AKS Arc pods, deployments, persistent volume claims, ingress | A pod reporting "Running" is meaningless if the cluster's NetATC intent is unhealthy or a node is offline. |
| **azurelocal-sqlmi-mp** | SQL Managed Instance Arc on Azure Local | Database health rolls up to platform health — if the storage pool is rebalancing, IO latency expectations change. |
| **azurelocal-avd-mp** | Azure Virtual Desktop session hosts running on Azure Local | Session host health depends on cluster + storage + network health beneath it. |

The pattern in every case: the workload MP defines its own classes/entities and signals,
**but its top-level Distributed Application or root entity references the corresponding
infrastructure entity from this MP** so health propagates upward correctly.

### Other future enhancements

- **Multi-cluster federation** — health rollup across multiple Azure Local clusters into a single dashboard
- **DCMA / Default Cluster Monitoring Agent integration** — surface the existing in-box telemetry through the same health model
- **Azure Monitor Workbook gallery** — pre-built workbooks for common operational views (capacity, replication lag, Arc connectivity)
- **SCOM 2025 modern authoring** — migrate the MP authoring surface to the new SCOM 2025 templates if/when they land
- **OpenTelemetry signal source** — accept OTel-emitted infrastructure metrics as an alternative signal source
- **Customer-facing audit pack** — an extension that produces compliance/audit reports based on health history

## How to suggest a roadmap addition

[Open a discussion or issue](https://github.com/AzureLocal/azurelocal-scom-mp/issues/new/choose)
on the GitHub repo. Roadmap items that align with the [project goals](about.md#project-goals)
get prioritized.
