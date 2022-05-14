local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)

local Door = {}
Door.__index = Door

function Door.new(door, PlayerClass)
	local self = {}
	setmetatable(self, Door)
	
	self.door = door
	self.debounce = false
	self.IsOpen = false
    self.PlayerClass = PlayerClass --// might need later on
	self.ProximityPrompt = self.door:WaitForChild("DoorPrompt")

    self.janitor = Janitor.new()

    self.janitor:Add(self.door)

	self.janitor:Add(
        self.ProximityPrompt.Triggered:Connect(function(...)
		    self:HandleDoor(...)
	    end)
    )
	
    self.janitor:Add(
        self.door.Destroying:Connect(function()
            if not self.door:IsDescendantOf(game) then
                self:Cleanup()
            end
        end)
    )

	return self
end


function Door:HandleDoor(Player)
	if not self.debounce and self.PlayerClass.Player == Player then
		self.debounce = true
        if self.IsOpen then
            self:Close(Player, 5)
        else
            self:Open(Player, 5)
        end
    else
        if self.IsOpen then
            self:Close(Player, 2.5)
        else
            self:Open(Player, 2.5)
        end
    end
end

function Door:Open()
	local HingePoint = self.door.PrimaryPart.CFrame * CFrame.new(self.door.PrimaryPart.Size.X/2,0,0):Inverse()
	local DoorOffset = HingePoint:Inverse() * self.door.PrimaryPart.CFrame
	local Rotation = Instance.new("NumberValue")
	Rotation.Value = 0
	Rotation.Changed:Connect(function()
		self.door:PivotTo(HingePoint * CFrame.Angles(0, math.rad(Rotation.Value), 0) * DoorOffset)
	end)
	local Tween = game:GetService("TweenService"):Create(Rotation, TweenInfo.new(.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Value = 90})
	Tween:Play()
	Tween.Completed:Wait()
	Tween:Destroy()
	Rotation:Destroy()

	task.wait()
	self.IsOpen = true
end

function Door:Close()
	local HingePoint = self.door.PrimaryPart.CFrame * CFrame.new(self.door.PrimaryPart.Size.X/2,0,0):Inverse()
	local DoorOffset = HingePoint:Inverse() * self.door.PrimaryPart.CFrame
	local Rotation = Instance.new("NumberValue")
	Rotation.Value = 0
	Rotation.Changed:Connect(function()
		self.door:PivotTo(HingePoint * CFrame.Angles(0, math.rad(Rotation.Value), 0):Inverse() * DoorOffset)
	end)
	local Tween = game:GetService("TweenService"):Create(Rotation, TweenInfo.new(.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Value = 90})
	Tween:Play()
	Tween.Completed:Wait()
	Tween:Destroy()
	Rotation:Destroy()

	task.wait()
	self.IsOpen = false
end

function Door:Cleanup()
	self.janitor:Cleanup()
	self = nil
end

return Door