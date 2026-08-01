---
title: "Unit Control Modes & Companion Movement"
date: 2026-07-31
tags: ["architecture", "pet", "controls", "hud", "gameplay"]
---

# Unit Control Modes & Companion Dynamics

`0_ath` features a real-time unit control system that allows players to switch between controlling their main character, their pet companion, or both units simultaneously.

## Control Modes

- **F1 - Character Only Mode**:
  - Direct WASD movement and actions control the **Player Character**.
  - The pet companion operates in AI automated follow mode.
  - Camera tracks the Player Character.

- **F2 - Pet Companion Mode**:
  - Direct WASD movement and actions control the **Pet Companion**.
  - The main character remains stationary in position.
  - Camera dynamically centers and follows the Pet.

- **F3 - Dual Control (Both) Mode**:
  - WASD movement commands apply to **BOTH** Character and Pet in parallel.
  - Camera dynamically focuses on the mid-point vector `(Player + Pet) / 2`.
  - Enables coordinated tactical positioning, dual trap placement, and flanking maneuvers.

## Network Protocol

Custom input datagram skill IDs handle real-time companion synchronization over QUIC:
- `SkillId = 0`: Standard player character movement datagram.
- `SkillId = 97`: Pet manual target movement position datagram.
- `SkillId = 96`: Pet reset follow mode datagram (returns pet to automated AI).
