---
title: "Backend Network Telemetry"
date: "2026-09-09"
tags: ["networking", "telemetry", "architecture"]
---

# Backend Network Telemetry Architecture

To maintain high visibility into the connection health of players connected to our QUIC Zone Server, we integrated player-centric connection metrics directly into the server's telemetry pipeline.

## QUIC Connection Tracking
The `0_ath_zone_server` leverages `quic-go` to maintain Unreliable Datagram connections for high-frequency player movement and combat. During the server's main tick loop (~60 TPS), the `ConnectionStats()` of every active client are polled.

## Emitted Metrics
We emit the following OpenTelemetry Histograms per tick:
- `zone_player_rtt_ms` (ms): Represents the smoothed round-trip-time (RTT) across all connected clients.
- `zone_player_packet_loss_pct` (%): Represents the packet loss ratio across all connected clients.
- `zone_bandwidth_sent_bytes` (Bytes): Total outbound traffic sent to players.
- `zone_bandwidth_received_bytes` (Bytes): Total inbound traffic received from players.
- `zone_snapshot_size_bytes` (Bytes): Size distribution of outbound zone snapshots.
- `zone_client_input_size_bytes` (Bytes): Size distribution of inbound client datagrams.

By aggregating these metrics over OTLP, the backend observability dashboards can compute p95, p99, and average real-time latencies globally across the zone infrastructure, as well as accurately track server bandwidth costs.
