local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TycoonClass = require(ServerStorage.Source.Classes.TycoonClass)

local TycoonService = Knit.CreateService {
    Name = "TycoonService",
    Client = {}
}



function TycoonService:AddPlayerTycoon(player: Player)
    local Tycoon = TycoonClass.new(player)
    Tycoon:init()
end


function TycoonService:KnitStart()
    for _, player: Player in ipairs(Players:GetPlayers()) do
        self:AddPlayerTycoon(player)
    end

    Players.PlayerAdded:Connect(function(player: Player)
        self:AddPlayerTycoon(player)
    end)

    Players.PlayerRemoving:Connect(function(player: Player)
       
    end)
end

function TycoonService:KnitInit()
    
end
return TycoonService