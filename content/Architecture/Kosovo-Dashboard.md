---
title: "Kosovo Network Dashboard"
date: 2026-07-12T22:50:00+02:00
tags: ["dashboard", "hugo", "visualization", "leaflet"]
---

# Kosovo Network Dashboard

A new Hugo-based static dashboard has been created to visualize network activity across Kosovo.

## Architecture
- **Framework**: Hugo (Static Site Generator)
- **Mapping**: Leaflet.js with CartoDB Dark Matter tiles
- **Styling**: Custom CSS (Dark Theme, Glassmorphism)
- **Data Source**: Simulated front-end engine for testing and UI demonstration.

## Structure
The dashboard resides in `kosovo-dashboard`.
- `layouts/index.html` orchestrates the UI.
- `static/js/app.js` handles the mock data generation and Leaflet API interactions.
