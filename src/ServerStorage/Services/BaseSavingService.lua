local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local SharedModules = ReplicatedStorage.Source.Modules
local PlacementObjectData = require(SharedModules.PlacementObjectData)

local Modules = script.Parent.Parent.Modules
local ProximityPromptModule = require(Modules.ProximityPrompt)

local Knit = require(ReplicatedStorage.Packages.Knit)
local ProfileService = require(ServerStorage.Source.Services.ProfileService)
local PlayerService

local Classes = script.Parent.Parent.Classes
local TurretClass = require(Classes.TurretClass)
local BarricadeClass = require(Classes.BarricadeClass)
local DoorClass = require(Classes.DoorClass)
local HatchClass = require(Classes.HatchClass)

local BaseSavingService = Knit.CreateService{
    Name = "BaseSavingService",
    Client = {}
}

local DataStoreSettings = {
    ProfileStoreTemplate = {
        Base = {}
    },
}
local ProfileStore = ProfileService.GetProfileStore("BaseDataV1.1", DataStoreSettings.ProfileStoreTemplate)
if RunService:IsStudio() == true then
   -- ProfileStore = ProfileStore.Mock
end


function BaseSavingService:GetID(player, base)
    local Profile = self.CachedProfiles[player]
    local Objects = base.Objects:GetChildren()
    if not Profile.Data.Base[#Objects+1] then --// if object count + 1 is open then return ID
        return tostring(#Objects+1)
    else
        for i = 1, #Objects do
            if not Profile.Data[i] then --// if data is open for this ID the return it
                return tostring(i)
            end
        end
    end
    return nil
end

function BaseSavingService:AddItem(player: Player, Item : Model, Category,  Base)
    if player and Item and Base then
        local Profile = self.CachedProfiles[player]
        if Profile
            and Profile.Data then
            local ID = BaseSavingService:GetID(player, Base)
            if ID then
                Profile.Data.Base[ID] = {
                    Name = Item.Name,
                    CFrame = {(Base.Baseplate.CFrame:ToObjectSpace(Item.WorldPivot)):GetComponents()},
                    Category = Category,
                    Health = PlacementObjectData[Category][Item.Name].Health
                }
                local Health = Instance.new("NumberValue")
                Health.Parent = Item
                Health.Name = "Health"
                Health.Value = PlacementObjectData[Category][Item.Name].Health or 1

                local ItemID = Instance.new("StringValue")
                ItemID.Parent = Item
                ItemID.Name = "ID"
                ItemID.Value = ID
            else
                assert(false, "Failed to create object ID")
            end
         end
    end
end

function BaseSavingService:RemoveItem(player: Player, Item : Model)
    if player and Item then
        local Profile = self.CachedProfiles[player]
        if Profile then
            local ID = Item:FindFirstChild("ID")
            if ID then
                Profile.Data.Base[ID.Value] = nil
            else
                assert(false, "Failed to find object ID")
            end
            Debris:AddItem(Item, 0)
        end
    end
end

function BaseSavingService:DamageItem(player: Player, Item : Model, Amount : number)
    if player and Item and tonumber(Amount) then
        local Profile = self.CachedProfiles[player]
        if Profile then
            local ID = Item:FindFirstChild("ID")
            local Health = Item:FindFirstChild("Health")
            if ID and Health then
                local ItemData = Profile.Data.Base[ID.Value]
                if ItemData then
                    if ItemData.Health - Amount > 0 then
                        Health.Value -= Amount
                        Profile.Data.Base[ID.Value].Health = Health.Value
                    else
                        Profile.Data.Base[ID.Value] = nil
                        Debris:AddItem(Item, 0)
                    end
                end
            else
                task.spawn(function()
                  assert(false, "Failed to find object ID")  
                end)
            end
        end
    end
end

function BaseSavingService:LoadPlayerBase(player : Player)
    local Profile = self.CachedProfiles[player]
    print(Profile.Data.Base)
    local ObjectData = Profile.Data.Base
    --// Find open bases
    local OpenBase = self.OpenBases[1]
    
    --// remove it from openbases as soon as you get the base 
    table.remove(self.OpenBases, 1) 
    self.ClaimedBases[player] = OpenBase
    
    local Base = workspace.Bases[OpenBase]
    --// Set Players spawn, Set Basename to playerservice
    print(PlayerService)
    PlayerService:SetSpawnPosition(player, Base.Baseplate.Position + Vector3.new(0,5,0))
    PlayerService:SetBase(player, Base)

    --// load objects in to the base
    for ID, ItemData in pairs(ObjectData) do
        local Item = ReplicatedStorage.Assets.PlacementObjects:FindFirstChild(ItemData.Name)
        if Item then
            Item = Item:Clone()
            Item:PivotTo(Base.Baseplate.CFrame:ToWorldSpace(CFrame.new(unpack(ItemData.CFrame))))
            Item.Parent = Base.Objects

            local Health = Instance.new("NumberValue")
            Health.Parent = Item
            Health.Name = "Health"
            Health.Value = ItemData.Health or PlacementObjectData[ItemData.Category][ItemData.Name].Health

            local ItemID = Instance.new("StringValue")
            ItemID.Parent = Item
            ItemID.Name = "ID"
            ItemID.Value = ID

            local ProximityPrompt = ProximityPromptModule.ObjectPrompt()
            ProximityPrompt.Parent = Item

            if string.find(ItemData.Name, "Turret")then
                TurretClass.new(Item, PlayerService.Players[player.UserId])
            elseif string.find(ItemData.Name, "Barricade") then
                BarricadeClass.new(Item, PlayerService.Players[player.UserId])
            elseif string.find(ItemData.Name, "Door") then
                ProximityPrompt.Name = "DoorPrompt"
                DoorClass.new(Item, PlayerService.Players[player.UserId])
            elseif string.find(ItemData.Name, "Hatch") then
                ProximityPrompt.Name = "DoorPrompt"
                HatchClass.new(Item, PlayerService.Players[player.UserId])
            end
        end
    end

    --// Important.. The character must load this first time to start the playerclass(respawning)
    if player then
        player:LoadCharacter()
    end
end


function BaseSavingService:PlayerAdded(player: Player)
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
			self:LoadPlayerBase(player)
		else
			Profile:Release()
		end
	else
		player:Kick("Unable to load data. Please rejoin.")
	end
end

function BaseSavingService:KnitStart()
    self.CachedProfiles = {}
    self.OpenBases = {"Base1", "Base2", "Base3", "Base3", "Base4", "Base5", "Base6"}
    self.ClaimedBases = {}

    PlayerService = Knit.GetService("PlayerService")
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
    
        --// Add base back to open bases and remove it from claimed bases, Clear out base objects
        table.insert(self.OpenBases, self.ClaimedBases[player])
        workspace.Bases[self.ClaimedBases[player]].Objects:ClearAllChildren()
        self.ClaimedBases[player] = nil
    end)
end

return BaseSavingService
