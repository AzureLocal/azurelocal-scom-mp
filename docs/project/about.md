---
title: About
description: About the Azure Local SCOM MP & Health Models project.
---

# About

`azurelocal-scom-mp` is a community project under the [AzureLocal](https://github.com/AzureLocal)
GitHub organization that delivers production-grade health monitoring for **Azure Local (HCI)** infrastructure
in two parallel tracks:

| Track | Format | Purpose |
|---|---|---|
| **SCOM Management Pack** | Sealed `.mp` + override `.xml` | Classic SCOM authoring — unit/aggregate/dependency/Distributed Application rollup |
| **Azure Monitor Health Models** | ARM/Bicep + Service Group | Native cloud-side health propagation using Azure Monitor's preview Health Models feature |

Both tracks share the same conceptual health model — they monitor the same components, agree on
what "healthy" means, and propagate health the same way. They differ only in implementation surface.

## Project Goals

1. **Cover the full Azure Local infrastructure footprint** — the on-prem cluster *plus* every Azure-side resource
   that the deployment provisions (managed identity, Key Vault, Storage Account, Custom Location, Arc-enabled
   servers, Resource Bridge, etc.). See the [Roadmap](roadmap.md) for the complete entity inventory.
2. **Ship parity across SCOM and Azure Monitor** — every signal that exists in one track has an equivalent
   in the other. Customers migrating from SCOM to Azure Monitor see the same health story.
3. **Customizable without forking** — every threshold, alert severity, and behavior is parameterized.
   Customers ship their own override pack (SCOM) or `*.bicepparam` file (Azure Monitor) and customizations
   survive upgrades. See [Customization](../design/customization.md).
4. **Document the health model first**, the implementation second — the design (this site) is the
   product; the XML and Bicep are downstream artifacts.
5. **Conform to the [AzureLocal/platform](https://github.com/AzureLocal/platform) standards** — same docs
   stack, same CI workflows, same release tooling as the rest of the org.

## Scope

**In scope (Phase 1–6):**

- Azure Local cluster, nodes, storage pool, volumes, network ATC / network intent
- Cluster-resident platform services: Arc Resource Bridge, MOC, AKS Arc *platform*
- Azure-side resources deployed by Azure Local: HCI cluster resource, Arc-enabled servers,
  Custom Locations, Managed Identities, Service Principals, Key Vault, Storage Account,
  storage containers, logical networks, Update Manager

**Out of scope (Phase 1–6) — but on the [Roadmap](roadmap.md) as future MPs:**

- Workloads running on Azure Local (VMs, AKS Arc *pods/containers*, application-level monitoring)
- These would be future Management Packs that take a *dependency* on this infrastructure health
  model — e.g. "VM workload X is impacted because the cluster is unhealthy."

## Project Structure

```text
azurelocal-scom-mp/
├── decisions/        # ADRs (architectural decision records) for the health model design
├── diagrams/         # Mermaid + draw.io source diagrams
├── docs/             # MkDocs Material site (this site)
├── src/              # SCOM MP authoring (VSAE) + Azure Monitor ARM/Bicep + KQL
├── PLAN.md           # Full implementation roadmap
├── REFERENCES.md     # Annotated link library (~100 references)
└── STANDARDS.md      # Pointer to AzureLocal/platform standards
```

## Maintainers

See [`CODEOWNERS`](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/CODEOWNERS).

## License

[MIT](license.md). See the [LICENSE](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/LICENSE)
file at the repo root.
