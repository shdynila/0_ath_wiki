---
title: "Go Standard Layout Restructuring"
date: 2026-08-31
tags: ["golang", "refactoring", "architecture", "android"]
---

We've completed a major architectural overhaul of `0_ath_client` to support a native Android build while bringing the repository into alignment with standard Go layout conventions.

## 1. Repository Structure Modernization

The codebase now follows the [Go Standard Project Layout](https://github.com/golang-standards/project-layout):

- `cmd/`: Contains all executable entry points.
  - `cmd/desktop/main.go`: The main desktop game client.
  - `cmd/wobble/main.go`: The standalone wobble tool.
  - `cmd/mobile/mobile.go`: The entry point for the Ebitengine mobile binder.
- `internal/`: Contains all private application code (game logic, data, GUI).
  - `internal/client/`: Core game engine logic.
  - `internal/data/`: Game data structures.
  - `internal/gui/`: Ebitengine-native GUI components.
- `android/`: The Android wrapper project required by Ebitengine for `.apk` generation.

## 2. Android `.apk` Build Pipeline

The Android build process is now fully integrated into the `.github/workflows/release.yml` CI pipeline:

1. **Mobile Binder**: We use `ebitenmobile bind` to compile the `cmd/mobile` package into a native Android library (`.aar`), outputting to `android/app/libs/0ath_client.aar`.
2. **Android Wrapper**: The CI runner changes into the `android/` directory and executes `gradle assembleRelease`. 
3. **APK Generation**: Gradle bundles the `.aar` with the `AndroidManifest.xml` and `MainActivity.java` to produce the final `app-release-unsigned.apk`.

### Overcoming Ebitengine Constraints
During this process, we navigated several strict constraints:
- `ebitenmobile` cannot bind a `main` package, which necessitated extracting the 1,400-line monolithic engine into `internal/client`.
- `ebitenmobile` relies on `gomobile bind`, which generates a temporary `gobind` package outside the module. This violates Go's internal visibility rules if the mobile package is located inside `internal/`, which is why the mobile binder entry point lives in `cmd/mobile`.
- The GUI packages are fully self-contained using Ebitengine's native UI system (`guigui`), meaning they compile perfectly for Android without relying on CGO-dependent desktop libraries like Raylib.
