# Server Architecture

## Inspiration: FKServer2
The architecture is inspired by **FKServer2**, an open-source 3D MMORPG server architecture (tlbb-like).
Key characteristics of FKServer2:
- **BillingSvr & LoginSvr**: Singleton instances. They do not depend on ShareMemory.
- **WorldSvr**: Singleton instance. Usually co-located with a ShareMemory instance on the same physical machine.
- **Game Servers (Server)**: Form a 1-to-1 pair with a ShareMemory instance.
- **Cluster Layout**: A cluster typically consists of:
  - 1 x BillingSvr
  - 1 x LoginSvr
  - 1 x (WorldSvr + ShareMemory) pair
  - N x (Server + ShareMemory) pairs

## Current 0ath Architecture
Our goal is to build a microservices architecture from scratch, likely using Go and gRPC (as evidenced by our proto files).

### Services Found:
- **Auth Server** (`0_ath_auth_server`): Handling authentication, token generation (similar to Login/BillingSvr).
- **Movement Server** (`0_ath_movement_server`): Handling player movement updates in the scene.
- **Proto Definitions** (`0_ath_proto`):
  - `login_service.proto`
  - `world_service.proto`
  - `scene_service.proto`
  - `cache_service.proto` (possibly taking the role of ShareMemory)

### Proposed Data Flow
- Clients connect to the **Auth Server** to authenticate.
- Once authenticated, they connect to the appropriate **Scene Server** (or Game Server) for their zone.
- The **Movement Server** provides high-frequency coordinate syncing.
- The **World Server** manages cross-scene states, global chats, guild data, and coordinates between Scene Servers.
- **Qdrant** is running via Docker Compose to manage vector search queries, perhaps for AI entities, smart log aggregation, or dynamic content generation.
