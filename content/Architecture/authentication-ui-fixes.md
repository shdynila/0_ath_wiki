---
title: "Authentication and UI Layout Fixes"
date: "2026-06-14T10:44:00+00:00"
tags: ["auth", "keycloak", "ui", "bugfix"]
---

# Authentication and UI Layout Fixes

## Keycloak Registration Flow Bug
The OIDC Password Grant flow for `game_client` was failing with an `Account is not fully set up` error. This issue was caused by:
1. **Implicit Profile Constraints:** `game_client` leverages the default `profile` and `email` client scopes. When a user is registered purely with a username and password via the Admin API, Keycloak enforces the creation of required profile fields (`firstName`, `lastName`, and `email`), causing subsequent logins to halt on a `resolve_required_actions` directive. 
2. **Credential Processing API Inconsistencies:** The `credentials` attribute within the `POST /users` user creation payload is occasionally omitted by Keycloak unless exact preconditions are met.

**Resolution:**
The `0_ath_core_server` signup endpoint was updated to supply a `firstName` (dummy string "Player"), a `lastName` (the username), and an `email` (`[username]@0ath.local`).
Furthermore, to definitively bind the plaintext password to the user account, the registration flow was modified to extract the `Location` header (which points to the newly created user resource) and independently dispatch a `PUT /reset-password` request to correctly instantiate a permanent password credential.

## GUI Rendering Clipping
Error messages propagated back to the `0_ath_client` Ebitengine instance via the `guigui` input widgets were becoming hidden when their length exceeded the physical pixel width of the text input bounds.
- Enabled `WrapModeNormal` within the `guigui/basicwidget/textinput.go` support text label.
- Expanded the vertical space allocated to the `Login` container panel within `0_ath_client/gui/login.go` by dynamically adjusting layout parameters to prevent the expanded multiline text from rendering out of frame.
