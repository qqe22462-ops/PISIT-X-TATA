# Examples

## Full example script

```lua
local Library = require(game:GetService("ReplicatedStorage"):WaitForChild("PISIT_HUB"))

local Window = Library:CreateWindow({
    Title = "PISIT HUB",
    SubTitle = "v1.0.0",
    Theme = "Red",
})

-- === Main Tab ===
local MainTab = Window:CreateTab({ Title = "Main", Icon = "settings" })
local GeneralSection = MainTab:CreateSection({ Title = "General" })

GeneralSection:CreateParagraph({
    Title = "Welcome",
    Content = "This is an example configuration panel built with PISIT HUB.",
})

GeneralSection:CreateButton({
    Title = "Print Hello",
    Callback = function()
        print("Hello from PISIT HUB!")
    end,
})

GeneralSection:CreateToggle({
    Title = "Enable ESP",
    Default = false,
    Flag = "EnableESP",
    Callback = function(value)
        print("ESP:", value)
    end,
})

GeneralSection:CreateSlider({
    Title = "Field of View",
    Min = 60,
    Max = 120,
    Default = 90,
    Flag = "FOV",
    Callback = function(value)
        print("FOV set to", value)
    end,
})

GeneralSection:CreateDropdown({
    Title = "Target Priority",
    Options = {"Closest", "Lowest Health", "Highest Health"},
    Default = "Closest",
    Flag = "TargetPriority",
    Callback = function(value)
        print("Target priority:", value)
    end,
})

GeneralSection:CreateKeybind({
    Title = "Toggle Menu",
    Default = Enum.KeyCode.RightShift,
    Flag = "ToggleMenuKey",
    Callback = function()
        Window:ToggleMinimize()
    end,
})

GeneralSection:CreateColorPicker({
    Title = "ESP Color",
    Default = Color3.fromRGB(220, 30, 30),
    Flag = "ESPColor",
    Callback = function(color)
        print("ESP color:", color)
    end,
})

-- === Settings Tab ===
local SettingsTab = Window:CreateTab({ Title = "Settings", Icon = "settings" })
local ConfigSection = SettingsTab:CreateSection({ Title = "Configuration" })

ConfigSection:CreateButton({
    Title = "Save Config",
    Callback = function()
        local ok, message = Library:SaveConfig("default")
        Library:Notify({
            Title = ok and "Saved" or "Save Failed",
            Content = message,
            Type = ok and "Success" or "Error",
        })
    end,
})

ConfigSection:CreateButton({
    Title = "Load Config",
    Callback = function()
        local ok, message = Library:LoadConfig("default")
        Library:Notify({
            Title = ok and "Loaded" or "Load Failed",
            Content = message,
            Type = ok and "Success" or "Error",
        })
    end,
})

ConfigSection:CreateToggle({
    Title = "Auto Save",
    Default = false,
    Flag = "AutoSaveEnabled",
    Callback = function(value)
        if value then
            Library:EnableAutoSave("default", 15)
        else
            Library:DisableAutoSave()
        end
    end,
})

local ThemeSection = SettingsTab:CreateSection({ Title = "Theme Manager" })

ThemeSection:CreateDropdown({
    Title = "UI Theme",
    Options = Library.Theme.List(),
    Default = "Red",
    Callback = function(value)
        Library:SetTheme(value)
    end,
})

-- Welcome notification
Library:Notify({
    Title = "PISIT HUB",
    Content = "Interface loaded successfully.",
    Duration = 4,
    Type = "Success",
})
```

## Minimal example

```lua
local Library = require(game.ReplicatedStorage.PISIT_HUB)
local Window = Library:CreateWindow({ Title = "PISIT HUB" })
local Tab = Window:CreateTab({ Title = "Main" })
local Section = Tab:CreateSection({ Title = "General" })

Section:CreateButton({
    Title = "Click Me",
    Callback = function() print("Clicked!") end,
})
```
