---
title: "Part 5: Client Modes and Dedicated Chat"
date: 2026-06-20
tags: ['client', 'chat', 'architecture']
draft: false
---

One of the biggest recent architectural changes was stripping physics from the client entirely. We moved to a "Dumb Client" model, where the server is fully authoritative over movement, collision, and state. The client only renders what the server tells it to render.

We also completely decoupled the Chat Server from the Zone Server. This allows players to remain connected to the global chat even if their local Zone Server crashes or they are transitioning between zones.
