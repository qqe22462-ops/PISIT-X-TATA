--[[
	PISIT HUB | Theme.lua
	--------------------------------------------------------------------
	Central theme registry for the PISIT HUB UI Library.

	This module stores every color palette ("theme") available to the
	library, exposes helpers to register new themes at runtime, and
	provides a simple pub/sub system so that live UI elements can react
	instantly whenever the active theme changes (Theme Manager feature).

	Usage:
		local Theme = require(script.Parent.Theme)
		Theme.SetTheme("Red")
		local accent = Theme.Get("Accent")
		Theme.OnChanged:Connect(function(themeName, palette) ... end)
--]]

local Theme = {}

-- A tiny signal implementation so this module has zero external
-- dependencies (kept consistent with Utility.Signal, but duplicated
-- here intentionally to avoid circular requires with Utility.lua).
local function newSignal()
	local signal = { _listeners = {} }

	function signal:Connect(fn)
		table.insert(self._listeners, fn)
		local connection = { Connected = true }
		function connection:Disconnect()
			self.Connected = false
			for i, listener in ipairs(signal._listeners) do
				if listener == fn then
					table.remove(signal._listeners, i)
					break
				end
			end
		end
		return connection
	end

	function signal:Fire(...)
		for _, fn in ipairs(self._listeners) do
			task.spawn(fn, ...)
		end
	end

	return signal
end

-- ====================================================================
-- Built-in Palettes
-- ====================================================================
-- Every palette must define the same key set so any UI element can
-- safely index Theme.Get(key) regardless of which theme is active.

Theme.Palettes = {

	Red = {
		Accent          = Color3.fromHex("#DC1E1E"),
		AccentDim       = Color3.fromHex("#8C1414"),
		Background      = Color3.fromHex("#0F0F0F"),
		SecondaryBackground = Color3.fromHex("#171717"),
		ElementBackground   = Color3.fromHex("#1B1B1B"),
		Border          = Color3.fromHex("#DC1E1E"),
		Text            = Color3.fromHex("#FFFFFF"),
		SubText         = Color3.fromHex("#B5B5B5"),
		Success         = Color3.fromHex("#3ED17B"),
		Warning         = Color3.fromHex("#E1B33D"),
		Error           = Color3.fromHex("#E14848"),
	},

	Dark = {
		Accent          = Color3.fromHex("#DC1E1E"),
		AccentDim       = Color3.fromHex("#8C1414"),
		Background      = Color3.fromHex("#0B0B0B"),
		SecondaryBackground = Color3.fromHex("#131313"),
		ElementBackground   = Color3.fromHex("#181818"),
		Border          = Color3.fromHex("#2A2A2A"),
		Text            = Color3.fromHex("#FFFFFF"),
		SubText         = Color3.fromHex("#9C9C9C"),
		Success         = Color3.fromHex("#3ED17B"),
		Warning         = Color3.fromHex("#E1B33D"),
		Error           = Color3.fromHex("#E14848"),
	},

	Light = {
		Accent          = Color3.fromHex("#DC1E1E"),
		AccentDim       = Color3.fromHex("#F5C0C0"),
		Background      = Color3.fromHex("#F4F4F4"),
		SecondaryBackground = Color3.fromHex("#FFFFFF"),
		ElementBackground   = Color3.fromHex("#ECECEC"),
		Border          = Color3.fromHex("#DC1E1E"),
		Text            = Color3.fromHex("#151515"),
		SubText         = Color3.fromHex("#5C5C5C"),
		Success         = Color3.fromHex("#1E9E52"),
		Warning         = Color3.fromHex("#A87B12"),
		Error           = Color3.fromHex("#C0392B"),
	},

	White = {
		Accent          = Color3.fromHex("#DC1E1E"),
		AccentDim       = Color3.fromHex("#FBE0E0"),
		Background      = Color3.fromHex("#FFFFFF"),
		SecondaryBackground = Color3.fromHex("#F7F7F7"),
		ElementBackground   = Color3.fromHex("#EFEFEF"),
		Border          = Color3.fromHex("#DDDDDD"),
		Text            = Color3.fromHex("#101010"),
		SubText         = Color3.fromHex("#6A6A6A"),
		Success         = Color3.fromHex("#1E9E52"),
		Warning         = Color3.fromHex("#A87B12"),
		Error           = Color3.fromHex("#C0392B"),
	},

	Black = {
		Accent          = Color3.fromHex("#DC1E1E"),
		AccentDim       = Color3.fromHex("#701010"),
		Background      = Color3.fromHex("#000000"),
		SecondaryBackground = Color3.fromHex("#0A0A0A"),
		ElementBackground   = Color3.fromHex("#111111"),
		Border          = Color3.fromHex("#DC1E1E"),
		Text            = Color3.fromHex("#FFFFFF"),
		SubText         = Color3.fromHex("#8A8A8A"),
		Success         = Color3.fromHex("#3ED17B"),
		Warning         = Color3.fromHex("#E1B33D"),
		Error           = Color3.fromHex("#E14848"),
	},
}

-- Fired whenever SetTheme succeeds. Listeners receive (themeName, palette).
Theme.OnChanged = newSignal()

-- Currently active theme name + palette (defaults to the PISIT HUB
-- signature "Red" theme).
Theme.Current = "Red"
Theme.Active = Theme.Palettes.Red

--- Registers a brand new theme (or overwrites an existing one).
-- @param name string
-- @param palette table -- must contain the same keys as Theme.Palettes.Red
function Theme.Register(name, palette)
	assert(type(name) == "string", "Theme name must be a string")
	assert(type(palette) == "table", "Theme palette must be a table")

	-- Fill any missing keys from the Red theme so partial palettes
	-- never break downstream UI code.
	local merged = {}
	for key, value in pairs(Theme.Palettes.Red) do
		merged[key] = palette[key] or value
	end

	Theme.Palettes[name] = merged
	return merged
end

--- Switches the active theme and notifies every listener.
-- @param name string
function Theme.SetTheme(name)
	local palette = Theme.Palettes[name]
	if not palette then
		warn(("[PISIT HUB] Theme '%s' does not exist."):format(tostring(name)))
		return false
	end

	Theme.Current = name
	Theme.Active = palette
	Theme.OnChanged:Fire(name, palette)
	return true
end

--- Fetches a single color value from the active palette.
-- @param key string
function Theme.Get(key)
	return Theme.Active[key]
end

--- Returns a list of all registered theme names, useful for populating
-- the Theme Manager dropdown.
function Theme.List()
	local names = {}
	for name in pairs(Theme.Palettes) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

return Theme
