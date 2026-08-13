# Azure Local SCOM Management Pack source

This directory owns every runtime and test artifact for the independent Azure Local SCOM product.

```text
scom-mp/
├── fragments/
│   ├── library/       # Classes, relationships, discoveries, and reusable model elements
│   └── monitoring/    # Monitors, rules, views, tasks, and DA behavior
├── tests/             # Offline and Management Pack contract tests
└── squaredup/         # Optional post-GA Dashboard Server content
```

The sealed product and customer override contract remains governed by the accepted Azure Local
ADRs. No Hyper-V runtime element or reference belongs here.
