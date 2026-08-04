---
title: "Standalone Netdata Child and Hubble UI Gateway Routing"
date: 2026-08-04
tags: ["infrastructure", "netdata", "hubble", "cilium", "gateway-api", "k0s"]
---

## Overview

This architectural change updates the cluster's observability suite:
1. **Netdata Optimization**: Removed the resource-heavy `netdata-parent` pod to reduce RAM consumption on the single Hetzner node. Reconfigured `netdata-child` to operate in standalone mode (`memory mode = dbengine`, `bind to = *`) and exposed its dashboard via Cilium Gateway API.
2. **Hubble UI Routing Fix**: Solved React Router 404 routing errors in Hubble UI when hosted on subpaths by routing Hubble UI directly to a dedicated subdomain (`hubble.37.27.37.253.nip.io`) and adding an automatic 302 redirect for `/hubble/`.

## Architectural Changes

### Netdata Manifest Updates (`netdata.yaml`)
- Disabled `netdata-parent`.
- Added `bind to = *` to `child.configs.netdata` to accept external connections from Cilium Envoy.
- Updated `netdata-child` `Service` selector labels (`app: netdata`, `role: child`).

### Gateway Route Configuration (`gateway.yaml`)
- `observability-route`: Directs `/netdata/` requests to `netdata-child` on port 19999.
- `hubble-route`: Directs `hubble.37.27.37.253.nip.io` root requests to `hubble-ui` on port 80.
- `hubble-redirect-route`: Redirects legacy `/hubble/` requests directly to `http://hubble.37.27.37.253.nip.io/` via a `RequestRedirect` filter.

## Embedded NGINX Sidecar Fix (`hubble-ui-nginx` ConfigMap)
Updated the embedded `hubble-ui-nginx` ConfigMap in `kube-system` namespace:
- Kept `/api` unstripped so requests to `/api/control-stream` and `/api/service-map-stream` proxy intact to `127.0.0.1:8090`.
- Added `/healthz` returning 200 to ensure liveness probes succeed without falling into `/index.html` rewrite loops.
