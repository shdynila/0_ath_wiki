---
title: "Client Architecture: Sandbox vs Online Mode"
date: 2026-05-30
tags: ["client", "architecture", "sandbox", "networking", "cli"]
---

# Dual-Mode Client Architecture

To streamline our UI/UX iteration speed and provide a robust testing environment, we have refactored the `0_ath_client` to support two completely distinct execution paths: **Sandbox Mode** and **Online Mode**.

## 1. Sandbox Mode (Offline)
Sandbox mode is designed purely for rapid iteration on graphics, UI layouts, animations, and local entity physics. It completely isolates the client from the backend network infrastructure.

**How to run it:**
* Using the CLI: `./0ath.exe client --sandbox`
* Direct execution: `go run main.go --sandbox=true`

**Internal Flow:**
1. The client boots up and instantly bypasses the Authentication screen.
2. It assigns a dummy `sandbox_user` identity to the player.
3. It completely skips dialing the UDP Movement socket.
4. During the `update()` tick, the client intercepts the network payload broadcast and silently discards it, preventing nil-pointer panics on the missing UDP socket.

## 2. Online Mode (Connected)
Online mode is the default state of the game client. It expects our microservice backend to be active (either deployed locally via `0ath dev` or on the `k3d` cluster).

**How to run it:**
* Using the CLI: `./0ath.exe client`
* Direct execution: `go run main.go`

**Internal Flow:**
1. **Authentication:** The client boots up the `raygui` Login Screen. It sends an HTTP `POST` request to our Gateway's Auth endpoint (configurable via `--authAddr`, defaulting to `http://localhost:8080/signin`).
2. **Identity Resolution:** Upon a successful `200 OK` response, the client parses the JSON payload to extract the player's unique `id`.
3. **Socket Bootstrapping:** The login context automatically closes. The client dials the Movement Server (configurable via `--movementAddr`, defaulting to `localhost:8081` UDP).
4. **Game Loop:** The core 60FPS `rl.BeginDrawing()` loop begins, synchronizing spatial state with the server every tick.

## CLI Integration
The `0ath` orchestrator tool has been updated to seamlessly handle these modes. By running `./0ath.exe client --sandbox`, the orchestrator will automatically pass the appropriate boolean flags downstream to the Go compiler and execute the binary in isolation!
