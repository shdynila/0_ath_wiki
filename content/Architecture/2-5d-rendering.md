---
title: "2.5D Rendering and Y-Sorting"
date: "2026-09-10"
tags: ["architecture", "rendering", "graphics", "2.5D"]
---

# 2.5D Rendering Architecture

To elevate the visual fidelity of the 2D grid, the engine employs a classic **2.5D top-down perspective** (commonly found in Zelda or Stardew Valley).

## Y-Sorting
By strictly iterating over the rendering grid row-by-row (from top to bottom), the graphics engine inherently Z-sorts objects. Entities that are further down on the screen (closer to the camera) will naturally overlap entities drawn behind them on previous rows.

## Tall Sprites and Anchors
The engine breaks out of the rigid 100x100 tile boundaries for tall objects (like Trees). 
- A tree sprite is generated as 100x200.
- The base (bottom half) is aligned precisely with the active grid coordinate.
- The canopy (top half) spills over and draws atop the tile behind it, providing an immediate sense of 3D height.

## Ambient Shadows
Objects with height feature drop shadows rendered directly into their base tile space, grounding them in the 3D space.
