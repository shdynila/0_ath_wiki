---
title: "Architecture: Envoy Gateway JWT & RBAC"
date: 2026-06-14
draft: false
tags: ["networking", "grpc", "gateway", "cilium", "security", "jwt", "rbac"]
---

# Architecture Upgrade: Zero-Trust Envoy Proxy

The Chat Service has been significantly upgraded with a zero-trust, infrastructure-level security model powered by Keycloak and Envoy Proxy.

## Summary of Changes

### 1. Replaced Gateway API with `CiliumEnvoyConfig`
The generic Kubernetes Gateway API (`0ath-gateway`) has been replaced with a native `CiliumEnvoyConfig` resource. This allows us to inject powerful Envoy-specific HTTP filters directly into the proxy chain.

### 2. JWT Authentication
The proxy now validates Keycloak JSON Web Tokens (`jwt_authn`) for all gRPC connections, entirely offloading signature verification and Keycloak JWKS fetching from the backend microservices.

### 3. Envoy CEL-Based RBAC
We implemented the `envoy.filters.http.rbac` filter to evaluate Common Expression Language (CEL) rules against the validated JWT claims and custom gRPC HTTP headers (`x-channel-type` and `x-target-group`). 

This enforces strict channel authorization:
- **ALL:** Public access for anyone with a valid token.
- **SYSTEM:** Anyone can read, but only users with the `system_admin` Keycloak role can send messages.
- **GUILDS:** Evaluates the target group header against the `groups` array embedded in the JWT payload.

### 4. gRPC Timeout Fixes
We resolved the `upstream request timeout` that occurred every 60 seconds by explicitly disabling `idleTimeout` and `maxStreamDuration` in the Envoy listener options, allowing for stable, infinite-duration game network streams.
