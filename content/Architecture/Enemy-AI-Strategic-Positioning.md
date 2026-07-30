---
title: "Enemy AI: Strategic Positioning"
date: 2026-07-28
tags: ["ai", "combat", "zone-server"]
---

# Enemy AI: Strategic Positioning

We have overhauled the creature combat AI to eliminate jittering and improve combat flow.

## The HoldPosition State
Previously, enemies were locked in a constant loop of pathfinding towards the player, reaching engagement distance, stopping, getting pushed slightly away by separation logic, and then pathing back towards the player. 

We introduced a new `ModeHoldPosition` state. Now, when an enemy gets within their ideal engagement range (e.g. 60 units for melee, 300 units for snipers):
- They plant their feet and transition to `HoldPosition`.
- They will only rotate to face the player, completely disabling pathfinding logic so they don't jitter around.
- They will hold this strategic spot unless the player gets too close (kiting threshold) or moves out of their maximum range (e.g. running > 330 units away), at which point they will resume the hunt.

## A* Grid Jitter Fix
We also resolved the root cause of the "walking backwards" phenomenon. Our `NavGrid` divides the world into coarse cells, and previously, creatures would often path to the exact center of the cell they were currently standing in, causing them to turn around briefly before advancing.

We added a smooth line-of-sight optimization: if the first node of their calculated path is the cell they are already inside, they instantly drop it from their queue and path to the next node. This ensures they take the most direct, aggressive route to the player.
