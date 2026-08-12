import { defineConfig } from 'vitepress'

const repositoryUrl = 'https://github.com/AzureLocal/azurelocal-scom-mp'
const base = '/azurelocal-scom-mp/'

export default defineConfig({
  base,
  title: 'Azure Local — Health Monitoring',
  description: 'SCOM Management Pack and Azure Monitor Health Models for Azure Local infrastructure.',
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
    hostname: 'https://azurelocal.cloud/azurelocal-scom-mp/',
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
      alt: 'Azure Local health monitoring',
    },
    siteTitle: 'Azure Local Health Monitoring',

    nav: [
      { text: 'Home', link: '/' },
      { text: 'Design', link: '/design/' },
      { text: 'SCOM MP', link: '/scom-mp/' },
      { text: 'Azure Monitor', link: '/azure-monitor/' },
      { text: 'Migration', link: '/comparison/' },
      { text: 'Project', link: '/project/about' },
    ],

    sidebar: {
      '/design/': [
        {
          text: 'Design',
          items: [
            { text: 'Overview', link: '/design/' },
            { text: 'Scope and topology', link: '/design/scope-topology' },
            { text: 'Health model', link: '/design/health-model' },
            { text: 'Signal catalog', link: '/design/signal-catalog' },
            { text: 'Customization', link: '/design/customization' },
            { text: 'SCOM and Azure Monitor mapping', link: '/design/concept-mapping' },
            { text: 'Health-state flow', link: '/design/diagrams/health-state-flow' },
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
            { text: 'ADR template', link: '/design/decisions/template' },
          ],
        },
      ],

      '/scom-mp/': [
        {
          text: 'SCOM Management Pack',
          items: [
            { text: 'Overview', link: '/scom-mp/' },
            { text: 'Health-rollup tree', link: '/scom-mp/diagrams/health-tree' },
            { text: 'SquaredUp Dashboard Server', link: '/scom-mp/squaredup/' },
          ],
        },
      ],

      '/azure-monitor/': [
        {
          text: 'Azure Monitor',
          items: [
            { text: 'Overview', link: '/azure-monitor/' },
            { text: 'Prerequisites', link: '/azure-monitor/prerequisites' },
            { text: 'Entity graph', link: '/azure-monitor/diagrams/entity-graph' },
            { text: 'SquaredUp Cloud', link: '/azure-monitor/squaredup/' },
          ],
        },
      ],

      '/comparison/': [
        {
          text: 'Migration',
          items: [
            { text: 'SCOM to Azure Monitor', link: '/comparison/' },
            { text: 'Concept mapping', link: '/design/concept-mapping' },
          ],
        },
      ],

      '/project/': [
        {
          text: 'Project',
          items: [
            { text: 'About', link: '/project/about' },
            { text: 'Roadmap', link: '/project/roadmap' },
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
      copyright: 'Copyright © Hybrid Cloud Solutions and AzureLocal',
    },
  },
})
