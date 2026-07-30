---
title: "Client Distribution Strategy"
date: 2026-07-29
tags: ["architecture", "distribution", "client", "gatekeeper"]
---

# Client Distribution Strategy

Due to the restrictions imposed by macOS Gatekeeper and Windows Defender SmartScreen on binaries downloaded directly via web browsers (which append a strict quarantine attribute to files), the `0ath` MMO client is distributed using native terminal installation scripts.

## Installation Architecture

We provide universal installers that download the latest client binary using purely command-line utilities. This bypasses browser-induced quarantine tags, allowing the un-signed binaries to run flawlessly without paid Developer Certificates.

- **Windows**: `install.ps1` runs via PowerShell's `Invoke-WebRequest`. It places the game securely into `C:\Games\0ath` and opens the folder for the user.
- **Mac/Linux**: `install.sh` runs via `curl`. It fetches the corresponding OS/Arch zip file from our GitHub Releases, extracts it, and makes it executable.

## Pipeline Integration

This strategy pairs with our automated `release-please` GitOps pipeline. When a Release PR is merged, GitHub Actions builds the binaries and pushes them as `.zip` artifacts to the `shdynila/0_ath_releases` repository, where the install scripts fetch them directly from the API.
