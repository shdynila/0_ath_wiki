---
title: "Part 4: Automation and Pipelines"
date: 2026-06-15
tags: ['automation', 'kubernetes', 'k0s', 'gitops']
draft: false
---

Managing 6 different microservices manually was a nightmare. 

We introduced **Taskfile.yml** to standardize our build, run, and proto generation commands. Then, we moved towards a true **GitOps** model.

We deployed a local **k0s** Kubernetes cluster to orchestrate our containers. Now, deploying a new version of the movement server is as simple as pushing a new Docker image and letting our manifests sync automatically. This set the stage for our production deployment strategy.
