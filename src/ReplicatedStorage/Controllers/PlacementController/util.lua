local config = require(script.Parent.config)

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

return util