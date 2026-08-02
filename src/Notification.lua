--[[
	PISIT HUB | Notification.lua
	--------------------------------------------------------------------
	Top-right notification system with the PISIT HUB "P" icon, fade
	in/out animation, vertical stacking, and a queue so notifications
	fired in rapid succession do not overlap.

	Usage:
		Notification.Init(screenGui)
		Notification.Notify({
			Title = "Saved",
			Content = "Your configuration has been saved.",
			Duration = 4,
			Type = "Success", -- Success | Warning | Error | Info
		})
--]]

local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)
local Utility = require(script.Parent.Utility)
local Animation = require(script.Parent.Animation)
local Icons = require(script.Parent.Icons)

local Notification = {}

local container -- holder Frame, top-right, parented into the ScreenGui
local activeCount = 0
local queue = {}
local MAX_VISIBLE = 5

local TYPE_COLOR_KEY = {
	Success = "Success",
	Warning = "Warning",
	Error   = "Error",
	Info    = "Accent",
}

-- ====================================================================
-- Setup
-- ====================================================================

--- Must be called once with the library's root ScreenGui before any
-- Notify() calls.
function Notification.Init(screenGui)
	container = Utility.New("Frame", {
		Name = "PISIT_Notifications",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.new(0, 300, 1, -32),
		Parent = screenGui,
	})

	Utility.New("UIListLayout", {
		Parent = container,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

-- ====================================================================
-- Internal: build + animate a single notification card
-- ====================================================================

local function buildCard(data)
	local colorKey = TYPE_COLOR_KEY[data.Type] or "Accent"
	local accentColor = Theme.Get(colorKey)

	local card = Utility.New("Frame", {
		Name = "NotificationCard",
		BackgroundColor3 = Theme.Get("SecondaryBackground"),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		Parent = container,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = card })
	local stroke = Utility.New("UIStroke", {
		Color = accentColor,
		Thickness = 1,
		Transparency = 0.6,
		Parent = card,
	})
	Utility.New("UIPadding", {
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		Parent = card,
	})

	local layout = Utility.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = card,
	})

	-- Header row: "P" icon + title
	local header = Utility.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		LayoutOrder = 1,
		Parent = card,
	})
	Utility.New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
		Parent = header,
	})
	local badge = Utility.New("Frame", {
		BackgroundColor3 = accentColor,
		Size = UDim2.fromOffset(20, 20),
		Parent = header,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = badge })
	Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "P",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Color3.new(1, 1, 1),
		Parent = badge,
	})
	Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -30, 1, 0),
		Text = data.Title or "Notification",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.Get("Text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	-- Content
	Utility.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = data.Content or "",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Theme.Get("SubText"),
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 2,
		Parent = card,
	})

	return card, stroke
end

-- ====================================================================
-- Public API
-- ====================================================================

--- Queues a notification. If more than MAX_VISIBLE are already shown,
-- this call waits its turn instead of overlapping the screen.
function Notification.Notify(data)
	table.insert(queue, data)
	Notification._processQueue()
end

function Notification._processQueue()
	if not container then
		warn("[PISIT HUB] Notification.Init() must be called before Notify().")
		return
	end
	if activeCount >= MAX_VISIBLE or #queue == 0 then
		return
	end

	local data = table.remove(queue, 1)
	activeCount += 1

	local card, stroke = buildCard(data)

	-- Fade + slide in
	card.Position = UDim2.new(0, 30, 0, 0)
	Animation.Tween(card, Animation.Easing.Smooth, {
		BackgroundTransparency = 0,
		Position = UDim2.new(0, 0, 0, 0),
	})
	Animation.Tween(stroke, Animation.Easing.Smooth, { Transparency = 0.2 })

	local duration = data.Duration or 4
	task.delay(duration, function()
		if not card or not card.Parent then
			return
		end
		local tween = Animation.Tween(card, Animation.Easing.Normal, {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 30, 0, 0),
		})
		Animation.Tween(stroke, Animation.Easing.Normal, { Transparency = 1 })
		tween.Completed:Connect(function()
			card:Destroy()
			activeCount -= 1
			Notification._processQueue()
		end)
	end)

	-- Immediately try to drain more of the queue if room allows.
	if activeCount < MAX_VISIBLE then
		Notification._processQueue()
	end
end

return Notification
