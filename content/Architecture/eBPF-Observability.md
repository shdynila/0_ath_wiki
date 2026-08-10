---
title: "Custom eBPF Observability Architecture"
date: 2026-08-09
tags: ["architecture", "observability", "ebpf", "performance"]
---

# 0_ath Custom eBPF Observability

To completely eliminate proprietary lock-in (e.g., Netdata Cloud) and aggressively minimize RAM overhead on worker nodes, `0_ath` utilizes a custom, hybrid eBPF observability stack.

## Components

The observability pipeline consists of two primary services:

### 1. `0_ath_ebpf_agent`
This lightweight Go daemon runs as a DaemonSet across all nodes (Hetzner Gateway + Private Local Workers). It serves two functions:
- **Hardware Polling:** Reads `/proc/stat` and `/proc/meminfo` at low frequencies to determine CPU and RAM usage.
- **eBPF Kernel Probes:** Loads compiled C bytecode into the Linux kernel using `cilium/ebpf`. It attaches kprobes/tracepoints to `netif_receive_skb` and `net_dev_start_xmit` to exactly quantify network throughput and drops directly in the kernel networking stack, bypassing user-space entirely.

### 2. `0_ath_telemetry_server`
This central service runs on a master node. It exposes a UDP endpoint (`:9090`) to receive metrics from the agents. 
Instead of a heavy TSDB like Prometheus, this server buffers the UDP payloads and performs batch `INSERT` operations into our existing PostgreSQL database, simplifying the infrastructure footprint.

## The Delta-Sync Optimization
Rather than pushing metrics at a fixed interval, the `0_ath_ebpf_agent` uses threshold-triggered reporting (Delta Sync). The agent polls internally at 1Hz, but only dispatches a UDP packet if the CPU or Network usage has changed beyond a configured threshold (e.g., >5% CPU delta). This ensures a real-time response to spikes while keeping baseline network telemetry noise at zero.
