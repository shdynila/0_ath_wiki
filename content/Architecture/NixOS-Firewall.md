---
title: "NixOS Declarative Firewall"
date: 2026-08-12
tags: ["nixos", "security", "firewall", "kubernetes"]
---

# NixOS Declarative Firewall

Our infrastructure relies on NixOS to declaratively configure the host-level firewall, ensuring that our Kubernetes (`k0s`) cluster is protected from direct public internet access.

## Architecture

By default, NixOS blocks all incoming connections. We explicitly whitelist required ports in `hosts/master/configuration.nix` using the `networking.firewall.allowedTCPPorts` setting.

To enforce a Zero-Trust perimeter:
1. **Public Ports:** Only ports `80` (HTTP), `443` (HTTPS), and `22` (SSH) are exposed to the public internet. 
2. **Kubernetes API:** Port `6443` (the k0s API server) and Kubelet APIs (`10250`) are blocked on public interfaces. Administration is performed either locally or via SSH port forwarding.
3. **Internal Node Routing:** Traffic between internal cluster interfaces (e.g., `cilium_host`, `cni0`, `flannel.1`) is fully trusted to allow pod-to-pod communication without iptables interference.

This setup pairs beautifully with our Cilium Gateway API, ensuring no traffic bypasses our ingress controller.
