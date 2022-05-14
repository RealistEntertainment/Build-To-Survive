local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Classes = ReplicatedStorage.Source.Classes
local PlacementViewport = require(Classes.PlacementViewport)

local Knit = require(ReplicatedStorage.Packages.Knit)
local janitor = require(ReplicatedStorage.Packages.Janitor)
local Util = require(script.util)

local PlayerService

local PlacementObjects

local Mouse = Players.LocalPlayer:GetMouse()

local PlacementController = Knit.CreateController {
    Name = "PlacementController",
}

function PlacementController:PromptCancelFrame(ObjectTitle)
    self.ObjectFrame.Visible = false
    self.CancelTitle.Text = ObjectTitle
    self.CancelFrame.Visible = true
    if ObjectTitle == "Delete Mode" then
        self.RotateButton.Visible = false
    else
        self.RotateButton.Visible = true
    end

    self.BuildJanitor:Add(self.CancelButton.Activated:Connect(function()
        PlacementController:SetDefault()
        self.WeaponController:Equip()
    end))
end

function PlacementController:BuildMode(ObjectName : string)
    local Object = self.PlacementObjects:FindFirstChild(tostring(ObjectName))
    local SelectedObjectName = if ObjectName and  self.SelectedObject then self.SelectedObject.Name else nil
    if Object and (SelectedObjectName ~= ObjectName or SelectedObjectName == nil) then
        self:PromptCancelFrame(Object.Name)
        Util.LoadItemData("Object", ObjectName, self.PlacementUI)
        --// Set state
        self.State = "BuildMode"

        -- if janitor doesn't exist create if it does then fire cleanup
        if not self.SelectedObjectJanitor then
            self.SelectedObjectJanitor = janitor.new()
        else
            self.SelectedObjectJanitor:Cleanup()
        end

        self.SelectedObject = Object:Clone()
        for _,Child : BasePart in ipairs(self.SelectedObject:GetDescendants()) do
            if Child:IsA("BasePart") then
                Child.CanCollide = false
                Child.Transparency = .5
            end
        end
        self.SelectedObject.Parent = workspace

        print(self.SelectionBox)
        if self.SelectionBox.Parent == nil then 
            self.SelectionBox = Util.CreateSelectionBox(Color3.fromRGB(0,255,0))
        end
        self.SelectionBox.Color3 = Color3.fromRGB(0,255,0)
        self.SelectionBox.Adornee = self.SelectedObject

         --// check for players base
         if self.Base  == nil then 
            PlayerService.GetPlayerBase():andThen(function(base)
                self.Base = base
            end):await()
        end

        --// Add Object to janitor to clean up later
        self.SelectedObjectJanitor:Add(self.SelectedObject)
        
        --// Connect InputService for detecting pressing R for rotate (added to janitor for clean up after build mode is exited)
        self.SelectedObjectJanitor:Add(
            UserInputService.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.Keyboard
                    and Input.KeyCode == Enum.KeyCode.R then
                        self:Rotate()
                end
            end)
        )

        --// Update object each renderstepped handle all the grid and hit detection calculations
        self.SelectedObjectJanitor:Add(
            RunService.RenderStepped:Connect(function()
                Mouse.TargetFilter = self.SelectedObject

                if Mouse.Target ~= nil and self.Base then
                    local Hitpos = Mouse.Hit.Position
                   
                    local ObjectExtents : Vector3 = self.SelectedObject.PrimaryPart.Size
                    local BaseCFrame, BaseSize  = self.Base.Baseplate.CFrame, self.Base.Baseplate.Size
                   
                    --// Base Grid Size
                    local minX, maxX = (BaseCFrame + Vector3.new(BaseSize.X/2,0,0)).Position.X ,
                                       (BaseCFrame - Vector3.new(BaseSize.X/2,0,0)).Position.X 

                    local minZ, maxZ = (BaseCFrame + Vector3.new(0,0,BaseSize.Z/2)).Position.Z, 
                                       (BaseCFrame - Vector3.new(0,0,BaseSize.Z/2)).Position.Z

                    local minY, maxY = BaseCFrame.Position.Y + BaseSize.Y/2,
                                       BaseCFrame.Position.Y + ObjectExtents.Y/2 + 90

                    --// make sure the target is an object on the base or the baseplate
                    local Target : Model = if Mouse.Target:FindFirstAncestorOfClass("Model") and Mouse.Target:IsDescendantOf(self.Base.Objects) then Mouse.Target:FindFirstAncestorOfClass("Model") elseif Mouse.Target == self.Base.Baseplate then self.Base.Baseplate else nil
                  
                    --// return incorrect target
                    if not Target then
                        return
                    end

                    --// relative Position to base plate (0,0,0) = center of baseplate
                    local HitPositionRelativeToBase =  Hitpos - BaseCFrame.Position
    
                    --// if we hit an object change the relative hit position based on self object size in the hit vector
                    local TargetPositionRelativeToBase
                    if Target 
                        and Target ~= self.Base.Baseplate then
                        local TargetSize = Target.PrimaryPart.Size
                        TargetPositionRelativeToBase = (Target.WorldPivot.Position - BaseCFrame.Position)

                       

                        --[[ X = right, Y = Up, Z = Back   ]]
                       if TargetPositionRelativeToBase.X - HitPositionRelativeToBase.X >= TargetSize.X/2.01 then
                            print("On Right Side Of Object")
                            Hitpos -= Vector3.new(ObjectExtents.X/2,0,0)
                        elseif TargetPositionRelativeToBase.X - HitPositionRelativeToBase.X <= -TargetSize.X/2.01 then
                            print(("On left side of object"))
                            Hitpos += Vector3.new(ObjectExtents.X/2,0,0)
                        elseif TargetPositionRelativeToBase.Z - HitPositionRelativeToBase.Z >= TargetSize.Z/2.01 then
                            print("On back of object")
                            Hitpos -= Vector3.new(0,0,ObjectExtents.Z/2)
                        elseif TargetPositionRelativeToBase.Z - HitPositionRelativeToBase.Z <= -TargetSize.Z/2.01 then
                            print(("in front of object"))
                            Hitpos += Vector3.new(0,0,ObjectExtents.Z/2)
                        elseif TargetPositionRelativeToBase.Y - HitPositionRelativeToBase.Y >= TargetSize.Y/2.01 then
                            print("On Top of object")
                            Hitpos -=  Vector3.new(0,ObjectExtents.Y,0)
                        elseif  TargetPositionRelativeToBase.Y - HitPositionRelativeToBase.Y <= -TargetSize.Y/2.01 then
                           -- Hitpos += Vector3.new(0,ObjectExtents.Y/2,0)
                            print("Bottom of object")
                        end
                    end

                    
                    
                    --// clamp to grid
                    local ClampedPosition = Vector3.new(
                        math.clamp(Hitpos.X, math.min(minX,maxX), math.max(minX,maxX)),
                        math.clamp(Hitpos.Y, minY, maxY),
                        math.clamp(Hitpos.Z, math.min(minZ,maxZ), math.max(minZ,maxZ))
                    )

                    local function roundToTheNearest(n, nearest)
                        if (n % nearest) == 0 then
                            return n
                        elseif n % nearest < (nearest / 2) then
                            return n - (n % nearest)
                        else
                            return n + (nearest - n % nearest)
                        end
                    end
                    --// apply grid
                    local GridPosition = Vector3.new(
                        roundToTheNearest(ClampedPosition.X, 3),
                        roundToTheNearest(ClampedPosition.Y, 3) + ObjectExtents.Y/2,
                        roundToTheNearest(ClampedPosition.Z, 3)
                    )

                    --// detect if we are colliding with another object
                    local OverLapPara = OverlapParams.new()
                    OverLapPara.FilterType = Enum.RaycastFilterType.Whitelist
                    OverLapPara.FilterDescendantsInstances = {self.Base.Objects}

                    local HitParts = workspace:GetPartBoundsInBox(
                        CFrame.new(GridPosition) * self.SelectedObject.WorldPivot.Rotation,
                        Vector3.new(ObjectExtents.X/2, ObjectExtents.Y/2, ObjectExtents.Z/2),
                        OverLapPara
                    )

                    for _, Part in ipairs(HitParts) do
                        local Model = Part:FindFirstAncestorOfClass("Model")
                        if Model
                            and Model ~= self.SelectedObject then
                             return
                        end
                    end

                    --// Apply relative gridposition to baseplate position
                    self.SelectedObject:PivotTo(
                        CFrame.new(GridPosition) * self.SelectedObject.WorldPivot.Rotation
                    )
                end
            end)
        )
        self.SelectedObjectJanitor:Add(
            UserInputService.InputBegan:Connect(function(Input : InputObject, GPE)
                print(GPE)
                if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and not GPE then
                    -- tell server to check for object
                    self.PlacementService:PlaceObject(self.SelectedObject.Name, self.SelectedObject.WorldPivot, self.Category)
                end
            end)
        )
    end
end

--[[function PlacementController:LoadObjectBrowser()
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
        local ObjectViewPort : ViewportFrame = Util.CreateViewportFrame()
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
end]]

function PlacementController:LoadCategory(Category : string, isBuild)
    if self.State == "Categories" then
        self.ItemList.CanvasPosition = Vector2.new(0,0)

        --// clear old category
        for _, Child in ipairs(self.ItemList:GetChildren()) do
            if not Child:IsA("UIGridLayout") then
                Child:Destroy()
            end
        end
        --// set title to the current state
        self.ObjectFrame.FrameTitle.Text = Category
        --// Update Current Category
        self.Category = Category

        --// Update GridLayout
        Util.CategoryGridLayout(self.GridLayout)

        --// Cleanup janitors
        self.Category_Janitor:Cleanup()
        self.BuildJanitor:Cleanup()


        --// create category Buttons
        local Objects = self.PlacementObjectData[Category] or self.WeaponData[Category]
        for objectName, ObjectData in pairs(Objects) do
            local ObjectViewPort : ViewportFrame = Util.CreateItemViewportFrame()
            ObjectViewPort.CurrentCamera = self.Camera 
            ObjectViewPort.Name = Objects[objectName].CategorySort[Category]
            ObjectViewPort.Parent = self.ItemList
           
    
            -- Object
            local ViewportObject: Model = PlacementObjects:FindFirstChild(objectName) or Weapons:FindFirstChild(objectName)
            ViewportObject = ViewportObject:Clone()
            ViewportObject.Parent = ObjectViewPort
            
            if isBuild then
               ObjectViewPort.ObjectPrice.Text = if not Objects[objectName].Cost or Objects[objectName].Cost <= 0 then "Free" else "$" .. Objects[objectName].Cost
            else --// weapon price text here
                if self.PlayerData.CurrentWeapon == objectName then
                    ObjectViewPort.ObjectPrice.Text = "Equipped"
                elseif self.PlayerData.Weapons[objectName] then
                    ObjectViewPort.ObjectPrice.Text = "Owned"
                else
                    ObjectViewPort.ObjectPrice.Text = if not Objects[objectName].Cost or Objects[objectName].Cost <= 0 then "Free" else "$" .. Objects[objectName].Cost
                end
            end
            

            local ObjectExtents : Vector3 = ViewportObject:GetExtentsSize()
            ViewportObject:PivotTo(
                self.Camera.CFrame 
                + (self.Camera.CFrame.LookVector * math.max(ObjectExtents.X*1.25, ObjectExtents.Y*1.25))
            )
    
            --create placment Class
            local PlacementViewportObject = PlacementViewport.new(ObjectViewPort, ViewportObject)
            
            -- when viewport is clicked
            PlacementViewportObject.SelectSignal:Connect(function(ObjectName: string)
                if self.SelectedObject
                    and self.SelectedObject.Name == ObjectName then
                        self.SelectedObjectJanitor:Cleanup()
                        self.SelectedObject = nil
                    else
                    self.SelectedObjectJanitor:Cleanup()
                    self.SelectedObject = nil
                    if isBuild then
                        self:BuildMode(ObjectName)  
                    else--// weapon stuff
                        self.ProductBuyButton.Text =  ObjectViewPort.ObjectPrice.Text
                        Util.LoadItemData("Weapon", ObjectName, self.PlacementUI)
                    end
                end
                
            end)
           
            -- Add objects, functions to janitor 
            self.BuildJanitor:Add(ObjectViewPort)
        end

        self.ObjectFrame.Visible = true
    else -- Player is in the category state and click the build tab again
        self.State = "Default"
        self.ObjectFrame.Visible = false
    end
end

function  PlacementController:LoadCategories(Categories, isBuild) 
    self:SetDefault()

    if self.ObjectFrame.Visible == false then
        self.ItemList.CanvasPosition = Vector2.new(0,0)
        self.State = "Categories"
        --// clear old category
        for _, Child in ipairs(self.ItemList:GetChildren()) do
            if not Child:IsA("UIGridLayout") then
                Child:Destroy()
            end
        end
        --// set title to the current state
        self.ObjectFrame.FrameTitle.Text = "Categories"

        --// Update GridLayout
        Util.CategoryGridLayout(self.GridLayout)

        --// Cleanup janitors
        self.Category_Janitor:Cleanup()
        self.BuildJanitor:Cleanup()

        --// create category Buttons
        for CategoryIndex, Category in ipairs(Categories) do
            local Button = Util.CreateCategoryButton(Category)
            Button.Parent = self.ItemList
            Button.Name = CategoryIndex
            --// check if user has the gamepass in data if not then check if user owns it. if any are true then don't add purchase text
            local OwnsCategory = if self.PlacementObjectData.CategoryPurchaseRequire[Category] then Util.UserOwnsCategory(self.PlayerData, self.Player, Category) else true
           
            if not OwnsCategory then
                local OverlayButton : TextButton = Util.CreatePurchaseCategoryOverlay()
                OverlayButton.Parent = Button
                self.Category_Janitor:Add(OverlayButton.Activated:Connect(function()
                        Util.PromptCategoryPurchase(self.Player, Category)
                    end)
                )
            end

            self.Category_Janitor:Add(
                Button.Activated:Connect(function()
                    OwnsCategory = if self.PlacementObjectData.CategoryPurchaseRequire[Category] then Util.UserOwnsCategory(self.PlayerData, self.Player, Category) else true
                    if OwnsCategory then
                        self:LoadCategory(Category, isBuild)
                    end
                end)
            )
        end

        self.ObjectFrame.Visible = true
    end
end

function PlacementController:DeleteMode()
    self:SetDefault()

    PlacementController:PromptCancelFrame("Delete Mode")
    
    self.State = "DeleteMode"
    if self.SelectionBox.Parent == nil  then 
        self.SelectionBox = Util.CreateSelectionBox(Color3.fromRGB(255,0,0)) 
    end
    self.SelectionBox.Color3 = Color3.fromRGB(255,0,0)

    --// check for players base
    if self.Base  == nil then 
        PlayerService.GetPlayerBase():andThen(function(base)
            self.Base = base
        end):await()
    end


    self.BuildJanitor:Add(UserInputService.InputChanged:Connect(function(InputObject)
        print("Firing")
        if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.MouseMovement or  InputObject.UserInputType == Enum.UserInputType.Touch then
            print("Fired")
           local target = Mouse.Target 
           self.SelectionBox.Adornee = nil
           if not target then return end
           local targetParent = Mouse.Target:FindFirstAncestorOfClass("Model")
           if targetParent then
                if targetParent:IsDescendantOf(self.Base.Objects) then
                    self.SelectionBox.Adornee = targetParent
                end
            end
        end
    end))

    self.BuildJanitor:Add(UserInputService.InputEnded:Connect(function(InputObject)
        if InputObject.UserInputType == Enum.UserInputType.MouseButton1 or InputObject.UserInputType == Enum.UserInputType.Touch then
           local target = Mouse.Target
           if not target then return end
           local targetParent = Mouse.Target:FindFirstAncestorOfClass("Model")
           if targetParent then
                if targetParent:IsDescendantOf(self.Base.Objects) then
                    self.SelectionBox.Adornee = targetParent
                    self.PlacementService:DestroyObject(targetParent)
                    self.Adornee = nil
                end
            end
        end
    end))
end

function PlacementController:Rotate()
    if self.SelectedObject then
        self.RotateButtonTween:Play()
        self.SelectedObject:PivotTo(self.SelectedObject.WorldPivot * CFrame.Angles(0,math.rad(90),0))
    end
end

function PlacementController:SetDefault()
    self.State = "Default"
    self.RotateButton.Visible = false
    self.CancelFrame.Visible = false
    self.ObjectFrame.Visible = false
    self.SelectedObjectJanitor:Cleanup()
    self.Category_Janitor:Cleanup()
    self.BuildJanitor:Cleanup()
    self.SelectedObject = nil
    if self.SelectionBox then
       self.SelectionBox.Adornee = nil 
    end
end

function PlacementController:KnitStart()
    local Assets = ReplicatedStorage.Assets
    local UI = Assets.UI
    PlacementObjects = Assets.PlacementObjects
    Weapons = Assets.Weapons
    --// Services
    PlayerService = Knit.GetService("PlayerService")
    PlayerDataService =  Knit.GetService("PlayerDataService")
    WeaponService = Knit.GetService("WeaponService")
    GamepassService = Knit.GetService("GamepassService")


    Util =  require(script.util)
    Config = require(script.config)

    self.PlacementObjects = Assets.PlacementObjects
    self.PlacementObjectData = require(ReplicatedStorage.Source.Modules.PlacementObjectData)
    
    self.WeaponData = require(ReplicatedStorage.Source.Modules.WeaponData)
    self.WeaponController = Knit.GetController("WeaponController")

    self.Player = Players.LocalPlayer
    self.PlayerData = nil --// PlayerData (cash..ect)
    PlayerDataService.GetData():andThen(function(Data)
        self.PlayerData = Data
    end):await()


    self.PlacementUI  = UI.Placement:Clone()
    self.PlacementUI.Parent = self.Player.PlayerGui

    -- Camera Used for ViewportFrame
    self.Camera = Instance.new("Camera")
    self.Camera.CFrame = CFrame.new()

    --// Selectionbox
    self.SelectionBox = Util.CreateSelectionBox(Color3.fromRGB(255,0,0))

    self.Base = nil
    self.State = "Default"

    --// connect buttons
    local MainButtons : Frame = self.PlacementUI.MainFrame
    local BuildButton : TextButton = MainButtons.BuildButton
    local DeleteButton : TextButton = MainButtons.DeleteButton
    local WeaponButton : TextButton = MainButtons.WeaponButton

    --//Object Frame
    self.ObjectFrame = self.PlacementUI.ObjectFrame
    self.ItemList = self.ObjectFrame.ItemList
    self.CloseButton = self.ObjectFrame.CloseButton
    self.GridLayout = self.ItemList.UIGridLayout

    --// Cancel Frame
    self.CancelFrame = self.PlacementUI.CancelFrame
    self.CancelButton = self.CancelFrame.CancelButton
    self.CancelTitle = self.CancelFrame.CancelTitle
    
    --// PurchaseProductFrame
    self.ProductPurchaseFrame = self.PlacementUI.ProductPurchaseFrame
    self.ProductBuyButton = self.ProductPurchaseFrame.BuyButton
    self.ProductCloseButton = self.ProductPurchaseFrame.CloseButton

    self.RotateButton = self.PlacementUI.RotateButton

    --//Janitors
    self._janitor = janitor.new()
    self.Category_Janitor = janitor.new()
    self.BuildJanitor = janitor.new()
    self.SelectedObjectJanitor = janitor.new()

    --// Tweens
    self.RotateButtonTween = TweenService:Create(self.RotateButton, Config.RotateTweenInfo, {Rotation = 45})

    --// Set GUI State
    self.State = "Default"

    self.PlacementService = Knit.GetService("PlacementService")

    WeaponButton.Activated:Connect(function()
        self:LoadCategories(self.WeaponData.CategoryList, false)
        self.WeaponController:Unequip()
    end)

    BuildButton.Activated:Connect(function(inputObject, clickCount)
        self:LoadCategories(self.PlacementObjectData.CategoryList, true)
        self.WeaponController:Unequip()
    end)

    DeleteButton.Activated:Connect(function(inputObject, clickCount)
        self:DeleteMode()
        self.WeaponController:Unequip()
    end)

    self.CloseButton.Activated:Connect(function()
        self:SetDefault()
        self.WeaponController:Equip()
        
    end)

    --// ProductBuyButton
    self.ProductBuyButton.Activated:Connect(function()
        local Weapon, Category = self.WeaponData.GetWeapon(self.ProductPurchaseFrame.Title.Text)
        if Weapon then
            WeaponService.HandleWeapon(self.Player, tostring(self.ProductPurchaseFrame.Title.Text), Category):andThen(function(newWeaponData)
                if newWeaponData.CurrentWeapon then
                    self.PlayerData.CurrentWeapon = newWeaponData.CurrentWeapon
                end
                if newWeaponData.Weapons then
                    self.PlayerData.Weapons = Weapons
                end
            end):await()
            self:LoadCategory(Category, false)
            self.ProductPurchaseFrame.Visible = false
        end
    end)

    self.ProductCloseButton.Activated:Connect(function()
        self.ProductPurchaseFrame.Visible = false
    end)

    --// rotate object
    self.RotateButton.Activated:Connect(function()
        self:Rotate()
    end)

    --// Update PlayerData on signal
    PlayerDataService.PlayerDataIsReady:Connect(function(data)
        self.PlayerData = data
    end)

    --//Update and connect cash
    MainButtons.Cash.Text = if self.PlayerData.Cash then "$" .. tostring(self.PlayerData.Cash) else "Error Loading Cash"
    PlayerDataService.CashUpdate:Connect(function(CashAmount : number)
        --// if new cash > Last Cash then "Adding" else "Removing" 
        local CashChangeState = if ((CashAmount - self.PlayerData.Cash) > 0) then "Adding" else "Removing"
        --// Time = changeAmount/10 clamped to .3, 5
       -- local CashTweenTime = math.clamp(math.abs(CashAmount - self.PlayerData.Cash)/10,.3, 5)
       -- local
        if CashChangeState  == "Adding" then
            MainButtons.Cash.Text = "$" .. tostring(CashAmount)
        else
            MainButtons.Cash.Text = "$" .. tostring(CashAmount)
        end
    end)

    --// update gamepass purchase
    GamepassService.Purchased:Connect(function(PurchasedID)
        print(PurchasedID)
        --// add gamepass to the players data
        table.insert(self.PlayerData.GamepassData, PurchasedID)
        --// get the name of gamepass (in this case we need it to know the category purchased)
        local GamepassName = Util.GetGamepassName(PurchasedID)
        --// after purchase tell the category to remove the Overlay
        Util.CategoryPurchased(self.ItemList, GamepassName)
    end)

    --// make the main UI visable after connections 
    MainButtons.Visible = true
end

function PlacementController:KnitInit()
    if not game:IsLoaded() then
      game.Loaded:Wait()
    end
end

return PlacementController