---
title: "Microservice Architecture Plan for 0_ath"
date: 2026-05-30
tags: ["architecture", "microservices", "backend"]
---

# Microservice Architecture Plan for 0_ath

This document outlines the modern microservice architecture for **0_ath**, evolving past the legacy monolithic design of FKServer2. 

The goal is to have a highly performant, scalable system where each distinct service lives in its own repository, communicating via well-defined Protocol Buffers.

## Repository Split & Roles

Based on the requirement for a "repository per service", here are the core repositories that have been created, and their specific roles:

### 1. `0_ath_zone_server` (The "Game Server")
**This is the primary Game Server.** It is the authoritative source of truth for the game world.
* **Responsibilities**: 
  * Combat calculations (damage, aggro, spell casting).
  * Inventory management and item drops.
  * NPC AI and spawn logic.
  * Quest tracking and state persistence.
  * Physics validation (ensuring players aren't teleporting or moving too fast).
* **Tech Stack**: Go, TCP/gRPC for internal communication.
* **Why**: By isolating this, the heavy CPU calculations of game logic won't be interrupted by the sheer volume of network packets from players moving around.

### 2. `0_ath_movement_server` (The Position Broadcaster)
**A high-tick, unauthoritative relay.** (Using `gnet/v2`).
* **Responsibilities**:
  * Receiving constant UDP position updates from players (X, Y, Z, Rotation, Velocity).
  * Immediately broadcasting these positions to other players in the same "Area of Interest" (AoI).
* **Tech Stack**: Go, `gnet/v2`, UDP.
* **Why**: Movement is extremely "spammy" (e.g., 20-30 packets per second per player). If the Game Server had to process all of this, combat would lag. The movement server just blindly echoes positions to keep things smooth.

### 3. `0_ath_gateway` (The Network Proxy / Front Door)
**The only server the client actually connects to directly.**
* **Responsibilities**:
  * Handling raw TCP and UDP connections from clients.
  * Managing Encryption (TLS/XOR) and packet boundary slicing.
  * Rate-limiting and DDoS protection.
  * Routing packets to the correct internal server (e.g., routing `MovePacket` to `movement_server`, and `CastSpellPacket` to `zone_server`).
* **Tech Stack**: Go, asynchronous networking.

### 4. `0_ath_auth_server` (The Login Server)
**Stateless authentication.**
* **Responsibilities**:
  * Validating usernames and passwords.
  * Issuing secure session tokens (JWTs) that the Gateway uses to identify connections.
  * Communicating with the player database.

### 5. `0_ath_proto` (The Shared Language)
**A repository containing only `.proto` files.**
* **Responsibilities**:
  * Defining the exact structure of packets (e.g., `PlayerMove`, `PlayerLogin`, `TakeDamage`).
* **Why**: All other repositories will import this repo. This ensures that the Gateway, Zone Server, and Movement Server all agree on exactly how data is structured. If you change a packet, you change it here, and all services update.

---

## How They Interact (The Flow)

```mermaid
graph TD
    Client[0_ath Game Client] -->|UDP| Gate[0_ath_gateway]
    Client -->|TCP| Gate
    
    Gate -->|gRPC/TCP| Auth[0_ath_auth_server]
    Gate -->|UDP (Positions)| Move[0_ath_movement_server]
    Gate -->|gRPC/TCP (Actions)| Zone[0_ath_zone_server]
    
    Zone -->|Async Save| DB[(Database)]
    Auth -->|Query User| DB
```

1. **Login**: Client connects to `0_ath_gateway`. Gateway forwards credentials to `0_ath_auth_server`. Auth server verifies and tells Gateway "This is Player 1".
2. **Movement**: Client holds 'W'. It spams UDP position packets to the `0_ath_gateway`. The Gateway looks at the packet, sees it's a movement packet, and immediately relays it to `0_ath_movement_server`. The Movement server broadcasts it to nearby players.
3. **Combat**: Client presses '1' to cast Fireball. Client sends a TCP packet to `0_ath_gateway`. Gateway sees it's a combat action, and forwards it to `0_ath_zone_server` (The Game Server). The Game Server calculates the damage and tells the Gateway to broadcast the "Damage Taken" animation to all nearby clients.

---

## Authoritative State vs Unauthoritative Movement
Because the `movement_server` is just echoing positions to be fast, a hacked client could send "I am teleporting 1000 meters forward". 
To prevent this, the `zone_server` (Game Server) will occasionally look at the player's position and validate it. If the player moved too fast, the `zone_server` tells the `gateway` to force the player back to their real position ("rubberbanding").
