--[[
	PISIT HUB | Dropdown.lua
	--------------------------------------------------------------------
	Dropdown element supporting: single or multi-select, an internal
	search box to filter long option lists, runtime Refresh/Add/Remove
	of options, and Config.lua flag registration.
--]]

local Theme = require(script.Parent.Theme)
local Utility = require(script.Parent.Utility)
local Animation = require(script.Parent.Animation)
local Config = require(script.Parent.Config)

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
