local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local SharedModules = ReplicatedStorage.Source.Modules
local PlacementObjectData = require(SharedModules.PlacementObjectData)

--// modules
local Modules = script.Parent.Parent.Modules
local MobsModule = require(Modules.Mobs)

local BarricadeClass = {}
BarricadeClass.__index = BarricadeClass

function BarricadeClass.new(Barricade : Model, PlayerClass)
    local self = setmetatable({}, BarricadeClass)

    self.Barricade = Barricade
    self.BarricadeData = PlacementObjectData["Barricades"][Barricade.Name]
   
    self.PlayerClass = PlayerClass
    self.Mobs = PlayerClass.Base:WaitForChild("Mobs")

    self.PlayerDataService = Knit.GetService("PlayerDataService")
    self.BaseSavingService = Knit.GetService("BaseSavingService")

    self.Damaging = {}

    self._janitor = Janitor.new()
    self._janitor:Add(self.Barricade.Destroying:Connect(function()
        self:Destroy()
    end))
    self._janitor:Add(self.Barricade.PrimaryPart.Touched:Connect(function(hit)
        self:Touched(hit)
    end))
    return self
end

function BarricadeClass:Touched(Hit)
    local Model : Model = Hit:FindFirstAncestorOfClass("Model")
    if Model
        and Model:IsDescendantOf(self.Mobs) and self.Barricade
        and not table.find(self.Damaging, self.Mobs) and self.Barricade:FindFirstChild("Health") then
           local Humanoid = Model:FindFirstChild("Humanoid")  
        if Humanoid
            and Humanoid.Health > 0 and self.Barricade.Health.Value > 0 then
            table.insert(self.Damaging, Model)
            local Damage = math.clamp(Humanoid.Health, 0, self.Barricade.Health.Value)
            self.PlayerDataService:AddMoney(self.PlayerClass.Player, math.floor(Damage))
            self.BaseSavingService:DamageItem(self.PlayerClass.Player, self.Barricade, Damage)

            
            if (Humanoid.Health - Damage <= 0)  and MobsModule[Model.Name]
                and MobsModule[Model.Name].DeathReward then
                self.PlayerDataService:AddMoney(self.PlayerClass.Player, MobsModule[Model.Name].DeathReward)
            end
            Humanoid:TakeDamage(Damage)
        end
    end
end


function BarricadeClass:Destroy()
    self.Touching = false
    self._janitor:Cleanup()
end

return BarricadeClass