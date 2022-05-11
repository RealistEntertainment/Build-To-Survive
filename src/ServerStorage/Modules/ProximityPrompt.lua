local ProximityPromptService = game:GetService("ProximityPromptService")

local ProximityPrompt = {}

function ProximityPrompt.ObjectPrompt()
    local ObjectPrompt : ProximityPrompt = Instance.new("ProximityPrompt")
    ObjectPrompt.Name = "ObjectPrompt"
    ObjectPrompt.Style = "Custom"
    ObjectPrompt.HoldDuration = .5
    return ObjectPrompt
end

return ProximityPrompt