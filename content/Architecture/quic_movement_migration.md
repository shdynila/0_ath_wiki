---
title: "QUIC Movement Server Migration"
date: 2026-06-14T12:00:00Z
tags: ["architecture", "networking", "quic", "movement-server"]
---

# QUIC Movement Server Migration

## Background

The `0_ath_movement_server` is responsible for handling high-frequency positional updates between players and propagating FOV (Field of View) datagrams. Previously, it utilized raw UDP sockets via `github.com/panjf2000/gnet`. While this provided excellent performance, it lacked native encryption and reliability mechanics. 

To future-proof the movement layer, we have migrated the entire movement server and client to use **QUIC** (specifically via the `quic-go` library).

## Architectural Changes

### 1. QUIC Protocol Adopton
QUIC brings several advantages out-of-the-box:
- **TLS 1.3 Encryption**: All traffic is inherently encrypted.
- **Congestion Control**: Native adaptation to network conditions.
- **Connection Migration**: Clients IP changes (e.g., switching from WiFi to Cellular) do not break the connection.

### 2. Unreliable Datagrams (RFC 9221)
Because movement data updates are highly ephemeral (the next positional update renders the previous one obsolete), using a reliable stream would introduce **Head-of-Line (HoL) Blocking**, stalling game ticks if a single packet is dropped. To maintain the performance of UDP over QUIC, we implemented **QUIC Datagrams** (`EnableDatagrams: true`). This encapsulates unreliable datagrams within the encrypted QUIC connection.

### 3. Bypassing the Envoy Gateway
For maximum performance and minimum latency, the movement server connection bypasses the central Envoy Gateway proxy. The client dials directly into the `movement-service` LoadBalancer on port `1118`.

## Implementation Details

- **Server-Side TLS**: Since TLS is mandatory for QUIC, the movement server automatically generates an ephemeral, self-signed ECDSA certificate in-memory at boot time.
- **Client-Side Validation**: The client establishes the connection using `InsecureSkipVerify: true` during local development to seamlessly accept the server's ephemeral certificate.
- **Connection Handling**: The architecture has shifted from `gnet`'s event loop to `quic-go`'s goroutine-per-connection model. Each connected client has an active goroutine polling `conn.ReceiveDatagram()`.
