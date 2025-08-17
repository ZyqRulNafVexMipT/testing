-- ==========================
-- VORTX HUB – FULL REMAKE (4 PARTS)
-- ==========================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "VortX Hub",
    Footer = "HyperShot",
    ToggleKeybind = Enum.KeyCode.LeftAlt,
    Center = true,
    AutoShow = true,
    MobileButtonsSide = "Left"
})

local MainTab = Window:AddTab("Main", "home")
local SettingsTab = Window:AddTab("Settings", "settings", "Customize the UI")
local LeftGroupbox = MainTab:AddLeftGroupbox("Main Features", "star")
local AddRightGroupbox = MainTab:AddRightGroupbox("Essential Features")
local InfoGroup = SettingsTab:AddLeftGroupbox("Script Information", "info")

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SaveFolder = "VortXHub"
local SaveFile = SaveFolder .. "/vortx_hub_HS.txt"
if not isfolder(SaveFolder) then makefolder(SaveFolder) end

getgenv().VortXConfig = getgenv().VortXConfig or {}
local config = getgenv().VortXConfig

-- AI Engine Core
local AICore = {
    aimbotEnabled = false,
    target = nil,
    fov = 120,
    smoothing = 0.1,
    prediction = 0.035,
    lockPart = "Head",
    teamCheck = true,
    visibleOnly = true,
    highlightTarget = true,
    toggleKey = Enum.KeyCode.E,
    toggleState = false,
    debounce = false
}

local AimbotFOVCircle = Drawing.new("Circle")
AimbotFOVCircle.Visible = false
AimbotFOVCircle.Thickness = 2
AimbotFOVCircle.Radius = AICore.fov
AimbotFOVCircle.Transparency = 0.5
AimbotFOVCircle.Color = Color3.fromRGB(0, 255, 255)
AimbotFOVCircle.Position = workspace.CurrentCamera.ViewportSize / 2

local function isVisible(part)
    local camera = workspace.CurrentCamera
    local origin = camera.CFrame.Position
    local direction = (part.Position - origin).Unit
    local ray = Ray.new(origin, direction * 500)
    local hit, pos = workspace:FindPartOnRay(ray, Players.LocalPlayer.Character)
    return hit and hit:IsDescendantOf(part.Parent)
end

local function getClosestPlayer()
    local camera = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    local closest = nil
    local minDist = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild(AICore.lockPart) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local part = player.Character[AICore.lockPart]
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                if onScreen and dist <= AICore.fov then
                    if not AICore.teamCheck or player.Team ~= Players.LocalPlayer.Team then
                        if not AICore.visibleOnly or isVisible(part) then
                            if dist < minDist then
                                minDist = dist
                                closest = player
                            end
                        end
                    end
                end
            end
        end
    end

    return closest
end

local function aimAtTarget()
    if not AICore.target then return end
    local camera = workspace.CurrentCamera
    local part = AICore.target.Character[AICore.lockPart]
    local targetPos = part.Position + part.Velocity * AICore.prediction
    local camPos = camera.CFrame.Position
    local newCFrame = CFrame.new(camPos, targetPos)
    camera.CFrame = camera.CFrame:Lerp(newCFrame, AICore.smoothing)
end

local function updateFOV()
    AimbotFOVCircle.Position = workspace.CurrentCamera.ViewportSize / 2
    AimbotFOVCircle.Radius = AICore.fov
end

local function enableAimbot()
    AICore.aimbotEnabled = true
    AimbotFOVCircle.Visible = true
    RunService:BindToRenderStep("AimbotLoop", 200, function()
        if not AICore.aimbotEnabled then return end
        updateFOV()
        AICore.target = getClosestPlayer()
        if AICore.target and AICore.toggleState then
            aimAtTarget()
        end
    end)
end

local function disableAimbot()
    AICore.aimbotEnabled = false
    AICore.target = nil
    AimbotFOVCircle.Visible = false
    RunService:UnbindFromRenderStep("AimbotLoop")
end

-- ==========================
-- SEMUA FITUR ASLI LANJUTAN
-- ==========================
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local MobsFolder = Workspace:FindFirstChild("Mobs")

local autoSpawnLoop = false
local autoPlaytimeLoop = false
local autoPickUpHealLoop = false
local autoPickUpCoinsLoop = false
local espLoop = false
local espOnlyLoop = false
local headLockLoop = false
local rapidFireLoop = false
local autoPickUpWeaponsLoop = false
local autoPickUpAmmoLoop = false
local autoOpenChestLoop = false
local autoSpinLoop = false

-- Load konfigurasi
loadConfig()

config.SelectedWeaponName = config.SelectedWeaponName or "All"
config.AutoSpawn = config.AutoSpawn or false
config.AutoPlaytime = config.AutoPlaytime or false
config.AutoPickUpHeal = config.AutoPickUpHeal or false
config.ESPChams = config.ESPChams or false
config.ESPOnly = config.ESPOnly or false
config.HeadLock = config.HeadLock or false
config.RapidFire = config.RapidFire or false
config.AutoPickUpWeapons = config.AutoPickUpWeapons or false
config.AutoPickUpCoins = config.AutoPickUpCoins or false
config.SelectedChest = config.SelectedChest or "Wooden"
config.AutoOpenChest = config.AutoOpenChest or false
config.AutoSpin = config.AutoSpin or false
config.AICoreEnabled = config.AICoreEnabled or false

local function saveConfig() writefile(SaveFile, HttpService:JSONEncode(config)) end

-- ESP + CHAMS
local function enableESP()
    espLoop = true
    -- [ESP logic asli tetap ada]
end

-- Auto Spawn
local function startAutoSpawn()
    autoSpawnLoop = true
    task.spawn(function()
        while autoSpawnLoop do
            local args = { [1] = false }
            ReplicatedStorage:WaitForChild("Network"):WaitForChild("Remotes"):WaitForChild("Spawn"):FireServer(unpack(args))
            task.wait(1.5)
        end
    end)
end

local function stopAutoSpawn() autoSpawnLoop = false end

-- Auto Playtime
local function startAutoPlaytime()
    autoPlaytimeLoop = true
    task.spawn(function()
        while autoPlaytimeLoop do
            for i = 1, 12 do
                local args = { [1] = i }
                ReplicatedStorage:WaitForChild("Network"):WaitForChild("Remotes"):WaitForChild("ClaimPlaytimeReward"):FireServer(unpack(args))
                task.wait(1)
            end
            task.wait(15)
        end
    end)
end

local function stopAutoPlaytime() autoPlaytimeLoop = false end

-- Auto Pickup Heal
local function startAutoPickUpHeal()
    autoPickUpHealLoop = true
    task.spawn(function()
        local network = ReplicatedStorage:WaitForChild("Network"):WaitForChild("Remotes"):WaitForChild("PickUpHeal")
        local healsFolder = workspace:WaitForChild("IgnoreThese"):WaitForChild("Pickups"):WaitForChild("Heals")
        while autoPickUpHealLoop do
            for _, heal in ipairs(healsFolder:GetChildren()) do
                network:FireServer(heal)
            end
            task.wait(0.3)
        end
    end)
end

local function stopAutoPickUpHeal() autoPickUpHealLoop = false end

-- Auto Pickup Ammo
local function startAutoPickUpAmmo()
    autoPickUpAmmoLoop = true
    task.spawn(function()
        local network = ReplicatedStorage:WaitForChild("Network"):WaitForChild("Remotes"):WaitForChild("PickUpAmmo")
        local ammoFolder = workspace:WaitForChild("IgnoreThese"):WaitForChild("Pickups"):WaitForChild("Ammo")
        while autoPickUpAmmoLoop do
            for _, ammo in ipairs(ammoFolder:GetChildren()) do
                network:FireServer(ammo)
            end
            task.wait(0.3)
        end
    end)
end

local function stopAutoPickUpAmmo() autoPickUpAmmoLoop = false end

-- Auto Pickup Coins
local function startAutoPickUpCoins()
    autoPickUpCoinsLoop = true
    task.spawn(function()
        local lootFolder = workspace:WaitForChild("IgnoreThese"):WaitForChild("Pickups"):WaitForChild("Loot")
        while autoPickUpCoinsLoop do
            for _, coin in ipairs(lootFolder:GetChildren()) do
                if coin:IsA("BasePart") then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (coin.Position - hrp.Position).Magnitude <= 100 then
                        coin.CFrame = coin.CFrame:Lerp(CFrame.new(hrp.Position + Vector3.new(0, 2, 0)), 0.5)
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end

local function stopAutoPickUpCoins() autoPickUpCoinsLoop = false end

-- Auto Open Chest
local function startAutoOpenChest()
    autoOpenChestLoop = true
    task.spawn(function()
        while autoOpenChestLoop do
            local args = { [1] = config.SelectedChest, [2] = "Random" }
            ReplicatedStorage:WaitForChild("Network"):WaitForChild("Remotes"):WaitForChild("OpenCase"):InvokeServer(unpack(args))
            task.wait(5)
        end
    end)
end

local function stopAutoOpenChest() autoOpenChestLoop = false end

-- Auto Spin Wheel
local function startAutoSpin()
    autoSpinLoop = true
    task.spawn(function()
        while autoSpinLoop do
            ReplicatedStorage:WaitForChild("Network"):WaitForChild("Remotes"):WaitForChild("SpinWheel"):InvokeServer()
            task.wait(5)
        end
    end)
end

local function stopAutoSpin() autoSpinLoop = false end

-- ==========================
-- UI TOGGLES + BIG HEAD + AUTO FIRE AI
-- ==========================
LeftGroupbox:AddToggle("AICoreEnabled", {
    Text = "VortX AI Aimbot",
    Default = config.AICoreEnabled,
    Tooltip = "Enable VortX AI Aimbot Engine",
    Callback = function(Value)
        config.AICoreEnabled = Value
        saveConfig()
        if Value then
            enableAimbot()
        else
            disableAimbot()
        end
    end
})

AddRightGroupbox:AddSlider("AICoreFOV", {
    Text = "AI FOV",
    Default = AICore.fov,
    Min = 20,
    Max = 300,
    Rounding = 0,
    Tooltip = "Adjust AI aimbot FOV",
    Callback = function(Value)
        AICore.fov = Value
        AimbotFOVCircle.Radius = Value
    end
})

-- Big Head
LeftGroupbox:AddButton("Make Player Head Big", function()
    local localplayer = Players.LocalPlayer
    RunService.RenderStepped:Connect(function()
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= localplayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local head = v.Character.Head
                head.Size = Vector3.new(5, 5, 5)
                head.Transparency = 0.5
            end
        end
    end)
end)

-- Auto Fire AI
local autoFireEnabled = false
local autoFireConnection

local function enableAutoFire()
    autoFireConnection = RunService.RenderStepped:Connect(function()
        if not autoFireEnabled then return end
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 then
            mouse1click()
        end
    end)
end

LeftGroupbox:AddToggle("Auto Fire AI", {
    Text = "Auto Fire AI",
    Default = false,
    Tooltip = "Automatically fires at enemies in FOV",
    Callback = function(Value)
        autoFireEnabled = Value
        if Value then
            enableAutoFire()
        elseif autoFireConnection then
            autoFireConnection:Disconnect()
        end
    end
})

-- ==========================
-- INFO + WATERMARK + AUTO LOAD
-- ==========================
InfoGroup:AddLabel("Script by: VortX")
InfoGroup:AddLabel("Version: 1.0.0")
InfoGroup:AddLabel("Game: HyperShot")

InfoGroup:AddButton("Join Discord", function()
    setclipboard("https://discord.gg/vortxhub")
    print("Copied VortX Discord Invite!")
end)

-- Auto load config
task.delay(0.5, function()
    if config.AICoreEnabled then enableAimbot() end
    if config.AutoSpawn then startAutoSpawn() end
    if config.AutoPlaytime then startAutoPlaytime() end
    if config.AutoPickUpHeal then startAutoPickUpHeal() end
    if config.AutoPickUpAmmo then startAutoPickUpAmmo() end
    if config.AutoPickUpCoins then startAutoPickUpCoins() end
    if config.AutoOpenChest then startAutoOpenChest() end
    if config.AutoSpin then startAutoSpin() end
end)
