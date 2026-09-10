---
title: "Procedural World Generation"
date: "2026-09-10"
tags: ["architecture", "world", "generation", "perlin", "noise"]
---

# Procedural World Generation

We have successfully transitioned the game from relying on finite, pre-rendered maps and static collision images to a fully infinite, procedurally generated world driven by Perlin noise.

## Architectural Changes

The world is now completely unbounded and deterministic. The client and server share a procedural seed so that they generate the exact same terrain everywhere without having to stream megabytes of map data over the network!

### 1. Shared Terrain Generation (`terrain` package)
We introduced `github.com/aquilax/go-perlin` to both the Client and Server and built a unified `terrain` generator.
- The generator uses two noise layers: **Elevation** and **Moisture**.
- These layers map values to biomes (TileTypes): `TileDeepWater`, `TileWater`, `TileSand`, `TileGrass`, `TileStone`, and `TileMountain`.

### 2. Infinite Walkability (Server)
- **File**: `nav/grid.go` and `main.go`
- **Changes**: We replaced the massive static boolean array with a dynamic lookup using the `terrain.Generator`.
- The A* pathfinder now clamps search distances rather than relying on grid bounds to prevent infinite loops when a path is blocked in an open world.

### 3. Dynamic Rendering & Movement (Client)
- **File**: `internal/client/game.go` and `internal/data/zone.go`
- **Changes**: 
  - We removed the old `wcollision_cloud.png` logic and the Cellular Automata `WaterGrid`.
  - We removed `drawWater(screen)` which used an Ebiten mask.
  - We introduced `drawTerrain(screen)` which dynamically computes the camera bounds and renders colored, tiled rectangles for every visible biome.

This new rendering loop only draws the exact tiles visible on the screen, meaning performance remains consistently high no matter how large the map becomes.
