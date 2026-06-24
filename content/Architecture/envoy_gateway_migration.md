---
title: "Envoy Gateway Migration & QUIC Updates"
date: 2026-06-15T19:06:00Z
tags: ["envoy", "cilium", "gateway", "quic"]
---

# QUIC Movement Migration Complete

We have successfully rewritten both the client and movement server to use the modern QUIC protocol!

## Changes Made
- Migrated `0_ath_movement_server` from `gnet` (raw UDP sockets) to `quic-go` using connection multiplexing and ephemeral TLS 1.3 self-signed certificates.
- Migrated `0_ath_client` to dial QUIC sessions and handle connection state instead of dialing raw UDP packets.
- Implemented **QUIC Datagrams** (RFC 9221) so we benefit from QUIC encryption and congestion control, but keep the unreliable packet delivery to avoid Head-of-Line blocking in our game tick processing.
- Updated `0ath-cli/skaffold.yaml` to port-forward the `movement-service` (port `1118`) directly to localhost so the client can connect without hitting the Envoy gateway overhead.

## Local Development Port-Forwarding Overhaul

Because we migrated to a native Cilium Envoy integration, the `gateway-0ath` service technically became a "selectorless" service. This completely broke Skaffold's ability to use `kubectl port-forward` on it, leading to endless "port taken" retries and cluster corruption.

To fix this with raw, native performance, we implemented a complete port-forwarding bypass:
- The `CiliumEnvoyConfig` now spins up listeners natively bound to `0.0.0.0` on the node for ports `1111` and `1113`.
- `0ath.exe` natively maps Windows ports `1111` and `1113` straight into those Envoy listeners on the `k0s` Docker container.
- We completely stripped `skaffold` of its buggy port forwarding rules for these services.
- Added a robust `kubectl wait` to the `0ath.exe dev` bootstrap to ensure the `CiliumEnvoyConfig` CRD is fully established before attempting to push the configuration, eliminating a silent race condition that was causing `EOF` connection drops.

## What Was Tested
- Both `0_ath_movement_server` and `0_ath_client` compile successfully with the new `github.com/quic-go/quic-go` dependencies.

## Validation Results
- The build succeeded. You should now be able to run `.\0ath.exe dev` to trigger the new builds via Skaffold!
- Wait for Skaffold to finish building the new `shdynila/0_ath_movement_server` and `shdynila/0_ath_client` images and deploy them, then open the client!
