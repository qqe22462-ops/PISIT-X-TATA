# Introduction

**PISIT HUB** is a production-grade UI library for Roblox, built entirely from scratch in Luau. It is designed for developers who need a polished, reliable, and easily extensible interface for scripts, admin panels, or in-game tools.

## Why PISIT HUB?

- **Original architecture.** PISIT HUB does not copy the internals, layout code, or visual structure of any existing library (Rayfield, Fluent, Orion, etc). Every module in `src/` is written independently around its own component system.
- **Signature theme.** A dark, high-contrast red-on-black identity (`#DC1E1E` accent on `#0F0F0F` background) with glowing red borders, designed to feel premium rather than "boxy."
- **Full component set.** Windows, Tabs, Sections, Buttons, Toggles, Sliders, Dropdowns, Textboxes, Paragraphs, Labels, Keybinds, Color Pickers, Notifications, a Theme Manager, a global Search Box, Mini Mode, and a full Config save/load/auto-save system.
- **Responsive by default.** Every element is built with `UICorner`, `UIStroke`, `UIPadding`, and `UIListLayout`, and the library detects touch-only devices to adjust default window sizing automatically.
- **No external dependencies.** Everything ships as plain `ModuleScript` files that `require()` each other. No HTTP requests, no third-party loaders required to use the library itself.

## Design Philosophy

PISIT HUB follows three rules throughout its codebase:

1. **One file, one responsibility.** `Theme.lua` only knows about colors. `Animation.lua` only knows about tweens. `Config.lua` only knows about persistence. This makes the library predictable to extend.
2. **Elements are self-contained objects.** Every `CreateX()` call returns a Lua object with its own `Instance`, its own `Set`/`Get` methods, and its own Theme/Config wiring. Nothing reaches back into Window internals.
3. **Fail safely.** Callbacks are wrapped in `pcall` (see `Utility.SafeCall`), and file I/O in `Config.lua` is guarded so the library never hard-crashes on platforms without filesystem access.

## Where to go next

- [Installation](Installation.md) — how to load PISIT HUB into your script.
- [Getting Started](Getting%20Started.md) — build your first window in under two minutes.
- [Window](Window.md), [Tab](Tab.md), [Section](Section.md) — the structural building blocks.
- [Examples](Examples.md) — full copy-paste scripts.
