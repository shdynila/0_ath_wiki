---
title: "Creature AI & Pathfinding"
date: 2026-07-22T18:00:00Z
tags: ["ai", "architecture", "pathfinding", "zone-server"]
---

# Creature AI Ecosystem

Our Zone Server implements a dynamic, node-based A* Pathfinding system for creature AI to simulate a breathing ecosystem.

## NavGrid
The Zone Server initializes a `nav.NavGrid` inside `main.go`. This grid defines the walkable space and physical obstacles within the Zone. 
Currently, we initialize a 100x100 grid of 100px cells (10,000 x 10,000 bounds) with procedural obstacles.

## Creature State Machine
Creatures are an extension of the generic `entity.Player` struct, allowing them to hook natively into the LEARS SpatialGrid for combat and AoE calculations.
Their AI ticks through the following states:
1. **Idle**: Waiting for stimulus or player presence.
2. **Wander**: Picking a random location and pathfinding to it when no players are nearby.
3. **Hunt**: Relentlessly tracking human players across the map, closing distance to <=10px, and engaging in combat.

## Faction & Projectile Mapping
- **Blue Passive / Aggressor**: Fires **Blue Plasma Fireballs** (`EffectID = 5`) with cyan core and cobalt blue glow.
- **Yellow Archer**: Fires **Golden Arrows** (`EffectID = 4`) using `arrowShader`.
- **Red Aggressor**: Fires **Red Fireballs** (`EffectID = 3`).

## Pathfinding & Proximity
- Removed player repulsion forces to allow creatures to swarm and engage in close melee range.
- Pathfinding updates every 0.3s for responsive pursuit.
