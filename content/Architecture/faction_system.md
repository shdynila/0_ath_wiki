---
title: "Dynamic AI Faction System"
date: 2026-07-15T22:50:00+02:00
tags: ["ai", "combat", "physics"]
---

# Dynamic AI Faction System

The `0ath` Zone Server now implements a fully dynamic faction AI system, departing from the classic binary "Player vs Everyone" arcade model. This introduces emergent gameplay where AI entities can hunt and fight each other based on faction allegiance.

## Factions

The system categorizes entities dynamically using the `getFaction` helper, mapping entity ID prefixes to string factions:
1. `player`: Controlled by the user.
2. `pet`: Allied entities (`pet_`).
3. `red`: Standard enemies (`enemy_`).
4. `yellow`: Corrupted variants (`yellow_enemy_`).

## Collision Rules
Physics and damage application in `batch_processor.go` respects the faction system.
The swept-sphere `Trace` method actively compares `ownerFaction` and `targetFaction`:
- If `ownerFaction == targetFaction`, the projectile phases through (preventing friendly fire).
- Special rules prevent `player` and `pet` from dealing damage to one another.

## AI Perception
The `TickEnemyAI` state machine evaluates all active entities in the Spatial Grid. Instead of explicitly searching for `player-` prefixes, the AI evaluates the `targetFaction`. If the target belongs to a rival faction, the AI will lock on, engage in a pursuit `HUNT` state, and utilize its assigned `EffectID` projectiles to eliminate the threat.
