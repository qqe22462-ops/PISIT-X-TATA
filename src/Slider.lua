--[[
	PISIT HUB | Slider.lua
	--------------------------------------------------------------------
	Drag-to-set numeric slider with Min/Max/Default, real-time value
	label, smooth fill animation, and full mouse + touch support.
--]]

local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent.Theme)
local Utility = require(script.Parent.Utility)
local Animation = require(script.Parent.Animation)
local Config = require(script.Parent.Config)

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
