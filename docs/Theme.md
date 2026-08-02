# Theme

`Theme.lua` centrally manages every color palette in PISIT HUB and powers the live Theme Manager.

## Built-in themes

| Theme | Accent | Background | Description |
|---|---|---|---|
| `Red` (default) | `#DC1E1E` | `#0F0F0F` | The PISIT HUB signature theme. |
| `Dark` | `#DC1E1E` | `#0B0B0B` | Slightly darker, more neutral borders. |
| `Light` | `#DC1E1E` | `#F4F4F4` | Light background, dark text. |
| `White` | `#DC1E1E` | `#FFFFFF` | Pure white background variant. |
| `Black` | `#DC1E1E` | `#000000` | Pure black background, glowing red borders. |

Switch themes at any time:

```lua
Library:SetTheme("Dark")
```

Every element in the library listens to `Theme.OnChanged` and re-colors itself instantly — no need to rebuild the UI when switching themes.

## Registering a custom theme

```lua
Library:RegisterTheme("Ocean", {
    Accent = Color3.fromHex("#1E9DDC"),
    Background = Color3.fromHex("#0A0F14"),
    -- any omitted keys automatically fall back to the Red theme's values
})

Library:SetTheme("Ocean")
```

## Palette keys

Every theme must (eventually) define the following keys. `Theme.Register` automatically fills any missing key from the `Red` theme so partial palettes never break UI code:

- `Accent`, `AccentDim`
- `Background`, `SecondaryBackground`, `ElementBackground`
- `Border`
- `Text`, `SubText`
- `Success`, `Warning`, `Error`

## API reference

| Function | Description |
|---|---|
| `Theme.Register(name, palette)` | Adds or overwrites a theme. |
| `Theme.SetTheme(name)` | Switches the active theme and fires `Theme.OnChanged`. |
| `Theme.Get(key)` | Returns a single color from the currently active palette. |
| `Theme.List()` | Returns a sorted array of every registered theme name — useful for populating a Theme Manager dropdown. |
| `Theme.OnChanged:Connect(fn)` | Subscribes to theme changes; `fn(themeName, palette)`. |
