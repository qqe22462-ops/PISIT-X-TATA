--[[
	PISIT HUB | Animation.lua
	--------------------------------------------------------------------
	Centralized TweenService wrapper for every animation used across the
	library: window open/close, hover, click, ripple, glow, fade, slide
	and scale. Keeping all tween definitions here means every element
	file (Button.lua, Toggle.lua, ...) stays focused on logic, not on
	repeating TweenInfo boilerplate.
--]]

local TweenService = game:GetService("TweenService")

local Utility = require(script.Parent.Utility)

local Animation = {}

-- Standard easing presets reused everywhere for visual consistency.
Animation.Easing = {
	Fast   = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Smooth = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Bounce = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

--- Generic tween helper. Returns the Tween object so callers can chain
-- :Play()/:Cancel() or connect to Completed if needed.
function Animation.Tween(instance, info, props)
	local tween = TweenService:Create(instance, info, props)
	tween:Play()
	return tween
end

-- ====================================================================
-- Window open / close
-- ====================================================================

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

	local tween = Animation.Tween(frame, Animation.Easing.Fast, {
		Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 0),
		BackgroundTransparency = 1,
	})

	tween.Completed:Connect(function()
		frame.Visible = false
		if onComplete then
			onComplete()
		end
	end)
end

-- ====================================================================
-- Hover / Click
-- ====================================================================

function Animation.Hover(instance, hoverColor, normalColor)
	instance.MouseEnter:Connect(function()
		Animation.Tween(instance, Animation.Easing.Fast, { BackgroundColor3 = hoverColor })
	end)
	instance.MouseLeave:Connect(function()
		Animation.Tween(instance, Animation.Easing.Fast, { BackgroundColor3 = normalColor })
	end)
end

function Animation.Click(instance)
	local originalSize = instance.Size
	Animation.Tween(instance, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
		Size = UDim2.new(
			originalSize.X.Scale, originalSize.X.Offset - 4,
			originalSize.Y.Scale, originalSize.Y.Offset - 2
		),
	})
	task.delay(0.08, function()
		Animation.Tween(instance, Animation.Easing.Bounce, { Size = originalSize })
	end)
end

-- ====================================================================
-- Ripple Effect
-- ====================================================================

--- Spawns a circular ripple centered on the input position, expanding
-- and fading out, then destroys itself. Common "Material Design"-style
-- click feedback used on Buttons.
function Animation.Ripple(parent, inputPosition, color)
	local relativeX = inputPosition.X - parent.AbsolutePosition.X
	local relativeY = inputPosition.Y - parent.AbsolutePosition.Y

	local ripple = Utility.New("Frame", {
		Name = "Ripple",
		BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(relativeX, relativeY),
		Size = UDim2.fromOffset(0, 0),
		ZIndex = parent.ZIndex + 1,
		Parent = parent,
	})
	Utility.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ripple })

	local maxDim = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.6

	local tween = Animation.Tween(ripple, Animation.Easing.Smooth, {
		Size = UDim2.fromOffset(maxDim, maxDim),
		BackgroundTransparency = 1,
	})

	tween.Completed:Connect(function()
		ripple:Destroy()
	end)
end

-- ====================================================================
-- Glow Effect
-- ====================================================================

--- Pulses a UIStroke's Transparency to create a soft glow, used for
-- focused inputs and the active tab indicator.
function Animation.Glow(stroke, active)
	local goal = active and 0 or 0.6
	Animation.Tween(stroke, Animation.Easing.Normal, { Transparency = goal })
end

-- ====================================================================
-- Fade / Slide / Scale
-- ====================================================================

function Animation.Fade(instance, transparency, duration)
	return Animation.Tween(instance, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quad), {
		BackgroundTransparency = transparency,
	})
end

function Animation.Slide(instance, targetPosition, duration)
	return Animation.Tween(instance, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = targetPosition,
	})
end

function Animation.Scale(instance, targetSize, duration)
	return Animation.Tween(instance, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = targetSize,
	})
end

return Animation
