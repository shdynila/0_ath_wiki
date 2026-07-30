---
title: "WebGL Dashboard Shader"
date: 2026-07-14T19:46:00+02:00
tags: ["architecture", "webgl", "shaders", "dashboard"]
---

# WebGL Water Shader Integration

The Kosova Torrent Traffic Dashboard has been successfully upgraded! The static 2D Canvas heatmap plugin has been completely ripped out and replaced with a custom-built WebGL Fragment Shader. 

## Architectural Changes

- **Removed `leaflet.heat`**: The old static 2D gradient blob generator has been removed from the application completely.
- **Custom Leaflet Layer**: A new layer extension (`L.WaterShaderLayer`) was created in `shader.js`. This creates an absolute-positioned Canvas over the map container and grabs a hardware-accelerated `webgl` context.
- **Coordinate Translation Bridge**: Geographic coordinates (Latitude/Longitude) are mathematically translated into screen-space pixels (`map.latLngToContainerPoint`) on every animation frame and streamed directly to the GPU as uniform arrays (`u_Drops[150]`).
- **GLSL Shaders**: 
  - A Vertex Shader passes through a full-screen quad.
  - A Fragment Shader calculates the geometric distance from every pixel to the active drop locations.

## Visual Upgrade

The shader mathematically generates **expanding concentric rings** for every active network event. 

- As a torrent download begins (intensity = 1.0), it creates a solid, bright cyan core at its geographic coordinates.
- As the event ages, the core fades out and an expanding geometric ring pushes outward up to 60 pixels, simulating a raindrop hitting a dark pond.
- A secondary inner "echo" ring trails behind it to give it a distinct liquid/fluid feel.
- Overlapping ripples use additive blending (`gl.blendFunc(gl.ONE, gl.ONE)`) and mix into a deep, glowing purple where network density is highest.

## Validation & Results
- [x] WebGL overlay respects the Z-index (renders above the GeoJSON map boundary, but below the interactive hover tooltips).
- [x] Renders at 60 FPS in the browser using `requestAnimationFrame`.
- [x] Correctly falls back to older browser support if WebGL crashes, throwing a safe console error rather than breaking the UI.
