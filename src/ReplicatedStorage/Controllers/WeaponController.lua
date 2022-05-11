local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Classes = script.Parent.Parent.Classes
local SwordClass = require(Classes.SwordClass)

local WeaponController = Knit.CreateController{
    Name = "WeaponController",
}
--[[
weld the tool to the players hand.
]]
function WeaponController:Unequip()
    if self.CurrentWeapon
        and self.CurrentWeapon.Weapon.Parent ~= self.Backpack then
        self.CurrentWeapon.Weapon.Parent = self.Backpack
    end
end

function WeaponController:Equip(weapon)
    if self.Player.Character then
        --//equip weapon
        if not self.CurrentWeapon and weapon then
           self.CurrentWeapon = SwordClass.new(weapon) 
        end
        
        if self.CurrentWeapon
            and self.CurrentWeapon.Weapon.Parent ~= self.Player.Character and self.PlacementController.State =="Default" then
           self.CurrentWeapon.Weapon.Parent = self.Player.Character 
        end
    end
end

function WeaponController:KnitInit()
    self.Player = Players.LocalPlayer
    self.Backpack = self.Player:WaitForChild("Backpack")
    self.CurrentWeapon = nil
end

function WeaponController:KnitStart()
    self.PlacementController = Knit.GetController("PlacementController")
    if self.Player.Character then
        repeat
            task.wait()
        until not self.Player.Character or (self.Player:HasAppearanceLoaded() and self.Player.Character:IsDescendantOf(workspace))

        self.Backpack = self.Player:WaitForChild("Backpack")

        --// check if weapon is already in the backpack
        for _, Weapon in pairs(self.Backpack:GetChildren()) do
            if Weapon:IsA("Tool") then
                self:Equip(Weapon)
            end
        end

        --// listen for anything added to backpack
        self.Player:WaitForChild("Backpack").ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                self:Equip(child)
            end
        end)
    end
    


    --// link new backpack
    self.Player.CharacterAdded:Connect(function(Character)
        repeat
            task.wait()
        until not Character or  (self.Player:HasAppearanceLoaded() and self.Player.Character:IsDescendantOf(workspace))
        
        if self.CurrentWeapon then
            self.CurrentWeapon:CleanUp()
            self.CurrentWeapon = nil
        end

        self.Backpack = self.Player:WaitForChild("Backpack")
        
         --// check if weapon is already in the backpack
        for _, Weapon in pairs(self.Backpack:GetChildren()) do
            if Weapon:IsA("Tool") then
                self:Equip(Weapon)
            end
        end
        --// listen for anything added to backpack
        self.Backpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                self:Equip(child)
            end
        end)
    end)
    
end

return WeaponController