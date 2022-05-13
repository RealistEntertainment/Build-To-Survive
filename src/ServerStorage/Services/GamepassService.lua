
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local GamepassService = Knit.CreateService{
	Name = "GamepassService",
	Client = {
        Purchased = Knit.CreateSignal()
    }
}

--// Gamepasses Data
local Gamepasses = require(ReplicatedStorage.Source.Modules.ProductData)

function GamepassService:UserOwnsPass(player, gamePassId)
    local PlayerData = self.PlayerDataService:GetData(player)
    return Gamepasses.UserOwnsPass(PlayerData, player, gamePassId)
end

function GamepassService:GamepassPromptFinished(player, gamePassId, wasPurchased)
    local PlayerData = self.PlayerDataService:GetData(player)
    if wasPurchased and PlayerData then
      --  table.insert(PlayerData.GamepassData, gamePassId)
        self.Client.Purchased:Fire(player,  gamePassId)
    end
end

function GamepassService:KnitInit()
    self.PlayerDataService = Knit.GetService("PlayerDataService")
    
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
        self:GamepassPromptFinished(player, gamePassId, wasPurchased)
    end)
end

function GamepassService:KnitStart()

end

return GamepassService
