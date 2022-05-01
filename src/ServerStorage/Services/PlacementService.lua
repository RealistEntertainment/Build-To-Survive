--local Players = game:GetService("Players")
--local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)



local PlacementService = Knit.CreateService {
    Name = "PlacementService",
    Client = {}
}




function PlacementService:KnitStart()

end

function PlacementService:KnitInit()

end

return PlacementService