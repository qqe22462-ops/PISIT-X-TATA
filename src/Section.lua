--[[
	PISIT HUB | Section.lua
	--------------------------------------------------------------------
	A Section is a titled group box living inside a Tab's page. It owns
	the factory methods for every leaf element (Button, Toggle, Slider,
	Dropdown, Textbox, Paragraph, Label) plus two elements implemented
	directly in this file because they are small and tightly coupled to
	Section-level layout: Keybind and Color Picker.
--]]

local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent.Theme)
local Utility = require(script.Parent.Utility)
local Animation = require(script.Parent.Animation)
local Config = require(script.Parent.Config)

local Button = require(script.Parent.Button)
local Toggle = require(script.Parent.Toggle)
local Slider = require(script.Parent.Slider)
local Dropdown = require(script.Parent.Dropdown)
local Textbox = require(script.Parent.Textbox)
local Paragraph = require(script.Parent.Paragraph)
local Label = require(script.Parent.Label)

local Section = {}
Section.__index = Section

--- @param parent Instance -- the Tab's page Frame
-- @param config table -- { Title }
function Section.new(parent, config)
	config = config or {}

	local self = setmetatable({}, Section)
	self.Title = config.Title or "Section"
	self.Elements = {}

	self.Instance = Utility.New("Frame", {
		Name = "Section_" .. self.Title,
		BackgroundColor3 = Theme.Get("SecondaryBackground"),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parent,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.Instance })
	self.Stroke = Utility.New("UIStroke", {
		Color = Theme.Get("Border"), Transparency = 0.8, Thickness = 1,
		Parent = self.Instance,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		Parent = self.Instance,
	})

	self.TitleLabel = Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Text = self.Title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Get("Accent"),
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 0,
		Parent = self.Instance,
	})

	self.Content = Utility.New("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 24),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self.Instance,
	})
	Utility.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.Content,
	})

	Theme.OnChanged:Connect(function(_, palette)
		self.Instance.BackgroundColor3 = palette.SecondaryBackground
		self.Stroke.Color = palette.Border
		self.TitleLabel.TextColor3 = palette.Accent
	end)

	return self
end

-- ====================================================================
-- Factory methods (delegate to element modules)
-- ====================================================================

function Section:CreateButton(config)
	local element = Button.new(self.Content, config)
	table.insert(self.Elements, element)
	return element
end

function Section:CreateToggle(config)
	local element = Toggle.new(self.Content, config)
	table.insert(self.Elements, element)
	return element
end

function Section:CreateSlider(config)
	local element = Slider.new(self.Content, config)
	table.insert(self.Elements, element)
	return element
end

function Section:CreateDropdown(config)
	local element = Dropdown.new(self.Content, config)
	table.insert(self.Elements, element)
	return element
end

function Section:CreateTextbox(config)
	local element = Textbox.new(self.Content, config)
	table.insert(self.Elements, element)
	return element
end

function Section:CreateParagraph(config)
	local element = Paragraph.new(self.Content, config)
	table.insert(self.Elements, element)
	return element
end

function Section:CreateLabel(config)
	local element = Label.new(self.Content, config)
	table.insert(self.Elements, element)
	return element
end

-- ====================================================================
-- Keybind
-- ====================================================================

--- Creates a rebindable hotkey element.
-- @param config table -- { Title, Default (Enum.KeyCode), Flag, Callback }
function Section:CreateKeybind(config)
	config = config or {}

	local keybind = {}
	keybind.Title = config.Title or "Keybind"
	keybind.Flag = config.Flag or keybind.Title
	keybind.Callback = config.Callback or function() end
	keybind.Value = config.Default or Enum.KeyCode.Unknown
	keybind.Listening = false

	local instance = Utility.New("TextButton", {
		Name = "Keybind_" .. keybind.Title,
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 38),
		Parent = self.Content,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = instance })
	local stroke = Utility.New("UIStroke", {
		Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1,
		Parent = instance,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		Parent = instance,
	})

	Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -80, 1, 0),
		Text = keybind.Title,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = instance,
	})

	local keyLabel = Utility.New("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(70, 24),
		BackgroundColor3 = Theme.Get("Background"),
		Text = keybind.Value.Name,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Theme.Get("Accent"),
		Parent = instance,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = keyLabel })

	instance.MouseButton1Click:Connect(function()
		keybind.Listening = true
		keyLabel.Text = "..."
		Animation.Glow(stroke, true)
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
			keybind.Value = input.KeyCode
			keyLabel.Text = input.KeyCode.Name
			keybind.Listening = false
			Animation.Glow(stroke, false)
			return
		end

		if not processed and not keybind.Listening
			and input.UserInputType == Enum.UserInputType.Keyboard
			and input.KeyCode == keybind.Value then
			Utility.SafeCall(keybind.Callback)
		end
	end)

	function keybind:Set(keyCode, fromConfig)
		self.Value = keyCode
		keyLabel.Text = keyCode.Name
		if not fromConfig then
			Utility.SafeCall(self.Callback)
		end
	end

	function keybind:Get()
		return self.Value
	end

	Config.Register(keybind.Flag, {
		Get = function() return keybind.Value.Name end,
		Set = function(name)
			local ok, enumItem = pcall(function() return Enum.KeyCode[name] end)
			if ok and enumItem then
				keybind:Set(enumItem, true)
			end
		end,
	})

	Theme.OnChanged:Connect(function(_, palette)
		instance.BackgroundColor3 = palette.ElementBackground
		stroke.Color = palette.Border
		keyLabel.BackgroundColor3 = palette.Background
		keyLabel.TextColor3 = palette.Accent
	end)

	table.insert(self.Elements, keybind)
	return keybind
end

-- ====================================================================
-- Color Picker
-- ====================================================================

--- Creates a simple RGB color picker (three sliders + live preview).
-- A full HSV wheel is intentionally avoided to keep the element light
-- and dependency-free; the RGB sliders are fully sufficient for most
-- script configuration use-cases (ESP colors, chams, etc).
-- @param config table -- { Title, Default (Color3), Flag, Callback }
function Section:CreateColorPicker(config)
	config = config or {}

	local picker = {}
	picker.Title = config.Title or "Color Picker"
	picker.Flag = config.Flag or picker.Title
	picker.Callback = config.Callback or function() end
	picker.Value = config.Default or Color3.fromRGB(220, 30, 30)

	local instance = Utility.New("Frame", {
		Name = "ColorPicker_" .. picker.Title,
		BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 118),
		Parent = self.Content,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = instance })
	local stroke = Utility.New("UIStroke", {
		Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1,
		Parent = instance,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 8),
		Parent = instance,
	})

	local header = Utility.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Parent = instance,
	})
	Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -30, 1, 0),
		Text = picker.Title,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	local preview = Utility.New("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = picker.Value,
		Parent = header,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = preview })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Thickness = 1, Parent = preview })

	local channelHolder = Utility.New("Frame", {
		Position = UDim2.new(0, 0, 0, 26),
		Size = UDim2.new(1, 0, 0, 84),
		BackgroundTransparency = 1,
		Parent = instance,
	})
	Utility.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 4),
		Parent = channelHolder,
	})

	local channels = {}

	local function buildChannel(name, initial, colorHint)
		local row = Utility.New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 22),
			Parent = channelHolder,
		})
		Utility.New("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(16, 22),
			Text = name,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = colorHint,
			Parent = row,
		})
		local bar = Utility.New("Frame", {
			Position = UDim2.new(0, 20, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.new(1, -20, 0, 6),
			BackgroundColor3 = Theme.Get("AccentDim"),
			Parent = row,
		})
		Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
		local fill = Utility.New("Frame", {
			Size = UDim2.new(initial / 255, 0, 1, 0),
			BackgroundColor3 = colorHint,
			Parent = bar,
		})
		Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

		local dragging = false
		local function setFromX(xPos)
			local relative = Utility.Clamp((xPos - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			fill.Size = UDim2.new(relative, 0, 1, 0)
			channels[name] = math.floor(relative * 255 + 0.5)
			picker:_updateFromChannels(channels, preview)
		end

		bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				setFromX(input.Position.X)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				setFromX(input.Position.X)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)

		channels[name] = initial
	end

	buildChannel("R", math.floor(picker.Value.R * 255), Color3.fromRGB(255, 90, 90))
	buildChannel("G", math.floor(picker.Value.G * 255), Color3.fromRGB(90, 255, 120))
	buildChannel("B", math.floor(picker.Value.B * 255), Color3.fromRGB(90, 150, 255))

	function picker:_updateFromChannels(rgb, previewInstance)
		self.Value = Color3.fromRGB(rgb.R or 0, rgb.G or 0, rgb.B or 0)
		previewInstance.BackgroundColor3 = self.Value
		Utility.SafeCall(self.Callback, self.Value)
	end

	function picker:Set(color3, fromConfig)
		self.Value = color3
		preview.BackgroundColor3 = color3
		if not fromConfig then
			Utility.SafeCall(self.Callback, self.Value)
		end
	end

	function picker:Get()
		return self.Value
	end

	Config.Register(picker.Flag, {
		Get = function()
			return { R = picker.Value.R, G = picker.Value.G, B = picker.Value.B }
		end,
		Set = function(data)
			if type(data) == "table" then
				picker:Set(Color3.new(data.R or 0, data.G or 0, data.B or 0), true)
			end
		end,
	})

	Theme.OnChanged:Connect(function(_, palette)
		instance.BackgroundColor3 = palette.ElementBackground
		stroke.Color = palette.Border
	end)

	table.insert(self.Elements, picker)
	return picker
end

return Section
