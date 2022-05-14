local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

--// modules
local Modules = script.Parent.Parent.Modules
local MobsModule = require(Modules.Mobs)

local WeaponService = Knit.CreateService{
    Name = "WeaponService",
    Client = {}
}

function WeaponService.Client:HandleWeapon(player : Player, Weapon, weaponCategory)
    local CachedPlayer = self.Server.PlayerDataService.CachedProfiles[player]
    print(CachedPlayer)
    if CachedPlayer
        and CachedPlayer.Data 
        and CachedPlayer.Data.Weapons and tostring(Weapon) then
        local CurrentWeapon = CachedPlayer.Data.CurrentWeapon
        local newWeaponData = self.Server.WeaponData[weaponCategory][Weapon]
        print(CurrentWeapon, newWeaponData)
        if CurrentWeapon ~= Weapon and newWeaponData then
            print(CachedPlayer.Data.Weapons[Weapon])
            if not CachedPlayer.Data.Weapons[Weapon] then --// if item doesn't exit in data then buy it
                local isBought = self.Server.PlayerDataService:RemoveMoney(player,newWeaponData.Cost)
                print(isBought)
                if isBought then
                    print("Bought")
                    self.Server:EquipWeapon(player, CurrentWeapon, Weapon)
                    self.Server.PlayerDataService:AddWeapon(player, Weapon, weaponCategory)
                    return {Weapons = self.Server.PlayerDataService.CachedProfiles[player].Data.Weapons, CurrentWeapon = self.Server.PlayerDataService.CachedProfiles[player].Data.CurrentWeapon}
                end
            else --// player has this item equip it
                print("Has it")
                self.Server:EquipWeapon(player, CurrentWeapon, Weapon)
                self.Server.PlayerDataService:AddWeapon(player, Weapon)
                return {CurrentWeapon = self.Server.PlayerDataService.CachedProfiles[player].Data.CurrentWeapon}
            end
        end
    end
end

function WeaponService:EquipWeapon(player : Player, oldWeapon : Tool, newWeapon : Tool)
    if player then
        local character = player.Character or player.CharacterAdded:Wait()
        --// wait for them to fully load in
        if not player:HasAppearanceLoaded() then
            player.CharacterAppearanceLoaded:Wait()
        end
        
        --// remove old weapon from character
        for _, Child in ipairs(character:GetDescendants()) do
            if Child:IsA("Tool")
                and Child.Name == oldWeapon then
                Child:Destroy()
            end
        end

        --// remove old weapon from backpack
        for _, Child in ipairs(player:WaitForChild("Backpack"):GetDescendants()) do
            if Child:IsA("Tool")
                and Child.Name == oldWeapon then
                Child:Destroy()
            end
        end

        --// remove old weapon from StarterGear
        for _, Child in ipairs(player:WaitForChild("StarterGear"):GetDescendants()) do
            if Child:IsA("Tool")
                and Child.Name == oldWeapon then
                Child:Destroy()
            end
        end

        --// add new weapon to players backpack
        local Weapon = self.Weapons[newWeapon]:Clone()
        Weapon.Parent = player:WaitForChild("StarterGear")
        Weapon:Clone().Parent = player:WaitForChild("Backpack")
    end
end

function WeaponService.Client:Damage(player, Target)
    if Target and player then
      return self.Server:Damage(player, Target)  
    end
end

function WeaponService:Damage(player : Player, target : BasePart)
    --//Get weapon data and current weapon and check distance of target from the character hrp
    local CachedPlayer = self.PlayerDataService.CachedProfiles[player]
    local PlayerClass = self.PlayerService.Players[player.UserId]
    if CachedPlayer and player.Character
        and player:HasAppearanceLoaded() then
            print(CachedPlayer)
        local CurrentWeapon = CachedPlayer.Data.CurrentWeapon
        local CurrentWeaponCategory = CachedPlayer.Data.Weapons[CurrentWeapon].Category
        local CurrentWeaponData = self.WeaponData[CurrentWeaponCategory][CurrentWeapon]
        print(CurrentWeaponData, (os.time() - PlayerClass.LastAttack),target:IsDescendantOf(PlayerClass.Base), (target.Position - player.Character.HumanoidRootPart.Position).Magnitude)
        if (os.time() - PlayerClass.LastAttack) >= CurrentWeaponData.AttackDelay and target:IsDescendantOf(PlayerClass.Base) then
            if (target.Position - player.Character.HumanoidRootPart.Position).Magnitude <= (CurrentWeaponData.AttackRange * 1.2) then
                local TargetHumanoid : Humanoid = target.Parent:FindFirstChild("Humanoid")
                if TargetHumanoid then
                    PlayerClass.LastAttack = os.time()  
                    
                    --// check if you are going to kill it
                    if (TargetHumanoid.Health - CurrentWeaponData.Damage <= 0)  and MobsModule[target.Name]
                        and MobsModule[target.Name].DeathReward then
                        self.PlayerDataService:AddMoney(player, MobsModule[target.Name].DeathReward)
                    end

                    TargetHumanoid:TakeDamage(CurrentWeaponData.Damage)
                    self.PlayerDataService:AddMoney(player, math.floor(CurrentWeaponData.Damage))
                end
            end
        end
    end
end

function WeaponService:KnitInit()
    
end

function WeaponService:KnitStart()
    self.PlayerService = Knit.GetService("PlayerService")
    self.PlayerDataService = Knit.GetService("PlayerDataService")
    self.WeaponData = require(ReplicatedStorage.Source.Modules.WeaponData)
    self.Weapons = ServerStorage.Assets.Weapons

    --// add weapon to player on join
    for _, player : Player in ipairs(Players:GetPlayers()) do
        local PlayerData = self.PlayerDataService:GetData(player)
        if PlayerData then
            local CurrentWeapon = PlayerData.CurrentWeapon
            self:EquipWeapon(player, CurrentWeapon, CurrentWeapon)
       end
    end

    Players.PlayerAdded:Connect(function(player : Player)
        local PlayerData = self.PlayerDataService:GetData(player)
        if PlayerData then
            local CurrentWeapon = PlayerData.CurrentWeapon
            self:EquipWeapon(player, CurrentWeapon, CurrentWeapon)
       end
    end)
end


return WeaponService