# Textbox

A single-line text input with placeholder text, a clear button, and focus glow animation.

## Creating a Textbox

```lua
local Textbox = Section:CreateTextbox({
    Title = "Player Name",
    Placeholder = "Enter a username...",
    Default = "",
    ClearOnFocus = false,
    Flag = "TargetPlayerName",
    Callback = function(value)
        print("Submitted:", value)
    end,
})
```

## Config table

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"Textbox"` | Label shown above the input. |
| `Placeholder` | string | `"Enter text..."` | Placeholder text shown when empty. |
| `Default` | string | `""` | Initial text content. |
| `ClearOnFocus` | boolean | `false` | Whether the box clears itself when clicked/focused. |
| `Flag` | string | `Title` | Config persistence key. |
| `Callback` | function | no-op | Called with the current text when Enter is pressed. |

## Methods

| Method | Description |
|---|---|
| `Textbox:Set(value)` | Sets the text programmatically. |
| `Textbox:Get()` | Returns the current text. |
| `Textbox:Focus()` | Forces keyboard focus onto the box. |
| `Textbox:Clear()` | Clears the text (equivalent to `Set("")`). |

## Notes

- The callback fires only when Enter is pressed, not on every keystroke, to avoid flooding downstream logic. If you need live updates as the user types, read `Textbox.Value` directly (it is kept in sync on every keystroke).
- The border glows via `Animation.Glow` while the box is focused.
