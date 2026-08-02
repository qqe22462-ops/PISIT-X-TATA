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

local Theme = require(script.Parent.Theme)
local Utility = require(script.Parent.Utility)
local Animation = require(script.Parent.Animation)
local Notification = require(script.Parent.Notification)
local Tab = require(script.Parent.Tab)

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
