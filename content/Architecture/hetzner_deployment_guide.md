---
title: "Hetzner Server Deployment Guide"
date: 2026-07-18T23:30:00+02:00
tags: ["infrastructure", "gitops", "fluxcd", "hetzner"]
---

# Hetzner Production Deployment

This guide documents the exact steps required to provision a brand-new Hetzner server and bootstrap it into a fully autonomous, self-healing MMO production node using **k0s**, **Cilium**, **SOPS**, and **FluxCD**.

## Step 1: Server Creation (Cloud-init)

When creating a new server (Debian/Ubuntu) in the Hetzner Cloud Console, paste the following script into the **Cloud-init** text box. 

This script configures `k0s` to natively use **Cilium** (disabling Kube-Router), installs the Gateway API CRDs required by Envoy, and installs the Flux CLI.

```yaml
#cloud-config
package_update: true
package_upgrade: true

write_files:
  - path: /etc/k0s/k0s.yaml
    permissions: '0644'
    content: |
      apiVersion: k0s.k0sproject.io/v1beta1
      kind: Cluster
      metadata:
        name: k0s
      spec:
        network:
          provider: custom
          kubeProxy:
            disabled: true
        extensions:
          helm:
            repositories:
            - name: cilium
              url: https://helm.cilium.io/
            charts:
            - name: cilium
              chartname: cilium/cilium
              version: "1.15.5"
              namespace: kube-system
              values: |
                kubeProxyReplacement: true
                k8sServiceHost: localhost
                k8sServicePort: 6443

runcmd:
  # 1. Install k0s Kubernetes using our custom config
  - curl -sSLf https://get.k0s.sh | sh
  - k0s install controller --single -c /etc/k0s/k0s.yaml
  - k0s start
  
  # 2. Wait for k0s to generate the admin config and link it for kubectl
  - sleep 25
  - mkdir -p /root/.kube
  - cp /var/lib/k0s/pki/admin.conf /root/.kube/config
  - chown root:root /root/.kube/config
  
  # 3. Install Kubernetes Gateway API CRDs (required by Envoy)
  - k0s kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/experimental-install.yaml
  
  # 4. Install Flux CLI
  - curl -s https://fluxcd.io/install.sh | bash
  
  # 5. Alias k0s kubectl so standard 'kubectl' commands work seamlessly
  - echo 'alias kubectl="k0s kubectl"' >> /root/.bashrc
```

## Step 2: SSH and Verify
Wait approximately 2 minutes after the server boots for Cilium to finish installing in the background.

1. SSH into the server: `ssh root@<HETZNER_IP>`
   - *(If you get a "Remote Host Identification Has Changed" warning from a previous server, run `ssh-keygen -R <HETZNER_IP>` on your local Windows PC to clear the old key).*
2. Verify pods are running: `kubectl get pods -A` (Ensure the `cilium` pods are running in `kube-system`).

## Step 3: Inject the SOPS Private Key
Flux needs your private Age key to decrypt passwords stored in the repository.

1. On your **Windows PC**, run: `Get-Content $env:APPDATA\sops\age\keys.txt` and copy the text starting with `AGE-SECRET-KEY-`.
2. On the **Hetzner server**, run:
```bash
kubectl create namespace flux-system
kubectl create secret generic sops-age --namespace=flux-system --from-literal=age.agekey="YOUR_COPIED_KEY_TEXT"
```

## Step 4: Bootstrap Flux
Finally, connect the server to GitHub so it can pull the game servers autonomously.

1. On the **Hetzner server**, export your GitHub Personal Access Token (Classic):
```bash
export GITHUB_TOKEN="ghp_YOUR_CLASSIC_GITHUB_PAT"
```

2. Run the Flux Bootstrap command:
```bash
flux bootstrap github \
  --owner=shdynila \
  --repository=0_ath_manifests \
  --branch=main \
  --path=clusters/hetzner \
  --personal
```

> [!TIP]
> **What happens next?**
> Flux will install itself, connect to GitHub, read `infrastructure.yaml` and `services.yaml`, automatically decrypt your SOPS secrets, and deploy your entire MMO into the `default` namespace.
> 
> You can force a manual sync at any time using: `flux reconcile kustomization flux-system --with-source`
