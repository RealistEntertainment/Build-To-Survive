local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asset = ReplicatedStorage.Assets

local Janitor = require(ReplicatedStorage.Packages.Janitor)

local Tycoon = {}
Tycoon.__index = Tycoon

local function NewModel(Model: Model, cframe: CFrame)
    local model = Model:Clone()
    model:SetPrimaryPartCFrame(cframe)
    model.Parent = workspace
    return model
end

function Tycoon.new(player: Player)
    local self = setmetatable({}, Tycoon)
    self.Owner = player

    self._janitor = Janitor.new()
    return self
end

function Tycoon:init()
    self.Tycoon = NewModel(Asset.Tycoon.TycoonTemplate, CFrame.new(0, 1,0))
    self._janitor:Add(self.Tycoon)

    print(self.Owner)
    print("Tycoon initilized")
end

function Tycoon:Destroy()
    self._janitor:Cleanup()
end

return Tycoon