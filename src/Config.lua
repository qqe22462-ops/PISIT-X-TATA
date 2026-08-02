--[[
	PISIT HUB | Config.lua
	--------------------------------------------------------------------
	Handles saving and loading of every flag-registered element
	(Toggle, Slider, Dropdown, Textbox, Keybind, ColorPicker, ...) to a
	JSON file inside the executor's workspace folder, plus an optional
	Auto Save loop.

	This module is deliberately isolated from Window/Section so the
	rest of the library never has to know *how* persistence works --
	elements simply call Config.Register(flag, getSet) once, and
	Config.Save / Config.Load do the rest.
--]]

local HttpService = game:GetService("HttpService")

local Config = {}
Config._flags = {}        -- [flagName] = { Get = fn, Set = fn }
Config._folder = "PISIT_HUB/configs"
Config._autoSaveEnabled = false
Config._autoSaveInterval = 10
Config._autoSaveThread = nil

-- ====================================================================
-- Filesystem helpers (guarded so the library never errors on
-- executors / platforms without file IO, e.g. Roblox Studio)
-- ====================================================================

local function fsAvailable()
	return typeof(writefile) == "function"
		and typeof(readfile) == "function"
		and typeof(isfile) == "function"
end

local function ensureFolder()
	if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
		if not isfolder(Config._folder) then
			makefolder(Config._folder)
		end
	end
end

-- ====================================================================
-- Flag registration
-- ====================================================================

--- Registers an element's state under a unique flag name so it can be
-- captured/restored by Save/Load.
-- @param flag string -- unique identifier, usually the element title
-- @param getSet table -- { Get = function() return value end, Set = function(value) end }
function Config.Register(flag, getSet)
	if Config._flags[flag] then
		warn(("[PISIT HUB] Config flag '%s' already registered, overwriting."):format(flag))
	end
	Config._flags[flag] = getSet
end

function Config.Unregister(flag)
	Config._flags[flag] = nil
end

-- ====================================================================
-- Save / Load
-- ====================================================================

--- Serializes every registered flag's current value into a table.
function Config.Capture()
	local data = {}
	for flag, getSet in pairs(Config._flags) do
		local ok, value = pcall(getSet.Get)
		if ok then
			data[flag] = value
		end
	end
	return data
end

--- Applies a previously captured table back onto every matching flag.
function Config.Apply(data)
	for flag, value in pairs(data) do
		local getSet = Config._flags[flag]
		if getSet then
			pcall(getSet.Set, value)
		end
	end
end

--- Saves the current state to `<configs>/<name>.json`.
-- @param name string
-- @return boolean success, string message
function Config.Save(name)
	name = name or "default"
	if not fsAvailable() then
		return false, "File IO is not available on this platform."
	end

	ensureFolder()
	local data = Config.Capture()
	local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
	if not ok then
		return false, "Failed to encode config: " .. tostring(encoded)
	end

	local path = Config._folder .. "/" .. name .. ".json"
	local writeOk, writeErr = pcall(writefile, path, encoded)
	if not writeOk then
		return false, "Failed to write config: " .. tostring(writeErr)
	end

	return true, "Saved to " .. path
end

--- Loads a config file previously written by Config.Save.
-- @param name string
-- @return boolean success, string message
function Config.Load(name)
	name = name or "default"
	if not fsAvailable() then
		return false, "File IO is not available on this platform."
	end

	local path = Config._folder .. "/" .. name .. ".json"
	if not isfile(path) then
		return false, "Config file does not exist: " .. path
	end

	local ok, raw = pcall(readfile, path)
	if not ok then
		return false, "Failed to read config: " .. tostring(raw)
	end

	local decodeOk, data = pcall(HttpService.JSONDecode, HttpService, raw)
	if not decodeOk then
		return false, "Failed to decode config: " .. tostring(data)
	end

	Config.Apply(data)
	return true, "Loaded " .. path
end

--- Lists every saved config name (without the .json extension).
function Config.List()
	local names = {}
	if typeof(listfiles) == "function" then
		ensureFolder()
		for _, path in ipairs(listfiles(Config._folder)) do
			local fileName = path:match("([^/\\]+)%.json$")
			if fileName then
				table.insert(names, fileName)
			end
		end
	end
	return names
end

-- ====================================================================
-- Auto Save
-- ====================================================================

--- Enables a background loop that calls Config.Save(name) every
-- `interval` seconds.
function Config.EnableAutoSave(name, interval)
	Config._autoSaveEnabled = true
	Config._autoSaveInterval = interval or Config._autoSaveInterval

	if Config._autoSaveThread then
		task.cancel(Config._autoSaveThread)
	end

	Config._autoSaveThread = task.spawn(function()
		while Config._autoSaveEnabled do
			task.wait(Config._autoSaveInterval)
			if Config._autoSaveEnabled then
				Config.Save(name)
			end
		end
	end)
end

function Config.DisableAutoSave()
	Config._autoSaveEnabled = false
	if Config._autoSaveThread then
		task.cancel(Config._autoSaveThread)
		Config._autoSaveThread = nil
	end
end

return Config
