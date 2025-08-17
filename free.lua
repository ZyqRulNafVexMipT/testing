--[[  VORTX HUB – ONE FILE  ]]
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

local HS = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local RS  = game:GetService("RunService")
local WS  = game:GetService("Workspace")
local PS  = game:GetService("Players")
local RS2 = game:GetService("ReplicatedStorage")

local LP = PS.LocalPlayer
local Cam = WS.CurrentCamera
local MobsFolder = WS:FindFirstChild("Mobs")

-- ┌─────────────────────────────────────────────┐
-- │ 1. CONFIG SAVE / LOAD                       │
-- └─────────────────────────────────────────────┘
local SaveFolder = "VortXHub"
local SaveFile   = SaveFolder .. "/vortx_config.json"
if not isfolder(SaveFolder) then makefolder(SaveFolder) end

local Config = {
    AntiCheatBypass = true,
    AICoreEnabled   = false,
    AICoreFOV       = 120,
    BigHeadEnabled  = false,
    AutoFireEnabled = false,
    HypershotMod    = false,
    ESPChams        = false,
    ESPOnly         = false,
    HeadLock        = false,
    RapidFire       = false,
    AutoSpawn       = false,
    AutoPlaytime    = false,
    AutoPickUpHeal  = false,
    AutoPickUpAmmo  = false,
    AutoPickUpCoins = false,
    AutoPickUpWeapons = false,
    AutoOpenChest   = false,
    AutoSpin        = false,
    SelectedChest   = "Wooden",
    SelectedWeapon  = "All"
}

local function loadCfg()
    local ok, data = pcall(function() return HS:JSONDecode(readfile(SaveFile)) end)
    if ok and type(data) == "table" then
        for k, v in pairs(data) do Config[k] = v end
    end
end

local function saveCfg()
    writefile(SaveFile, HS:JSONEncode(Config))
end

loadCfg() -- load first
-- ┌─────────────────────────────────────────────┐
-- │ 2. ANTI-CHEAT BYPASS                        │
-- └─────────────────────────────────────────────┘
if Config.AntiCheatBypass then
    -- chat log block
    for _, v in pairs(game:GetDescendants()) do
        if v.Name:lower():find("chat") then
            pcall(function() v:Destroy() end)
        end
    end
    -- remote cloaking
    local remote = RS2:FindFirstChild("Network", true)
    if remote then
        pcall(function() sethiddenproperty(remote, "Name", "") end)
    end
end

-- ┌─────────────────────────────────────────────┐
-- │ 3. HYPERSHOT GUN MODS                       │
-- └─────────────────────────────────────────────┘
local function applyHypershot()
    for _, v in next, getgc(true) do
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

-- ┌─────────────────────────────────────────────┐
-- │ 4. AI ENGINE                                │
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

local function isVisible(part)
    local origin = Cam.CFrame.Position
    local dir    = (part.Position - origin).Unit
    local ray    = Ray.new(origin, dir * 500)
    local hit, _ = WS:FindPartOnRay(ray, LP.Character)
    return hit and hit:IsDescendantOf(part.Parent)
end

local function getClosest()
    local mousePos = UIS:GetMouseLocation()
    local closest, distMin = nil, math.huge
    for _, plr in pairs(PS:GetPlayers()) do
        if plr == LP then continue end
        local char = plr.Character
        if not char or not char:FindFirstChild(AICore.lockPart) then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = char[AICore.lockPart]
        local screenPos, onScreen = Cam:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist > AICore.fov then continue end
        if AICore.teamCheck and plr.Team == LP.Team then continue end
        if AICore.visibleOnly and not isVisible(part) then continue end
        if dist < distMin then distMin = dist; closest = plr end
    end
    return closest
end

local function aimAtTarget()
    local target = getClosest()
    if not target then return end
    local part = target.Character[AICore.lockPart]
    local targetPos = part.Position + part.Velocity * AICore.prediction
    local camPos = Cam.CFrame.Position
    local newCf = CFrame.new(camPos, targetPos)
    Cam.CFrame = Cam.CFrame:Lerp(newCf, AICore.smoothing)
end

local function enableAimbot()
    AICore.enabled = true
    AimbotCircle.Visible = true
    RS:BindToRenderStep("VortX_Aimbot", 200, function()
        if not AICore.enabled then return end
        AimbotCircle.Radius = AICore.fov
        AimbotCircle.Position = UIS:GetMouseLocation()
        aimAtTarget()
    end)
end

local function disableAimbot()
    AICore.enabled = false
    AimbotCircle.Visible = false
    RS:UnbindFromRenderStep("VortX_Aimbot")
end

-- ┌─────────────────────────────────────────────┐
-- │ 5. BIG HEAD & AUTO FIRE                     │
-- └─────────────────────────────────────────────┘
local bigHeadConn
local function enableBigHead()
    if bigHeadConn then bigHeadConn:Disconnect() end
    bigHeadConn = RS.RenderStepped:Connect(function()
        for _, plr in pairs(PS:GetPlayers()) do
            if plr == LP then continue end
            local char = plr.Character
            if char and char:FindFirstChild("Head") then
                char.Head.Size = Vector3.new(6, 6, 6)
                char.Head.Transparency = 0.4
            end
        end
    end)
end

local function disableBigHead()
    if bigHeadConn then bigHeadConn:Disconnect(); bigHeadConn = nil end
end

local autoFireConn
local function enableAutoFire()
    if autoFireConn then autoFireConn:Disconnect() end
    autoFireConn = RS.RenderStepped:Connect(function()
        if getClosest() then mouse1click() end
    end)
end

local function disableAutoFire()
    if autoFireConn then autoFireConn:Disconnect(); autoFireConn = nil end
end

-- ┌─────────────────────────────────────────────┐
-- │ 6. AUTO FEATURES (short loops)              │
-- └─────────────────────────────────────────────┘
local loops = {}
local function startLoop(name, delay, func)
    if loops[name] then loops[name]:Disconnect() end
    loops[name] = RS.RenderStepped:Connect(func)
end
local function stopLoop(name)
    if loops[name] then loops[name]:Disconnect(); loops[name]=nil end
end

-- spawn
local function startAutoSpawn()
    startLoop("AutoSpawn", 1.5, function()
        RS2:WaitForChild("Network"):WaitForChild("Remotes"):WaitForChild("Spawn"):FireServer(false)
    end)
end
local function stopAutoSpawn() stopLoop("AutoSpawn") end

-- playtime
local function startAutoPlaytime()
    startLoop("AutoPlaytime", 16, function()
        for i = 1, 12 do
            RS2:WaitForChild("Network"):WaitForChild("Remotes"):WaitForChild("ClaimPlaytimeReward"):FireServer(i)
            wait(1)
        end
    end)
end
local function stopAutoPlaytime() stopLoop("AutoPlaytime") end

-- heal
local function startAutoPickUpHeal()
    startLoop("AutoHeal", 0.3, function()
        local folder = WS:WaitForChild("IgnoreThese"):WaitForChild("Pickups"):WaitForChild("Heals")
        for _, h in ipairs(folder:GetChildren()) do
            RS2:WaitForChild("Network"):WaitForChild("Remotes"):WaitForChild("PickUpHeal"):FireServer(h)
        end
    end)
end
local function stopAutoPickUpHeal() stopLoop("AutoHeal") end

-- ammo
local function startAutoPickUpAmmo()
    startLoop("AutoAmmo", 0.3, function()
        local folder = WS:WaitForChild("IgnoreThese"):WaitForChild("Pickups"):WaitForChild("Ammo")
        for _, a in ipairs(folder:GetChildren()) do
            RS2:WaitForChild("Network"):WaitForChild("Remotes"):WaitForChild("PickUpAmmo"):FireServer(a)
        end
    end)
end
local function stopAutoPickUpAmmo() stopLoop("AutoAmmo") end

-- coins
local function startAutoPickUpCoins()
    startLoop("AutoCoins", 0.05, function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local folder = WS:WaitForChild("IgnoreThese"):WaitForChild("Pickups"):WaitForChild("Loot")
        for _, c in ipairs(folder:GetChildren()) do
            if c:IsA("BasePart") and (c.Position - hrp.Position).Magnitude <= 100 then
                c.CFrame = c.CFrame:Lerp(CFrame.new(hrp.Position + Vector3.new(0, 2, 0)), 0.5)
            end
        end
    end)
end
local function stopAutoPickUpCoins() stopLoop("AutoCoins") end

-- weapons
local function startAutoPickUpWeapons()
    startLoop("AutoWeapons", 0.3, function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local folder = WS:WaitForChild("IgnoreThese"):WaitForChild("Pickups"):WaitForChild("Weapons")
        for _, w in ipairs(folder:GetChildren()) do
            w.CFrame = hrp.CFrame
        end
    end)
end
local function stopAutoPickUpWeapons() stopLoop("AutoWeapons") end

-- chest
local function startAutoOpenChest()
    startLoop("AutoChest", 5, function()
        local args = { Config.SelectedChest, "Random" }
        RS2:WaitForChild("Network"):WaitForChild("Remotes"):WaitForChild("OpenCase"):InvokeServer(unpack(args))
    end)
end
local function stopAutoOpenChest() stopLoop("AutoChest") end

-- spin
local function startAutoSpin()
    startLoop("AutoSpin", 5, function()
        RS2:WaitForChild("Network"):WaitForChild("Remotes"):WaitForChild("SpinWheel"):InvokeServer()
    end)
end
local function stopAutoSpin() stopLoop("AutoSpin") end

-- ┌─────────────────────────────────────────────┐
-- │ 7. UI WITH ORIONLIB                         │
-- └─────────────────────────────────────────────┘
local Window = OrionLib:MakeWindow({
    Name = "VortX Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "VortXHub"
})

local MainTab = Window:MakeTab({ Name = "Main", Icon = "rbxassetid://4483345998" })

local MainSection = MainTab:AddSection({ Name = "Main Features" })

MainSection:AddToggle({
    Name = "Anti-Cheat Bypass",
    Default = Config.AntiCheatBypass,
    Save = true,
    Flag = "AntiCheatBypass",
    Callback = function(v) Config.AntiCheatBypass = v; saveCfg() end
})

MainSection:AddToggle({
    Name = "Ultra-Gacor AI Aimbot",
    Default = Config.AICoreEnabled,
    Save = true,
    Flag = "AICoreEnabled",
    Callback = function(v)
        Config.AICoreEnabled = v; saveCfg()
        v and enableAimbot() or disableAimbot()
    end
})

MainSection:AddSlider({
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

MainSection:AddToggle({
    Name = "Hypershot Gun Mods",
    Default = Config.HypershotMod,
    Save = true,
    Flag = "HypershotMod",
    Callback = function(v)
        Config.HypershotMod = v; saveCfg()
        if v then applyHypershot() end
    end
})

MainSection:AddToggle({
    Name = "Big Head",
    Default = Config.BigHeadEnabled,
    Save = true,
    Flag = "BigHeadEnabled",
    Callback = function(v)
        Config.BigHeadEnabled = v; saveCfg()
        v and enableBigHead() or disableBigHead()
    end
})

MainSection:AddToggle({
    Name = "Silent Auto Fire",
    Default = Config.AutoFireEnabled,
    Save = true,
    Flag = "AutoFireEnabled",
    Callback = function(v)
        Config.AutoFireEnabled = v; saveCfg()
        v and enableAutoFire() or disableAutoFire()
    end
})

MainSection:AddToggle({
    Name = "Auto Spawn",
    Default = Config.AutoSpawn,
    Save = true,
    Flag = "AutoSpawn",
    Callback = function(v)
        Config.AutoSpawn = v; saveCfg()
        v and startAutoSpawn() or stopAutoSpawn()
    end
})

MainSection:AddToggle({
    Name = "Auto Playtime Rewards",
    Default = Config.AutoPlaytime,
    Save = true,
    Flag = "AutoPlaytime",
    Callback = function(v)
        Config.AutoPlaytime = v; saveCfg()
        v and startAutoPlaytime() or stopAutoPlaytime()
    end
})

MainSection:AddToggle({
    Name = "Auto Pickup Heal",
    Default = Config.AutoPickUpHeal,
    Save = true,
    Flag = "AutoPickUpHeal",
    Callback = function(v)
        Config.AutoPickUpHeal = v; saveCfg()
        v and startAutoPickUpHeal() or stopAutoPickUpHeal()
    end
})

MainSection:AddToggle({
    Name = "Auto Pickup Ammo",
    Default = Config.AutoPickUpAmmo,
    Save = true,
    Flag = "AutoPickUpAmmo",
    Callback = function(v)
        Config.AutoPickUpAmmo = v; saveCfg()
        v and startAutoPickUpAmmo() or stopAutoPickUpAmmo()
    end
})

MainSection:AddToggle({
    Name = "Auto Pickup Coins",
    Default = Config.AutoPickUpCoins,
    Save = true,
    Flag = "AutoPickUpCoins",
    Callback = function(v)
        Config.AutoPickUpCoins = v; saveCfg()
        v and startAutoPickUpCoins() or stopAutoPickUpCoins()
    end
})

MainSection:AddToggle({
    Name = "Auto Pickup Weapons",
    Default = Config.AutoPickUpWeapons,
    Save = true,
    Flag = "AutoPickUpWeapons",
    Callback = function(v)
        Config.AutoPickUpWeapons = v; saveCfg()
        v and startAutoPickUpWeapons() or stopAutoPickUpWeapons()
    end
})

MainSection:AddToggle({
    Name = "Auto Open Chest",
    Default = Config.AutoOpenChest,
    Save = true,
    Flag = "AutoOpenChest",
    Callback = function(v)
        Config.AutoOpenChest = v; saveCfg()
        v and startAutoOpenChest() or stopAutoOpenChest()
    end
})

MainSection:AddDropdown({
    Name = "Chest Selector",
    Default = Config.SelectedChest,
    Save = true,
    Flag = "SelectedChest",
    Options = {"Wooden","Bronze","Silver","Gold","Diamond"},
    Callback = function(v)
        Config.SelectedChest = v; saveCfg()
    end
})

MainSection:AddToggle({
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
-- │ 8. ORIONLIB INIT (AFTER CONFIG LOADED)      │
-- └─────────────────────────────────────────────┘
OrionLib:Init()

-- ┌─────────────────────────────────────────────┐
-- │ 9. AUTO-LOAD TOGGLES ON START               │
-- └─────────────────────────────────────────────┘
task.spawn(function()
    if Config.AntiCheatBypass then -- already applied above
    end
    if Config.HypershotMod then applyHypershot() end
    if Config.AICoreEnabled then enableAimbot() end
    if Config.BigHeadEnabled then enableBigHead() end
    if Config.AutoFireEnabled then enableAutoFire() end
    if Config.AutoSpawn then startAutoSpawn() end
    if Config.AutoPlaytime then startAutoPlaytime() end
    if Config.AutoPickUpHeal then startAutoPickUpHeal() end
    if Config.AutoPickUpAmmo then startAutoPickUpAmmo() end
    if Config.AutoPickUpCoins then startAutoPickUpCoins() end
    if Config.AutoPickUpWeapons then startAutoPickUpWeapons() end
    if Config.AutoOpenChest then startAutoOpenChest() end
    if Config.AutoSpin then startAutoSpin() end
end)
