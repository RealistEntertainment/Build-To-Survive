local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local PlayerDataService = Knit.GetService("PlayerDataService")

local config = require(script.Parent.config)
local util = {}

util.Products = { 
    [1263372863] = function(profile, player) --// 49 obux cash option 1
        PlayerDataService:AddMoney(player, 3500)
    end,
	[1263733810] = function(profile, player) --// 99 obux cash option 2
        PlayerDataService:AddMoney(player, 7250)
    end,
	[1263733847] = function(profile, player) --// 199 obux cash option 3
        PlayerDataService:AddMoney(player, 15000)
    end,
	[1263733947] = function(profile, player) --// 399 obux cash option 4
        PlayerDataService:AddMoney(player, 32000)
    end,
	[1263733972] = function(profile, player) --// 599 obux cash option 5
        PlayerDataService:AddMoney(player, 65000)
    end,
	[1263734005] = function(profile, player) --// 1199 obux cash option 6
        PlayerDataService:AddMoney(player, 140000)
    end,
}


function util.PurchaseIdCheckAsync(profile, PurchaseId, GiveProductCallback)
	if profile:IsActive() ~= true then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else
		local MetaData = profile.MetaData
		
		local localPurchaseIds = MetaData.MetaTags.ProfilePurchaseIds
		print(localPurchaseIds)
		if localPurchaseIds == nil then
			localPurchaseIds = {}
			MetaData.MetaTags.ProfilePurchaseIds = localPurchaseIds
		end
		
		-- give product if not received
		if table.find(localPurchaseIds, PurchaseId) == nil then
			while #localPurchaseIds >= config.DataStoreSettings.PurchaseIdLog do
				table.remove(localPurchaseIds, 1)
			end
			table.insert(localPurchaseIds, PurchaseId)
			task.spawn(GiveProductCallback)
		end
		
		--waiting until purchase is confirmed to be saved
		local Result = nil
		local function CheckLatestMetaTags()
			local SavedPurchaseIds = MetaData.MetaTagsLatest.ProfilePurchaseIds
			print(SavedPurchaseIds)
			if SavedPurchaseIds ~= nil and table.find(SavedPurchaseIds, PurchaseId) ~= nil then
				print("Granted")
				Result = Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
		
		CheckLatestMetaTags()
		
		local MetaTagsConnection = profile.MetaTagsUpdated:Connect(function()
			CheckLatestMetaTags()
			-- When MetaTagsUpdated fires after profile release:
			if profile:IsActive() == false and Result == nil then
				Result = Enum.ProductPurchaseDecision.NotProcessedYet
			end
		end)

		
		while Result == nil do
			task.wait()
		end
		
		MetaTagsConnection:Disconnect()
		
		return Result
		
	end
end

function util.GetPlayerProfileAsync(player)
	-- waits until a profiled linked to player loads or the play leaves
	local Profile = PlayerDataService.CachedProfiles[player]
	while Profile == nil and player:IsDescendantOf(Players) == true do
		task.wait()
		Profile = PlayerDataService.CachedProfiles[player]
	end
	return Profile
end

function util.GiveProduct(player, ProductId)
    print("Give product")
	local profile = PlayerDataService.CachedProfiles[player]
	local ProductFunction = util.Products[ProductId]
	if ProductFunction ~= nil then
		ProductFunction(profile, player)
	else
		warn("ProductId: "..tostring(ProductId).." is missing from the products table.")
	end
end

function util.ProcessReceipt(Receipt_info)
    print("ProcessReceipt")
	local Player = Players:GetPlayerByUserId(Receipt_info.PlayerId)
	if Player == nil then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local profile = util.GetPlayerProfileAsync(Player)
	if profile ~= nil then
		return util.PurchaseIdCheckAsync(
			profile,
			Receipt_info.PurchaseId,
			function()
				util.GiveProduct(Player, Receipt_info.ProductId)
			end
		)
	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

return util