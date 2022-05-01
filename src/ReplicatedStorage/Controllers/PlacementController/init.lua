local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Classes = ReplicatedStorage.Source.Classes
local PlacementViewport = require(Classes.PlacementViewport)

local Knit = require(ReplicatedStorage.Packages.Knit)
local janitor = require(ReplicatedStorage.Packages.Janitor)

local Mouse = Players.LocalPlayer:GetMouse()

local PlacementController = Knit.CreateController {
    Name = "PlacementController",
}

function PlacementController:Select(ObjectName : string)
    local Object = self.PlacementObjects:FindFirstChild(tostring(ObjectName))
    if Object then
        -- if janitor doesn't exist create if it does then fire cleanup
        if not self.SelectedObjectJanitor then
            self.SelectedObjectJanitor = janitor.new()
        else
            self.SelectedObjectJanitor:Cleanup()
        end

        self.SelectedObject = Object:Clone()
        self.SelectedObject.Parent = workspace

        self.SelectedObjectJanitor:Add(self.SelectedObject)

        self.SelectedObjectJanitor:Add(RunService.RenderStepped:Connect(function()
            Mouse.TargetFilter = self.SelectedObject
            if Mouse.Target ~= nil  then
                local Hitpos = Mouse.Hit.Position
                local ObjectExtents : Vector3 = self.SelectedObject:GetExtentsSize()
                self.SelectedObject:PivotTo(CFrame.new(
                    math.floor(Hitpos.X),
                    math.floor(Hitpos.Y) + (ObjectExtents.Y/2),
                    math.floor(Hitpos.Z)
                    )
                ) 
            end
            
        end))

        self:LoadEditor()
    end
end

function PlacementController:LoadObjectBrowser()
    print("Load Browser")
    local ObjectBrowser : Frame = self.PlacementUI.ObjectBrowser
    local ItemsScrollingFrame : ScrollingFrame = ObjectBrowser.ItemsScrollingFrame

    local PlacementObjects : Folder = ReplicatedStorage.Assets.PlacementObjects

    -- Check if we have a (maid..) if so then clean out the old objects
    if not self.ObjectBrowserJanitor then
        self.ObjectBrowserJanitor = janitor.new()
    else
        self.ObjectBrowserJanitor:Cleanup()
    end
    
    for _, PlacementObject in ipairs(PlacementObjects:GetChildren()) do
        -- Viewport
        local ObjectViewPort : ViewportFrame = self.Util.CreateViewportFrame()
        ObjectViewPort.CurrentCamera = self.Camera
        ObjectViewPort.Parent = ItemsScrollingFrame
        print(ObjectViewPort)

        -- Object
        local ViewportObject: Model = PlacementObject:Clone()
        ViewportObject.Parent = ObjectViewPort

        local ObjectExtents : Vector3 = ViewportObject:GetExtentsSize()
        ViewportObject:PivotTo(
            self.Camera.CFrame 
            + (self.Camera.CFrame.LookVector * math.max(ObjectExtents.X*1.25, ObjectExtents.Y*1.25))
        )

        --create placment Class
        local PlacementViewportObject = PlacementViewport.new(ObjectViewPort, ViewportObject)
        
        -- when viewport is clicked
        PlacementViewportObject.SelectSignal:Connect(function(ObjectName: string)
            self:Select(ObjectName)
        end)
       
        -- Add objects, functions to janitor 
        self.ObjectBrowserJanitor:Add(ObjectViewPort)
    end
end

function PlacementController:LoadEditor()
    if self.SelectedObject then
        local Editor : Frame = self.PlacementUI.Editor
        local ApplyButton : TextButton = Editor.ApplyButton
        local RemoveButton : TextButton = Editor.RemoveButton 
        local ResetButton : TextButton = Editor.ResetButton
        local CurrentObjectTitle : TextLabel = Editor.CurrentObjectTitle

        local PositionFrame : Frame = Editor.PositionFrame
        local PositionXInput : TextBox = PositionFrame.PositionXInput
        local PositionYInput : TextBox = PositionFrame.PositionYInput
        local PositionZInput : TextBox = PositionFrame.PositionZInput

        local ScaleFrame : Frame = Editor.ScaleFrame

        self.SelectedObject.Changed:Connect(function()
            PositionXInput.Text = self.SelectedObject.WorldPivot.Position.X
            PositionYInput.Text = self.SelectedObject.WorldPivot.Position.Y
            PositionZInput.Text = self.SelectedObject.WorldPivot.Position.Z
        end)
        
        CurrentObjectTitle.Text = self.SelectedObject.Name
    end
end

function PlacementController:KnitStart()
    print("Knit started in controller")
    local Assets = ReplicatedStorage.Assets
    local UI = Assets.UI

    self.Util =  require(script.util)

    self.PlacementObjects = Assets.PlacementObjects

    self.PlacementUI  = UI.Placement:Clone()
    self.PlacementUI.Parent = Players.localPlayer.PlayerGui

    -- Camera Used for ViewportFrame
    self.Camera = Instance.new("Camera")
    self.Camera.CFrame = CFrame.new()

    self:LoadObjectBrowser()
end

function PlacementController:KnitInit()
    if not game:IsLoaded() then
      game.Loaded:Wait()
    end
end

return PlacementController