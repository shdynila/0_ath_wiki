# AI Knowledge Service & Sync

The knowledge ecosystem gives NPCs a "brain" and memory, integrating game mechanics with our devlog lore.

## 0_ath_knowledge_sync
A background Go service using `fsnotify`.
- **Purpose**: Watch the `C:\Users\nil\Documents\0ath` Obsidian vault for Markdown saves.
- **Mechanism**: Splits markdown, pings the local `Ollama` endpoint (running `Gemma`) to get a vector embedding, and upserts it to `Qdrant` locally on port `6333`.
- **Run Command**: `go run main.go` inside the `0_ath_knowledge_sync` dir.

## 0_ath_knowledge_service
A gRPC microservice designed to handle heavy AI computational loads without blocking the main game servers (`World`, `Scene`, `Movement`).
- **Port**: `50055`
- **Interface**: Defined in `knowledge_service.proto`.
  - `QueryKnowledge`: Fetches vector embeddings from Qdrant.
  - `GenerateNPCResponse`: Takes a player's message and contextual vector history to prompt Gemma for an immersive NPC response.
