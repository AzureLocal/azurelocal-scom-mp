# Changelog

## [Unreleased]

* Move the project to `Hybrid-Solutions-Cloud/hybrid-health-monitoring` and publish documentation
  at `https://labs.hybridsolutions.cloud/hybrid-health-monitoring/`.

### Changed

* Migrate the documentation site and deployment pipelines from MkDocs to VitePress while preserving the project logo, banner, and favicon.
* Rename the public site to Hybrid Infrastructure Health Monitoring and organize it by Azure Local and Hyper-V platform tracks.
* Replace the phase-only roadmap with Azure DevOps-backed platform Epics, delivery Features, research spikes, and architecture gates.

### Added

* Add the committed Hyper-V SCOM Management Pack track and conditional Azure Monitor track through Arc-enabled SCVMM.
* Add ADRs 0021–0023 for the platform split, SCOM packaging boundary, and Hyper-V Azure Monitor go/no-go gate.
* Add the phase-one Hyper-V SCOM monitoring research plan, exhaustive inventory schema, threshold
  policy, and ADO child spikes AB#7343–AB#7353.
* Treat Network ATC as the preferred baseline for eligible Windows Server 2025 Datacenter Hyper-V
  clusters, with separate manual and SCVMM/SDN-managed networking paths.
* Define the Microsoft Hyper-V 2019 Management Pack as research evidence only, with no import,
  extension, override, or runtime dependency in the new Hyper-V MP.
* Split the design documentation into explicit Azure Local and Hyper-V platform sections, each
  separated into SCOM and Azure Monitor design lanes.
* Add ADR 0025 for Hyper-V network-management authority and the Network ATC, SCVMM/SDN, and manual
  networking variants.

## [0.2.1](https://github.com/AzureLocal/azurelocal-scom-mp/compare/azurelocal-scom-mp-v0.2.0...azurelocal-scom-mp-v0.2.1) (2026-05-05)

### Bug Fixes

* Resolve 3 mkdocs strict-mode link errors ([52d9251](https://github.com/AzureLocal/azurelocal-scom-mp/commit/52d9251e4fc0f94ad610672cb7bf107f08222573))

## [0.2.0](https://github.com/AzureLocal/azurelocal-scom-mp/compare/azurelocal-scom-mp-v0.1.0...azurelocal-scom-mp-v0.2.0) (2026-05-05)

### Features

* Add logo, favicon, and banner SVG assets ([811def0](https://github.com/AzureLocal/azurelocal-scom-mp/commit/811def0098dcc74e791880e49e78a1a05614915c))
* Complete Phase 1 - diagram stubs ([5bd3575](https://github.com/AzureLocal/azurelocal-scom-mp/commit/5bd357562729cc5ea850fc3d6a4f15e64633c09d))
* Initial repo scaffold and platform compliance ([ab51f12](https://github.com/AzureLocal/azurelocal-scom-mp/commit/ab51f1268469606a906719339791f4a7445fa495))
* Phase 2 kickoff - infra scope, customization, ADR 0001 ([067c5c8](https://github.com/AzureLocal/azurelocal-scom-mp/commit/067c5c8eb625266fbba838152b526fef1245664b))
* **phase-2:** Complete Phase 2 sign-off — ADRs accepted, drawio diagrams, SquaredUp, Mermaid refinement ([d17595b](https://github.com/AzureLocal/azurelocal-scom-mp/commit/d17595baa2ea6d7a05015e23ec4a1020603fc290))
* **phase-2:** Docs reorg — promote Design to top-level section + author ADRs 0002-0010 ([de266cb](https://github.com/AzureLocal/azurelocal-scom-mp/commit/de266cb668d8c6ff63f7ec697e773841b99b653d))

## Changelog

All notable changes to Hybrid Infrastructure Health Monitoring are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Release notes are generated automatically by
[release-please](https://github.com/googleapis/release-please).
