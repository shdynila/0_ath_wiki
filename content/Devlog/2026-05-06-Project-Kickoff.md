# Devlog - 2026-05-06: Project Kickoff

## Today's Progress
- Transitioned focus onto building the **0ath MMORPG**.
- Established a dedicated Obsidian Vault at `/Documents/0ath` to graph out knowledge, game mechanisms, and devlogs.
- Set up **Qdrant** database via Docker Compose (`docker-compose.yml`) in the `prjcts` root to enable vector storage. This will make it easier for AI retrieval and potentially drive intelligent NPC logic or game analytics.
- Reviewed the **FKServer2** server architecture for inspiration. The concept of singleton Login/World servers combined with horizontally scaled Game Servers paired with ShareMemory will serve as our architectural north star.
- Our current microservice split includes:
  - `0_ath_auth_server`
  - `0_ath_movement_server`
  - `0_ath_client`
  - `0_ath_proto`

## Next Steps
- Validate the proto files and update them based on the new architectural insights.
- Start implementing the `WorldSvr` equivalent if not already present.
- Implement the `ShareMemory` / Cache mechanism (via `cache_service.proto` or Redis/Memcached) for crash recovery and quick state syncing.
- Tie Qdrant into the actual dev workflow (using Python or Go clients) to start vectorizing design documents.
