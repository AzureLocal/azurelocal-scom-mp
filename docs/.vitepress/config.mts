import { defineConfig } from 'vitepress'

const repositoryUrl = 'https://github.com/Hybrid-Solutions-Cloud/hybrid-health-monitoring'
const base = '/hybrid-health-monitoring/'

export default defineConfig({
  base,
  title: 'Hybrid Infrastructure Health Monitoring',
  description: 'SCOM and Azure Monitor health models for Hyper-V and Azure Local.',
  lang: 'en-US',
  cleanUrls: true,
  lastUpdated: true,

  head: [
    ['link', {
      rel: 'icon',
      type: 'image/svg+xml',
      href: `${base}assets/images/azurelocal-scom-mp-icon.svg`,
    }],
    ['meta', { name: 'theme-color', content: '#0078d4' }],
  ],

  sitemap: {
    hostname: 'https://labs.hybridsolutions.cloud/hybrid-health-monitoring/',
  },

  markdown: {
    config(markdown) {
      const defaultFence = markdown.renderer.rules.fence!

      markdown.renderer.rules.fence = (tokens, index, options, environment, self) => {
        const token = tokens[index]

        if (token.info.trim() === 'mermaid') {
          const id = `mermaid-${token.map?.[0] ?? index}`
          const graph = encodeURIComponent(token.content)
          return `<MermaidDiagram id="${id}" graph="${graph}" />`
        }

        return defaultFence(tokens, index, options, environment, self)
      }
    },
  },

  themeConfig: {
    logo: {
      src: '/assets/images/azurelocal-scom-mp-icon.svg',
      alt: 'Hybrid Infrastructure Health Monitoring',
    },
    siteTitle: '<span class="brand-line">Hybrid Infrastructure</span> <span class="brand-line">Health Monitoring</span>',

    nav: [
      { text: 'Home', link: '/' },
      { text: 'Design', link: '/design/' },
      { text: 'Azure Local', link: '/azure-local/' },
      { text: 'Hyper-V', link: '/hyper-v/' },
      { text: 'SCOM → Azure Monitor', link: '/comparison/' },
      { text: 'Integrations', link: '/integrations/' },
      { text: 'Project', link: '/project/about' },
    ],

    sidebar: {
      '/design/': [
        {
          text: 'Design map',
          items: [
            { text: 'Overview', link: '/design/' },
            { text: 'Shared design', link: '/design/shared/' },
            { text: 'Research spikes', link: '/design/research-spikes' },
            { text: 'Decision scope map', link: '/design/decisions/' },
            { text: 'Health-state flow', link: '/design/diagrams/health-state-flow' },
          ],
        },
        {
          text: 'Azure Local · SCOM MP',
          items: [
            { text: 'Solution design', link: '/design/azure-local/scom-mp' },
            { text: 'Architecture', link: '/design/azure-local/architecture' },
            { text: 'MP structure', link: '/design/azure-local/management-pack-structure' },
            { text: 'Class and relationship model', link: '/design/azure-local/class-and-relationship-model' },
            { text: 'Discovery and workflows', link: '/design/azure-local/discovery-and-workflow-architecture' },
            { text: 'Health and alerts', link: '/design/azure-local/health-and-alert-architecture' },
            { text: 'Distributed Application', link: '/design/azure-local/distributed-application' },
            { text: 'Overrides and tuning', link: '/design/azure-local/override-and-tuning-architecture' },
            { text: 'Validation and release', link: '/design/azure-local/validation-and-release' },
            { text: 'Product documentation', link: '/scom-mp/' },
            { text: 'Monitoring research', link: '/scom-mp/monitoring-research' },
            { text: 'Monitoring catalog', link: '/scom-mp/monitoring-catalog' },
            { text: 'Administration guide', link: '/scom-mp/management-pack-guide' },
            { text: 'SquaredUp Dashboard Server', link: '/scom-mp/squaredup/' },
          ],
        },
        {
          text: 'Azure Local · Azure Monitor',
          items: [
            { text: 'Solution design', link: '/design/azure-local/azure-monitor' },
            { text: 'Architecture', link: '/design/azure-local/azure-monitor-architecture' },
            { text: 'Product documentation', link: '/azure-monitor/' },
            { text: 'Research and signal evidence', link: '/azure-monitor/research' },
            { text: 'Cloud prerequisites', link: '/azure-monitor/prerequisites' },
            { text: 'SquaredUp Cloud', link: '/azure-monitor/squaredup/' },
          ],
        },
        {
          text: 'Azure Local · Platform context',
          collapsed: true,
          items: [
            { text: 'Platform design map', link: '/design/azure-local/' },
            { text: 'Scope and topology', link: '/design/scope-topology' },
            { text: 'Health model', link: '/design/health-model' },
            { text: 'Signal catalog', link: '/design/signal-catalog' },
            { text: 'Customization', link: '/design/customization' },
            { text: 'SCOM ↔ Azure Monitor mapping', link: '/design/concept-mapping' },
          ],
        },
        {
          text: 'Hyper-V · SCOM MP',
          items: [
            { text: 'Solution design', link: '/design/hyper-v/scom-mp' },
            { text: 'Architecture', link: '/design/hyper-v/architecture' },
            { text: 'MP structure', link: '/design/hyper-v/management-pack-structure' },
            { text: 'Overrides and tuning', link: '/design/hyper-v/override-and-tuning-architecture' },
            { text: 'Class and relationship model', link: '/design/hyper-v/class-and-relationship-model' },
            { text: 'Discovery and workflows', link: '/design/hyper-v/discovery-and-workflow-architecture' },
            { text: 'Health and alerts', link: '/design/hyper-v/health-and-alert-architecture' },
            { text: 'Distributed Application', link: '/design/hyper-v/distributed-application' },
            { text: 'Authoring standards', link: '/design/hyper-v/authoring-standards' },
            { text: 'Security and operability', link: '/design/hyper-v/security-and-operability' },
            { text: 'Validation and release', link: '/design/hyper-v/validation-and-release' },
            { text: 'Administration guide', link: '/hyper-v/management-pack-guide' },
            { text: 'SCOM monitoring research', link: '/hyper-v/monitoring-research' },
            { text: 'Monitoring catalog policy', link: '/hyper-v/monitoring-catalog' },
            { text: 'SquaredUp Dashboard Server', link: '/hyper-v/squaredup-dashboard-server' },
          ],
        },
        {
          text: 'Hyper-V · Azure Monitor',
          items: [
            { text: 'Solution design', link: '/design/hyper-v/azure-monitor' },
            { text: 'Health Model', link: '/hyper-v/azure-monitor' },
            { text: 'Research and parity gaps', link: '/hyper-v/azure-monitor-research' },
            { text: 'SquaredUp Cloud', link: '/hyper-v/squaredup-cloud' },
          ],
        },
        {
          text: 'Hyper-V · Platform context',
          collapsed: true,
          items: [
            { text: 'Platform design map', link: '/design/hyper-v/' },
            { text: 'Research spikes', link: '/design/research-spikes' },
          ],
        },
        {
          text: 'Architecture decisions',
          collapsed: true,
          items: [
            { text: 'Decision index', link: '/design/decisions/' },
            { text: '0001 — Scope and topology', link: '/design/decisions/0001-scope-and-topology' },
            { text: '0002 — Signal source', link: '/design/decisions/0002-signal-source' },
            { text: '0003 — Health rollup', link: '/design/decisions/0003-health-rollup-policy' },
            { text: '0004 — SCOM discovery', link: '/design/decisions/0004-scom-discovery-strategy' },
            { text: '0005 — SCOM class hierarchy', link: '/design/decisions/0005-scom-class-hierarchy' },
            { text: '0006 — Azure Monitor entities', link: '/design/decisions/0006-azmon-entity-model' },
            { text: '0007 — Naming', link: '/design/decisions/0007-naming-convention' },
            { text: '0008 — Customization', link: '/design/decisions/0008-customization-strategy' },
            { text: '0009 — Alerts and health state', link: '/design/decisions/0009-alert-vs-health-state' },
            { text: '0010 — Cloud prerequisites', link: '/design/decisions/0010-cloud-prerequisites-contract' },
            { text: '0011 — Azure-side connectivity', link: '/design/decisions/0011-l3-azure-scope-and-connectivity' },
            { text: '0012 — Metrics routing', link: '/design/decisions/0012-azure-monitor-workspace-vs-law-metrics' },
            { text: '0013 — Azure deployment', link: '/design/decisions/0013-azmon-deployment-strategy' },
            { text: '0014 — CI/CD', link: '/design/decisions/0014-cicd-pipeline-strategy' },
            { text: '0015 — Testing', link: '/design/decisions/0015-testing-strategy' },
            { text: '0016 — Signing and secrets', link: '/design/decisions/0016-signing-and-secrets' },
            { text: '0017 — Versioning and release', link: '/design/decisions/0017-versioning-and-release' },
            { text: '0018 — Self-observability', link: '/design/decisions/0018-self-observability' },
            { text: '0019 — Cost, scale, and retention', link: '/design/decisions/0019-cost-scale-retention' },
            { text: '0020 — VitePress documentation', link: '/design/decisions/0020-vitepress-documentation-platform' },
            { text: '0021 — Platform and delivery tracks', link: '/design/decisions/0021-platform-and-delivery-track-architecture' },
            { text: '0022 — SCOM packaging boundaries', link: '/design/decisions/0022-scom-management-pack-packaging-boundaries' },
            { text: '0023 — Hyper-V Azure Monitor gate', link: '/design/decisions/0023-hyper-v-azure-monitor-through-arc-enabled-scvmm' },
            { text: '0024 — Repository and publishing identity', link: '/design/decisions/0024-repository-and-publishing-identity' },
            { text: '0025 — Hyper-V network authority', link: '/design/decisions/0025-hyper-v-network-management-authority' },
            { text: '0026 — Platform-owned SCOM DAs', link: '/design/decisions/0026-platform-owned-scom-distributed-applications' },
            { text: '0027 — Hyper-V MP decomposition', link: '/design/decisions/0027-hyper-v-scom-management-pack-decomposition' },
            { text: '0028 — Hyper-V object and discovery', link: '/design/decisions/0028-hyper-v-object-and-discovery-architecture' },
            { text: '0029 — Hyper-V health and DA rollup', link: '/design/decisions/0029-hyper-v-health-alert-and-da-rollup' },
            { text: '0030 — Platform-first source tree', link: '/design/decisions/0030-platform-first-source-tree' },
            { text: '0031 — Hyper-V MP authoring toolchain', link: '/design/decisions/0031-hyper-v-mp-authoring-toolchain' },
            { text: '0032 — Azure Local runtime boundary', link: '/design/decisions/0032-azure-local-scom-local-runtime-boundary' },
            { text: '0033 — Azure Local MP decomposition', link: '/design/decisions/0033-azure-local-scom-management-pack-decomposition' },
            { text: '0034 — Azure Local object and DA', link: '/design/decisions/0034-azure-local-object-discovery-and-da-architecture' },
            { text: '0035 — Azure Local health and rollup', link: '/design/decisions/0035-azure-local-health-alert-and-rollup-architecture' },
            { text: '0036 — Azure Local Health Model v1', link: '/design/decisions/0036-azure-local-azure-monitor-health-model-v1' },
            { text: '0037 — Hyper-V Health Model', link: '/design/decisions/0037-hyper-v-azure-monitor-health-model-architecture' },
            { text: '0038 — SCOM to ServiceNow', link: '/design/decisions/0038-scom-servicenow-connector-boundary' },
            { text: 'ADR template', link: '/design/decisions/template' },
          ],
        },
      ],

      '/azure-local/': [
        {
          text: 'Azure Local track',
          items: [
            { text: 'Track overview', link: '/azure-local/' },
            { text: 'Platform design', link: '/design/azure-local/' },
          ],
        },
        {
          text: 'Azure Local · SCOM MP',
          items: [
            { text: 'Solution design', link: '/design/azure-local/scom-mp' },
            { text: 'Architecture', link: '/design/azure-local/architecture' },
            { text: 'MP structure', link: '/design/azure-local/management-pack-structure' },
            { text: 'Class and relationship model', link: '/design/azure-local/class-and-relationship-model' },
            { text: 'Discovery and workflows', link: '/design/azure-local/discovery-and-workflow-architecture' },
            { text: 'Health and alerts', link: '/design/azure-local/health-and-alert-architecture' },
            { text: 'SCOM Distributed Application', link: '/design/azure-local/distributed-application' },
            { text: 'Overrides and tuning', link: '/design/azure-local/override-and-tuning-architecture' },
            { text: 'Validation and release', link: '/design/azure-local/validation-and-release' },
            { text: 'SCOM Management Pack', link: '/scom-mp/' },
            { text: 'Monitoring research', link: '/scom-mp/monitoring-research' },
            { text: 'Monitoring catalog', link: '/scom-mp/monitoring-catalog' },
            { text: 'Administration guide', link: '/scom-mp/management-pack-guide' },
            { text: 'SquaredUp Dashboard Server', link: '/scom-mp/squaredup/' },
          ],
        },
        {
          text: 'Azure Local · Azure Monitor',
          items: [
            { text: 'Solution design', link: '/design/azure-local/azure-monitor' },
            { text: 'Architecture', link: '/design/azure-local/azure-monitor-architecture' },
            { text: 'Azure Monitor Health Models', link: '/azure-monitor/' },
            { text: 'Research and signal evidence', link: '/azure-monitor/research' },
            { text: 'Azure Monitor prerequisites', link: '/azure-monitor/prerequisites' },
            { text: 'SquaredUp Cloud', link: '/azure-monitor/squaredup/' },
          ],
        },
      ],

      '/scom-mp/': [
        {
          text: 'Azure Local / SCOM',
          items: [
            { text: 'Overview', link: '/scom-mp/' },
            { text: 'Design', link: '/design/azure-local/scom-mp' },
            { text: 'Architecture', link: '/design/azure-local/architecture' },
            { text: 'MP structure', link: '/design/azure-local/management-pack-structure' },
            { text: 'Class model', link: '/design/azure-local/class-and-relationship-model' },
            { text: 'Discovery and workflows', link: '/design/azure-local/discovery-and-workflow-architecture' },
            { text: 'Health and alerts', link: '/design/azure-local/health-and-alert-architecture' },
            { text: 'Distributed Application', link: '/design/azure-local/distributed-application' },
            { text: 'Overrides and tuning', link: '/design/azure-local/override-and-tuning-architecture' },
            { text: 'Validation and release', link: '/design/azure-local/validation-and-release' },
            { text: 'Monitoring research', link: '/scom-mp/monitoring-research' },
            { text: 'Monitoring catalog', link: '/scom-mp/monitoring-catalog' },
            { text: 'Administration guide', link: '/scom-mp/management-pack-guide' },
            { text: 'Health-rollup tree', link: '/scom-mp/diagrams/health-tree' },
            { text: 'SquaredUp Dashboard Server', link: '/scom-mp/squaredup/' },
          ],
        },
      ],

      '/azure-monitor/': [
        {
          text: 'Azure Local / Azure Monitor',
          items: [
            { text: 'Overview', link: '/azure-monitor/' },
            { text: 'Design', link: '/design/azure-local/azure-monitor' },
            { text: 'Architecture', link: '/design/azure-local/azure-monitor-architecture' },
            { text: 'Research and signal evidence', link: '/azure-monitor/research' },
            { text: 'Prerequisites', link: '/azure-monitor/prerequisites' },
            { text: 'Entity graph', link: '/azure-monitor/diagrams/entity-graph' },
            { text: 'SquaredUp Cloud', link: '/azure-monitor/squaredup/' },
          ],
        },
      ],

      '/hyper-v/': [
        {
          text: 'Hyper-V track',
          items: [
            { text: 'Track overview', link: '/hyper-v/' },
            { text: 'Platform design', link: '/design/hyper-v/' },
          ],
        },
        {
          text: 'Hyper-V · SCOM MP',
          items: [
            { text: 'Solution design', link: '/design/hyper-v/scom-mp' },
            { text: 'SCOM architecture', link: '/design/hyper-v/architecture' },
            { text: 'MP structure', link: '/design/hyper-v/management-pack-structure' },
            { text: 'Overrides and tuning', link: '/design/hyper-v/override-and-tuning-architecture' },
            { text: 'Class and relationship model', link: '/design/hyper-v/class-and-relationship-model' },
            { text: 'Discovery and workflows', link: '/design/hyper-v/discovery-and-workflow-architecture' },
            { text: 'Health and alerts', link: '/design/hyper-v/health-and-alert-architecture' },
            { text: 'SCOM Distributed Application', link: '/design/hyper-v/distributed-application' },
            { text: 'Authoring standards', link: '/design/hyper-v/authoring-standards' },
            { text: 'Security and operability', link: '/design/hyper-v/security-and-operability' },
            { text: 'Validation and release', link: '/design/hyper-v/validation-and-release' },
            { text: 'SCOM Management Pack', link: '/hyper-v/scom-mp' },
            { text: 'Administration guide', link: '/hyper-v/management-pack-guide' },
            { text: 'SCOM monitoring research', link: '/hyper-v/monitoring-research' },
            { text: 'Monitoring catalog policy', link: '/hyper-v/monitoring-catalog' },
            { text: 'SquaredUp Dashboard Server', link: '/hyper-v/squaredup-dashboard-server' },
          ],
        },
        {
          text: 'Hyper-V · Azure Monitor',
          items: [
            { text: 'Solution design', link: '/design/hyper-v/azure-monitor' },
            { text: 'Azure Monitor Health Model', link: '/hyper-v/azure-monitor' },
            { text: 'Research and parity gaps', link: '/hyper-v/azure-monitor-research' },
            { text: 'SquaredUp Cloud', link: '/hyper-v/squaredup-cloud' },
          ],
        },
        {
          text: 'Shared research',
          collapsed: true,
          items: [
            { text: 'Research spikes', link: '/design/research-spikes' },
          ],
        },
      ],

      '/comparison/': [
        {
          text: 'SCOM → Azure Monitor migration',
          items: [
            { text: 'Migration overview', link: '/comparison/' },
            { text: 'Concept mapping', link: '/design/concept-mapping' },
          ],
        },
      ],

      '/integrations/': [
        {
          text: 'Integrations',
          items: [
            { text: 'Overview', link: '/integrations/' },
            { text: 'ServiceNow', link: '/integrations/servicenow' },
            { text: 'SCOM to ServiceNow', link: '/integrations/scom-servicenow' },
          ],
        },
      ],

      '/project/': [
        {
          text: 'Project',
          items: [
            { text: 'About', link: '/project/about' },
            { text: 'Roadmap', link: '/project/roadmap' },
            { text: 'ServiceNow integration', link: '/integrations/servicenow' },
            { text: 'SCOM to ServiceNow', link: '/integrations/scom-servicenow' },
            { text: 'Changelog', link: '/project/changelog' },
            { text: 'License', link: '/project/license' },
          ],
        },
      ],
    },

    search: {
      provider: 'local',
    },

    outline: {
      level: [2, 3],
    },

    editLink: {
      pattern: `${repositoryUrl}/edit/main/docs/:path`,
      text: 'Edit this page on GitHub',
    },

    lastUpdated: {
      text: 'Last updated',
    },

    docFooter: {
      prev: 'Previous page',
      next: 'Next page',
    },

    socialLinks: [
      { icon: 'github', link: repositoryUrl },
    ],

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © Hybrid Solutions Cloud contributors',
    },
  },
})
