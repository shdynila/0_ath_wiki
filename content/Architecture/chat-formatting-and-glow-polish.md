---
title: "Chat Formatting, QUIC Session Cleanups, and Visual Glow Polish"
date: 2026-07-28
tags: ["chat", "quic", "rendering", "graphics", "client"]
---

# Chat Formatting, QUIC Session Cleanups, and Visual Glow Polish

## Overview
This update addresses multiple networking, input, and rendering enhancements across the `0_ath` client and `0_ath_zone_server`.

## Key Changes

### 1. QUIC Session Handling
- **Multi-Client Support**: Removed IP-based connection eviction from `QuicServer.handleConnection()`, allowing multiple concurrent client processes on the same IP or LAN to connect without triggering `superseded` disconnect loops.
- **Graceful Disconnects**: Added `ebiten.IsWindowBeingClosed()` and `SIGINT`/`SIGTERM` signal handlers in `0_ath_client/main.go` to cleanly close QUIC sockets on app exit.

### 2. Unified Character Name & Chat Formatting
- **Signed-up Usernames**: Updated `validateUser()` and `0ath-cli` to pass signed-up account usernames into `clientUserId` and `player.Name`.
- **Composite Chat Payload (`CharacterName|EntityID`)**: `SendChatMessage()` packs both character name and spatial entity ID so chat messages render as `[<CharacterName>]: <message>` in the chat window while simultaneously routing overhead speech bubbles to the correct player entity on all connected clients.

### 3. Visual Glow Polish
- **Local Player**: Rendered with the 10-step soft radial white glow (`vector.DrawFilledCircle`).
- **Player Pet**: Rendered with the pulsating pink smokey shader aura (`playerGlowShader`).
- **Other Players**: Clean green squares without surrounding glow to maintain visual clarity during gameplay.
