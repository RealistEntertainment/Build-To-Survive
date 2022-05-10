local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Components)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local GamepassPromptPartComponent = Component.new{
    Tag = "GamepassPartPrompt",
    Ancestors = {workspace}
}

function GamepassPromptPartComponent:Touched(Hit)
    local Model = Hit:FindFirstAncestorOfClass("Model")
    local Player = Model and Players:GetPlayerFromCharacter(Model)
    if Player then
        MarketplaceService:PromptGamePassPurchase(Player, self.GamepassId)
    end
end

function GamepassPromptPartComponent:Construct()
    self.Janitor = Janitor.new()
    self.GamepassId = self.Instance:GetAttribute("GamepassId")

    self.Janitor:Add(self.Instance.Touched:Connect(function(Hit)
        self:Touched(Hit)
    end))
end

function GamepassPromptPartComponent:Destroy()
    self.janitor:Destroy()
end

return GamepassPromptPartComponent