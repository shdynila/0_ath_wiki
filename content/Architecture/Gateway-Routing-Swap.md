---
title: "Gateway Routing Swap: Telemetry & Auth"
date: 2026-08-12
tags: ["architecture", "kubernetes", "networking", "gateway-api"]
---

# Gateway Routing Swap: Telemetry & Auth

To ensure secure and efficient access to our PocketBase instances, we have restructured our Cilium Gateway API HTTPRoutes.

## Architectural Changes

1. **Auth Server Isolation**: The primary game Auth PocketBase (`pocketbase`) no longer has a public HTTPRoute attached to the Gateway API. Since the game clients connect to Auth exclusively via a dedicated NodePort (`31117`) using gRPC, exposing the Auth PocketBase admin UI on the public internet was an unnecessary attack surface. The Auth admin UI is now accessible strictly via an SSH port forward to its ClusterIP service.
2. **Telemetry Server Public Access**: The Telemetry PocketBase (`telemetry-server`), which collects metrics and traces from our eBPF agents, has taken over the root IP space (`37.27.37.253`). This eliminates the need for wildcard `nip.io` domains and provides a clean, top-level URL for our observability data without path collisions.

## Usage

- **Telemetry Admin Panel**: Navigate directly to `http://37.27.37.253/_/`.
- **Auth Admin Panel**: Tunnel into the cluster (`ssh -L 8090:<Auth_Cluster_IP>:80 root@37.27.37.253`) and access via `http://localhost:8090/_/`.
