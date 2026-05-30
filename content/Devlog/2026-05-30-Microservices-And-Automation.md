---
title: "Completing the Microservice Architecture & Obsidian Automation"
date: 2026-05-30
tags: ["microservices", "architecture", "automation", "obsidian", "wiki"]
---

# Microservice Architecture Finalized

Today, we successfully expanded our backend infrastructure to encompass all the core pillars required for a modern, scalable MMO. 

We initialized three new critical services:
1. **`0_ath_social_server`**: Dedicated entirely to managing Friends Lists, Parties, and Guild interactions. By isolating this, complex guild-wide database queries will never stutter the combat systems.
2. **`0_ath_persistence_server`**: A dedicated persistence layer. It accepts asynchronous state updates (inventory changes, quest completions, coordinate saving) via gRPC and handles the heavy lifting of queueing and writing them to PostgreSQL. This ensures the gameplay loops on the core servers never block on slow database I/O.
3. **`0_ath_combat_server`**: We realized that calculating Area-of-Effect (AoE) damage, hit registration, and combat formulas is extremely CPU intensive. The Combat Server acts as a dedicated high-performance node that executes attacks and pushes the results back to the Gateway for broadcasting, and to the Core server for state validation.

### Internal Microservices Topology
Our cluster now consists of:
* `0_ath_gateway` (Edge Routing)
* `0_ath_auth_server` (Authentication)
* `0_ath_core_server` (Central State Validation)
* `0_ath_movement_server` (UDP High-Tick Proxy)
* `0_ath_chat_server` (Postgres Pub/Sub)
* `0_ath_social_server` (Guilds/Friends)
* `0_ath_persistence_server` (Async Persistence)
* `0_ath_combat_server` (Hit Registration/Formulas)
* `0_ath_proto` (Shared Protobuf schemas)

## Obsidian + Wiki Automation (The Junction Link)
To streamline our documentation process, we implemented a powerful automation trick. We used a **Windows Directory Junction** (`mklink /J`) to map the entire `0_ath_wiki` git repository directly into the local Obsidian Vault as a subfolder named `Wiki_Repo`.

**Why this is amazing:**
* **Zero Duplication**: We no longer have to manually copy Markdown files between the local Vault and the Git repo.
* **Instant Sync**: Modifying a file in Obsidian instantly updates the file in the Git repo because they point to the exact same physical bytes on the hard drive.
* **Unified Workflow**: We can browse, edit, and link our Wiki architecture documents seamlessly within Obsidian's graph view!
