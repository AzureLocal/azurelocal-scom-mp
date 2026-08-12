---
title: About
description: About the Hybrid Infrastructure Health Monitoring project.
---

# About

`azurelocal-scom-mp` is a community project under the
[AzureLocal](https://github.com/AzureLocal) organization. It delivers production-grade health
monitoring for **Hyper-V and Azure Local** through SCOM and, where supported, Azure Monitor.

The repository name reflects its original Azure Local scope. The public product title is
**Hybrid Infrastructure Health Monitoring**. Renaming the repository or ADO project is deferred
until SCOM packaging and release dependencies are understood.

## Product structure

| Platform | Delivery surface | Status |
|---|---|---|
| Azure Local | SCOM Management Pack | Committed |
| Azure Local | Azure Monitor Health Models | Committed |
| Hyper-V | SCOM Management Pack | Committed |
| Hyper-V | Azure Monitor through Arc-enabled SCVMM | Conditional roadmap item; research gate |

## Project goals

1. **Model platform health, not just alerts.** Define entity topology, signals, states, rollup,
   alerting, customization, and monitoring-pipeline health.
2. **Keep platform support honest.** Reuse stable patterns without claiming Hyper-V and Azure Local
   expose identical topology or telemetry.
3. **Customize without forking.** Provide upgrade-safe SCOM overrides and parameterized Azure
   Monitor deployments.
4. **Validate before promising parity.** Use research spikes, ADRs, lab evidence, and deterministic
   tests to decide supported scope.
5. **Publish decisions and delivery status.** Keep the web documentation, Azure DevOps hierarchy,
   roadmap, and implementation plan aligned.

## Shared foundation

The two platforms share health dimensions, state semantics, rollup principles, naming patterns,
SCOM authoring conventions, test strategy, and documentation structure. Platform-specific entity
inventories, discoveries, signals, thresholds, prerequisites, and support matrices stay separate.

Whether the two SCOM products share a sealed library or only source-level patterns is deliberately
unresolved. Proposed [ADR 0022](../design/decisions/0022-scom-management-pack-packaging-boundaries.md)
owns that decision.

## Scope

### Azure Local

- physical cluster, nodes, storage, networking, and lifecycle;
- cluster-resident Azure Local platform services;
- related Azure resources and monitoring dependencies; and
- SCOM and Azure Monitor delivery surfaces.

### Hyper-V

- standalone and failover-clustered Hyper-V topology approved by research;
- optional SCVMM management context where supported; and
- a SCOM Management Pack as the committed delivery surface.

Azure Monitor for Hyper-V is considered only for Arc-enabled SCVMM environments and remains
conditional on [ADR 0023](../design/decisions/0023-hyper-v-azure-monitor-through-arc-enabled-scvmm.md).

### Out of scope

- guest application monitoring;
- AKS pod or application monitoring;
- production deployment into customer environments; and
- unsupported or undocumented telemetry dependencies.

Future companion products can depend on the appropriate platform health model.

## Maintainers

See [`CODEOWNERS`](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/CODEOWNERS).

## License

[MIT](license.md). See the
[LICENSE](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/LICENSE) file.
