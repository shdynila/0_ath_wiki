---
title: "Zero-Trust Cluster Security and Gateway API"
date: 2026-08-12
tags: ["kubernetes", "security", "cilium", "gateway-api"]
---

# Zero-Trust Cluster Security

To secure the bare-metal k0s Hetzner cluster, we have implemented a zero-trust architecture for internal observability and telemetry services.

## Changes Implemented

1. **Removed Public HostPorts:** We removed raw `hostPort` exposures for internal services like the PocketBase telemetry admin UI.
2. **Gateway API Routing:** All public HTTP traffic (such as PocketBase and Netdata) is now securely routed through the Cilium Gateway API Envoy proxy.
3. **Restricted gRPC:** Internal gRPC ports (like the telemetry metrics ingest) that lack authentication are restricted to the local machine (`127.0.0.1`) to prevent external abuse while allowing local eBPF agents to communicate.
4. **Network Policies:** We implemented default-deny `NetworkPolicies` for the `o11y` namespace, ensuring that services can only be accessed if they explicitly allow traffic from the Gateway API.

This setup prevents malicious actors from bypassing the Gateway to hit unprotected services directly on the host's public IP.
