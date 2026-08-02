# Section

A `Section` is a titled group box inside a Tab's page. It is the factory for every leaf UI element in PISIT HUB.

## Creating a Section

```lua
local Section = Tab:CreateSection({
    Title = "General",
})
```

## Factory methods

Every method below creates an element inside this section's content area and returns the element object.

| Method | Returns | Docs |
|---|---|---|
| `Section:CreateButton(config)` | Button | [Button.md](Button.md) |
| `Section:CreateToggle(config)` | Toggle | [Toggle.md](Toggle.md) |
| `Section:CreateSlider(config)` | Slider | [Slider.md](Slider.md) |
| `Section:CreateDropdown(config)` | Dropdown | [Dropdown.md](Dropdown.md) |
| `Section:CreateTextbox(config)` | Textbox | [Textbox.md](Textbox.md) |
| `Section:CreateParagraph(config)` | Paragraph | [Paragraph.md](Paragraph.md) |
| `Section:CreateLabel(config)` | Label | — simple one-line text, see below |
| `Section:CreateKeybind(config)` | Keybind | — see below |
| `Section:CreateColorPicker(config)` | ColorPicker | — see below |

## Label

```lua
Section:CreateLabel({ Text = "Status: Idle" })
```

`label:SetText("Status: Running")` updates it live — useful for FPS counters, ping displays, or status readouts.

## Keybind

```lua
local Keybind = Section:CreateKeybind({
    Title = "Toggle ESP",
    Default = Enum.KeyCode.RightShift,
    Flag = "ToggleESPKey",
    Callback = function()
        print("ESP hotkey pressed")
    end,
})
```

Click the key label to enter listening mode, then press any keyboard key to rebind. `Keybind:Get()` returns the current `Enum.KeyCode`; `Keybind:Set(Enum.KeyCode.X)` rebinds it programmatically.

## Color Picker

```lua
local Picker = Section:CreateColorPicker({
    Title = "ESP Color",
    Default = Color3.fromRGB(220, 30, 30),
    Flag = "ESPColor",
    Callback = function(color)
        print("New color:", color)
    end,
})
```

PISIT HUB's color picker uses three draggable R/G/B channel bars with a live preview swatch — lightweight and dependency-free, while still fully covering the RGB color space. `Picker:Get()` returns a `Color3`; `Picker:Set(Color3.new(...))` sets it programmatically.

## Section layout

Sections stack vertically inside a Tab's page with 10px spacing, and every section auto-sizes its height to fit its contents (`AutomaticSize = Enum.AutomaticSize.Y`), so you never need to manually calculate heights when adding or removing elements at runtime.
