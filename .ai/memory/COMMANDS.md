# Commands

```powershell
Set-Location docs
npm ci
npm run docs:dev
npm run docs:build
npm run docs:preview -- --host 127.0.0.1 --port 4173
```

The local site URL includes the configured base path:
`http://127.0.0.1:4173/hybrid-health-monitoring/`.

Hyper-V SCOM MP development checks:

```powershell
pwsh -NoProfile -File src/hyper-v/scom-mp/tools/Build-HyperVManagementPacks.ps1 `
  -PublicKeyToken 0123456789abcdef
pwsh -NoProfile -File src/hyper-v/scom-mp/tools/Test-HyperVManagementPacks.ps1
Invoke-Pester -Path tests/unit/HyperVManagementPack.Build.Tests.ps1 -CI
pwsh -NoProfile -File src/hyper-v/scom-mp/tools/New-HyperVOverrideManagementPacks.ps1 `
  -TuningProfile Standard -OrganizationId Contoso -OrganizationName Contoso `
  -Version 0.1.0.0 -PublicKeyToken 0123456789abcdef
pwsh -NoProfile -File src/hyper-v/scom-mp/tools/Test-HyperVManagementPacksWithSdk.ps1 `
  -InputPath src/hyper-v/scom-mp/out/development `
  -DependencyPath 'C:/Program Files (x86)/System Center Visual Studio 2022 Authoring Extensions/References/OM2022'
```

Development build output is written under `src/hyper-v/scom-mp/out/` and remains untracked.

Azure Local SCOM MP development checks:

```powershell
pwsh -NoProfile -File src/azure-local/scom-mp/tools/Test-AzureLocalManagementPacks.ps1
Invoke-Pester -Path tests/unit/AzureLocalManagementPack.Build.Tests.ps1 -CI
pwsh -NoProfile -File src/azure-local/scom-mp/tools/Test-AzureLocalManagementPacksWithSdk.ps1 `
  -InputPath src/azure-local/scom-mp/out/development `
  -DependencyPath 'C:/Program Files (x86)/System Center Visual Studio 2022 Authoring Extensions/References/OM2022'
```

Azure Monitor and integration contract checks:

```powershell
pwsh -NoProfile -File src/azure-local/azure-monitor/scripts/Test-AzureLocalHealthModel.ps1
pwsh -NoProfile -File src/hyper-v/azure-monitor/scripts/Test-HyperVHealthModel.ps1
pwsh -NoProfile -File src/integrations/servicenow/scom/scripts/Test-ScomServiceNowIntegration.ps1
```
