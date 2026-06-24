---
title: "0ath Zone Server"
date: 2026-06-18
tags: ["architecture", "backend", "go", "networking"]
---

# 0ath Zone Server (Functional Monolith)

The `0_ath_zone_server` represents a major architectural shift from our previous microservices approach. Instead of synchronizing state across `Core`, `Movement`, and `Combat` over a network boundary, we have collapsed them into a single, highly concurrent application.

## Core Architectural Pillars

### 1. LEARS Model (Concurrency)
Lockless, Relaxed-Atomicity State (LEARS). 
- We do not use `sync.Mutex` for game entities.
- Each Player and AI is an independent goroutine.
- State updates (e.g., applying damage, updating position) are passed via Go `chan`s to be processed safely by the entity's own loop.

### 2. Component-Based Projectiles
To combat the "Rainbow Vomit" of inheritance, projectiles are composed of components:
- `MovementTracker`
- `Collider`
- `Visibility`

We utilize **Object Pooling** to reuse projectiles, achieving zero allocations during high-intensity firefights.

### 3. Data-Oriented Multitracing
Projectile arrays are processed in batches. We evaluate `new_pos = old_pos + (vel * dt)` over flat slices, drastically improving cache locality and performance compared to pointer-heavy OOP designs.

### 4. Time Warp (Latency Compensation)
The server maintains a 120-tick **History Buffer** of all hitboxes. 
When a client sends a firing datagram, the server extracts the timestamp, rewinds the hitboxes of the relevant targets, evaluates the raycast, and then rolls the simulation forward—all while preventing "shot around the corner" exploits with a hard rewind limit.

### 5. QUIC Networking
We have shifted from gRPC/TCP to `quic-go`:
- **Unreliable Datagrams**: High-frequency movement and combat events.
- **Multiplexed Streams**: Heavy data transfer, RPCs, and Shaders.
- **Area of Interest (AOI)**: The server compiles an authoritative tick snapshot, filters it based on proximity, and broadcasts the unified state to clients.
