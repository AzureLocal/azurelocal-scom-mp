---
title: Changelog
description: Release history for Hybrid Infrastructure Health Monitoring.
---

# Changelog

All notable changes to this project are documented in [`CHANGELOG.md`](https://github.com/Hybrid-Solutions-Cloud/hybrid-health-monitoring/blob/main/CHANGELOG.md)
at the repository root.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Release notes are generated automatically by [release-please](https://github.com/googleapis/release-please).

Until the first tagged release, the canonical changelog lives in
[`CHANGELOG.md`](https://github.com/Hybrid-Solutions-Cloud/hybrid-health-monitoring/blob/main/CHANGELOG.md)
at the repo root.

---

## How releases work

This repo uses **release-please** for automated semantic versioning. Conventional
Commit messages on `main` (e.g., `feat:`, `fix:`, `docs:`) drive the version bump
and produce a release PR. When that PR is merged, a tagged GitHub Release and an
updated `CHANGELOG.md` are published.

See the platform [release strategy standard](https://AzureLocal.github.io/platform/standards/)
for the org-wide release conventions.

## Release artifacts

Released product artifacts will be versioned by platform and delivery surface. Depending on the
accepted packaging ADRs, releases can include:

- Azure Local and Hyper-V sealed SCOM Management Packs plus override packs
- Azure Local Azure Monitor health-model Bicep templates
- The KQL signal library
- The Azure Monitor Workbook JSON
- Signed, versioned bundles with explicit platform dependencies

Hyper-V Azure Monitor artifacts are included only if ADR 0023 is accepted with a go decision.
