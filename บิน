--[[
    PISIT x TATA - Fly Script (Red & White Theme)
    Features:
    - Unique Anti-Duplicate GUI check (No conflict with Fling GUI)
    - Minimize (-) / Maximize (Logo & +) support
    - Close (X) button
    - Fly functionality with live-updating speed controls (+, -, and typing)
]]

-- Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- Show notification helper
local function Message(Title, Text, Time)
    StarterGui:SetCore("SendNotification", {
        Title = Title,
        Text = Text,
        Duration = Time or 5
    })
end

-- ป้องกันรันซ้ำและไม่ให้ซ้อนทับกับ UI ตัวอื่น (ใช้ชื่อเฉพาะของ Fly)
if game:GetService("CoreGui"):FindFirstChild("PisitTataFlyGUI") then
    Message("แจ้งเตือน", "สคริปต์บินรันอยู่แล้วเพื่อน!", 3)
    return
end

-- GUI Setup
local main = Instance.new("ScreenGui")
main.Name = "PisitTataFlyGUI"
main.Parent = game:GetService("CoreGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

-- Main Frame (เน้นโทนสีแดงจัดเต็มตามบรีฟ)
local Frame = Instance.new("Frame")
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
Frame.BorderColor3 = Color3.fromRGB(220, 20, 20)
Frame.Position = UDim2.new(0.1, 0, 0.38, 0)
Frame.Size = UDim2.new(0, 210, 0, 100)
Frame.Active = true
Frame.Draggable = true

-- Main Frame Gradient & Styling (แดงเด่นๆ นุ่มๆ)
local MainUiGradient = Instance.new("UIGradient")
MainUiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 20, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 0, 0))
})
MainUiGradient.Rotation = 45
MainUiGradient.Parent = Frame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Frame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 80, 80)
MainStroke.Thickness = 1.5
MainStroke.Parent = Frame

-- Title (PISIT x TATA FLY)
local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0, 10, 0, 5)
TextLabel.Size = UDim2.new(0, 115, 0, 28)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.Text = "PISIT x TATA"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 13
TextLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Content Holder (สำหรับซ่อนเวลาพับจอ)
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Parent = Frame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 0, 0, 35)
ContentContainer.Size = UDim2.new(1, 0, 1, -35)

-- UP Button
local up = Instance.new("TextButton")
up.Name = "up"
up.Parent = ContentContainer
up.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
up.TextColor3 = Color3.fromRGB(255, 255, 255)
up.Position = UDim2.new(0, 10, 0, 5)
up.Size = UDim2.new(0, 42, 0, 26)
up.Font = Enum.Font.GothamBold
up.Text = "UP"
up.TextSize = 12

local UpCorner = Instance.new("UICorner")
UpCorner.CornerRadius = UDim.new(0, 6)
UpCorner.Parent = up

-- DOWN Button
local down = Instance.new("TextButton")
down.Name = "down"
down.Parent = ContentContainer
down.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
down.Position = UDim2.new(0, 10, 0, 35)
down.Size = UDim2.new(0, 42, 0, 26)
down.Font = Enum.Font.GothamBold
down.Text = "DOWN"
down.TextColor3 = Color3.fromRGB(255, 255, 255)
down.TextSize = 11

local DownCorner = Instance.new("UICorner")
DownCorner.CornerRadius = UDim.new(0, 6)
DownCorner.Parent = down

-- PLUS Button (+)
local plus = Instance.new("TextButton")
plus.Name = "plus"
plus.Parent = ContentContainer
plus.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
plus.Position = UDim2.new(0, 58, 0, 5)
plus.Size = UDim2.new(0, 42, 0, 26)
plus.Font = Enum.Font.GothamBold
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(255, 255, 255)
plus.TextSize = 14

local PlusCorner = Instance.new("UICorner")
PlusCorner.CornerRadius = UDim.new(0, 6)
PlusCorner.Parent = plus

-- MINUS Button (-)
local mine = Instance.new("TextButton")
mine.Name = "mine"
mine.Parent = ContentContainer
mine.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
mine.Position = UDim2.new(0, 58, 0, 35)
mine.Size = UDim2.new(0, 42, 0, 26)
mine.Font = Enum.Font.GothamBold
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(255, 255, 255)
mine.TextSize = 14

local MineCorner = Instance.new("UICorner")
MineCorner.CornerRadius = UDim.new(0, 6)
MineCorner.Parent = mine

-- SPEED TextBox
local speed = Instance.new("TextBox")
speed.Name = "speed"
speed.Parent = ContentContainer
speed.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
speed.Position = UDim2.new(0, 106, 0, 35)
speed.Size = UDim2.new(0, 42, 0, 26)
speed.Font = Enum.Font.GothamBold
speed.Text = "1"
speed.TextColor3 = Color3.fromRGB(255, 255, 255)
speed.TextSize = 13
speed.ClearTextOnFocus = false

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = speed

-- ONOF (Fly Toggle Button)
local onof = Instance.new("TextButton")
onof.Name = "onof"
onof.Parent = ContentContainer
onof.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
onof.Position = UDim2.new(0, 106, 0, 5)
onof.Size = UDim2.new(0, 92, 0, 26)
onof.Font = Enum.Font.GothamBold
onof.Text = "FLY : OFF"
onof.TextColor3 = Color3.fromRGB(255, 255, 255)
onof.TextSize = 12

local OnOfCorner = Instance.new("UICorner")
OnOfCorner.CornerRadius = UDim.new(0, 6)
OnOfCorner.Parent = onof

-- Top Right Buttons Holder (-, X, Logo)
local TopButtonsHolder = Instance.new("Frame")
TopButtonsHolder.Parent = Frame
TopButtonsHolder.BackgroundTransparency = 1
TopButtonsHolder.Position = UDim2.new(1, -85, 0, 5)
TopButtonsHolder.Size = UDim2.new(0, 80, 0, 25)

-- Close Button (X)
local closebutton = Instance.new("TextButton")
closebutton.Name = "Close"
closebutton.Parent = TopButtonsHolder
closebutton.BackgroundColor3 = Color3.fromRGB(255, 25, 0)
closebutton.BackgroundTransparency = 1
closebutton.Font = Enum.Font.GothamBold
closebutton.Size = UDim2.new(0, 20, 0, 20)
closebutton.Position = UDim2.new(1, -20, 0, 2)
closebutton.Text = "X"
closebutton.TextColor3 = Color3.fromRGB(255, 120, 120)
closebutton.TextSize = 14

-- Minimize Button (-)
local mini = Instance.new("TextButton")
mini.Name = "minimize"
mini.Parent = TopButtonsHolder
mini.BackgroundTransparency = 1
mini.Font = Enum.Font.GothamBold
mini.Size = UDim2.new(0, 20, 0, 20)
mini.Position = UDim2.new(1, -44, 0, 2)
mini.Text = "-"
mini.TextColor3 = Color3.fromRGB(255, 255, 255)
mini.TextSize = 18

-- Logo Toggle Button
local logoBtn = Instance.new("ImageButton")
logoBtn.Name = "LogoButton"
logoBtn.Parent = TopButtonsHolder
logoBtn.BackgroundTransparency = 1
logoBtn.Position = UDim2.new(1, -68, 0, 2)
logoBtn.Size = UDim2.new(0, 20, 0, 20)
logoBtn.Image = "https://i.postimg.cc/hP39YjVY/logo.png"

-- Logic & Variables
speeds = 1
local speaker = game:GetService("Players").LocalPlayer
local nowe = false

-- Notification on load
Message("PISIT x TATA", "FLY Loaded!", 3)

-- Minimize Function
local isMinimized = false
local function ToggleMinimize()
	isMinimized = not isMinimized
	if isMinimized then
		Frame.Size = UDim2.new(0, 210, 0, 35)
		ContentContainer.Visible = false
		mini.Text = "+"
	else
		Frame.Size = UDim2.new(0, 210, 0, 100)
		ContentContainer.Visible = true
		mini.Text = "-"
	end
end

mini.MouseButton1Click:Connect(ToggleMinimize)
logoBtn.MouseButton1Click:Connect(ToggleMinimize)

closebutton.MouseButton1Click:Connect(function()
	main:Destroy()
end)

-- Function สำหรับเพิ่มเลเยอร์ความเร็วขณะบินแบบเรียลไทม์
local function applySpeedLayers(targetSpeed)
	for i = 1, targetSpeed do
		spawn(function()
			local hb = game:GetService("RunService").Heartbeat	
			tpwalking = true
			local chr = game.Players.LocalPlayer.Character
			local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
			local currentTag = targetSpeed
			while nowe and speeds >= currentTag and hb:Wait() and chr and hum and hum.Parent do
				if hum.MoveDirection.Magnitude > 0 then
					chr:TranslateBy(hum.MoveDirection)
				end
			end
		end)
	end
end

-- Fly Toggle Script
onof.MouseButton1Down:connect(function()
	if nowe == true then
		nowe = false
		onof.Text = "FLY : OFF"
		onof.BackgroundColor3 = Color3.fromRGB(200, 20, 20)

		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,true)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,true)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	else 
		nowe = true
		onof.Text = "FLY : ON"
		onof.BackgroundColor3 = Color3.fromRGB(40, 180, 40)

		applySpeedLayers(speeds)
		
		local Char = game.Players.LocalPlayer.Character
		if Char:FindFirstChild("Animate") then
			Char.Animate.Disabled = true
		end
		local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

		for i,v in next, Hum:GetPlayingAnimationTracks() do
			v:AdjustSpeed(0)
		end
		
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics,false)
		speaker.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming,false)
		speaker.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	end

	if game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
		local plr = game.Players.LocalPlayer
		local torso = plr.Character:FindFirstChild("Torso")
		if not torso then return end
		local bg = Instance.new("BodyGyro", torso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = torso.CFrame
		local bv = Instance.new("BodyVelocity", torso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		if nowe == true then
			plr.Character.Humanoid.PlatformStand = true
		end
		
		local ctrl = {f = 0, b = 0, l = 0, r = 0}
		local lastctrl = {f = 0, b = 0, l = 0, r = 0}
		local maxspeed = 50
		local flyspeed = 0

		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
			game:GetService("RunService").RenderStepped:Wait()
			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				flyspeed = flyspeed + .5 + (flyspeed / maxspeed)
				if flyspeed > maxspeed then flyspeed = maxspeed end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and flyspeed ~= 0 then
				flyspeed = flyspeed - 1
				if flyspeed < 0 then flyspeed = 0 end
			end
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame
		end
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		if plr.Character:FindFirstChild("Animate") then
			plr.Character.Animate.Disabled = false
		end
		tpwalking = false
	else
		local plr = game.Players.LocalPlayer
		local UpperTorso = plr.Character:FindFirstChild("UpperTorso")
		if not UpperTorso then return end
		local bg = Instance.new("BodyGyro", UpperTorso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = UpperTorso.CFrame
		local bv = Instance.new("BodyVelocity", UpperTorso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		if nowe == true then
			plr.Character.Humanoid.PlatformStand = true
		end
		
		while nowe == true or game:GetService("Players").LocalPlayer.Character.Humanoid.Health == 0 do
			task.wait()
		end
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
		if plr.Character:FindFirstChild("Animate") then
			plr.Character.Animate.Disabled = false
		end
		tpwalking = false
	end
end)

-- UP / DOWN Buttons Movement
local tis
up.MouseButton1Down:connect(function()
	tis = up.MouseEnter:connect(function()
		while tis do
			task.wait()
			local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = hrp.CFrame * CFrame.new(0, 1, 0)
			end
		end
	end)
end)

up.MouseLeave:connect(function()
	if tis then
		tis:Disconnect()
		tis = nil
	end
end)

local dis
down.MouseButton1Down:connect(function()
	dis = down.MouseEnter:connect(function()
		while dis do
			task.wait()
			local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = hrp.CFrame * CFrame.new(0, -1, 0)
			end
		end
	end)
end)

down.MouseLeave:connect(function()
	if dis then
		dis:Disconnect()
		dis = nil
	end
end)

-- Speed Controls (+)
plus.MouseButton1Down:connect(function()
	speeds = speeds + 1
	speed.Text = tostring(speeds)
	
	if nowe then
		applySpeedLayers(speeds)
	end
end)

-- Speed Controls (-)
mine.MouseButton1Down:connect(function()
	if speeds <= 1 then
		speeds = 1
		speed.Text = '1'
	else
		speeds = speeds - 1
		speed.Text = tostring(speeds)
	end
end)

-- รองรับการพิมพ์ตัวเลขลงช่อง TextBox
speed.FocusLost:Connect(function(enterPressed)
	local num = tonumber(speed.Text)
	if num and num > 0 then
		speeds = math.floor(num)
		speed.Text = tostring(speeds)
		if nowe then
			applySpeedLayers(speeds)
		end
	else
		speed.Text = tostring(speeds)
	end
end)
