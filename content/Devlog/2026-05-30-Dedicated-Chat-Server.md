---
title: "Dedicated Chat Server Architecture"
date: 2026-05-30
tags: ["networking", "microservices", "chat", "go"]
---

# Dedicated Chat Server Architecture

As part of our commitment to building a highly scalable MMO backend, we have successfully decoupled the Chat System into its own isolated microservice: `0_ath_chat_server`.

## Why Separate Chat?
In an MMO environment, chat generates an enormous amount of string allocation, garbage collection overhead, and I/O wait times. A server-wide broadcast can instantly flood the network stack. By separating chat from the `0_ath_core_server` (which handles combat, physics, and state validation), we ensure that a sudden influx of player messages will **never** cause combat lag spikes. 

## The Implementation
1. **Schema Update**: We created `service/chat_service.proto` in the `0_ath_proto` shared repository and moved `ChatMessage`, `ChatResponse`, and the `SendChat` RPC method out of the `world_service`.
2. **Chat Microservice**: We initialized the `0_ath_chat_server` repository which runs a lightweight gRPC server on `:50052`. It currently receives the messages and logs them, ready for the next phase (PubSub broadcasting).
3. **Gateway Routing**: The `0_ath_gateway` was updated to act as a smart proxy. When an authenticated client sends a `ChatMessage`, the gateway identifies the action type and routes the gRPC payload directly to the `0_ath_chat_server` (`:50052`), bypassing the Core Server entirely.
4. **Core Server Cleanup**: The `0_ath_core_server` was stripped of its chat logic, leaving it purely focused on its `Ping` and future game loop routines.

## Broadcast Mechanism (Next Steps)
Currently, the Chat Server only receives and acknowledges messages. To truly complete the chat feature, we will need to implement a fan-out mechanism. The likely approach will involve the Chat Server publishing messages to a Redis PubSub channel, which the Gateway (or an array of Gateways) will subscribe to and broadcast to all connected TCP clients.
