# Getting Started

This page walks through building a minimal but complete PISIT HUB interface.

## 1. Require the Library

```lua
local Library = require(game:GetService("ReplicatedStorage"):WaitForChild("PISIT_HUB"))
```

## 2. Create a Window

```lua
local Window = Library:CreateWindow({
    Title = "PISIT HUB",
    SubTitle = "v1.0.0",
    Theme = "Red", -- Red | Dark | Light | White | Black
})
```

`CreateWindow` builds the entire draggable frame, top bar, search box, minimize/close buttons, and mini-mode pill. It returns a `Window` object.

## 3. Create a Tab

```lua
local MainTab = Window:CreateTab({
    Title = "Main",
    Icon = "settings", -- optional, see Icons.lua
})
```

The first tab created is automatically selected/visible.

## 4. Create a Section

```lua
local GeneralSection = MainTab:CreateSection({
    Title = "General",
})
```

Sections are titled group boxes. You can create as many sections per tab as you like; they stack vertically and the tab's page scrolls automatically.

## 5. Add elements

```lua
GeneralSection:CreateButton({
    Title = "Say Hello",
    Callback = function()
        print("Hello from PISIT HUB!")
    end,
})

GeneralSection:CreateToggle({
    Title = "Enable Feature",
    Default = false,
    Flag = "EnableFeature",
    Callback = function(value)
        print("Feature enabled:", value)
    end,
})

GeneralSection:CreateSlider({
    Title = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        print("Walk speed set to", value)
    end,
})
```

## 6. Fire a notification

```lua
Library:Notify({
    Title = "Welcome",
    Content = "PISIT HUB loaded successfully.",
    Duration = 4,
    Type = "Success",
})
```

## 7. Save / load configuration

```lua
Library:SaveConfig("my_config")
Library:LoadConfig("my_config")
Library:EnableAutoSave("my_config", 15) -- autosave every 15 seconds
```

That's it — you now have a fully themed, draggable, searchable UI with persistent settings. Continue to the individual component pages ([Button](Button.md), [Toggle](Toggle.md), [Slider](Slider.md), ...) for the full option list of every element.
