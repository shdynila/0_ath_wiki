---
title: "2D Ground Rendering using Lightmaps"
date: 2026-09-07T18:14:00+02:00
tags: ["Architecture", "Client", "Rendering", "Ebitengine"]
---

# 2D Ground Rendering using TLBB Lightmaps

## Overview
As part of the initiative to port the TLBB scene assets into a 2D environment, we adopted a "start small" approach for rendering the ground in `0_ath_client`.

Instead of immediately writing a complex `.dds` texture tile parser to handle the raw 3D scene grid files, we utilize the existing `.lightmap.png` assets found in `tlbb-assets/Scene/`. These act as large, pre-baked 2D representations of the entire zone.

## Implementation Details
- **Asset Loading**: `caoyuan.lightmap.png` is loaded during the `init()` sequence in `internal/client/ground.go` using Ebitengine.
- **Rendering**: The ground is drawn immediately after the background fill and before all entities (players, water, UI) in the `render()` loop.
- **Transformations**: The ground texture is scaled (currently hardcoded by `10.0x`) and shifted by the camera offset using Ebitengine's `GeoM` matrix transformations. This ensures it behaves as a static world map that pans correctly relative to the player's movement.

## Future Work
- Implementing a parser for the `jpg_*.dds` tile textures for higher fidelity ground mapping.
- Dynamically loading the correct lightmap or tilemap based on the active zone the player is currently in.
