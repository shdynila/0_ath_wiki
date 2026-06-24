---
title: "The Dumb-Client Rendering Model"
date: 2026-06-18
tags: ["architecture", "client", "rendering", "ebiten"]
---

# Rendering Authoritative Snapshots

To prevent desynchronization and cheat-development in the `0_ath_client`, we utilize a strict "Dumb-Terminal" rendering model. The client performs absolutely zero physics simulation or hit detection.

## How It Works

1. **The Area of Interest (AOI) Datagram**
   Every 16 milliseconds (60 TPS), the `0_ath_zone_server` compiles an Area of Interest snapshot for every player. This snapshot contains a flat array of all Entity Coordinates and Projectile Coordinates within visual range of that specific player.

2. **Thread-Safe Handoff**
   The client receives these protobuf datagrams via a background QUIC networking goroutine. Upon receipt, the goroutine locks a `sync.RWMutex` and overwrites the global `LatestSnapshot` variable.

3. **Ebiten Render Loop**
   In the main thread, the Ebiten `Draw()` method fires up to 144 times a second. It briefly acquires a read-lock on the `LatestSnapshot` mutex, copies the pointer, and releases the lock. 
   It then iterates over the arrays in that snapshot, drawing shaders and sprites at the exact coordinates dictated by the server. 

If the server drops a packet or lags, the client simply continues drawing the previous snapshot's coordinates (appearing "frozen" until the next update), guaranteeing that the player never sees a false reality or "ghost hits".
