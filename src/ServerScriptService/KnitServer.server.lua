local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)



for _, Child: ModuleScript in pairs(ServerStorage.Source:GetDescendants()) do
  local IsModule = Child:IsA("ModuleScript")

  local IsComponent = Child:IsDescendantOf(ServerStorage.Source.Components) and Child.Name:match("Component$")
  local IsService = Child:IsDescendantOf(ServerStorage.Source.Services) and Child.Name:match("Service$")
  print(IsService, IsComponent)
  if IsModule and (IsComponent or IsService) then
    print(Child)
    require(Child)
  end
end

Knit.Start():andThen(function()
  print("Knit Started")
end):catch(warn)