---
title: "Dashboard & Infrastructure Routing Architecture"
date: 2026-09-14T21:54:00+02:00
tags: ["architecture", "kubernetes", "networking", "dashboards"]
---

# Dashboard & Infrastructure Routing Architecture

This document describes how our core internal services and dashboards are exposed in the cluster.

## NodePort Strategy vs Gateway API

Initially, we intended to use the Cilium Gateway API combined with `.nip.io` hostnames to route traffic seamlessly to various dashboards (Hubble, Perses, Telemetry) over port 80. However, relying on `.nip.io` proved fragile in certain networking environments due to DNS blocking and firewall rules.

### Transition to NodePorts
To ensure robust, DNS-independent access for developers and administrators, we shifted to a direct `NodePort` mapping strategy. All internal observability and infrastructure services are now assigned static NodePorts in the `31000-32000` range.

**Active Assignments:**
- `31116` / TCP+UDP: Game Server
- `31117` / TCP: Auth Service (gRPC)
- `31119` / TCP: Hubble UI (Cilium Observability)
- `31120` / TCP: Perses (Dashboarding)
- `31121` / TCP: Telemetry Service
- `31122` / TCP: Telemetry Service

### Firewall and Cloud-Init
Because these ports are accessed directly on the node's IP, they must be explicitly permitted by the node firewall. We use `ufw` inside our `hetzner-cloud-init.yaml` to automatically open these ports upon node provisioning. 

> **Important**: If the managed Hetzner Cloud Console Firewall is enabled for the VM, these ports must *also* be added to the Cloud Firewall inbound rules manually, as `ufw` operates inside the VM and cannot punch through the external cloud provider firewall.
