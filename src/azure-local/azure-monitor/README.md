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
