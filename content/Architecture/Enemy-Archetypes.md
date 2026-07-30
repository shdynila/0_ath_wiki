---
title: "AI Enemy Archetypes"
date: 2026-07-24T21:30:00Z
tags: ["ai", "combat", "archetypes"]
---

# AI Enemy Archetypes

To create a dynamic and challenging combat sandbox, the game now features distinct AI enemy archetypes. All enemies share a baseline survival instinct (predictive trajectory teleport dodging), but their combat engagement rules differ drastically.

## 1. The Duelist (Deep Blue Aggressor)
- **Role:** Balanced melee/ranged combatant.
- **Behavior (`ModeHunt`):** Actively pursues the player.
- **Combat Stats:** Fires standard projectiles at a 1.5s cooldown.

## 2. The Berserker (Crimson Red)
- **Role:** High-pressure rushdown.
- **Behavior (`ModeHunt`):** Relentlessly pursues the player.
- **Combat Stats:** Fires at an extremely accelerated rate (0.5s cooldown), creating walls of projectiles that force the player into defensive positioning.

## 3. The Sniper (Golden Yellow)
- **Role:** Evasive ranged support.
- **Behavior (`ModeKite`):** Actively runs away from the player to maintain a safe engagement distance of 500px.
- **Combat Stats:** Fires high-velocity Grey Arrows (600px/sec) at a moderate 1.0s cooldown while retreating.

## 4. The Bystander (Cyan Passive)
- **Role:** Ambient world population.
- **Behavior (`ModeWander`):** Moves randomly. If engaged, it utilizes advanced predictive teleportation to survive but will not retaliate.
