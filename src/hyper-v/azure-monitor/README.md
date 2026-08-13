# Hyper-V Azure Monitor source

This is the reserved implementation boundary for the conditional Hyper-V Azure Monitor solution
through Arc-enabled SCVMM.

```text
azure-monitor/
├── bicep/
│   ├── modules/
│   └── parameters/
├── kql/
│   └── signals/
├── scripts/
├── workbooks/
└── squaredup/         # Optional SquaredUp Cloud content after a go decision
```

Do not add deployable templates, queries, workbooks, or dashboards until the research program provides
the evidence and ADR 0023 records a go decision. The directory exists now to make the platform-first,
solution-second repository contract complete and stable.
