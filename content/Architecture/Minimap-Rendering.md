---
title: "Client Architecture: Minimap Rendering"
date: 2026-07-28T18:50:00+02:00
weight: 15
---

# Minimap Rendering Architecture

The `0_ath_client` utilizes a high-performance minimap system to represent the procedural world and its entities to the user.

## Static Caching
The world geometry (`zone.WaterGrid`) can be thousands of tiles large. Iterating and drawing shapes for each tile every frame would cause significant GPU bottlenecking. Instead, the minimap leverages Ebitengine's off-screen rendering capabilities:
1. `generateMinimap()` is called exactly once during the `graphicsInit` phase.
2. It paints the map's terrain topology (water and land) pixel-by-pixel into a cached `*ebiten.Image`.
3. The renderer draws this single cached image, offloading the terrain cost entirely.

## Dynamic Overlay
While the map texture is static, the entity data is highly dynamic. 
During `drawMinimap()`, the minimap overlays the active snapshot entities (`LatestSnapshot.Entities`).
We calculate a ratio scale `minimapSize / WorldGridSize` to map the raw spatial coordinates of characters `(0 - 10,000)` down to the local pixel space of the minimap box `(0 - 150)`.
