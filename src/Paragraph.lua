--[[
	PISIT HUB | Paragraph.lua
	--------------------------------------------------------------------
	Multi-line, word-wrapped informational text block with an optional
	bold title row. Used for descriptions, changelogs, warnings, etc.
--]]

local Theme = require(script.Parent.Theme)
local Utility = require(script.Parent.Utility)

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
