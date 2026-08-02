--[[
	PISIT HUB | Utility.lua
	--------------------------------------------------------------------
	Grab-bag of small, dependency-free helper functions that are reused
	across the entire library: Instance creation shorthand, signals,
	dragging behaviour, rounding, table utilities, and safe-callback
	wrapping.
--]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Utility = {}

-- ====================================================================
-- Instance creation shorthand
-- ====================================================================

--- Creates an Instance and applies a table of properties + optional
-- children in a single call. This keeps every UI file readable and
-- avoids 15-line property blocks scattered everywhere.
-- @param className string
-- @param props table<string, any>
-- @param children table<Instance>?
function Utility.New(className, props, children)
	local inst = Instance.new(className)

	if props then
		for key, value in pairs(props) do
			-- "Parent" is applied last so children/events don't fire
			-- against a half-configured instance.
			if key ~= "Parent" then
				inst[key] = value
			end
		end
	end

	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end

	if props and props.Parent then
		inst.Parent = props.Parent
	end

	return inst
end

-- ====================================================================
-- Signals (lightweight custom event system, no RemoteEvents required)
-- ====================================================================

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _listeners = {} }, Signal)
end

function Signal:Connect(fn)
	table.insert(self._listeners, fn)
	local connection = { Connected = true }
	function connection:Disconnect()
		self.Connected = false
		for i, listener in ipairs(self._listeners) do
			if listener == fn then
				table.remove(self._listeners, i)
				break
			end
		end
	end
	return connection
end

function Signal:Fire(...)
	for _, fn in ipairs(self._listeners) do
		task.spawn(fn, ...)
	end
end

Utility.Signal = Signal

-- ====================================================================
-- Safe callback invocation
-- ====================================================================

--- Wraps a user-provided callback in pcall so a broken callback inside
-- a Button/Toggle/Slider never crashes the whole UI.
function Utility.SafeCall(fn, ...)
	if type(fn) ~= "function" then
		return
	end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[PISIT HUB] Callback error: " .. tostring(err))
	end
end

-- ====================================================================
-- Dragging behaviour (used by Window + Mini Mode)
-- ====================================================================

--- Makes `frame` draggable using `handle` as the drag hotspot.
-- Supports both mouse and touch input for full mobile support.
function Utility.MakeDraggable(frame, handle)
	handle = handle or frame

	local dragging = false
	local dragStart = nil
	local startPos = nil

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ====================================================================
-- Misc helpers
-- ====================================================================

--- Rounds `value` to `decimals` decimal places (default 0).
function Utility.Round(value, decimals)
	local mult = 10 ^ (decimals or 0)
	return math.floor(value * mult + 0.5) / mult
end

--- Clamps `value` between `min` and `max`.
function Utility.Clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

--- Deep-copies a table (used when saving/loading configs).
function Utility.DeepCopy(tbl)
	if type(tbl) ~= "table" then
		return tbl
	end
	local copy = {}
	for key, value in pairs(tbl) do
		copy[key] = Utility.DeepCopy(value)
	end
	return copy
end

--- Generates a short pseudo-random id, used for element/config keys.
function Utility.GenerateId(prefix)
	return (prefix or "id") .. "_" .. tostring(math.random(100000, 999999))
end

--- Returns true if the current device is a touch/mobile device,
-- used by elements to switch to Responsive layout behaviour.
function Utility.IsMobile()
	return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

return Utility
