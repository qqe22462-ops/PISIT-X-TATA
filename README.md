<div align="center">

# 🔴 PISIT HUB

**A from-scratch, production-grade UI Library for Roblox — built in Luau.**

`#DC1E1E` accent · `#0F0F0F` background · glowing red borders · fully responsive

[![Luau](https://img.shields.io/badge/Luau-Language-DC1E1E?style=for-the-badge)](https://luau-lang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-DC1E1E?style=for-the-badge)](#license)
[![Version](https://img.shields.io/badge/version-1.0.0-DC1E1E?style=for-the-badge)](#)

</div>

---

```
┌──────────────────────────────────────────────┐
│  PISIT HUB                              -  x  │
│  v1.0.0        [ Search elements...      ]    │
├───────────┬────────────────────────────────────┤
│  ▌ Main   │  General                            │
│    Settings│  ┌────────────────────────────┐    │
│           │  │ Say Hello            [ ⚫ ]  │    │
│           │  │ Enable Feature       [◯──]  │    │
│           │  │ Walk Speed      ▬▬▬●───  42 │    │
│           │  └────────────────────────────┘    │
└───────────┴────────────────────────────────────┘
```
*(ASCII preview — see [Examples.md](docs/Examples.md) for the full script that produces a real interface like this.)*

## ✨ Features

- 🪟 **Window** — draggable, minimizable (Mini Mode pill), closable/reopenable, fully destroyable
- 🗂️ **Tabs & Sections** — sidebar navigation with auto-sizing, scrollable group boxes
- 🔘 **Full component set** — Button, Toggle, Slider, Dropdown, Textbox, Paragraph, Label, Keybind, Color Picker
- 🔔 **Notifications** — stacked, queued, top-right, fade in/out, PISIT HUB icon badge
- 🎨 **Theme Manager** — 5 built-in themes (Red, Dark, Light, White, Black) + register your own at runtime
- 🔍 **Global Search Box** — instantly filter every element across every tab
- 💾 **Config System** — Save / Load / Auto Save, backed by JSON on disk
- 📱 **Responsive** — full mouse *and* touch support, adaptive default window sizing
- 🎬 **Animation-first** — every interaction (open/close, hover, click, ripple, glow, fade, slide, scale) is driven by `TweenService`
- 🧱 **Zero external dependencies** — pure Luau `ModuleScript` files, `require()`'d together

## 📦 Installation

```lua
-- Place the `src` folder (renamed to PISIT_HUB) under ReplicatedStorage, then:
local Library = require(game:GetService("ReplicatedStorage"):WaitForChild("PISIT_HUB"))
```

Full instructions, including executor/script-hub loading, are in [`docs/Installation.md`](docs/Installation.md).

## 🚀 Quick Example

```lua
local Library = require(game.ReplicatedStorage.PISIT_HUB)

local Window = Library:CreateWindow({
    Title = "PISIT HUB",
    SubTitle = "v1.0.0",
    Theme = "Red",
})

local Tab = Window:CreateTab({ Title = "Main", Icon = "settings" })
local Section = Tab:CreateSection({ Title = "General" })

Section:CreateButton({
    Title = "Say Hello",
    Callback = function()
        print("Hello from PISIT HUB!")
    end,
})

Section:CreateToggle({
    Title = "Enable Feature",
    Default = false,
    Flag = "EnableFeature",
    Callback = function(value)
        print("Feature enabled:", value)
    end,
})

Library:Notify({
    Title = "Welcome",
    Content = "PISIT HUB loaded successfully.",
    Type = "Success",
})
```

See [`docs/Examples.md`](docs/Examples.md) for a complete, multi-tab, multi-component script.

## 📁 Project Structure

```
PISIT_HUB/
├── src/
│   ├── init.lua        -- Library entry point
│   ├── Theme.lua        -- Palettes + live theme switching
│   ├── Window.lua        -- Root container, top bar, mini mode, search
│   ├── Tab.lua            -- Sidebar tab + content page
│   ├── Section.lua         -- Group box + element factories (incl. Keybind, ColorPicker)
│   ├── Button.lua
│   ├── Toggle.lua
│   ├── Slider.lua
│   ├── Dropdown.lua
│   ├── Textbox.lua
│   ├── Paragraph.lua
│   ├── Label.lua
│   ├── Notification.lua   -- Stacked/queued toast notifications
│   ├── Config.lua          -- Save / Load / Auto Save
│   ├── Animation.lua        -- Centralized TweenService helpers
│   ├── Utility.lua           -- Instance creation, signals, dragging, math helpers
│   └── Icons.lua              -- Icon id registry
├── docs/                        -- Full documentation site (Markdown)
└── README.md
```

## 📖 API Reference

| Call | Description |
|---|---|
| `Library:CreateWindow(config)` | Creates the root `Window`. |
| `Window:CreateTab(config)` | Creates a `Tab`. |
| `Tab:CreateSection(config)` | Creates a `Section`. |
| `Section:CreateButton(config)` | Adds a [Button](docs/Button.md). |
| `Section:CreateToggle(config)` | Adds a [Toggle](docs/Toggle.md). |
| `Section:CreateSlider(config)` | Adds a [Slider](docs/Slider.md). |
| `Section:CreateDropdown(config)` | Adds a [Dropdown](docs/Dropdown.md). |
| `Section:CreateTextbox(config)` | Adds a [Textbox](docs/Textbox.md). |
| `Section:CreateParagraph(config)` | Adds a [Paragraph](docs/Paragraph.md). |
| `Section:CreateLabel(config)` | Adds a one-line Label. |
| `Section:CreateKeybind(config)` | Adds a rebindable Keybind. |
| `Section:CreateColorPicker(config)` | Adds an RGB Color Picker. |
| `Library:Notify(data)` | Fires a [Notification](docs/Introduction.md). |
| `Library:SetTheme(name)` / `Library:RegisterTheme(name, palette)` | [Theme Manager](docs/Theme.md). |
| `Library:SaveConfig(name)` / `Library:LoadConfig(name)` / `Library:EnableAutoSave(name, interval)` | Config persistence. |
| `Window:ToggleMinimize()` / `Window:Close()` / `Window:Open()` / `Window:Destroy()` | Window lifecycle. |

Full documentation index: [`docs/Introduction.md`](docs/Introduction.md)

## 🪪 License

MIT — see below. Use PISIT HUB in any project, commercial or personal, with attribution appreciated but not required.

```
MIT License

Copyright (c) 2026 PISIT HUB

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

## 🙏 Credits

- Designed & built for the **PISIT HUB** project.
- Architecture, theming, animation system, and every component written from scratch in Luau — no code copied from Rayfield, Fluent, Orion, or any other UI library.
