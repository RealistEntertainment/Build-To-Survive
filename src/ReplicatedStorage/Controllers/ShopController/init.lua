local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local ShopController = Knit.CreateController{
    Name = "ShopController"
}

function ShopController:PromptShop()
    if self.MainFrame.Visible and self.TweenState then
        self.TweenState = true

        self.TweenClose:Play()
        self.TweenClose.Completed:Wait()

        self.MainFrame.Visible = false
        self.BlurButton.Visible = false

        self.TweenState = false
    else 
        self.TweenState = true

        self.MainFrame.Visible = true
        self.BlurButton.Visible = true

        self.TweenOpen:Play()
        self.TweenClose.Completed:Wait()

        self.TweenState = false
    end
end

function ShopController:KnitInit()
    self.Config = require(script.config)
    self.Util = require(script.util)

    --// tween state is created just so we don't spam or override tweens
    self.TweenState = false
end

function ShopController:KnitStart()
    self.Player = Players.LocalPlayer
    self.ProductData = require(ReplicatedStorage.Source.Modules.ProductData)

    --// Clone shop to the player
    self.ShopUI = ReplicatedStorage.Assets.UI.Shop:Clone()
    self.ShopUI.Parent = self.Player:WaitForChild("PlayerGui")

    --// Frames
    self.MainFrame = self.ShopUI.MainFrame
    self.GamepassesFrame = self.MainFrame.Gamepasses

    --//  Tweens
    self.TweenClose = TweenService:Create(self.MainFrame, self.Config.TweenCloseInfo, {Position = self.Config.TweenClosePosition})
    self.TweenOpen = TweenService:Create(self.MainFrame, self.Config.TweenOpenInfo, {Position = self.Config.TweenOpenPosition})

    --// Buttons
    self.BlurButton = self.ShopUI.BlurButton
    self.ShopButton = self.ShopUI.ShopButton
    self.CloseButton = self.ShopUI.MainFrame.CloseButton

    --// janitors
    self.OverlayJanitor = Janitor.new()

    --// Currency(Dev Products)
    for _,CurrencyButton in ipairs(self.MainFrame:GetChildren()) do
        if string.find(CurrencyButton.Name, "Money") then
            --// Shake tween or something

            --// prompt purchase
            CurrencyButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    self.Util.PromptDeveloperProduct(self.Player, CurrencyButton.Name)
                end 
            end)
        end
    end

    --// Gamepasses
    for _,GamepassButton : ImageButton in ipairs(self.GamepassesFrame:GetChildren()) do
        if GamepassButton:IsA("ImageButton") then
            --// handle buy overlay
            GamepassButton.InputBegan:Connect(function(input)
                print(input.UserInputType)
                GamepassButton.MouseEnter:Connect(function()
                    print("Enter")
                end)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    --// Delay for input ended to not delate the new overlay
                    task.wait()
                    --// generate new overlay
                    self.GamepassOverlay = self.Util.CreateGamepassOverlay()
                    self.GamepassOverlay.Parent = GamepassButton
                    self.OverlayJanitor:Add(self.GamepassOverlay)

                    --// connect to prompt purchase
                    self.OverlayJanitor:Add(self.GamepassOverlay.BuyButton.Activated:Connect(function()
                        self.Util.PromptGamepass(self.Player, GamepassButton.Name)
                    end))
                end 
            end)
            GamepassButton.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    self.Util.PromptGamepass(self.Player, GamepassButton.Name)
                elseif input.UserInputType == Enum.UserInputType.MouseMovement then
                    self.OverlayJanitor:Cleanup()
                end 
            end)

        end
    end

    --// connections
    self.ShopButton.Activated:Connect(function()
        self:PromptShop()
    end)

    self.BlurButton.Activated:Connect(function()
        self:PromptShop()
    end)

    self.CloseButton.Activated:Connect(function()
        self:PromptShop()
    end)
end

return ShopController