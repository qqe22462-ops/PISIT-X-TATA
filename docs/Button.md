# Button

A standard clickable button with hover glow, click-scale feedback, a ripple effect on press, and Enable/Disable state.

## Creating a Button

```lua
local Button = Section:CreateButton({
    Title = "Say Hello",
    Callback = function()
        print("Hello from PISIT HUB!")
    end,
})
```

## Config table

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"Button"` | Text shown on the button. |
| `Callback` | function | no-op | Called when the button is clicked. Wrapped in `pcall`. |

## Methods

| Method | Description |
|---|---|
| `Button:Disable()` | Dims the button and blocks clicks/ripple until re-enabled. |
| `Button:Enable()` | Restores a previously disabled button. |
| `Button:SetCallback(fn)` | Replaces the click callback at runtime. |
| `Button:SetTitle(text)` | Renames the button label at runtime. |

## Visual behaviour

- **Hover:** background tints toward the accent color.
- **Click:** the button briefly scales down, then bounces back (`Animation.Click`), and a circular ripple expands from the exact input position (`Animation.Ripple`).
- **Glow:** the button's border stroke briefly glows on click (`Animation.Glow`).
- 
