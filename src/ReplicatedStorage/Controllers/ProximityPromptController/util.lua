local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

--//Assets
local Assets = ReplicatedStorage.Assets
local ProximityPrompts = Assets.ProximityPrompts

--// data
local PlacementObjectData = require(ReplicatedStorage.Source.Modules.PlacementObjectData)

local util = {}
local config = require(script.Parent.config)

--[[function util.Template(prompt, inputType, gui)
	local PromptUI = ProximityPrompts[prompt.Name]:Clone()
	
	local MainFrame = PromptUI:WaitForChild("Frame")
	
	local ActionText = MainFrame:WaitForChild("Action")
	
	local InputFrame = MainFrame:WaitForChild("InputFrame"):WaitForChild("Frame")
	local InputText = InputFrame:WaitForChild("ButtonText")
	local InputImage = InputFrame:WaitForChild("ButtonImage")
	
	local ActionBarFrame = MainFrame:WaitForChild("ActionBar")
	local ActionBar = ActionBarFrame:WaitForChild("Bar")
	

	-- set all information need into the UI
	local function UpdatePromptUI()
		ActionText.Text = prompt.ActionText
		
		if inputType == Enum.ProximityPromptInputType.Gamepad then
			if config.GamepadButtonImage[prompt.GamepadKeyCode] then
				InputImage.Image = config.GamepadButtonImage[prompt.GamepadKeyCode]
			end
		elseif inputType == Enum.ProximityPromptInputType.Touch then
			InputImage.Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png"
		else
			InputImage.Image = "rbxasset://textures/ui/Controls/key_single.png"
			local InputString = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)
			
			local InputTextImage = config.KeyboardButtonImage[prompt.KeyboardKeyCode]
			if InputTextImage == nil then
				InputTextImage = config.KeyboardButtonIconMapping[InputString]
			end
			
			if InputTextImage == nil then
				local KeyCodeMappedText = config.KeyCodeToTextMapping[prompt.KeyboardKeyCode]
				if KeyCodeMappedText then
					InputString = KeyCodeMappedText
				end
			end			
			
			if InputTextImage then
				InputImage.Image = InputTextImage
			elseif InputString ~= nil and InputString ~= "" then
				InputText.Text = InputString
			else
				error("Warning failed to map a keycode. Possibly Unsupported")
			end
		end
	end
	UpdatePromptUI()
	
	--TweenObjects
	local TextTweenTable = {
		ActionText,
		InputText
	}
	
	local FrameTweenTable = {
		ActionBarFrame,
		MainFrame
	}
	
	--Tween Tables
	local TweenFadeOut = {}
	local TweenFadeIn = {}
	local TweenHoldBegin = {}
	local TweenHoldEnd = {}
	local TweenInfoData = TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfoInFullDuration = TweenInfo.new(prompt.HoldDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tweenInfoOutHalfSecond = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	--TextTween
	for _, child in ipairs(TextTweenTable) do
		table.insert(TweenFadeOut, TweenService:Create(child, TweenInfoData, {TextTransparency = 1}))
		table.insert(TweenFadeIn,  TweenService:Create(child, TweenInfoData, {TextTransparency = 0}))
	end
	
	--Frame
	for _, child in ipairs(FrameTweenTable) do
		table.insert(TweenFadeOut, TweenService:Create(child, TweenInfoData, {BackgroundTransparency = 1, Visible = false}))
		table.insert(TweenFadeIn,  TweenService:Create(child, TweenInfoData, {BackgroundTransparency = child.BackgroundTransparency, Visible = true}))
	end
	
	-- check if it has a duration
	if prompt.HoldDuration > 0 then
		table.insert(TweenHoldBegin, TweenService:Create(ActionBar, tweenInfoInFullDuration, {  Size = UDim2.fromScale(1,1) }))
		table.insert(TweenHoldEnd, TweenService:Create(ActionBar, tweenInfoOutHalfSecond, { Size = UDim2.fromScale(0,1) }))
	end

	-- Connect Trigger events
	local TriggredConnection
	local TriggredEndedConnection
	local HoldBeganConnection
	local HoldEndedConnection
	
	TriggredConnection = prompt.Triggered:Connect(function()
		for _, Tweens in ipairs(TweenFadeOut) do
			Tweens:Play()
		end
	end)
	
	TriggredEndedConnection = prompt.TriggerEnded:Connect(function()
		for _, Tweens in ipairs(TweenFadeIn) do
			Tweens:Play()
		end
	end)
	
	-- make clicking prompts work and touching
	if inputType == Enum.ProximityPromptInputType.Touch or prompt.ClickablePrompt then
		local button = PromptUI:WaitForChild("TextButton")
		
		local ButtonDown = false
		
		button.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1)
				and input.UserInputState ~= Enum.UserInputState.Change then
				prompt:InputHoldBegin()
				ButtonDown = true
			end
		end)
		
		button.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				if ButtonDown then
					ButtonDown = false
					prompt:InputHoldEnd()
				end
			end
		end)
	end
	
	-- Connect hold events
	if prompt.HoldDuration > 0 then
		HoldBeganConnection = prompt.PromptButtonHoldBegan:Connect(function()
			for _, tween in ipairs(TweenHoldBegin) do
				tween:Play()
			end
		end)

		HoldEndedConnection = prompt.PromptButtonHoldEnded:Connect(function()
			for _, tween in ipairs(TweenHoldEnd) do
				tween:Play()
			end
		end)
	end
	
	PromptUI.Parent = gui
	
	local function cleanup()
		TriggredConnection:Disconnect()
		TriggredEndedConnection:Disconnect()
		
		for _, Tweens in ipairs(TweenFadeOut) do
			Tweens:Play()
		end
		
		task.wait(.2)
		
		PromptUI.Parent = nil
	end
	return cleanup
end]]

function util.ObjectPrompt(prompt, inputType)
    local PromptUI = ProximityPrompts[prompt.Name]:Clone()
	
	local MainFrame : Frame = PromptUI.Status
	
    local HealthBar : Frame = MainFrame.HealthBar
    local Health : Frame = HealthBar.Health
    local HealthText : TextLabel = HealthBar.HealthText
	
    local ObjectHealth : NumberValue = prompt.Parent:WaitForChild("Health")

    local ObjectData = PlacementObjectData.GetObject(prompt.Parent.Name)

	-- set all information need into the UI
	local function UpdatePromptUI()
		HealthText.Text = ObjectHealth.Value
		Health.Size = UDim2.new(ObjectHealth.Value/ObjectData.Health, 0, 1, 0)
	end
	UpdatePromptUI()


	local HealthChangedConnection = ObjectHealth:GetPropertyChangedSignal("Value"):Connect(function()
        UpdatePromptUI()
    end)
	
	
	PromptUI.Parent = prompt.Parent
	
	local function cleanup()
		HealthChangedConnection:Disconnect()
		PromptUI.Parent = nil
	end
	return cleanup
end

function util.DoorPrompt(prompt, inputType)
    local PromptUI = ProximityPrompts[prompt.Name]:Clone()
	
	local MainFrame : Frame = PromptUI.Status
	
    local HealthBar : Frame = MainFrame.HealthBar
    local Health : Frame = HealthBar.Health
    local HealthText : TextLabel = HealthBar.HealthText
	
	local ActionText = MainFrame:WaitForChild("Action")
	
	local InputFrame = MainFrame:WaitForChild("InputFrame"):WaitForChild("Frame")
	local InputText = InputFrame:WaitForChild("ButtonText")
	local InputImage = InputFrame:WaitForChild("ButtonImage")
	
	local ActionBarFrame = MainFrame:WaitForChild("ActionBar")
	local ActionBar = ActionBarFrame:WaitForChild("Bar")

    local ObjectHealth : NumberValue = prompt.Parent:WaitForChild("Health")

    local ObjectData = PlacementObjectData.GetObject(prompt.Parent.Name)

	-- set all information need into the UI
	local function UpdatePromptUI()
		HealthText.Text = ObjectHealth.Value
		Health.Size = UDim2.new(ObjectHealth.Value/ObjectData.Health, 0, 1, 0)

		ActionText.Text = prompt.ActionText
		
		if inputType == Enum.ProximityPromptInputType.Gamepad then
			if config.GamepadButtonImage[prompt.GamepadKeyCode] then
				InputImage.Image = config.GamepadButtonImage[prompt.GamepadKeyCode]
			end
		elseif inputType == Enum.ProximityPromptInputType.Touch then
			InputImage.Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png"
		else
			InputImage.Image = "rbxasset://textures/ui/Controls/key_single.png"
			local InputString = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)
			
			local InputTextImage = config.KeyboardButtonImage[prompt.KeyboardKeyCode]
			if InputTextImage == nil then
				InputTextImage = config.KeyboardButtonIconMapping[InputString]
			end
			
			if InputTextImage == nil then
				local KeyCodeMappedText = config.KeyCodeToTextMapping[prompt.KeyboardKeyCode]
				if KeyCodeMappedText then
					InputString = KeyCodeMappedText
				end
			end			
			
			if InputTextImage then
				InputImage.Image = InputTextImage
			elseif InputString ~= nil and InputString ~= "" then
				InputText.Text = InputString
			else
				error("Warning failed to map a keycode. Possibly Unsupported")
			end
		end
	end
	UpdatePromptUI()


	local HealthChangedConnection = ObjectHealth:GetPropertyChangedSignal("Value"):Connect(function()
        HealthText.Text = ObjectHealth.Value
		Health.Size = UDim2.new(ObjectHealth.Value/ObjectData.Health, 0, 1, 0)
    end)
	
		--TweenObjects
		local TextTweenTable = {
			ActionText,
			InputText
		}
		
		local FrameTweenTable = {
			ActionBarFrame,
			MainFrame
		}
		
		--Tween Tables
		local TweenFadeOut = {}
		local TweenFadeIn = {}
		local TweenHoldBegin = {}
		local TweenHoldEnd = {}
		local TweenInfoData = TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tweenInfoInFullDuration = TweenInfo.new(prompt.HoldDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local tweenInfoOutHalfSecond = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		
		--TextTween
		for _, child in ipairs(TextTweenTable) do
			table.insert(TweenFadeOut, TweenService:Create(child, TweenInfoData, {TextTransparency = 1}))
			table.insert(TweenFadeIn,  TweenService:Create(child, TweenInfoData, {TextTransparency = 0}))
		end
		
		--Frame
		for _, child in ipairs(FrameTweenTable) do
			table.insert(TweenFadeOut, TweenService:Create(child, TweenInfoData, {BackgroundTransparency = 1, Visible = false}))
			table.insert(TweenFadeIn,  TweenService:Create(child, TweenInfoData, {BackgroundTransparency = child.BackgroundTransparency, Visible = true}))
		end
		
		-- check if it has a duration
		if prompt.HoldDuration > 0 then
			table.insert(TweenHoldBegin, TweenService:Create(ActionBar, tweenInfoInFullDuration, {  Size = UDim2.fromScale(1,1) }))
			table.insert(TweenHoldEnd, TweenService:Create(ActionBar, tweenInfoOutHalfSecond, { Size = UDim2.fromScale(0,1) }))
		end
	
		-- Connect Trigger events
		local TriggredConnection
		local TriggredEndedConnection
		local HoldBeganConnection
		local HoldEndedConnection
		
		TriggredConnection = prompt.Triggered:Connect(function()
			for _, Tweens in ipairs(TweenFadeOut) do
				Tweens:Play()
			end
		end)
		
		TriggredEndedConnection = prompt.TriggerEnded:Connect(function()
			for _, Tweens in ipairs(TweenFadeIn) do
				Tweens:Play()
			end
		end)
	-- make clicking prompts work and touching
	if inputType == Enum.ProximityPromptInputType.Touch or prompt.ClickablePrompt then
		local button = PromptUI:WaitForChild("TextButton")
		
		local ButtonDown = false
		
		button.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1)
				and input.UserInputState ~= Enum.UserInputState.Change then
				prompt:InputHoldBegin()
				ButtonDown = true
			end
		end)
		
		button.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				if ButtonDown then
					ButtonDown = false
					prompt:InputHoldEnd()
				end
			end
		end)
	end

	-- Connect hold events
	if prompt.HoldDuration > 0 then
		HoldBeganConnection = prompt.PromptButtonHoldBegan:Connect(function()
			for _, tween in ipairs(TweenHoldBegin) do
				tween:Play()
			end
		end)

		HoldEndedConnection = prompt.PromptButtonHoldEnded:Connect(function()
			for _, tween in ipairs(TweenHoldEnd) do
				tween:Play()
			end
		end)
	end


	PromptUI.Adornee = prompt.Parent
	PromptUI.Parent = Players.LocalPlayer.PlayerGui
	
	local function cleanup()
		HealthChangedConnection:Disconnect()
		TriggredConnection:Disconnect()
		TriggredEndedConnection:Disconnect()

		if HoldBeganConnection or HoldEndedConnection then
			HoldBeganConnection:Disconnect()
			HoldEndedConnection:Disconnect()
		end

		PromptUI.Parent = nil
	end
	return cleanup
end


return util