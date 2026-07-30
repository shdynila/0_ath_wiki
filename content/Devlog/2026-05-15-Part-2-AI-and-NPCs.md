---
title: "Part 2: Introducing AI and NPCs"
date: 2026-05-15
tags: ['ai', 'npcs', 'qdrant', 'ollama']
draft: false
---

A game feels dead without interactivity. Instead of writing massive state machines for NPC dialogue, we decided to integrate local Large Language Models (LLMs).

We set up **Ollama** running the `gemma` model locally. To give the NPCs long-term memory and context about the game world, we integrated **Qdrant** as our vector database.

Now, when a player talks to an NPC, the chat server sends the context to our `0_ath_knowledge_service`, which retrieves relevant lore from Qdrant and generates a dynamic response using Ollama. This completely changed the feel of the world!
