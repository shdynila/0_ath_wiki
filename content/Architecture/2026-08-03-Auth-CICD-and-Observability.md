---
title: "Infrastructure: Auth CI/CD and Postgres Observability"
date: 2026-08-03T21:00:00Z
tags: ["infrastructure", "cicd", "observability", "netdata"]
draft: false
---

# Infrastructure Updates

We recently made several key improvements to the cluster's infrastructure, focusing on the Auth Server deployment pipeline and Database observability.

## Auth Server CI/CD Pipeline

During the migration from Keycloak to PocketBase, we discovered that while the local codebase was updated, the `shdynila/0_ath_auth_server` Docker image running in the Kubernetes cluster was severely outdated. 

Because there was no automated deployment pipeline, the old Keycloak logic was still executing in production, leading to DNS lookup errors.

To solve this, we implemented a dedicated GitHub Actions workflow for the Auth Server. It uses `ko` to compile the Go binary into a lightweight, distroless Docker image and pushes it directly to Docker Hub (`shdynila/0_ath_auth_server:latest`) whenever code is pushed to the `main` branch. 

## Netdata Postgres Integration

We expanded our observability stack by connecting Netdata natively to our internal Postgres database. By injecting a `postgres.conf` via the `go.d` data collector in the Netdata Helm chart, Netdata now tracks crucial internal metrics such as:

- Queries per second
- Cache Hit Ratios
- Lock and Deadlock occurrences
- Active Connections

This gives us zero-code visibility into database performance without requiring complex Grafana dashboards.
