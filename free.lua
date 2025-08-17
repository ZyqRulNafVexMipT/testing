local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua'))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Function to fire server events
local function fireServerAsync(func, ...)
    local args = {...}
    local result = pcall(function()
        return func:InvokeServer(unpack(args))
    end)
    if not result then
        warn("Error firing RemoteEvent:", ...)
    end
end

local Window = OrionLib:MakeWindow({
    Name = "VORTX HUB V0.0.1",
    HidePremium = false,
    ShouldClose = true,
    MinSize = Vector2.new(500, 400),
    Folder = "VORTX HUB"
})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

-- Auto Open
MainTab:MakeToggle({
    Name = "Auto Open",
    Default = false,
    Callback = function(state)
        if state then
            local REUnlockCrate = ReplicatedStorage.Modules.Net["RE/UnlockCrate"]
            while wait(0.1) and state do
                fireServerAsync(REUnlockCrate, "Smoothie", "")
            end
        end
    end
})

-- Infinite Money
MainTab:MakeButton({
    Name = "Infinite Money",
    Callback = function()
        local MoneyValue = LocalPlayer.leaderstats.Money
        MoneyValue.Value = math.huge
    end
})

-- Spawn Crate
local function getCrates()
    return {"Smoothie", "Neon", "Gold", "Diamond"} -- List of crates available in the game
end

MainTab:MakeDropdown({
    Name = "Spawn Crate",
    Options = getCrates(),
    Default = {"Smoothie"},
    Callback = function(selectedCrate)
        local RENewCrate = ReplicatedStorage.Modules.Net["RE/NewCrate"]
        fireServerAsync(RENewCrate, selectedCrate[1])
    end
})

-- Run Faster
MainTab:MakeToggle({
    Name = "Run Faster",
    Default = false,
    Callback = function(state)
        if state then
            local Humanoid = LocalPlayer.Character.Humanoid
            Humanoid.WalkSpeed = 40
        else
            local Humanoid = LocalPlayer.Character.Humanoid
            Humanoid.WalkSpeed = 16
        end
    end
})

-- Auto Collect
MainTab:MakeToggle({
    Name = "Auto Collect",
    Default = false,
    Callback = function(state)
        if state then
            local REClientSFX = ReplicatedStorage.Modules.Net["RE/ClientSFX"]
            while wait(0.1) and state do
                fireServerAsync(REClientSFX, "Collect")
            end
        end
    end
})

-- Open Bank (Without GamePass)
MainTab:MakeButton({
    Name = "Open Bank",
    Callback = function()
        local REClientSFX = ReplicatedStorage.Modules.Net["RE/ClientSFX"]
        fireServerAsync(REClientSFX, "Place1")
    end
})

-- 5x Multiple Money (Without GamePass)
local function multiplyMoney()
    local MoneyValue = LocalPlayer.leaderstats.Money
    MoneyValue.Value = MoneyValue.Value * 5
end

MainTab:MakeButton({
    Name = "5x Money",
    Callback = multiplyMoney
})

-- 5x Luck (Without GamePass)
local function increaseLuck()
    local LuckValue = LocalPlayer.leaderstats.Luck
    LuckValue.Value = LuckValue.Value * 5
end

MainTab:MakeButton({
    Name = "5x Luck",
    Callback = increaseLuck
})

-- High Jump
MainTab:MakeToggle({
    Name = "High Jump",
    Default = false,
    Callback = function(state)
        if state then
            local Humanoid = LocalPlayer.Character.Humanoid
            Humanoid.JumpPower = 100
        else
            local Humanoid = LocalPlayer.Character.Humanoid
            Humanoid.JumpPower = 50
        end
    end
})

-- Auto Trade
MainTab:MakeToggle({
    Name = "Auto Trade",
    Default = false,
    Callback = function(state)
        if state then
            local REClientSFX = ReplicatedStorage.Modules.Net["RE/ClientSFX"]
            while wait(0.1) and state do
                fireServerAsync(REClientSFX, "Trade")
            end
        end
    end
})

-- Fly Function
local function fly()
    local Player = game.Players.LocalPlayer
    local Mouse = Player:GetMouse()
    local Plr = game.Players.LocalPlayer
    local Toggles = {Fly = false}
    local Speed = 50
    local Keys = {a = false, d = false, w = false, s = false}
    local function Fly()
        if Toggles.Fly then
            local BodyPosition = Instance.new("BodyPosition", Plr.Character.HumanoidRootPart)
            BodyPosition.Name = "OrionFly"
            BodyPosition.D = 100
            BodyPosition.P = 2000
            BodyPosition.Position = Plr.Character.HumanoidRootPart.Position
            local BodyGyro = Instance.new("BodyGyro", Plr.Character.HumanoidRootPart)
            BodyGyro.Name = "OrionFly"
            BodyGyro.D = 100
            BodyGyro.P = 2000
            BodyGyro.maxTorque = Vector3.new(0, 9000, 0)
            BodyGyro.cframe = Plr.Character.HumanoidRootPart.CFrame
            task.spawn(function()
                while Toggles.Fly do
                    if Keys.w then
                        Plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        BodyPosition.Position = Plr.Character.HumanoidRootPart.Position + (Plr.Character.HumanoidRootPart.CFrame.lookVector * Speed)
                    end
                    if Keys.s then
                        Plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        BodyPosition.Position = Plr.Character.HumanoidRootPart.Position - (Plr.Character.HumanoidRootPart.CFrame.lookVector * Speed)
                    end
                    if Keys.a then
                        Plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        BodyPosition.Position = Plr.Character.HumanoidRootPart.Position - (Plr.Character.HumanoidRootPart.CFrame.rightVector * Speed)
                    end
                    if Keys.d then
                        Plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        BodyPosition.Position = Plr.Character.HumanoidRootPart.Position + (Plr.Character.HumanoidRootPart.CFrame.rightVector * Speed)
                    end
                    task.wait()
                end
            end)
            Mouse.KeyDown:Connect(function(KeyPressed)
                if KeyPressed == "w" then
                    Keys.w = true
                end
                if KeyPressed == "s" then
                    Keys.s = true
                end
                if KeyPressed == "a" then
                    Keys.a = true
                end
                if KeyPressed == "d" then
                    Keys.d = true
                end
            end)
            Mouse.KeyUp:Connect(function(KeyPressed)
                if KeyPressed == "w" then
                    Keys.w = false
                end
                if KeyPressed == "s" then
                    Keys.s = false
                end
                if KeyPressed == "a" then
                    Keys.a = false
                end
                if KeyPressed == "d" then
                    Keys.d = false
                end
            end)
        else
            if Plr.Character.HumanoidRootPart:FindFirstChild("OrionFly") then
                Plr.Character.HumanoidRootPart.OrionFly:Destroy()
            end
        end
    end
    MainTab:MakeToggle({
        Name = "Fly",
        Default = false,
        Callback = function(state)
            Toggles.Fly = state
            Fly()
        end
    })
end

-- Initialize OrionLib
OrionLib:Init()
