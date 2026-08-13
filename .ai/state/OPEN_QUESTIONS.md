# Open questions

<!-- Unresolved questions or deferred decisions for the next session or tool to pick up. -->

- Remove the superseded clone at `D:/git/azurelocal/azurelocal-scom-mp` after the current process
  releases its Windows working-directory handle.
- Which Windows Server, SCOM, Failover Cluster, and optional SCVMM versions and topology fixtures
  form the first-release support matrix, including Network ATC eligibility and SCVMM/SDN-managed
  alternatives? Resolve in the research program.
- Which candidate thresholds are safe defaults after duration, recovery, dependency, and lab
  evidence are included? Resolve in the research program.
- Beyond the verified SCOM 2022 dependency set, which exact sealed dependency-MP versions should
  the first release support? Export them from each additional target SCOM release and run
  `Test-HyperVManagementPacksWithSdk.ps1`.
- Does the target SCOM HealthService and supported Windows Server matrix execute every embedded
  PowerShell provider workflow consistently, including Hyper-V, FailoverClusters, and Network ATC
  modules? Prove in the standalone and clustered labs.
- Do stable VM identity, multi-node topology contributions, DA population/rollup, maintenance,
  migration/failover, recovery, upgrade, and removal behave as designed in SCOM?
- What release signing identity and governed sealing pipeline will produce the first signed bundle?
- Beyond the verified SCOM 2022 dependency set, which official sealed dependency-MP versions should
  the first Azure Local release support, and does the suite pass VSAE verification against each?
- In the representative Azure subscription, do the preview Health Model resources deploy with the
  documented Azure Local metrics, identities, dimensions, and state transitions used by the Bicep
  baselines?
- For Hyper-V Azure Monitor, which supported SCVMM/Arc/AMA matrix supplies enough inventory and
  telemetry coverage, and how will DCR associations be governed at scale?
- Which ServiceNow release and SCOM version pair will be used for the connector lab, and will
  ServiceNow confirm SCOM 2025 support before that pair is claimed?
- Should the ServiceNow SCOM Metrics connector remain disabled permanently, or is there a licensed
  Metric Intelligence use case that justifies separate data-warehouse access and validation?
