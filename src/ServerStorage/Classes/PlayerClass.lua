local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerClass = {}
PlayerClass.__index = PlayerClass


function PlayerClass.new(player: Player)
    local self = setmetatable({}, PlayerClass)
    self.Player = player
    self.PlayerData = nil

    self.Character = player.Character or nil
    
    self._janitor = Janitor.new()
    self.CharacterAdded = Signal.new()
    self.CharacterDied = Signal.new()

    self.ActiveDebounces = {}
    self.LastAttack = os.time()

    self.GamepassService = Knit.GetService("GamepassService")

    self.SpawnPosition = Vector3.new(0,0,0)
    --// character added event
    self._janitor:Add(
        player.CharacterAdded:Connect(function(Character)
            self.Character = Character
            repeat
                task.wait()
            until self.Character:IsDescendantOf(workspace)
            Character.PrimaryPart.CFrame = CFrame.new(self.SpawnPosition)
            self.CharacterAdded:Fire()
            --// character died event
            local Hum : Humanoid = Character:WaitForChild("Humanoid")
            if self.GamepassService:UserOwnsPass(player, 44187143) then
                if Hum then
                    Hum.WalkSpeed = 32
                end
            end
            Hum.Died:Connect(function()
                self.CharacterDied:Fire()
                self.Player:LoadCharacter()
            end)
        end)
    )

    --// if the player character is loaded then we need to connect the event 
    if self.Character
        and self.Character:FindFirstChild("Humanoid") then
        self.Character:WaitForChild("Humanoid").Died:Connect(function()
            self.CharacterDied:Fire()
            self.Player:LoadCharacter()
        end)
    end
    
    return self
end

function PlayerClass:HandleDebounce(Name, Timeout)
    if tostring(Name) and tonumber(Timeout) then
        if not self.ActiveDebounces[Name] or (os.time - self.ActiveDebounces[Name]) > Timeout then
            self.ActiveDebounces[Name] = os.time()
            return true
        else
            return false
        end
    else
        assert(false, "Invalid debounce data")
        return false
    end
    
end

function PlayerClass:Destroy()
    self._janitor:Cleanup()
end

return PlayerClass