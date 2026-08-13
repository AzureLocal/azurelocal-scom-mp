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
  -DependencyPath D:/scom/reference-mps
```

Development build output is written under `src/hyper-v/scom-mp/out/` and remains untracked.
