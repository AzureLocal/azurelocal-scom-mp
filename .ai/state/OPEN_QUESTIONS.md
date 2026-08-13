# Open questions

<!-- Unresolved questions or deferred decisions for the next session or tool to pick up. -->

- Remove the superseded clone at `D:/git/azurelocal/azurelocal-scom-mp` after the current process
  releases its Windows working-directory handle.
- Which Windows Server, SCOM, Failover Cluster, and optional SCVMM versions and topology fixtures
  form the first-release support matrix, including Network ATC eligibility and SCVMM/SDN-managed
  alternatives? Resolve in AB#7343 and AB#7348.
- Which candidate thresholds are safe defaults after duration, recovery, dependency, and lab
  evidence are included? Resolve in AB#7351 and AB#7352.
- What final `HybridSolutionsCloud.HyperV` namespace, sealed artifact set, Microsoft library
  dependencies/versions, reporting package, language strategy, and signing identities should ADR
  0027 accept? Resolve through AB#7319, AB#7327, and AB#7359.
- Which exact base classes, stable keys, workflow execution points, cookdown groups, and supported
  PowerShell execution runtime should ADR 0028 accept? Resolve through AB#7343–AB#7352 and AB#7359.
- Which VM expected-state policy, population/redundancy rollups, stale-data impact, threshold bands,
  alert severity mapping, and scale budgets should ADR 0029 accept? Resolve through AB#7351–AB#7353,
  AB#7357, and AB#7359.
