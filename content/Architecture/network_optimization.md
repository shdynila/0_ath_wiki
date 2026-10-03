---
title: "Architecture: Network Optimization (Targeting 1KB/s)"
date: 2026-10-03T17:40:00+02:00
tags: ["networking", "optimization", "architecture"]
---

# Network Optimization Strategy

To bring the bandwidth of a single player down from 23 KB/s to roughly 1 KB/s, we are implementing a robust MMORPG networking architecture. This will be done in three distinct phases to ensure the game remains stable and smooth.

## Phase 1: Decoupling Simulation from Broadcasting
Currently, the `0_ath_zone_server` ticks the game logic at 60Hz and broadcasts the resulting `ZoneSnapshot` to every client at 60Hz. 
- **Action**: We will decouple the broadcast loop. The physics and AI will continue to tick at 60Hz, but the `AOI.BuildSnapshot` broadcast will only run at **10Hz** (every 100ms).
- **Result**: Immediate 83% reduction in bandwidth.

## Phase 2: Client-Side Interpolation
Because the server is now sending updates at 10Hz, rendering the raw snapshot coordinates in the client will look "choppy".
- **Action**: Modify `0_ath_client/internal/client/game.go` to store the last two received snapshots. In the `Draw` loop, we will use linear interpolation (Lerp) to smoothly animate the entities between the previous snapshot's position and the current snapshot's position based on the delta time.
- **Result**: Butter-smooth 144+ FPS rendering despite a 10Hz network tick rate.

## Phase 3: Delta Compression & Quantization
If Phase 1 and 2 don't bring us down to the 1 KB/s target, we will attack the data size itself.
- **Action**: 
  - Update `AOI.go` to track which entities moved. If an entity is standing still, it is omitted from the `Entities` array.
  - Modify `zone_service.proto` to change `X` and `Y` coordinates from 32-bit floats to 16-bit integers (`int16(pos * 100)`).
- **Result**: Packet sizes drop from ~100 bytes per entity to ~10 bytes per moving entity.
