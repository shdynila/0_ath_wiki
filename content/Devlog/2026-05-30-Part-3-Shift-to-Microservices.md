---
title: "Part 3: The Shift to Microservices"
date: 2026-05-30
tags: ['microservices', 'grpc', 'envoy']
draft: false
---

As the feature set grew, the monolithic Go server started becoming cumbersome. We needed to scale the movement server independently of the chat server.

We split the backend into several microservices:
- **Auth Server**: Handles JWT generation and user login.
- **Movement Server**: Uses UDP for high-tick coordinate streaming.
- **Chat Server**: Handles global and local text chat over TCP/WebSockets.
- **Zone Server**: Manages the spatial grid and entity states.

To route traffic securely, we implemented **Envoy Gateway**. We also transitioned all our internal service-to-service communication to **gRPC** using Protobufs, which significantly reduced our serialization overhead.
