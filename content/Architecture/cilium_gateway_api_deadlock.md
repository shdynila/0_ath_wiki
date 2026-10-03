---
title: "Fixing the Cilium Gateway API Deadlock on Hetzner"
date: 2026-10-03
tags: ["cilium", "kubernetes", "networking", "debugging", "ebpf"]
---

# Fixing the Cilium Gateway API Deadlock on Hetzner

## The Problem
For 19 days, the core `cilium-agent` pod in our `k0s` cluster was stuck in a continuous crash-loop (`CrashLoopBackOff`), terminating exactly every 3 minutes. This prevented the Gateway API from ever successfully provisioning the `public-gateway`, and caused the `hubble-relay` pod to remain in a pending/crashing state due to node taints.

## Root Cause Analysis
By inspecting the `cilium-agent` and `cilium-envoy` logs, we discovered two overlapping issues:
1. **Envoy xDS Socket Stale State**: The `cilium-envoy` pod was running continuously for 19 days, but the `cilium-agent` kept crashing. Every time the agent restarted, it recreated the `/var/run/cilium/envoy/sockets/xds.sock` Unix Domain Socket. Envoy was attempting to connect to a stale file descriptor, resulting in continuous `Connection refused` errors.
2. **Startup Probe Timeout**: The `cilium-agent` has a `startupProbe` configured to fail after 210 seconds (3.5 minutes). Compiling complex Envoy L7 BPF maps on a constrained Hetzner node occasionally took longer than this, causing Kubernetes to falsely identify the agent as dead and kill it mid-initialization. This caused the agent to deadlock while waiting for the Envoy stream ACK.

## The Solution
1. **Socket Purge**: We forcefully deleted both the `cilium-agent` and `cilium-envoy` DaemonSet pods simultaneously, forcing them to initialize cleanly and establish a fresh xDS Unix socket handshake.
2. **Probe Relaxation**: We patched the `cilium` DaemonSet to increase the `startupProbe`'s `failureThreshold` from `105` to `500`. This provides the agent up to 16 minutes to compile its BPF maps and synchronize with Envoy without being prematurely terminated by the kubelet.
3. **HTTPRoute Provisioning**: We created an `auth-route` HTTPRoute to explicitly route `/` traffic from the `public-gateway` to the `auth-service` on port `1117`, officially replacing the raw NodePort implementation.

## Outcome
The `cilium-agent` successfully passed its startup probes, untainted the cluster, and allowed Hubble to boot. We now have a fully functioning, eBPF-native Gateway API handling HTTP traffic securely.
