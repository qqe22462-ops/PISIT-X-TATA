--[[
	PISIT HUB | Toggle.lua
	--------------------------------------------------------------------
	On/off switch element with a smooth sliding knob animation, default
	value support, callback firing, and Config.lua flag registration
	for Save/Load/Auto Save.
--]]

local Theme = require(script.Parent.Theme)
local Utility = require(script.Parent.Utility)
local Animation = require(script.Parent.Animation)
local Config = require(script.Parent.Config)

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
