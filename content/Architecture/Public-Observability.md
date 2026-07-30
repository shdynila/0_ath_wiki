---
title: "Public Observability Stack"
date: 2026-07-31
tags: ["observability", "grafana", "prometheus", "cilium", "gateway-api"]
---

# Public Observability Stack

The `0_ath` observability stack is publicly accessible without requiring VPNs or local port forwarding, allowing easy monitoring of the game servers.

## Architecture

1. **Cilium Gateway API**: We use the native Cilium Gateway API to expose HTTP routes. The `Gateway` requests an IP from the `CiliumLoadBalancerIPPool`.
2. **Prometheus**: Prometheus scrapes metrics from the OpenTelemetry Collector on port 8889. It currently runs statelessly (without PVCs) due to the lack of a default storage class.
3. **Grafana**: Grafana is exposed at `http://<public-ip>/grafana` via the `HTTPRoute`. It is provisioned using GitOps, utilizing a sidecar to dynamically load dashboards from Kubernetes `ConfigMap` resources labeled with `grafana_dashboard: "1"`.
4. **Dashboards**: The `0_ath_zone_server` emits metrics like `zone_tick_duration_ms` and active entity counts via OpenTelemetry, which are scraped by Prometheus and visualized in a dedicated Grafana dashboard managed through the infrastructure repo.
