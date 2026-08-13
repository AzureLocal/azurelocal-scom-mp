# ADR 0031 — Hyper-V Management Pack authoring toolchain

**Status:** Proposed

**Date:** 2026-08-13

**Decision owners:** Repository owner and maintainers

## Context

The Hyper-V SCOM product needs reviewable source, deterministic builds, schema and dependency
validation, sealing, signing, and lab imports. No single authoring application should become a
runtime dependency or the only place where product source exists. The current workstation does not
have Microsoft Management Pack verification or sealing tools installed.

Microsoft distinguishes editable XML from sealed `.mp` artifacts and requires dependencies to be
present during import. The Management Pack Authoring Guide supports SCOM 2019, 2022, 2025, and SCOM
Managed Instance and documents both direct authoring and fragment-assisted workflows. Community
fragments provide useful patterns, but every imported pattern still requires source review,
namespace replacement, current-version validation, and product-specific tests.

## Proposed decision

Use tool-neutral Management Pack XML templates and scenario-focused fragments as the canonical
source. Build and contract checks run through repository-owned PowerShell 7 scripts. An approved
SCOM authoring environment performs Microsoft SDK verification, test sealing, release sealing, and
lab import. Silect MP Author or MP Studio can be used to inspect, compose, and review content, but
their project database is not the source of truth.

The pipeline is:

`source templates and fragments → deterministic development XML → static contract checks → Microsoft verification → test sealing → SCOM lab import → release sealing and signing`.

The repository never commits a private signing key. Development output without the release signing
identity is explicitly non-release material.

## Options considered

### Tool-neutral XML and fragments

| Dimension | Assessment |
|---|---|
| Reviewability | High; all semantics are visible in source control |
| Automation | High; composition and policy checks are deterministic |
| Vendor lock-in | Low; authoring tools can change without changing the public XML contract |
| Initial effort | Moderate; repository build and validation logic must be maintained |

### Silect-only project source

| Dimension | Assessment |
|---|---|
| Reviewability | Depends on exported artifacts and tool availability |
| Automation | Strong where licensed build features are available |
| Vendor lock-in | Higher; project state and build depend on one toolchain |
| Initial effort | Lower for interactive authoring |

### Visual Studio Authoring Extensions-only source

| Dimension | Assessment |
|---|---|
| Reviewability | Good for XML and fragments |
| Automation | Depends on a compatible Visual Studio and extension environment |
| Vendor lock-in | Moderate; tied to a specific development environment |
| Initial effort | Moderate; compatibility must be proven for the supported SCOM releases |

## Trade-off analysis

Tool-neutral XML requires more repository engineering, but it gives the clearest long-term contract
and supports independent review. Silect remains valuable for interactive authoring and the current
Management Pack Authoring Guide. Visual Studio Authoring Extensions and community fragment tooling
remain optional accelerators. Microsoft SDK verification and a real SCOM management group remain
mandatory because XML well-formedness alone cannot prove importability or runtime behavior.

## Consequences

- Every generated product artifact traces to a committed template or fragment.
- Build scripts must be PowerShell 7 and must not contain signing secrets.
- Development XML can be generated on a normal workstation, but it is not called sealed, signed,
  verified, or release-ready until the approved toolchain produces that evidence.
- Imported fragments are copied into this repository, attributed, reviewed, and adapted; the
  product never depends on a community fragment repository at runtime.
- The SCOM lab is the authority for dependency resolution, import, discovery, workflows, health,
  overrides, Distributed Applications, upgrade, and removal behavior.

## Acceptance gates

1. Static build tests prove deterministic output, IDs, versions, references, override separation,
   and the absence of prohibited runtime dependencies.
2. The approved authoring environment and exact Microsoft verification/sealing commands are
   documented and repeatable.
3. Test-sealed artifacts import in dependency order into every supported SCOM baseline.
4. Signing identities and secret retrieval follow the release-security decision without committing
   key material.

## References

- [What is in an Operations Manager Management Pack?](https://learn.microsoft.com/en-us/system-center/scom/manage-overview-management-pack?view=sc-om-2025)
- [Management Pack lifecycle](https://learn.microsoft.com/en-us/system-center/scom/manage-mp-lifecycle?view=sc-om-2025)
- [Silect Management Pack Authoring Guide](https://silect.com/downloads/Training/Management%20Pack%20Authoring%20Guide.pdf)
- [Kevin Holman Fragment Library](https://github.com/thekevinholman/FragmentLibrary)
- [Advanced cookdown Management Pack authoring](https://kevinholman.com/2024/01/13/advanced-cookdown-management-pack-authoring/)

## Related design

- [ADR 0027 — Hyper-V SCOM Management Pack decomposition](0027-hyper-v-scom-management-pack-decomposition.md)
- [Authoring standards](../hyper-v/authoring-standards.md)
- [Validation and release architecture](../hyper-v/validation-and-release.md)
