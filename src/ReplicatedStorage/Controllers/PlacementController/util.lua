local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local config = require(script.Parent.config)

local ProductData = require(ReplicatedStorage.Source.Modules.ProductData)
local PlacementObjectData = require(ReplicatedStorage.Source.Modules.PlacementObjectData)

local util = {}

function util.CreateItemViewportFrame()
    local Viewport = Instance.new("ViewportFrame")
    Viewport.Size = config.ItemViewport.Size

    local ItemViewportPrice = Instance.new("TextLabel")
    ItemViewportPrice.Name = "ObjectPrice"
    ItemViewportPrice.Text = "$1"
    ItemViewportPrice.Font = Enum.Font.Cartoon
    ItemViewportPrice.TextXAlignment = "Center"
    ItemViewportPrice.TextYAlignment = "Center"
    ItemViewportPrice.BackgroundColor3 = Color3.fromRGB(255,255,255)
    ItemViewportPrice.TextColor3 = Color3.fromRGB(139,139,139)
    ItemViewportPrice.Position = UDim2.new(0,0,.8,0)
    ItemViewportPrice.Size = UDim2.new(1,0,.2,0)
    ItemViewportPrice.TextScaled = true
    ItemViewportPrice.Parent = Viewport

    local ItemPriceUICorner = Instance.new("UICorner")
    ItemPriceUICorner.CornerRadius = UDim.new(0,4)
    ItemPriceUICorner.Parent = ItemViewportPrice
    return Viewport
end


function util.CreateCategoryButton(Title)
    local Button : TextButton = Instance.new("TextButton")
    Button.Text = Title
    Button.BackgroundColor3 = config.CategoryButton.Color
    Button.TextColor3 = config.CategoryButton.TextColor
    Button.TextScaled = true
    for SubName, SubValue in pairs(config.CategoryButton.SubObject) do
        local Object = Instance.new(SubName)
        Object.Parent = Button
        for Property, Value in pairs(SubValue) do
            Object[Property] = Value
        end
    end
    return Button
end

function util.CategoryGridLayout(Grid : UIGridLayout)
    if Grid then
        for Property, Value in ipairs(config.CategoryUIGridLayout) do
            Grid[Property] = Value
        end
    end
end

function util.CreateSelectionBox(color)
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Color3 = color
    selectionBox.Parent = workspace
    return selectionBox
end

function util.CreatePurchaseCategoryOverlay()
    local Overlay : TextButton = Instance.new("TextButton")
    Overlay.Name = "Overlay"
    Overlay.Size = UDim2.new(1,0,1,0)
    Overlay.Text = "PURCHASE REQUIRED"
    Overlay.TextScaled = true
    Overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Overlay.BackgroundTransparency = .2
    Overlay.TextColor3 = Color3.fromRGB(255,255,255)
    return Overlay
end

function util.PromptCategoryPurchase(player, Category)
   local gamePassId = ProductData.Gamepasses[Category]
   MarketplaceService:PromptGamePassPurchase(player, gamePassId)
end

--// Check if they have the category open then delete the Overlay (scan for the id)
function util.CategoryPurchased(ItemList : ScrollingFrame, Category)
    local CategoryIndex = PlacementObjectData.GetCategory(Category)
    print(CategoryIndex)
    local CategoryButton = CategoryIndex and ItemList:FindFirstChild(CategoryIndex)
    local Overlay = CategoryButton and CategoryButton:FindFirstChild("Overlay")
    
    if Overlay then
        Overlay:Destroy()
    end
end

function util.GetGamepassName(id)
    return ProductData.GetGamepassById(id)
end

function util.UserOwnsCategory(PlayerData, player, Category)
    return ProductData.UserOwnsPass(PlayerData, player, Category)
end

return util