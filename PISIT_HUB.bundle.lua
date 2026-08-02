--[[
	PISIT HUB | Complete Single-File Bundle (Rayfield Style)
	--------------------------------------------------------------------
	Includes: Window, Tabs, Sections, Buttons, Toggles, Sliders, Dropdowns,
	Textbox, Paragraph, Label, Keybind, ColorPicker, Minimize/Close Controls,
	and Mobile-optimized 400x320 default window sizing.
--]]

local Modules = {}

Modules.Utility = (function()
local UserInputService = game:GetService("UserInputService")
local Utility = {}

function Utility.New(className, props, children)
	local inst = Instance.new(className)
	if props then
		for key, value in pairs(props) do
			if key ~= "Parent" then inst[key] = value end
		end
	end
	if children then
		for _, child in ipairs(children) do child.Parent = inst end
	end
	if props and props.Parent then inst.Parent = props.Parent end
	return inst
end

function Utility.SafeCall(fn, ...)
	if type(fn) ~= "function" then return end
	local ok, err = pcall(fn, ...)
	if not ok then warn("[PISIT HUB] Error: " .. tostring(err)) end
end

function Utility.MakeDraggable(frame, handle)
	handle = handle or frame
	local dragging, dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function Utility.Round(val, dec)
	local mult = 10 ^ (dec or 0)
	return math.floor(val * mult + 0.5) / mult
end

function Utility.Clamp(val, min, max)
	return math.max(min, math.min(max, val))
end

return Utility
end)()

Modules.Theme = (function()
local Theme = {}
local function newSignal()
	local signal = { _listeners = {} }
	function signal:Connect(fn)
		table.insert(signal._listeners, fn)
		return { Disconnect = function()
			for i, l in ipairs(signal._listeners) do if l == fn then table.remove(signal._listeners, i) break end end
		end }
	end
	function signal:Fire(...) for _, fn in ipairs(signal._listeners) do task.spawn(fn, ...) end end
	return signal
end

Theme.Palettes = {
	Red = {
		Accent = Color3.fromHex("#DC1E1E"),
		AccentDim = Color3.fromHex("#8C1414"),
		Background = Color3.fromHex("#0F0F0F"),
		SecondaryBackground = Color3.fromHex("#171717"),
		ElementBackground = Color3.fromHex("#1B1B1B"),
		Border = Color3.fromHex("#DC1E1E"),
		Text = Color3.fromHex("#FFFFFF"),
		SubText = Color3.fromHex("#B5B5B5"),
		Success = Color3.fromHex("#3ED17B"),
		Warning = Color3.fromHex("#E1B33D"),
		Error = Color3.fromHex("#E14848"),
	}
}

Theme.OnChanged = newSignal()
Theme.Current = "Red"
Theme.Active = Theme.Palettes.Red

function Theme.Get(key) return Theme.Active[key] end
return Theme
end)()

Modules.Animation = (function()
local TweenService = game:GetService("TweenService")
local Animation = {}
Animation.Easing = {
	Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Bounce = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

function Animation.Tween(inst, info, props)
	local tw = TweenService:Create(inst, info, props)
	tw:Play()
	return tw
end

function Animation.OpenWindow(frame)
	frame.Visible = true
	local goalSize = frame:GetAttribute("TargetSize") or frame.Size
	frame.Size = UDim2.new(goalSize.X.Scale, goalSize.X.Offset, 0, 0)
	frame.BackgroundTransparency = 1
	Animation.Tween(frame, Animation.Easing.Bounce, { Size = goalSize })
	Animation.Tween(frame, Animation.Easing.Normal, { BackgroundTransparency = 0 })
end

function Animation.CloseWindow(frame, onComplete)
	frame:SetAttribute("TargetSize", frame.Size)
	local tw = Animation.Tween(frame, Animation.Easing.Fast, { Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 0), BackgroundTransparency = 1 })
	tw.Completed:Connect(function()
		frame.Visible = false
		if onComplete then onComplete() end
	end)
end

function Animation.Hover(inst, hoverCol, normCol)
	inst.MouseEnter:Connect(function() Animation.Tween(inst, Animation.Easing.Fast, { BackgroundColor3 = hoverCol }) end)
	inst.MouseLeave:Connect(function() Animation.Tween(inst, Animation.Easing.Fast, { BackgroundColor3 = normCol }) end)
end

function Animation.Click(inst)
	local orig = inst.Size
	Animation.Tween(inst, TweenInfo.new(0.08), { Size = UDim2.new(orig.X.Scale, orig.X.Offset - 4, orig.Y.Scale, orig.Y.Offset - 2) })
	task.delay(0.08, function() Animation.Tween(inst, Animation.Easing.Bounce, { Size = orig }) end)
end

function Animation.Glow(stroke, active)
	Animation.Tween(stroke, Animation.Easing.Normal, { Transparency = active and 0 or 0.6 })
end

return Animation
end)()

Modules.Button = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Button = {}
Button.__index = Button

function Button.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Button)
	self.Instance = Utility.New("TextButton", {
		Name = "Button", Text = "", AutoButtonColor = false,
		BackgroundColor3 = Theme.Get("ElementBackground"), Size = UDim2.new(1, 0, 0, 36),
		Parent = parent
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Instance })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = self.Instance })

	Utility.New("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
		Text = config.Title or "Button", Font = Enum.Font.GothamMedium, TextSize = 13,
		TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance
	})

	Animation.Hover(self.Instance, Theme.Get("ElementBackground"):Lerp(Theme.Get("Accent"), 0.15), Theme.Get("ElementBackground"))
	self.Instance.MouseButton1Click:Connect(function()
		Animation.Click(self.Instance)
		Utility.SafeCall(config.Callback)
	end)
	return self
end
return Button
end)()

Modules.Toggle = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Toggle)
	self.Value = config.Default or false

	self.Instance = Utility.New("Frame", {
		Name = "Toggle", BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 36), Parent = parent
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Instance })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 8), Parent = self.Instance })

	Utility.New("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -38, 1, 0),
		Text = config.Title or "Toggle", Font = Enum.Font.GothamMedium, TextSize = 13,
		TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance
	})

	local box = Utility.New("TextButton", {
		Text = "", AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(24, 24),
		BackgroundColor3 = Theme.Get("Background"), Parent = self.Instance
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = box })
	local stroke = Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.4, Thickness = 1, Parent = box })

	local function render(anim)
		local col = self.Value and Theme.Get("Accent") or Theme.Get("Background")
		if anim then Animation.Tween(box, Animation.Easing.Fast, { BackgroundColor3 = col }) else box.BackgroundColor3 = col end
	end

	box.MouseButton1Click:Connect(function()
		self.Value = not self.Value
		render(true)
		Utility.SafeCall(config.Callback, self.Value)
	end)
	render(false)
	return self
end
return Toggle
end)()

Modules.Slider = (function()
local UserInputService = game:GetService("UserInputService")
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Slider = {}
Slider.__index = Slider

function Slider.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Slider)
	self.Min = config.Min or 0
	self.Max = config.Max or 100
	self.Value = Utility.Clamp(config.Default or self.Min, self.Min, self.Max)
	self.Dragging = false

	self.Instance = Utility.New("Frame", {
		Name = "Slider", BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 46), Parent = parent
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Instance })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 6), Parent = self.Instance })

	local header = Utility.New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Parent = self.Instance })
	Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), Text = config.Title or "Slider", Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = header })
	local valLbl = Utility.New("TextLabel", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(50, 16), Text = tostring(self.Value), Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Get("Accent"), TextXAlignment = Enum.TextXAlignment.Right, Parent = header })

	local bar = Utility.New("Frame", { Position = UDim2.new(0, 0, 0, 26), Size = UDim2.new(1, 0, 0, 5), BackgroundColor3 = Theme.Get("AccentDim"), Parent = self.Instance })
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
	local fill = Utility.New("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Get("Accent"), Parent = bar })
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

	local function update(xPos)
		local rel = Utility.Clamp((xPos - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local raw = self.Min + rel * (self.Max - self.Min)
		local stepped = Utility.Round(raw / (config.Increment or 1)) * (config.Increment or 1)
		self.Value = Utility.Clamp(stepped, self.Min, self.Max)
		valLbl.Text = tostring(self.Value)
		fill.Size = UDim2.new((self.Value - self.Min)/(self.Max - self.Min), 0, 1, 0)
		Utility.SafeCall(config.Callback, self.Value)
	end

bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.Dragging = true
			update(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if self.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then self.Dragging = false end
	end)

	fill.Size = UDim2.new((self.Value - self.Min)/(self.Max - self.Min), 0, 1, 0)
	return self
end
return Slider
end)()

Modules.Dropdown = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Dropdown)
	self.Options = config.Options or {}
	self.Selected = config.Default or self.Options[1] or ""
	self.Open = false

	self.Instance = Utility.New("Frame", {
		Name = "Dropdown", BackgroundColor3 = Theme.Get("ElementBackground"),
		Size = UDim2.new(1, 0, 0, 36), ClipsDescendants = true, Parent = parent
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Instance })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })

	local header = Utility.New("TextButton", { Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = header })
	local lbl = Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Text = (config.Title or "Dropdown") .. ": " .. tostring(self.Selected), Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = header })

	local holder = Utility.New("Frame", { Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, Parent = self.Instance })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 2), Parent = holder })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), Parent = holder })

	local function refresh()
		for _, c in ipairs(holder:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		for _, opt in ipairs(self.Options) do
			local optBtn = Utility.New("TextButton", { Text = opt, AutoButtonColor = false, BackgroundColor3 = Theme.Get("Background"), Size = UDim2.new(1, 0, 0, 26), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Get("SubText"), Parent = holder })
			Utility.New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = optBtn })
			optBtn.MouseButton1Click:Connect(function()
				self.Selected = opt
				lbl.Text = (config.Title or "Dropdown") .. ": " .. tostring(opt)
				self.Open = false
				Animation.Tween(self.Instance, Animation.Easing.Fast, { Size = UDim2.new(1, 0, 0, 36) })
				Utility.SafeCall(config.Callback, opt)
			end)
		end
	end

	header.MouseButton1Click:Connect(function()
		self.Open = not self.Open
		local targetH = 36 + (#self.Options * 28) + 8
		Animation.Tween(self.Instance, Animation.Easing.Smooth, { Size = UDim2.new(1, 0, 0, self.Open and math.min(targetH, 160) or 36) })
	end)

	refresh()
	function self:Refresh(list) self.Options = list; refresh() end
	return self
end
return Dropdown
end)()

Modules.Textbox = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Textbox = {}
Textbox.__index = Textbox
function Textbox.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Textbox)
	self.Value = config.Default or ""
	self.Instance = Utility.New("Frame", { Name = "Textbox", BackgroundColor3 = Theme.Get("ElementBackground"), Size = UDim2.new(1, 0, 0, 50), Parent = parent })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Instance })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.75, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 6), Parent = self.Instance })

	Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Text = config.Title or "Textbox", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance })
	local boxBg = Utility.New("Frame", { Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = Theme.Get("Background"), Parent = self.Instance })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = boxBg })
	local box = Utility.New("TextBox", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = self.Value, PlaceholderText = config.Placeholder or "Type...", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Get("Text"), Parent = boxBg })
	box.FocusLost:Connect(function()
		self.Value = box.Text
		Utility.SafeCall(config.Callback, self.Value)
	end)
	return self
end
return Textbox
end)()

Modules.Paragraph = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Paragraph = {}
Paragraph.__index = Paragraph
function Paragraph.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Paragraph)
	self.Instance = Utility.New("Frame", { Name = "Paragraph", BackgroundColor3 = Theme.Get("ElementBackground"), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Instance })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.8, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = self.Instance })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 4), Parent = self.Instance })

	if config.Title and config.Title ~= "" then
		Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Text = config.Title, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance })
	end
	Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = config.Content or "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Get("SubText"), TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance })
	return self
end
return Paragraph
end)()

Modules.Label = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Label = {}
Label.__index = Label
function Label.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Label)
	self.Instance = Utility.New("TextLabel", { Name = "Label", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Text = config.Text or "Label", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Get("SubText"), TextXAlignment = Enum.TextXAlignment.Left, Parent = parent })
	return self
end
return Label
end)()

Modules.Section = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Section = {}
Section.__index = Section

function Section.new(parent, config)
	config = config or {}
	local self = setmetatable({}, Section)
	self.Instance = Utility.New("Frame", { Name = "Section", BackgroundColor3 = Theme.Get("SecondaryBackground"), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = parent })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = self.Instance })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Transparency = 0.8, Thickness = 1, Parent = self.Instance })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = self.Instance })
	Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Text = config.Title or "Section", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Get("Accent"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Instance })

	self.Content = Utility.New("Frame", { BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 20), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = self.Instance })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 6), Parent = self.Content })
	return self
end

function Section:CreateButton(cfg) return Modules.Button.new(self.Content, cfg) end
function Section:CreateToggle(cfg) return Modules.Toggle.new(self.Content, cfg) end
function Section:CreateSlider(cfg) return Modules.Slider.new(self.Content, cfg) end
function Section:CreateDropdown(cfg) return Modules.Dropdown.new(self.Content, cfg) end
function Section:CreateTextbox(cfg) return Modules.Textbox.new(self.Content, cfg) end
function Section:CreateParagraph(cfg) return Modules.Paragraph.new(self.Content, cfg) end
function Section:CreateLabel(cfg) return Modules.Label.new(self.Content, cfg) end
return Section
end)()

Modules.Tab = (function()
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Tab = {}
Tab.__index = Tab

function Tab.new(window, tabListParent, pageParent, config)
	config = config or {}
	local self = setmetatable({}, Tab)
	self.Window = window

	self.Button = Utility.New("TextButton", { Name = "TabBtn", Text = "", AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), Parent = tabListParent })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = self.Button })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = self.Button })

	self.Indicator = Utility.New("Frame", { Size = UDim2.new(0, 2, 0, 14), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.Get("Accent"), BackgroundTransparency = 1, Parent = self.Button })
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = self.Indicator })

	self.Label = Utility.New("TextLabel", { Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(1, -8, 1, 0), BackgroundTransparency = 1, Text = config.Title or "Tab", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Get("SubText"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Button })

	self.Page = Utility.New("ScrollingFrame", { Name = "Page", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, Visible = false, Parent = pageParent })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8), Parent = self.Page })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 2), Parent = self.Page })

	self.Button.MouseButton1Click:Connect(function() self.Window:SelectTab(self) end)
	return self
end

function Tab:CreateSection(cfg) return Modules.Section.new(self.Page, cfg) end

function Tab:SetActive(active)
	self.Active = active
	self.Page.Visible = active
	Animation.Tween(self.Indicator, Animation.Easing.Normal, { BackgroundTransparency = active and 0 or 1 })
	Animation.Tween(self.Label, Animation.Easing.Normal, { TextColor3 = active and Theme.Get("Text") or Theme.Get("SubText") })
end

return Tab
end)()

Modules.Window = (function()
local Players = game:GetService("Players")
local Theme = Modules.Theme
local Utility = Modules.Utility
local Animation = Modules.Animation
local Window = {}
Window.__index = Window

function Window.new(config)
	config = config or {}
	local self = setmetatable({}, Window)
	self.Tabs = {}
	self.ActiveTab = nil
	self.Minimized = false

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	self.ScreenGui = Utility.New("ScreenGui", { Name = "PISIT_HUB", ResetOnSpawn = false, Parent = playerGui })

	-- ปรับขนาดเริ่มต้นเป็น 400x320 เหมาะกับมือถือ ไม่กว้างแบน
	self.Main = Utility.New("Frame", { Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(400, 320), BackgroundColor3 = Theme.Get("Background"), ClipsDescendants = true, Parent = self.ScreenGui })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.Main })
	Utility.New("UIStroke", { Color = Theme.Get("Border"), Thickness = 1.2, Transparency = 0.2, Parent = self.Main })

	self:_buildTopBar(config.Title or "PISIT HUB")
	self:_buildBody()
	Utility.MakeDraggable(self.Main, self.TopBar)
	Animation.OpenWindow(self.Main)
	return self
end

function Window:_buildTopBar(titleText)
	self.TopBar = Utility.New("Frame", { Name = "TopBar", BackgroundColor3 = Theme.Get("SecondaryBackground"), Size = UDim2.new(1, 0, 0, 40), Parent = self.Main })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 10), Parent = self.TopBar })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 8), Parent = self.TopBar })

	Utility.New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, -65, 1, 0), Text = titleText, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Get("Accent"), TextXAlignment = Enum.TextXAlignment.Left, Parent = self.TopBar })

	-- ปุ่มปิด (X) ชิดขวาสุด
	local closeBtn = Utility.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Theme.Get("ElementBackground"), Text = "x", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Get("Text"), AutoButtonColor = false, Parent = self.TopBar })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = closeBtn })
	closeBtn.MouseButton1Click:Connect(function() self.ScreenGui:Destroy() end)

	-- ปุ่มย่อหน้าต่าง (-) อยู่ทางซ้ายของปุ่มปิดทันที ไม่ทับซ้อน
	local minBtn = Utility.New("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -56, 0.5, 0), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Theme.Get("ElementBackground"), Text = "-", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Get("Text"), AutoButtonColor = false, Parent = self.TopBar })
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 5), Parent = minBtn })
	minBtn.MouseButton1Click:Connect(function()
		self.Minimized = not self.Minimized
		if self.Minimized then
			Animation.CloseWindow(self.Main)
		else
			Animation.OpenWindow(self.Main)
		end
	end)
end

function Window:_buildBody()
	self.Body = Utility.New("Frame", { Name = "Body", Position = UDim2.new(0, 0, 0, 40), Size = UDim2.new(1, 0, 1, -40), BackgroundTransparency = 1, Parent = self.Main })
	self.Sidebar = Utility.New("ScrollingFrame", { Name = "Sidebar", BackgroundColor3 = Theme.Get("SecondaryBackground"), Size = UDim2.new(0, 110, 1, 0), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, Parent = self.Body })
	Utility.New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), Parent = self.Sidebar })
	Utility.New("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 3), Parent = self.Sidebar })

	self.PageContainer = Utility.New("Frame", { Name = "PageContainer", Position = UDim2.new(0, 110, 0, 0), Size = UDim2.new(1, -110, 1, 0), BackgroundTransparency = 1, Parent = self.Body })
end

function Window:CreateTab(config)
	local tab = Modules.Tab.new(self, self.Sidebar, self.PageContainer, config)
	table.insert(self.Tabs, tab)
	if #self.Tabs == 1 then self:SelectTab(tab) end
	return tab
end

function Window:SelectTab(tab)
	if self.ActiveTab then self.ActiveTab:SetActive(false) end
	self.ActiveTab = tab
	tab:SetActive(true)
end

return Window
end)()

local Library = {}
Library._version = "2.0.0"
function Library:CreateWindow(config) return Modules.Window.new(config) end
return Library
