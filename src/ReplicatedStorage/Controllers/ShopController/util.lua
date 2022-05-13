local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProductData = require(ReplicatedStorage.Source.Modules.ProductData)

local util = {}

function util.CreateGamepassOverlay()
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.BackgroundTransparency = 0.7

    local overlayUICorner : UICorner = Instance.new("UICorner")
    overlayUICorner.CornerRadius = UDim.new(.5,0)
    overlayUICorner.Parent = overlay

    local BuyButton : TextButton = Instance.new("TextButton")
    BuyButton.Size = UDim2.new(1,0,.33,0)
    BuyButton.Position = UDim2.new(0,0.33,0)
    BuyButton.BackgroundColor3 = Color3.fromRGB(9,194,45)
    BuyButton.Text = "BUY"
    BuyButton.TextScaled = true
    BuyButton.TextColor3 = Color3.fromRGB(236,236,236)
    BuyButton.Parent = overlay
    BuyButton.Name = "BuyButton"

    local BuyButtonUICorner : UICorner = Instance.new("UICorner")
    BuyButtonUICorner.CornerRadius = UDim.new(.2,0)
    BuyButtonUICorner.Parent = BuyButton

    return overlay
end

function util.PromptGamepass(player, Gamepass)
    local gamePassId = ProductData.Gamepasses[Gamepass]
    MarketplaceService:PromptGamePassPurchase(player, gamePassId)
 end

function util.PromptDeveloperProduct(player, DeveloperProduct)
    local DeveloperProductId = ProductData.DeveloperProducts[DeveloperProduct]
    MarketplaceService:PromptProductPurchase(player, DeveloperProductId)
 end

return util