local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

--// modules
local Modules = script.Parent.Parent.Modules
local RoundsModule = require(Modules.Rounds)

--// Classes
local Classes = script.Parent.Parent.Classes
local EventClass = require(Classes.EventClass)


local RoundService = Knit.CreateService{
    Name = "RoundService",
    Client = {
        Feedback = Knit.CreateSignal()
    },
}


function RoundService:StartRound()
    local RandomizeRound = math.random(1, #RoundsModule.List)
    local RandomRound = RoundsModule.List[RandomizeRound]
    if RandomRound then
        local Event = EventClass.new(RandomRound)
        Event:StartEvent()
        Event:CleanUp()
    end
end

function RoundService:KnitInit()
    self.RoundJanitor = Janitor.new()
    self.RoundIsStarted = false
    self.DeadPlayers = {}
end

function RoundService:KnitStart()
    --// Start the round service loop
    task.spawn(function()
        while true do
            task.wait()
            if #Players:GetPlayers() >= 1 then
                print("Round service started")
                RoundService:StartRound()
             end
        end
    end)
end

return RoundService