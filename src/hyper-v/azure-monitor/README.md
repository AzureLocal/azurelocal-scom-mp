# Hyper-V Azure Monitor source

This is the implementation boundary for the constrained Hyper-V Azure Monitor development solution
through Arc-enabled SCVMM and Arc-enabled Servers.

```text
azure-monitor/
├── bicep/
│   ├── modules/
│   └── parameters/
├── kql/
│   └── signals/
├── scripts/
├── workbooks/
└── squaredup/         # Optional SquaredUp Cloud content after a go decision
```

ADR 0023 now records a constrained go. The initial baseline creates an independent Health Model,
Windows data collection rule, SCVMM management entity, Arc-enabled Hyper-V host entities, heartbeat,
CPU, cluster-event, and telemetry-coverage signals, state alerts, and a starter workbook.

This is not SCOM parity. Arc-enabled SCVMM inventory does not expose a complete Hyper-V host,
cluster, storage, or network health model. Participating hosts require Arc-enabled Server, AMA, and
an explicit association to the emitted DCR.

Build and validate:

```powershell
& ./src/hyper-v/azure-monitor/scripts/Test-HyperVHealthModel.ps1
```

Subscription what-if/deployment, DCR association, live table schemas, fault/recovery, RBAC, cost,
scale, and teardown remain release gates.
