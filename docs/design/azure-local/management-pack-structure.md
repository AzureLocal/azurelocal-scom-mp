---
title: Azure Local Management Pack structure
description: Projects, dependencies, release forms, and customer customization boundaries.
---

# Azure Local Management Pack structure

![Azure Local package graph](/assets/diagrams/azure-local-scom-packages.svg)

| Project | Depends on | Public contract |
|---|---|---|
| Library | Microsoft System, Windows, and Service Designer libraries | 17 classes and 28 relationships |
| Discovery | Library and Microsoft Windows library | Role seed, topology, DA root/components, dynamic membership |
| Monitoring | Library plus Microsoft health, performance, SCOM, and data-warehouse libraries | 14 unit monitors, six domain aggregates, 12 DA dependencies, 12 performance rules, four event rules, one task |
| Presentation | Library and Monitoring | Four folders and 14 operator views |
| Reporting | Library and Monitoring | Optional release boundary reserved for certified reports and SLO content |

## Override ownership

Each customer generates and owns:

- a Discovery Overrides MP for discovery interval, enablement, and scope; and
- a Monitoring Overrides MP for thresholds, intervals, alert enablement, severity, and collection.

The Lab, Standard, and Strict profiles are reviewed starting points. They are not automatically
imported and do not replace measured customer policy.

## Release dependency gate

The product references standard sealed SCOM libraries by ID and public key. Exact dependency
versions are validated from official MPs exported from every target SCOM management group. A
development build can be structurally correct before those dependency files are available, but it
cannot be called SDK-verified, sealed, signed, or lab-certified.
