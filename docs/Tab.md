# Tab

A `Tab` represents one entry in the Window's sidebar, paired with its own scrolling content page.

## Creating a Tab

```lua
local Tab = Window:CreateTab({
    Title = "Main",     -- string, shown in the sidebar
    Icon = "settings",  -- optional, icon name registered in Icons.lua
})
```

The first `Tab` created on a `Window` is automatically selected and its page becomes visible.

## Methods

| Method | Description |
|---|---|
| `Tab:CreateSection(config)` | Creates and returns a new [Section](Section.md) inside this tab's page. |
| `Tab:SetActive(active: boolean)` | Internal — toggles page visibility and sidebar highlight. Normally called via `Window:SelectTab`. |

## Behaviour

- Switching tabs is handled by `Window:SelectTab(tab)`, which deactivates the previously active tab and activates the new one.
- The active tab's sidebar button shows a glowing red indicator bar and highlighted (white) label text; inactive tabs use the muted `SubText` color.
- Each tab's page is an independent `ScrollingFrame` with `AutomaticCanvasSize` so content of any length scrolls correctly without manual canvas math.
