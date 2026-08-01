---
title: Centralized Logging (PLG Stack)
date: 2026-07-10
tags: [architecture, logging, k0s, grafana, loki, promtail]
---

# Centralized Logging in 0ath

As the MMO infrastructure grows into multiple microservices (Zone Server, Social Server, Data Server, etc.), reading raw text logs from individual machines via SSH becomes unscalable.

To solve this, we use the **PLG Stack (Promtail, Loki, Grafana)** for centralized logging.

## Components

1. **Promtail (The Courier):** Deployed as a DaemonSet to every k0s node. It discovers container log files, attaches Kubernetes metadata (like `pod_name`, `namespace`), and ships them.
2. **Loki (The Brain):** The central log storage system. It indexes logs by labels (not by full text) to remain highly efficient and cost-effective.
3. **Grafana (The UI):** Connects to Loki to visualize the logs using LogQL.

## Application Best Practices: Structured JSON Logging

While Promtail *can* read plain text, the true power of Loki is unlocked through **structured JSON logging**.

All Go services in `0_ath` MUST use the `log/slog` package to output JSON logs.

```go
package main

import (
	"log/slog"
	"os"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	slog.SetDefault(logger)

	slog.Info("Player connected", 
		"player_name", "nil", 
		"zone_id", 5,
	)
}
```

By logging in JSON, Grafana allows us to instantly filter logs based on the JSON keys:
`{app="zone-server"} | json | zone_id=5 | level="info"`

## Deployment

The stack is deployed via ArgoCD using the official `loki-stack` Helm chart. The manifest is located in `0_ath_manifests/infrastructure/logging-stack.yaml`.
