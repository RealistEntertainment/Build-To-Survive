local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Module = script.Parent.Parent.Modules
local WeaponDataModule = require(Module.WeaponData)

local SwordClass = {}
SwordClass.__index = SwordClass

function SwordClass.new(Weapon : Tool)
    --// make sure we have existing weapon and Base
    if not Weapon then
        return 
    end

    local self = setmetatable({}, SwordClass)

    self.PlayerService = Knit.GetService("PlayerService")
    self.WeaponService = Knit.GetService("WeaponService")

    self.Weapon = Weapon
    self.WeaponData = WeaponDataModule.Swords[self.Weapon.Name]
    
    self.Player = Players.LocalPlayer
    self.Character = self.Player.Character or self.Player.CharacterAdded:Wait()
    self.Humanoid = self.Character:WaitForChild("Humanoid")
    self.Animator = self.Humanoid:WaitForChild("Animator")

    self.SwingAnim = Instance.new("Animation")
    self.SwingAnim.AnimationId = "rbxassetid://8430291859"
    self.SwingAnim.Parent = self.Weapon
    self.SwingAnimTrack = self.Animator:LoadAnimation(self.SwingAnim)

    self.PlayerService.GetPlayerBase():andThen(function(base)
        self.PlayerBase = base
    end):await()

    self.Debounce = false
    self.LastSwing = os.time()

    self.Janitor = janitor.new()
    self.Janitor:Add(Weapon)
    self.Janitor:Add(self.SwingAnim)
    self.Janitor:Add(self.Weapon.Destroying:Connect(function()
        self:CleanUp()
    end))
    self.Janitor:Add(
        self.Weapon.Activated:Connect(function()
            self:Swing()
        end)
    )
    return self
end 

function SwordClass:Swing()
    if os.time() - self.LastSwing >= self.WeaponData.AttackDelay then
        self.LastSwing = os.time()
    else
        return
    end

    print(self.WeaponData, self.WeaponData.AttackRange)
    if self.SwingAnimTrack then
        self.SwingAnimTrack:Play()
    end

    --// Detect if we hit an object in our radius
    local OverLapPara = OverlapParams.new()--// maxparts, BrutforceAllSLow, CollisionGroup, FilterDescendantsIntances
    OverLapPara.FilterType = Enum.RaycastFilterType.Whitelist
    OverLapPara.FilterDescendantsInstances = {self.PlayerBase.Mobs}
    
    --// create a raycast box around sword handle
    local HitParts = workspace:GetPartBoundsInBox(
        CFrame.new(self.Weapon.Handle.Position), 
        Vector3.new(
            self.WeaponData.AttackRange, 
            self.WeaponData.AttackRange, 
            self.WeaponData.AttackRange
        ),
        OverLapPara
    )

    --// find closest HumanoidRootPart
    local closestHRP = nil
    local Dist = 10^5
    for _, Part in ipairs(HitParts) do
        if Part:IsA("BasePart") and Part.Name == "HumanoidRootPart" then
            if (Part.Position - self.Weapon.Handle.Position).Magnitude < Dist then
                Dist = (Part.Position - self.Weapon.Handle.Position).Magnitude
                closestHRP = Part
            end
        end
    end

    print(closestHRP, HitParts)
    if closestHRP then
        --// tell server you have a target
        print("Fired")
        self.WeaponService.Damage(self.Player, closestHRP)
    end
end

function SwordClass:CleanUp()
    if self.janitor then
        self.janitor:Destroy()
    end
end


return SwordClass