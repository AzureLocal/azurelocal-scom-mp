# azurelocal-scom-mp

[![Platform Standards](https://img.shields.io/badge/standards-AzureLocal%2Fplatform-0078D4)](https://github.com/AzureLocal/platform)

> Health monitoring for Azure Local — delivered two ways: a **SCOM Management Pack** and **Azure Monitor Health Models**.

This repo contains everything needed to monitor **Azure Local (HCI) clusters** at the health-model level, not just raw metric thresholds. It is organized into two parallel tracks that share the same conceptual health model and documentation platform.

---

## Tracks

| Track | What it is | Target audience |
|---|---|---|
| **1 — SCOM Management Pack** | Sealed `.mp` + unsealed `.xml` overrides for System Center Operations Manager. Monitors Azure Local clusters, nodes, storage pools, volumes, and VMs using unit/aggregate/dependency monitors and the classic SCOM health rollup tree. | Organizations running SCOM on-premises |
| **2 — Azure Monitor Health Models** | Service-group-backed health models in Azure Monitor (public preview). Entities, signals, relationships, and health propagation for the same Azure Local resources, surfaced natively in the Azure portal. | Azure-native / cloud-first operations teams |

**Companion tooling:** [SquaredUp DS](https://ds.squaredup.com) (on-prem SCOM dashboards) and [SquaredUp Cloud](https://squaredup.com) (SaaS — Azure + SCOM plugins) are evaluated as visualization layers on top of both tracks. See [PLAN.md](PLAN.md) for detail.

---

## Documentation

The `docs/` folder is a [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) site covering both tracks, including:

- Conceptual health model explanations with **draw.io** and **Mermaid** diagrams
- SCOM MP authoring guide and fragment reference
- Azure Monitor health model configuration walkthroughs
- Side-by-side SCOM ↔ Azure Monitor concept mapping
- Full [References](docs/references.md) page with every upstream source

---

## Repo Structure

```
azurelocal-scom-mp/
├── README.md
├── PLAN.md                          # Full implementation plan
├── REFERENCES.md                    # All reference links (raw)
├── STANDARDS.md                     # Points to AzureLocal/platform standards
├── CHANGELOG.md                     # Keep-a-Changelog / release-please
├── CODEOWNERS
├── .azurelocal-platform.yml         # Platform metadata (repoType: iac-solution)
├── .editorconfig                    # Canonical AzureLocal editor config
├── .gitignore
├── mkdocs.yml                       # MkDocs site config
│
├── docs/                            # MkDocs source
│   ├── index.md
│   ├── references.md
│   ├── scom-mp/
│   │   ├── index.md
│   │   ├── health-model.md
│   │   ├── monitors.md
│   │   ├── rules.md
│   │   ├── authoring.md
│   │   ├── overrides.md
│   │   ├── lifecycle.md
│   │   └── diagrams/
│   ├── azure-monitor/
│   │   ├── index.md
│   │   ├── concepts.md
│   │   ├── health-states.md
│   │   ├── service-groups.md
│   │   ├── alerts.md
│   │   ├── create.md
│   │   └── diagrams/
│   └── comparison/
│       ├── index.md
│       └── migration.md
│
├── src/
│   ├── scom-mp/                     # Management Pack XML source
│   │   ├── AzureLocal.SCOM.MP.xml
│   │   ├── AzureLocal.SCOM.MP.Overrides.xml
│   │   └── fragments/
│   └── azure-monitor/               # Azure Monitor artifacts
│       ├── arm-templates/
│       ├── kql/
│       └── workbooks/
│
└── diagrams/                        # Master diagram sources
    ├── drawio/
    └── mermaid/
```

---

## Quick Links

- [Implementation Plan](PLAN.md)
- [References](REFERENCES.md)
- [SCOM MP overview](docs/scom-mp/index.md)
- [Azure Monitor health models overview](docs/azure-monitor/index.md)
- [Concept comparison](docs/comparison/index.md)

---

## Status

> **Phase 0 — Research & Planning** complete (May 2026).  
> See [PLAN.md](PLAN.md) for the full phased delivery roadmap.

