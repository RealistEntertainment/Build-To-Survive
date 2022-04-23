local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Components)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)

local TestExtention = require(script.Parent.TestExtention)

local TestComponent = Component.new{
    Tag = "Test",
    Ancestors = {workspace},
    Extensions = {TestExtention}
}


function TestComponent:Construct()
    print("Test Component is created", self.Instance)
end

function TestComponent:Destroy()
    
end

return TestComponent