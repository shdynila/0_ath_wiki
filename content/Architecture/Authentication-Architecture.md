---
title: "Authentication Architecture"
date: 2026-08-01T19:00:00Z
tags: ["auth", "pocketbase", "architecture"]
---

# Authentication Architecture

We have completely removed Keycloak in favor of PocketBase to drastically reduce the server memory footprint from ~1GB to ~15MB.

## Services Involved
1. **0_ath_auth_server (Go)**: A gRPC microservice exposing a `LoginService` that handles `Signup` and `Authenticate` requests directly from the Game Client.
2. **PocketBase (SQLite/Alpine)**: The Identity Provider. It exposes HTTP REST APIs for the Go auth service to call, and provides a sleek Admin UI to manage players.

## Data Flow
- **Signup**: The Game Client sends a gRPC request to `auth-service`. The `auth-service` forwards the request as an HTTP POST to PocketBase's `/api/collections/users/records` endpoint.
- **Login**: The Game Client sends a gRPC request to `auth-service`. The `auth-service` forwards the request to `/api/collections/users/auth-with-password`. PocketBase validates the credentials and returns a JWT access token, which `auth-service` returns to the Game Client.

## Admin Dashboard
The GM / Admin dashboard is accessible securely via the Cilium Gateway API at `http://37.27.37.253/pb/_/`.
