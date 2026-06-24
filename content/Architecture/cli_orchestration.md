---
title: "CLI Cluster Deployment Orchestration"
date: 2026-06-14T02:48:00+02:00
tags: ["cli", "kubernetes", "architecture", "skaffold", "k0s"]
---

# Cluster Deployment Orchestration

The `0ath-cli` now orchestrates cluster startup using a deterministic, staged rollout. This prevents Skaffold from racing against Docker image downloads, completely eliminating timeout failures and confusing pending states on fresh clusters.

## The Problem
When a cluster is reset via `0ath dev reset --hard`, Docker must pull gigabytes of images (`quay.io/cilium`, `postgres`, `keycloak`). While this was happening, Skaffold would blindly attempt to deploy microservices and port-forward to a Gateway LoadBalancer that hadn't been provisioned yet, resulting in timeout crashes.

## The Solution

We reorganized the raw YAML manifests into strict `infrastructure/` and `services/` layers and programmed `0ath-cli` to coordinate the deployment.

### Stage 1: Network Bootstrapping
The CLI explicitly waits for the `cilium` DaemonSet to become `Ready`.
```powershell
kubectl wait --for=condition=Ready pod -l k8s-app=cilium -n kube-system --timeout=15m
```

### Stage 2: Core Infrastructure
The CLI applies `0ath_k0s/k8s/infrastructure/` (Postgres, Gateway API objects) and Keycloak, then blocks until the databases are actively running.
```powershell
kubectl wait --for=condition=Ready pod -l app=postgres --timeout=15m
kubectl wait --for=condition=Ready pod -l app=keycloak --timeout=15m
```

### Stage 3: Microservices
Finally, the CLI triggers `skaffold dev`, which now ignores infrastructure components and only focuses on hot-reloading the Go microservices in `0ath_k0s/k8s/services/`.

## The New `reset` CLI
`reset` is now a dedicated subcommand of `dev`, supporting tiers:
- `0ath dev reset`: **Soft Reset**. Deletes ONLY the `0_ath` microservices (deployments, pods, services) to rapidly wipe server state while leaving Postgres, Keycloak, and Docker caches intact.
- `0ath dev reset --hard`: **Hard Reset**. Completely shreds the underlying `0ath-cluster` k0s Docker container, volume, and registry, forcing a total rebuild.
