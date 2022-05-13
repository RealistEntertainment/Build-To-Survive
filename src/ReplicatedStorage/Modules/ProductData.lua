local MarketplaceService = game:GetService("MarketplaceService")
local ProductData = {}

ProductData.Gamepasses = {
    ["Double Speed"] =  44187143, --// Double Speed
    ["Double Money"] = 44188735, --// Double Money

    --// packages (set the name to the category name for packages)
    ["Modern"] = 44482787, --// Modern Build Package
}

--// might not be nesscessy (Developer Products are handled in the PlayerDataService)
ProductData.DeveloperProducts = {
    ["Money1"] = 1263372863,
    ["Money2"] = 1263733810,
    ["Money3"] = 1263733847,
    ["Money4"] = 1263733947,
    ["Money5"] = 1263733972,
    ["Money6"] = 1263734005,
}

function ProductData.UserOwnsPass(PlayerData, player : Player, gamePassId)
    print(PlayerData, player, gamePassId)
    if PlayerData then
        local Haspass = table.find(PlayerData.GamepassData, gamePassId) or table.find(PlayerData.GamepassData, ProductData.Gamepasses[gamePassId])
        print(Haspass)
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

function ProductData.GetGamepassById(id)
    for GamepassName, GamepassId in pairs(ProductData.Gamepasses) do
        if GamepassId == id then
            return GamepassName
        end
    end
end

return ProductData