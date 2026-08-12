# Handoff

<!--
  Written at the END of every session by whichever tool was used.
  This is the single most important cross-tool file — the next session
  (possibly a different tool) starts by reading it.
-->

## Last session

- **What changed and why:** Renamed the product and repository identity for the cross-platform
  Azure Local and Hyper-V scope. Accepted ADR 0024. The canonical GitHub repository is now
  `Hybrid-Solutions-Cloud/hybrid-health-monitoring`; the canonical documentation URL is
  `https://labs.hybridsolutions.cloud/hybrid-health-monitoring/`.
- **GitHub:** Transferred and renamed the public repository, updated its description, homepage, and
  topics, and preserved the old GitHub repository redirect. Migration commit
  `6cea867` was pushed with AB#7340 before transfer. The canonical local clone is
  `D:/git/hybrid-solutions-cloud/hybrid-health-monitoring`.
- **Azure DevOps:** Renamed project `Azure Local SCOM MP` to
  `Hybrid Infrastructure Health Monitoring`. Migration Story AB#7340 owns the cutover. Existing
  Epics AB#7313–AB#7314, Features AB#7315–AB#7318, and Stories AB#7319–AB#7334 remain intact.
- **Governance:** Platform registry commit `aba6241` replaces the old registry entry with
  `hybrid-health-monitoring`, sets the Hybrid-Solutions-Cloud org and HCS scope, corrects the docs
  platform to VitePress, updates the local path and ADO project, and refreshes reference tables.
  The governance build and smoke suite passed and the commit was pushed to Platform Engineering.
- **Validation:** `npm run docs:build` passed; representative local routes returned HTTP 200;
  markdownlint passed with the repository configuration; `git diff --check`, identity assertions,
  and the secret-pattern scan passed. The HCS Governance MCP build and smoke suite passed.
- **Publishing verification:** Product workflow
  `https://github.com/Hybrid-Solutions-Cloud/hybrid-health-monitoring/actions/runs/31629720789`
  succeeded and the canonical site returned HTTP 200 at
  `https://labs.hybridsolutions.cloud/hybrid-health-monitoring/`. Azure Local portal workflow
  `https://github.com/AzureLocal/azurelocal.github.io/actions/runs/31631115407` succeeded; the
  former URL returned HTTP 200 with a meta-refresh and canonical link to the new site.
- **Tracking:** AB#7340 was closed after the repository, ADO, registry, site, and compatibility
  route were verified.
- **Local cleanup:** Windows would not move the active session folder because the current process
  holds it open. A clean canonical clone was created in the correct location. Remove
  `D:/git/azurelocal/azurelocal-scom-mp` only after that handle is released and after confirming
  the canonical clone is clean.
- **Branch:** `main`.
- **Next product work:** Run AB#7319, AB#7327, and AB#7323. Run AB#7331 then AB#7332 before resolving
  ADR 0023. Do not activate Hyper-V Azure Monitor unless ADR 0023 records a go decision.
