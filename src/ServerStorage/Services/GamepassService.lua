
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local GamepassService = Knit.CreateService{
	Name = "GamepassService",
	Client = {}
}

--// Gamepasses Data
local Gamepasses = require(ReplicatedStorage.Source.Modules.ProductData).Gamepasses

function GamepassService:UserOwnsPass(player, gamePassId)
    local PlayerData = self.PlayerDataService:GetData(player)
    if PlayerData then --// 
        local Haspass = table.find(PlayerData.GamepassData, gamePassId) or table.find(PlayerData.GamepassData, Gamepasses[gamePassId]) 
        if Haspass then
            return true
        else
            local Success, OwnsPass = pcall(MarketplaceService.UserOwnsGamePassAsync, player.UserId, gamePassId)
            if Success then
                if OwnsPass then
                    table.insert(PlayerData.GamepassData, gamePassId)
                    print('Has pass not in data')
                    return true
                end
            end
        end
    end
    print("Doesn't have a pass")
    return false
end

function GamepassService:GamepassPromptFinished(player, gamePassId, wasPurchased)
    local PlayerData = self.PlayerDataService:GetData(player)
    if wasPurchased and PlayerData then
        table.insert(PlayerData.GamepassData, gamePassId)
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
