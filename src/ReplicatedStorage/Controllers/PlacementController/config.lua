local config = {
    ItemViewport = {
      Size =  UDim2.new(
            0, -- scale X
            100, -- offset X
            0, -- scale Y
            100 -- offset Y
        ),
    },
    CategoryUIGridLayout = {
        CellPadding = UDim2.new(
            0,
            5,
            0,
            5
        ),
        CellSize = UDim2.new(
            0.1,
            0,
            0.4,
            0
        ),
        HorizontalAlignment = "Left",
        FillDirectionMax = 0, 
        FillDirection = "Horizontal",
        SortOrder = "Name",
        StartCorner = "TopLeft",
        VerticalAlignment = "Top",

    },
    CategoryButton = {
        Color = Color3.fromRGB(0, 170, 255),
        TextColor = Color3.fromRGB(255,255,255),
        SubObject = {
            UICorner = {
                CornerRadius = UDim.new(
                        0,
                        4
                    )
            },
            UIStroke = {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Color3.fromRGB(0,149,223),
                Thickness = 2,
                Transparency = 0,
            }
        }
    },
    RotateTweenInfo = TweenInfo.new(.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
}

return config