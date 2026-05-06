# Devlog - 2026-05-06: AI, NPCs, and Buf Migration

## Today's Progress
1. **AI Knowledge Ecosystem**:
   - Built the `0_ath_knowledge_service` repository. It provides a gRPC interface (`knowledge_service.proto`) for generating NPC responses and retrieving lore.
   - Built the `0_ath_knowledge_sync` background Go tool. It watches this Obsidian vault recursively and pushes real-time document embeddings to our local Qdrant Vector database via Ollama (Gemma model).

2. **NPC Entity Rendering**:
   - Updated `0_ath_proto/player/location.proto` to include an `EntityType` enum so the client can differentiate players from NPCs.
   - Updated `0_ath_movement_server` to inject a permanent mock `NPC Guide` at coordinates `[400, 300]` and modified the UDP broadcast loop so NPCs don't get deleted via the timeout mechanism.
   - Updated `0_ath_client` rendering loop (`drawPlayers()`) to render the NPC uniquely as a red circle with an "NPC Guide" text tag, while rendering other players as green circles.

3. **Protobuf Migration to Buf**:
   - Replaced the clunky `create_proto_out.sh` with the modern `buf` toolchain.
   - Created `buf.yaml` and `buf.gen.yaml` to handle linting, breaking change detection, and standardized code generation.
   - Forced a clean push of `0_ath_proto` to GitHub to sync upstream.

## Next Steps
- Connect the NPC rendering in the client to a click-event/chat UI.
- Replace the mock responses in `0_ath_knowledge_service` with actual Qdrant similarity searches and LLM prompt chaining.
