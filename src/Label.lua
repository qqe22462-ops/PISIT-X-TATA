--[[
	PISIT HUB | Label.lua
	--------------------------------------------------------------------
	Minimal single-line text element, cheaper than Paragraph, used for
	status readouts, headers within a section, or dynamic value display
	(e.g. "FPS: 60").
--]]

local Theme = require(script.Parent.Theme)
local Utility = require(script.Parent.Utility)

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
