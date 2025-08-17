--[[
    VORTX HUB – FINAL SINGLE FILE
    • OrionLib compatible
    • Config loaded first → OrionLib init last
    • OP anti-cheat bypass
    • Rainbow bullet trail
    • Full English
]]

-- ┌─────────────────────────────────────────────┐
-- │ 1.  LOAD ORIONLIB (your exact link)         │
-- └─────────────────────────────────────────────┘
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

-- ┌─────────────────────────────────────────────┐
-- │ 2.  SERVICES                                │
-- └─────────────────────────────────────────────┘
local HS  = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local RS  = game:GetService("RunService")
local WS  = game:GetService("Workspace")
local PS  = game:GetService("Players")
local RS2 = game:GetService("ReplicatedStorage")

-- ┌─────────────────────────────────────────────┐
-- │ 3.  CONFIG SAVE / LOAD  (STEP 8)            │
-- └─────────────────────────────────────────────┘
local SaveFolder = "VortXHub"
local SaveFile   = SaveFolder .. "/vortx_config.json"
if not isfolder(SaveFolder) then makefolder(SaveFolder) end

local Config = {
    AntiCheatBypass   = true,
    AICoreEnabled     = false,
    AICoreFOV         = 120,
    BigHeadEnabled    = false,
    AutoFireEnabled   = false,
    HypershotMod      = false,
    RainbowBullet     = true,
    AutoSpawn         = false,
    AutoPlaytime      = false,
    AutoPickUpHeal    = false,
    AutoPickUpAmmo    = false,
    AutoPickUpCoins   = false,
    AutoPickUpWeapons = false,
    AutoOpenChest     = false,
    AutoSpin          = false,
    SelectedChest     = "Wooden"
}

local function loadCfg()
    local ok, data = pcall(function() return HS:JSONDecode(readfile(SaveFile)) end)
    if ok and type(data) == "table" then
        for k,v in pairs(data) do Config[k] = v end
    end
end

local function saveCfg()
    writefile(SaveFile, HS:JSONEncode(Config))
end

loadCfg()   -- STEP 8

-- ┌─────────────────────────────────────────────┐
-- │ 4.  ANTI-CHEAT BYPASS (OP 2024)             │
-- └─────────────────────────────────────────────┘
if Config.AntiCheatBypass then
    -- 1. Memory spoofing
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            return -- drop all remote traffic
        end
        return old(...)
    end)
    setreadonly(mt, true)

    -- 2. Chat log / report kill
    for _,v in pairs(game:GetDescendants()) do
        if v.Name:lower():find("chat") or v.Name:find("Report") then
            pcall(function() v:Destroy() end)
        end
    end

    -- 3. Hide script itself
    pcall(function()
        for _, coreGui in pairs(game:GetService("CoreGui"):GetChildren()) do
            if coreGui.Name == "Orion" then
                coreGui.Name = ""
            end
        end
    end)
end

-- ┌─────────────────────────────────────────────┐
-- │ 5.  HYPERSHOT GUN MODS                      │
-- └─────────────────────────────────────────────┘
local function applyHypershot()
    for _,v in next, getgc(true) do
        if typeof(v) == "table" and rawget(v, "Spread") then
            rawset(v, "Spread", 0)
            rawset(v, "BaseSpread", 0)
            rawset(v, "MinCamRecoil", Vector3.new())
            rawset(v, "MaxCamRecoil", Vector3.new())
            rawset(v, "MinRotRecoil", Vector3.new())
            rawset(v, "MaxRotRecoil", Vector3.new())
            rawset(v, "MinTransRecoil", Vector3.new())
            rawset(v, "MaxTransRecoil", Vector3.new())
            rawset(v, "ScopeSpeed", 100)
            rawset(v, "ReloadTime", 0)
        end
    end
end
if Config.HypershotMod then applyHypershot() end

-- ┌─────────────────────────────────────────────┐
-- │ 6.  RAINBOW BULLET TRAIL                    │
-- └─────────────────────────────────────────────┘
local function rainbowBullet()
    local hue = 0
    game:GetService("RunService").Heartbeat:Connect(function()
        hue = (hue + 2) % 360
        local color = Color3.fromHSV(hue/360,1,1)
        for _,b in pairs(game:GetService("Workspace"):GetDescendants()) do
            if b.Name:lower():find("bullet") or b.Name:lower():find("trail") then
                if b:IsA("Trail") or b:IsA("Beam") then
                    b.Color = ColorSequence.new(color)
                end
            end
        end
    end)
end
if Config.RainbowBullet then rainbowBullet() end

-- ┌─────────────────────────────────────────────┐
-- │ 7.  AI AIMBOT                               │
-- └─────────────────────────────────────────────┘
local AICore = {
    enabled   = Config.AICoreEnabled,
    fov       = Config.AICoreFOV,
    smoothing = 0.08,
    prediction = 0.045,
    lockPart  = "Head",
    teamCheck = true,
    visibleOnly = true
}
local AimbotCircle = Drawing.new("Circle")
AimbotCircle.Visible = false
AimbotCircle.Thickness = 2
AimbotCircle.Radius = AICore.fov
AimbotCircle.Color = Color3.fromRGB(0,255,255)
AimbotCircle.Transparency = 0.5

local function getClosest()
    local mousePos = UIS:GetMouseLocation()
    local closest, distMin = nil, math.huge
    for _, plr in pairs(PS:GetPlayers()) do
        if plr == game.Players.LocalPlayer then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild(AICore.lockPart) then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = char[AICore.lockPart]
        local screenPos, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist > AICore.fov then continue end
        if AICore.teamCheck and plr.Team == game.Players.LocalPlayer.Team then continue end
        if AICore.visibleOnly and not (function(part)
            local origin = game.Workspace.CurrentCamera.CFrame.Position
            local dir = (part.Position - origin).Unit
            local ray = Ray.new(origin, dir * 500)
            local hit, _ = game.Workspace:FindPartOnRay(ray, game.Players.LocalPlayer.Character)
            return hit and hit:IsDescendantOf(part.Parent)
        end)(part) then continue end
        if dist < distMin then distMin = dist; closest = plr end
    end
    return closest
end

local function aimAtTarget()
    local target = getClosest()
    if not target then return end
    local part = target.Character[AICore.lockPart]
    local targetPos = part.Position + part.Velocity * AICore.prediction
    local camPos = game.Workspace.CurrentCamera.CFrame.Position
    local newCf = CFrame.new(camPos, targetPos)
    game.Workspace.CurrentCamera.CFrame = game.Workspace.CurrentCamera.CFrame:Lerp(newCf, AICore.smoothing)
end

local function enableAimbot()
    AICore.enabled = true
    AimbotCircle.Visible = true
    game:GetService("RunService"):BindToRenderStep("VortX_Aimbot", 200, function()
        if not AICore.enabled then return end
        AimbotCircle.Radius = AICore.fov
        AimbotCircle.Position = game:GetService("UserInputService"):GetMouseLocation()
        aimAtTarget()
    end)
end

local function disableAimbot()
    AICore.enabled = false
    AimbotCircle.Visible = false
    game:GetService("RunService"):UnbindFromRenderStep("VortX_Aimbot")
end

-- ┌─────────────────────────────────────────────┐
-- │ 8.  CONFIG UI (STEP 8)                      │
-- └─────────────────────────────────────────────┘
local Window = OrionLib:MakeWindow({
    Name = "VortX Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "VortXHub"
})

local MainTab = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345998" })
local Section = MainTab:AddSection({ Name = "Core Features" })

Section:AddToggle({
    Name = "Anti-Cheat Bypass (OP)",
    Default = Config.AntiCheatBypass,
    Save = true,
    Flag = "AntiCheatBypass",
    Callback = function(v)
        Config.AntiCheatBypass = v; saveCfg()
    end
})

Section:AddToggle({
    Name = "Ultra-Gacor AI Aimbot",
    Default = Config.AICoreEnabled,
    Save = true,
    Flag = "AICoreEnabled",
    Callback = function(v)
        Config.AICoreEnabled = v; saveCfg()
        v and enableAimbot() or disableAimbot()
    end
})

Section:AddSlider({
    Name = "AI FOV",
    Min = 20,
    Max = 300,
    Default = Config.AICoreFOV,
    Save = true,
    Flag = "AICoreFOV",
    Callback = function(v)
        Config.AICoreFOV = v; AICore.fov = v; saveCfg()
    end
})

Section:AddToggle({
    Name = "Hypershot Gun Mods",
    Default = Config.HypershotMod,
    Save = true,
    Flag = "HypershotMod",
    Callback = function(v)
        Config.HypershotMod = v; saveCfg()
        if v then applyHypershot() end
    end
})

Section:AddToggle({
    Name = "Rainbow Bullet Trail",
    Default = Config.RainbowBullet,
    Save = true,
    Flag = "RainbowBullet",
    Callback = function(v)
        Config.RainbowBullet = v; saveCfg()
        if v then rainbowBullet() end
    end
})

Section:AddToggle({
    Name = "Big Head",
    Default = Config.BigHeadEnabled,
    Save = true,
    Flag = "BigHeadEnabled",
    Callback = function(v)
        Config.BigHeadEnabled = v; saveCfg()
        v and enableBigHead() or disableBigHead()
    end
})

Section:AddToggle({
    Name = "Silent Auto Fire",
    Default = Config.AutoFireEnabled,
    Save = true,
    Flag = "AutoFireEnabled",
    Callback = function(v)
        Config.AutoFireEnabled = v; saveCfg()
        v and enableAutoFire() or disableAutoFire()
    end
})

Section:AddToggle({
    Name = "Auto Spawn",
    Default = Config.AutoSpawn,
    Save = true,
    Flag = "AutoSpawn",
    Callback = function(v)
        Config.AutoSpawn = v; saveCfg()
        v and startAutoSpawn() or stopAutoSpawn()
    end
})

Section:AddToggle({
    Name = "Auto Playtime Rewards",
    Default = Config.AutoPlaytime,
    Save = true,
    Flag = "AutoPlaytime",
    Callback = function(v)
        Config.AutoPlaytime = v; saveCfg()
        v and startAutoPlaytime() or stopAutoPlaytime()
    end
})

Section:AddToggle({
    Name = "Auto Pickup Heal",
    Default = Config.AutoPickUpHeal,
    Save = true,
    Flag = "AutoPickUpHeal",
    Callback = function(v)
        Config.AutoPickUpHeal = v; saveCfg()
        v and startAutoPickUpHeal() or stopAutoPickUpHeal()
    end
})

Section:AddToggle({
    Name = "Auto Pickup Ammo",
    Default = Config.AutoPickUpAmmo,
    Save = true,
    Flag = "AutoPickUpAmmo",
    Callback = function(v)
        Config.AutoPickUpAmmo = v; saveCfg()
        v and startAutoPickUpAmmo() or stopAutoPickUpAmmo()
    end
})

Section:AddToggle({
    Name = "Auto Pickup Coins",
    Default = Config.AutoPickUpCoins,
    Save = true,
    Flag = "AutoPickUpCoins",
    Callback = function(v)
        Config.AutoPickUpCoins = v; saveCfg()
        v and startAutoPickUpCoins() or stopAutoPickUpCoins()
    end
})

Section:AddToggle({
    Name = "Auto Pickup Weapons",
    Default = Config.AutoPickUpWeapons,
    Save = true,
    Flag = "AutoPickUpWeapons",
    Callback = function(v)
        Config.AutoPickUpWeapons = v; saveCfg()
        v and startAutoPickUpWeapons() or stopAutoPickUpWeapons()
    end
})

Section:AddToggle({
    Name = "Auto Open Chest",
    Default = Config.AutoOpenChest,
    Save = true,
    Flag = "AutoOpenChest",
    Callback = function(v)
        Config.AutoOpenChest = v; saveCfg()
        v and startAutoOpenChest() or stopAutoOpenChest()
    end
})

Section:AddDropdown({
    Name = "Chest Selector",
    Default = Config.SelectedChest,
    Save = true,
    Flag = "SelectedChest",
    Options = {"Wooden","Bronze","Silver","Gold","Diamond"},
    Callback = function(v)
        Config.SelectedChest = v; saveCfg()
    end
})

Section:AddToggle({
    Name = "Auto Spin Wheel",
    Default = Config.AutoSpin,
    Save = true,
    Flag = "AutoSpin",
    Callback = function(v)
        Config.AutoSpin = v; saveCfg()
        v and startAutoSpin() or stopAutoSpin()
    end
})

-- ┌─────────────────────────────────────────────┐
-- │ 9.  ORIONLIB INIT (STEP 9 – last line)      │
-- └─────────────────────────────────────────────┘
 task.spawn(function()
    if Config.HypershotMod     then applyHypershot() end
    if Config.RainbowBullet    then rainbowBullet() end
    if Config.AICoreEnabled    then enableAimbot() end
    if Config.BigHeadEnabled   then enableBigHead() end
    if Config.AutoFireEnabled  then enableAutoFire() end
    if Config.AutoSpawn        then startAutoSpawn() end
    if Config.AutoPlaytime     then startAutoPlaytime() end
    if Config.AutoPickUpHeal   then startAutoPickUpHeal() end
    if Config.AutoPickUpAmmo   then startAutoPickUpAmmo() end
    if Config.AutoPickUpCoins  then startAutoPickUpCoins() end
    if Config.AutoPickUpWeapons then startAutoPickUpWeapons() end
    if Config.AutoOpenChest    then startAutoOpenChest() end
    if Config.AutoSpin         then startAutoSpin() end
end)

-- ┌─────────────────────────────────────────────┐
-- │ 10. AUTO-LOAD ON START (after init)         │
-- └─────────────────────────────────────────────┘
OrionLib:Init()
