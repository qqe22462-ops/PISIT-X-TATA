-- ====================================================================
-- PISIT x TATA | Player & Cheat Tabs Only (All Fixed & Clean URLs)
-- ====================================================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/PISIT-X-TATA/refs/heads/main/PISIT_HUB.bundle.lua"))()

-- สร้างหน้าต่างหลักของโปรเจกต์
local Window = Library:CreateWindow({
    Title = "PISIT x TATA | Player & Cheat"
})

-- สร้าง Tabs (เอาแค่ Player กับ ช่วยเล่น)
local PlayerTab = Window:CreateTab({ Title = "Player" })
local CheatTab = Window:CreateTab({ Title = "ช่วยเล่น" })

-- สร้าง Sections
local MoveSection = PlayerTab:CreateSection({ Title = "Movement & Speed" })
local ActionSection = PlayerTab:CreateSection({ Title = "Character Utilities" })

local CheatSection = CheatTab:CreateSection({ Title = "Script Executor Helper" })

-- ตัวแปรระบบ Roblox พื้นฐาน
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ====================================================================
-- PLAYER TAB: ระบบเคลื่อนไหวและความเร็ว (WalkSpeed, JumpPower, Noclip)
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
-- CHEAT TAB: ปุ่มกดรันสคริปต์เสริม
-- ====================================================================
CheatSection:CreateButton({
    Title = "สคริปผลักคน",
    Callback = function()
        task.spawn(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/PISIT-X-TATA/refs/heads/main/PISIT%20X%20TATA"))()
        end)
    end
})

CheatSection:CreateButton({
    Title = "สคริปบิน",
    Callback = function()
        task.spawn(function()
            -- *คำแนะนำ: ให้ไปเปลี่ยนชื่อไฟล์บินบน GitHub ให้เป็น fly.lua แล้วแก้ลิงก์ข้างล่างนี้ให้ตรงกันครับ*
            loadstring(game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/PISIT-X-TATA/refs/heads/main/fly.lua"))()
        end)
    end
})

CheatSection:CreateButton({
    Title = "สคริปต์หยุดเวลา",
    Callback = function()
        task.spawn(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/qqe22462-ops/PISIT-X-TATA/refs/heads/main/Stop"))()
        end)
    end
})
