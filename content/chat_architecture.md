---
title: "Chat Architecture"
date: 2026-05-31
draft: false
description: "Documentation on the State-Based Dynamic Chat UI and MMO channel mirroring."
---

# Chat Architecture: State-Based Customizable Tabs

## Overview
The chat system in `0_ath` is designed around dynamic, state-based tabs with deep customization inspired by modern MMOs and the `FKServer2` architecture.

## Chat Channels (Types)
We support the following fundamental channels:
* `TEAM`: Exclusive to current party members.
* `AREA`: Local proximity chat. Renders text bubbles directly above the player's head.
* `ALL`: Server/Map-wide broadcast.
* `TELL`: Private 1-on-1 whispers.
* `SYS`: Server and combat system logs.
* `CHANNEL`: Custom chat rooms.
* `GUILD`: Exclusive to guild members.
* `SELF`: Client-side only messages (errors, local events).

*(Note: The `MENPAI` faction channel was removed from the core design).*

## State-Based Tabs
The UI does not hardcode tabs. Instead, tabs are added or removed dynamically based on the player's active state.
For example:
- A new player will only see `ALL`, `PRV`, and `SYS`.
- If the player joins a guild, the `GUILD` tab is dynamically injected into their UI.
- If they leave the guild, the tab is removed.

## Customization
The system allows for users to create their own custom tabs. Each `ChatTab` struct contains an `IncludedTypes` array. This means a player can create a custom tab named "Social" and configure it to *only* accept `GUILD`, `TEAM`, and `TELL` messages, effectively filtering out all spam from `ALL` (AREA and WORLD channels).

## API Structure
```go
type ChatTab struct {
    Name          string
    IncludedTypes []ChatMessageType
    IsCustom      bool
}
```
Client methods:
* `AddTab(name, types, custom)`
* `RemoveTab(name)`
* `UpdateTab(name, types)`
