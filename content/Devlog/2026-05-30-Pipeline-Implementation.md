---
title: "End-to-End Microservice Pipelines Live"
date: 2026-05-30
tags: ["networking", "microservices", "udp", "tcp", "go"]
---

# End-to-End Microservice Pipelines Live

Following up on our recent transition to a microservice architecture, we have successfully implemented the core networking pipelines that route client traffic to our backend systems!

## 1. UDP Movement Pipeline
We've established a highly performant UDP proxy in `0_ath_gateway`.
- **Flow**: Client -> Gateway (UDP `:8081`) -> Movement Server (UDP `:9000`).
- **Mechanics**: The Gateway blindly accepts UDP packets and forwards them to the Movement Server. The Movement Server (using `gnet/v2`) deserializes the `player.Location` protobuf, calculates the Area of Interest (AoI), and broadcasts the surrounding entities back to the Gateway. The Gateway then fans out this response to all active UDP clients.
- **Result**: We tested this via a custom simulator and successfully received real-time broadcast positions of other players and NPCs!

## 2. TCP Login & Action Pipeline
The legacy TCP monolithic structure is officially a thing of the past.
- **Flow**: Client -> Gateway (TCP `:8080`) -> Auth Server (HTTP POST) -> Core Server (gRPC `:50051`).
- **Mechanics**: 
  1. The Gateway intercepts the raw TCP stream, identifies the legacy `$-^` boundary markers, and decrypts the header and payload using the legacy XOR cypher.
  2. Upon receiving a `CLAskLogin` packet, the Gateway delegates the actual credential validation to the `0_ath_auth_server` via an internal HTTP POST to `/signin`.
  3. If successful, the Gateway encrypts and returns a `LCRetLogin` packet back to the client.
  4. The connection is now considered **Authenticated**. Any future game actions (e.g., `ChatMessage`) are decoded and dispatched via gRPC to the `0_ath_core_server` for authoritative processing.

## Next Steps
The structural plumbing is fully operational. We can now begin iterating on the specific game logic within the Core Server (like combat, inventory, and AI) knowing that the networking layer is scalable and secure.
