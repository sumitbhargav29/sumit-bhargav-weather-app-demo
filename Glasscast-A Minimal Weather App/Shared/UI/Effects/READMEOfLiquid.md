# LiquidGlass – Metal-Powered Glassmorphism for SwiftUI

LiquidGlass is a lightweight, battery-conscious visual effect that brings realistic glassmorphism to SwiftUI using a custom Metal shader. It creates a subtle, dynamic refraction of background content to simulate translucent glass with liquid-like motion.

This document explains the concepts, architecture, and usage of the LiquidGlass effect and its underlying Metal implementation.

---

## What Is Glassmorphism?

Glassmorphism is a UI style characterized by:
- Translucent surfaces with background blur/refraction
- Soft highlights and inner/outer strokes
- Subtle shadows and depth
- Adaptive appearance in Light and Dark modes

LiquidGlass focuses on physical plausibility and performance by simulating how light refracts through frosted glass using a GPU shader.

---

## Why Metal for Glass Effects?

While SwiftUI materials (e.g., .ultraThinMaterial) provide built-in translucency, Metal enables:
- Custom refraction models with controllable intensity and frequency
- Per-pixel distortion for a “liquid” look
- Fine-grained performance tuning (reduced frequency, shared timers)
- Consistent visuals across views with a single effect pipeline

LiquidGlass combines SwiftUI ergonomics with a Metal shader for the best of both worlds.

---

## Architecture Overview

- LiquidGlass.swift (public API)
  - SwiftUI ViewModifier and convenience `.liquidGlass(...)` view extension
  - Configures materials, strokes, shadows
  - Adapts to Light/Dark mode
  - Connects to a shared animation timer to minimize power usage
- LiquidGlass.metal (implementation detail)
  - `liquidRefraction` kernel function
  - Samples a background texture and applies per-pixel UV distortion
  - Parameters: time, intensity, scale, direction, noise

Design goals:
- Encapsulation: Metal is private; SwiftUI API is stable and easy to use
- Testable visuals: predictable aesthetic with tunable parameters
- Battery-aware: shared timer at 30 FPS and low-frequency math

---

## How the Effect Works

1. Background Sampling
   - The shader receives a snapshot/texture of the content behind the glass.
   - Each output pixel maps to a UV coordinate in that background.

2. Per-Pixel Refraction
   - The shader computes a small offset to the UV coordinate using time-based noise/wave functions (e.g., sin/cos, simplex-like noise).
   - The offset magnitude is controlled by intensity and scale parameters.
   - The result mimics how light refracts through imperfect glass.

3. Composition
   - The distorted background is combined with subtle tinting, highlights, and strokes at the SwiftUI layer.
   - Optional shadows provide depth without heavy blur passes.

4. Animation
   - Time is driven by a shared LiquidGlassTimer to keep all instances in sync and to reduce CPU/GPU wakeups.
   - The effect runs at 30 FPS for energy efficiency.

---

## Key Parameters

- intensity: Controls how strong the refraction distortion appears (recommended 0.2–0.5).
- scale/frequency: Adjusts the size of the “waves” in the distortion; larger scales look smoother and more glass-like.
- speed: How quickly the liquid motion flows over time.
- direction/phase: Optional controls to bias motion in a particular direction or introduce phase offsets for variation.

Tip: Subtle values look more natural and conserve power.

---

## Performance Considerations

- Shared Timer (LiquidGlassTimer)
  - One timer drives all instances to reduce scheduling overhead.
  - Lower tick rate (30 FPS) balances smoothness and battery life.

- Low-Frequency Math
  - Wave/noise functions are kept simple and low frequency to minimize ALU pressure.
  - No expensive multi-octave noise by default.

- Conditional Rendering
  - The effect can pause updates when off-screen or not visible.
  - Consider reducing intensity or disabling animation for static screens.

- Metal Best Practices
  - Use linear color space sampling where appropriate.
  - Avoid unnecessary texture copies/bindings.
  - Prefer smaller intermediate textures on memory-constrained devices.

---

## Visual Design Tips

- Pair with a subtle inner/outer stroke to define edges of the glass.
- Use a soft drop shadow to separate the glass from busy backgrounds.
- Apply a tint that adapts to Light/Dark mode (e.g., cool tint in light, warmer/tinted in dark).
- Keep motion minimal—too much refraction feels noisy and distracts from content.

---

## Example Usage (SwiftUI)

```swift
VStack(spacing: 12) {
    Text("Glass Card")
        .font(.title2.weight(.semibold))
    Text("Liquid refraction with Metal")
        .font(.footnote)
        .opacity(0.7)
}
.padding(20)
.liquidGlass(
    cornerRadius: 24,
    intensity: 0.35 // try 0.25–0.45
)
