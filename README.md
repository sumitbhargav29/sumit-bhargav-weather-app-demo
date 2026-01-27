# sumit-bhargav-weather-app-demo

README.md
 

# Design System – Visual Effects

This folder contains **custom SwiftUI visual effects** that define the glassmorphic look and feel of the Glasscast app.

These effects are part of the **UI Design System** and are intentionally isolated from
business logic, networking, and domain models.

---

## 🌊 LiquidGlass Effect

`LiquidGlass` is a GPU-accelerated glass distortion effect built using **SwiftUI + Metal shaders**.

### Files

* **`LiquidGlass.swift`**

  * SwiftUI `ViewModifier`
  * Public API used throughout the app
  * Handles:

    * Light / Dark mode adaptation
    * Materials, strokes, shadows
    * Shared animation timing (battery-optimized)

* **`LiquidGlass.metal`**

  * Custom Metal shader (`liquidRefraction`)
  * Performs per-pixel refraction distortion
  * Optimized for performance and low power usage

---

## 🧠 Architectural Notes

* Lives entirely in the **UI layer**
* Has **no dependency** on ViewModels, Services, or Models
* Metal shader is an **implementation detail**
* Swift file is the **only public interface**

This separation allows:

* Easy refactoring or replacement
* Clean MVVM boundaries
* Reuse across multiple views

---

## ⚡ Performance Considerations

* Uses a **shared animation timer** (`LiquidGlassTimer`)
* Runs at **30 FPS** instead of 60 FPS to reduce battery usage
* Automatically starts/stops based on visible views
* Shader math is intentionally low-frequency to reduce GPU load

---

## 🧪 Testing Strategy

* Not unit tested (GPU shaders are non-deterministic)
* Validated using:

  * Visual inspection
  * Instruments → GPU & Energy profiling
  * Real device testing

---

## 🧩 Usage Example

```swift
VStack {
    Text("Glass Card")
}
.liquidGlass(cornerRadius: 24, intensity: 0.4)
```

---

# App Configuration & Backend Setup

The Glasscast app uses **Supabase** as its backend for authentication and data storage.

All sensitive values are handled using **Xcode User-Defined Build Settings**, ensuring
that secrets are never hardcoded or committed to the repository.

This approach provides:

* Better security
* Cleaner architecture
* Safe public repository sharing

---

## 🔐 Supabase Overview

Supabase is used for:

* Email & password authentication
* User-specific data storage
* Secure REST API access

High-level setup:

* Supabase project created via dashboard
* Email/password authentication enabled
* Database tables managed via Supabase SQL Editor
* Supabase Swift SDK used on the client

> Backend credentials are never committed to source control.

---

## 🌱 Environment Variables

Sensitive configuration values are managed using **Xcode User-Defined Build Settings**.

### Variables Used

```text
SUPABASE_URL=your-supabase-project-url
SUPABASE_ANON_KEY=your-supabase-anon-key
WEATHER_API_URL=weather-api-base-url
WEATHER_API_KEY=weather-api-key
```

⚠️ All values shown above are **placeholders**.
Actual values are configured locally in Xcode and are not included in version control.

---

## 🛠 Configuration via Xcode (User-Defined Settings)

Environment variables are configured directly in **Xcode Build Settings**.

### Setup Flow

1. Open the project in **Xcode**
2. Select the **App Target**
3. Go to **Build Settings**
4. Scroll to **User-Defined**
5. Add the following keys:

   * `SUPABASE_URL`
   * `SUPABASE_ANON_KEY`
   * `WEATHER_API_URL`
   * `WEATHER_API_KEY`
6. Assign values per build configuration (Debug / Release)

### Info.plist Injection

The values are referenced inside `Info.plist` using:

```text
$(SUPABASE_URL)
$(SUPABASE_ANON_KEY)
$(WEATHER_API_URL)
$(WEATHER_API_KEY)
```

---

## 📦 Accessing Configuration in Code

At runtime, configuration values are read from `Info.plist` via `Bundle.main`.

Usage pattern:

* Values injected at build time
* Accessed at runtime
* App validates required keys during initialization

This ensures configuration issues are detected early during app launch.

---

## 🔒 Security Notes

* API keys are **not hardcoded**
* Secrets are **not committed** to the repository
* User-Defined settings remain local to the developer machine
* Keys can be rotated without code changes

This setup keeps the repository secure while remaining simple and transparent.

---

## ▶️ Running the App

1. Clone the repository
2. Configure User-Defined values in Xcode
3. Open the project in Xcode
4. Run on simulator or device

> The app will not run without valid environment variables configured locally.

---

