--[[
	PISIT HUB | Tab.lua
	--------------------------------------------------------------------
	Represents one sidebar tab: a clickable icon+label button in the
	Window's tab list, and a scrolling content "page" that shows/hides
	when the tab becomes active. Owns CreateSection() so tabs can be
	populated with grouped content.
--]]

local Theme = require(script.Parent.Theme)
local Utility = require(script.Parent.Utility)
local Animation = require(script.Parent.Animation)
local Icons = require(script.Parent.Icons)
local Section = require(script.Parent.Section)

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
