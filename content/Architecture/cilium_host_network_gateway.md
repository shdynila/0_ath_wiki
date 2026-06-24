---
title: "Architecture: Cilium hostNetwork Gateway Mode"
date: 2026-06-14
draft: false
tags: ["networking", "gateway", "cilium", "hostnetwork"]
---

# Cilium Gateway API hostNetwork Mode

To support local single-node development clusters (e.g., k0s running inside Docker) where a physical cloud LoadBalancer provider is not available, we configured Cilium's Gateway API to run in **hostNetwork mode**.

## The Problem
By default, the Cilium Gateway controller provisions a Kubernetes Service of type `LoadBalancer`. In local k0s/Docker environments, this service remains in a `<pending>` EXTERNAL-IP status indefinitely. Because the address is not resolved, the Cilium operator cannot program the Envoy Gateway, leading to:
- `Address is not ready` errors in the Gateway resource status.
- Inability to bind or route TCP/UDP connections.
- Failure of automatic/manual port forwarding.

Additionally, `kubectl port-forward` does not support forwarding UDP traffic, making direct connection forwarding to the UDP-based `movement-service` (port 1118) impossible.

## The Solution: hostNetwork Mode
By configuring the Cilium Helm values to enable hostNetwork mode for the Gateway API, Envoy binds directly to the ports of the cluster host node (which is the Docker container):

```yaml
gatewayAPI:
  enabled: true
  hostNetwork:
    enabled: true
```

### Traffic Flow & Routing Architecture

1. **Docker Port Mapping**: The `0ath-cluster` container is run with `-p 1111-1120:1111-1120` and `-p 1111-1120:1111-1120/udp` to publish host ports directly.
2. **Envoy Binding & Ingress IP**: Cilium allocates an ingress IP (e.g., `10.0.0.182`) from the pod network for the shared Envoy proxy.
3. **Loopback Routing Automation**: When backend pods respond to Envoy, the replies are sent to the proxy's ingress IP (`10.0.0.182`). Because this IP is not bound on the host namespace, the Linux kernel would normally forward it back out of the `cilium_host` interface, causing a loop and timeout. To fix this, `0ath-cli` automatically queries the ingress IP from the `CiliumNode` resource (`spec.ingress.ipv4`) and binds it to the container's loopback (`lo`) interface inside `0ath-cluster`.
4. **TCP Service Proxies**: In local Docker setups, socket connections from mapped host ports arrive at the container's main IP. Since Cilium's eBPF only intercepts traffic destined for the Gateway Service ClusterIP/ExternalIP, `0ath-cli` starts `socat` TCP listeners on ports `1111` and `1113` inside the container that proxy connections to the Gateway's ClusterIP. Cilium then intercepts these proxied connections and routes them to Envoy.
5. **UDP Movement Proxy**: Cilium does not support mixing HTTPRoute and UDPRoute on the same gateway instance under some k0s network modes. We bypass this by running a `socat` proxy on UDP port `1112` inside the container that forwards directly to the `movement-service` ClusterIP.
6. **Detailed Validation Error Propagation**: Keycloak validation error payloads (returned as JSON by the Admin API) are parsed by the `0_ath_core_server` signup endpoint. Specific validation messages (like short usernames or duplicate registration checks) are extracted and converted into clear, friendly plaintext strings (e.g. `"username length must be between 3 and 255 characters"`) which are propagated back to the client using appropriate HTTP status codes (e.g. 400 Bad Request, 409 Conflict). The client displays these messages directly in the login GUI support text.

### Client Access Ports
- `localhost:1111` (Unified Gateway gRPC TCP) -> Routes to `chat-service`, `social-service`, or `core-service` based on gRPC service name.
- `localhost:1113` (Unified Gateway HTTP TCP) -> Routes `/signup` requests to `core-service` signup server.
- `127.0.0.1:1112` (UDP Movement) -> Proxied directly to `movement-service` port `1118`.
- `127.0.0.1:8080` (Keycloak HTTP) -> Port-forwarded directly via Skaffold.
- `127.0.0.1:5432` (Postgres TCP) -> Port-forwarded directly via Skaffold.
