---
title: "Decoupling Projectiles to a Scalable Combat Service"
date: 2026-06-15T20:11:00Z
tags: ["combat", "grpc", "postgres", "pubsub", "architecture"]
---

# Decoupling Projectiles to a Scalable Combat Service

To improve the architecture of `0_ath`, we've successfully moved the logic for rendering and syncing projectiles out of local client scope and into the highly scalable **Combat Server**.

## Implementation Details

### Protocol Buffers
- Kept `ProjectileSpawn` and `ProjectileEvent` message definitions.
- Removed the `service CombatService` gRPC definitions, as we are now using raw UDP/QUIC datagrams.

### Combat Server
- Connected the `0_ath_combat_server` to PostgreSQL to retain `pg_notify` for pod-to-pod synchronization.
- Swapped the transport layer from gRPC (TCP) to `quic-go` (UDP).
- The server listens on UDP port `1119` and broadcasts incoming projectile events as raw binary datagrams to all connected QUIC clients.

### Client Integration
- The client now opens a dedicated QUIC connection to the Combat Server (`combatQUICConn`) on port `1119`.
- Replaced the local `append(projectiles)` loop with a call to `combatQUICConn.SendDatagram()`.
- The client listens for datagrams on a separate goroutine and triggers `HandleRemoteProjectileSpawn` to render network projectiles.

> [!TIP]
> By migrating the Combat Server from gRPC to UDP/QUIC, we eliminate TCP head-of-line blocking while preserving strict microservice decoupling. Projectiles now fly over the network with the same speed and reliability as player movement!
