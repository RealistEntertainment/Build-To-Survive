local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

if not game:IsLoaded() then
  game.Loaded:Wait()
end

for _, Child: ModuleScript in pairs(ReplicatedStorage.Source:GetDescendants()) do
  local IsModule = Child:IsA("ModuleScript")
  print(Child.Name)
  local IsComponent = Child:IsDescendantOf(ReplicatedStorage.Source.Components) and Child.Name:match("Component$")
  local IsController = Child:IsDescendantOf(ReplicatedStorage.Source.Controllers) and Child.Name:match("Controller$")
  print(IsController, IsComponent)
  if IsModule and (IsComponent or IsController) then
    
    require(Child)
  end
end


Knit.Start():andThen(function()
  print("Knit Started")
end):catch(warn)

