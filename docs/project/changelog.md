---
title: Changelog
description: Release history for azurelocal-scom-mp.
---

# Changelog

All notable changes to this project are documented in [`CHANGELOG.md`](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/CHANGELOG.md)
at the repository root.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Release notes are generated automatically by [release-please](https://github.com/googleapis/release-please).

Until the first tagged release, the canonical changelog lives in
[`CHANGELOG.md`](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/CHANGELOG.md)
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

Once Phase 6 ships v1.0.0, releases will include:

- The sealed SCOM Management Pack (`.mp`) + override pack (`.xml`)
- The Azure Monitor health model ARM/Bicep templates
- The KQL signal library
- The Azure Monitor Workbook JSON
- A signed `azurelocal-scom-mp-vX.Y.Z.zip` containing all of the above
