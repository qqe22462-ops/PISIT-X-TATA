# Dropdown

A collapsible option list supporting single or multi-select, an internal search box, and runtime option management.

## Creating a Dropdown

```lua
local Dropdown = Section:CreateDropdown({
    Title = "Select Target",
    Options = {"Closest", "Lowest Health", "Highest Health"},
    Default = "Closest",
    Multi = false,
    Searchable = true,
    Flag = "TargetMode",
    Callback = function(value)
        print("Selected:", value)
    end,
})
```

For multi-select:

```lua
local Dropdown = Section:CreateDropdown({
    Title = "Enabled Modules",
    Options = {"ESP", "Aimbot", "Fly", "Noclip"},
    Default = {"ESP", "Fly"},
    Multi = true,
    Flag = "EnabledModules",
    Callback = function(values)
        print("Selected:", table.concat(values, ", "))
    end,
})
```

## Config table

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | string | `"Dropdown"` | Label shown when nothing is selected (or, in multi-select, the count of selections). |
| `Options` | `{string}` | `{}` | Initial list of selectable option strings. |
| `Default` | string \| `{string}` | `nil` | Initial selection. String for single-select, array for multi-select. |
| `Multi` | boolean | `false` | Enables multi-select (checkbox-like) behaviour. |
| `Searchable` | boolean | `true` | Shows an internal search box to filter long option lists. |
| `Flag` | string | `Title` | Config persistence key. |
| `Callback` | function | no-op | Called with the new selection (`string` or `{string}`) on change. |

## Methods

| Method | Description |
|---|---|
| `Dropdown:Refresh(list)` | Rebuilds the option list from a new array of strings. |
| `Dropdown:AddOption(name)` | Appends a single option without rebuilding the whole list. |
| `Dropdown:RemoveOption(name)` | Removes a single option by name (also clears it from the selection if selected). |
| `Dropdown:Get()` | Returns the current selection (`string` for single-select, `{string}` for multi-select). |
| `Dropdown:SetSelected(value)` | Sets the selection programmatically. |
| `Dropdown:Toggle()` / `OpenMenu()` / `Close()` | Controls the expand/collapse state. |

## Behaviour

- Single-select automatically closes the dropdown after a choice; multi-select stays open so multiple options can be toggled.
- The search box (when `Searchable = true`) filters the visible option buttons live as you type, without touching the underlying `Options` list.
