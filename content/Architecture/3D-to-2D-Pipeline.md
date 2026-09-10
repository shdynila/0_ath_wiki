---
title: "3D to 2D Rendering Pipeline"
date: 2026-09-07
tags: ["architecture", "graphics", "pipeline"]
---

# 3D to 2D Rendering Pipeline

## Overview
Because Ebitengine is a 2D engine, we need to adapt the existing TLBB 3D `.mesh` assets into 2D sprites. To accomplish this, we designed a standalone 3D-to-2D asset conversion pipeline.

## Pipeline Components

1. **Ogre3D Conversion (`convert_to_xml.ps1`)**
   - Utilizes `OgreXMLConverter.exe` to parse the proprietary binary `.mesh` and `.skeleton` files from `tlbb-assets`.
   - Converts the models into standard `.xml` formats that can be imported into modern DCC (Digital Content Creation) tools.

2. **Headless Blender Rendering (`render_sprites.py`)**
   - A Python script designed to run inside Blender's headless mode (`-b -P render_sprites.py`).
   - Sets up a strict isometric orthographic camera (45 degrees down, 45 degrees rotated).
   - Loads the Ogre XML data and materials.
   - Iterates over 8 cardinal directions and renders transparent `.png` frames for the character animations.

3. **Sprite Packing (`pack_sprites.go`)**
   - A Go utility that combines the thousands of individual `.png` frames into unified spritesheets.
   - Encodes direction and frame index logic into the spritesheet grid so the client can easily calculate UV coordinates.

## Client Integration
The `0_ath_client` has been updated to dynamically load and display a placeholder 2D character sprite, substituting the placeholder white rectangle in the rendering loop. Upon execution of the pipeline, the placeholder can be seamlessly swapped out for the actual processed TLBB spritesheets.
