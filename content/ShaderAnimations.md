# Shader Animations

We use **Ebitengine (Kage)** to create high-performance GPU shaders for various animations and effects in the MMO client.

## Player Glow (Subtle Pink Aura)

The player character features a solid pink core that exponentially fades into a highly transparent, subtle pink halo. The gradient mathematically follows the center of the character with zero drag or trailing.

```go
var playerGlowShader *ebiten.Shader

const smokeyShaderSrc = `package main

var Time float
var Center vec2
var Radius vec2
var PlayerPos vec2
var Velocity vec2
var DashIntensity float

func Fragment(dstPos vec4, srcPos vec2, color vec4) vec4 {
    // Perfectly centered glow, no velocity trail from WASD movement
    dist := distance(dstPos.xy, Center)

	// Expand radius dynamically based on dash
    maxRad := Radius.x * (1.0 + DashIntensity * 1.5)
    if maxRad <= 0.0 {
        return vec4(0.0)
    }
    
    normDist := dist / maxRad
    
    // Solid near the character (0.0 to 0.15), then smooth fade out to the edge
    glowAlpha := 1.0 - smoothstep(0.15, 1.0, normDist)
    
    // Apply an exponential curve to make the fade out look more gradual
    glowAlpha = glowAlpha * glowAlpha
    
    // Overall transparency multiplier (reduced to make it very subtle)
    glowAlpha *= 0.25
    
    // Bright Pink color (pre-multiplied by alpha)
    pinkColor := vec3(1.0, 0.2, 0.8) * glowAlpha * (1.0 + DashIntensity * 3.0) 
    
    return vec4(pinkColor, glowAlpha)
}
`
```

## Glowing Projectiles (Laser Lines)

When the player clicks to shoot, we render highly elongated rectangles that are rotated toward the velocity vector. We pass the local rectangle dimensions (`Size`) to the shader to compute the distance from the horizontal axis, resulting in a glowing laser beam effect.

```go
var projectileShader *ebiten.Shader

const projectileShaderSrc = `package main

var Size vec2

func Fragment(dstPos vec4, srcPos vec2, color vec4) vec4 {
    // Distance from the horizontal center line
    distY := abs(srcPos.y - Size.y/2.0)
    glowY := 1.0 - smoothstep(0.0, Size.y/2.0, distY)
    
    // Distance from the vertical ends
    distX := abs(srcPos.x - Size.x/2.0)
    glowX := 1.0 - smoothstep(Size.x/2.0 - 20.0, Size.x/2.0, distX)
    
    // Combine for a smooth glowing line
    alpha := glowY * glowX
    return vec4(0.8 * alpha, 0.2 * alpha, 1.0 * alpha, alpha) // Purple Glow
}
`
```
