# Health State Flow — SCOM & Azure Monitor

> Source: `diagrams/mermaid/health-state-flow.md`
> Applies to both tracks: SCOM uses Green/Yellow/Red; Azure Monitor uses Healthy/Degraded/Unhealthy/Unknown.

```mermaid
stateDiagram-v2
    direction LR

    [*] --> Healthy : Model loaded\nno signals breached

    Healthy --> Degraded : Signal crosses\ndegraded threshold\n(SCOM: Warning)
    Healthy --> Unknown  : No data / agent down\n> 5 min

    Degraded --> Healthy   : All signals\nwithin healthy range
    Degraded --> Unhealthy : Signal crosses\ncritical threshold\nOR child entity Unhealthy\n(Impact = Standard)

    Unhealthy --> Degraded : Critical condition\npartially clears
    Unhealthy --> Healthy  : All conditions cleared

    Unknown --> Healthy : Data resumes

    note right of Healthy
      SCOM: Green
      Azure Monitor: Healthy
    end note

    note right of Degraded
      SCOM: Yellow (Warning)
      Azure Monitor: Degraded
    end note

    note right of Unhealthy
      SCOM: Red (Critical)
      Azure Monitor: Unhealthy
    end note

    note right of Unknown
      SCOM: Grey (Unmonitored)
      Azure Monitor: Unknown
    end note
```

## Impact settings (Azure Monitor)

| Impact | Behaviour |
|---|---|
| **Standard** | Child entity health propagates to parent — worst state wins |
| **Limited** | Child entity health shown but does NOT roll up to parent |
| **Suppressed** | Child entity health completely excluded from rollup (e.g. intentionally stopped VMs) |
