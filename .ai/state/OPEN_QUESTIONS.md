# Open questions

<!-- Unresolved questions or deferred decisions for the next session or tool to pick up. -->

- Remove the superseded clone at `D:/git/azurelocal/azurelocal-scom-mp` after the current process
  releases its Windows working-directory handle.
- Which Windows Server, SCOM, Failover Cluster, and optional SCVMM versions and topology fixtures
  form the first-release support matrix, including Network ATC eligibility and SCVMM/SDN-managed
  alternatives? Resolve in the research program.
- Which candidate thresholds are safe defaults after duration, recovery, dependency, and lab
  evidence are included? Resolve in the research program.
- Which exact official sealed dependency-MP versions should the first release support? Export them
  from each target SCOM release and run `Test-HyperVManagementPacksWithSdk.ps1`.
- Does the target SCOM HealthService and supported Windows Server matrix execute every embedded
  PowerShell provider workflow consistently, including Hyper-V, FailoverClusters, and Network ATC
  modules? Prove in the standalone and clustered labs.
- Do stable VM identity, multi-node topology contributions, DA population/rollup, maintenance,
  migration/failover, recovery, upgrade, and removal behave as designed in SCOM?
- What release signing identity and governed sealing pipeline will produce the first signed bundle?
