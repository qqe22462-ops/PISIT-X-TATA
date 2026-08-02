# Slider

A draggable numeric slider with a real-time value label, configurable min/max/increment, and full mouse + touch support.

## Creating a Slider

```lua
local Slider = Section:CreateSlider({
    Title = "Walk Speed",
    Min = 16,
    Max = 100,
    Increment = 1,
    Default = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        print("Walk speed set to", value)
    end,
})
```

## Config table

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"Slider"` | Label text. |
| `Min` | number | `0` | Minimum value. |
| `Max` | number | `100` | Maximum value. |
| `Increment` | number | `1` | Step size the value snaps to while dragging. |
| `Default` | number | `Min` | Initial value. |
| `Flag` | string | `Title` | Config persistence key. |
| `Callback` | function | no-op | Called with the new number whenever it changes by user interaction. |

## Methods

| Method | Description |
|---|---|
| `Slider:Set(value)` | Sets the value programmatically (clamped to `Min`/`Max`), animates the fill/knob, and fires the callback. |
| `Slider:Get()` | Returns the current numeric value. |

## Behaviour

- Clicking or dragging anywhere on the bar jumps the value to that position.
- Touch and mouse dragging are both supported via `UserInputService.InputChanged`.
- The value label updates in real time as you drag, not just on release.
