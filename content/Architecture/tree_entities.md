---
title: "Tree Entity Migration"
date: 2026-09-15
tags: ["architecture", "entities", "server", "client"]
---

# Tree Entity Migration

Trees in the game were previously generated entirely on the client side using procedural noise and rendered as `TileTree` in the `terrain.Generator`. While this was efficient, it prevented the server from interacting with trees or validating player movement against them.

## The Problem
Players could easily walk through trees because the server had no concept of them. To fix this, trees needed to be synchronized and validated by the server.

## The Solution
We migrated trees from static terrain tiles to dynamic entities (`entity.Player` instances on the server).

### 1. Server-Side Spawning
The server now queries the procedural foliage noise map (`navGrid.Terrain.GetFoliage()`) during initialization to spawn tree entities (e.g., `tree_123`) within the central playable area. These trees are inserted into the `SpatialGrid`.

### 2. Collision Validation
- **Server:** When the server processes a player's movement update (`UpdatePosition`), it queries the spatial grid for nearby entities (`GetEntitiesInRadius`). If the player intersects with a `tree_` entity, the movement update is rejected. This prevents cheating.
- **Client Prediction:** To keep the game feeling smooth, the client also performs collision checks locally. Within `CheckPlayerMovement()`, the client checks its intended movement against the `LatestSnapshot` of entities, blocking the player from walking into trees before sending the packet to the server.

### 3. Client Rendering
Trees are no longer drawn as part of the terrain tilemap. Instead, they are drawn in the `drawPlayers` loop when an entity ID begins with `tree_`. This ensures they respect Z-ordering properly with other entities.
