-- ====================================================================
-- PISIT HUB | Ultimate Mega Project + Multi-External Script Loaders
-- ====================================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/PISIT-X-TATA/refs/heads/main/PISIT_HUB.bundle.lua"))()

-- สร้างหน้าต่างหลักของโปรเจกต์
local Window = Library:CreateWindow({
    Title = "PISIT HUB | Ultimate Mega Project"
})

-- สร้าง Tabs ทั้งหมด
local HomeTab = Window:CreateTab({ Title = "Home" })
local PlayerTab = Window:CreateTab({ Title = "Player" })
local VisualsTab = Window:CreateTab({ Title = "Visuals" })
local CheatTab = Window:CreateTab({ Title = "ช่วยเล่น" }) -- Tab ช่วยเล่น
local WorldTab = Window:CreateTab({ Title = "World & Misc" })

-- สร้าง Sections
local HomeSection = HomeTab:CreateSection({ Title = "Player Information & Status" })
local StatsSection = HomeTab:CreateSection({ Title = "Quick Stats" })

local MoveSection = PlayerTab:CreateSection({ Title = "Movement & Speed" })
local ActionSection = PlayerTab:CreateSection({ Title = "Character Utilities" })

local ESPSection = VisualsTab:CreateSection({ Title = "ESP & Wallhack Settings" })
local ColorSection = VisualsTab:CreateSection({ Title = "Color Customization" })

-- Section สำหรับ Tab ช่วยเล่น (บรรจุสคริปต์เสริมทั้ง 2 ตัว)
local CheatSection = CheatTab:CreateSection({ Title = "Script Executor Helper" })

local PerfSection = WorldTab:CreateSection({ Title = "Performance & HD Boost" })
local WorldSection = WorldTab:CreateSection({ Title = "World & Lighting" })

-- ตัวแปรระบบ Roblox พื้นฐาน
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ====================================================================
-- 1. HOME TAB: ข้อมูลผู้เล่นและสถิติ
-- ====================================================================
HomeSection:CreateButton({
    Title = "ชื่อผู้ใช้: " .. LocalPlayer.Name,
    Callback = function() end
})

HomeSection:CreateButton({
    Title = "User ID: " .. tostring(LocalPlayer.UserId),
    Callback = function() end
})

HomeSection:CreateButton({
    Title = "เกมที่เล่น (Place ID): " .. tostring(game.PlaceId),
    Callback = function() end
})

StatsSection:CreateButton({
    Title = "สถานะระบบ: พร้อมใช้งาน (Ready)",
    Callback = function() end
})

-- ====================================================================
-- 2. PLAYER TAB: ระบบเคลื่อนไหวและความเร็ว (WalkSpeed, JumpPower, Noclip)
-- ====================================================================
local speedEnabled = false
local customWalkSpeed = 16

MoveSection:CreateToggle({
    Title = "เปิด/ปิด ระบบความเร็ววิ่ง",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if not speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

MoveSection:CreateSlider({
    Title = "ปรับความเร็ววิ่ง (1-1000)",
    Min = 1,
    Max = 1000,
    Increment = 1,
    Default = 16,
    Callback = function(value)
        customWalkSpeed = value
    end
})

RunService.Heartbeat:Connect(function()
    if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = customWalkSpeed
    end
end)

-- ระบบกระโดดสูง
local jumpEnabled = false
local customJumpPower = 50

MoveSection:CreateToggle({
    Title = "เปิด/ปิด พลังกระโดดสูง",
    Default = false,
    Callback = function(state)
        jumpEnabled = state
        if not jumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
    end
})

MoveSection:CreateSlider({
    Title = "ปรับความสูงการกระโดด (50-500)",
    Min = 50,
    Max = 500,
    Increment = 5,
    Default = 50,
    Callback = function(value)
        customJumpPower = value
    end
})

RunService.Heartbeat:Connect(function()
    if jumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = customJumpPower
    end
end)

-- ระบบ Noclip (เดินทะลุกำแพง)
local noclipConnection = nil
ActionSection:CreateToggle({
    Title = "เดินทะลุกำแพง (Noclip)",
    Default = false,
    Callback = function(state)
        if state then
            noclipConnection = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
        end
    end
})

-- ระบบ Infinite Jump
local infJumpConn = nil
ActionSection:CreateToggle({
    Title = "กระโดดกลางอากาศไม่จำกัด (Inf Jump)",
    Default = false,
    Callback = function(state)
        if state then
            infJumpConn = UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
        end
    end
})

-- ====================================================================
-- 3. VISUALS TAB: ESP 2D Box และระบบเลือกสีได้
-- ====================================================================
local espEnabled = false
local espColor = Color3.fromRGB(255, 255, 255)
local espDrawings = {}

local function removeESP(player)
    if espDrawings[player] then
        for _, d in pairs(espDrawings[player]) do d:Remove() end
        espDrawings[player] = nil
    end
end

local function setupESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = espColor
    box.Thickness = 1.5
    box.Filled = false
    espDrawings[player] = { Box = box }

    player.CharacterRemoving:Connect(function() removeESP(player) end)
end

for _, p in ipairs(Players:GetPlayers()) do setupESP(p) end
Players.PlayerAdded:Connect(setupESP)
Players.PlayerRemoving:Connect(removeESP)

ESPSection:CreateToggle({
    Title = "เปิด/ปิด ESP 2D Box ทั่วแมพ",
    Default = false,
    Callback = function(state)
        espEnabled = state
        if not espEnabled then
            for p, _ in pairs(espDrawings) do removeESP(p) end
        end
    end
})

ColorSection:CreateDropdown({
    Title = "เลือกสี ESP",
    Options = {"สีขาว", "สีแดง", "สีเขียว", "สีฟ้า", "สีเหลือง", "สีชมพู"},
    Default = "สีขาว",
    Callback = function(selected)
        if selected == "สีขาว" then espColor = Color3.fromRGB(255, 255, 255)
        elseif selected == "สีแดง" then espColor = Color3.fromRGB(255, 0, 0)
        elseif selected == "สีเขียว" then espColor = Color3.fromRGB(0, 255, 0)
        elseif selected == "สีฟ้า" then espColor = Color3.fromRGB(0, 150, 255)
        elseif selected == "สีเหลือง" then espColor = Color3.fromRGB(255, 255, 0)
        elseif selected == "สีชมพู" then espColor = Color3.fromRGB(255, 105, 180) end

        for _, drawings in pairs(espDrawings) do
            if drawings and drawings.Box then drawings.Box.Color = espColor end
        end
    end
})

RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local hrp = player.Character.HumanoidRootPart
            local hum = player.Character.Humanoid
            if hum.Health > 0 then
                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    if not espDrawings[player] then setupESP(player) end
                    local drawings = espDrawings[player]
                    if drawings and drawings.Box then
                        local head = player.Character:FindFirstChild("Head")
                        local top = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or vector
                        local leg = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        local h = math.abs(top.Y - leg.Y)
                        local w = h / 2
                        drawings.Box.Size = Vector2.new(w, h)
                        drawings.Box.Position = Vector2.new(vector.X - w/2, top.Y)
                        drawings.Box.Color = espColor
                        drawings.Box.Visible = true
                    end
                else
                    if espDrawings[player] and espDrawings[player].Box then
                        espDrawings[player].Box.Visible = false
                    end
                end
            else
                if espDrawings[player] and espDrawings[player].Box then
                    espDrawings[player].Box.Visible = false
                end
            end
        end
    end
end)

-- ====================================================================
-- 4. CHEAT TAB: ปุ่มกดรันสคริปต์เสริม (ผลักกระเด็น & บิน)
-- ====================================================================
CheatSection:CreateButton({
    Title = "สคริปผักกระเด็น",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/PISIT-X-TATA/refs/heads/main/%E0%B8%9C%E0%B8%A5%E0%B8%B1%E0%B8%81%E0%B8%81%E0%B8%A3%E0%B8%B0%E0%B9%80%E0%B8%94%E0%B9%87%E0%B8%99"))()
        end)
    end
})

CheatSection:CreateButton({
    Title = "สคริปบิน",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/PISIT-X-TATA/refs/heads/main/%E0%B8%9A%E0%B8%B4%E0%B8%99"))()
		end)
    end
})

-- ====================================================================
-- 5. WORLD & PERFORMANCE TAB: บายพาสภาพชัด คมชัด และลื่นไหล 120 FPS
-- ====================================================================
PerfSection:CreateToggle({
    Title = "บายพาส ภาพชัด คมชัด & ลื่นไหล 120 FPS",
    Default = false,
    Callback = function(state)
        if state then
            Lighting.GlobalShadows = true
            Lighting.Brightness = 1.5
            Lighting.FogEnd = 9e9
            
            if pcall(function() setfpscap(120) end) then
                setfpscap(120)
            end
            
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
        else
            Lighting.GlobalShadows = true
            if pcall(function() setfpscap(60) end) then
                setfpscap(60)
            end
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end
})

WorldSection:CreateToggle({
    Title = "เปิดไฟสว่างคมชัดทั่วแมพ (Fullbright HD)",
    Default = false,
    Callback = function(state)
        if state then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 0
            Lighting.GlobalShadows = true
        end
    end
})
