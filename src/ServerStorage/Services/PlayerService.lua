local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Classes = ServerStorage.Source.Classes
local PlayerClass = require(Classes.PlayerClass)

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService = Knit.CreateService{
    Name = "PlayerService",
    Client = {
        CharacterDied = Knit.CreateSignal(),
    },
}
function PlayerService.Client:GetPlayerBase(player : Player)
    local Base = nil
    if self.Server.Players[player.UserId]
     and self.Server.Players[player.UserId].Base  then
         Base = self.Server.Players[player.UserId].Base 
    end 
    return Base
end

function  PlayerService:SetBase(player : Player, Base)
    if self.Players[player.UserId] then
        self.Players[player.UserId].Base = Base
    end
end

function PlayerService:SetSpawnPosition(player : Player, Position : Vector3)
    if self.Players[player.UserId] then
        self.Players[player.UserId].SpawnPosition = Position
    end
end

--// tell services that need to know player died
function PlayerService:PlayerDied(player : Player)
    --// Update round service
    if not RoundService.DeadPlayers[player] and RoundService.RoundIsStarted then
        table.insert(RoundService.DeadPlayers, player)
    end
end


function PlayerService:KnitInit()
    self.Players = {}

    for _, player : Player in ipairs(Players:GetPlayers()) do
        print("Creating Player Class")
        self.Players[player.UserId] = PlayerClass.new(player)
        self.Players[player.UserId].CharacterDied:Connect(function()
            self.PlayerDied:Fire(player)
        end)
    end

    Players.PlayerAdded:Connect(function(player: Player)
        print("Create Player Class")
        self.Players[player.UserId] = PlayerClass.new(player)
        
        print(self.Players)
    end)
    Players.PlayerRemoving:Connect(function(player)
        if self.Players[player.UserId] then
            self.Players[player.UserId]:Destroy()
            self.Players[player.UserId] = nil
        end
    end)
end

function PlayerService:KnitStart()
   RoundService = Knit.GetService("RoundService")
end



return PlayerService