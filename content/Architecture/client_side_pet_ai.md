---
title: "Implementing Client-Side Pet AI"
date: "2026-06-22T15:30:00+02:00"
tags: ["client", "ai", "shaders", "vfx"]
---

# Client-Side Pet AI

To add flavor and companionship to the 0_ath client without increasing the computational load on the authoritative LEARS (Latency-hiding Entity Authority and Resolution System) server, we implemented a purely client-side Pet AI system.

## Design Philosophy

The core philosophy of 0_ath's architecture dictates that the server (`0_ath_zone_server`) remains a "dumb," highly optimized number-cruncher, responsible only for physics, collision, and authority. Visual fluff, cosmetics, and non-mechanical AI should be offloaded to the client whenever possible.

By implementing the Pet AI client-side:
- **Zero Server Overhead**: The server doesn't calculate pet paths, line of sight, or send pet coordinates over the network.
- **Immediate Responsiveness**: The pet can react instantly to the player's movements and dodging logic without network round-trip delays.

## Implementation Details

### The Pet Struct
The pet's state is maintained locally in the Ebiten client:
```go
type Pet struct {
	X, Y             float32
	TargetX, TargetY float32
	TeleportTimer    float32
	TeleportFlashTimer float32
}
```

### AI Behaviours

1. **Orbiting Follow Logic**
   The pet calculates a `TargetX` and `TargetY` that orbits the player at a fixed distance (60 pixels). The orbit angle is derived from `time.Since(gameStartTime)`, creating a smooth, floating, "fairy-like" movement pattern. If the player dashes or moves quickly, the pet interpolates towards its target, increasing its speed dramatically if it falls too far behind.

2. **Autonomous Projectile Dodging**
   Because the client receives a unified `ZoneDatagram` containing all `ActiveProjectiles`, the Pet AI can seamlessly read this state. 
   - Every frame, the pet iterates through the active projectiles.
   - If a projectile comes within a danger radius (80 pixels) and is moving towards the pet (calculated via the dot product of the projectile's velocity and the vector to the pet), the dodge triggers.
   - The pet instantly teleports to the opposite side of the player and goes on a 1-second cooldown, triggering a visual teleport flash.

### Procedural VFX
Instead of using sprite sheets, the pet is rendered using a highly optimized, math-driven GLSL shader (`chargeSmokeShaderSrc`). 
- It uses a combination of `sin` and `atan2` functions to create a swirling, turbulent cloud effect.
- The hue perfectly matches the goldenrod (`R=218, G=165, B=32`) color of the player's teleport ability, cementing the magical aesthetic.
- During a dodge, it draws two fast-fading concentric circles (yellow and white) to simulate a spatial displacement flash.

## Conclusion
This implementation demonstrates how rich, reactive visual systems can be built entirely on the client, leveraging the data provided by the authoritative server without contributing to its workload.
