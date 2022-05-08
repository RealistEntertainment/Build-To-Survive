local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local FeedbackController = Knit.CreateController{
    Name = "FeedbackController"
}

function FeedbackController:KnitInit()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    self.FeedbackUI = ReplicatedStorage.Assets.UI.Feed:Clone()
    self.FeedbackUI.Parent = Players.LocalPlayer.PlayerGui
end

function FeedbackController:KnitStart()
    local RoundService = Knit.GetService("RoundService")
    RoundService.Feedback:Connect(function(Visible, Feed)
        if not Visible then
            self.FeedbackUI.MainFrame.Visible = false 
            elseif tostring(Feed) then
            self.FeedbackUI.MainFrame.Visible = true
            self.FeedbackUI.MainFrame.TextLabel.Text = tostring(Feed) 
        end
    end)
end

return FeedbackController