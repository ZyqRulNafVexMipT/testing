local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua'))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local function fireServerAsync(func, ...)
    local args = {...}
    local result = pcall(function()
        return func:InvokeServer(unpack(args))
    end)
    if not result then
        warn("Error firing RemoteEvent:", ...)
    end
end

-- Auto Open
local AutoOpenToggle = MainTab:MakeToggle({
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
local InfiniteMoneyButton = MainTab:MakeButton({
    Name = "Infinite Money",
    Callback = function()
        local MoneyValue = game.Players.LocalPlayer.leaderstats.Money
        MoneyValue.Value = math.huge
    end
})

-- Spawn Crate
local function getCrates()
    return {"Smoothie", "Neon", "Gold", "Diamond"} -- Daftar crate yang ditemukan di game
end

local CrateDropdown = MainTab:MakeDropdown({
    Name = "Spawn Crate",
    Options = getCrates(),
    Default = {"Smoothie"},
    Callback = function(selectedCrate)
        local RENewCrate = ReplicatedStorage.Modules.Net["RE/NewCrate"]
        fireServerAsync(RENewCrate, selectedCrate[1])
    end
})

-- Run Faster
local RunFasterToggle = MainTab:MakeToggle({
    Name = "Run Faster",
    Default = false,
    Callback = function(state)
        if state then
            local Humanoid = game.Players.LocalPlayer.Character.Humanoid
            Humanoid.WalkSpeed = 40
        else
            local Humanoid = game.Players.LocalPlayer.Character.Humanoid
            Humanoid.WalkSpeed = 16
        end
    end
})

-- Auto Collect
local AutoCollectToggle = MainTab:MakeToggle({
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
local OpenBankButton = MainTab:MakeButton({
    Name = "Open Bank",
    Callback = function()
        local REClientSFX = ReplicatedStorage.Modules.Net["RE/ClientSFX"]
        fireServerAsync(REClientSFX, "Place1")
    end
})

-- 5x Multiple Money (Without GamePass)
local function multiplyMoney()
    local MoneyValue = game.Players.LocalPlayer.leaderstats.Money
    MoneyValue.Value = MoneyValue.Value * 5
end

local MultiplyMoneyButton = MainTab:MakeButton({
    Name = "5x Money",
    Callback = multiplyMoney
})

-- 5x Luck (Without GamePass)
local function increaseLuck()
    local LuckValue = game.Players.LocalPlayer.leaderstats.Luck
    LuckValue.Value = LuckValue.Value * 5
end

local IncreaseLuckButton = MainTab:MakeButton({
    Name = "5x Luck",
    Callback = increaseLuck
})

-- High Jump
local HighJumpToggle = MainTab:MakeToggle({
    Name = "High Jump",
    Default = false,
    Callback = function(state)
        if state then
            local Humanoid = game.Players.LocalPlayer.Character.Humanoid
            Humanoid.JumpPower = 100
        else
            local Humanoid = game.Players.LocalPlayer.Character.Humanoid
            Humanoid.JumpPower = 50
        end
    end
})

-- Auto Trade
local AutoTradeToggle = MainTab:MakeToggle({
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

OrionLib:Init()
