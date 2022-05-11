local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")


local Knit = require(ReplicatedStorage.Packages.Knit)
local ProfileService = require(ServerStorage.Source.Services.ProfileService)
local PlayerService

local config = require(script.config)

local PlayerDataService = Knit.CreateService{
    Name = "PlayerDataService",
    Client = {
        CashUpdate = Knit.CreateSignal(),
        PlayerDataIsReady = Knit.CreateSignal(),
    }
}

local DataStoreSettings = config.DataStoreSettings

local ProfileStore = ProfileService.GetProfileStore("PlayerDataV1", DataStoreSettings.ProfileStoreTemplate)
if RunService:IsStudio() == true then
  --  ProfileStore = ProfileStore.Mock
end

function PlayerDataService.Client:GetData(player: Player)
    if self.Server.CachedProfiles[player] then
        return self.Server.CachedProfiles[player].Data
    else
        repeat
            task.wait()
        until not player or self.Server.CachedProfiles[player]
        if self.Server.CachedProfiles[player] then
            return self.Server.CachedProfiles[player].Data
        end
    end
    return nil
end

function PlayerDataService:GetData(player: Player)
    if self.CachedProfiles[player] then
        return self.CachedProfiles[player].Data
    else
        repeat
            task.wait()
        until not player or self.CachedProfiles[player]
        if self.CachedProfiles[player] then
            return self.CachedProfiles[player].Data
        end
    end
    return nil
end

--// fired from weaponservice on purchase
function PlayerDataService:AddWeapon(player : Player, Weapon : string, Category)
    local Profile = self.CachedProfiles[player]
    if Profile then
        Profile.Data.Weapons[Weapon] = {
            Category = Category
        }
        Profile.Data.CurrentWeapon = Weapon
    end
end

--// fired from weaponservice on equip
function PlayerDataService:EquipWeapon(player : Player, Weapon : string)
    local Profile = self.CachedProfiles[player]
    if Profile then
        Profile.Data.CurrentWeapon = Weapon
    end
end

function PlayerDataService:RemoveMoney(player: Player, amount : number)
    local Profile = self.CachedProfiles[player]
    local isSuccessful : boolean = false
    if Profile and tonumber(amount) then
        if (Profile.Data.Cash - amount) >= 0 then
            isSuccessful = true
            Profile.Data.Cash -= amount
            self.Client.CashUpdate:Fire(player, Profile.Data.Cash)
        end
    end
    return isSuccessful
end

function PlayerDataService:AddMoney(player: Player, amount : number)
    local Profile = self.CachedProfiles[player]
    if Profile and tonumber(amount) then
        local DoubleMoneyPass = self.GamepassService:UserOwnsPass(player, 44188735)
        if DoubleMoneyPass then
            Profile.Data.Cash += (amount * 2)
        else
            Profile.Data.Cash += amount
        end
        self.Client.CashUpdate:Fire(player, Profile.Data.Cash)
    end
end

function PlayerDataService:PlayerLoaded(player, Profile)
    if Profile then
        self.Client.CashUpdate:Fire(player, Profile.Data.Cash)
    end
end

function PlayerDataService:PlayerAdded(player : Player)
    local Profile = ProfileStore:LoadProfileAsync("Player_"..player.UserId, "ForceLoad")
    if Profile ~= nil then
        Profile:AddUserId(player.UserId) -- GDPR compliance
        Profile:Reconcile() -- Fill in missing variables from ProfileTemplate
        Profile:ListenToRelease(function()
            self.CachedProfiles[player] = nil
            player:Kick("Your profile has been loaded in another server. Please rejoin.")
        end)

        if player:IsDescendantOf(Players) then -- loaded data
            self.CachedProfiles[player] = Profile
            PlayerDataService:PlayerLoaded(player, Profile)
        else
            Profile:Release()
        end
    else
        player:Kick("Unable to load data. Please rejoin.")
    end
end

function PlayerDataService:KnitInit()
    self.GamepassService = Knit.GetService("GamepassService")
    self.CachedProfiles = {}
end

function PlayerDataService:KnitStart()
    --// Check if players already in
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function()
            self:PlayerAdded(player)
        end)
    end

    Players.PlayerAdded:Connect(function(player : Player)
        self:PlayerAdded(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        local Profile = self.CachedProfiles[player]
        if Profile then
            Profile:Release()
        end
    end)

    self.util = require(script.util)
    MarketplaceService.ProcessReceipt = self.util.ProcessReceipt 
end
 

return PlayerDataService