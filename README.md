# Hybrid Infrastructure Health Monitoring

[![HCS Standards](https://img.shields.io/badge/standards-HCS-0078D4)](https://platform.hybridsolutions.cloud/standards/)

> SCOM and Azure Monitor health models for **Hyper-V and Azure Local**.

This repository defines infrastructure health as an entity model with signals, state, rollup,
alerts, customization, and lifecycle—not merely a list of metric thresholds.

## Platform tracks

| Platform | SCOM Management Pack | Azure Monitor Health Models |
|---|---|---|
| **Azure Local** | Committed | Committed |
| **Hyper-V** | Committed | Constrained development through Azure Arc-enabled SCVMM and Arc-enabled Servers |

The platforms share SCOM authoring patterns and health semantics where appropriate. Their topology,
discoveries, signals, prerequisites, support matrices, and release boundaries remain explicit.

## Prerequisites

To preview or contribute to the documentation, install:

- Git;
- Node.js 20; and
- PowerShell 7 or later.

Product implementation prerequisites are documented per platform and delivery surface. A functional
development baseline is not a production release until its platform-specific certification gates
pass.

## Documentation

The `docs/` folder is a [VitePress](https://vitepress.dev/) site published at
<https://labs.hybridsolutions.cloud/hybrid-health-monitoring/>. It includes:

- separate [Azure Local](docs/azure-local/index.md) and [Hyper-V](docs/hyper-v/index.md) entry points;
- the shared health-model design, signal catalog, and Architecture Decision Records;
- Azure Local SCOM and Azure Monitor implementation guidance;
- the implemented Hyper-V SCOM Management Pack development baseline;
- the constrained Hyper-V Azure Monitor path through Arc-enabled SCVMM and Arc-enabled hosts; and
- an Azure DevOps-backed [roadmap](docs/project/roadmap.md) and [implementation plan](PLAN.md).

Preview the site locally:

```powershell
Set-Location docs
npm ci
npm run docs:dev
```

The configured local URL includes the repository base path:
`http://localhost:5173/hybrid-health-monitoring/`.

## Delivery hierarchy

- Azure Local monitoring
  - Azure Local SCOM Management Pack
  - Azure Local Azure Monitor Health Models
- Hyper-V monitoring
  - Hyper-V SCOM Management Pack
  - Hyper-V Azure Monitor through Arc-enabled SCVMM — conditional

Research and implementation Stories are linked in [PLAN.md](PLAN.md).

## Repository structure

```text
hybrid-health-monitoring/
├── docs/                    # VitePress content and configuration
│   ├── azure-local/         # Azure Local platform entry point
│   ├── hyper-v/             # Hyper-V platform and conditional Arc track
│   ├── design/              # Shared design, spikes, and ADRs
│   ├── scom-mp/             # Azure Local SCOM implementation docs
│   └── azure-monitor/       # Azure Local Azure Monitor docs
├── diagrams/drawio/         # Editable diagram sources
├── src/                     # Platform-first product source
│   ├── azure-local/         # Azure Local SCOM and Azure Monitor solutions
│   ├── hyper-v/             # Hyper-V SCOM and constrained Azure Monitor solutions
│   └── integrations/        # Optional connector-owned profiles, mappings, and validation
├── PLAN.md                  # Executable delivery plan
├── REFERENCES.md            # Annotated source library
└── STANDARDS.md             # Governance pointers
```

The [source tree](src/README.md) is platform first and solution second. Azure Local and Hyper-V each
own separate `scom-mp/` and `azure-monitor/` roots. Accepted
[ADR 0030](docs/design/decisions/0030-platform-first-source-tree.md) defines the layout; accepted
ADR 0022 prohibits shared SCOM runtime elements.

## Current status

- The Azure Local SCOM design, research catalog, deterministic source build, DA, monitoring,
  presentation, reporting, and customer override baseline are implemented.
- The platform-first roadmap and Azure DevOps hierarchy are established.
- The independent Hyper-V SCOM functional development baseline is also implemented.
- Both five-project SCOM suites pass Microsoft VSAE/SDK verification against the installed SCOM
  2022 dependencies and complete ordered test sealing with a transient development key. Governed
  release signing, clean lab import, runtime, fault/recovery, scale, upgrade, coexistence, and
  removal certification remain before release.
- Independent Azure Local and constrained Hyper-V Azure Monitor Health Model development baselines
  compile with Bicep; live API, identity, telemetry, fault, cost, and teardown evidence remains.
- The optional SCOM-to-ServiceNow integration uses ServiceNow's existing SCOM Events connector. It
  has separate product allow-list profiles, a mapping contract, administration guidance, and
  passing offline validation; Windows MID Server configuration and live connector proof remain.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for authoring, testing, signing, and documentation guidance.

## License

Licensed under the [MIT License](LICENSE).
