# Hybrid Infrastructure Health Monitoring

[![HCS Standards](https://img.shields.io/badge/standards-HCS-0078D4)](https://platform.hybridsolutions.cloud/standards/)

> SCOM and Azure Monitor health models for **Hyper-V and Azure Local**.

This repository defines infrastructure health as an entity model with signals, state, rollup,
alerts, customization, and lifecycle—not merely a list of metric thresholds.

## Platform tracks

| Platform | SCOM Management Pack | Azure Monitor Health Models |
|---|---|---|
| **Azure Local** | Committed | Committed |
| **Hyper-V** | Committed | Conditional future track through Azure Arc-enabled SCVMM |

The platforms share SCOM authoring patterns and health semantics where appropriate. Their topology,
discoveries, signals, prerequisites, support matrices, and release boundaries remain explicit.

## Prerequisites

To preview or contribute to the documentation, install:

- Git;
- Node.js 20; and
- PowerShell 7 or later.

Product implementation prerequisites will be documented per platform and delivery surface after
the current research and architecture gates complete.

## Documentation

The `docs/` folder is a [VitePress](https://vitepress.dev/) site published at
<https://labs.hybridsolutions.cloud/hybrid-health-monitoring/>. It includes:

- separate [Azure Local](docs/azure-local/index.md) and [Hyper-V](docs/hyper-v/index.md) entry points;
- the shared health-model design, signal catalog, and Architecture Decision Records;
- Azure Local SCOM and Azure Monitor implementation guidance;
- the planned Hyper-V SCOM Management Pack;
- the research-gated Hyper-V Azure Monitor path through Arc-enabled SCVMM; and
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

- Azure Local monitoring — Epic AB#7313
  - Azure Local SCOM Management Pack — Feature AB#7315
  - Azure Local Azure Monitor Health Models — Feature AB#7316
- Hyper-V monitoring — Epic AB#7314
  - Hyper-V SCOM Management Pack — Feature AB#7317
  - Hyper-V Azure Monitor through Arc-enabled SCVMM — conditional Feature AB#7318

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
│   └── hyper-v/             # Hyper-V SCOM and reserved Azure Monitor solutions
├── PLAN.md                  # Executable delivery plan
├── REFERENCES.md            # Annotated source library
└── STANDARDS.md             # Governance pointers
```

The [source tree](src/README.md) is platform first and solution second. Azure Local and Hyper-V each
own separate `scom-mp/` and `azure-monitor/` roots. Accepted
[ADR 0030](docs/design/decisions/0030-platform-first-source-tree.md) defines the layout; accepted
ADR 0022 prohibits shared SCOM runtime elements.

## Current status

- The Azure Local design baseline and VitePress site are complete.
- The platform-first roadmap and Azure DevOps hierarchy are established.
- Hyper-V MP/DA architecture validation, monitoring research, and Arc-enabled SCVMM feasibility are
  the next research gates.
- Product authoring has not started.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for authoring, testing, signing, and documentation guidance.

## License

Licensed under the [MIT License](LICENSE).
