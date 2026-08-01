---
title: "Observability Stack Migration & OOM Rescue"
date: 2026-08-01
tags: ["kubernetes", "observability", "infrastructure", "postmortem"]
---

# Observability Stack Migration

## The Problem
The original observability stack consisted of Prometheus, Loki, Grafana, Promtail, and Kube-State-Metrics. This was an extremely heavy deployment for a single-node cluster with a strict 4GB RAM limitation. The high memory consumption caused the node's control plane to experience severe Out-of-Memory (OOM) deadlocks, crashing the Kubernetes API server and preventing Flux CD from successfully syncing.

## The Solution
We migrated from the heavy Prometheus/Loki stack to a much more lightweight, open-source stack tailored for constrained environments:

- **Netdata:** Replaces Prometheus and Grafana for real-time node and container metrics with a significantly smaller memory footprint.
- **VictoriaLogs & Vector:** Replaces Loki and Promtail. VictoriaLogs offers incredible compression and low memory usage, while Vector acts as an ultra-fast, lightweight log router.
- **Jaeger (Badger backend):** Used for distributed tracing in memory, avoiding heavy Cassandra or Elasticsearch dependencies.

All traffic for monitoring was re-routed through the NGINX gateway to `/netdata` and `/jaeger`.

## Postmortem: Cluster Rescue
Because the cluster was in an OOM deadlock during the migration, Flux was unable to pull the Git commits to gracefully remove the old stack. 
The following rescue steps were taken:
1. Hard rebooted the node to flush all memory.
2. Force-deleted the orphaned `logging-stack` pods and deployments while the API server had breathing room.
3. **Cilium Deadlock:** The hard reboot caused the Cilium CNI to lose routing to the API server's service IP (`10.96.0.1`), trapping it in `Init:0/6` and preventing pod scheduling. This was resolved by patching the Cilium DaemonSet to explicitly use the Host IP (`37.27.37.253`) for `KUBERNETES_SERVICE_HOST`, allowing the eBPF maps to build and the cluster to recover.
