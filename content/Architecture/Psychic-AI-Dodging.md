---
title: "Smart Trajectory AI Evasion"
date: 2026-07-24T21:15:00Z
tags: ["ai", "networking", "combat", "evasion", "math"]
---

# Smart Trajectory AI Evasion

To make enemy creatures incredibly intelligent duelists, the evasion mechanic was upgraded from simple distance-based proximity to exact trajectory matching.

## Architecture

1. **Protobuf & Client Networking**:
   The `ClientInput` Protobuf message was extended to include `aim_x`, `aim_y`, and `charge` parameters. The client now continuously streams its mouse cursor position and its active skill charge state over the background movement datagram (`SkillId = 0`).

2. **Server State**:
   The `entity.Player` struct inside `0_ath_zone_server` was updated to store `AimX`, `AimY`, and `Charge`. The `UpdatePosition` message was expanded to safely propagate these fields into the LEARS (Lockless, Relaxed-Atomicity State) goroutine loop.

## Evasion Logic (TickAI)

Inside `TickAI`, creatures evaluate threats in two ways:

### 1. Active Projectile Intersection
Creatures iterate through all active projectiles. For each projectile, they project its exact flight path (a line vector).
They calculate the perpendicular distance from their center point to this flight path using projection arithmetic (`perpDistSq = distToOrigSq - (dot * dot)`).
If the flight path passes within 50px of the creature's center, it constitutes a direct hit, triggering an instant teleport/dash out of the way.

### 2. Channel Prediction
If a nearby player is winding up an attack (`Charge > 0`), the creature draws a virtual trajectory originating from the player and passing through their `AimX/AimY` crosshair. 
If this virtual trajectory is mathematically guaranteed to hit the creature, they preemptively trigger a teleport/dash before the player even releases the mouse button.

### 3. Rapid Blinking
Because the AI only dodges when mathematically necessary, their dodge behavior is an instantaneous 150px perpendicular teleport (dash) with an incredibly short cooldown of `0.2s`. This allows them to rapid-fire blink out of the way of multiple perfectly aimed shots in succession.
