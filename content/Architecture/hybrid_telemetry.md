---
title: "Hybrid PocketBase Architecture for Telemetry"
date: 2026-08-12T22:50:00Z
tags: ["telemetry", "pocketbase", "architecture", "ui"]
---

# Hybrid PocketBase Architecture

To balance the need for a lightweight, bespoke telemetry dashboard with the robust user management capabilities of PocketBase, the `telemetry-server` was redesigned using a hybrid architecture.

## Overview

Instead of replacing PocketBase entirely with raw SQLite, PocketBase is retained as the core backend engine. This ensures that:
- User management, authentication, and the Admin UI remain intact.
- The built-in REST API is available for querying records.
- Database schema and migrations are handled gracefully.

To address the UI requirements, a custom HTML/JS dashboard was built specifically for visualizing telemetry data (CPU/RAM, Network I/O, and SSH Drops).

## Implementation Details

1. **Embedded Frontend**: A sleek, dark-mode `index.html` file using Chart.js is embedded directly into the Go binary using the `//go:embed` directive.
2. **Router Interception**: The default PocketBase router is intercepted via the `OnServe` hook. The embedded frontend is served at the root path (`/`) using `apis.Static`.
3. **Public Data Access**: The `node_metrics` and `ssh_attempts` collections are configured with empty (`""`) `ListRule` and `ViewRule` properties, allowing the frontend to pull data unauthenticated while the backend still manages the schema securely.

This approach provides a powerful hybrid solution:
- `http://<ip>/`: Serves the bespoke, lightning-fast telemetry dashboard.
- `http://<ip>/_/`: Serves the standard PocketBase Admin UI for user management.
