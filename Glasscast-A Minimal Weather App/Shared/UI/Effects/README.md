README.md
# Design System – Visual Effects

This folder contains **custom SwiftUI visual effects** that define the glassmorphic look and feel of the Glasscast app.

These effects are part of the **UI Design System** and are intentionally isolated from
business logic, networking, and domain models.

---

## 🌊 LiquidGlass Effect

`LiquidGlass` is a GPU-accelerated glass distortion effect built using **SwiftUI + Metal shaders**.

### Files

- `LiquidGlass.swift`
  - SwiftUI `ViewModifier`
  - Public API used throughout the app
  - Handles:
    - Light / Dark mode adaptation
    - Materials, strokes, shadows
    - Shared animation timing (battery-optimized)

- `LiquidGlass.metal`
  - Custom Metal shader (`liquidRefraction`)
  - Performs per-pixel refraction distortion
  - Optimized for performance and low power usage

---

## 🧠 Architectural Notes

- This effect lives in the **UI layer**
- It has **no dependency on ViewModels, Services, or Models**
- The Metal shader is considered an **implementation detail**
- The Swift file is the **only public interface**

This separation allows:
- Easy refactoring or replacement
- Clean MVVM boundaries
- Reuse across multiple views

---

## ⚡ Performance Considerations

- Uses a **shared animation timer** (`LiquidGlassTimer`)
- Updates at **30 FPS** instead of 60 FPS to reduce battery usage
- Automatically starts/stops the timer based on visible views
- Shader math is intentionally low-frequency to reduce GPU load

---

## 🧪 Testing Strategy

- Not unit tested (GPU shaders are non-deterministic)
- Validated via:
  - Visual inspection
  - Instruments → GPU & Energy profiling
  - Real device testing

---

## 🧩 Usage Example

```swift
VStack {
    Text("Glass Card")
}
.liquidGlass(cornerRadius: 24, intensity: 0.4)
