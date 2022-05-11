local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)

local HatchClass = {}
HatchClass.__index = HatchClass

function HatchClass.new(Hatch, PlayerClass)
	local self = {}
	setmetatable(self, HatchClass)
	
	self.Hatch = Hatch
	self.debounce = false
	self.IsOpen = false
    self.PlayerClass = PlayerClass --// might need later on
	self.ProximityPrompt = self.Hatch:WaitForChild("DoorPrompt")

    self.janitor = Janitor.new()

    self.janitor:Add(self.Hatch)

	self.janitor:Add(
        self.ProximityPrompt.Triggered:Connect(function(...)
            print(...)
		    self:HandleHatch(...)
	    end)
    )
	
    self.janitor:Add(
        self.Hatch.Destroying:Connect(function()
            if not self.Hatch:IsDescendantOf(game) then
                self:Cleanup()
            end
        end)
    )

	return self
end


function HatchClass:HandleHatch(Player)
	if not self.debounce then
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

function HatchClass:Open()
	local HingePoint = self.Hatch.PrimaryPart.CFrame * CFrame.new(0,0,-self.Hatch.PrimaryPart.Size.Z/2):Inverse()
	local HatchOffset = HingePoint:Inverse() * self.Hatch.PrimaryPart.CFrame
	local Rotation = Instance.new("NumberValue")
	Rotation.Value = 0
	Rotation.Changed:Connect(function()
		self.Hatch:PivotTo(HingePoint * CFrame.Angles(0, 0, math.rad(Rotation.Value)):Inverse() * HatchOffset)
	end)
	local Tween = game:GetService("TweenService"):Create(Rotation, TweenInfo.new(.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Value = 90})
	Tween:Play()
	Tween.Completed:Wait()
	Tween:Destroy()
	Rotation:Destroy()

	task.wait()
	self.IsOpen = true
end

function HatchClass:Close()
	local HingePoint = self.Hatch.PrimaryPart.CFrame * CFrame.new(0,0,-self.Hatch.PrimaryPart.Size.Z/2):Inverse()
	local HatchOffset = HingePoint:Inverse() * self.Hatch.PrimaryPart.CFrame
	local Rotation = Instance.new("NumberValue")
	Rotation.Value = 0
	Rotation.Changed:Connect(function()
		self.Hatch:PivotTo(HingePoint * CFrame.Angles(0, 0, math.rad(Rotation.Value)) * HatchOffset)
	end)
	local Tween = game:GetService("TweenService"):Create(Rotation, TweenInfo.new(.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Value = 90})
	Tween:Play()
	Tween.Completed:Wait()
	Tween:Destroy()
	Rotation:Destroy()

	task.wait()
	self.IsOpen = false
end

function HatchClass:Cleanup()
	self.janitor:Cleanup()
	self = nil
end

return HatchClass