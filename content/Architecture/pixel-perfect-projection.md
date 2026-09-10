---
title: "Pixel-Perfect Projection & State Authority Fixes"
date: 2026-09-10
tags: ["Rendering", "2.5D", "Architecture", "Math", "State"]
---

# Pixel-Perfect Projection

When implementing our 2.5D renderer in Ebitengine, we encountered significant diagonal movement jitter where static objects (e.g. trees) would wobble back and forth by exactly 1 pixel relative to the grid tiles.

## The Flawed Approach
Initially, we used `worldToScreen` to project world coordinates, and then applied `math.Round` independently on the camera's base offset and the entity offsets. 

```go
// Flawed:
baseX = math.Round(cx - camX*zoom)
px = math.Round(cx + (entityX - camX)*zoom)
```
When `camX` changes smoothly across subpixel values, `baseX` and `px` do not snap to integers on the exact same frame due to floating-point truncation variances (specifically, when `zoom` is a fractional number like `0.7`). This resulted in a "staircase" tearing effect where an entity appeared to shift relative to the terrain grid.

## The Mathematical Fix
We rewrote the projection function to strictly calculate relative to an integer-anchored camera pixel offset:

```go
// Perfect:
targetSize := float32(math.Round(float64(zone.TileSize) * float64(cameraZoom)))
actualZoom := targetSize / float32(zone.TileSize)

camPixelX := float32(math.Round(float64(camX * actualZoom)))
entityPixelX := float32(math.Round(float64(x * actualZoom)))

sx := entityPixelX - camPixelX + cx
```

By calculating `entityPixelX` completely independently of the camera, and then subtracting `camPixelX` via pure integer math, we guarantee that the relative offset between any two static entities remains constant. They shift across the screen in perfect synchrony.

# Zone Server State Authority & Ghost Players

Another critical issue arose where the client rendered duplicate "ghost" players. 

## The Flaw
The `0_ath_zone_server`'s QUIC connection handler was greedily generating generic player IDs (e.g., `player-127.0.0.1:45321`) the moment a connection opened, and mapping them to new player entities. When the client subsequently sent the reliable `JoinRequest` stream containing their actual JWT-authenticated `Username`, the server ignored it.

## The Fix
We updated the stream handler to parse `ZoneStreamMessage_Join`. When the authenticated username arrives, the server now:
1. Searches the active spatial grid for any lingering ghost entity belonging to that username.
2. Instantly kills and removes the old ghost.
3. Overwrites the generic `player-ip:port` ID of the current connection with the verified `Username`.

This ensures there is strictly one authoritative entity per user and seamlessly manages reconnection zombies.
