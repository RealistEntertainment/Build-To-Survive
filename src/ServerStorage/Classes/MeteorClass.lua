local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit  = require(ReplicatedStorage.Packages.Knit)


local MeteorClass = {}
MeteorClass.__index = MeteorClass

--// spawn object in. make a black circle where the object is going to land then wait a few seconds and spawn it

function MeteorClass.new(Meteor : BasePart, Player, TargetBase : Folder, Damage : number)
    if not Meteor then return end
    local self = setmetatable({}, MeteorClass)
    self.Meteor = Meteor:Clone()
    self.Damage = Damage
    self.Player = Player
    self.TargetBase = TargetBase

    --// service
    self.BaseSavingService= Knit.GetService("BaseSavingService")

    self:CastShadow()
    return self
end

function MeteorClass:CastShadow()
    self.Baseplate = self.TargetBase:FindFirstChild("Baseplate")
    if self.Baseplate then
        local ShadowPart : Part = Instance.new("Part")
        ShadowPart.Shape = Enum.PartType.Cylinder.Name
        ShadowPart.Anchored = true
        ShadowPart.Parent = workspace
        ShadowPart.Size = Vector3.new(.1,self.Meteor.Size.Y,self.Meteor.Size.Z)
        ShadowPart.Orientation = Vector3.new(0,0,90)
        ShadowPart.Transparency = .5
        ShadowPart.Color = Color3.fromRGB(0,0,0)

        local RandomPosition = Vector3.new(
            math.random(-self.Baseplate.Size.X/2,self.Baseplate.Size.X/2),
            self.Baseplate.Size.Y + 150,
            math.random(-self.Baseplate.Size.Z/2,self.Baseplate.Size.Z/2)
        )
        self.TargetPosition = RandomPosition
        local RaycastParam = RaycastParams.new()
        RaycastParam.FilterType = Enum.RaycastFilterType.Whitelist
        RaycastParam.FilterDescendantsInstances = {self.TargetBase.Objects, self.Baseplate}

        local ShadowRayCast = workspace:Raycast(self.Baseplate.Position + RandomPosition, -Vector3.new(0,200,0), RaycastParam)
        if ShadowRayCast then
            ShadowPart.Position = ShadowRayCast.Position
        end

        self.ShadowPart = ShadowPart
        task.wait(1)
        self:FireMeteor()
    end
end

function MeteorClass:FireMeteor()
    self.Meteor.Position = self.TargetPosition + self.Baseplate.Position
    self.Meteor.Parent = workspace
    local RaycastParam = RaycastParams.new()
    RaycastParam.FilterType = Enum.RaycastFilterType.Whitelist
    RaycastParam.FilterDescendantsInstances = {self.TargetBase.Objects, self.Baseplate}

    local GoalPosition = self.TargetPosition + self.Baseplate.Position
    local MeteorRayCast = workspace:Raycast(self.Baseplate.Position + self.TargetPosition, -Vector3.new(0,200,0), RaycastParam)
    if MeteorRayCast then
        GoalPosition = MeteorRayCast.Position
    end

    --//Tween ball 
    local TweenInf = TweenInfo.new(
        .2,
        Enum.EasingStyle.Exponential,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    local Tween : Tween = TweenService:Create(self.Meteor, TweenInf, {Position = GoalPosition})
    Tween:Play()
    Tween.Completed:Wait()

    --// Detect if we hit an object in our radius
    local OverLapPara = OverlapParams.new()--// maxparts, BrutforceAllSLow, CollisionGroup, FilterDescendantsIntances

    --// create a raycast box around sword handle
    local HitParts = workspace:GetPartBoundsInBox(
    CFrame.new(GoalPosition), 
    Vector3.new(
        self.Meteor.Size.X, 
        self.Meteor.Size.Y, 
        self.Meteor.Size.Z
    ),
    OverLapPara
    )
    
    local DamagedObjects = {}
    for _, Child in ipairs(HitParts) do
        if Child:IsDescendantOf(self.TargetBase.Objects) then
            local Object : Model = Child:FindFirstAncestorOfClass("Model")
            if Object 
                and not table.find(DamagedObjects, Object) then
                table.insert(DamagedObjects, Object)
                self.BaseSavingService:DamageItem(self.Player, Object, self.Damage)
                print("Damaged", Object)
            end
        elseif Child.Name == "HumanoidRootPart"
            and not table.find(DamagedObjects, Child.Parent) then
            table.insert(DamagedObjects, Child.Parent)
            local Player = Players:GetPlayerFromCharacter(Child.Parent)
            if Player then
                local Hum = Child.Parent:FindFirstChild("Humanoid")
                if Hum then
                    Hum:TakeDamage(math.huge)
                end
            end
        end
    end



    self.ShadowPart:Destroy()
    self.Meteor:Destroy()
end

function MeteorClass:CleanUP()
    
end

return MeteorClass

