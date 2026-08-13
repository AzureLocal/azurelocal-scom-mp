# Azure Local Azure Monitor source

This directory owns every deployable and test artifact for Azure Local Azure Monitor Health Models.

```text
azure-monitor/
├── bicep/
│   ├── modules/
│   └── parameters/
├── kql/
│   └── signals/
├── scripts/
├── workbooks/
└── squaredup/         # Optional post-GA SquaredUp Cloud content
```

Azure Monitor artifacts may correlate with the Azure Local SCOM design, but they do not live in or
create a runtime dependency on the SCOM solution directory.

## Development status

The current preview-gated baseline includes:

- a Bicep deployment for the Azure Monitor account and Health Model;
- a deployment entity, six domain entities, a cluster Azure-resource entity, and relationships;
- system-assigned managed identity authentication;
- two evidence-backed Azure Local platform metric signal definitions;
- Lab and Standard development parameter files;
- research-only KQL queries that are not assigned until their target schemas are validated; and
- a starter investigation workbook.

Build and test from the repository root:

```powershell
& ./src/azure-local/azure-monitor/scripts/Test-AzureLocalHealthModel.ps1
```

The test compiles the Bicep source and enforces the solution boundary. Subscription deployment,
what-if, identity/RBAC, regional availability, signal evaluation, fault/recovery, cost, and teardown
remain lab gates.
