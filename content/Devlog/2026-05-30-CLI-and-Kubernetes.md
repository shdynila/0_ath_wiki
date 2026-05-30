---
title: "The 0ath CLI and Local Kubernetes Automation"
date: 2026-05-30
tags: ["cli", "kubernetes", "k3d", "automation", "architecture"]
---

# The `0ath` CLI Orchestrator

As our microservice architecture grew to encompass 8 separate backend services, running them manually became unmanageable. To solve this, we created the `0ath-cli`—a dedicated orchestration tool built in Go using the `cobra` framework.

The CLI serves two primary purposes: 
1. **Local Development:** Running `0ath dev` spins up all our backend servers simultaneously via `os/exec`, multiplexing their logs into a single terminal window.
2. **Infrastructure Automation:** It handles the complex bootstrapping of our Kubernetes clusters.

# Local-First Kubernetes with `k3d`

We firmly believe in a "local-first" development mindset. To ensure every developer can spin up the full production topology on their local Windows machine, we integrated **`k3d`** automation directly into the CLI.

By running `0ath cluster create`, the CLI performs the following heavy lifting:
* **Bootstraps the Cluster**: Spins up a lightweight `k3s` cluster running inside Docker containers.
* **Port Forwarding**: Automatically maps the k3d LoadBalancer's TCP `8080` (for Actions/Auth) and UDP `8081` (for Movement) directly to the host machine's `localhost`.
* **Local Registry**: Initializes a local Docker registry at `localhost:5000`. This allows us to build Docker images locally and push them straight into the cluster without touching the public internet (DockerHub).

## Our Kubernetes Topology

Inside the `0ath-cli/k8s/` directory, we established the declarative YAML manifests that define our cluster:

1. **The Edge (`gateway.yaml`)**:
   The `0_ath_gateway` is the *only* service exposed to the public via a `LoadBalancer`. It routes incoming TCP XOR traffic and UDP packets.
2. **The Internal Mesh (`internal-services.yaml`)**:
   The Auth, Chat, Social, Combat, and Data servers are completely sealed off from the internet. They are exposed exclusively via internal `ClusterIP` Services, communicating entirely over internal cluster DNS.
3. **The Stateful Layer (`stateful-services.yaml`)**:
   Crucially, the `0_ath_movement_server` is deployed as a **`StatefulSet`**. This lays the foundation for map-sharding (e.g., `movement-server-0` handles City A, `movement-server-1` handles Forest B), ensuring pods retain stable network identities rather than being randomly destroyed by auto-scalers.
