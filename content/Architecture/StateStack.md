---
title: "Client State Stack Architecture"
date: 2026-10-04
tags: ["architecture", "client", "ebiten", "ui"]
---

# Modular State Stack Architecture

To cleanly manage multiple overlapping interactive layers—such as the core gameplay loop, right-click context menus, and future inventory panes—we have transitioned the client to a **State Stack (Pushdown Automaton)** architecture.

## The State Interface

Every distinct screen or overlay in the game must implement the `State` interface:

```go
type State interface {
	Init() error
	Update(stack *StateStack) error
	Draw(screen *ebiten.Image)
	Destroy()
}
```

## The State Stack

The `StateStack` struct manages an ordered slice of these States:

- **Update Loop:** Input and logic update events are routed exclusively to the **top-most state**. If you open a context menu, it intercepts the inputs, preventing you from accidentally moving your character underneath it. If the state determines it doesn't need to capture an input, it can simply skip it or pop itself off the stack.
- **Draw Loop:** Rendering is performed from the **bottom-up**. The foundational `GameplayState` renders the entire world first. Then, the `ContextMenuState` renders its UI on top, ensuring perfect visual composition without tangling their specific drawing logic together.

## Implementation Example

The massive monolith that previously controlled the game was refactored into the foundational `GameplayState`. 
When a player right-clicks a tree in the world, the `GameplayState` pushes a temporary `ContextMenuState` onto the stack:

```go
stack.Push(&ContextMenuState{
    TargetID: treeID,
    ScreenX:  mouseX,
    ScreenY:  mouseY,
})
```

The menu remains on the screen until the user makes a selection or clicks away, at which point it calls `stack.Pop()` to destroy itself and return focus entirely to the `GameplayState`.
