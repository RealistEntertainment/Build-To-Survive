local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Modules = script.Parent.Parent.Modules
local MobsModule = require(Modules.Mobs)

local EnemyClass = {}
EnemyClass.__index = EnemyClass

function EnemyClass.new(Npc : Model, TargetPlayer : Player)
    local self = setmetatable({}, EnemyClass)

    self.Npc = Npc
    self.NpcData = MobsModule[Npc.Name]
    self.Humanoid = self.Npc.Humanoid

    self.BrainActive = false

    self.State = "Idle"

    self.Target = TargetPlayer

    self.BaseSavingService = Knit.GetService("BaseSavingService")

    self._janitor = Janitor.new()
    self._janitor:Add(self.Npc)
    self._janitor:Add(
        self.Humanoid.Died:Connect(function()
        self:Destroy()
    end)
    )
    return self
end

function EnemyClass:PlayAttack()
    local Attack = self.Humanoid.Animator:LoadAnimation(self.Npc.Animations.Attack)
    Attack:Play()
end

function EnemyClass:StartBrain()
    self.BrainActive = true
    task.spawn(function()
        while self.BrainActive do
            task.wait(.1)
            if self.Target and self.Npc:IsDescendantOf(workspace) then
            local TargetCharacter = self.Target.Character
                if TargetCharacter
                    and TargetCharacter.PrimaryPart then
                    local raycastpara = RaycastParams.new()
                    raycastpara.FilterDescendantsInstances = {self.Npc.Parent}
                    raycastpara.FilterType = Enum.RaycastFilterType.Blacklist
                    local rayResult = workspace:Raycast(self.Npc.PrimaryPart.Position, TargetCharacter.PrimaryPart.Position - self.Npc.PrimaryPart.Position,  raycastpara)
                    if rayResult then
                        --// if target is the players character
                        if rayResult.Instance:IsDescendantOf(TargetCharacter) then
                            if rayResult.Distance < self.NpcData.AttackRange then
                                local Model : Model = rayResult.Instance:FindFirstAncestorOfClass("Model")
                                local Humanoid : Humanoid = Model:FindFirstChild("Humanoid")
                                if Humanoid then
                                    Humanoid:TakeDamage(self.NpcData.PlayerDamage)
                                    self:PlayAttack()
                                    task.wait(self.NpcData.AttackDelay)
                                end
                            else
                                self.Humanoid:MoveTo(TargetCharacter.PrimaryPart.Position) 
                            end
                        elseif rayResult.Instance:IsDescendantOf(self.Npc.Parent.Parent.Objects) then --// target is players object
                            local Model : Model = rayResult.Instance:FindFirstAncestorOfClass("Model")
                            if Model then
                                if rayResult.Distance < self.NpcData.AttackRange then
                                    if Model then
                                        self.BaseSavingService:DamageItem(self.Target, Model, self.NpcData.ObjectDamage)
                                        self:PlayAttack()
                                        task.wait(self.NpcData.AttackDelay)
                                    end
                                else
                                    self.Humanoid:MoveTo(Model.WorldPivot.Position) 
                                end 
                            end
                        end

                    end
                end
            end
        end
    end)
end

function EnemyClass:Destroy()
    self.BrainActive = false
    self._janitor:Cleanup()
end

return EnemyClass