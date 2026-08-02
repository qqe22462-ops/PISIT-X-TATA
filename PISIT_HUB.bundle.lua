--[[
	PISIT HUB | Single-File Bundle
	--------------------------------------------------------------------
	Auto-generated bundle for loadstring/HttpGet distribution.
	Source of truth is the multi-file src/ project - edit that, then
	regenerate this bundle. Do not hand-edit this file.

	Usage:
		local Library = loadstring(game:HttpGet("<raw_github_url>"))()
--]]

local Modules = {}


Modules.Utility = (function()
--[[
	PISIT HUB | Utility.lua
	--------------------------------------------------------------------
	Grab-bag of small, dependency-free helper functions that are reused
	across the entire library: Instance creation shorthand, signals,
	dragging behaviour, rounding, table utilities, and safe-callback
	wrapping.
--]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Utility = {}

-- ====================================================================
-- Instance creation shorthand
-- ====================================================================

--- Creates an Instance and applies a table of properties + optional
-- children in a single call. This keeps every UI file readable and
-- avoids 15-line property blocks scattered everywhere.
-- @param className string
-- @param props table<string, any>
-- @param children table<Instance>?
function Utility.New(className, props, children)
	local inst = Instance.new(className)

	if props then
		for key, value in pairs(props) do
			-- "Parent" is applied last so children/events don't fire
			-- against a half-configured instance.
			if key ~= "Parent" then
				inst[key] = value
			end
		end
	end

	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end

	if props and props.Parent then
		inst.Parent = props.Parent
	end

	return inst
end

-- ====================================================================
-- Signals (lightweight custom event system, no RemoteEvents required)
-- ====================================================================

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _listeners = {} }, Signal)
end

function Signal:Connect(fn)
	table.insert(self._listeners, fn)
	local connection = { Connected = true }
	function connection:Disconnect()
		self.Connected = false
		for i, listener in ipairs(self._listeners) do
			if listener == fn then
				table.remove(self._listeners, i)
				break
			end
		end
	end
	return connection
end

function Signal:Fire(...)
	for _, fn in ipairs(self._listeners) do
		task.spawn(fn, ...)
	end
end

Utility.Signal = Signal

-- ====================================================================
-- Safe callback invocation
-- ====================================================================

--- Wraps a user-provided callback in pcall so a broken callback inside
-- a Button/Toggle/Slider never crashes the whole UI.
function Utility.SafeCall(fn, ...)
	if type(fn) ~= "function" then
		return
	end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[PISIT HUB] Callback error: " .. tostring(err))
	end
end

-- ====================================================================
-- Dragging behaviour (used by Window + Mini Mode)
-- ====================================================================

--- Makes `frame` draggable using `handle` as the drag hotspot.
-- Supports both mouse and touch input for full mobile support.
function Utility.MakeDraggable(frame, handle)
	handle = handle or frame

	local dragging = false
	local dragStart = nil
	local startPos = nil

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ====================================================================
-- Misc helpers
-- ====================================================================

--- Rounds `value` to `decimals` decimal places (default 0).
function Utility.Round(value, decimals)
	local mult = 10 ^ (decimals or 0)
	return math.floor(value * mult + 0.5) / mult
end

--- Clamps `value` between `min` and `max`.
function Utility.Clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

--- Deep-copies a table (used when saving/loading configs).
function Utility.DeepCopy(tbl)
	if type(tbl) ~= "table" then
		return tbl
	end
	local copy = {}
	for key, value in pairs(tbl) do
		copy[key] = Utility.DeepCopy(value)
	end
	return copy
end

--- Generates a short pseudo-random id, used for element/config keys.
function Utility.GenerateId(prefix)
	return (prefix or "id") .. "_" .. tostring(math.random(100000, 999999))
end

--- Returns true if the current device is a touch/mobile device,
-- used by elements to switch to Responsive layout behaviour.
function Utility.IsMobile()
	return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

return Utility

end)()


Modules.Theme = (function()
--[[
	PISIT HUB | Theme.lua
	--------------------------------------------------------------------
	Central theme registry for the PISIT HUB UI Library.

	This module stores every color palette ("theme") available to the
	library, exposes helpers to register new themes at runtime, and
	provides a simple pub/sub system so that live UI elements can react
	instantly whenever the active theme changes (Theme Manager feature).

	Usage:
		local Theme = Modules.Theme
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

end)()


Modules.Animation = (function()
--[[
	PISIT HUB | Animation.lua
	--------------------------------------------------------------------
	Centralized TweenService wrapper for every animation used across the
	library: window open/close, hover, click, ripple, glow, fade, slide
	and scale. Keeping all tween definitions here means every element
	file (Button.lua, Toggle.lua, ...) stays focused on logic, not on
	repeating TweenInfo boilerplate.
--]]

local TweenService = game:GetService("TweenService")

local Utility = Modules.Utility

local Animation = {}

-- Standard easing presets reused everywhere for visual consistency.
Animation.Easing = {
	Fast   = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Bounce = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

--- Generic tween helper. Returns the Tween object so callers can chain
-- :Play()/:Cancel() or connect to Completed if needed.
function Animation.Tween(instance, info, props)
	local tween = TweenService:Create(instance, info, props)
	tween:Play()
	return tween
end

-- ====================================================================
-- Window open / close
-- ====================================================================

function Animation.OpenWindow(frame)
	frame.Visible = true
	local goalSize = frame:GetAttribute("TargetSize") or frame.Size

	frame.Size = UDim2.new(goalSize.X.Scale, goalSize.X.Offset, 0, 0)
	frame.BackgroundTransparency = 1

	Animation.Tween(frame, Animation.Easing.Bounce, { Size = goalSize })
	Animation.Tween(frame, Animation.Easing.Normal, { BackgroundTransparency = 0 })
end

function Animation.CloseWindow(frame, onComplete)
	frame:SetAttribute("TargetSize", frame.Size)

	local tween = Animation.Tween(frame, Animation.Easing.Fast, {
		Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 0),
		BackgroundTransparency = 1,
	})

	tween.Completed:Connect(function()
		frame.Visible = false
		if onComplete then
			onComplete()
		end
	end)
end

-- ====================================================================
-- Hover / Click
-- ====================================================================

function Animation.Hover(instance, hoverColor, normalColor)
	instance.MouseEnter:Connect(function()
		Animation.Tween(instance, Animation.Easing.Fast, { BackgroundColor3 = hoverColor })
	end)
	instance.MouseLeave:Connect(function()
		Animation.Tween(instance, Animation.Easing.Fast, { BackgroundColor3 = normalColor })
	end)
end

function Animation.Click(instance)
	local originalSize = instance.Size
	Animation.Tween(instance, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
		Size = UDim2.new(
			originalSize.X.Scale, originalSize.X.Offset - 4,
			originalSize.Y.Scale, originalSize.Y.Offset - 2
		),
	})
	task.delay(0.08, function()
		Animation.Tween(instance, Animation.Easing.Bounce, { Size = originalSize })
	end)
end

-- ====================================================================
-- Ripple Effect
-- ====================================================================

--- Spawns a circular ripple centered on the input position, expanding
-- and fading out, then destroys itself. Common "Material Design"-style
-- click feedback used on Buttons.
function Animation.Ripple(parent, inputPosition, color)
	local relativeX = inputPosition.X - parent.AbsolutePosition.X
	local relativeY = inputPosition.Y - parent.AbsolutePosition.Y

	local ripple = Utility.New("Frame", {
		Name = "Ripple",
		BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(relativeX, relativeY),
		Size = UDim2.fromOffset(0, 0),
		ZIndex = parent.ZIndex + 1,
		Parent = parent,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ripple })

	local maxDim = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.6

	local tween = Animation.Tween(ripple, Animation.Easing.Smooth, {
		Size = UDim2.fromOffset(maxDim, maxDim),
		BackgroundTransparency = 1,
	})

	tween.Completed:Connect(function()
		ripple:Destroy()
	end)
end

-- ====================================================================
-- Glow Effect
-- ====================================================================

--- Pulses a UIStroke's Transparency to create a soft glow, used for
-- focused inputs and the active tab indicator.
function Animation.Glow(stroke, active)
	local goal = active and 0 or 0.6
	Animation.Tween(stroke, Animation.Easing.Normal, { Transparency = goal })
end

-- ====================================================================
-- Fade / Slide / Scale
-- ====================================================================

function Animation.Fade(instance, transparency, duration)
	return Animation.Tween(instance, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quad), {
		BackgroundTransparency = transparency,
	})
end

function Animation.Slide(instance, targetPosition, duration)
	return Animation.Tween(instance, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = targetPosition,
	})
end

function Animation.Scale(instance, targetSize, duration)
	return Animation.Tween(instance, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = targetSize,
	})
end

return Animation

end)()


Modules.Icons = (function()
--[[
	PISIT HUB | Icons.lua
	--------------------------------------------------------------------
	Small registry mapping icon names to Roblox asset/image ids.

	PISIT HUB does not bundle a full icon-font, but exposes an easily
	extensible table so users of the library can register their own
	icons (e.g. from a Lucide/Feather rbxassetid spritesheet) and
	reference them by name everywhere: Section:CreateButton({Icon="settings"}).
--]]

local Icons = {}

-- Default placeholder set. Replace these ids with your own uploaded
-- icon assets. "logo" is used by the Notification system (icon "P").
Icons.Registry = {
	logo      = "rbxassetid://0",
	settings  = "rbxassetid://0",
	search    = "rbxassetid://0",
	close     = "rbxassetid://0",
	minimize  = "rbxassetid://0",
	check     = "rbxassetid://0",
	chevron   = "rbxassetid://0",
	warning   = "rbxassetid://0",
	success   = "rbxassetid://0",
	error     = "rbxassetid://0",
	info      = "rbxassetid://0",
	keybind   = "rbxassetid://0",
	color     = "rbxassetid://0",
}

--- Registers or overwrites an icon id.
function Icons.Register(name, assetId)
	Icons.Registry[name] = assetId
end

--- Fetches an icon id by name, falling back to a transparent 1x1 if
-- the icon does not exist (prevents red "missing texture" boxes).
function Icons.Get(name)
	return Icons.Registry[name] or "rbxasset://textures/ui/GuiImagePlaceholder.png"
end

return Icons

end)()


Modules.Config = (function()
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

end)()


Modules.Button = (function()
--[[
	PISIT HUB | Button.lua
	--------------------------------------------------------------------
	Standard clickable button element: hover glow, click scale, ripple
	feedback, callback support, and Enable/Disable state.
--]]

local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation

local Button = {}
Button.__index = Button

--- Internal constructor, called by Section:CreateButton().
-- @param parent Instance -- the Section's content frame
-- @param config table -- { Title, Description, Callback }
function Button.new(parent, config)
	config = config or {}

	local self = setmetatable({}, Button)
	self.Title = config.Title or "Button"
	self.Callback = config.Callback or function() end
	self.Enabled = true

	self.Instance = Utility.New("TextButton", {
		Name = "Button_" .. self.Title,
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 38),
		ClipsDescendants = true,
		Parent = parent,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Instance })
	self.Stroke = Utility.New("UIStroke", {
		Color = Theme.Get("Border"),
		Transparency = 0.75,
		Thickness = 1,
		Parent = self.Instance,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		Parent = self.Instance,
	})

	self.Label = Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = self.Title,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Instance,
	})

	-- Hover + click feedback
	Animation.Hover(self.Instance, Theme.Get("ElementBackground"):Lerp(Theme.Get("Accent"), 0.15), Theme.Get("ElementBackground"))

	self.Instance.MouseButton1Click:Connect(function()
		self:_fire()
	end)

	self.Instance.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			if self.Enabled then
				Animation.Ripple(self.Instance, input.Position, Theme.Get("Accent"))
			end
		end
	end)

	Theme.OnChanged:Connect(function(_, palette)
		self.Instance.BackgroundColor3 = palette.ElementBackground
		self.Stroke.Color = palette.Border
		self.Label.TextColor3 = palette.Text
	end)

	return self
end

function Button:_fire()
	if not self.Enabled then
		return
	end
	Animation.Click(self.Instance)
	Animation.Glow(self.Stroke, true)
	task.delay(0.2, function()
		Animation.Glow(self.Stroke, false)
	end)
	Utility.SafeCall(self.Callback)
end

--- Disables the button: dims it and blocks clicks/ripple.
function Button:Disable()
	self.Enabled = false
	Animation.Fade(self.Instance, 0.5, 0.2)
	self.Label.TextTransparency = 0.5
end

--- Re-enables a previously disabled button.
function Button:Enable()
	self.Enabled = true
	Animation.Fade(self.Instance, 0, 0.2)
	self.Label.TextTransparency = 0
end

--- Updates the button's callback at runtime.
function Button:SetCallback(fn)
	self.Callback = fn
end

--- Renames the button.
function Button:SetTitle(title)
	self.Title = title
	self.Label.Text = title
end

return Button

end)()


Modules.Toggle = (function()
--[[
	PISIT HUB | Toggle.lua
	--------------------------------------------------------------------
	On/off switch element with a smooth sliding knob animation, default
	value support, callback firing, and Config.lua flag registration
	for Save/Load/Auto Save.
--]]

local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Config = Modules.Config

local Toggle = {}
Toggle.__index = Toggle

--- @param parent Instance
-- @param config table -- { Title, Description, Default, Flag, Callback }
function Toggle.new(parent, config)
	config = config or {}

	local self = setmetatable({}, Toggle)
	self.Title = config.Title or "Toggle"
	self.Flag = config.Flag or self.Title
	self.Callback = config.Callback or function() end
	self.Value = config.Default or false

	self.Instance = Utility.New("TextButton", {
		Name = "Toggle_" .. self.Title,
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 38),
		Parent = parent,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Instance })
	self.Stroke = Utility.New("UIStroke", {
		Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1,
		Parent = self.Instance,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		Parent = self.Instance,
	})

	self.Label = Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -50, 1, 0),
		Text = self.Title,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Instance,
	})

	-- Track + knob
	self.Track = Utility.New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(38, 20),
		BackgroundColor3 = Theme.Get("AccentDim"),
		Parent = self.Instance,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Track })

	self.Knob = Utility.New("Frame", {
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = self.Track,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Knob })

	self.Instance.MouseButton1Click:Connect(function()
		self:Set(not self.Value)
	end)

	Config.Register(self.Flag, {
		Get = function() return self.Value end,
		Set = function(value) self:Set(value, true) end,
	})

	Theme.OnChanged:Connect(function(_, palette)
		self.Instance.BackgroundColor3 = palette.ElementBackground
		self.Stroke.Color = palette.Border
		self.Label.TextColor3 = palette.Text
		self:_render(false)
	end)

	self:_render(false)
	return self
end

function Toggle:_render(animate)
	local palette = Theme.Active
	local trackColor = self.Value and palette.Accent or palette.AccentDim
	local knobPos = self.Value and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)

	if animate then
		Animation.Tween(self.Track, Animation.Easing.Normal, { BackgroundColor3 = trackColor })
		Animation.Tween(self.Knob, Animation.Easing.Bounce, { Position = knobPos })
	else
		self.Track.BackgroundColor3 = trackColor
		self.Knob.Position = knobPos
	end
end

--- Sets the toggle's value. `fromConfig` suppresses the callback when
-- the value is being restored from a saved config (avoids re-running
-- side effects during Load).
function Toggle:Set(value, fromConfig)
	self.Value = value and true or false
	self:_render(true)

	if not fromConfig then
		Utility.SafeCall(self.Callback, self.Value)
	end
end

function Toggle:Get()
	return self.Value
end

return Toggle

end)()


Modules.Slider = (function()
--[[
	PISIT HUB | Slider.lua
	--------------------------------------------------------------------
	Drag-to-set numeric slider with Min/Max/Default, real-time value
	label, smooth fill animation, and full mouse + touch support.
--]]

local UserInputService = game:GetService("UserInputService")

local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Config = Modules.Config

local Slider = {}
Slider.__index = Slider

--- @param parent Instance
-- @param config table -- { Title, Min, Max, Default, Increment, Flag, Callback }
function Slider.new(parent, config)
	config = config or {}

	local self = setmetatable({}, Slider)
	self.Title = config.Title or "Slider"
	self.Flag = config.Flag or self.Title
	self.Min = config.Min or 0
	self.Max = config.Max or 100
	self.Increment = config.Increment or 1
	self.Callback = config.Callback or function() end
	self.Value = Utility.Clamp(config.Default or self.Min, self.Min, self.Max)
	self.Dragging = false

	self.Instance = Utility.New("Frame", {
		Name = "Slider_" .. self.Title,
		BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 50),
		Parent = parent,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Instance })
	self.Stroke = Utility.New("UIStroke", {
		Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1,
		Parent = self.Instance,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 8),
		Parent = self.Instance,
	})

	local header = Utility.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Parent = self.Instance,
	})
	Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -60, 1, 0),
		Text = self.Title,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	self.ValueLabel = Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(60, 18),
		Text = tostring(self.Value),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Get("Accent"),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = header,
	})

	self.Bar = Utility.New("Frame", {
		Position = UDim2.new(0, 0, 0, 30),
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = Theme.Get("AccentDim"),
		Parent = self.Instance,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Bar })

	self.Fill = Utility.New("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Theme.Get("Accent"),
		Parent = self.Bar,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Fill })

	self.Knob = Utility.New("Frame", {
		Size = UDim2.fromOffset(14, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = self.Bar,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Knob })

	self:_connectInput()

	Config.Register(self.Flag, {
		Get = function() return self.Value end,
		Set = function(value) self:Set(value, true) end,
	})

	Theme.OnChanged:Connect(function(_, palette)
		self.Instance.BackgroundColor3 = palette.ElementBackground
		self.Stroke.Color = palette.Border
		self.Bar.BackgroundColor3 = palette.AccentDim
		self.Fill.BackgroundColor3 = palette.Accent
		self.ValueLabel.TextColor3 = palette.Accent
		self:_render(false)
	end)

	self:_render(false)
	return self
end

function Slider:_connectInput()
	local function updateFromX(xPos)
		local relative = Utility.Clamp((xPos - self.Bar.AbsolutePosition.X) / self.Bar.AbsoluteSize.X, 0, 1)
		local raw = self.Min + relative * (self.Max - self.Min)
		local stepped = Utility.Round(raw / self.Increment) * self.Increment
		self:Set(Utility.Clamp(stepped, self.Min, self.Max))
	end

	self.Bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			self.Dragging = true
			updateFromX(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if self.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			self.Dragging = false
		end
	end)
end

function Slider:_render(animate)
	local alpha = (self.Value - self.Min) / (self.Max - self.Min)
	alpha = Utility.Clamp(alpha, 0, 1)
	self.ValueLabel.Text = tostring(self.Value)

	if animate then
		Animation.Tween(self.Fill, Animation.Easing.Fast, { Size = UDim2.new(alpha, 0, 1, 0) })
		Animation.Tween(self.Knob, Animation.Easing.Fast, { Position = UDim2.new(alpha, 0, 0.5, 0) })
	else
		self.Fill.Size = UDim2.new(alpha, 0, 1, 0)
		self.Knob.Position = UDim2.new(alpha, 0, 0.5, 0)
	end
end

--- Sets the slider value programmatically (real-time display update).
function Slider:Set(value, fromConfig)
	self.Value = Utility.Clamp(value, self.Min, self.Max)
	self:_render(true)

	if not fromConfig then
		Utility.SafeCall(self.Callback, self.Value)
	end
end

function Slider:Get()
	return self.Value
end

return Slider

end)()


Modules.Dropdown = (function()
--[[
	PISIT HUB | Dropdown.lua
	--------------------------------------------------------------------
	Dropdown element supporting: single or multi-select, an internal
	search box to filter long option lists, runtime Refresh/Add/Remove
	of options, and Config.lua flag registration.
--]]

local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Config = Modules.Config

local Dropdown = {}
Dropdown.__index = Dropdown

--- @param parent Instance
-- @param config table -- { Title, Options, Default, Multi, Searchable, Flag, Callback }
function Dropdown.new(parent, config)
	config = config or {}

	local self = setmetatable({}, Dropdown)
	self.Title = config.Title or "Dropdown"
	self.Flag = config.Flag or self.Title
	self.Options = config.Options or {}
	self.Multi = config.Multi or false
	self.Searchable = config.Searchable ~= false
	self.Callback = config.Callback or function() end
	self.Open = false

	-- Selected is always stored as a set-like table { [optionName] = true }
	self.Selected = {}
	if self.Multi then
		for _, v in ipairs(config.Default or {}) do
			self.Selected[v] = true
		end
	elseif config.Default then
		self.Selected[config.Default] = true
	end

	self.Instance = Utility.New("Frame", {
		Name = "Dropdown_" .. self.Title,
		BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 38),
		ClipsDescendants = true,
		Parent = parent,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Instance })
	self.Stroke = Utility.New("UIStroke", {
		Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1,
		Parent = self.Instance,
	})

	self.Header = Utility.New("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 38),
		Parent = self.Instance,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		Parent = self.Header,
	})
	self.Label = Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 1, 0),
		Text = self.Title,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Header,
	})
	self.Chevron = Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		Text = "v",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Theme.Get("SubText"),
		Parent = self.Header,
	})

	-- Body (search box + scrolling option list), collapsed by default
	self.Body = Utility.New("Frame", {
		Position = UDim2.new(0, 0, 0, 38),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		Parent = self.Instance,
	})
	local bodyLayout = Utility.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 4),
		Parent = self.Body,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
		Parent = self.Body,
	})

	if self.Searchable then
		self.SearchBox = Utility.New("TextBox", {
			PlaceholderText = "Search...",
			Text = "",
			BackgroundColor3 = Theme.Get("Background"),
			Size = UDim2.new(1, 0, 0, 26),
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = Theme.Get("Text"),
			PlaceholderColor3 = Theme.Get("SubText"),
			ClearTextOnFocus = false,
			Parent = self.Body,
		})
		Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.SearchBox })
		Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = self.SearchBox })

		self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
			self:_filter(self.SearchBox.Text)
		end)
	end

	self.OptionHolder = Utility.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self.Body,
	})
	Utility.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 2),
		Parent = self.OptionHolder,
	})

	self.Header.MouseButton1Click:Connect(function()
		self:Toggle()
	end)

	self:Refresh(self.Options)

	Config.Register(self.Flag, {
		Get = function() return self:Get() end,
		Set = function(value) self:SetSelected(value, true) end,
	})

	Theme.OnChanged:Connect(function(_, palette)
		self.Instance.BackgroundColor3 = palette.ElementBackground
		self.Stroke.Color = palette.Border
		self.Label.TextColor3 = palette.Text
		self.Chevron.TextColor3 = palette.SubText
		self:Refresh(self.Options)
	end)

	self:_updateLabel()
	return self
end

-- ====================================================================
-- Open / Close
-- ====================================================================

function Dropdown:Toggle()
	if self.Open then
		self:Close()
	else
		self:OpenMenu()
	end
end

function Dropdown:OpenMenu()
	self.Open = true
	local bodyHeight = self.Body.UIListLayout and 0 or 0
	-- compute target height from children after layout resolves
	task.defer(function()
		local target = self.SearchBox and 34 or 0
		for _, child in ipairs(self.OptionHolder:GetChildren()) do
			if child:IsA("GuiObject") and child.Visible then
				target += 30
			end
		end
		target += 16
		Animation.Tween(self.Instance, Animation.Easing.Smooth, {
			Size = UDim2.new(1, 0, 0, 38 + math.min(target, 220)),
		})
	end)
	Animation.Tween(self.Chevron, Animation.Easing.Normal, { Rotation = 180 })
end

function Dropdown:Close()
	self.Open = false
	Animation.Tween(self.Instance, Animation.Easing.Fast, { Size = UDim2.new(1, 0, 0, 38) })
	Animation.Tween(self.Chevron, Animation.Easing.Normal, { Rotation = 0 })
end

-- ====================================================================
-- Options management
-- ====================================================================

--- Rebuilds the option list UI from `list`. Can be called at runtime
-- to refresh available choices.
function Dropdown:Refresh(list)
	self.Options = list

	for _, child in ipairs(self.OptionHolder:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	for _, optionName in ipairs(list) do
		self:_createOption(optionName)
	end
end

--- Appends a single new option without rebuilding the whole list.
function Dropdown:AddOption(optionName)
	table.insert(self.Options, optionName)
	self:_createOption(optionName)
end

--- Removes an option by name.
function Dropdown:RemoveOption(optionName)
	for i, name in ipairs(self.Options) do
		if name == optionName then
			table.remove(self.Options, i)
			break
		end
	end
	self.Selected[optionName] = nil
	local btn = self.OptionHolder:FindFirstChild("Option_" .. optionName)
	if btn then
		btn:Destroy()
	end
	self:_updateLabel()
end

function Dropdown:_createOption(optionName)
	local btn = Utility.New("TextButton", {
		Name = "Option_" .. optionName,
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Get("Background"),
		Size = UDim2.new(1, 0, 0, 28),
		Parent = self.OptionHolder,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = btn })
	local lbl = Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = optionName,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = self.Selected[optionName] and Theme.Get("Accent") or Theme.Get("SubText"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = btn,
	})

	btn.MouseButton1Click:Connect(function()
		if self.Multi then
			self.Selected[optionName] = not self.Selected[optionName] or nil
		else
			self.Selected = { [optionName] = true }
			self:Close()
		end
		lbl.TextColor3 = self.Selected[optionName] and Theme.Get("Accent") or Theme.Get("SubText")
		self:_updateLabel()
		Utility.SafeCall(self.Callback, self:Get())
	end)

	return btn
end

function Dropdown:_filter(query)
	query = query:lower()
	for _, child in ipairs(self.OptionHolder:GetChildren()) do
		if child:IsA("TextButton") then
			local matches = query == "" or child.Name:lower():find(query, 1, true) ~= nil
			child.Visible = matches
		end
	end
end

function Dropdown:_updateLabel()
	local names = {}
	for name in pairs(self.Selected) do
		table.insert(names, name)
	end
	table.sort(names)

	if #names == 0 then
		self.Label.Text = self.Title
	elseif self.Multi then
		self.Label.Text = self.Title .. " (" .. #names .. ")"
	else
		self.Label.Text = names[1]
	end
end

-- ====================================================================
-- Value accessors
-- ====================================================================

function Dropdown:Get()
	if self.Multi then
		local names = {}
		for name in pairs(self.Selected) do
			table.insert(names, name)
		end
		table.sort(names)
		return names
	end
	for name in pairs(self.Selected) do
		return name
	end
	return nil
end

function Dropdown:SetSelected(value, fromConfig)
	self.Selected = {}
	if self.Multi and type(value) == "table" then
		for _, v in ipairs(value) do
			self.Selected[v] = true
		end
	elseif value then
		self.Selected[value] = true
	end
	self:Refresh(self.Options)
	self:_updateLabel()

	if not fromConfig then
		Utility.SafeCall(self.Callback, self:Get())
	end
end

return Dropdown

end)()


Modules.Textbox = (function()
--[[
	PISIT HUB | Textbox.lua
	--------------------------------------------------------------------
	Single-line text input element with placeholder text, a Clear
	button, focus glow animation, and callback-on-enter support.
--]]

local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Config = Modules.Config

local Textbox = {}
Textbox.__index = Textbox

--- @param parent Instance
-- @param config table -- { Title, Placeholder, Default, ClearOnFocus, Flag, Callback }
function Textbox.new(parent, config)
	config = config or {}

	local self = setmetatable({}, Textbox)
	self.Title = config.Title or "Textbox"
	self.Flag = config.Flag or self.Title
	self.Callback = config.Callback or function() end
	self.Value = config.Default or ""

	self.Instance = Utility.New("Frame", {
		Name = "Textbox_" .. self.Title,
		BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 58),
		Parent = parent,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Instance })
	self.Stroke = Utility.New("UIStroke", {
		Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1,
		Parent = self.Instance,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8),
		Parent = self.Instance,
	})

	Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Text = self.Title,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Instance,
	})

	local inputRow = Utility.New("Frame", {
		Position = UDim2.new(0, 0, 0, 22),
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = Theme.Get("Background"),
		Parent = self.Instance,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = inputRow })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 28), Parent = inputRow })

	self.Box = Utility.New("TextBox", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = self.Value,
		PlaceholderText = config.Placeholder or "Enter text...",
		ClearTextOnFocus = config.ClearOnFocus or false,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Theme.Get("Text"),
		PlaceholderColor3 = Theme.Get("SubText"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = inputRow,
	})

	self.ClearButton = Utility.New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		BackgroundTransparency = 1,
		Text = "x",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = Theme.Get("SubText"),
		Parent = inputRow,
	})

	self.ClearButton.MouseButton1Click:Connect(function()
		self:Set("")
		self.Box:CaptureFocus()
	end)

	self.Box.Focused:Connect(function()
		Animation.Glow(self.Stroke, true)
	end)

	self.Box.FocusLost:Connect(function(enterPressed)
		Animation.Glow(self.Stroke, false)
		self.Value = self.Box.Text
		if enterPressed then
			Utility.SafeCall(self.Callback, self.Value)
		end
	end)

	self.Box:GetPropertyChangedSignal("Text"):Connect(function()
		self.Value = self.Box.Text
	end)

	Config.Register(self.Flag, {
		Get = function() return self.Value end,
		Set = function(value) self:Set(value, true) end,
	})

	Theme.OnChanged:Connect(function(_, palette)
		self.Instance.BackgroundColor3 = palette.ElementBackground
		self.Stroke.Color = palette.Border
		inputRow.BackgroundColor3 = palette.Background
		self.Box.TextColor3 = palette.Text
		self.Box.PlaceholderColor3 = palette.SubText
	end)

	return self
end

--- Sets the textbox contents. `fromConfig` suppresses the callback.
function Textbox:Set(value, fromConfig)
	self.Value = value or ""
	self.Box.Text = self.Value

	if not fromConfig then
		Utility.SafeCall(self.Callback, self.Value)
	end
end

function Textbox:Get()
	return self.Value
end

--- Forces keyboard focus onto the textbox.
function Textbox:Focus()
	self.Box:CaptureFocus()
end

--- Clears the textbox contents.
function Textbox:Clear()
	self:Set("")
end

return Textbox

end)()


Modules.Paragraph = (function()
--[[
	PISIT HUB | Paragraph.lua
	--------------------------------------------------------------------
	Multi-line, word-wrapped informational text block with an optional
	bold title row. Used for descriptions, changelogs, warnings, etc.
--]]

local Theme = Modules.Theme
local Utility = Modules.Utility

local Paragraph = {}
Paragraph.__index = Paragraph

--- @param parent Instance
-- @param config table -- { Title, Content }
function Paragraph.new(parent, config)
	config = config or {}

	local self = setmetatable({}, Paragraph)
	self.Title = config.Title or ""
	self.Content = config.Content or ""

	self.Instance = Utility.New("Frame", {
		Name = "Paragraph",
		BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parent,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Instance })
	self.Stroke = Utility.New("UIStroke", {
		Color = Theme.Get("Border"), Transparency = 0.8, Thickness = 1,
		Parent = self.Instance,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		Parent = self.Instance,
	})
	Utility.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 4),
		Parent = self.Instance,
	})

	self.TitleLabel = Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, self.Title ~= "" and 16 or 0),
		Visible = self.Title ~= "",
		Text = self.Title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1,
		Parent = self.Instance,
	})

	self.ContentLabel = Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = self.Content,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Theme.Get("SubText"),
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 2,
		Parent = self.Instance,
	})

	Theme.OnChanged:Connect(function(_, palette)
		self.Instance.BackgroundColor3 = palette.ElementBackground
		self.Stroke.Color = palette.Border
		self.TitleLabel.TextColor3 = palette.Text
		self.ContentLabel.TextColor3 = palette.SubText
	end)

	return self
end

--- Updates the paragraph body text at runtime.
function Paragraph:SetContent(text)
	self.Content = text
	self.ContentLabel.Text = text
end

--- Updates the paragraph title at runtime.
function Paragraph:SetTitle(text)
	self.Title = text
	self.TitleLabel.Text = text
	self.TitleLabel.Visible = text ~= ""
	self.TitleLabel.Size = UDim2.new(1, 0, 0, text ~= "" and 16 or 0)
end

return Paragraph

end)()


Modules.Label = (function()
--[[
	PISIT HUB | Label.lua
	--------------------------------------------------------------------
	Minimal single-line text element, cheaper than Paragraph, used for
	status readouts, headers within a section, or dynamic value display
	(e.g. "FPS: 60").
--]]

local Theme = Modules.Theme
local Utility = Modules.Utility

local Label = {}
Label.__index = Label

--- @param parent Instance
-- @param config table -- { Text }
function Label.new(parent, config)
	config = config or {}

	local self = setmetatable({}, Label)
	self.Text = config.Text or "Label"

	self.Instance = Utility.New("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Text = self.Text,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Theme.Get("SubText"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent,
	})

	Theme.OnChanged:Connect(function(_, palette)
		self.Instance.TextColor3 = palette.SubText
	end)

	return self
end

--- Updates the label's text at runtime, e.g. for live stats.
function Label:SetText(text)
	self.Text = text
	self.Instance.Text = text
end

return Label

end)()


Modules.Notification = (function()
--[[
	PISIT HUB | Notification.lua
	--------------------------------------------------------------------
	Top-right notification system with the PISIT HUB "P" icon, fade
	in/out animation, vertical stacking, and a queue so notifications
	fired in rapid succession do not overlap.

	Usage:
		Notification.Init(screenGui)
		Notification.Notify({
			Title = "Saved",
			Content = "Your configuration has been saved.",
			Duration = 4,
			Type = "Success", -- Success | Warning | Error | Info
		})
--]]

local TweenService = game:GetService("TweenService")

local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Icons = Modules.Icons

local Notification = {}

local container -- holder Frame, top-right, parented into the ScreenGui
local activeCount = 0
local queue = {}
local MAX_VISIBLE = 5

local TYPE_COLOR_KEY = {
	Success = "Success",
	Warning = "Warning",
	Error   = "Error",
	Info    = "Accent",
}

-- ====================================================================
-- Setup
-- ====================================================================

--- Must be called once with the library's root ScreenGui before any
-- Notify() calls.
function Notification.Init(screenGui)
	container = Utility.New("Frame", {
		Name = "PISIT_Notifications",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.new(0, 300, 1, -32),
		Parent = screenGui,
	})

	Utility.New("UIListLayout", {
		Parent = container,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

-- ====================================================================
-- Internal: build + animate a single notification card
-- ====================================================================

local function buildCard(data)
	local colorKey = TYPE_COLOR_KEY[data.Type] or "Accent"
	local accentColor = Theme.Get(colorKey)

	local card = Utility.New("Frame", {
		Name = "NotificationCard",
		BackgroundColor3 = Theme.Get("SecondaryBackground"),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		Parent = container,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = card })
	local stroke = Utility.New("UIStroke", {
		Color = accentColor,
		Thickness = 1,
		Transparency = 0.6,
		Parent = card,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		Parent = card,
	})

	local layout = Utility.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = card,
	})

	-- Header row: "P" icon + title
	local header = Utility.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		LayoutOrder = 1,
		Parent = card,
	})
	Utility.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
		Parent = header,
	})
	local badge = Utility.New("Frame", {
		BackgroundColor3 = accentColor,
		Size = UDim2.fromOffset(20, 20),
		Parent = header,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = badge })
	Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "P",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Color3.new(1, 1, 1),
		Parent = badge,
	})
	Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -30, 1, 0),
		Text = data.Title or "Notification",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	-- Content
	Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = data.Content or "",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Theme.Get("SubText"),
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 2,
		Parent = card,
	})

	return card, stroke
end

-- ====================================================================
-- Public API
-- ====================================================================

--- Queues a notification. If more than MAX_VISIBLE are already shown,
-- this call waits its turn instead of overlapping the screen.
function Notification.Notify(data)
	table.insert(queue, data)
	Notification._processQueue()
end

function Notification._processQueue()
	if not container then
		warn("[PISIT HUB] Notification.Init() must be called before Notify().")
		return
	end
	if activeCount >= MAX_VISIBLE or #queue == 0 then
		return
	end

	local data = table.remove(queue, 1)
	activeCount += 1

	local card, stroke = buildCard(data)

	-- Fade + slide in
	card.Position = UDim2.new(0, 30, 0, 0)
	Animation.Tween(card, Animation.Easing.Smooth, {
		BackgroundTransparency = 0,
		Position = UDim2.new(0, 0, 0, 0),
	})
	Animation.Tween(stroke, Animation.Easing.Smooth, { Transparency = 0.2 })

	local duration = data.Duration or 4
	task.delay(duration, function()
		if not card or not card.Parent then
			return
		end
		local tween = Animation.Tween(card, Animation.Easing.Normal, {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 30, 0, 0),
		})
		Animation.Tween(stroke, Animation.Easing.Normal, { Transparency = 1 })
		tween.Completed:Connect(function()
			card:Destroy()
			activeCount -= 1
			Notification._processQueue()
		end)
	end)

	-- Immediately try to drain more of the queue if room allows.
	if activeCount < MAX_VISIBLE then
		Notification._processQueue()
	end
end

return Notification

end)()


Modules.Section = (function()
--[[
	PISIT HUB | Section.lua
	--------------------------------------------------------------------
	A Section is a titled group box living inside a Tab's page. It owns
	the factory methods for every leaf element (Button, Toggle, Slider,
	Dropdown, Textbox, Paragraph, Label) plus two elements implemented
	directly in this file because they are small and tightly coupled to
	Section-level layout: Keybind and Color Picker.
--]]

local UserInputService = game:GetService("UserInputService")

local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Config = Modules.Config

local Button = Modules.Button
local Toggle = Modules.Toggle
local Slider = Modules.Slider
local Dropdown = Modules.Dropdown
local Textbox = Modules.Textbox
local Paragraph = Modules.Paragraph
local Label = Modules.Label

local Section = {}
Section.__index = Section

--- @param parent Instance -- the Tab's page Frame
-- @param config table -- { Title }
function Section.new(parent, config)
	config = config or {}

	local self = setmetatable({}, Section)
	self.Title = config.Title or "Section"
	self.Elements = {}

	self.Instance = Utility.New("Frame", {
		Name = "Section_" .. self.Title,
		BackgroundColor3 = Theme.Get("SecondaryBackground"),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parent,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.Instance })
	self.Stroke = Utility.New("UIStroke", {
		Color = Theme.Get("Border"), Transparency = 0.8, Thickness = 1,
		Parent = self.Instance,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		Parent = self.Instance,
	})

	self.TitleLabel = Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Text = self.Title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Get("Accent"),
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 0,
		Parent = self.Instance,
	})

	self.Content = Utility.New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 24),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self.Instance,
	})
	Utility.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.Content,
	})

	Theme.OnChanged:Connect(function(_, palette)
		self.Instance.BackgroundColor3 = palette.SecondaryBackground
		self.Stroke.Color = palette.Border
		self.TitleLabel.TextColor3 = palette.Accent
	end)

	return self
end

-- ====================================================================
-- Factory methods (delegate to element modules)
-- ====================================================================

function Section:CreateButton(config)
	local element = Button.new(self.Content, config)
	table.insert(self.Elements, element)
	return element
end

function Section:CreateToggle(config)
	local element = Toggle.new(self.Content, config)
	table.insert(self.Elements, element)
	return element
end

function Section:CreateSlider(config)
	local element = Slider.new(self.Content, config)
	table.insert(self.Elements, element)
	return element
end

function Section:CreateDropdown(config)
	local element = Dropdown.new(self.Content, config)
	table.insert(self.Elements, element)
	return element
end

function Section:CreateTextbox(config)
	local element = Textbox.new(self.Content, config)
	table.insert(self.Elements, element)
	return element
end

function Section:CreateParagraph(config)
	local element = Paragraph.new(self.Content, config)
	table.insert(self.Elements, element)
	return element
end

function Section:CreateLabel(config)
	local element = Label.new(self.Content, config)
	table.insert(self.Elements, element)
	return element
end

-- ====================================================================
-- Keybind
-- ====================================================================

--- Creates a rebindable hotkey element.
-- @param config table -- { Title, Default (Enum.KeyCode), Flag, Callback }
function Section:CreateKeybind(config)
	config = config or {}

	local keybind = {}
	keybind.Title = config.Title or "Keybind"
	keybind.Flag = config.Flag or keybind.Title
	keybind.Callback = config.Callback or function() end
	keybind.Value = config.Default or Enum.KeyCode.Unknown
	keybind.Listening = false

	local instance = Utility.New("TextButton", {
		Name = "Keybind_" .. keybind.Title,
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 38),
		Parent = self.Content,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = instance })
	local stroke = Utility.New("UIStroke", {
		Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1,
		Parent = instance,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		Parent = instance,
	})

	Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -80, 1, 0),
		Text = keybind.Title,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = instance,
	})

	local keyLabel = Utility.New("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(70, 24),
		BackgroundColor3 = Theme.Get("Background"),
		Text = keybind.Value.Name,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Theme.Get("Accent"),
		Parent = instance,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = keyLabel })

	instance.MouseButton1Click:Connect(function()
		keybind.Listening = true
		keyLabel.Text = "..."
		Animation.Glow(stroke, true)
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
			keybind.Value = input.KeyCode
			keyLabel.Text = input.KeyCode.Name
			keybind.Listening = false
			Animation.Glow(stroke, false)
			return
		end

		if not processed and not keybind.Listening
			and input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode == keybind.Value then
			Utility.SafeCall(keybind.Callback)
		end
	end)

	function keybind:Set(keyCode, fromConfig)
		self.Value = keyCode
		keyLabel.Text = keyCode.Name
		if not fromConfig then
			Utility.SafeCall(self.Callback)
		end
	end

	function keybind:Get()
		return self.Value
	end

	Config.Register(keybind.Flag, {
		Get = function() return keybind.Value.Name end,
		Set = function(name)
			local ok, enumItem = pcall(function() return Enum.KeyCode[name] end)
			if ok and enumItem then
				keybind:Set(enumItem, true)
			end
		end,
	})

	Theme.OnChanged:Connect(function(_, palette)
		instance.BackgroundColor3 = palette.ElementBackground
		stroke.Color = palette.Border
		keyLabel.BackgroundColor3 = palette.Background
		keyLabel.TextColor3 = palette.Accent
	end)

	table.insert(self.Elements, keybind)
	return keybind
end

-- ====================================================================
-- Color Picker
-- ====================================================================

--- Creates a simple RGB color picker (three sliders + live preview).
-- A full HSV wheel is intentionally avoided to keep the element light
-- and dependency-free; the RGB sliders are fully sufficient for most
-- script configuration use-cases (ESP colors, chams, etc).
-- @param config table -- { Title, Default (Color3), Flag, Callback }
function Section:CreateColorPicker(config)
	config = config or {}

	local picker = {}
	picker.Title = config.Title or "Color Picker"
	picker.Flag = config.Flag or picker.Title
	picker.Callback = config.Callback or function() end
	picker.Value = config.Default or Color3.fromRGB(220, 30, 30)

	local instance = Utility.New("Frame", {
		Name = "ColorPicker_" .. picker.Title,
		BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 118),
		Parent = self.Content,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = instance })
	local stroke = Utility.New("UIStroke", {
		Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1,
		Parent = instance,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8),
		Parent = instance,
	})

	local header = Utility.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Parent = instance,
	})
	Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -30, 1, 0),
		Text = picker.Title,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	local preview = Utility.New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = picker.Value,
		Parent = header,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = preview })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Thickness = 1, Parent = preview })

	local channelHolder = Utility.New("Frame", {
		Position = UDim2.new(0, 0, 0, 26),
		Size = UDim2.new(1, 0, 0, 84),
		BackgroundTransparency = 1,
		Parent = instance,
	})
	Utility.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 4),
		Parent = channelHolder,
	})

	local channels = {}

	local function buildChannel(name, initial, colorHint)
		local row = Utility.New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 22),
			Parent = channelHolder,
		})
		Utility.New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(16, 22),
			Text = name,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = colorHint,
			Parent = row,
		})
		local bar = Utility.New("Frame", {
			Position = UDim2.new(0, 20, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.new(1, -20, 0, 6),
			BackgroundColor3 = Theme.Get("AccentDim"),
			Parent = row,
		})
		Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
		local fill = Utility.New("Frame", {
			Size = UDim2.new(initial / 255, 0, 1, 0),
			BackgroundColor3 = colorHint,
			Parent = bar,
		})
		Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

		local dragging = false
		local function setFromX(xPos)
			local relative = Utility.Clamp((xPos - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(relative, 0, 1, 0)
			channels[name] = math.floor(relative * 255 + 0.5)
			picker:_updateFromChannels(channels, preview)
		end

		bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				setFromX(input.Position.X)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				setFromX(input.Position.X)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		channels[name] = initial
	end

	buildChannel("R", math.floor(picker.Value.R * 255), Color3.fromRGB(255, 90, 90))
	buildChannel("G", math.floor(picker.Value.G * 255), Color3.fromRGB(90, 255, 120))
	buildChannel("B", math.floor(picker.Value.B * 255), Color3.fromRGB(90, 150, 255))

	function picker:_updateFromChannels(rgb, previewInstance)
		self.Value = Color3.fromRGB(rgb.R or 0, rgb.G or 0, rgb.B or 0)
		previewInstance.BackgroundColor3 = self.Value
		Utility.SafeCall(self.Callback, self.Value)
	end

	function picker:Set(color3, fromConfig)
		self.Value = color3
		preview.BackgroundColor3 = color3
		if not fromConfig then
			Utility.SafeCall(self.Callback, self.Value)
		end
	end

	function picker:Get()
		return self.Value
	end

	Config.Register(picker.Flag, {
		Get = function()
			return { R = picker.Value.R, G = picker.Value.G, B = picker.Value.B }
		end,
		Set = function(data)
			if type(data) == "table" then
				picker:Set(Color3.new(data.R or 0, data.G or 0, data.B or 0), true)
			end
		end,
	})

	Theme.OnChanged:Connect(function(_, palette)
		instance.BackgroundColor3 = palette.ElementBackground
		stroke.Color = palette.Border
	end)

	table.insert(self.Elements, picker)
	return picker
end

return Section

end)()


Modules.Tab = (function()
--[[
	PISIT HUB | Tab.lua
	--------------------------------------------------------------------
	Represents one sidebar tab: a clickable icon+label button in the
	Window's tab list, and a scrolling content "page" that shows/hides
	when the tab becomes active. Owns CreateSection() so tabs can be
	populated with grouped content.
--]]

local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Icons = Modules.Icons
local Section = Modules.Section

local Tab = {}
Tab.__index = Tab

--- @param window table -- the owning Window object (for tab-switching coordination)
-- @param tabListParent Instance -- sidebar frame that holds tab buttons
-- @param pageParent Instance -- frame that holds every tab's page
-- @param config table -- { Title, Icon }
function Tab.new(window, tabListParent, pageParent, config)
	config = config or {}

	local self = setmetatable({}, Tab)
	self.Window = window
	self.Title = config.Title or "Tab"
	self.Sections = {}

	-- Sidebar button
	self.Button = Utility.New("TextButton", {
		Name = "TabButton_" .. self.Title,
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Get("SecondaryBackground"),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 36),
		Parent = tabListParent,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Button })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = self.Button })

	self.Indicator = Utility.New("Frame", {
		Size = UDim2.new(0, 3, 0, 18),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Get("Accent"),
		BackgroundTransparency = 1,
		Parent = self.Button,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Indicator })

	if config.Icon then
		self.Icon = Utility.New("ImageLabel", {
			Position = UDim2.new(0, 10, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromOffset(16, 16),
			BackgroundTransparency = 1,
			Image = Icons.Get(config.Icon),
			ImageColor3 = Theme.Get("SubText"),
			Parent = self.Button,
		})
	end

	self.Label = Utility.New("TextLabel", {
		Position = UDim2.new(0, config.Icon and 32 or 10, 0, 0),
		Size = UDim2.new(1, -(config.Icon and 42 or 20), 1, 0),
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = Theme.Get("SubText"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Button,
	})

	-- Content page
	self.Page = Utility.New("ScrollingFrame", {
		Name = "Page_" .. self.Title,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Get("Accent"),
		Visible = false,
		Parent = pageParent,
	})
	Utility.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.Page,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 8),
		PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 12),
		Parent = self.Page,
	})

	self.Button.MouseButton1Click:Connect(function()
		self.Window:SelectTab(self)
	end)

	Animation.Hover(self.Button, Theme.Get("ElementBackground"), Theme.Get("SecondaryBackground"))

	Theme.OnChanged:Connect(function(_, palette)
		self.Label.TextColor3 = self.Active and palette.Text or palette.SubText
		self.Indicator.BackgroundColor3 = palette.Accent
		self.Page.ScrollBarImageColor3 = palette.Accent
		if self.Icon then
			self.Icon.ImageColor3 = self.Active and palette.Accent or palette.SubText
		end
	end)

	return self
end

--- Creates a new Section inside this tab's page.
function Tab:CreateSection(config)
	local section = Section.new(self.Page, config)
	table.insert(self.Sections, section)
	return section
end

--- Visually activates this tab (called by Window:SelectTab).
function Tab:SetActive(active)
	self.Active = active
	self.Page.Visible = active

	Animation.Tween(self.Indicator, Animation.Easing.Normal, {
		BackgroundTransparency = active and 0 or 1,
	})
	Animation.Tween(self.Label, Animation.Easing.Normal, {
		TextColor3 = active and Theme.Get("Text") or Theme.Get("SubText"),
	})
	if self.Icon then
		Animation.Tween(self.Icon, Animation.Easing.Normal, {
			ImageColor3 = active and Theme.Get("Accent") or Theme.Get("SubText"),
		})
	end
end

return Tab

end)()


Modules.Window = (function()
--[[
	PISIT HUB | Window.lua
	--------------------------------------------------------------------
	The root visual container of the library. Handles:
		- Dragging (desktop + mobile)
		- Open / Close animation
		- Minimize -> Mini Mode pill
		- Global element Search Box
		- Theme Manager dropdown
		- Tab creation + switching
		- Destroy (full UI teardown)

	One Window is created per Library:CreateWindow() call. Multiple
	windows can technically coexist since nothing here is stored in
	module-level state.
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Notification = Modules.Notification
local Tab = Modules.Tab

local Window = {}
Window.__index = Window

local DEFAULT_SIZE = UDim2.fromOffset(560, 380)
local MOBILE_SIZE = UDim2.fromScale(0.92, 0.7)

--- @param config table -- { Title, SubTitle, Theme, Size }
function Window.new(config)
	config = config or {}

	if config.Theme then
		Theme.SetTheme(config.Theme)
	end

	local self = setmetatable({}, Window)
	self.Title = config.Title or "PISIT HUB"
	self.SubTitle = config.SubTitle or ""
	self.Tabs = {}
	self.ActiveTab = nil
	self.Minimized = false

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	self.ScreenGui = Utility.New("ScreenGui", {
		Name = "PISIT_HUB",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = playerGui,
	})

	local size = config.Size or (Utility.IsMobile() and MOBILE_SIZE or DEFAULT_SIZE)

	self.Main = Utility.New("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = size,
		BackgroundColor3 = Theme.Get("Background"),
		ClipsDescendants = true,
		Parent = self.ScreenGui,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = self.Main })
	self.MainStroke = Utility.New("UIStroke", {
		Color = Theme.Get("Border"),
		Thickness = 1.5,
		Transparency = 0.2,
		Parent = self.Main,
	})

	self:_buildTopBar()
	self:_buildBody()
	self:_buildMiniPill()

	Notification.Init(self.ScreenGui)

	Utility.MakeDraggable(self.Main, self.TopBar)

	Theme.OnChanged:Connect(function(_, palette)
		self.Main.BackgroundColor3 = palette.Background
		self.MainStroke.Color = palette.Border
	end)

	Animation.OpenWindow(self.Main)

	return self
end

-- ====================================================================
-- Top bar: title, search box, minimize, close
-- ====================================================================

function Window:_buildTopBar()
	self.TopBar = Utility.New("Frame", {
		Name = "TopBar",
		BackgroundColor3 = Theme.Get("SecondaryBackground"),
		Size = UDim2.new(1, 0, 0, 44),
		Parent = self.Main,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = self.TopBar })
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 10),
		Parent = self.TopBar,
	})

	local titleHolder = Utility.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 220, 1, 0),
		Parent = self.TopBar,
	})
	Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 4),
		Size = UDim2.new(1, 0, 0, 18),
		Text = self.Title,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = Theme.Get("Accent"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleHolder,
	})
	if self.SubTitle ~= "" then
		Utility.New("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 22),
			Size = UDim2.new(1, 0, 0, 14),
			Text = self.SubTitle,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = Theme.Get("SubText"),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = titleHolder,
		})
	end

	-- Window controls (close / minimize), anchored right
	local controls = Utility.New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(64, 28),
		BackgroundTransparency = 1,
		Parent = self.TopBar,
	})
	Utility.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Parent = controls,
	})

	local minimizeBtn = self:_controlButton(controls, "-")
	minimizeBtn.MouseButton1Click:Connect(function()
		self:ToggleMinimize()
	end)

	local closeBtn = self:_controlButton(controls, "x")
	closeBtn.MouseButton1Click:Connect(function()
		self:Close()
	end)

	-- Search box, centered, appears between title and controls
	self.SearchBox = Utility.New("TextBox", {
		Position = UDim2.new(0, 230, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(1, -304, 0, 26),
		BackgroundColor3 = Theme.Get("ElementBackground"),
		PlaceholderText = "Search elements...",
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.Get("Text"),
		PlaceholderColor3 = Theme.Get("SubText"),
		ClearTextOnFocus = false,
		Parent = self.TopBar,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.SearchBox })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = self.SearchBox })

	self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_search(self.SearchBox.Text)
	end)
end

function Window:_controlButton(parent, text)
	local btn = Utility.New("TextButton", {
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Theme.Get("ElementBackground"),
		Text = text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Get("Text"),
		AutoButtonColor = false,
		Parent = parent,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
	Animation.Hover(btn, Theme.Get("Accent"), Theme.Get("ElementBackground"))
	return btn
end

--- Filters every element across every tab's every section by title
-- substring match, hiding non-matches. Empty query shows everything.
function Window:_search(query)
	query = query:lower()

	for _, tab in ipairs(self.Tabs) do
		for _, section in ipairs(tab.Sections) do
			local sectionHasMatch = query == ""
			for _, element in ipairs(section.Elements) do
				local title = (element.Title or ""):lower()
				local matches = query == "" or title:find(query, 1, true) ~= nil
				if element.Instance then
					element.Instance.Visible = matches
				end
				if matches then
					sectionHasMatch = true
				end
			end
			section.Instance.Visible = sectionHasMatch
		end
	end
end

-- ====================================================================
-- Body: sidebar (tab list) + page container
-- ====================================================================

function Window:_buildBody()
	self.Body = Utility.New("Frame", {
		Name = "Body",
		Position = UDim2.new(0, 0, 0, 44),
		Size = UDim2.new(1, 0, 1, -44),
		BackgroundTransparency = 1,
		Parent = self.Main,
	})

	self.Sidebar = Utility.New("ScrollingFrame", {
		Name = "Sidebar",
		BackgroundColor3 = Theme.Get("SecondaryBackground"),
		Size = UDim2.new(0, 140, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Get("Accent"),
		Parent = self.Body,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8),
		Parent = self.Sidebar,
	})
	Utility.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 4),
		Parent = self.Sidebar,
	})

	self.PageContainer = Utility.New("Frame", {
		Name = "PageContainer",
		Position = UDim2.new(0, 140, 0, 0),
		Size = UDim2.new(1, -140, 1, 0),
		BackgroundTransparency = 1,
		Parent = self.Body,
	})

	Theme.OnChanged:Connect(function(_, palette)
		self.Sidebar.BackgroundColor3 = palette.SecondaryBackground
		self.Sidebar.ScrollBarImageColor3 = palette.Accent
	end)
end

-- ====================================================================
-- Tabs
-- ====================================================================

--- Creates a new Tab and auto-selects it if it is the first tab.
-- @param config table -- { Title, Icon }
function Window:CreateTab(config)
	local tab = Tab.new(self, self.Sidebar, self.PageContainer, config)
	table.insert(self.Tabs, tab)

	if #self.Tabs == 1 then
		self:SelectTab(tab)
	end

	return tab
end

function Window:SelectTab(tab)
	if self.ActiveTab then
		self.ActiveTab:SetActive(false)
	end
	self.ActiveTab = tab
	tab:SetActive(true)
end

-- ====================================================================
-- Minimize / Mini Mode
-- ====================================================================

function Window:_buildMiniPill()
	self.MiniPill = Utility.New("Frame", {
		Name = "MiniPill",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.08),
		Size = UDim2.fromOffset(160, 40),
		BackgroundColor3 = Theme.Get("SecondaryBackground"),
		Visible = false,
		Parent = self.ScreenGui,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.MiniPill })
	Utility.New("UIStroke", { Color = Theme.Get("Accent"), Thickness = 1, Parent = self.MiniPill })

	local label = Utility.New("TextLabel", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.MiniPill,
	})

	local expandBtn = Utility.New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1,
		Text = "+",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Theme.Get("Accent"),
		Parent = self.MiniPill,
	})

	expandBtn.MouseButton1Click:Connect(function()
		self:ToggleMinimize()
	end)

	Utility.MakeDraggable(self.MiniPill)

	Theme.OnChanged:Connect(function(_, palette)
		self.MiniPill.BackgroundColor3 = palette.SecondaryBackground
		label.TextColor3 = palette.Text
		expandBtn.TextColor3 = palette.Accent
	end)
end

--- Collapses the main window into a small draggable pill (Mini Mode)
-- or restores it, depending on current state.
function Window:ToggleMinimize()
	self.Minimized = not self.Minimized

	if self.Minimized then
		Animation.CloseWindow(self.Main, function()
			self.MiniPill.Visible = true
			self.MiniPill.Size = UDim2.fromOffset(0, 40)
			Animation.Tween(self.MiniPill, Animation.Easing.Bounce, { Size = UDim2.fromOffset(160, 40) })
		end)
	else
		local tween = Animation.Tween(self.MiniPill, Animation.Easing.Fast, { Size = UDim2.fromOffset(0, 40) })
		tween.Completed:Connect(function()
			self.MiniPill.Visible = false
			Animation.OpenWindow(self.Main)
		end)
	end
end

-- ====================================================================
-- Close / Destroy
-- ====================================================================

--- Plays the close animation and hides the window (state preserved,
-- can be reopened with Window:Open()).
function Window:Close()
	Animation.CloseWindow(self.Main)
end

--- Reopens a previously closed window.
function Window:Open()
	Animation.OpenWindow(self.Main)
end

--- Fully destroys the window and every descendant Instance. This is
-- irreversible -- use Close() instead if you may want to reopen later.
function Window:Destroy()
	Animation.CloseWindow(self.Main, function()
		self.ScreenGui:Destroy()
	end)
end

return Window

end)()


-- ==== init.lua (bundle entry point) ====

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

local Theme = Modules.Theme
local Config = Modules.Config
local Notification = Modules.Notification
local Window = Modules.Window
local Icons = Modules.Icons

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
