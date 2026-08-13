# Hyper-V SCOM Management Pack source

This directory owns every runtime and test artifact for the independent Hyper-V SCOM product and
its platform-owned Distributed Application.

```text
scom-mp/
├── fragments/
│   ├── library/
│   ├── discovery/
│   ├── monitoring/
│   ├── presentation/
│   └── reporting/
├── templates/
│   └── overrides/     # Lab, Standard, and Strict profiles and structural examples
├── scripts/
├── tests/
└── squaredup/         # Optional post-GA Dashboard Server content
```

The folders implement ADR 0027. The functional development build contains 13 classes, 20
relationships, staged role/topology discovery, a platform-owned Distributed Application, nine
health monitors, ten dependency rollups, twelve performance rules, four event-alert rules, one
read-only diagnostic task, and ten operator views. The Microsoft SDK and SCOM lab gates remain
separate from source completeness.

The release keeps product-authored sealed artifacts separate from customer-owned unsealed
overrides. Discovery and Monitoring receive independent generated override MPs for each optional
tuning profile. The generated files are intentionally unsealed and become customer-owned.

No Azure Local or Microsoft Hyper-V 2019 Management Pack runtime element or reference belongs here.

## Development build

Run the contract tests with PowerShell 7:

```powershell
./tools/Test-HyperVManagementPacks.ps1
```

Generate development XML with a non-secret public key token from the approved test-signing
identity:

```powershell
./tools/Build-HyperVManagementPacks.ps1 `
    -Version '0.1.0.0' `
    -PublicKeyToken '<16-hex-character-public-token>'
```

The build inventory always marks this output as development-only. The script does not claim SDK
verification, sealing, signing, or lab import. Those gates require the approved SCOM build and lab
environment defined by accepted ADR 0031.

## Generate customer-owned overrides

Generate one profile into separate Discovery and Monitoring override MPs:

```powershell
./tools/New-HyperVOverrideManagementPacks.ps1 `
    -TuningProfile Standard `
    -OrganizationId Contoso `
    -OrganizationName 'Contoso' `
    -Version '0.1.0.0' `
    -PublicKeyToken '<16-hex-character-public-token>' `
    -OutputPath './out/contoso-overrides'
```

Review and test the generated XML before import. Never import more than one starter profile and
never store active overrides in the Default Management Pack.

## Microsoft SDK verification

After exporting the official sealed dependency MPs from the target SCOM release, run:

```powershell
./tools/Test-HyperVManagementPacksWithSdk.ps1 `
    -InputPath './out/development' `
    -DependencyPath 'D:/scom/reference-mps'
```

The command fails on missing dependencies as well as schema and verification errors. SDK success
does not replace test sealing, clean lab import, fault/recovery tests, upgrade/removal tests, or
release signing.
