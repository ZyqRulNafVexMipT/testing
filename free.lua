-- ==========================
-- ORIGINAL SEISEN HUB START
-- ==========================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()

local Window = Library:CreateWindow({
    Title = "Seisen Hub",
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

local SaveFolder = "SeisenHub"
local SaveFile = SaveFolder .. "/seisen_hub_HS.txt"
if not isfolder(SaveFolder) then makefolder(SaveFolder) end

getgenv().HypershotConfig = getgenv().HypershotConfig or {}
local config = getgenv().HypershotConfig
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
local selectedWeaponName = false
local autoOpenChestLoop = false
local autoSpinLoop = false
local aimbotEnabled = false
local aimbotFOV = 20

local function saveConfig() writefile(SaveFile, HttpService:JSONEncode(config)) end
local function loadConfig()
    if isfile(SaveFile) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(SaveFile)) end)
        if success and type(data) == "table" then for k, v in pairs(data) do config[k] = v end end
    end
end

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
config.SelectedWeaponName = config.SelectedWeaponName or "All"
config.SelectedChest = config.SelectedChest or "Wooden"
config.AutoOpenChest = config.AutoOpenChest or false
config.AutoSpin = config.AutoSpin or false
config.AimbotEnabled = config.AimbotEnabled or false
config.AimbotFOV = config.AimbotFOV or 20

-- ==========================
-- NEW UNIVERSAL AIMBOT START
-- ==========================
local teamCheck = true
local fov = 90
local smoothing = 1
local predictionFactor = 0
local highlightEnabled = false
local lockPart = "Head"
local Toggle = false
local ToggleKey = Enum.KeyCode.E

local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "Universal Aimbot",
    Text = "me",
    Duration = 5,
})

local FOVring = Drawing.new("Circle")
FOVring.Visible = true
FOVring.Thickness = 1
FOVring.Radius = fov
FOVring.Transparency = 0.8
FOVring.Color = Color3.fromRGB(255, 128, 128)
FOVring.Position = workspace.CurrentCamera.ViewportSize / 2

local currentTarget = nil
local toggleState = false
local debounce = false

local function getClosest(cframe)
    local ray = Ray.new(cframe.Position, cframe.LookVector).Unit
    local target = nil
    local mag = math.huge
    local screenCenter = workspace.CurrentCamera.ViewportSize / 2

    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild(lockPart) and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("HumanoidRootPart") and v ~= Players.LocalPlayer and (v.Team ~= Players.LocalPlayer.Team or (not teamCheck)) then
            local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(v.Character[lockPart].Position)
            local distanceFromCenter = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
            if onScreen and distanceFromCenter <= fov then
                local magBuf = (v.Character[lockPart].Position - ray:ClosestPoint(v.Character[lockPart].Position)).Magnitude
                if magBuf < mag then
                    mag = magBuf
                    target = v
                end
            end
        end
    end
    return target
end
-- ==========================
-- NEW UNIVERSAL AIMBOT END
-- ==========================

-- ==========================
-- BIG HEAD FEATURE
-- ==========================
LeftGroupbox:AddButton("Make Player Head big", function()
    local localplayer = Players.LocalPlayer
    game:GetService("RunService").RenderStepped:Connect(function()
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= localplayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local head = v.Character:FindFirstChild("Head")
                head.Size = Vector3.new(5, 5, 5)
                head.Transparency = 0.5
            end
        end
    end)
end)

-- ==========================
-- AUTO FIRE AI ENGINE
-- ==========================
local autoFireEnabled = false
local autoFireConnection

local function enableAutoFire()
    autoFireConnection = RunService.RenderStepped:Connect(function()
        if not autoFireEnabled then return end
        local mouse = Players.LocalPlayer:GetMouse()
        local target = getClosest(workspace.CurrentCamera.CFrame)
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
-- REST OF ORIGINAL SCRIPT
-- ==========================
-- [ALL ORIGINAL FUNCTIONS REMAIN UNCHANGED]
-- ... (ESP, AutoSpawn, AutoChest, etc.)
local headLockConnection

local function enableHeadLock()
    headLockConnection = RunService.RenderStepped:Connect(function()
        if headLockLoop then
            local camera = Workspace.CurrentCamera
            local localTeam = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Team")

            -- Lock all enemy heads (Players, UGC models, Mobs) to camera

            -- Roblox Players
            for _, player in Players:GetPlayers() do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local playerTeam = player.Character:GetAttribute("Team")
                    if not localTeam or not playerTeam or localTeam ~= playerTeam or localTeam == -1 then
                        local head = player.Character.Head
                        head.CFrame = camera.CFrame + camera.CFrame.LookVector * 7
                    end
                end
            end

            -- UGC workspace player models
            local ugc = Workspace:FindFirstChild("ugc")
            if ugc and ugc:FindFirstChild("workspace") then
                for _, playerModel in ipairs(ugc.workspace:GetChildren()) do
                    if playerModel:IsA("Model") then
                        local modelTeam = playerModel:GetAttribute("Team")
                        if not localTeam or not modelTeam or localTeam ~= modelTeam or localTeam == -1 then
                            local head = playerModel:FindFirstChild("Head")
                            if head then
                                head.CFrame = camera.CFrame + camera.CFrame.LookVector * 6
                            end
                        end
                    end
                end
            end

            -- Mobs
            if MobsFolder then
                for _, mob in MobsFolder:GetChildren() do
                    if mob:IsA("Model") and mob:FindFirstChild("Head") then
                        local mobTeam = mob:GetAttribute("Team")
                        if not localTeam or not mobTeam or localTeam ~= mobTeam or localTeam == -1 then
                            local head = mob:FindFirstChild("Head")
                            head.CFrame = camera.CFrame + camera.CFrame.LookVector * 5
                        end
                    end
                end
            end
        end
    end)
end

local function disableHeadLock()
    if headLockConnection then
        headLockConnection:Disconnect()
        headLockConnection = nil
    end
end

-- ESP + CHAMS Logic
_G.HeadSize = 10
_G.Disabled = config.ESPChams

local function applyPropertiesToPart(part, isEnemy)
    if part and part.Parent ~= LocalPlayer.Character then
        part.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
        part.Transparency = 0.7
        part.BrickColor = isEnemy and BrickColor.new("Really red") or BrickColor.new("Bright blue")
        part.Material = Enum.Material.Neon
        part.CanCollide = false
    end
end

local function applyHighlight(model, isEnemy)
    if model ~= LocalPlayer.Character then
        for _, highlight in ipairs(model:GetChildren()) do
            if highlight:IsA("Highlight") and (highlight.Name == "EnemyHighlight" or highlight.Name == "PlayerOutline") then
                highlight:Destroy()
            end
        end
        local highlightName = isEnemy and "EnemyHighlight" or "PlayerOutline"
        local highlight = Instance.new("Highlight")
        highlight.Name = highlightName
        highlight.FillColor = isEnemy and Color3.fromRGB(234, 0, 0) or Color3.fromRGB(0, 0, 255)
        highlight.OutlineColor = isEnemy and Color3.new(255, 0.4, 0.4) or Color3.new(0, 0, 0.4)
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = model
        highlight.Parent = model
    end
end

local espConnection
local function enableESP()
    espConnection = RunService.RenderStepped:Connect(function()
        if espLoop then
            -- Check Players service (for bots/mobs with characters)
            for _, player in Players:GetPlayers() do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        local localTeam = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Team")
                        local playerTeam = player.Character and player.Character:GetAttribute("Team")
                        local isEnemy = (localTeam and playerTeam) and localTeam ~= playerTeam and localTeam ~= -1
                        applyPropertiesToPart(player.Character.HumanoidRootPart, isEnemy)
                        applyHighlight(player.Character, isEnemy)
                    end)
                end
            end

            -- Check workspace for real player models (ugc.workspace.playername.hrp)
            for _, playerModel in pairs(Workspace:GetChildren()) do
                if playerModel:IsA("Model") and playerModel:FindFirstChild("HumanoidRootPart") then
                    -- Skip if this is a mob (mobs are handled separately)
                    if MobsFolder and playerModel.Parent == MobsFolder then
                        continue
                    end
                    
                    pcall(function()
                        local localTeam = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Team")
                        local modelTeam = playerModel:GetAttribute("Team")
                        
                        -- Try multiple ways to determine if this is an enemy
                        local isEnemy = false
                        if localTeam and modelTeam then
                            isEnemy = localTeam ~= modelTeam and localTeam ~= -1
                        else
                            -- Fallback: assume it's an enemy if we can't determine team (real players)
                            isEnemy = true
                        end
                        
                        applyPropertiesToPart(playerModel.HumanoidRootPart, isEnemy)
                        applyHighlight(playerModel, isEnemy)
                    end)
                end
            end

            -- Check Mobs folder
            if MobsFolder then
                for _, mob in MobsFolder:GetChildren() do
                    if mob:IsA("Model") and mob:FindFirstChild("HumanoidRootPart") then
                        pcall(function()
                            local localTeam = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Team")
                            local mobTeam = mob:GetAttribute("Team")
                            local isEnemy = (localTeam and mobTeam) and localTeam ~= mobTeam and localTeam ~= -1
                            applyPropertiesToPart(mob.HumanoidRootPart, isEnemy)
                            applyHighlight(mob, isEnemy)
                        end)
                    end
                end
            end
        end
    end)
end

local espOnlyConnection
local function enableESPOnly()
    espOnlyConnection = RunService.RenderStepped:Connect(function()
        if espOnlyLoop then
            -- Check Players service (for bots/mobs with characters)
            for _, player in Players:GetPlayers() do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        local localTeam = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Team")
                        local playerTeam = player.Character and player.Character:GetAttribute("Team")
                        local isEnemy = (localTeam and playerTeam) and localTeam ~= playerTeam and localTeam ~= -1
                        applyHighlight(player.Character, isEnemy)
                    end)
                end
            end

            -- Check workspace for real player models (ugc.workspace.playername.hrp)
            for _, playerModel in pairs(Workspace:GetChildren()) do
                if playerModel:IsA("Model") and playerModel:FindFirstChild("HumanoidRootPart") then
                    -- Skip if this is a mob (mobs are handled separately)
                    if MobsFolder and playerModel.Parent == MobsFolder then
                        continue
                    end
                    
                    pcall(function()
                        local localTeam = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Team")
                        local modelTeam = playerModel:GetAttribute("Team")
                        
                        -- Try multiple ways to determine if this is an enemy
                        local isEnemy = false
                        if localTeam and modelTeam then
                            isEnemy = localTeam ~= modelTeam and localTeam ~= -1
                        else
                            -- Fallback: assume it's an enemy if we can't determine team (real players)
                            isEnemy = true
                        end
                        
                        applyHighlight(playerModel, isEnemy)
                    end)
                end
            end

            -- Check Mobs folder
            if MobsFolder then
                for _, mob in MobsFolder:GetChildren() do
                    if mob:IsA("Model") and mob:FindFirstChild("HumanoidRootPart") then
                        pcall(function()
                            local localTeam = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Team")
                            local mobTeam = mob:GetAttribute("Team")
                            local isEnemy = (localTeam and mobTeam) and localTeam ~= mobTeam and localTeam ~= -1
                            applyHighlight(mob, isEnemy)
                        end)
                    end
                end
            end
        end
    end)
end

local function disableESP()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    -- Clean up highlights from Players service
    for _, player in Players:GetPlayers() do
        if player.Character then
            for _, highlight in ipairs(player.Character:GetChildren()) do
                if highlight:IsA("Highlight") and (highlight.Name == "EnemyHighlight" or highlight.Name == "PlayerOutline") then
                    highlight:Destroy()
                end
            end
        end
    end
    -- Clean up highlights from workspace player models
    for _, playerModel in pairs(Workspace:GetChildren()) do
        if playerModel:IsA("Model") then
            for _, highlight in ipairs(playerModel:GetChildren()) do
                if highlight:IsA("Highlight") and (highlight.Name == "EnemyHighlight" or highlight.Name == "PlayerOutline") then
                    highlight:Destroy()
                end
            end
        end
    end
    -- Clean up highlights from Mobs folder
    if MobsFolder then
        for _, mob in MobsFolder:GetChildren() do
            for _, highlight in ipairs(mob:GetChildren()) do
                if highlight:IsA("Highlight") and (highlight.Name == "EnemyHighlight" or highlight.Name == "PlayerOutline") then
                    highlight:Destroy()
                end
            end
        end
    end
end

local function disableESPOnly()
    if espOnlyConnection then
        espOnlyConnection:Disconnect()
        espOnlyConnection = nil
    end
    -- Clean up highlights from Players service
    for _, player in Players:GetPlayers() do
        if player.Character then
            for _, highlight in ipairs(player.Character:GetChildren()) do
                if highlight:IsA("Highlight") and (highlight.Name == "EnemyHighlight" or highlight.Name == "PlayerOutline") then
                    highlight:Destroy()
                end
            end
        end
    end
    -- Clean up highlights from workspace player models
    for _, playerModel in pairs(Workspace:GetChildren()) do
        if playerModel:IsA("Model") then
            for _, highlight in ipairs(playerModel:GetChildren()) do
                if highlight:IsA("Highlight") and (highlight.Name == "EnemyHighlight" or highlight.Name == "PlayerOutline") then
                    highlight:Destroy()
                end
            end
        end
    end
    -- Clean up highlights from Mobs folder
    if MobsFolder then
        for _, mob in MobsFolder:GetChildren() do
            for _, highlight in ipairs(mob:GetChildren()) do
                if highlight:IsA("Highlight") and (highlight.Name == "EnemyHighlight" or highlight.Name == "PlayerOutline") then
                    highlight:Destroy()
                end
            end
        end
    end
end
local function startAutoSpawn()
    autoSpawnLoop = true
    task.spawn(function()
        while autoSpawnLoop do
            local args = {
                [1] = false;
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Network", 9e9):WaitForChild("Remotes", 9e9):WaitForChild("Spawn", 9e9):FireServer(unpack(args))
            task.wait(1.5)
        end
    end)
end

local function stopAutoSpawn()
    autoSpawnLoop = false
end

local function startAutoPlaytime()
    autoPlaytimeLoop = true
    task.spawn(function()
        while autoPlaytimeLoop do
            for i = 1, 12 do
                local args = { [1] = i }
                print("Trying to claim playtime reward:", i)
                local success, err = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Network", 9e9)
                        :WaitForChild("Remotes", 9e9)
                        :WaitForChild("ClaimPlaytimeReward", 9e9)
                        :FireServer(unpack(args))
                end)
                if not success then
                    warn("Failed to claim playtime reward " .. i .. ": " .. tostring(err))
                end
                task.wait(1)
            end
            task.wait(15)
        end
    end)
end

local function stopAutoPlaytime()
    autoPlaytimeLoop = false
end

local function startAutoPickUpHeal()
    autoPickUpHealLoop = true
    task.spawn(function()
        local rs = game:GetService("ReplicatedStorage")
        local network = rs:WaitForChild("Network", 9e9):WaitForChild("Remotes", 9e9):WaitForChild("PickUpHeal", 9e9)
        local healsFolder = workspace:WaitForChild("IgnoreThese", 9e9):WaitForChild("Pickups", 9e9):WaitForChild("Heals", 9e9)

        local function pickUpHeals()
            for _, heal in ipairs(healsFolder:GetChildren()) do
                local args = { heal }
                network:FireServer(unpack(args))
            end
        end

        while autoPickUpHealLoop do
            pickUpHeals()
            task.wait(0.3)
        end
    end)
end

local function stopAutoPickUpHeal()
    autoPickUpHealLoop = false
end

-- Auto Pickup Ammo
local function startAutoPickUpAmmo()
    autoPickUpAmmoLoop = true
    task.spawn(function()
        local rs = game:GetService("ReplicatedStorage")
        local pickUpAmmo = rs:WaitForChild("Network", 9e9):WaitForChild("Remotes", 9e9):WaitForChild("PickUpAmmo", 9e9)
        local ammoFolder = workspace:WaitForChild("IgnoreThese", 9e9):WaitForChild("Pickups", 9e9):WaitForChild("Ammo", 9e9)

        local function pickUpAllAmmo()
            for _, ammo in ipairs(ammoFolder:GetChildren()) do
                if ammo:IsA("Model") or ammo:IsA("Part") then
                    pickUpAmmo:FireServer(ammo)
                end
            end
        end

        while autoPickUpAmmoLoop do
            pickUpAllAmmo()
            task.wait(0.3)
        end
    end)
end

local function stopAutoPickUpAmmo()
    autoPickUpAmmoLoop = false
end

local function startAutoPickUpCoins()
    autoPickUpCoinsLoop = true
    local function coinMagnet()
        local player = Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local lootFolder = workspace:WaitForChild("IgnoreThese", 9e9)
            :WaitForChild("Pickups", 9e9)
            :WaitForChild("Loot", 9e9)
        while autoPickUpCoinsLoop do
            for _, coin in ipairs(lootFolder:GetChildren()) do
                if coin:IsA("BasePart") then
                    local distance = (coin.Position - hrp.Position).Magnitude
                    if distance <= 100 then
                        coin.CFrame = coin.CFrame:Lerp(
                            CFrame.new(hrp.Position + Vector3.new(0, 2, 0)),
                            0.5
                        )
                    end
                end
            end
            task.wait(0.05)
        end
    end
    task.spawn(coinMagnet)
    -- Listen for respawn and restart coin magnet
    local respawnConn
    respawnConn = Players.LocalPlayer.CharacterAdded:Connect(function()
        if autoPickUpCoinsLoop then
            task.spawn(coinMagnet)
        end
    end)
    -- Clean up connection on stop
    local function cleanup()
        if respawnConn then respawnConn:Disconnect() end
    end
    getgenv()._CoinMagnetCleanup = cleanup
end

local function stopAutoPickUpCoins()
    autoPickUpCoinsLoop = false
    if getgenv()._CoinMagnetCleanup then
        getgenv()._CoinMagnetCleanup()
        getgenv()._CoinMagnetCleanup = nil
    end
end

local function startAutoOpenChest()
    autoOpenChestLoop = true
    task.spawn(function()
        while autoOpenChestLoop do
            local success, err = pcall(function()
                local args = {
                    [1] = config.SelectedChest,
                    [2] = "Random"
                }
                local result = game:GetService("ReplicatedStorage")
                    :WaitForChild("Network")
                    :WaitForChild("Remotes")
                    :WaitForChild("OpenCase")
                    :InvokeServer(unpack(args))
                print("OpenCase result:", result)
            end)
            if not success then
                warn("Failed to open chest:", err)
            end
            task.wait(5)
        end
    end)
end

local function stopAutoOpenChest()
    autoOpenChestLoop = false
end

local function startAutoSpin()
    autoSpinLoop = true
    task.spawn(function()
        while autoSpinLoop do
            local success, err = pcall(function()
                local args = {}
                local result = game:GetService("ReplicatedStorage")
                    :WaitForChild("Network")
                    :WaitForChild("Remotes")
                    :WaitForChild("SpinWheel")
                    :InvokeServer(unpack(args))
                print("SpinWheel result:", result)
            end)
            if not success then
                warn("Failed to spin wheel:", err)
            end
            task.wait(5) -- Adjustable delay to avoid rate limits
        end
    end)
end

local function stopAutoSpin()
    autoSpinLoop = false
end

-- Auto Pick Up Coins
local respawnConn
local function startAutoPickUpCoins()
    autoPickUpCoinsLoop = true
    respawnConn = RunService.RenderStepped:Connect(function()
        if not autoPickUpCoinsLoop then return end
        local coinsFolder = Workspace:FindFirstChild("IgnoreThese") and Workspace.IgnoreThese:FindFirstChild("Pickups") and Workspace.IgnoreThese.Pickups:FindFirstChild("Coins")
        if coinsFolder then
            for _, coin in ipairs(coinsFolder:GetChildren()) do
                if coin:IsA("Model") or coin:IsA("Part") then
                    coin.CFrame = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame or coin.CFrame
                end
            end
        end
    end)
end

local function stopAutoPickUpCoins()
    autoPickUpCoinsLoop = false
    if respawnConn then respawnConn:Disconnect() end
end

-- Auto Pick Up Weapons
local function startAutoPickUpWeapons()
    autoPickUpWeaponsLoop = true
    task.spawn(function()
        while autoPickUpWeaponsLoop do
            local weaponsFolder = Workspace:FindFirstChild("IgnoreThese") and Workspace.IgnoreThese:FindFirstChild("Pickups") and Workspace.IgnoreThese.Pickups:FindFirstChild("Weapons")
            if weaponsFolder then
                for _, weapon in ipairs(weaponsFolder:GetChildren()) do
                    if weapon:IsA("Model") or weapon:IsA("Part") then
                        weapon.CFrame = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame or weapon.CFrame
                    end
                end
            end
            task.wait(0.3)
        end
    end)
end

local function stopAutoPickUpWeapons()
    autoPickUpWeaponsLoop = false
end

-- Auto Pick Up Ammo
local function startAutoPickUpAmmo()
    autoPickUpAmmoLoop = true
    task.spawn(function()
        while autoPickUpAmmoLoop do
            local ammoFolder = Workspace:FindFirstChild("IgnoreThese") and Workspace.IgnoreThese:FindFirstChild("Pickups") and Workspace.IgnoreThese.Pickups:FindFirstChild("Ammo")
            if ammoFolder then
                for _, ammo in ipairs(ammoFolder:GetChildren()) do
                    if ammo:IsA("Model") or ammo:IsA("Part") then
                        ammo.CFrame = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame or ammo.CFrame
                    end
                end
            end
            task.wait(0.3)
        end
    end)
end


local function enableRapidFire()
    task.spawn(function()
        while rapidFireLoop do
            for _, v in next, getgc(true) do
                if typeof(v) == 'table' and rawget(v, 'Spread') then
                    pcall(function()
                        rawset(v, 'Spread', 0)
                        rawset(v, 'BaseSpread', 0)
                        rawset(v, 'MinCamRecoil', Vector3.new())
                        rawset(v, 'MaxCamRecoil', Vector3.new())
                        rawset(v, 'MinRotRecoil', Vector3.new())
                        rawset(v, 'MaxRotRecoil', Vector3.new())
                        rawset(v, 'MinTransRecoil', Vector3.new())
                        rawset(v, 'MaxTransRecoil', Vector3.new())
                        rawset(v, 'ScopeSpeed', 100)
                    end)
                end
            end
            task.wait(2)
        end
    end)
end
-- Toggles
LeftGroupbox:AddToggle("ESPChams", {
    Text = "ESP Chams",
    Default = config.ESPChams,
    Tooltip = "Enable chams + ESP highlights",
    Callback = function(Value)
        config.ESPChams = Value
        espLoop = Value
        _G.Disabled = Value
        if Value then 
            -- Disable ESP Only if ESP Chams is enabled
            if config.ESPOnly then
                config.ESPOnly = false
                espOnlyLoop = false
                disableESPOnly()
            end
            enableESP() 
        else 
            disableESP() 
        end
        saveConfig()
    end
})

LeftGroupbox:AddToggle("ESPOnly", {
    Text = "ESP Only",
    Default = config.ESPOnly,
    Tooltip = "Enable ESP highlights without chams",
    Callback = function(Value)
        config.ESPOnly = Value
        espOnlyLoop = Value
        if Value then 
            -- Disable ESP Chams if ESP Only is enabled
            if config.ESPChams then
                config.ESPChams = false
                espLoop = false
                _G.Disabled = false
                disableESP()
            end
            enableESPOnly() 
        else 
            disableESPOnly() 
        end
        saveConfig()
    end
})


LeftGroupbox:AddToggle("HeadLock", {
    Text = "Head Lock",
    Default = config.HeadLock,
    Tooltip = "Lock enemy and mob heads to camera",
    Callback = function(Value)
        config.HeadLock = Value
        headLockLoop = Value
        if Value then enableHeadLock() else disableHeadLock() end
        saveConfig()
    end
})

LeftGroupbox:AddToggle("RapidFire", {
    Text = "Rapid Fire",
    Default = config.RapidFire,
    Tooltip = "Enables reduced spread and recoil repeatedly",
    Callback = function(Value)
        config.RapidFire = Value
        rapidFireLoop = Value
        if Value then enableRapidFire() end
        saveConfig()
    end
})

-- New Aimbot Toggle
LeftGroupbox:AddToggle("AimbotToggle", {
    Text = "Aimbot",
    Default = config.AimbotEnabled,
    Tooltip = "Locks onto heads inside FOV and follows them.",
    Callback = function(Value)
        aimbotEnabled = Value
        config.AimbotEnabled = Value
        saveConfig()
        if Value then
            enableAimbot()
        else
            disableAimbot()
        end
    end
})

-- Aimbot FOV Slider
AddRightGroupbox:AddSlider("AimbotFOVSlider", {
    Text = "Aimbot FOV",
    Default = config.AimbotFOV,
    Min = 20,
    Max = 300,
    Rounding = 0,
    Tooltip = "Adjust aimbot FOV radius",
    Callback = function(Value)
        aimbotFOV = Value
        config.AimbotFOV = Value
        saveConfig()
        AimbotFOVCircle.Radius = aimbotFOV
    end
})

local AutoSpawnToggle = LeftGroupbox:AddToggle("AutoSpawn", {
    Text = "Auto Spawn",
    Default = config.AutoSpawn or false,
    Tooltip = "Automatically respawn when you die",
    Callback = function(Value)
        config.AutoSpawn = Value
        if Value then
            startAutoSpawn()
        else
            stopAutoSpawn()
        end
        saveConfig()
    end
})

local AutoPlaytimeToggle = AddRightGroupbox:AddToggle("AutoPlaytime", {
    Text = "Auto Collect Playtime Award",
    Default = config.AutoPlaytime or false,
    Tooltip = "Automatically collects all playtime rewards",
    Callback = function(Value)
        config.AutoPlaytime = Value
        if Value then
            startAutoPlaytime()
        else
            stopAutoPlaytime()
        end
        saveConfig()
    end
})

AddRightGroupbox:AddToggle("AutoPickUpHeal", {
    Text = "Auto Pick Up Heal",
    Default = config.AutoPickUpHeal,
    Tooltip = "Automatically picks up all heals",
    Callback = function(Value)
        config.AutoPickUpHeal = Value
        if Value then
            startAutoPickUpHeal()
        else
            stopAutoPickUpHeal()
        end
        saveConfig()
    end
})


AddRightGroupbox:AddToggle("AutoPickUpAmmo", {
    Text = "Auto Pick Up Ammo",
    Default = false,
    Tooltip = "Automatically picks up all ammo on the ground",
    Callback = function(Value)
        if Value then
            startAutoPickUpAmmo()
        else
            stopAutoPickUpAmmo()
        end
        saveConfig()
    end
})

AddRightGroupbox:AddToggle("AutoPickUpCoins", {
    Text = "Auto Pick Up Coins",
    Default = config.AutoPickUpCoins or false,
    Tooltip = "Automatically attracts coins within range",
    Callback = function(Value)
        config.AutoPickUpCoins = Value
        if Value then
            startAutoPickUpCoins()
        else
            stopAutoPickUpCoins()
        end
        saveConfig()
    end
})

AddRightGroupbox:AddToggle("AutoOpenChest", {
    Text = "Auto Open Chest",
    Default = config.AutoOpenChest,
    Tooltip = "Automatically opens selected chest repeatedly",
    Callback = function(Value)
        config.AutoOpenChest = Value
        if Value then
            startAutoOpenChest()
        else
            stopAutoOpenChest()
        end
        saveConfig()
    end
})

AddRightGroupbox:AddToggle("AutoSpin", {
    Text = "Auto Spin Wheel",
    Default = config.AutoSpin,
    Tooltip = "Automatically spins the wheel repeatedly",
    Callback = function(Value)
        config.AutoSpin = Value
        if Value then
            startAutoSpin()
        else
            stopAutoSpin()
        end
        saveConfig()
    end
})

AddRightGroupbox:AddDropdown("ChestSelector", {
    Values = { "Wooden", "Bronze", "Silver", "Gold", "Diamond" },
    Default = config.SelectedChest,
    Multi = false,
    Text = "Chest Type",
    Tooltip = "Select which chest to auto open",
    Callback = function(value)
        config.SelectedChest = value
        saveConfig()
    end
})

AddRightGroupbox:AddToggle("AutoPickUpWeapons", {
    Text = "Auto Pick Up Weapons",
    Default = config.AutoPickUpWeapons,
    Tooltip = "Automatically picks up nearby weapons within range",
    Callback = function(Value)
        config.AutoPickUpWeapons = Value
        if Value then
            startAutoPickUpWeapons()
        else
            stopAutoPickUpWeapons()
        end
        saveConfig()
    end
})

local selectedWeaponName = config.SelectedWeaponName or "All"

AddRightGroupbox:AddDropdown("WeaponSelector", {
    Values = { "All", "AK", "M4", "Deagle", "Sniper" },
    Default = config.SelectedWeaponName,
    Multi = false,
    Text = "Weapon Filter",
    Tooltip = "Only pick up this weapon (or All)",
    Callback = function(value)
        config.SelectedWeaponName = value
        selectedWeaponName = value
        saveConfig()
    end
})

task.delay(0.5, function()
    if config.AutoSpawn then startAutoSpawn() end
    if config.AutoPlaytime then startAutoPlaytime() end
    if config.AutoPickUpHeal then startAutoPickUpHeal() end
    if config.AutoPickUpWeapons then startAutoPickUpWeapons() end
    if config.ESPChams then
        espLoop = true
        enableESP()
    end
    if config.ESPOnly then
        espOnlyLoop = true
        enableESPOnly()
    end
    if config.HeadLock then
        headLockLoop = true
        enableHeadLock()
    end
    if config.RapidFire then
        rapidFireLoop = true
        enableRapidFire()
    end
    if config.AutoPickUpCoins then
        autoPickUpCoinsLoop = true
        startAutoPickUpCoins()
    end
    if config.AutoOpenChest then
        autoOpenChestLoop = true
        startAutoOpenChest()
    end
    if config.AutoSpin then
        autoSpinLoop = true
        startAutoSpin()
    end
end)

InfoGroup:AddLabel("Script by: Seisen")
InfoGroup:AddLabel("Version: 1.0.0")
InfoGroup:AddLabel("Game: HyperShot")

InfoGroup:AddButton("Join Discord", function()
    setclipboard("https://discord.gg/F4sAf6z8Ph")
    print("Copied Discord Invite!")
end)

-- Custom Watermark setup (independent of UI scaling)

-- Custom Watermark setup (independent of UI scaling)
local CoreGui = game:GetService("CoreGui")

-- Create independent watermark ScreenGui
local WatermarkGui = Instance.new("ScreenGui")
WatermarkGui.Name = "SeisenWatermark"
WatermarkGui.DisplayOrder = 999999
WatermarkGui.IgnoreGuiInset = true
WatermarkGui.ResetOnSpawn = false
WatermarkGui.Parent = CoreGui

-- Create watermark frame (main container)
local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Name = "WatermarkFrame"
WatermarkFrame.Size = UDim2.new(0, 100, 0, 120) -- Taller container for vertical layout
WatermarkFrame.Position = UDim2.new(0, 10, 0, 100) -- Default position (lower)
WatermarkFrame.BackgroundTransparency = 1 -- Transparent container
WatermarkFrame.BorderSizePixel = 0
WatermarkFrame.Parent = WatermarkGui

-- Create perfect circular logo frame
local CircleFrame = Instance.new("Frame")
CircleFrame.Name = "CircleFrame"
CircleFrame.Size = UDim2.new(0, 60, 0, 60) -- Perfect square = perfect circle
CircleFrame.Position = UDim2.new(0.5, -30, 0, 0) -- Centered horizontally at top
CircleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
CircleFrame.BorderSizePixel = 0
CircleFrame.Parent = WatermarkFrame

-- Create circular corner (makes it a perfect circle)
local WatermarkCorner = Instance.new("UICorner")
WatermarkCorner.CornerRadius = UDim.new(0.5, 0) -- 50% radius = perfect circle
WatermarkCorner.Parent = CircleFrame

-- Create custom logo/image
local WatermarkImage = Instance.new("ImageLabel")
WatermarkImage.Name = "WatermarkImage"
WatermarkImage.Size = UDim2.new(1, 0, 1, 0) -- Fill the entire circle frame
WatermarkImage.Position = UDim2.new(0, 0, 0, 0) -- Cover the entire circle
WatermarkImage.BackgroundTransparency = 1
WatermarkImage.ImageColor3 = Color3.fromRGB(255, 255, 255) -- White tint
WatermarkImage.ScaleType = Enum.ScaleType.Crop -- Crop to fill the circle
WatermarkImage.Parent = CircleFrame

-- Make the image circular to match the frame
local ImageCorner = Instance.new("UICorner")
ImageCorner.CornerRadius = UDim.new(0.5, 0) -- Same circular radius as the frame
ImageCorner.Parent = WatermarkImage

-- Try multiple image formats for better compatibility
local imageFormats = {
    "rbxassetid://121631680891470",
    "http://www.roblox.com/asset/?id=121631680891470",
    "rbxasset://textures/ui/GuiImagePlaceholder.png" -- Fallback image
}

-- Function to try loading the image
local function tryLoadImage()
    for i, imageId in ipairs(imageFormats) do
        WatermarkImage.Image = imageId
        task.wait(0.5)
        if WatermarkImage.AbsoluteSize.X > 0 and WatermarkImage.AbsoluteSize.Y > 0 then
            break
        elseif i == #imageFormats then
            WatermarkImage.Image = ""
            local FallbackText = Instance.new("TextLabel")
            FallbackText.Size = UDim2.new(1, 0, 1, 0)
            FallbackText.Position = UDim2.new(0, 0, 0, 0)
            FallbackText.BackgroundTransparency = 1
            FallbackText.Text = "S"
            FallbackText.TextColor3 = Color3.fromRGB(125, 85, 255) -- Accent color
            FallbackText.TextSize = 24
            FallbackText.Font = Enum.Font.GothamBold
            FallbackText.TextXAlignment = Enum.TextXAlignment.Center
            FallbackText.TextYAlignment = Enum.TextYAlignment.Center
            FallbackText.Parent = CircleFrame
        end
    end
end

-- Try loading the image
task.spawn(tryLoadImage)

-- Create Hub Name text
local HubNameText = Instance.new("TextLabel")
HubNameText.Name = "HubNameText"
HubNameText.Size = UDim2.new(1, 0, 0, 20)
HubNameText.Position = UDim2.new(0, 0, 0, 65) -- Below the circle
HubNameText.BackgroundTransparency = 1
HubNameText.Text = "Seisenhub"
HubNameText.TextColor3 = Color3.fromRGB(255, 255, 255)
HubNameText.TextSize = 14
HubNameText.Font = Enum.Font.GothamBold
HubNameText.TextXAlignment = Enum.TextXAlignment.Center
HubNameText.TextYAlignment = Enum.TextYAlignment.Center
HubNameText.TextStrokeTransparency = 0.5
HubNameText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
HubNameText.Parent = WatermarkFrame

-- Create FPS text
local FPSText = Instance.new("TextLabel")
FPSText.Name = "FPSText"
FPSText.Size = UDim2.new(1, 0, 0, 16)
FPSText.Position = UDim2.new(0, 0, 0, 85) -- Below hub name
FPSText.BackgroundTransparency = 1
FPSText.Text = "60 fps"
FPSText.TextColor3 = Color3.fromRGB(200, 200, 200)
FPSText.TextSize = 12
FPSText.Font = Enum.Font.Code
FPSText.TextXAlignment = Enum.TextXAlignment.Center
FPSText.TextYAlignment = Enum.TextYAlignment.Center
FPSText.TextStrokeTransparency = 0.5
FPSText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
FPSText.Parent = WatermarkFrame

-- Create Ping text
local PingText = Instance.new("TextLabel")
PingText.Name = "PingText"
PingText.Size = UDim2.new(1, 0, 0, 16)
PingText.Position = UDim2.new(0, 0, 0, 101) -- Below FPS
PingText.BackgroundTransparency = 1
PingText.Text = "60 ms"
PingText.TextColor3 = Color3.fromRGB(200, 200, 200)
PingText.TextSize = 12
PingText.Font = Enum.Font.Code
PingText.TextXAlignment = Enum.TextXAlignment.Center
PingText.TextYAlignment = Enum.TextYAlignment.Center
PingText.TextStrokeTransparency = 0.5
PingText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
PingText.Parent = WatermarkFrame

-- Make watermark draggable
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local dragging = false
local dragStart = nil
local startPos = nil

-- Mouse/touch input for dragging and UI toggle
local dragThreshold = 5 -- Pixels moved before considering it a drag
local clickStartPos = nil

-- Global input connections for better drag handling
local inputChangedConnection = nil
local inputEndedConnection = nil

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false -- Reset dragging state
        dragStart = input.Position
        clickStartPos = input.Position
        startPos = WatermarkFrame.Position
        -- Visual feedback - slightly fade the circle frame
        local fadeInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local fadeTween = TweenService:Create(CircleFrame, fadeInfo, {BackgroundTransparency = 0.3})
        fadeTween:Play()
        -- Connect global input events for smooth dragging
        if inputChangedConnection then inputChangedConnection:Disconnect() end
        if inputEndedConnection then inputEndedConnection:Disconnect() end
        inputChangedConnection = UserInputService.InputChanged:Connect(function(globalInput)
            if globalInput.UserInputType == Enum.UserInputType.MouseMovement or globalInput.UserInputType == Enum.UserInputType.Touch then
                if dragStart then
                    local delta = globalInput.Position - dragStart
                    local distance = math.sqrt(delta.X^2 + delta.Y^2)
                    -- Only start dragging if moved beyond threshold
                    if distance > dragThreshold then
                        dragging = true
                        WatermarkFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                end
            end
        end)
        inputEndedConnection = UserInputService.InputEnded:Connect(function(globalInput)
            if globalInput.UserInputType == Enum.UserInputType.MouseButton1 or globalInput.UserInputType == Enum.UserInputType.Touch then
                -- Restore original transparency
                local restoreInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local restoreTween = TweenService:Create(CircleFrame, restoreInfo, {BackgroundTransparency = 0})
                restoreTween:Play()
                -- If it wasn't a drag, treat it as a click to toggle UI
                if not dragging and clickStartPos then
                    local delta = globalInput.Position - clickStartPos
                    local distance = math.sqrt(delta.X^2 + delta.Y^2)
                    if distance <= dragThreshold then
                        if Library and Library.Toggle then
                            Library:Toggle()
                        end
                    end
                end
                -- Reset states and disconnect global events
                dragging = false
                dragStart = nil
                clickStartPos = nil
                if inputChangedConnection then inputChangedConnection:Disconnect() end
                if inputEndedConnection then inputEndedConnection:Disconnect() end
            end
        end)
    end
end

-- Connect only the initial input event to the watermark frame
WatermarkFrame.InputBegan:Connect(onInputBegan)

-- Dynamic watermark with FPS and Ping (completely independent)
local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end

    -- Update custom watermark text
    pcall(function()
        local pingValue = game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue()
        FPSText.Text = math.floor(FPS) .. " fps"
        PingText.Text = math.floor(pingValue) .. " ms"
        -- No need to resize frame - it's now fixed size for vertical layout
    end)
end)

local UISettingsGroupbox = SettingsTab:AddLeftGroupbox("UI Settings")
UISettingsGroupbox:AddButton("Unload Script", function()
    autoSpawnLoop = false
    autoPlaytimeLoop = false
    autoPickUpHealLoop = false
    autoPickUpCoinsLoop = false 
    espLoop = false 
    espOnlyLoop = false
    headLockLoop = false
    rapidFireLoop = false
    autoPickUpWeaponsLoop = false
    autoOpenChestLoop = false
    autoSpinLoop = false -- Added for auto spin
    aimbotEnabled = false
    

    disableESP()
    disableESPOnly()
    disableHeadLock()

    for _, player in Players:GetPlayers() do
        if player.Character then
            for _, v in ipairs(player.Character:GetChildren()) do
                if v:IsA("Highlight") then
                    v:Destroy()
                end
            end
        end
    end

    if MobsFolder then
        for _, mob in MobsFolder:GetChildren() do
            for _, v in ipairs(mob:GetChildren()) do
                if v:IsA("Highlight") then
                    v:Destroy()
                end
            end
        end
    end

    if FOVCircle then
        FOVCircle.Visible = false
        FOVCircle:Remove()
    end

    table.clear(config)
    if isfile(SaveFile) then
        delfile(SaveFile)
    end

    getgenv().HypershotConfig = nil
    _G.HeadSize = nil
    _G.Disabled = nil

    -- Use Obsidian UI Library's proper unload method
    Library:Unload()

    print("✅ Seisen Hub completely unloaded.")
end)
