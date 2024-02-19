-- Services
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Imports
local Packages = ReplicatedStorage:WaitForChild("Packages")
local NewInputLabel = require(script.NewInputLabel)
local NewInputConnections = require(script.NewInputConnections)
local BuildTextLabels = require(script.BuildTextLabels)
local BuildFrames = require(script.BuildFrames)
local UpdateUIFromPrompt = require(script.UpdateUIFromPrompt)
local Fusion = require(Packages.Fusion)
local New = Fusion.New
local Hydrate = Fusion.Hydrate
local Value = Fusion.Value
local OnEvent = Fusion.OnEvent
local Cleanup = Fusion.cleanup
local Children = Fusion.Children
local Spring = Fusion.Spring
local Computed = Fusion.Computed

-- Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--[[
	@docs GetScreenGui
	@args nil
	@desc Returns the ScreenGui that the prompts will be parented to.
	@return ScreenGui
]]

local function GetScreenGui()
	local ScreenGui = PlayerGui:FindFirstChild("ProximityPrompts")

	if not ScreenGui then
		ScreenGui = New "ScreenGui" {
			Name = "ProximityPrompts",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			Parent = PlayerGui,
		}
	end

	return ScreenGui
end

--[[
	@docs CreatePrompt
	@args ProximityPrompt, Enum.ProximityPromptInputType, ScreenGui
	@desc Creates a prompt and returns a cleanup function.
	@return function
]]

local function CreatePrompt(prompt : ProximityPrompt, inputType : Enum.ProximityPromptInputType, gui : ScreenGui)
	local InputFrameScaleFactor = inputType == Enum.ProximityPromptInputType.Touch and 1.6 or 1.33
	local CurrentFrameScaleFactor = Value(1)
	local PromptTransparency = Value(1)
	local ButtonHeldDown = Value(false)
	local AspectRatioValue = Value(1)
	local CurrentBarSize = Value(0)

	local InputConnections : {RBXScriptConnection} = NewInputConnections {
		prompt = prompt,
		ButtonHeldDown = ButtonHeldDown,
		CurrentBarSize = CurrentBarSize,
		CurrentFrameScaleFactor = CurrentFrameScaleFactor,
		PromptTransparency = PromptTransparency,
		InputFrameScaleFactor = InputFrameScaleFactor,
	}

	local PromptUI = New "BillboardGui" {
		Name = "Prompt",
		AlwaysOnTop = true,
		Parent = gui,
		Adornee = prompt.Parent,

		StudsOffset = Spring(Computed(function()
			return PromptTransparency:get() < 1 and Vector3.new(0, 0, 0) or Vector3.new(-1, 0, 0)
		end), 15, 0.5)
	} :: BillboardGui

	local Frame : CanvasGroup, ResizeableInputFrame : Frame = unpack(BuildFrames(
		PromptUI,
		ButtonHeldDown,
		PromptTransparency,
		AspectRatioValue,
		CurrentBarSize,
		CurrentFrameScaleFactor
	))

	local ActionText : TextLabel, ObjectText : TextLabel = unpack(BuildTextLabels(
		Frame,
		ButtonHeldDown
	))

	Hydrate(ResizeableInputFrame) {
		[Children] = NewInputLabel(inputType, prompt)
	}

	if inputType == Enum.ProximityPromptInputType.Touch or prompt.ClickablePrompt then
		local buttonDown = false

		Hydrate(PromptUI) {
			Active = true,

			[Children] = {
				New "TextButton" {
					BackgroundTransparency = 1,
					TextTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					--Parent = PromptUI,
		
					[OnEvent "InputBegan"] = function(input)
						if
							(
								input.UserInputType == Enum.UserInputType.Touch
								or input.UserInputType == Enum.UserInputType.MouseButton1
							) and input.UserInputState ~= Enum.UserInputState.Change
						then
							prompt:InputHoldBegin()
							buttonDown = true
						end
					end,
		
					[OnEvent "InputEnded"] = function(input)
						if
							input.UserInputType == Enum.UserInputType.Touch
							or input.UserInputType == Enum.UserInputType.MouseButton1
						then
							if buttonDown then
								buttonDown = false
								prompt:InputHoldEnd()
							end
						end
					end,
				}
			}
		}
	end

	local function Update()
		UpdateUIFromPrompt(
			prompt,
			PromptUI,
			AspectRatioValue,
			ActionText,
			ObjectText
		)
	end

	InputConnections[# InputConnections+1] = prompt.Changed:Connect(Update)
	Update()

	PromptTransparency:set(0)

	return function() -- Cleanup callback
		Cleanup(InputConnections)
		PromptTransparency:set(1)
		task.wait(2)
		PromptUI:Destroy()
	end
end

--[[
	@docs Init
	@args nil
	@desc Initializes the module.
	@return nil
]]

local function Init()
	Hydrate(ProximityPromptService) {
		[OnEvent "PromptShown"] = function(prompt, inputType)
			if prompt.Style == Enum.ProximityPromptStyle.Default then
				prompt.Style = Enum.ProximityPromptStyle.Custom
			end

			local gui = GetScreenGui()

			local cleanupFunction = CreatePrompt(prompt, inputType, gui)

			prompt.PromptHidden:Wait()

			cleanupFunction()
		end
	}
end

Init()