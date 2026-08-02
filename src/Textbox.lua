--[[
	PISIT HUB | Textbox.lua
	--------------------------------------------------------------------
	Single-line text input element with placeholder text, a Clear
	button, focus glow animation, and callback-on-enter support.
--]]

local Theme = require(script.Parent.Theme)
local Utility = require(script.Parent.Utility)
local Animation = require(script.Parent.Animation)
local Config = require(script.Parent.Config)

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
