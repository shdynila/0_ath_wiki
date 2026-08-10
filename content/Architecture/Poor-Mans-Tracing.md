---
title: "Poor Man's Tracing: High Performance Correlation"
date: 2026-08-05
tags: ["architecture", "observability", "tracing", "performance"]
---

# Poor Man's Tracing in 0_ath

To achieve robust observability without the heavy RAM and CPU overhead of full distributed tracing tools (like Jaeger), 0_ath utilizes a strategy called "Poor Man's Tracing". 

## The Strategy

Instead of generating Spans and maintaining parent-child hierarchies across the entire lifecycle of a tick, we use **Correlation Logging**. This means that context identifiers (like `player_id`) are injected directly into structured JSON logs using Go's high-performance `log/slog` library.

When using a local terminal UI like **Gonzo**, developers can instantly grep or filter by a specific `player_id`, reconstructing the entire sequence of events for that user as if they were viewing a trace.

## Implementation Details (Zone Server)

In the `0_ath_zone_server`:
1. **The Cold Path**: We inject `player_id` into all connection lifecycle events and reliable stream RPCs.
2. **The Hot Path**: We intentionally omit tracing and correlation logging from the high-frequency UDP movement and combat loops (60 TPS). This prevents log spam and preserves CPU cycles for game logic calculation.

By replacing the standard `log` package with `log/slog` and configuring it with `slog.NewJSONHandler`, we gain structured JSON output with zero allocations on disabled log levels.
