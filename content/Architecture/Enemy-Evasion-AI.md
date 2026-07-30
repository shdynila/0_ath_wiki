---
title: "Enemy Evasion AI"
date: 2026-07-23T20:54:00+02:00
tags: ["ai", "combat", "architecture"]
---

# Enemy Evasion AI Architecture

To support engaging combat in our one-hit-kill design, the `0_ath_zone_server` introduces two new behavioral states to the LEARS-compliant `entity.Creature` AI:

## State Machine Extensions

1. **ModeKite (Spacing)**
   When an enemy detects a player getting within a critical threshold (e.g., `< 400px`), it transitions from `ModeHunt` to `ModeKite`. It will compute the vector from the player to itself and apply a negative velocity to maintain space. Once a safe distance is reached (`> 500px`), it returns to Idle or Hunt mode.

2. **ModeEvade (Active Dodging)**
   To actively avoid incoming projectiles, the AI scans the spatial grid's active `combat.Projectile` array at the start of `TickAI`. If a projectile comes within `200px` and its velocity vector indicates it is traveling towards the creature, the AI preempts all other modes and forces `ModeEvade`. 
   
   During evasion, the creature calculates a perpendicular impulse vector relative to the projectile's velocity and executes a sharp sidestep maneuver for 0.5 seconds to dodge the attack.
