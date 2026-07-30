---
title: "ADR-002: Choosing NixOS for the MMO Cluster"
date: 2026-06-28
tags: ['adr', 'architecture', 'infrastructure', 'nixos']
draft: false
---

# Architecture Decision Record: NixOS for Cluster Host

## TL;DR
We have decided to migrate our hosting infrastructure from **CachyOS** to **NixOS** for our MMO backend services. This decision prioritizes declarative configuration, reproducibility, and atomic rollbacks over the raw compute optimizations that CachyOS provided.

## Context
Previously (see [ADR-001](ADR-001-CachyOS-Cluster.md)), we opted for CachyOS to squeeze maximum performance out of our physical nodes for the high-tick UDP Movement server and other Go microservices. However, running a rolling-release Arch-based distribution in a production cluster introduced significant maintenance overhead and risk of system breakage during updates (`pacman -Syu`).

As the infrastructure scales, the need to easily replicate node configurations and recover instantly from bad updates has become more critical than marginal compute gains.

## Decision
We are adopting **NixOS** as the host operating system for our nodes.

**Reasons:**
- **Declarative Infrastructure:** The entire OS state, from installed packages to running services, is defined in Nix files. This allows us to track infrastructure changes in version control alongside application code.
- **Reproducibility:** A NixOS configuration guarantees that scaling up from 1 to 10 nodes results in identical environments down to the binary level, eliminating configuration drift.
- **Atomic Rollbacks:** If an OS update or a service deployment fails, we can instantly rollback to the previous generation via the bootloader or command line, ensuring near-zero downtime from infrastructure failures.
- **Dev/Prod Parity:** Developers can use Nix flakes to replicate the exact production environment locally.

## Consequences

**Positive:**
- Extremely reliable node updates and rollbacks.
- Simplified horizontal scaling (new nodes just pull the Nix configuration).
- Infrastructure is fully documented as code.

**Negative:**
- **Learning Curve:** The Nix ecosystem and language can be complex and steep to learn.
- **Packaging:** We may need to write custom derivations (packages) if any third-party dependencies are missing from the `nixpkgs` repository.
- **Performance Trade-off:** We may lose the specific `-march=x86-64-v3/v4` baseline optimizations out of the box, although NixOS can be configured to build optimized packages if required.
