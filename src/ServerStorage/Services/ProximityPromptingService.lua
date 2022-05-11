local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ProximityPromptingService = Knit.CreateService{
    Name = "ProximityPromptingService",
    Client = {}

}

function ProximityPromptingService:KnitStart()


 --// if we do intereactions with objects it will be handled here
end

return ProximityPromptingService

