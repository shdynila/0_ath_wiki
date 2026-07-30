---
title: "CLI Registry Switch"
date: 2026-07-16T19:28:00+02:00
tags: ["cli", "infrastructure", "registry"]
---

# CLI Registry Switch

The `0ath` command-line tool has been updated to stop using the local ephemeral Docker registry (`localhost:5001/0ath-registry`) for local development and cluster deployments. 

## Workflow Split
- **`0ath dev`**: Uses a local Docker registry (`localhost:5001/0ath-registry`) for rapid, unauthenticated iteration. Does not consume WAN bandwidth.
- **`0ath publish`**: A dedicated command that invokes `skaffold build --default-repo=ghcr.io/shdynila`. This compiles all container images and pushes them directly to GitHub Packages, ready for production deployment.

## Implications
- **Authentication**: Local dev clusters (`k0s`) no longer require `imagePullSecrets` to function. 
- **Production Parity**: Deployment to the production server requires running `0ath publish` locally to push the latest layers, followed by `kubectl apply` on the remote cluster to fetch the tags from `ghcr.io`.
