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
├── scripts/
├── tests/
└── squaredup/         # Optional post-GA Dashboard Server content
```

The folders mirror proposed ADR 0027. Their presence does not accept that ADR or authorize XML
authoring. AB#7327 and AB#7359 must validate the architecture and resolve ADRs 0027–0029 first.

No Azure Local or Microsoft Hyper-V 2019 Management Pack runtime element or reference belongs here.
