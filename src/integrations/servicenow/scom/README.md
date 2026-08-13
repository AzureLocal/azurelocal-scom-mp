# SCOM to ServiceNow integration source

This optional package provides public, secret-free configuration contracts for the ServiceNow SCOM
Events connector. It does not modify ServiceNow, install a MID Server, redistribute Microsoft SCOM
assemblies, or store credentials.

```text
scom/
├── config/       # Connector development profiles
├── mappings/     # Normalized event/alert mapping contract
└── scripts/      # Offline validation
```

Validate from the repository root:

```powershell
& ./src/integrations/servicenow/scom/scripts/Test-ScomServiceNowIntegration.ps1
```

See the public [integration guide](../../../../docs/integrations/scom-servicenow.md).
