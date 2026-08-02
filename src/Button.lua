--[[
	PISIT HUB | Button.lua
	--------------------------------------------------------------------
	Standard clickable button element: hover glow, click scale, ripple
	feedback, callback support, and Enable/Disable state.
--]]

local Theme = require(script.Parent.Theme)
local Utility = require(script.Parent.Utility)
local Animation = require(script.Parent.Animation)

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
