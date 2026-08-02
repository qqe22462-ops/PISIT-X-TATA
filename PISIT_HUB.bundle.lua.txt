--[[
	PISIT HUB | Single-File Bundle (Updated with All Rayfield-style Components)
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
}

Theme.OnChanged = newSignal()
Theme.Current = "Red"
Theme.Active = Theme.Palettes.Red

function Theme.Register(name, palette)
	assert(type(name) == "string", "Theme name must be a string")
	assert(type(palette) == "table", "Theme palette must be a table")
	local merged = {}
	for key, value in pairs(Theme.Palettes.Red) do
		merged[key] = palette[key] or value
	end
	Theme.Palettes[name] = merged
	return merged
end

function Theme.SetTheme(name)
	local palette = Theme.Palettes[name]
	if not palette then return false end
	Theme.Current = name
	Theme.Active = palette
	Theme.OnChanged:Fire(name, palette)
	return true
end

function Theme.Get(key)
	return Theme.Active[key]
end

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
local TweenService = game:GetService("TweenService")
local Utility = Modules.Utility
local Animation = {}

Animation.Easing = {
	Fast   = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Bounce = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

function Animation.Tween(instance, info, props)
	local tween = TweenService:Create(instance, info, props)
	tween:Play()
	return tween
end

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
		if onComplete then onComplete() end
	end)
end

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
		Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset - 4, originalSize.Y.Scale, originalSize.Y.Offset - 2),
	})
	task.delay(0.08, function()
		Animation.Tween(instance, Animation.Easing.Bounce, { Size = originalSize })
	end)
end

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
	tween.Completed:Connect(function() ripple:Destroy() end)
end

function Animation.Glow(stroke, active)
	local goal = active and 0 or 0.6
	Animation.Tween(stroke, Animation.Easing.Normal, { Transparency = goal })
end

function Animation.Fade(instance, transparency, duration)
	return Animation.Tween(instance, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quad), { BackgroundTransparency = transparency })
end

return Animation
end)()

Modules.Icons = (function()
local Icons = {}
Icons.Registry = {
	logo      = "rbxassetid://0",
	settings  = "rbxassetid://0",
	search    = "rbxassetid://0",
	close     = "rbxassetid://0",
	minimize  = "rbxassetid://0",
	check     = "rbxassetid://106878473664566",
}
function Icons.Get(name)
	if type(name) == "string" and name:sub(1, 13) == "rbxassetid://" then
		return name
	end
	return Icons.Registry[name] or "rbxasset://textures/ui/GuiImagePlaceholder.png"
end
return Icons
end)()


Modules.Config = (function()
local HttpService = game:GetService("HttpService")
local Config = {}
Config._flags = {}
Config._folder = "PISIT_HUB/configs"

local function fsAvailable()
	return typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function"
end

local function ensureFolder()
	if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
		if not isfolder(Config._folder) then makefolder(Config._folder) end
	end
end

function Config.Register(flag, getSet)
	Config._flags[flag] = getSet
end

function Config.Save(name)
	name = name or "default"
	if not fsAvailable() then return false, "No file IO" end
	ensureFolder()
	local data = {}
	for flag, getSet in pairs(Config._flags) do
		local ok, value = pcall(getSet.Get)
		if ok then data[flag] = value end
	end
	local encoded = HttpService:JSONEncode(data)
	writefile(Config._folder .. "/" .. name .. ".json", encoded)
	return true
end

function Config.Load(name)
	name = name or "default"
	if not fsAvailable() then return false, "No file IO" end
	local path = Config._folder .. "/" .. name .. ".json"
	if not isfile(path) then return false, "Not found" end
	local raw = readfile(path)
	local data = HttpService:JSONDecode(raw)
	for flag, value in pairs(data) do
		local getSet = Config._flags[flag]
		if getSet then pcall(getSet.Set, value) end
	end
	return true
end

return Config
end)()


Modules.Button = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Button = {}
Button.__index = Button

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
	self.Stroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = self.Instance })

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

	Animation.Hover(self.Instance, Theme.Get("ElementBackground"):Lerp(Theme.Get("Accent"), 0.15), Theme.Get("ElementBackground"))

	self.Instance.MouseButton1Click:Connect(function()
		if not self.Enabled then return end
		Animation.Click(self.Instance)
		Utility.SafeCall(self.Callback)
	end)

	return self
end
return Button
end)()


Modules.Toggle = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Config = Modules.Config
local Icons = Modules.Icons
local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Toggle)
	self.Title = config.Title or "Toggle"
	self.Flag = config.Flag or self.Title
	self.Callback = config.Callback or function() end
	self.Value = config.Default or false

	self.Instance = Utility.New("Frame", {
		Name = "Toggle_" .. self.Title,
		BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 38),
		Parent = parent,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Instance })
	self.Stroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 8), Parent = self.Instance })

	self.Label = Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -44, 1, 0),
		Text = self.Title,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.Instance,
	})

	self.Square = Utility.New("TextButton", {
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = Theme.Get("Background"),
		Parent = self.Instance,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Square })
	self.SquareStroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Thickness = 1, Transparency = 0.4, Parent = self.Square })

	self.Icon = Utility.New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 1, -10),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Image = Icons.Get("check"),
		ImageColor3 = Theme.Get("SubText"),
		Parent = self.Square,
	})

	self.Square.MouseButton1Click:Connect(function()
		self:Set(not self.Value)
	end)

	Config.Register(self.Flag, {
		Get = function() return self.Value end,
		Set = function(value) self:Set(value, true) end,
	})

	self:_render(false)
	return self
end

function Toggle:_render(animate)
	local palette = Theme.Active
	self.Square.BackgroundColor3 = self.Value and palette.AccentDim or palette.Background
	self.Icon.ImageColor3 = self.Value and palette.Accent or palette.SubText
end

function Toggle:Set(value, fromConfig)
	self.Value = value and true or false
	self:_render(true)
	if not fromConfig then Utility.SafeCall(self.Callback, self.Value) end
end

return Toggle
end)()


Modules.Slider = (function()
local UserInputService = game:GetService("UserInputService")
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Config = Modules.Config
local Slider = {}
Slider.__index = Slider

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
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8), Parent = self.Instance })

	local header = Utility.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Parent = self.Instance })
	Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Text = self.Title, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
	self.ValueLabel = Utility.New("TextLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(60, 18), Text = tostring(self.Value), Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Get("Accent"), TextXAlignment = Enum.TextXAlignment.Right, Parent = header })

	self.Bar = Utility.New("Frame", { Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 6), BackgroundColor3 = Theme.Get("AccentDim"), Parent = self.Instance })
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Bar })
	self.Fill = Utility.New("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Get("Accent"), Parent = self.Bar })
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Fill })
	self.Knob = Utility.New("Frame", { Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), Parent = self.Bar })
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Knob })

	local function updateFromX(xPos)
		local relative = Utility.Clamp((xPos - self.Bar.AbsolutePosition.X) / self.Bar.AbsoluteSize.X, 0, 1)
		local raw = self.Min + relative * (self.Max - self.Min)
		local stepped = Utility.Round(raw / self.Increment) * self.Increment
		self:Set(Utility.Clamp(stepped, self.Min, self.Max))
	end

	self.Bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.Dragging = true
			updateFromX(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if self.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromX(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.Dragging = false
		end
	end)

	Config.Register(self.Flag, { Get = function() return self.Value end, Set = function(v) self:Set(v, true) end })
	self:_render(false)
	return self
end

function Slider:_render()
	local alpha = Utility.Clamp((self.Value - self.Min) / (self.Max - self.Min), 0, 1)
	self.ValueLabel.Text = tostring(self.Value)
	self.Fill.Size = UDim2.new(alpha, 0, 1, 0)
	self.Knob.Position = UDim2.new(alpha, 0, 0.5, 0)
end

function Slider:Set(value, fromConfig)
	self.Value = Utility.Clamp(value, self.Min, self.Max)
	self:_render()
	if not fromConfig then Utility.SafeCall(self.Callback, self.Value) end
end

return Slider
end)()


Modules.Dropdown = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Config = Modules.Config
local Dropdown = {}
Dropdown.__index = Dropdown

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
	self.Selected = {}

	if self.Multi then
		for _, v in ipairs(config.Default or {}) do self.Selected[v] = true end
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
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })

	self.Header = Utility.New("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = self.Header })
	self.Label = Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Text = self.Title, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Header })
	self.Chevron = Utility.New("TextLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(16, 16), Text = "v", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.Get("SubText"), Parent = self.Header })

	self.Body = Utility.New("Frame", { Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Parent = self.Instance })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 4), Parent = self.Body })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = self.Body })

	if self.Searchable then
		self.SearchBox = Utility.New("TextBox", { PlaceholderText = "Search...", Text = "", BackgroundColor3 = Theme.Get("Background"), Size = UDim2.new(1, 0, 0, 26), Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Get("Text"), Parent = self.Body })
		Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.SearchBox })
		Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = self.SearchBox })
		self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
			local q = self.SearchBox.Text:lower()
			for _, child in ipairs(self.OptionHolder:GetChildren()) do
				if child:IsA("TextButton") then
					child.Visible = q == "" or child.Name:lower():find(q, 1, true) ~= nil
				end
			end
		end)
	end

	self.OptionHolder = Utility.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = self.Body })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 2), Parent = self.OptionHolder })

	self.Header.MouseButton1Click:Connect(function()
		self.Open = not self.Open
		local target = self.SearchBox and 34 or 0
		for _, _ in ipairs(self.Options) do target = target + 30 end
		Animation.Tween(self.Instance, Animation.Easing.Smooth, { Size = UDim2.new(1, 0, 0, self.Open and (38 + math.min(target + 16, 220)) or 38) })
		Animation.Tween(self.Chevron, Animation.Easing.Normal, { Rotation = self.Open and 180 or 0 })
	end)

	self:Refresh(self.Options)
	Config.Register(self.Flag, { Get = function() return self:Get() end, Set = function(v) self:SetSelected(v, true) end })
	return self
end

function Dropdown:Refresh(list)
	self.Options = list
	for _, child in ipairs(self.OptionHolder:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
	for _, optionName in ipairs(list) do
		local btn = Utility.New("TextButton", { Name = "Option_" .. optionName, Text = "", AutoButtonColor = false, BackgroundColor3 = Theme.Get("Background"), Size = UDim2.new(1, 0, 0, 28), Parent = self.OptionHolder })
		Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
		Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = btn })
		local lbl = Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = optionName, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = self.Selected[optionName] and Theme.Get("Accent") or Theme.Get("SubText"), TextXAlignment = Enum.TextXAlignment.Left, Parent = btn })
		btn.MouseButton1Click:Connect(function()
			if self.Multi then
				self.Selected[optionName] = not self.Selected[optionName] or nil
			else
				self.Selected = { [optionName] = true }
				self.Open = false
				Animation.Tween(self.Instance, Animation.Easing.Fast, { Size = UDim2.new(1, 0, 0, 38) })
			end
			lbl.TextColor3 = self.Selected[optionName] and Theme.Get("Accent") or Theme.Get("SubText")
			Utility.SafeCall(self.Callback, self:Get())
		end)
	end
end

function Dropdown:Get()
	if self.Multi then
		local names = {}
		for name in pairs(self.Selected) do table.insert(names, name) end
		return names
	end
	for name in pairs(self.Selected) do return name end
	return nil
end

function Dropdown:SetSelected(value, fromConfig)
	self.Selected = {}
	if self.Multi and type(value) == "table" then
		for _, v in ipairs(value) do self.Selected[v] = true end
	elseif value then
		self.Selected[value] = true
	end
	self:Refresh(self.Options)
	if not fromConfig then Utility.SafeCall(self.Callback, self:Get()) end
end

return Dropdown
end)()


Modules.Textbox = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Config = Modules.Config
local Textbox = {}
Textbox.__index = Textbox

function Textbox.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Textbox)
	self.Title = config.Title or "Textbox"
	self.Flag = config.Flag or self.Title
	self.Callback = config.Callback or function() end
	self.Value = config.Default or ""

	self.Instance = Utility.New("Frame", { Name = "Textbox_" .. self.Title, BackgroundColor3 = Theme.Get("ElementBackground"), Size = UDim2.new(1, 0, 0, 58), Parent = parent })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Instance })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8), Parent = self.Instance })

	Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Text = self.Title, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance })
	local inputRow = Utility.New("Frame", { Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = Theme.Get("Background"), Parent = self.Instance })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = inputRow })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = inputRow })

	self.Box = Utility.New("TextBox", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = self.Value, PlaceholderText = config.Placeholder or "Enter text...", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = inputRow })
	self.Box.FocusLost:Connect(function(enterPressed)
		self.Value = self.Box.Text
		if enterPressed then Utility.SafeCall(self.Callback, self.Value) end
	end)

	Config.Register(self.Flag, { Get = function() return self.Value end, Set = function(v) self.Value = v; self.Box.Text = v end })
	return self
end

function Textbox:Get() return self.Value end
return Textbox
end)()


Modules.Paragraph = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Paragraph = {}
Paragraph.__index = Paragraph

function Paragraph.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Paragraph)
	self.Instance = Utility.New("Frame", { Name = "Paragraph", BackgroundColor3 = Theme.Get("ElementBackground"), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Instance })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.8, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = self.Instance })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 4), Parent = self.Instance })

	if config.Title and config.Title ~= "" then
		Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Text = config.Title, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance })
	end
	Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = config.Content or "", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Get("SubText"), TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance })
	return self
end
return Paragraph
end)()


Modules.Label = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Label = {}
Label.__index = Label
function Label.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Label)
	self.Instance = Utility.New("TextLabel", { Name = "Label", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Text = config.Text or "Label", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Get("SubText"), TextXAlignment = Enum.TextXAlignment.Left, Parent = parent })
	return self
end
return Label
end)()


Modules.Section = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Section = {}
Section.__index = Section

function Section.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Section)
	self.Title = config.Title or "Section"
	self.Elements = {}

	self.Instance = Utility.New("Frame", { Name = "Section_" .. self.Title, BackgroundColor3 = Theme.Get("SecondaryBackground"), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.Instance })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.8, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), Parent = self.Instance })
	Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Text = self.Title, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Get("Accent"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance })

	self.Content = Utility.New("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 24), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = self.Instance })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8), Parent = self.Content })
	return self
end

function Section:CreateButton(cfg) local e = Modules.Button.new(self.Content, cfg); table.insert(self.Elements, e); return e end
function Section:CreateToggle(cfg) local e = Modules.Toggle.new(self.Content, cfg); table.insert(self.Elements, e); return e end
function Section:CreateSlider(cfg) local e = Modules.Slider.new(self.Content, cfg); table.insert(self.Elements, e); return e end
function Section:CreateDropdown(cfg) local e = Modules.Dropdown.new(self.Content, cfg); table.insert(self.Elements, e); return e end
function Section:CreateTextbox(cfg) local e = Modules.Textbox.new(self.Content, cfg); table.insert(self.Elements, e); return e end
function Section:CreateParagraph(cfg) local e = Modules.Paragraph.new(self.Content, cfg); table.insert(self.Elements, e); return e end
function Section:CreateLabel(cfg) local e = Modules.Label.new(self.Content, cfg); table.insert(self.Elements, e); return e end

return Section
end)()


Modules.Tab = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Tab = {}
Tab.__index = Tab

function Tab.new(window, tabListParent, pageParent, config)
	config = config or {}
	local self = setmetatable({}, Tab)
	self.Window = window
	self.Title = config.Title or "Tab"
	self.Sections = {}

	self.Button = Utility.New("TextButton", { Name = "TabButton_" .. self.Title, Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = tabListParent })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Button })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = self.Button })

	self.Indicator = Utility.New("Frame", { Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.Get("Accent"), BackgroundTransparency = 1, Parent = self.Button })
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Indicator })

	self.Label = Utility.New("TextLabel", { Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1, Text = self.Title, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Get("SubText"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Button })

	self.Page = Utility.New("ScrollingFrame", { Name = "Page_" .. self.Title, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, Visible = false, Parent = pageParent })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 10), Parent = self.Page })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 4), Parent = self.Page })

	self.Button.MouseButton1Click:Connect(function() self.Window:SelectTab(self) end)
	return self
end

function Tab:CreateSection(cfg)
	local section = Modules.Section.new(self.Page, cfg)
	table.insert(self.Sections, section)
	return section
end

function Tab:SetActive(active)
	self.Active = active
	self.Page.Visible = active
	Animation.Tween(self.Indicator, Animation.Easing.Normal, { BackgroundTransparency = active and 0 or 1 })
	Animation.Tween(self.Label, Animation.Easing.Normal, { TextColor3 = active and Theme.Get("Text") or Theme.Get("SubText") })
end

return Tab
end)()


Modules.Window = (function()
local Players = game:GetService("Players")
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Window = {}
Window.__index = Window

function Window.new(config)
	config = config or {}
	local self = setmetatable({}, Window)
	self.Title = config.Title or "PISIT HUB"
	self.Tabs = {}
	self.ActiveTab = nil

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	self.ScreenGui = Utility.New("ScreenGui", { Name = "PISIT_HUB", ResetOnSpawn = false, Parent = playerGui })

	self.Main = Utility.New("Frame", { Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(380, 300), BackgroundColor3 = Theme.Get("Background"), ClipsDescendants = true, Parent = self.ScreenGui })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = self.Main })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Thickness = 1.5, Transparency = 0.2, Parent = self.Main })

	self:_buildTopBar()
	self:_buildBody()
	Utility.MakeDraggable(self.Main, self.TopBar)
	Animation.OpenWindow(self.Main)
	return self
end

function Window:_buildTopBar()
	self.TopBar = Utility.New("Frame", { Name = "TopBar", BackgroundColor3 = Theme.Get("SecondaryBackground"), Size = UDim2.new(1, 0, 0, 50), Parent = self.Main })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = self.TopBar })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 10), Parent = self.TopBar })

	Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), Text = self.Title, Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = Theme.Get("Accent"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.TopBar })

	local closeBtn = Utility.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(26, 26), BackgroundColor3 = Theme.Get("ElementBackground"), Text = "x", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Get("Text"), AutoButtonColor = false, Parent = self.TopBar })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = closeBtn })
	closeBtn.MouseButton1Click:Connect(function() self.ScreenGui:Destroy() end)
end

function Window:_buildBody()
	self.Body = Utility.New("Frame", { Name = "Body", Position = UDim2.new(0, 0, 0, 50), Size = UDim2.new(1, 0, 1, -50), BackgroundTransparency = 1, Parent = self.Main })
	self.Sidebar = Utility.New("ScrollingFrame", { Name = "Sidebar", BackgroundColor3 = Theme.Get("SecondaryBackground"), Size = UDim2.new(0, 140, 1, 0), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, Parent = self.Body })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), Parent = self.Sidebar })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 4), Parent = self.Sidebar })

	self.PageContainer = Utility.New("Frame", { Name = "PageContainer", Position = UDim2.new(0, 140, 0, 0), Size = UDim2.new(1, -140, 1, 0), BackgroundTransparency = 1, Parent = self.Body })
end

function Window:CreateTab(config)
	local tab = Modules.Tab.new(self, self.Sidebar, self.PageContainer, config)
	table.insert(self.Tabs, tab)
	if #self.Tabs == 1 then self:SelectTab(tab) end
	return tab
end

function Window:SelectTab(tab)
	if self.ActiveTab then self.ActiveTab:SetActive(false) end
	self.ActiveTab = tab
	tab:SetActive(true)
end

return Window
end)()


local Library = {}
Library._version = "1.0.0"
Library.Theme = Modules.Theme
Library.Config = Modules.Config
Library.Icons = Modules.Icons

function Library:CreateWindow(config)
	return Modules.Window.new(config)
end

return Library