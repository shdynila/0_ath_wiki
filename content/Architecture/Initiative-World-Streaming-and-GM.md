---
title: "Initiative: World Streaming and GM Mode"
date: 2026-05-31
draft: false
---

# Real-Time World Streaming & GM Mode

This document outlines the architectural strategy and initiatives for migrating map object rendering into a dedicated **Real-Time gRPC Streaming World Server**, and adding **interactive dynamic object spawning** for both offline and online multiplayer.

## Architectural Goals

1.  **Maintain High-Frequency Movement:** `0_ath_movement_server` must continue to handle only high-frequency player movement (UDP).
2.  **Modular Core Server:** `0_ath_core_server` must be structured as a **Modular Monolith** using `internal/` packages (e.g., `internal/world`, `internal/gm`). This prevents the need to spin up multiple microservices in the future while keeping the codebase decoupled and clean.
3.  **Real-Time Subscriptions:** Game clients will open a persistent gRPC server-to-client stream to `0_ath_core_server` to receive dynamic world object events (`EVENT_SPAWN`, `EVENT_MOVE`, `EVENT_DESPAWN`) instantly.
4.  **Interactive GM Mode:** Players acting as GMs can spawn items by using a `/gm` chat command to enter GM Mode, followed by left-clicking the game map.

---

## Initiatives Breakdown

We will execute this vision through three distinct, manageable initiatives:

### Initiative 1: Client Chat UI Framework
*   **Goal:** Build the client-side infrastructure to intercept chat commands (specifically `/gm`).
*   **Tasks:** 
    *   Export the memory-safe `SafeTextBox` (from our previous Cgo fix) from the `gui` package.
    *   Add a chat UI overlay to the main game loop (`main.go`).
    *   Implement an input interceptor that toggles the chat box on `Enter` and processes slash commands.

### Initiative 2: Core Server Modularization
*   **Goal:** Refactor `0_ath_core_server` to support a clean, monolithic architecture before adding complex streaming logic.
*   **Tasks:**
    *   Create an `internal/world` package.
    *   Define the base `Server` struct inside `internal/world` to hold business logic and state (e.g., connected clients, active world objects).
    *   Wire the refactored package back to the main gRPC listener in `main.go`.

### Initiative 3: gRPC World Streaming, GM Validation & Client Integration
*   **Goal:** Implement the authoritative server logic for dynamic objects and wire the client to it.
*   **Tasks:**
    *   Update `0_ath_proto` to include `SubscribeWorldState`, `ValidateGM`, and `SpawnWorldObject` RPCs.
    *   Implement `ValidateGM` and `SubscribeWorldState` in the `world` package.
    *   Rename the client's local "Sandbox" mode flag to "Offline" mode (`--offline`).
    *   Implement the background listener in the client to receive gRPC stream updates and update local map objects.
    *   Wire the `/gm` chat command to the server validation endpoint (or bypass in Offline Mode).
    *   Render a gold preview square at the cursor when GM Mode is active, allowing the user to click-to-spawn.

---
*This document tracks the execution plan for the current milestone. Progress will be tracked via task artifacts.*
