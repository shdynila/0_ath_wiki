---
title: "gRPC and SSH Tracing in eBPF Observability"
date: 2026-08-09
tags: ["architecture", "observability", "ebpf", "grpc"]
---

# Upgrading the 0_ath Observability Stack

The custom eBPF observability stack has been upgraded to provide better reliability over the WAN and deeper kernel insights into security.

## gRPC Transport

We replaced the basic UDP transmission layer with a robust **gRPC** stream.
While UDP is incredibly fast on a local network, transmitting telemetry data across the public internet (from local nodes to the Hetzner gateway) requires reliability. gRPC, built on HTTP/2, natively handles TCP congestion control, connection multiplexing, and automatic retries. 

This ensures that our threshold-triggered metrics (Delta Sync) arrive safely at the central PocketBase database without being silently dropped by ISP routers.

## eBPF SSH Tracing

We expanded the capabilities of `0_ath_ebpf_agent` beyond simple hardware polling. 

By inserting a `kprobe` at the `tcp_v4_conn_request` kernel function, the agent now intercepts all inbound TCP connection attempts in real-time. By filtering for destination Port 22, we generate an event every time a bot or malicious actor attempts to probe the SSH port.

These events are pushed into a highly efficient eBPF Ring Buffer (`BPF_MAP_TYPE_RINGBUF`), read by the Go user-space daemon, and streamed via gRPC to the Hetzner PocketBase database (`ssh_attempts` collection) for security auditing.
