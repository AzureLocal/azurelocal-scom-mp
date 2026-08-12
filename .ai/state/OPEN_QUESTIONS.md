# Open questions

<!-- Unresolved questions or deferred decisions for the next session or tool to pick up. -->

- Remove the superseded clone at `D:/git/azurelocal/azurelocal-scom-mp` after the current process
  releases its Windows working-directory handle.
- Which Windows Server, SCOM, Failover Cluster, and optional SCVMM versions and topology fixtures
  form the first-release support matrix? Resolve in AB#7343.
- Should the product depend on, extend, override, replace, or coexist independently with the
  Microsoft Hyper-V 2019, Windows Server, and Failover Cluster MPs? Resolve in AB#7349 and ADR 0022.
- Which candidate thresholds are safe defaults after duration, recovery, dependency, and lab
  evidence are included? Resolve in AB#7351 and AB#7352.
