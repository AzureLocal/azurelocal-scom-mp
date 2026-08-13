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
│   └── overrides/     # Future Lab, Standard, and Strict public examples
├── scripts/
├── tests/
└── squaredup/         # Optional post-GA Dashboard Server content
```

The folders mirror proposed ADR 0027. Foundation authoring is active: manifests, dependency
contracts, override examples, and static tests can be built before workflow evidence closes.
Classes, discoveries, monitors, rules, Distributed Application elements, thresholds, and enabled
profiles remain gated by the research program and ADRs 0027–0029.

The future release will keep product-authored sealed artifacts separate from customer-owned
unsealed overrides. Discovery and Monitoring receive independent override starter files for each
optional tuning profile. No active customer override or importable example is committed until the
workflow IDs, defaults, safe ranges, profile manifests, and lifecycle tests are accepted.

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
environment defined by proposed ADR 0031.
