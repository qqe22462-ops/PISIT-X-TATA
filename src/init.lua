--[[
	PISIT HUB | init.lua
	--------------------------------------------------------------------
	Public entry point for the PISIT HUB UI Library.

	require(path.to.PISIT_HUB) returns this Library table. Everything
	else in src/ is an implementation detail reached only through the
	API exposed here, exactly like Rayfield/Fluent-style libraries, but
	built from scratch with PISIT HUB's own structure and theme.

	Example:
		local Library = require(game.ReplicatedStorage.PISIT_HUB)

		local Window = Library:CreateWindow({
			Title = "PISIT HUB",
			SubTitle = "v1.0.0",
			Theme = "Red",
		})

		local Tab = Window:CreateTab({ Title = "Main", Icon = "settings" })
		local Section = Tab:CreateSection({ Title = "General" })

		Section:CreateButton({
			Title = "Say Hello",
			Callback = function()
				print("Hello from PISIT HUB!")
			end,
		})
--]]

local Theme = require(script.Theme)
local Config = require(script.Config)
local Notification = require(script.Notification)
local Window = require(script.Window)
local Icons = require(script.Icons)

local Library = {}
Library._version = "1.0.0"
Library.Windows = {}

-- Re-export submodules for advanced users who want direct access
-- (custom themes, custom icons, manual config flags, etc).
Library.Theme = Theme
Library.Config = Config
Library.Icons = Icons

--- Creates a new top-level Window. This is the only required call to
-- start building a PISIT HUB interface.
-- @param config table -- { Title, SubTitle, Theme, Size }
-- @return Window
function Library:CreateWindow(config)
	local window = Window.new(config)
	table.insert(self.Windows, window)
	return window
end

--- Convenience passthrough so users don't need to `require` Notification
-- separately: Library:Notify({ Title = "...", Content = "...", Type = "Success" }).
function Library:Notify(data)
	Notification.Notify(data)
end

--- Convenience passthrough for global theme switching:
-- Library:SetTheme("Dark").
function Library:SetTheme(name)
	return Theme.SetTheme(name)
end

--- Registers a brand-new theme palette, usable from Library:SetTheme.
function Library:RegisterTheme(name, palette)
	return Theme.Register(name, palette)
end

--- Save the current config under `name` (defaults to "default").
function Library:SaveConfig(name)
	return Config.Save(name)
end

--- Load a previously saved config by name.
function Library:LoadConfig(name)
	return Config.Load(name)
end

--- Enables Auto Save, writing the config every `interval` seconds.
function Library:EnableAutoSave(name, interval)
	return Config.EnableAutoSave(name, interval)
end

function Library:DisableAutoSave()
	return Config.DisableAutoSave()
end

--- Destroys every window created through this Library instance.
function Library:Destroy()
	for _, window in ipairs(self.Windows) do
		window:Destroy()
	end
	self.Windows = {}
end

return Library
