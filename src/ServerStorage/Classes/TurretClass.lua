local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local SharedModules = ReplicatedStorage.Source.Modules
local PlacementObjectData = require(SharedModules.PlacementObjectData)


local TurretClass = {}
TurretClass.__index = TurretClass

function TurretClass.new(Turret : Model, PlayerClass)
    local self = setmetatable({}, TurretClass)

    self.Turret = Turret
    self.TurretData = PlacementObjectData["Turrets"][Turret.Name]
   
    self.PlayerClass = PlayerClass
    self.Mobs = PlayerClass.Base:WaitForChild("Mobs")
  
    self.BrainActive = false

    self.PlayerDataService = Knit.GetService("PlayerDataService")

    self._janitor = Janitor.new()
    self._janitor:Add(self.Turret)
    self:StartBrain()
    return self
end

function TurretClass:PlayAttack(TargetPosition)
    local GunBarrel = self.Turret:FindFirstChild("Gun")
    local Base = self.Turret:FindFirstChild("Base")
    if GunBarrel and Base then
        local rotation : CFrame = CFrame.new(GunBarrel.Position, TargetPosition)
        local RelatativeCenterCFrame = Base.CFrame:ToObjectSpace(GunBarrel.CFrame)
        --// offset the vector to be the look vector 
        local GoalRotation : CFrame = (GunBarrel.CFrame * CFrame.Angles(0, math.pi/2, 0)):Inverse() * rotation 
        local X, Y, Z = GoalRotation:ToEulerAnglesXYZ()
        GunBarrel:PivotTo(
            Base.CFrame
            * CFrame.fromEulerAnglesXYZ(0, Y, 0)
            * RelatativeCenterCFrame

        )
    end
end

function TurretClass:GetClosetsNPC()
    local ClosestNPC = nil
    local Distance = math.huge
    for _, NPC : Model in ipairs(self.Mobs:GetChildren()) do
        if NPC.PrimaryPart then
            if (NPC.PrimaryPart.Position - self.Turret.WorldPivot.Position).Magnitude < Distance and NPC:FindFirstChild("Humanoid")
                and NPC.Humanoid.health > 0 then
               Distance = (NPC.PrimaryPart.Position - self.Turret.WorldPivot.Position).Magnitude
               ClosestNPC = NPC
            end
        end
    end
    return ClosestNPC
end

function TurretClass:StartBrain()
    self.BrainActive = true
    task.spawn(function()
        while self.BrainActive do
            task.wait(self.TurretData.FireRate)
            local ClosestNPC = self:GetClosetsNPC()
            if ClosestNPC then
                local raycastpara = RaycastParams.new()
                local rayResult = workspace:Raycast(self.Turret.WorldPivot.Position, ClosestNPC.PrimaryPart.Position - self.Turret.WorldPivot.Position, raycastpara)
                if rayResult then
                    if rayResult.Instance:IsDescendantOf(ClosestNPC) then
                        print(rayResult.Instance)
                        local Humanoid : Humanoid = ClosestNPC:FindFirstChild("Humanoid")
                        if Humanoid then
                            Humanoid:TakeDamage(self.TurretData.Damage)
                            self.PlayerDataService:AddMoney(self.PlayerClass.Player, math.floor(self.TurretData.Damage))
                            self:PlayAttack(ClosestNPC.PrimaryPart.Position)
                        end
                    end
                end
            end        
        end
    end)
end

function TurretClass:Destroy()
    self.BrainActive = false
    self._janitor:Cleanup()
end

return TurretClass