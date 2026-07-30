---
title: "ADR-001: Choosing CachyOS for the k0s Cluster"
date: 2026-06-27
tags: ['adr', 'architecture', 'infrastructure', 'cachyos']
draft: false
---

# Architecture Decision Record: CachyOS for Cluster Host

> [!WARNING]
> **DEPRECATED:** This ADR is superseded by [ADR-002: Choosing NixOS for the MMO Cluster](ADR-002-NixOS-Cluster.md).

## TL;DR
We have decided to use **CachyOS** as the host operating system for our bare-metal `k0s` Kubernetes cluster instead of standard server distributions like Debian or Ubuntu, prioritizing raw compute performance and modern network stack features over conservative stability.

## Context
As we migrate the `0_ath` microservices (Auth, Chat, Zone, Movement) into a `k0s` cluster, we need to decide on the underlying host Operating System for our physical nodes. The microservices are written in Go (compiled to static binaries) and deployed via Docker/containerd. The movement server specifically relies on high-tick UDP streaming, requiring the lowest possible latency and overhead.

We evaluated running a Linux VM inside Windows vs formatting to bare-metal Linux, and chose bare-metal for maximum NIC access and hardware utilization. 
We then evaluated distributions:
1. **Ubuntu/Debian**: Industry standard, highest stability, excellent container support.
2. **Alpine**: Lightweight, secure.
3. **Arch Linux / CachyOS**: Rolling release, bleeding edge, highly optimized.

## Decision
We selected **CachyOS** as the host OS. 

**Reasons:**
- **Aggressive Optimizations**: CachyOS compiles its packages with `x86-64-v3/v4` instruction sets and uses custom CPU schedulers (like BORE). This provides a measurable baseline performance increase for our Go binaries and database operations running in containers.
- **Bleeding Edge Kernel**: The newest Linux kernels provide the latest networking stack improvements (e.g., eBPF, Cilium enhancements), which directly benefits our high-tick UDP movement server.

## Consequences

**Positive:**
- Maximum theoretical compute performance for physics calculations and entity state management.
- Lowest possible networking latency due to the latest kernel and unvirtualized NIC access.

**Negative:**
- **Maintenance Overhead**: CachyOS is a rolling release. System updates (`pacman -Syu`) carry an inherent risk of breaking the system or container runtime.
- **Mitigation Strategy**: We will implement strict GitOps practices and avoid updating the host OS automatically. Updates will be applied during scheduled maintenance windows, and the cluster must be designed to tolerate node reboots.
