local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua'))()
local Drawing = loadstring(game:HttpGet('https://raw.githubusercontent.com/6yNuiC9/RobloxDrawingAPI/main/DrawingAPI.lua'))()

--------------------------------------------------
-- Services
--------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

--------------------------------------------------
-- Anti-Cheat Bypass (Simplified)
--------------------------------------------------
local function simpleBypass()
    -- Hide script presence in CoreGui
    pcall(function()
        for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if gui.Name == "Orion" then
                gui.Name = "BrowserService"
            end
        end
    end)
end
simpleBypass()

--------------------------------------------------
-- Hypershot Gun Mods
--------------------------------------------------
for _, v in next, getgc(true) do
    if typeof(v) == 'table' and rawget(v, 'Spread') then
        rawset(v, 'Spread', 0)
        rawset(v, 'BaseSpread', 0)
        rawset(v, 'ReloadTime', 0)
        rawset(v, 'MinCamRecoil', Vector3.new())
        rawset(v, 'MaxCamRecoil', Vector3.new())
        rawset(v, 'MinRotRecoil', Vector3.new())
        rawset(v, 'MaxRotRecoil', Vector3.new())
        rawset(v, 'MinTransRecoil', Vector3.new())
        rawset(v, 'MaxTransRecoil', Vector3.new())
        rawset(v, 'ScopeSpeed', 100)
    end
end

--------------------------------------------------
-- Rainbow Bullet Trail
--------------------------------------------------
local hue = 0
RunService.Heartbeat:Connect(function()
    hue = (hue + 2) % 360
    local col = Color3.fromHSV(hue / 360, 1, 1)
    for _, b in ipairs(WS:GetDescendants()) do
        if b:IsA("Trail") or b:IsA("Beam") then
            b.Color = ColorSequence.new(col)
        end
    end
end)

--------------------------------------------------
-- Aimbot with Prediction and Wall-Bang
--------------------------------------------------
local AI = {
    Enabled = false,
    FOV = 120,
    Smooth = 0.08,
    Prediction = 0.045,
    LockPart = "Head",
    Wallbang = false
}
local AimCircle = Drawing.new("Circle")
AimCircle.Visible = false
AimCircle.Thickness = 2
AimCircle.Radius = AI.FOV
AimCircle.Color = Color3.fromRGB(0, 255, 255)
AimCircle.Transparency = 0.5

local function isVisible(part)
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin).Unit
    local ray = Ray.new(origin, dir * 500)
    local hit, _ = WS:FindPartOnRay(ray, LP.Character)
    return hit and hit:IsDescendantOf(part.Parent)
end

local function getClosest()
    local mousePos = UIS:GetMouseLocation()
    local closest, distMin = nil, AI.FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local char = p.Character
        if not char or not char:FindFirstChild(AI.LockPart) then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = char[AI.LockPart]
        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist > distMin then continue end
        if not AI.Wallbang and not isVisible(part) then continue end
        distMin = dist
        closest = p
    end
    return closest
end

local function predictTarget(target)
    local part = target.Character[AI.LockPart]
    local velocity = part.Velocity
    local distance = (part.Position - Camera.CFrame.Position).Magnitude
    local bulletTime = distance / 4500
    local drop = 0.5 * 196.2 * bulletTime ^ 2
    return part.Position + velocity * AI.Prediction * bulletTime + Vector3.new(0, -drop, 0)
end

local function aim()
    local target = getClosest()
    if not target then return end
    local targetPos = predictTarget(target)
    local camPos = Camera.CFrame.Position
    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(camPos, targetPos), AI.Smooth)
end

local function enableAimbot()
    if not AI.Enabled then return end
    AimCircle.Visible = true
    RunService:BindToRenderStep("VortX_Aim", 200, function()
        AimCircle.Position = UIS:GetMouseLocation()
        AimCircle.Radius = AI.FOV
        aim()
    end)
end

local function disableAimbot()
    AI.Enabled = false
    AimCircle.Visible = false
    RunService:UnbindFromRenderStep("VortX_Aim")
end

--------------------------------------------------
-- Full ESP + Chams
--------------------------------------------------
local ESP = {
    Enabled = false,
    Color = Color3.fromRGB(255, 0, 0),
    Thickness = 2,
    Transparency = 0.75
}
local Drawings = {}

local function createESP(plr)
    if plr == LP then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = ESP.Thickness
    box.Color = ESP.Color
    box.Transparency = ESP.Transparency

    local name = Drawing.new("Text")
    name.Visible = false
    name.Text = plr.Name
    name.Size = 16
    name.Color = ESP.Color
    name.Center = true
    name.Outline = true

    table.insert(Drawings, {box, name, plr})

    RunService.Heartbeat:Connect(function()
        if not ESP.Enabled or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
            box.Visible = false
            name.Visible = false
            return
        end
        local root = plr.Character.HumanoidRootPart
        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if onScreen then
            box.Size = Vector2.new(60, 120)
            box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
            box.Visible = true

            name.Position = Vector2.new(pos.X, pos.Y - 40)
            name.Visible = true
        else
            box.Visible = false
            name.Visible = false
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    createESP(p)
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(plr)
    for i, d in ipairs(Drawings) do
        if d[3] == plr then
            d[1]:Remove()
            d[2]:Remove()
            table.remove(Drawings, i)
            break
        end
    end
end)

--------------------------------------------------
-- Auto-collect
--------------------------------------------------
local function autoCollect(name)
    return function()
        for _, part in ipairs(WS:GetDescendants()) do
            if part:IsA("BasePart") and part.Name:lower():find(name:lower()) then
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    part.CFrame = hrp.CFrame
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(autoCollect("coin"))
RunService.Heartbeat:Connect(autoCollect("heal"))
RunService.Heartbeat:Connect(autoCollect("ammo"))

--------------------------------------------------
-- UI – Seisen Hub Enhanced
--------------------------------------------------
local Window = OrionLib:MakeWindow({
    Name = "Seisen Hub Enhanced",
    HidePremium = true,
    IntroEnabled = true,
    IntroText = "Seisen Hub Enhanced",
    IntroIcon = "rbxassetid://4483345875"
})

local Combat = Window:MakeTab({Name = "Combat"})
local ESP_Tab = Window:MakeTab({Name = "ESP"})
local Utility = Window:MakeTab({Name = "Utility"})

Combat:AddToggle({
    Name = "Aimbot (Head-Wallbang)",
    Default = false,
    Callback = function(v)
        AI.Enabled = v
        if v then
            enableAimbot()
        else
            disableAimbot()
        end
    end
})

Combat:AddSlider({
    Name = "Aimbot FOV",
    Min = 20,
    Max = 300,
    Default = 120,
    Callback = function(v) AI.FOV = v end
})

Combat:AddToggle({
    Name = "Wallbang",
    Default = false,
    Callback = function(v) AI.Wallbang = v end
})

ESP_Tab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(v) ESP.Enabled = v end
})

Utility:AddToggle({
    Name = "Auto Collect Items",
    Default = true,
    Callback = function() end
})

Utility:AddToggle("AntiCheatBypass", {
    Name = "Simple Anti-Cheat Bypass",
    Default = false,
    Callback = function(v)
        if v then
            simpleBypass()
            print("Simple Anti-Cheat Bypass Activated")
        else
            print("Simple Anti-Cheat Bypass Deactivated")
        end
    end
})

OrionLib:Init()
print("Seisen Hub Enhanced loaded successfully!")
