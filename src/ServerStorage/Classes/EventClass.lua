local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = script.Parent.Parent.Modules
local RoundsModule = require(Modules.Rounds)

--//Assets
local ServerAssets = ServerStorage.Assets
--// Classes
local Classes = script.Parent.Parent.Classes
local EnemyClass = require(Classes.EnemyClass)
local MeteorClass = require(Classes.MeteorClass)

local Knit = require(ReplicatedStorage.Packages.Knit)
local EventClass = {}
EventClass.__index = EventClass

function EventClass.new(Event)
    if RoundsModule[Event]
        and RoundsModule[Event].EventType then

        local self = setmetatable({}, EventClass)

        self.EventData = RoundsModule[Event]

        self.RoundService = Knit.GetService("RoundService")
        self.PlayerService = Knit.GetService("PlayerService")
        self.PlayerDataService = Knit.GetService("PlayerDataService")

        return self
    else
        assert(false, "EventClass couldn't find Event or EventType")
        return nil
    end
end

function EventClass:Intermission()
    self.RoundService.Client.Feedback:FireAll(true, "Picking Random Round!")
    task.wait(3)
    self.RoundService.Client.Feedback:FireAll(true, self.EventData.Announcement)
    for i = 1, 30 do
        task.wait(1)
        self.RoundService.Client.Feedback:FireAll(true, "Round starting in..." .. 15 - i)
    end
end

function EventClass:StartEvent()

    --// announce intermission
    self:Intermission()

    --// handle spawning event stuff for each player
    for _, PlayerClass in pairs(self.PlayerService.Players) do
        local Base = PlayerClass.Base
        if Base then
            if self.EventData.EventType == "MobSpawning" then
                self.Npc = {}
                local Npc = ServerAssets.Mobs:FindFirstChild(self.EventData.NpcModel)
                for i = 1, self.EventData.NpcCount do
                    local newNpc = Npc:Clone()
                    newNpc.Parent = Base.Mobs
                    newNpc:PivotTo(Base.MobSpawner.CFrame)
                    self.Npc[i] = EnemyClass.new(newNpc, PlayerClass.Player)
                    self.Npc[i]:StartBrain()
                end 
            elseif self.EventData.EventType == "MeteorShower" then
                self.Meteor = {}
                local Meteor = ServerAssets.EventObjects:FindFirstChild(self.EventData.MeteorModel) 
                if Meteor then
                    local WaitTimeForMeteor = ((self.EventData.RoundTime - 5) / self.EventData.Meteors)
                    task.spawn(function()
                        for i = 1, self.EventData.Meteors do
                            task.wait(WaitTimeForMeteor)
                            task.spawn(function()
                                MeteorClass.new(Meteor,PlayerClass.Player, Base, self.EventData.MeteorDamage)
                            end)
                        end
                    end)
                end
            end
        end
    end

    --// event timer
    for i = 1, self.EventData.RoundTime  do
        task.wait(1)
        self.RoundService.Client.Feedback:FireAll(true, "Time Left..." .. self.EventData.RoundTime - i)
    end

    --// round over remove npc and award alive players
end


function EventClass:CleanUp()
    self.RoundService.Client.Feedback:FireAll(false)

    --// remove npc
    if self.Npc ~= nil then
        print(self.Npc)
        for idx, NpcClass in pairs(self.Npc) do
            NpcClass:Destroy()
        end
        self.Npc = {}
    end

    --// Award players
    for _, PlayerClass in pairs(self.PlayerService.Players) do
        if not self.RoundService.DeadPlayers[PlayerClass.Player] then
            self.PlayerDataService:AddMoney(PlayerClass.Player, self.EventData.Award)
        end
    end
end

return EventClass