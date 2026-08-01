---
title: "k0s Multi-Node Cluster Architecture"
date: 2026-06-26
tags: ["kubernetes", "architecture", "k0s", "cilium", "self-hosting"]
---

# `0_ath` Multi-Node Kubernetes Architecture

As the `0_ath` MMO infrastructure matures, we are migrating from a local `k3d` development environment to a live, self-hosted `k0s` multi-node cluster. This architecture utilizes native Linux hosts to maximize performance and distribute workloads.

## Node Topology

The cluster spans across x86_64 and ARM64 hardware:

1. **Node 1: Main PC (Control Plane + Worker - x86_64)**
   - Serves as the brain of the cluster (API server, etcd).
   - **Workloads:** Heavy stateful applications requiring fast disk I/O and CPU, such as `0_ath_data_server`, the `PostgreSQL` master database (via Local Persistent Volumes), and `0_ath_movement_server`.
2. **Node 2: Laptop (Worker - x86_64)**
   - Acts as a scalable compute node.
   - **Workloads:** Stateless mesh microservices like `0_ath_auth_server`, Chat, Social, and Combat.
3. **Node 3: Raspberry Pi (Worker - ARM64)**
   - Acts as a lightweight edge node.
   - **Workloads:** Runs the asynchronous Go `0_ath_gateway` and telemetry agents.

## Multi-Architecture Builds

To support the Raspberry Pi, all Go backend services are built using **`ko`**. 
`ko` natively cross-compiles Go binaries and builds multi-arch OCI images (e.g., `linux/amd64` and `linux/arm64`) without the need for complex Dockerfiles or QEMU emulators.

## Networking via eBPF (Cilium)

We disabled the default Kube-Router CNI in favor of **Cilium**.
- **Performance:** Cilium leverages eBPF (Extended Berkeley Packet Filter) to bypass traditional `iptables`. This drastically reduces CPU overhead and network latency, which is critical for our high-tickrate UDP movement server.
- **Load Balancing:** Cilium natively supports Layer 2 IP Announcements, assigning a local DHCP IP address (e.g., `192.168.1.100`) directly to the `0_ath_gateway` LoadBalancer service on our home network.

## Public Access

For our initial testing phase with friends, we utilize **Direct Port Forwarding**. 
TCP `8080` (Actions/Auth) and UDP `8081` (Movement) are forwarded directly from the home router to the Gateway's LoadBalancer IP. While this exposes the home IP, it guarantees the absolute lowest latency by removing any VPN or proxy overhead.

## CLI Automation

The `0ath-cli` has been updated to fully automate this setup once the machines are formatted to Linux.
By running:
```bash
0ath cluster create --multi-node
```
The CLI will automatically download `k0sctl`, generate a template `k0sctl.yaml` for you to fill out with your node IP addresses, and bootstrap the entire multi-node cluster across SSH.
