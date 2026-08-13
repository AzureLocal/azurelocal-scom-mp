# Handoff

<!--
  Written at the END of every session by whichever tool was used.
  This is the single most important cross-tool file — the next session
  (possibly a different tool) starts by reading it.
-->

## Last session

- **What changed and why:** Activated Hyper-V Epic AB#7314, SCOM Feature AB#7317, and umbrella
  research Story AB#7327. Expanded phase one so an exhaustive technical inventory is kept separate
  from the smaller, opinionated default monitoring catalog.
- **Azure DevOps:** Created child research Tasks AB#7343–AB#7353 in the Hyper-V area. AB#7343–AB#7349
  cover support/topology, raw signal domains, and prior Microsoft MP research. AB#7350–AB#7351
  depend on those inventories and cover SCOM workflows and thresholds. AB#7352 depends on both
  engineering tasks and validates sources/faults in the lab. AB#7353 depends on lab validation and
  curates defaults. AB#7343 and AB#7348 now explicitly cover Network ATC, SCVMM/SDN, manual
  networking, and authority detection; comments were added to those Tasks and AB#7327.
- **Documentation:** Added `docs/hyper-v/monitoring-research.md` and
  `docs/hyper-v/monitoring-catalog.md`; updated VitePress navigation, roadmap, implementation plan,
  signal-catalog gate, Hyper-V pages, research-spike page, changelog, and source register.
- **Threshold decision:** Do not use 75% host memory utilization as a standalone default health
  trigger. Research must combine available/reserved host memory, Hyper-V memory pressure, paging,
  sustained duration, recovery, topology, and lab evidence.
- **Sources:** Initial source set includes current Microsoft Hyper-V performance/tuning,
  troubleshooting, Failover Cluster/CSV, SCOM, PowerShell, and Hyper-V MP documentation, plus
  current Veeam ONE Hyper-V alarms as secondary comparison evidence.
- **Network and prior-MP corrections:** Network ATC is the preferred baseline for eligible Windows
  Server 2025 Datacenter Hyper-V clusters unless SCVMM/SDN is the selected network authority. The
  Microsoft Hyper-V 2019 MP is research evidence only; the new MP will not import, extend,
  override, require, or take a runtime dependency on it.
- **Design navigation:** Reorganized design platform first, then delivery surface. Azure Local and
  Hyper-V each have explicit SCOM and Azure Monitor design lanes; Hyper-V Azure Monitor remains
  conditional. Added an ADR scope map so Azure Local ADRs are not silently applied to Hyper-V.
- **Documentation title:** The sidebar documentation layout renders the brand as two lines—Hybrid
  Infrastructure, then Health Monitoring—so it stays inside the title column and does not cover
  search. The landing-page header remains a single line.
- **Architecture:** Added accepted ADR 0025 for Hyper-V network-management authority. It preserves
  accepted ADR 0021 as an immutable historical record while superseding its Network ATC
  implication.
- **Independent SCOM products:** Accepted ADR 0022 with no shared Azure Local/Hyper-V sealed
  library, class, namespace, package, Distributed Application, release, or runtime dependency.
  Research and non-runtime engineering practices may still be reused.
- **Distributed Applications:** Added accepted ADR 0026 and dedicated Azure Local and Hyper-V DA
  design pages. Azure Local owns its deployment DA; Hyper-V owns a separate DA per supported
  failover cluster or standalone host. Both require dynamic membership, tested health propagation,
  operator views, reports, dashboards, and SLO targeting.
- **DA backlog:** Created AB#7354–AB#7357 for Azure Local and Hyper-V DA classes/membership and
  rollups/operator surfaces. Updated Features AB#7315 and AB#7317 plus AB#7319, AB#7320, AB#7321,
  AB#7327, AB#7328, AB#7329, AB#7343, and AB#7350 to enforce independent packaging and DA
  delivery/research requirements.
- **Validation:** VitePress production build passed and rendered both DA pages plus ADRs 0022 and
  0026. Markdownlint passed across all changed Markdown, `git diff --check` passed, and the
  changed-file secret scan found no matches. Governance validation found its global markdownlint
  and lychee executables unavailable; the repository-configured markdownlint and VitePress internal
  link/build checks ran successfully instead.
- **Branch:** `main`.
- **Next steps:** Run AB#7343 and the raw inventory Tasks AB#7344–AB#7349. Preserve raw enumeration
  output even when a signal is later rejected. Do not author AB#7328 or AB#7329 until AB#7353 and
  the successor Hyper-V scope/discovery/signal ADRs are approved.
- **Unrelated cleanup:** The superseded clone at `D:/git/azurelocal/azurelocal-scom-mp` remains until
  the prior Windows working-directory handle is released.
