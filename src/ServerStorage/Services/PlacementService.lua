--local Players = game:GetService("Players")
--local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ReplicatedModules = ReplicatedStorage.Source.Modules
local PlacementObjectData = require(ReplicatedModules.PlacementObjectData)

local Classes = script.Parent.Parent.Classes
local TurretClass = require(Classes.TurretClass)
local BarricadeClass = require(Classes.BarricadeClass)
local DoorClass = require(Classes.DoorClass)
local HatchClass = require(Classes.HatchClass)

local Modules = script.Parent.Parent.Modules
local ProximityPromptModule = require(Modules.ProximityPrompt)

local Assets

local PlacementService = Knit.CreateService {
    Name = "PlacementService",
    Client = {
    }
}

function PlacementService.Client:PlaceObject(player : Player, ObjectName, ObjectCFrame, Category)
    return self.Server:PlaceObject(player, ObjectName, ObjectCFrame, Category)
end

function PlacementService:PlaceObject(player : Player, ObjectName, ObjectCFrame, Category)
    if tostring(ObjectName) and type(ObjectCFrame) == "userdata" then
        local Object = Assets.PlacementObjects:FindFirstChild(ObjectName)
        local ObjectData = PlacementObjectData[Category][ObjectName]
        --// this checks if the category is owned and requires a purchase
        local OwnsCategory = if PlacementObjectData.CategoryPurchaseRequire[Category] then GamepassService:UserOwnsPass(player, Category) else true
        if Object and ObjectData and OwnsCategory then
            --// make sure the object isn't intersecting others
            local OverLapPara = OverlapParams.new()
            OverLapPara.FilterType = Enum.RaycastFilterType.Whitelist
            OverLapPara.FilterDescendantsInstances = {PlayerService.Players[player.UserId].Base.Objects}

            local HitParts = workspace:GetPartBoundsInBox(
                ObjectCFrame,
                Vector3.new(Object.PrimaryPart.Size.X/2, Object.PrimaryPart.Size.Y/2, Object.PrimaryPart.Size.Z/2),
                OverLapPara
            )

            for _, Part in ipairs(HitParts) do
                local Model = Part:FindFirstAncestorOfClass("Model")
                if Model
                    and Model ~= self.SelectedObject then
                        return
                end
            end

            --// Make sure player can purchase item
            local isCashRemoved = PlayerDataService:RemoveMoney(player, ObjectData.Cost)
            print(isCashRemoved)
            if isCashRemoved then
                --// make sure objects is inside the player bases
                Object = Object:Clone()
                Object:PivotTo(ObjectCFrame)
                Object.Parent = PlayerService.Players[player.UserId].Base.Objects

                local ProximityPrompt = ProximityPromptModule.ObjectPrompt()
                ProximityPrompt.Parent = Object

                if string.find(Object.Name, "Turret")then
                    TurretClass.new(Object, PlayerService.Players[player.UserId])
                elseif string.find(Object.Name, "Barricade") then
                    BarricadeClass.new(Object, PlayerService.Players[player.UserId])
                elseif string.find(Object.Name, "Door") then
                    ProximityPrompt.Name = "DoorPrompt"
                    DoorClass.new(Object, PlayerService.Players[player.UserId])
                elseif string.find(Object.Name, "Hatch") then
                    ProximityPrompt.Name = "DoorPrompt"
                    HatchClass.new(Object, PlayerService.Players[player.UserId])
                end
                BaseSavingService:AddItem(player, Object, Category, PlayerService.Players[player.UserId].Base)
            end

         end
    end
end

function PlacementService.Client:DestroyObject(player : Player, Object)
    BaseSavingService:RemoveItem(player, Object)
end

function PlacementService:KnitStart()
    PlayerService = Knit.GetService("PlayerService")
    BaseSavingService = Knit.GetService("BaseSavingService")
    PlayerDataService = Knit.GetService("PlayerDataService")
    GamepassService = Knit.GetService("GamepassService")
end

function PlacementService:KnitInit()

    Assets = ReplicatedStorage.Assets
end

return PlacementService