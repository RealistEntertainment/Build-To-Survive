local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

for _, Child: ModuleScript in pairs(ReplicatedStorage.Source:GetDescendants()) do
  local IsModule = Child:IsA("ModuleScript")
  
  local IsComponent = Child:IsDescendantOf(ReplicatedStorage.Source.Components) and Child.Name:match("Component$")
  local IsController = Child:IsDescendantOf(ReplicatedStorage.Source.Controllers) and Child.Name:match("Controller$")
  if IsModule and (IsComponent and IsController) then
    require(Child)
  end
end

Knit.Start():andThen(function()
  print("Knit Started")
end):catch(warn)

