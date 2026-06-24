---
title: "Migrating to Server-Side Companion AI"
date: "2026-06-22T15:40:00+02:00"
tags: ["server", "ai", "entities"]
---

# Server-Side Companion AI

Following the initial exploration of a purely client-side cosmetic pet, we decided to migrate the Pet AI to the server. This monumental shift elevates the pet from a mere local visual effect to a fully realized, authoritative entity present in the world. 

## Architectural Changes

### The Pet Entity
We created a new `entity.Pet` struct in `0_ath_zone_server`. Unlike a standard player, the Pet is driven by a server-side state machine evaluated every tick:
- **`PetStateIdle`**: Triggered when the owner stops moving. The pet settles near the owner and stays completely still.
- **`PetStateFollowing`**: Triggered when the owner moves. The pet calculates an orbital target behind the player and smoothly interpolates towards it.
- **`PetStateDodging`**: Triggered when a projectile threatens the pet.

### "Rain World" Style Dodging
Unlike the client-side implementation which instantly teleported the pet away, the server-side AI uses mechanical dodging.
1. The pet scans the `combat.BatchProcessor`'s active projectiles.
2. If a projectile comes within 100 pixels and is headed towards the pet (calculated via dot product), the pet enters `PetStateDodging`.
3. It calculates an evasion vector perpendicular to the projectile's velocity.
4. The pet significantly increases its movement speed and physically moves out of the projectile's path, simulating a panicked dodge.

### Broadcasting & Rendering
- **Zone Snapshot Integration**: Pets are automatically appended to the `ZoneSnapshot` alongside players. Their IDs are prefixed with `pet_` (e.g., `pet_user123`).
- **Client Rendering**: The client no longer manages any pet logic. Instead, `0_ath_client` simply checks if an incoming entity ID has the `pet_` prefix. If it does, it renders it as a smaller goldenrod square (`RGBA{218, 165, 32, 255}`).

## The Result
Because the pet is now an authoritative entity:
- **Universal Visibility**: All players in the zone can see your pet accompanying you.
- **Shared Experience**: Other players can see your pet reacting and dodging their projectiles in real-time.
- **Mechanical Foundation**: This architecture opens the door for future mechanics, such as pets blocking specific attacks, retrieving items, or casting support abilities, as they are now fully integrated into the server's spatial systems.
