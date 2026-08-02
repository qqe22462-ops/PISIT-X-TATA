# Toggle

An on/off switch with a smoothly sliding knob, default value support, and automatic Config persistence.

## Creating a Toggle

```lua
local Toggle = Section:CreateToggle({
    Title = "Enable Feature",
    Default = false,
    Flag = "EnableFeature",
    Callback = function(value)
        print("Feature enabled:", value)
    end,
})
```

## Config table

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"Toggle"` | Label text. |
| `Default` | boolean | `false` | Initial state. |
| `Flag` | string | `Title` | Unique key used by `Config.Save`/`Config.Load`. |
| `Callback` | function | no-op | Called with the new boolean value whenever it changes by user interaction. |

## Methods

| Method | Description |
|---|---|
| `Toggle:Set(value)` | Sets the value programmatically and fires the animation + callback. |
| `Toggle:Get()` | Returns the current boolean value. |

## Notes

- Every Toggle is automatically registered with [Config](Theme.md) under its `Flag`, so it will be included in `Library:SaveConfig()` / restored by `Library:LoadConfig()` without any extra code.
- When a value is restored from a saved config, the callback is intentionally **not** re-fired (to avoid re-triggering side effects like re-equipping items during load) — only direct user clicks or explicit `Toggle:Set(value)` calls fire the callback.
