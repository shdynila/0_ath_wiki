---
title: "Refactoring Authentication and Signup to gRPC Auth Server"
date: 2026-06-18T22:25:00+02:00
tags: ["auth", "grpc", "keycloak", "refactoring"]
---

# Refactoring Authentication & Signup to gRPC Auth Server

We have refactored the auth and signup pipelines to run through a dedicated `0_ath_auth_server` over gRPC.

## Architecture Before vs After

### Before
* Client performed HTTP REST calls directly to Keycloak's token endpoint on port `8080` to log in.
* Client performed HTTP REST POST calls to the gateway on port `1113`, which routed to `0_ath_core_server` to signup (bridging to Keycloak Admin REST API).
* Legacy `0_ath_auth_server` (built with Goa Design and PostgreSQL) was completely deprecated and unused.

### After
* Client communicates exclusively with the Envoy Gateway on gRPC port `1111` for all actions, including login and signup.
* Envoy Gateway routes `/service.login.LoginService` requests to the new `0_ath_auth_server` running on port `1117`.
* `0_ath_auth_server` acts as the secure Keycloak API bridge, keeping Keycloak admin credentials and endpoint details isolated from the game client.
* HTTP port `1113` and the registration handlers have been completely removed from `0_ath_core_server`.
