---
title: "Combat & PvE System"
date: 2026-06-24T18:30:00+02:00
draft: false
tags: ["architecture", "combat", "ai"]
---

# Combat System Overview

The combat system in 0ath revolves around a data-oriented multitracing `BatchProcessor` and the `SpatialGrid` for extremely fast entity lookups.

## Projectiles & Ownership

To facilitate friendly fire rules, projectiles are tracked with an `OwnerID`.
- When the `BatchProcessor` simulates collision sweeps (`Trace`), it cross-references the `OwnerID` with the target's ID to prevent self-harm, pet damage, or enemy-on-enemy damage.
- Damage in 0ath is absolute: all projectiles instantly kill the target. This toggles the `IsDead` boolean flag on the entity rather than dealing numerical damage.

## AI & PvE

Enemies in 0ath are handled by the `ZoneManager`.

1. **Spawning**: Sentries are inserted into the `SpatialGrid` on boot and respawn on a 10-second timer when killed.
2. **AI Loop**: AI is ticked synchronously in `TickEnemyAI`. It scans nearby entities using standard distance checks.
3. **Behavior**: 
   - **Projectile Clashing & Overthrow**: The `BatchProcessor` computes physical intersections between projectiles. Enemy and Player projectiles cancel each other out upon colliding. A charged (larger scale) projectile will overthrow a smaller one, destroying it while losing a fraction of its own size to kinetic friction.
   - **Organic State Machine (Rain World AI)**: Enemies act like living creatures with limited senses and physics-based momentum.
     - **Perception**: They have a 600px hearing radius and a massive 1500px, 150-degree vision cone. They cannot "see" the player if the player is outside these ranges.
     - **IDLE**: They wander around randomly and pause to sniff their environment.
     - **ALERT**: When they detect a player, they freeze in place for 0.8 seconds to lock on, providing a visual tell.
     - **HUNT**: They accelerate towards their optimal firing distance using drifty momentum, rather than rigid snapping.
   - **Hyper-Mobility**: Enemies move at the exact same base speed as the player (300px/sec).
   - **Firing**: Cooldowns are tracked in a map inside `ZoneManager`. When the cooldown expires, the enemy calculates a normalized direction vector to the closest player and injects a new `Projectile` into the `BatchProcessor` inbox.

## Death & Respawn

Because of the LEARS (Lockless Relaxed-Atomicity State) architecture, the server doesn't force a teleport upon death natively; rather, the client reads its own status from the Area-of-Interest (AOI) snapshot. 

When the client detects `IsDead == true`, it overrides the player's input position to `(0, 0)`. The `ZoneManager` receives this `UpdatePosition` message. The server recognizes that a "dead" player moving to the origin is respawning, and subsequently sets `IsDead = false`.
