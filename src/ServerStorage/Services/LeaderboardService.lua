local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local LeaderboardService = Knit.CreateService{
	Name = "LeaderboardService",
	Client = {}
}

local function getNameFromId(id)
	local name = ""
	local s, m = pcall(function()
		name = Players:GetNameFromUserIdAsync(tonumber(id) or 1)
	end)
	if name == "ROBLOX" and id ~= 1 then
		name = ""
	end
	return name
end

local function convertNum(n)
	if n < 10 then
		n = "0"..n
	end
	return n
end

local function convertToTimeStamp(seconds)
	seconds = tonumber(seconds) or 0
	if seconds < 60 then
		return "00:00:00"
	else
		local days = math.floor(seconds/86400)
		local hours = math.floor(math.fmod(seconds,86400)/3600)
		local minutes = math.floor(math.fmod(seconds,3600)/60)

		if days < 10 then 
			days = "0"..days 
		end
		if hours < 10 then 
			hours = "0"..hours 
		end
		if minutes < 10 then 
			minutes = "0"..minutes 
		end
		return tostring(days..":"..hours..":"..minutes)
	end
end

function LeaderboardService:UpdatePlayerTime(LastTime, key)
	pcall(function() 
		self.TimePlayedDataStore:UpdateAsync(key, function(oldValue)
			local newValue = tonumber(oldValue) or 0
			return newValue + math.floor(os.time() - LastTime)
		end)
	end)
end

function LeaderboardService:UpdateTimeLeaderboards()
	local pages = self.TimePlayedDataStore:GetSortedAsync(false, 100)
	local top100 = pages:GetCurrentPage()
	local n = 0
	local Boards = CollectionService:GetTagged("TimePlayedLeaderboard")
	for _, Board in ipairs(Boards) do
		for rank, data in ipairs(top100) do
			n = rank
			local name = getNameFromId(tostring(data.key))
			local score = tonumber(data.value) or "..."
			Board.SurfaceGui.Frame.ScrollingFrame.PlayerNames["Spot"..convertNum(n)].Text = n..") "..tostring(name)
			Board.SurfaceGui.Frame.ScrollingFrame.PlayerScores["Spot"..convertNum(n)].Text = convertToTimeStamp(tonumber(score) or 0)
		end
	end
end

function LeaderboardService:KnitInit()
	self.PlayerTimes = {}
	self.TimePlayedDataStore = DataStoreService:GetOrderedDataStore("TimePlayedData")

	Players.PlayerAdded:Connect(function(player : Player)
		self.PlayerTimes[player] = {player.UserId, os.time()}
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		self.PlayerTimes[player] = nil
	end)
end

function LeaderboardService:KnitStart()
	while true do
		--// Update player times
		for player, Data in pairs(self.PlayerTimes) do
			task.wait(15)
			if self.PlayerTimes[player]  then
				self:UpdatePlayerTime(Data[2], Data[1])
				Data[2] = os.time() -- reset last time 
			end
		end

		--// display on boards
		self:UpdateTimeLeaderboards()
	end
end

return LeaderboardService
