---
title: "Hetzner Cluster Bootstrapping & Client Connections"
date: 2026-07-27T21:44:00+02:00
tags: ["hetzner", "kubernetes", "k0s", "cli", "cloud-init", "cilium", "ebpf"]
---

# Hetzner Cluster Bootstrapping & Client Connections

This document describes the architecture, setup procedure, Cilium eBPF networking, and client connection workflow for running **0ath** microservices on **Hetzner Cloud**.

---

## Architecture Overview

1. **Host OS**: Debian / Ubuntu on Hetzner Cloud.
2. **Cluster Runtime**: Single-node **k0s** controller (`k0s install controller --single`).
3. **CNI / Networking**: **Cilium** (v1.15.5) with `kubeProxyReplacement: true` (eBPF host routing).
4. **Ingress & Gateway**: Kubernetes Gateway API CRDs (v1.1.0).
5. **Local Workstation Orchestration**: `0ath-cli` + **Skaffold** + **GitHub Container Registry (GHCR)**.

---

## Cilium eBPF Networking & Port Forwarding

Cilium replaces `kube-proxy` using eBPF programs loaded directly into the Linux kernel on the Hetzner host interface.

### Exposed NodePorts:
* **Auth Service** (`auth-service`): `NodePort 31117` (TCP)
* **Chat Service** (`chat-service`): `NodePort 31115` (TCP)
* **Zone Service** (`zone-service`): `NodePort 31118` (UDP - QUIC movement protocol)

Cilium's eBPF bypasses standard iptables packet translation, routing incoming UDP/TCP packets on ports `31115`, `31117`, and `31118` directly to pod network namespaces with sub-millisecond latency.

---

## Spawning a Remote Client

To launch the `0_ath` game client and connect directly to the microservices on Hetzner:

### Option A: Using `0ath-cli`
```bash
0ath client --remote 37.27.37.253
```

### Option B: Running directly with `go`
```bash
cd 0_ath_client
go run . -authAddr=http://37.27.37.253:31117 -movementAddr=37.27.37.253:31118 -serverAddr=37.27.37.253:31115
```

---

## 1-Click Setup & Fast Reproduction Workflow

### 1. Provision Cloud Server
Supply [hetzner-cloud-init.yaml](file:///c:/Users/nil/Desktop/prjcts/0ath_k0s/k0s/hetzner-cloud-init.yaml) as `user_data`.

### 2. Connect Local Environment
```bash
0ath cluster connect <SERVER_IP>
```

### 3. Deploy Applications
```bash
skaffold run --default-repo=ghcr.io/shdynila
```
