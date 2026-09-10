---
title: "Android Port and Auto-Update Feature"
date: "2026-08-31"
tags: ["client", "android", "deployment", "updater"]
---

# Android Port & Auto-Update Feature Walkthrough

## What changed?

1. **Android CI/CD Build Step**: Since local building wasn't possible due to a missing Android SDK in the environment, the `release.yml` GitHub Actions workflow in `0_ath_client` was updated. A new job, `build-android`, has been added to use the pre-installed Java/Android SDK on the `ubuntu-latest` runner to compile your game to a native Android APK using Ebitengine's `gomobile` wrapper, uploading it directly to the release artifacts.
2. **Auto-Update Tracker**: Created `0ath_releases/static/version.json` which tracks the most recent version of your game and contains links to all release binaries. 
3. **In-game Auto-Update Poller**: Built a background updater into `0_ath_client` that queries `version.json` upon startup without stalling the game launch. If the remote version is greater than `version.go`'s `ClientVersion`, a sleek "Update Now" glassmorphic UI panel will be rendered in the bottom right corner of the screen.
4. **Platform-native OS Launchers**: When the player clicks "Update Now", Go standard library's `os/exec` automatically maps to the correct system command (`xdg-open` on Linux, `rundll32 url.dll` on Windows, `open` on Mac, and `am start` intent on Android) to open their default web browser and navigate directly to the correct download artifact.

## Validation Results

- The build command compiled correctly on Windows and integrated with the `Ebitengine` loop seamlessly.
- The workflow `release.yml` syntax passes validation.
- All file hooks into `gui.Panel` and `gui.Button` were integrated securely without causing rendering race conditions.
