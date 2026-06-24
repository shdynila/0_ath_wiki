---
title: "Spatial Partitioning & Swept-Sphere Collision"
date: 2026-06-18
tags: ["architecture", "backend", "go", "physics"]
---

# High Performance Server-Side Physics

To support large-scale battles in the `0_ath_zone_server` without CPU meltdown, we have implemented a high-performance Spatial Partitioning Grid combined with Swept-Sphere collision tests.

## Spatial Partitioning Grid
Instead of checking every projectile against every player (which is $O(N^2)$ complexity), the Zone Server divides the map into a 2D grid of 100x100 pixel buckets (`GridCell`).

### Lockless Concurrency
Because our player entities run as independent goroutines (the LEARS model), we cannot use a global mutex on the grid. Instead, each `GridCell` contains its own `sync.RWMutex`. This means a player walking in the northern part of the map will never lock or block a player moving in the southern part.

### Voxel Traversal
When a projectile moves, we use a Digital Differential Analyzer (DDA) algorithm to trace its path through the grid. The server instantly knows which buckets the projectile's line-segment crosses, narrowing the collision candidates down from 100 players to just 1 or 2.

## Swept-Sphere Anti-Tunneling
Projectiles in our engine can move incredibly fast. If we simply checked if an arrow overlapped a player at the end of a server tick, it could easily "tunnel" straight through them between ticks.

Instead, the `BatchProcessor` performs a **Line-to-Circle Intersection Test**. We draw a line segment from the projectile's Old Position to its New Position, and mathematically project the target player's position onto that segment. If the distance from the player to the closest point on that line is less than the combined radii, a hit is registered.

This guarantees perfect collision accuracy regardless of server tick rate or projectile speed!
