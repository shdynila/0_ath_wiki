---
title: "GitOps Architecture with FluxCD"
date: 2026-07-16T20:45:00+02:00
tags: ["infrastructure", "gitops", "fluxcd"]
---

# FluxCD GitOps Pipeline

To fully automate the deployment of the `0_ath_manifests` repository to the production Hetzner server, we have adopted a native GitOps architecture powered by **FluxCD**.

## Why FluxCD?
Unlike ArgoCD, Flux is extremely lightweight (headless, no UI by default) which is critical for conserving resources on a single-node indie game server. More importantly, Flux offers native, first-class support for **SOPS** decryption, whereas ArgoCD requires fragile third-party plugins.

## Configuration Structure
Flux is configured via the `clusters/hetzner` directory in the `0_ath_manifests` repository.

1. **`infrastructure.yaml`**: A Flux Kustomization that syncs the `infrastructure/` directory (Postgres, Gateway, Keycloak, Cilium).
2. **`services.yaml`**: A Flux Kustomization that syncs the `services/` directory (Auth, Chat, Social, Zone, Data). 
   - This explicitly depends on `infrastructure` to ensure databases and networking are ready first.
   - It is configured with `decryption: provider: sops; secretRef: sops-age` to automatically unlock encrypted secrets on the fly.

## Multi-Repository Strategy

As the architecture scales, we have adopted a multi-repository approach to isolate different operational lifecycles:

1. **`0_ath_manifests`**: Contains the core infrastructure (databases, networking) and game services (Zone, Social, Auth).
2. **`0_ath_o11y`**: A dedicated repository for observability configurations (Grafana dashboards, Prometheus rules). This isolates monitoring tweaks from core game deployments, meaning a simple dashboard update cannot accidentally trigger a redeployment of game servers.

Flux in the Hetzner cluster is configured to pull and sync from both repositories simultaneously, using `dependsOn` to guarantee that the core `infrastructure` is ready before attempting to provision `o11y` dashboards.

## Separation of Concerns
- **Local Dev**: Remains managed by `0ath dev` (Skaffold) and `localhost:5001`. Flux is **not** installed locally to prevent it from continuously pulling the `main` branch and overwriting local iteration.
- **Production**: Entirely managed by Flux pulling autonomously from GitHub. The `0ath deploy` command is essentially retired for production use.
