# Azure Local SCOM Management Pack source

This directory owns every runtime and test artifact for the independent Azure Local SCOM product.
It is a functional development baseline: the source builds, passes offline contract tests and
VSAE/SDK verification against the installed SCOM 2022 dependencies, and completes ordered
transient test sealing. It is not governed-release-signed or certified in a SCOM management group.

```text
scom-mp/
├── build/                 # Artifact manifest
├── fragments/
│   ├── library/           # Classes, relationships, and DA component model
│   ├── discovery/         # Role qualification and topology discovery
│   ├── monitoring/        # Health, alerts, performance, events, and diagnostics
│   ├── presentation/      # Operator folders and views
│   └── reporting/         # Optional reporting surface
├── templates/             # Lab, Standard, and Strict tuning starters
├── tools/                 # Deterministic build, validation, and override generation
└── squaredup/         # Optional post-GA Dashboard Server content
```

The sealed product and customer override contract remains governed by the accepted Azure Local
ADRs. No Hyper-V runtime element or reference belongs here.

## Build and validate

Run these commands from the repository root with PowerShell 7 or later:

```powershell
& ./src/azure-local/scom-mp/tools/Test-AzureLocalManagementPacks.ps1
Invoke-Pester ./tests/unit/AzureLocalManagementPack.Build.Tests.ps1
```

The contract test builds five development artifacts under `artifacts/azure-local/scom-mp/` and
checks their XML, identities, public localization, topology, workflows, views, and independent
product boundary. The Pester suite exercises the same public build contract as a test runner.

Microsoft SDK verification additionally requires System Center VSAE for Visual Studio 2022 and the
official sealed SCOM dependency MPs. The PowerShell 7 wrapper delegates verification to Visual
Studio 2022's full-framework MSBuild host:

```powershell
& ./src/azure-local/scom-mp/tools/Test-AzureLocalManagementPacksWithSdk.ps1 `
    -InputPath './src/azure-local/scom-mp/out/development' `
    -DependencyPath <path-to-exported-sealed-scom-mps>
```

The verifier currently passes for all five projects against the installed SCOM 2022 dependency
set. Verify and seal the Library first, then use the sealed Library while verifying Discovery and
the remaining product MPs in dependency order.

Transient test sealing is also proven. Governed release sealing/signing, clean import, discovery,
fault/recovery, scale, upgrade, coexistence, and removal gates must pass before a release is
described as production-ready.

## Customer overrides

Generate separate unsealed Discovery and Monitoring override MPs with one of the provisional
starter profiles:

```powershell
& ./src/azure-local/scom-mp/tools/New-AzureLocalOverrideManagementPacks.ps1 `
    -Profile Standard `
    -OutputPath ./artifacts/azure-local/scom-mp/overrides
```

Customers retain ownership of active overrides. Never store overrides in the Default Management
Pack. See the public [administration guide](../../../docs/scom-mp/management-pack-guide.md) for the
complete import, tuning, upgrade, and removal workflow.
