---
title: "ADR: HTTP Ingress Routing (Cilium Gateway API vs NGINX)"
date: 2026-10-03
tags: ["architecture", "kubernetes", "networking", "security"]
---

# Architecture Decision Record: HTTP Ingress Routing

## Context
Our MMORPG relies on a lightweight UDP/QUIC protocol for real-time game state, but we also run an Auth Server for login and registration over HTTP. Currently, the Auth Server is exposed via a raw Kubernetes `NodePort`. 

While NodePort works for early development, it is unsuitable for production because:
1. It lacks TLS (HTTPS) termination, transmitting player credentials in plaintext.
2. It lacks rate-limiting and DDoS protection (WAF).
3. It forces the use of non-standard ports (30000+), which are often blocked by corporate/university firewalls.

We need a secure L7 routing solution. Our cluster runs **Cilium** as the CNI, which natively supports the modern Kubernetes **Gateway API** (powered by Envoy). However, enabling the Gateway API caused the core `cilium-agent` to deadlock during xDS Envoy synchronization on our Hetzner node, leading to a cluster-wide crash-loop.

## Options Considered

### Option 1: Fix and Setup Cilium Gateway API
Deep-dive into the `cilium-agent` xDS deadlock, patch the node constraints, and fully utilize Cilium's native Gateway API.
* **Pros:** 
  * Keeps the tech stack unified (Cilium handles both L3/L4 eBPF and L7 Gateway routing).
  * Uses the modern Kubernetes standard (`Gateway` and `HTTPRoute` CRDs).
  * Highly performant when properly tuned.
* **Cons:** 
  * Requires debugging a complex deadlock between Envoy and Cilium on Hetzner.
  * Envoy can be memory-heavy on constrained single-node clusters.

### Option 2: Install NGINX Ingress Controller
Keep Cilium's Gateway API disabled (to guarantee CNI stability) and install the industry-standard NGINX Ingress Controller strictly for HTTP traffic.
* **Pros:** 
  * Extremely lightweight and battle-tested.
  * Isolated from the CNI (if NGINX crashes, cluster networking survives).
  * Deploys instantly without kernel/eBPF deadlocks.
* **Cons:** 
  * Adds an additional architectural component to manage.
  * Relies on the older `Ingress` API standard (though transitioning to Gateway API is possible).

## Decision
**We will pursue Option 1: Fix and Setup Cilium Gateway API.**

While Option 2 is an easy escape hatch, unifying our network stack under Cilium provides the best long-term scalability and leverages the modern Kubernetes Gateway API standard. We will investigate the Envoy xDS deadlock (likely caused by memory constraints or MTU misconfigurations on Hetzner) and properly provision the `public-gateway`.
