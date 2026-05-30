---
title: "Zero-Dependency Pub/Sub with Postgres"
date: 2026-05-30
tags: ["networking", "microservices", "chat", "postgres", "sqlc"]
---

# Zero-Dependency Pub/Sub with Postgres

As we fleshed out the **`0_ath_chat_server`**, we needed a way to broadcast chat messages across our microservice cluster so the `0_ath_gateway` could push them down to connected TCP clients. The standard industry approach would be to deploy Redis or NATS. 

However, to keep our deployment infrastructure lean, mean, and simple for this early stage, we chose to leverage **PostgreSQL's native `LISTEN/NOTIFY`** capabilities!

## The Architecture
1. **The Chat Server (`0_ath_chat_server`)**:
   - We integrated **SQLC** as our type-safe Go ORM. 
   - When a chat message arrives via gRPC, we insert it into a `chat_logs` table for persistence and moderation tracking.
   - Immediately after, we use SQLC to execute `SELECT pg_notify('global_chat', payload)` to fire the event directly into Postgres.

2. **The Gateway (`0_ath_gateway`)**:
   - The Gateway uses `github.com/lib/pq` to maintain an active `pq.Listener` on the `global_chat` channel.
   - Whenever Postgres fires the notification, a dedicated goroutine in the Gateway catches the JSON payload, deserializes it, and iterates over an `activeConns` map to broadcast the message down every single authenticated TCP socket.

## Why Postgres instead of Redis/NATS?
* **Simplicity**: We already need Postgres for our Game State and Auth databases. Reusing it for Pub/Sub means zero extra containers, zero extra monitoring, and a unified tech stack.
* **Transactional Integrity**: We can insert into the database and broadcast the message simultaneously.
* **The Caveat**: `LISTEN/NOTIFY` is excellent for low-to-medium throughput events like Chat or Global Announcements. It is *not* suitable for high-tick-rate loops like Player Movement—which is exactly why our Movement Server bypasses Pub/Sub entirely and uses direct UDP proxying via the Gateway!

We now have a fully functional, highly decoupled, and easily deployable Chat architecture.
