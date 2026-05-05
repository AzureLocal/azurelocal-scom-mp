# References

All upstream sources used in designing and implementing this project. Organized by topic area.

---

## Azure Monitor Health Models (Native — Preview)

| Resource | URL | Notes |
|---|---|---|
| **Health models overview** ⭐ | https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/overview | Primary doc. Entities, signals, rollup, alerting. |
| **Health model concepts** ⭐ | https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/concepts | Entities (Root/Azure resource/Generic), Relationships, Signals, Health states (Healthy/Degraded/Unhealthy/Unknown), Impact, Health Objectives, Alerts. |
| Create a health model | https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/create | Prerequisites, RBAC, Service Group wiring, Designer views. |
| Configure using the Designer | https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/designer | Visual entity/signal configuration. |
| Azure Monitor documentation hub | https://learn.microsoft.com/en-us/azure/azure-monitor/ | Top-level index. |
| What is Azure Monitor? | https://learn.microsoft.com/en-us/azure/azure-monitor/fundamentals/overview | |
| Azure Monitor SLI/SLO (Public Preview Apr 2026) ⭐ | https://learn.microsoft.com/azure/azure-monitor/fundamentals/service-level-indicators-create | SLI doc page. |
| SLI announcement blog | https://techcommunity.microsoft.com/blog/azureobservabilityblog/azure-monitor-service-level-indicators-sli/4507445 | Apr 29, 2026. Availability/Latency SLIs, Error Budget, Burn Rate alerts. |
| **DevOps Masterminds — Health Models deep dive** ⭐ | https://masterminds.io/technical-blog-posts-devops-masterminds/indispensable-azure-tools-health-models-in-azure-monitor-structuring-what-healthy-really-means-for-a-cloud-workload/ | Dec 2025. Excellent conceptual overview. Signals vs health separation. |
| Design a health model for mission-critical workloads (Training module) | https://learn.microsoft.com/en-us/training/modules/design-health-model-mission-critical-workload/ | MS Learn module. |

---

## Azure Monitor Health Models — Architectural Patterns

| Resource | URL | Notes |
|---|---|---|
| **WAF Mission-Critical Health Modeling** ⭐ | https://learn.microsoft.com/en-us/azure/well-architected/mission-critical/mission-critical-health-modeling | Layered Green/Amber/Red health model. KQL health scores. Most SCOM-analogous pattern. |
| WAF Operational Excellence — Health Modeling | https://learn.microsoft.com/en-us/azure/well-architected/operational-excellence/health-modeling | OE pillar guidance. |
| Mission-Critical Online reference implementation | https://github.com/Azure/Mission-Critical-Online | Sample KQL health score queries at `src/infra/monitoring/queries`. |
| Mission-Critical Connected reference implementation | https://github.com/Azure/Mission-Critical-Connected | |
| Azure Monitor Baseline Alerts (AMBA) ⭐ | https://azure.github.io/azure-monitor-baseline-alerts/welcome/ | Pre-built alert baselines for all Azure services — analogous to vendor Management Packs. |
| AMBA GitHub | https://github.com/Azure/azure-monitor-baseline-alerts | Bicep/ARM/Azure Policy templates. |
| **AMBA — Azure Monitoring Packs (MonStar Packs)** ⭐ | https://azure.github.io/azure-monitor-baseline-alerts/patterns/monitoring-packs/ | Open-source initiative (fka MonStar Packs). Quickly enables monitoring for services and IaaS workloads via Azure Function + Logic App + Workbook UI. Uses AMBA as source of truth. GitHub: https://github.com/Azure/AzureMonitorStarterPacks |
| Cloud Adoption Framework — Monitor your Azure estate | https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/manage/monitor | |

---

## Azure Monitor — Supporting Services

| Resource | URL | Notes |
|---|---|---|
| Azure Service Groups overview | https://learn.microsoft.com/en-us/azure/governance/service-groups/overview | Foundation for health models. Logical grouping of Azure resources. |
| Create a Service Group (portal) | https://learn.microsoft.com/en-us/azure/governance/service-groups/create-service-group-portal | |
| Azure Service Health overview | https://learn.microsoft.com/en-us/azure/service-health/overview | Azure Status + Service Health + Resource Health. |
| Resource Health overview | https://learn.microsoft.com/en-us/azure/service-health/resource-health-overview | Per-resource health state — closest platform equivalent to SCOM agent health. Free signal for every Azure resource in the model. |
| Azure Monitor Workbooks | https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/workbooks-overview | Primary mechanism for custom health dashboards. |
| Azure Monitor Managed Service for Prometheus | https://learn.microsoft.com/en-us/azure/azure-monitor/metrics/prometheus-metrics-overview | Required backend for SLI/SLO tracking. |
| Azure Monitor Insights overview | https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/insights-overview | Curated monitoring experiences (replacement for legacy monitoring solutions). |
| VM Insights overview | https://learn.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-overview | Per-VM perf + processes/dependency map. Recommended for Arc Resource Bridge VM. |
| Enable enhanced VM monitoring | https://learn.microsoft.com/en-us/azure/azure-monitor/vm/monitor-vm#enable-enhanced-monitoring | Walkthrough of VM Insights enable flow. |
| Azure Monitor Agent overview | https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview | The `AzureMonitorWindowsAgent` extension installed by HCI Insights. |
| AMA network / DCE settings | https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-data-collection-endpoint?tabs=PowerShellWindows | Endpoints AMA must reach; firewall + DCE config. |
| Data Collection Rules overview | https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-overview | DCR concepts and authoring. |
| Data Collection Rules best practices | https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-best-practices | |
| Azure Monitor Alerts overview | https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview | |
| Azure Monitor Activity Log | https://learn.microsoft.com/en-us/azure/azure-monitor/platform/activity-log | Free, automatic for every Azure resource. |
| **Azure Local monitoring overview** | https://learn.microsoft.com/en-us/azure/azure-local/concepts/monitoring-overview?view=azloc-2604 | Canonical Azure Local monitoring concepts page. |
| **Azure Local Insights — single cluster** | https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later | The most authoritative HCI Insights enable + troubleshoot reference. |
| **Azure Local Insights — feature workbooks** | https://learn.microsoft.com/en-us/azure/azure-local/manage/monitor-features?view=azloc-2604 | ReFS dedup, Dell APEX hardware events. |
| Azure Local — firewall requirements | https://learn.microsoft.com/en-us/azure/azure-local/concepts/firewall-requirements?view=azloc-2604 | Outbound endpoints; HTTPS-inspection prohibited; Arc Private Link Scopes unsupported. |
| Azure Local — required permissions | https://learn.microsoft.com/en-us/azure/azure-local/deploy/deployment-arc-register-server-permissions?view=azloc-2604 | Resource provider list + deployment RBAC matrix. |
| Azure Arc-enabled servers overview | https://learn.microsoft.com/en-us/azure/azure-arc/servers/overview | Each Azure Local node is `Microsoft.HybridCompute/machines`. |

---

## SCOM → Azure Monitor Migration

| Resource | URL | Notes |
|---|---|---|
| **SCOM to Azure Monitor Migration Tool** ⭐ | https://techcommunity.microsoft.com/blog/azureobservabilityblog/accelerating-scom-to-azure-monitor-migrations-with-automated-analysis-and-arm-te/4493593 | Feb 2026. Parses MP XML → DCR + Alert Rules + Workbook ARM templates. |
| Migration Tool download | https://tinyurl.com/Scom2Azure | Community tool. |
| Azure Monitor Agent (AMA) migration | https://learn.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-migrate-agent | |

---

## SCOM — Official Microsoft Documentation (Current / 2025)

| Resource | URL | Notes |
|---|---|---|
| SCOM documentation hub | https://learn.microsoft.com/en-us/system-center/scom/ | Top-level index for all SCOM docs. |
| Welcome / Overview | https://learn.microsoft.com/en-us/system-center/scom/welcome?view=sc-om-2025 | |
| **Key Concepts** ⭐ | https://learn.microsoft.com/en-us/system-center/scom/key-concepts?view=sc-om-2025 | Management Groups, Agents, Management Packs, Rules vs. Monitors, health states. |
| **What is in a Management Pack** ⭐ | https://learn.microsoft.com/en-us/system-center/scom/manage-overview-management-pack?view=sc-om-2025 | Monitors, Rules, Views, Knowledge, Tasks, Reports, Discoveries, Run As Profiles. Sealed vs Unsealed. |
| Management Pack Lifecycle | https://learn.microsoft.com/en-us/system-center/scom/manage-mp-lifecycle?view=sc-om-2025 | Review/Tune/Deploy/Maintain stages. Best practices. |
| Create MP for Overrides | https://learn.microsoft.com/en-us/system-center/scom/manage-mp-create-unsealed-mp?view=sc-om-2025 | |
| Import/Export/Remove MPs | https://learn.microsoft.com/en-us/system-center/scom/manage-mp-import-remove-delete?view=sc-om-2025 | |
| Management Pack Templates | https://learn.microsoft.com/en-us/system-center/scom/management-pack-templates?view=sc-om-2025 | |
| Create MP Templates | https://learn.microsoft.com/en-us/system-center/scom/create-management-pack-templates?view=sc-om-2025 | |
| Add Knowledge to MP | https://learn.microsoft.com/en-us/system-center/scom/manage-mp-add-knowledge?view=sc-om-2025 | |
| SCOM Managed Instance Overview | https://learn.microsoft.com/en-us/system-center/scom/operations-manager-managed-instance-overview?view=sc-om-2025 | Cloud-hosted SCOM. |
| Migrate to SCOM Managed Instance | https://learn.microsoft.com/en-us/system-center/scom/migrate-to-operations-manager-managed-instance?view=sc-om-2025 | |
| Heartbeat overview | https://learn.microsoft.com/en-us/system-center/scom/manage-agent-heartbeat-overview?view=sc-om-2025 | |
| Agentless monitoring | https://learn.microsoft.com/en-us/system-center/scom/manage-agentless-monitoring?view=sc-om-2025 | |
| Management Group Design | https://learn.microsoft.com/en-us/system-center/scom/plan-mgmt-group-design?view=sc-om-2025 | |

---

## SCOM — SC 2012 R2 Authoring Guide (Legacy — Most Detailed Reference)

> Still the definitive authoring reference. The 2025 docs do not cover authoring at this depth.

| Resource | URL | Notes |
|---|---|---|
| **Authoring Guide Index** ⭐ | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457564(v=sc.12) | Root of the authoring guide. |
| Key Concepts for Authors | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457547(v=sc.12) | |
| Structure of a Management Pack | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457558(v=sc.12) | XML schema, elements, file types. |
| **Monitors and Rules** ⭐ | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457603(v=sc.12) | Unit/Aggregate/Dependency monitor types. Health state. Monitor vs Rule decision criteria. |
| **Aggregate Monitors** ⭐ | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457599(v=sc.12) | 4 standard aggregates (Availability/Config/Perf/Security). Health rollup policies (worst/best state). |
| **Dependency Monitors** ⭐ | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457606(v=sc.12) | Cross-class health rollup. Worst/Best/Percentage policies. Cross-agent constraints. |
| Understanding Classes and Objects | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457568(v=sc.12) | Object, Class, Base Class, Hosting Class, Group. |
| Sealed Management Pack Files | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457596(v=sc.12) | |
| Targets and Objects | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457611(v=sc.12) | |
| Data Sources | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh563868(v=sc.12) | Event log, perf counter, script, OLE DB, LDAP, WMI, registry. |
| Expressions | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457585(v=sc.12) | |
| Alerts | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457540(v=sc.12) | |
| Event Monitors and Rules | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457593(v=sc.12) | |
| Performance Monitors and Rules | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457556(v=sc.12) | |
| Script Monitors and Rules | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457579(v=sc.12) | |
| Event Monitor Reset | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457598(v=sc.12) | Manual/Timer reset patterns. |
| Distributed Applications | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457612(v=sc.12) | |
| Watcher Nodes | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457584(v=sc.12) | |
| Selecting a Target | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457539(v=sc.12) | |
| Creating a New Target | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457543(v=sc.12) | |
| MP Templates | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457614(v=sc.12) | |
| Creating Templates | https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh563869(v=sc.12) | |

---

## SCOM — Community: Brian Wren (MPAuthor)

> Brian Wren was a **Microsoft technical writer on the Information Experience (IX) Team** who owned all SCOM management pack authoring documentation from ~2007–2016. He ran the `@mpauthor` Twitter handle. His 23-module video series on SC 2012 R2 is the most complete end-to-end MP authoring course ever produced. Note: `mpauthor.com` redirects to Silect Software — unrelated to Brian Wren (see Silect section below).

### Video Series — Microsoft Learn / Channel 9

| Resource | URL | Notes |
|---|---|---|
| **SC 2012 R2 MP Video Series (23 modules)** ⭐⭐ | https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/ | Jan 2014 – Mar 2015. Most complete MP authoring video course produced. **Modules 15–19 cover the health model directly.** |
| Channel 9 (original URL) | https://channel9.msdn.com/Series/System-Center-2012-R2-Operations-Manager-Management-Packs | Same content, legacy URL. |
| Module 15 — Health Model Introduction ⭐ | `/Health-Model-Introduction` (append to Learn URL above) | |
| Module 16 — Designing a Health Model ⭐ | `/Designing-a-Health-Model` | |
| Module 17 — Unit Monitors ⭐ | `/Unit-Monitors` | |
| Module 18 — Rules ⭐ | `/Rules` | |
| Module 19 — Health Rollup ⭐ | `/Health-Rollup` | |
| Module 6 — Designing a Service Model | `/Designing-a-Service-Model` | |
| Module 7 — Building Classes and Relationships | `/Building-Classes-and-Relationships` | |
| Module 8 — Intro to Discoveries | `/Introduction-to-Discoveries` | |
| Module 23 — Cookdown | `/Cookdown` | |
| **VSAE Intro YouTube Playlist** (by Teknoglot) | https://www.youtube.com/playlist?list=PL9Yal_Kg7hiHPirvvtlb5zQWsWb54Twmu | 5 videos. Brian Wren VSAE intro content. |

### MPAuthor Blog (Jan 2010 – Jun 2014)

| Resource | URL | Notes |
|---|---|---|
| **MPAuthor Blog Archive** ⭐ | https://learn.microsoft.com/en-us/archive/blogs/mpauthor/ | 45 posts. Original: `blogs.technet.com/MPAuthor`. |
| Management Pack Development Training | `/management-pack-development-training` (append to blog URL) | Apr 7, 2014. |
| Authoring Guide Health Model Section Live ⭐ | `/authoring-guide-health-model-section-live` | Apr 2011. |
| Designing Managed Applications Whitepaper ⭐ | `/designing-managed-applications-whitepaper` | May 2011. |
| How Discovery Works | `/how-discovery-works` | Oct 2010. |
| Discovery Series Parts 2 and 3 (Registry + WMI) | `/discovery-series-parts-2-and-3` | Nov 2010. |
| Discovery Series Part 4 — Scripts | `/discovery-series-part-4-discovery-scripts` | Jan 2011. |
| Complete MP Authoring Guide Available | `/complete-mp-authoring-guide-available-for-download` | Aug 2010. |
| Management Pack Basics | `/management-pack-basics` | Jun 2010. |
| How Do I? Videos (first MP video post) | `/how-do-i-videos` | Jun 2010. |

### BWren's Management Space Blog (2007 – Jan 2010)

| Resource | URL | Notes |
|---|---|---|
| **BWren Blog Archive** | https://learn.microsoft.com/en-us/archive/blogs/brianwren/ | 28 posts. Earlier blog before MPAuthor brand. |
| Management Pack Authoring Guide v2 | `/management-pack-authoring-guide-v2` | Jan 2010. |
| Running PowerShell Scripts from a Management Pack | `/running-powershell-scripts-from-a-management-pack` | Feb 2008. |
| Targeting Rules and Monitors | `/targeting-rules-and-monitors` | Aug 2007. |

### Downloadable Content

| Resource | URL | Notes |
|---|---|---|
| **SC 2012 OpsMgr Authoring PDF** ⭐ | https://download.microsoft.com/download/3/3/F/33F52373-3A75-422C-969B-61E05EEC5E72/SC2012_OpsMgr_Authoring.pdf | The authoritative downloadable authoring guide. |

---

## SCOM — Community: Kevin Holman

> Kevin Holman (Microsoft PFE) is the primary community authority on SCOM MP authoring and the originator of the MP Fragment concept.

| Resource | URL | Notes |
|---|---|---|
| **Blog — kevinholman.com** ⭐ | https://kevinholman.com | 30+ pages of SCOM content. |
| **GitHub — thekevinholman** ⭐ | https://github.com/thekevinholman | 52 public repos. |
| **Fragment Library** | https://github.com/thekevinholman/FragmentLibrary | VSAE + Silect fragment library. Reusable XML snippets for every common workflow. |
| SCOM.Management MP | https://github.com/thekevinholman/SCOM.Management | Discover properties + tasks for SCOM admins. |
| SQL RunAs Addendum MP | https://github.com/thekevinholman/SQLRunAsAddendum | |
| Demo Cookdown MP | https://github.com/thekevinholman/Demo.Cookdown | Demonstrates cookdown/shared data source patterns. |
| Post: Advanced Cookdown MP Authoring | https://kevinholman.com/2024/01/13/advanced-cookdown-management-pack-authoring/ | Jan 2024. |
| Post: Demo Cookdown MP Example | https://kevinholman.com/2022/02/17/demo-cookdown-management-pack-example/ | Feb 2022. |
| Post: How to write event log rules (non-EventData) | https://kevinholman.com/2024/05/30/how-to-write-event-log-rules-that-filter-on-something-other-than-eventdata/ | May 2024. |
| Post: SCOM 2025 Security Account Matrix | https://kevinholman.com/2024/11/25/scom-2025-security-account-matrix/ | Nov 2024. |
| Post: SCOM 2025 QuickStart Deployment Guide | https://kevinholman.com/2024/11/22/scom-2025-quickstart-deployment-guide/ | Nov 2024. |
| Post: UR1 for SCOM 2025 | https://kevinholman.com/2026/03/06/ur1-for-scom-2025-step-by-step/ | Mar 2026. |

---

## SCOM — Community: Silect Software (MP Author)

> `mpauthor.com` redirects to `silect.com/products/`. "MP Author" is a product, not a person.

| Resource | URL | Notes |
|---|---|---|
| Silect homepage | https://silect.com | Founded 2003. Microsoft GOLD Partner. 5,000+ customers. |
| **MP Author Professional** ⭐ | https://silect.com/mp-author-professional/ | Wizard-driven MP authoring. Fragments support. Advanced aggregate/dependency monitors. SNMP/Linux. $1,194/named user. |
| MP Studio | https://silect.com/mp-studio/ | Full MP lifecycle: authoring + version control + override management + migration assistant. |
| Silect Assistant (AI for SCOM) | https://silect.com/silect-assistant/ | Alert optimization, root cause analysis, anomaly detection. NL interaction within SCOM. |
| Silect Operations Portal | https://silect.com/silect-operations-portal/ | Web self-service for SCOM. Grafana integration. |
| Grafana Dashboards for SCOM (free) | https://silect.com/grafana-dashboards-for-scom-free-edition/ | |
| Power BI Dashboards for SCOM | https://silect.com/dashboards-for-scom/ | 10 infrastructure health dashboards. |
| MP Author v11 release notes | https://silect.com/version-11 | |
| MP Author Pro Datasheet (PDF) | https://silect.com/wp-content/uploads/2020/09/MP-Author-Professional-Datasheet.pdf | |
| MP Author vs VSAE comparison (PDF) | https://silect.com/wp-content/uploads/2020/09/VSAE-Compared-to-Silect-MP-Authoring-Products.pdf | |
| MP Author Pro demo video | https://www.youtube.com/watch?v=5Xr6guCr06s | YouTube. |
| MP Authoring Training | https://silect.com/product/mp-authoring-training/ | $395 separate course. |
| **Silect Fragments** ⭐ | https://silect.com/fragments/ | |
| Silect Fragments GitHub | https://github.com/SilectSoftware/Fragments | |
| Silect Fragments download | https://silect.com/download-fragments/ | |
| Linux Fragments | https://silect.com/linux-fragments/ | |
| Webinar: Authoring MPs using Fragments | https://youtu.be/OF_wi17X7mM | |
| Webinar: Advanced MP Authoring using Fragments | https://youtu.be/IGFoh2qcUJ4 | |
| MP Studio demo video | https://youtu.be/ZWoTBMJnU1Y | |
| SCOM Explorer demo | https://youtu.be/2LTEOoVkQas | |
| Migration Assistant demo | https://youtu.be/oAjVeZeYEjk | |

---

## Tools

| Tool | URL | Notes |
|---|---|---|
| **SquaredUp Dashboard Server (DS)** ⭐ | https://ds.squaredup.com | The #1 on-premises dashboard for SCOM. VADA app topology. 60+ integrations (Azure, AWS, Prometheus, SolarWinds, Splunk…). 30-day free trial. |
| DS — SCOM Dashboards | https://ds.squaredup.com/scom-dashboards/ | Next-gen SCOM dashboard feature overview. |
| DS — Enterprise App Monitoring (VADA) | https://ds.squaredup.com/enterprise-application-monitoring/ | Visual Application Discovery & Analysis. |
| DS — Dashboard Packs | https://ds.squaredup.com/dashboard-packs/ | Pre-built dashboard packs. |
| DS — Free MPs (Cookdown) | https://ds.squaredup.com/cookdown/ | Free management packs: PowerShell MP, Self Maintenance MP, Community Catalog MP. |
| DS — Downloads | https://download.squaredup.com/ | Trial download. |
| DS — SCOM Learning Hub | https://ds.squaredup.com/learn/ | |
| DS — Documentation | https://scomsupport.squaredup.com/ | |
| DS — Blog | https://ds.squaredup.com/blog/ | |
| DS Blog: DS 6.3 — Scheduled Maintenance Mode | https://ds.squaredup.com/blog/introducing-squaredup-dashboard-server-6-3/ | |
| DS Blog: DS 6.4 Release Webinar | https://ds.squaredup.com/release-webinars/release-webinar-dashboard-server-6-4/ | |
| **SquaredUp Cloud** ⭐ | https://squaredup.com | SaaS platform. 80+ integrations. Azure + SCOM plugins both available. Free tier: 2 users / 3 sources / 10 monitors / unlimited dashboards. |
| Cloud — Azure Plugin | https://squaredup.com/plugins/azure-dashboards/ | 55 data streams (Azure Monitor metrics, KQL, Cost, Sentinel, Resource Graph, Log Analytics, App Insights…). 44 ready-made dashboards. |
| Cloud — Azure Plugin docs | https://docs.squaredup.com/data-sources/azure-plugin | |
| Cloud — SCOM Plugin | https://squaredup.com/plugins/scom-dashboards/ | Connects SquaredUp Cloud to SCOM (on-prem and SCOM MI). 8 ready-made dashboards. |
| Cloud — SCOM Plugin docs | https://docs.squaredup.com/data-sources/scom-plugin | |
| Cloud Blog: Dashboarding SCOM MI in SquaredUp | https://squaredup.com/blog/dashboarding-scom-mi-in-squaredup/ | SCOM Managed Instance + SquaredUp Cloud. |
| Cloud Blog: SCOM MI Reporting — New Plugin | https://squaredup.com/blog/scom-mi-reporting-new-squaredup-plugin/ | |
| Cloud Blog: Getting Started with SCOM dashboards | https://squaredup.com/blog/getting-started-with-the-scom-plugin/ | |
| Cloud Blog: Getting Started with Azure plugin | https://squaredup.com/blog/getting-started-with-azure-plugin/ | Step-by-step guide. |
| Cloud Blog: Dashboarding Azure — SquaredUp vs Grafana | https://squaredup.com/blog/dashboarding-azure-squaredup-vs-grafana/ | Feb 2026. Comparison of Azure dashboarding in both tools. |
| Cloud Blog: A dive into health roll-up ⭐ | https://squaredup.com/blog/a-dive-into-health-roll-up/ | Apr 2024. SquaredUp's own health propagation model — directly analogous to SCOM aggregate/dependency monitors. |
| Cloud Blog: Perspectives — Dashboard Sprawl | https://squaredup.com/blog/perspectives-our-solution-to-dashboard-sprawl/ | Feb 2026. Smart dashboards concept. |
| Cloud Blog: Low Code Plugins (AI-ready) | https://squaredup.com/blog/introducing-our-ai-ready-low-code-plugins/ | Feb 2026. 16 new integrations, any API source. |
| Cloud — Azure user story | https://squaredup.com/user-stories/azure-dashboards/ | Monitoring Azure VMs and Functions. |
| Cloud — Azure cost dashboard user story | https://squaredup.com/user-stories/visualize-and-monitor-azure-costs/ | 8 ready-made cost dashboards. |
| Cloud — Pricing | https://squaredup.com/pricing/ | |
| Cloud — Documentation | https://docs.squaredup.com/ | |
| Cloud — Community | https://community.squaredup.com/ | |
| SCOMathon | https://scomathon.com/ | Community SCOM event run by SquaredUp. |
| MPViewer | https://github.com/dani3l3/mpviewer | Inspect sealed `.mp` files without VSAE. |
| Visual Studio Authoring Extensions (VSAE) | *(part of Visual Studio)* | Microsoft's official MP authoring IDE extension. |
| MkDocs Material | https://squidfunk.github.io/mkdocs-material/ | Documentation platform used in this repo. |
| draw.io | https://www.drawio.com | Diagramming tool. Source files stored in `diagrams/drawio/`. |

---

## AzureLocal Platform (Org Standards)

> `AzureLocal/platform` is the single source of truth for standards, reusable workflows, test frameworks, and scaffolding across the ~28 repos in the AzureLocal org. Local path: `e:\git\azurelocal-platform`.

| Resource | URL | Notes |
|---|---|---|
| **Platform repo** ⭐ | https://github.com/AzureLocal/platform | Centralized standards, reusable workflows, test frameworks, scaffolding. |
| Platform docs | https://AzureLocal.github.io/platform/ | Full docs site. |
| Getting started | `docs/getting-started/what-is-platform.md` | |
| Onboarding existing repo | `docs/onboarding/adopt-from-existing-repo.md` | **Key file for this repo.** |
| Reusable workflow patterns | `docs/reusable-workflows/consumer-patterns.md` | Copy-paste patterns per repo type. |
| Templates overview | `templates/README.md` | 5 variants: ps-module, ts-web-app, iac-solution, migration-runbook, training-site. |
| `iac-solution` template ⭐ | `templates/iac-solution/` | **This repo's template type.** Bicep/Terraform/ARM + MkDocs. |
| `_common/` template files | `templates/_common/` | `.editorconfig`, `.gitignore`, `.azurelocal-platform.yml`, `CHANGELOG.md`, `STANDARDS.md`, `CODEOWNERS`. |
| Platform metadata schema | https://AzureLocal.github.io/platform/reference/platform-metadata/ | `.azurelocal-platform.yml` schema. |
| Breaking changes governance | `docs/governance/breaking-changes.md` | Reusable workflow versioning policy. |
| MAPROOM overview | `docs/maproom/overview.md` | Offline fixture-based testing framework. |
| TRAILHEAD overview | `docs/trailhead/overview.md` | Live-cluster validation. |
| Architecture overview | `docs/getting-started/architecture-overview.md` | |
| MkDocs requirements (pinned) | `requirements-docs.txt` | mkdocs==1.6.1, mkdocs-material==9.5.49, pygments==2.17.2 (pinned), mermaid2==1.2.1. |

---

## SCOM ↔ Azure Monitor Concept Mapping

| SCOM | Azure Monitor |
|---|---|
| Management Pack | DCR + Alert Rules + Workbook (ARM/Bicep bundle) |
| Health Model (rollup tree) | Azure Monitor Health Model (preview) / WAF layered KQL health model |
| Unit Monitor | Signal on an entity (metric or log query) |
| Aggregate Monitor | Generic entity aggregating child entity health |
| Dependency Monitor | Relationship between entities with health propagation |
| Health State (Green/Yellow/Red) | Healthy / Degraded / Unhealthy |
| Distributed Application | Service Group + Health Model root entity |
| SLA Reporting | Azure Monitor SLI/SLO (public preview) |
| Discovery | Azure Resource Graph / Service Group auto-discovery |
| Override | Signal threshold / entity impact setting |
| Notification Subscription | Action Group |
| Data Warehouse | Log Analytics Workspace |
| Agents | Azure Monitor Agent (AMA) |
| Operations Console | Azure Portal + Workbooks + Grafana |
| MP Authoring | Azure portal health model designer + KQL + ARM/Bicep |
