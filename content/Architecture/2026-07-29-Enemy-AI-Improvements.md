---
title: "Enemy AI Improvements: Kiting and Combat State Fixes"
date: "2026-07-29T22:33:00Z"
tags: ["AI", "Server", "Combat"]
---

Today we addressed a critical oversight in the `0_ath_zone_server` enemy AI behavior. Players reported that Red enemies would frequently walk directly on top of the player and stop attacking, effectively freezing in place.

Upon investigation, we identified two main bugs in the AI controller:

1. **Combat Whitelist in `ModeHoldPosition`:**
   The zone server's `TickCreatureCombat` function previously only allowed combat processing if the creature was in `ModeHunt` or `ModeKite`. Once the AI reached its ideal engagement distance (the "sweet spot"), it transitioned to `ModeHoldPosition`. Because this mode was missing from the combat whitelist, the enemy would stop shooting entirely while holding its ground.
   *Fix:* Added `ModeHoldPosition` to the whitelist, allowing enemies to continue attacking while maintaining optimal range.

2. **Lack of Player Separation (Kiting):**
   `ModeHoldPosition` correctly implemented a separation algorithm to prevent enemies from stacking on *each other*, but neglected to enforce a minimum distance from the *player*. If a player walked toward an enemy, the enemy would remain perfectly still.
   *Fix:* We implemented dynamic kiting logic. If the player gets too close (e.g., within 50px for Red enemies), the AI calculates an inverse velocity vector, allowing the enemy to backpedal and maintain distance automatically.

These changes were compiled, published to `ghcr.io`, and immediately rolled out to the live Kubernetes cluster via a `statefulset` restart. Enemies are now significantly more responsive and tactical!
