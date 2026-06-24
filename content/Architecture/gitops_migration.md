---
title: "GitOps Migration & State Centralization"
date: 2026-06-14T03:01:00+02:00
tags: ["gitops", "kubernetes", "architecture", "argocd", "skaffold"]
---

# GitOps Migration Walkthrough

The Kubernetes manifests and cluster state have been completely decoupled from the local `0ath_k0s` bootstrapper and moved into an enterprise-grade GitOps State Repository. 

## What Was Done

1. **State Repository Creation**: A new Git repository `0_ath_manifests` was initialized.
2. **Manifest Migration**: 
   - All `0ath_k0s/k8s/` files were transferred to `0_ath_manifests/`.
   - The standalone Keycloak YAML in `configuration/` was also centralized into `0_ath_manifests/infrastructure/keycloak.yaml`.
3. **CLI Refactoring**: 
   - The `0ath-cli` orchestrator was reprogrammed to target the new repository for all `apply` and `delete` commands.
   - `skaffold.yaml` was updated to watch the new `0_ath_manifests/services/` folder for local hot-reloading.
4. **ArgoCD Preparation**: A base `application.yaml` was created inside an `argocd/` folder, ready to sync the `services/` folder automatically when deployed to a remote cluster.

## Why This Matters
The architecture is now perfectly aligned with standard cloud-native engineering practices. 

- **Local Dev Loop**: `0ath-cli` + Skaffold watch the `0_ath_manifests` locally and update the cluster instantly without polluting Git history.
- **Production CI/CD**: ArgoCD will watch the remote Git history of `0_ath_manifests` and deploy any changes merged into the main branch. 

Both pipelines now share the exact same source of truth, completely eliminating configuration drift between environments.
