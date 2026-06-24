---
title: "Wiring QUIC Networking to LEARS"
date: 2026-06-19
tags: ["architecture", "server", "lears", "networking"]
---

# Routing Client Input via LEARS

To uphold the **Lockless, Relaxed-Atomicity State (LEARS)** model, the `0_ath_zone_server` strictly separates its QUIC networking layer from its main simulation thread. 

## The Concurrency Problem
If the networking layer directly locked the `BatchProcessor` or the Spatial Partitioning Grid to insert a projectile or update a player's coordinates, it would stall the 60 TPS simulation loop. Global mutexes (`sync.Mutex`) are prohibited in the core simulation components for this reason.

## The Solution: Inbox Channels

Instead of locks, we use highly buffered Go Channels (Inboxes) to facilitate lock-free state mutation.

### 1. Player Movement
When the background `QuicServer` receives a `ZoneDatagram_Input` with `SkillId = 0` (movement), it does not modify the player's `X` and `Y` properties directly. Instead, it pushes an `entity.UpdatePosition` struct into the player's personal `Inbox` channel. 
The player's independent Goroutine (`p.Run()`) reads from this channel and mutates its own state, completely independently of the global simulation.

### 2. Projectile Spawning
When the `QuicServer` receives a `ZoneDatagram_Input` for a spell cast (e.g., `SkillId = 1`), it constructs a raw `Projectile` struct and pushes it into the `BatchProcessor.Inbox` channel. 
At the beginning of every 16ms tick (`Tick(dt)`), the `BatchProcessor` drains this channel, copying all pending projectiles into its highly contiguous, cache-friendly array before executing its swept-sphere collision physics.

### 3. Broadcasting Snapshots
Once the `BatchProcessor` finishes simulating the tick, the main thread pulls the list of active clients from `QuicServer.GetConnections()`. It utilizes the `Area of Interest (AOI)` module to build a custom snapshot for each client, packaging all visible players and active projectiles into a `ZoneSnapshot` protobuf, which is then broadcasted back over the reliable QUIC streams.
