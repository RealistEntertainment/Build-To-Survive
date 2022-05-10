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

function EnemyClass:BoxCast()
     --// Detect if we hit an object in our radius
     local OverLapPara = OverlapParams.new()--// maxparts, BrutforceAllSLow, CollisionGroup, FilterDescendantsIntances
     OverLapPara.FilterType = Enum.RaycastFilterType.Whitelist
     OverLapPara.FilterDescendantsInstances = {self.Npc.Parent.Parent.Objects, self.Target.Character}

     --// create a raycast box around NPC
     local NpcSize = self.Npc:GetExtentsSize()
     local HitParts = workspace:GetPartBoundsInBox(
         self.Npc.PrimaryPart.CFrame,
         Vector3.new(
             NpcSize.X + self.NpcData.AttackRange,
             NpcSize.Y + self.NpcData.AttackRange, 
             NpcSize.Z + self.NpcData.AttackRange
         ),
         OverLapPara
     )
     
     --// itterate through found parts
     local Models = {}
     local ClosestModel = nil
     local Dist = math.huge
     for _, Part in ipairs(HitParts) do
         local Model : Model = Part:FindFirstAncestorOfClass("Model")
         if Model
            and not table.find(Models,  Model) then
            table.insert(Models, Model)
            if (Model.WorldPivot.Position - self.Npc.WorldPivot.Position).Magnitude < Dist then
                Dist = (Model.WorldPivot.Position - self.Npc.WorldPivot.Position).Magnitude
                ClosestModel = Model
            end
        end
     end

     return ClosestModel
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
                    raycastpara.FilterDescendantsInstances = {self.Npc.Parent.Parent.Objects, self.Target.Character}
                    raycastpara.FilterType = Enum.RaycastFilterType.Whitelist
                    local rayResult = workspace:Raycast(self.Npc.PrimaryPart.Position, Vector3.new(TargetCharacter.PrimaryPart.Position.X, 0, TargetCharacter.PrimaryPart.Position.Z) - Vector3.new(self.Npc.PrimaryPart.Position.X, 0, self.Npc.PrimaryPart.Position.Z),  raycastpara)
                    local Attacked = false
                    if rayResult then
                        --// if target is the players character
                        if rayResult.Instance:IsDescendantOf(TargetCharacter) then
                            if rayResult.Distance < self.NpcData.AttackRange then
                                local Model : Model = rayResult.Instance:FindFirstAncestorOfClass("Model")
                                local Humanoid : Humanoid = Model:FindFirstChild("Humanoid")
                                if Humanoid then
                                    Humanoid:TakeDamage(self.NpcData.PlayerDamage)
                                    self:PlayAttack()
                                    Attacked = true
                                end
                            end
                        elseif rayResult.Instance:IsDescendantOf(self.Npc.Parent.Parent.Objects) then --// target is players object
                            local Model : Model = rayResult.Instance:FindFirstAncestorOfClass("Model")
                            if Model then
                                if rayResult.Distance < self.NpcData.AttackRange then
                                    if Model then
                                        self.BaseSavingService:DamageItem(self.Target, Model, self.NpcData.ObjectDamage)
                                        self:PlayAttack()
                                        Attacked = true
                                    end
                                end 
                            end
                        end
                    end

                     --// if no attack was possible check bounding box for targets
                     if not Attacked then
                        local BoundingTarget = self:BoxCast()
                        if BoundingTarget then
                            if BoundingTarget:IsDescendantOf(TargetCharacter) then
                                local Humanoid : Humanoid = BoundingTarget:FindFirstChild("Humanoid")
                                if Humanoid then
                                    Humanoid:TakeDamage(self.NpcData.PlayerDamage)
                                    Attacked = true
                                end
                            elseif BoundingTarget:IsDescendantOf(self.Npc.Parent.Parent.Objects) then
                                self.BaseSavingService:DamageItem(self.Target, BoundingTarget, self.NpcData.ObjectDamage)
                                Attacked = true
                            end
                        end
                    end

                    --// move to target player
                    if self.Target.Character then
                        self.Humanoid:MoveTo(TargetCharacter.PrimaryPart.Position)
                    end

                    --// if attacked player or object then
                    if Attacked then
                        task.wait(self.NpcData.AttackDelay)
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