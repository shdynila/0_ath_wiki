# 0ath MMORPG Knowledge Base

Welcome to the 0ath MMORPG documentation and devlog graph.

## Quick Links
- **Architecture**:
  - [[Server_Architecture]]
  - [[AI_Knowledge_Service]]
  - [[Protobuf_Workflow]]
- **Devlogs**:
  - [[2026-05-06-Project-Kickoff]]
  - [[2026-05-06-AI-and-NPC-Updates]]

## Infrastructure
- **Qdrant**: Used as the vector database to store game-related unstructured data, chat logs, AI NPC memories, and documentation retrieval. It runs via Docker Compose in the project root.
- **Ollama**: Local AI runner powering NPC responses using the `gemma` model.
- **Microservices**:
  - `0_ath_auth_server` (Auth & Tokens)
  - `0_ath_movement_server` (UDP high-tick coordinate streaming)
  - `0_ath_knowledge_service` (gRPC wrapper for AI & Qdrant)
  - `0_ath_client` (Ebitengine Go Client)
  - `0_ath_proto` (gRPC definitions using Buf)
  - `0_ath_knowledge_sync` (Auto-syncs this Obsidian vault to Qdrant)
