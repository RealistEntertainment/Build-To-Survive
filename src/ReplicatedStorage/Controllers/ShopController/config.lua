local config = {
    TweenOpenInfo = TweenInfo.new(
        .5,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    ),

    TweenCloseInfo = TweenInfo.new(
        .5,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    ),

    TweenClosePosition = UDim2.new(0.5, 0, 1.45, 0),
    TweenOpenPosition = UDim2.new(0.5, 0,0.45, 0)
}


return config