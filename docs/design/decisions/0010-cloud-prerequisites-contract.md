# ADR 0010 — Cloud-side prerequisites contract

- **Status**: Proposed
- **Date**: 2026-05-05
- **Deciders**: @AzureLocal/azurelocal-scom-mp-maintainers

## Context

The Azure Monitor Health Models track does **not** collect signals on its own — it
*evaluates* signals already flowing through Azure Monitor, Resource Health, and
DCMA. If those upstream signals aren't flowing, the model is empty regardless of how
good its design is.

The full prerequisites discovery is captured in
[docs/azure-monitor/prerequisites.md](../../azure-monitor/prerequisites.md). This ADR
**locks the prerequisites as a project contract**: a deployment that does not satisfy
this contract will not deploy. The Bicep module fails the dry-run with an actionable
error rather than silently producing a degraded model.

Failure modes if prerequisites are advisory rather than contractual:

1. **Silent partial models** — half the entities show Unknown because their signal
   source isn't flowing; operator doesn't realize there's a gap.
2. **Pre-flight chaos** — deployment time is the wrong place to discover that HCI
   Insights isn't enabled.
3. **No upgrade path** — when a future Azure Local version requires a new prerequisite,
   we have no way to enforce it on existing deployments.

## Decision

The Azure Monitor Bicep module enforces a **prerequisites contract** at deployment
time. Every prerequisite is in one of two tiers:

| Tier | Behavior on failure |
|---|---|
| **Blocking** | Bicep `assert` fails dry-run; deployment refuses to proceed |
| **Recommended** | Bicep produces a `warning` output; deployment proceeds |

### Blocking prerequisites (deployment refuses to proceed)

Per [prerequisites.md](../../azure-monitor/prerequisites.md):

1. **Azure subscription registered for required Resource Providers** —
   `Microsoft.AzureStackHCI`, `Microsoft.HybridCompute`, `Microsoft.Insights`,
   `Microsoft.OperationalInsights`, `Microsoft.HybridConnectivity`,
   `Microsoft.Maintenance`, `Microsoft.ResourceConnector`, `Microsoft.Monitor`
   (Health Models)
2. **Cluster Arc-registered** with `connectivityStatus = Connected`
3. **Cluster Managed Identity ("enhanced management") enabled** — gates the Insights
   "Get Started" flow and AMA's identity binding
4. **Log Analytics Workspace exists and is healthy** — the destination for AMA + HCI
   Insights
5. **HCI Insights enabled on the cluster** — installs AMA on every node and creates
   the canonical `AzureStackHCI-…` DCR
6. **Service Group exists and contains the required L3 entities**
   ([ADR 0006](0006-azmon-entity-model.md))
7. **Health Model author** has Service Group Reader + Monitoring Reader on Service
   Group members + Monitoring Contributor on the Service Group
8. **Health Model managed identity** has Monitoring Reader on the workspace + Reader on
   Service Group
9. **Network reachability** — outbound 80/443 to required Microsoft endpoints; HTTPS
   inspection disabled; Arc Private Link Scopes not configured (unsupported)

### Recommended (warns but does not block)

10. **Cluster registered with Microsoft Entra ID for the Arc Connected Machine agent**
    on each node (older clusters may need migration; pre-Nov-2023 clusters definitely do)
11. **DCMA / Telemetry & Diagnostics agent enabled** on the cluster (separate from AMA;
    surfaces the 60+ Azure Local platform metrics under `AzureStackHCI/clusters`)
12. **VM Insights enabled** for the Resource Bridge VM (and any management VMs) — gives
    process map + dependency view + `InsightsMetrics`
13. **Update Manager linked to the cluster** — enables the `Update.LastResult` and
    `Update.Available.Days` signals; without it those signals are Unknown
14. **No MMA (legacy Log Analytics agent) coexisting with AMA** — double ingestion adds
    cost without benefit
15. **Activity Log streaming to the same workspace** — improves correlation in queries

### Contract enforcement mechanism

The prerequisites are checked in three places:

| Location | What | When |
|---|---|---|
| **Bicep module dry-run** (`what-if`) | Resource provider registration, RP versions, Service Group existence, RBAC role assignments | Before every deployment |
| **Pre-flight PowerShell script** | HCI Insights state, AMA presence on each node, DCMA state, network reachability, MMA absence | Before initial deployment + on demand via `azurelocal-scom-mp.ps1 -CheckPrerequisites` |
| **Health model itself** | Some prerequisites are also model entities (e.g., LAW reachability is a Layer-3 signal). When the prereq breaks post-deployment, the model itself reports it Unhealthy. | Continuously after deployment |

This three-layer check means:
- Pre-deployment: the operator gets a clear "you're missing X" error
- Post-deployment: the operator can re-run pre-flight on demand
- Steady state: the model itself surfaces drift in the prereq

### Versioning

The contract is versioned with the project:
- v1.x has the prerequisites listed above (azloc-2604 baseline)
- Future versions can add prerequisites with a deprecation pass first
- The CHANGELOG records every change to the contract

## Consequences

- **Positive**: Failed deployments fail loudly and early. No silent partial models in
  production.
- **Positive**: Operators have a single source of truth ("this is what must be true")
  rather than scattered docs.
- **Positive**: The pre-flight script is a debugging tool by itself — operators run it
  to sanity-check after Azure Local updates or RBAC changes.
- **Positive**: Versioning the contract means we can evolve it cleanly across Azure
  Local releases.
- **Negative**: First-time deployments take longer because operators must complete
  prerequisites before the model deploys. Mitigated by clear error messages and the
  pre-flight script.
- **Negative**: Some operators will be tempted to bypass blocking checks. Mitigated by
  *not* providing a `-Force` flag — bypass requires editing the Bicep module, which is
  documented and traceable.
- **Affected**: Phase 4 (Azure Monitor) — the Bicep module structure, the pre-flight
  script, the health model entity definitions for prereqs that double as L3 signals.

## Alternatives considered

- **Advisory prerequisites; no enforcement** — rejected: same as having no contract.
- **Enforcement at Bicep deployment time only** — rejected: misses post-deployment
  drift; operator only learns when alerts go silent.
- **Enforcement only post-deployment via the model** — rejected: deployment succeeds
  with a broken state; operator has to debug a half-deployed model.
- **One blocking tier, no recommended tier** — rejected: VM Insights and Update
  Manager are genuinely optional; blocking on them frustrates operators who don't
  need those signals.

## References

- [Prerequisites page](../../azure-monitor/prerequisites.md)
- ADR 0001 — [Scope & topology](0001-scope-and-topology.md)
- ADR 0006 — [Azure Monitor entity model alignment](0006-azmon-entity-model.md)
- [Azure Local — monitoring overview](https://learn.microsoft.com/en-us/azure/azure-local/concepts/monitoring-overview?view=azloc-2604)
- [Azure Local Insights — single cluster](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later)
- [Azure Local — required permissions](https://learn.microsoft.com/en-us/azure/azure-local/deploy/deployment-arc-register-server-permissions?view=azloc-2604)
- [Azure Local — firewall requirements](https://learn.microsoft.com/en-us/azure/azure-local/concepts/firewall-requirements?view=azloc-2604)
- [Azure Monitor Agent — overview](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [Azure Service Groups — overview](https://learn.microsoft.com/en-us/azure/governance/service-groups/overview)
- [Azure Monitor Health Models — overview](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/)
