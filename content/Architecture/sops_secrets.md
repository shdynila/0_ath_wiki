---
title: "Kubernetes Secrets Management via SOPS"
date: 2026-07-16T20:30:00+02:00
tags: ["cli", "infrastructure", "secrets", "sops"]
---

# Secrets Management via SOPS

To securely commit Kubernetes secrets into the `0_ath_manifests` repository without leaking credentials, the ecosystem now utilizes **SOPS** paired with **Age**.

## Architecture Setup
- **Age Keys**: The host machine stores an `age` private key locally (in `~/.sops/age/keys.txt`).
- **SOPS Configuration**: A `.sops.yaml` file exists in the root of the manifests repository mapping `.sops.yaml` files to the generated public key.
- **Client-Side Decryption**: We do *not* run a dedicated Secrets Operator controller pod inside the cluster (like Bitnami Sealed Secrets) to conserve server resources. Instead, decryption happens entirely client-side.

## CLI Integration
The `0ath deploy` command has been heavily refactored to support this native GitOps workflow. 

When `0ath deploy` traverses the manifest directories:
1. Standard `.yaml` files are applied directly via `kubectl`.
2. Encrypted `.sops.yaml` files are intercepted. The CLI spawns a `sops -d` process to decrypt the file in memory, and pipes the stdout directly into `kubectl apply -f -`. 

This guarantees that unencrypted sensitive data (like GitHub Packages ImagePullSecrets or Database passwords) is never written to the disk during the deployment pipeline.
