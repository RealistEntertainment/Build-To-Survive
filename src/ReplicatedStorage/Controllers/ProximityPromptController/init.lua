local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)


local ProximityPromptController = Knit.CreateController{
    Name = "ProximityPromptController",
}

function ProximityPromptController:KnitInit()
    self.util = require(script.util)
end

function ProximityPromptController:KnitStart()
    ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
        if prompt.Style == Enum.ProximityPromptStyle.Default then
            return
        end
        
        if prompt.Name == "ObjectPrompt" then
            local cleanupFunction = self.util.ObjectPrompt(prompt, inputType)
            prompt.PromptHidden:Wait()
            cleanupFunction()
        elseif prompt.Name == "DoorPrompt" then
            local cleanupFunction = self.util.DoorPrompt(prompt, inputType)
            prompt.PromptHidden:Wait()
            cleanupFunction()
        end
        
    end)
    
end

return ProximityPromptController

