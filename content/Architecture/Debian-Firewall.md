---
title: "Debian Iptables Firewall"
date: 2026-08-12
tags: ["debian", "security", "firewall", "kubernetes", "iptables"]
---

# Debian Iptables Firewall

Our bare-metal Hetzner server is running standard Debian. To ensure that our Kubernetes (`k0s`) cluster is protected from direct public internet access without conflicting with Cilium's eBPF networking, we use a targeted `iptables` configuration.

## Architecture

We avoid `ufw` entirely, as it overrides the default `FORWARD` policy to DROP and flushes iptables rules on restart, which breaks Kubernetes networking and Cilium.

Instead, we use `iptables-persistent` to load rules on boot. We have a provisioning script (`0_ath_manifests/infrastructure/firewall.sh`) which applies explicit `DROP` rules to the top of the `INPUT` chain on the external public interface (`eth0`).

### Protected Ports:
- **6443**: Kubernetes API Server
- **9443**: k0s Controller Metrics
- **10250**: Kubelet API
- **8132 / 8133**: Konnectivity Agents

This ensures that our internal Kubernetes ports are completely isolated from the internet, while our Cilium Gateway API (listening on ports 80/443) continues to serve web traffic smoothly. Remote administration is conducted strictly via SSH port forwarding through the loopback interface (`lo`).
