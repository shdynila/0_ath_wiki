---
title: "Part 1: The Kickoff and Modernizing"
date: 2026-05-01
tags: ['kickoff', 'architecture', 'ebitengine']
draft: false
---

Welcome to the development journey of **0ath**, our upcoming MMORPG. 

We started by moving away from the legacy C++ codebase of FKServer2. The old architecture was monolithic and hard to scale. We decided to rewrite the entire backend in **Go**, taking advantage of its incredible concurrency model (goroutines) and static compilation.

For the client, we chose **Ebitengine**, a dead-simple 2D game library for Go. This allowed us to share data structures directly between the server and the client without any translation layers.

The initial days were focused on proving that we could handle basic TCP connections and render a simple sprite on the screen. It wasn't pretty, but it was fast!
