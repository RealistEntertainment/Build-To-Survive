--local Players = game:GetService("Players")
--local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ReplicatedModules = ReplicatedStorage.Source.Modules
local PlacementObjectData = require(ReplicatedModules.PlacementObjectData)

local Classes = script.Parent.Parent.Classes
local TurretClass = require(Classes.TurretClass)

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
        if Object and ObjectData then
            --// Make sure player can purchase item
            local isCashRemoved = PlayerDataService:RemoveMoney(player, ObjectData.Cost)
            print(isCashRemoved)
            if isCashRemoved then
                if Category == "Turrets" then
                     --// make sure objects is inside the player bases
                     Object = Object:Clone()
                     Object:PivotTo(ObjectCFrame)
                     Object.Parent = PlayerService.Players[player.UserId].Base.Objects
                     TurretClass.new(Object, PlayerService.Players[player.UserId])
                else
                    --// make sure objects is inside the player bases
                    Object = Object:Clone()
                    Object:PivotTo(ObjectCFrame)
                    Object.Parent = PlayerService.Players[player.UserId].Base.Objects
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
end

function PlacementService:KnitInit()

    Assets = ReplicatedStorage.Assets
end

return PlacementService