# Window

The `Window` is the root container returned by `Library:CreateWindow()`. It owns the top bar, sidebar (tab list), page container, mini-mode pill, and the global search box.

## Creating a Window

```lua
local Window = Library:CreateWindow({
    Title = "PISIT HUB",     -- string, shown in the top bar and mini pill
    SubTitle = "v1.0.0",     -- string, optional, shown under the title
    Theme = "Red",           -- string, one of Theme.List(), defaults to "Red"
    Size = UDim2.fromOffset(560, 380), -- optional, overrides the responsive default
})
```

If `Size` is omitted, PISIT HUB automatically picks a sensible default: a fixed `560x380` pixel window on desktop, or `92% x 70%` of the screen on touch-only mobile devices.

## Methods

| Method | Description |
|---|---|
| `Window:CreateTab(config)` | Creates and returns a new [Tab](Tab.md). |
| `Window:SelectTab(tab)` | Programmatically switches the active tab. |
| `Window:ToggleMinimize()` | Collapses the window into the Mini Mode pill, or restores it. |
| `Window:Close()` | Plays the close animation and hides the window (state preserved). |
| `Window:Open()` | Reopens a window previously hidden with `Close()`. |
| `Window:Destroy()` | Permanently destroys the window and all of its Instances. |

## Dragging

The window is draggable from its top bar on both desktop (mouse) and mobile (touch), implemented in `Utility.MakeDraggable`.

## Search Box

The top bar includes a live search box. Typing filters every element across every tab/section by title, hiding non-matching elements and any section that has zero remaining visible elements. Clearing the search box restores everything.

## Mini Mode

Clicking the minimize (`-`) button in the top bar, or calling `Window:ToggleMinimize()`, animates the window closed and shows a small draggable pill with the window's title and a `+` button to expand it again. This is intended for cases where the user wants the UI out of the way without fully closing/losing state.

## Destroy UI

`Window:Destroy()` (or `Library:Destroy()` to destroy every window created by that Library instance) plays the close animation and then calls `:Destroy()` on the root `ScreenGui`, removing every descendant Instance from the game. This is irreversible; use `Close()`/`Open()` if you need to hide and later restore the same window.
