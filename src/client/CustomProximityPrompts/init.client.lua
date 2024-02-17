-- Constants
local GAMEPAD_BUTTON_IMAGE = require(script.GamepadButtonImage)
local KEYBOARD_BUTTON_IMAGE = require(script.KeyboardButtonImage)
local KEYBOARD_BUTTON_ICON_MAPPING = require(script.KeyboardButtonIconMapping)
local KEYCODE_TO_TEXT_MAPPING = require(script.KeyCodeToTextMapping)

-- Services
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Imports
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages.Fusion)
local New = Fusion.New
local Hydrate = Fusion.Hydrate
local Spring = Fusion.Spring
local Value = Fusion.Value
local OnEvent = Fusion.OnEvent
local Cleanup = Fusion.cleanup
local Children = Fusion.Children
local Computed = Fusion.Computed

-- Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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

local function createPrompt(prompt : ProximityPrompt, inputType, gui)
	local InputFrameScaleFactor = inputType == Enum.ProximityPromptInputType.Touch and 1.6 or 1.33
	local InputConnections = {}
	local CurrentFrameScaleFactor = Value(1)
	local PromptTransparency = Value(1)
	local ButtonHeldDown = Value(false)
	local AspectRatioValue = Value(1)
	local CurrentBarSize = Value(0)

	local PromptUI = New "BillboardGui" {
		Name = "Prompt",
		AlwaysOnTop = true,
		Parent = gui,
	}

	local Frame = New "CanvasGroup" {
		Size = Spring(Computed(function()
			return ButtonHeldDown:get() and UDim2.fromScale(0.5, 1) or UDim2.fromScale(1, 1)
		end), 20, 0.5),
		BackgroundTransparency = 0.5,
		GroupTransparency = Spring(PromptTransparency, 30, 1),
		BackgroundColor3 = Color3.new(0.07, 0.07, 0.07),
		Parent = PromptUI,

		[Children] = {
			New "UICorner" {
				CornerRadius = UDim.new(0, 16),
			},

			New "UIAspectRatioConstraint" {
				AspectRatio = Spring(Computed(function()
					return ButtonHeldDown:get() and 1 or AspectRatioValue:get()
				end), 20, 0.5),
			},

			New "Frame" {
				Name = "ProgressBar",
				Position = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0, 1),
				BorderSizePixel = 0,
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 0.5,
				Size = Computed(function()
					return UDim2.fromScale(CurrentBarSize:get(), 0.1)
				end),
			}
		},
	}

	local InputFrame = New "Frame" {
		Name = "InputFrame",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Parent = Frame,
	}

	local ResizeableInputFrame = New "Frame" {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = InputFrame,

		[Children] = {
			New "UIScale" {
				--Scale = InputFrameScaleFactor,
				Scale = Spring(CurrentFrameScaleFactor, 20, 0.7),
			},

			New "Frame" {
				Name = "RoundFrame",
				Size = UDim2.fromOffset(48, 48),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
		
				[Children] = {
					New "UICorner" {
						CornerRadius = UDim.new(0.5, 0),
					},
				}
			}
		}
	}

	local ActionText = New "TextLabel" {
		Name = "ActionText",
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamMedium,
		TextSize = 19,
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Frame,

		TextTransparency = Spring(Computed(function()
			return ButtonHeldDown:get() and 1 or 0
		end), 30, 1)
	}

	local ObjectText = New "TextLabel" {
		Name = "ObjectText",
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(0.7, 0.7, 0.7),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = Frame,

		TextTransparency = Spring(Computed(function()
			return ButtonHeldDown:get() and 1 or 0
		end), 30, 1)
	}

	if inputType == Enum.ProximityPromptInputType.Gamepad then
		if GAMEPAD_BUTTON_IMAGE[prompt.GamepadKeyCode] then
			local Icon = New "ImageLabel" {
				Name = "ButtonImage",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(24, 24),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				ImageTransparency = 1,
				Image = GAMEPAD_BUTTON_IMAGE[prompt.GamepadKeyCode],
				Parent = ResizeableInputFrame,
			}
		end
	elseif inputType == Enum.ProximityPromptInputType.Touch then
		local ButtonImage = New "ImageLabel" {
			Name = "ButtonImage",
			BackgroundTransparency = 1,
			ImageTransparency = 1,
			Size = UDim2.fromOffset(25, 31),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png",
			Parent = ResizeableInputFrame,
		}
	else
		local AddedChildren = {}
		local buttonTextString = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)

		local buttonTextImage = KEYBOARD_BUTTON_IMAGE[prompt.KeyboardKeyCode]
		if buttonTextImage == nil then
			buttonTextImage = KEYBOARD_BUTTON_ICON_MAPPING[buttonTextString]
		end

		if buttonTextImage == nil then
			local keyCodeMappedText = KEYCODE_TO_TEXT_MAPPING[prompt.KeyboardKeyCode]
			if keyCodeMappedText then
				buttonTextString = keyCodeMappedText
			end
		end

		AddedChildren[#AddedChildren + 1] = New "ImageLabel" {
			Name = "ButtonImage",
			BackgroundTransparency = 1,
			--ImageTransparency = 1,
			Size = UDim2.fromOffset(28, 30),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Image = "rbxasset://textures/ui/Controls/key_single.png",
		}

		if buttonTextImage then
			AddedChildren[#AddedChildren + 1] = New "ImageLabel" {
				Name = "ButtonImage",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(36, 36),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				--ImageTransparency = 1,
				Image = buttonTextImage,
			}
		elseif buttonTextString ~= nil and buttonTextString ~= "" then
			AddedChildren[#AddedChildren + 1] = New "TextLabel" {
				Name = "ButtonText",
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromOffset(0, -1),
				Font = Enum.Font.GothamMedium,
				TextSize = if string.len(buttonTextString) > 2 then 12 else 14,
				BackgroundTransparency = 1,
				--TextTransparency = 1,
				TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Center,
				Text = buttonTextString,
			}
		else
			error(
				"ProximityPrompt '"
					.. prompt.Name
					.. "' has an unsupported keycode for rendering UI: "
					.. tostring(prompt.KeyboardKeyCode)
			)
		end

		Hydrate(ResizeableInputFrame) {
			[Children] = AddedChildren
		}
	end

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

	InputConnections[#InputConnections + 1] = RunService.RenderStepped:Connect(function(deltaTime)
		if ButtonHeldDown:get() then
			CurrentBarSize:set(math.min(CurrentBarSize:get() + deltaTime / prompt.HoldDuration, 1))
		else
			CurrentBarSize:set(0)
		end
	end)

	if prompt.HoldDuration > 0 then
		InputConnections[#InputConnections + 1] = prompt.PromptButtonHoldBegan:Connect(function()
			ButtonHeldDown:set(true)
			CurrentFrameScaleFactor:set(InputFrameScaleFactor)
		end)

		InputConnections[#InputConnections + 1] = prompt.PromptButtonHoldEnded:Connect(function()
			ButtonHeldDown:set(false)
			CurrentFrameScaleFactor:set(1)
		end)
	end

	InputConnections[#InputConnections + 1] = prompt.Triggered:Connect(function()
		PromptTransparency:set(1)
	end)

	InputConnections[#InputConnections + 1] = prompt.TriggerEnded:Connect(function()
		PromptTransparency:set(1)
	end)

	local function updateUIFromPrompt()
		local actionTextSize = TextService:GetTextSize(
			prompt.ActionText,
			19,
			Enum.Font.GothamMedium,
			Vector2.new(1000, 1000)
		)

		local objectTextSize = TextService:GetTextSize(
			prompt.ObjectText,
			14,
			Enum.Font.GothamMedium,
			Vector2.new(1000, 1000)
		)

		local maxTextWidth = math.max(actionTextSize.X, objectTextSize.X)
		local promptHeight = 72
		local promptWidth = 72
		local textPaddingLeft = 72

		if
			(prompt.ActionText ~= nil and prompt.ActionText ~= "")
			or (prompt.ObjectText ~= nil and prompt.ObjectText ~= "")
		then
			promptWidth = maxTextWidth + textPaddingLeft + 24
		end

		local actionTextYOffset = 0
		if prompt.ObjectText ~= nil and prompt.ObjectText ~= "" then
			actionTextYOffset = 9
		end

		Hydrate(ActionText) {
			Position = UDim2.new(0.5, textPaddingLeft - promptWidth / 2, 0, actionTextYOffset),
			Text = prompt.ActionText,
			AutoLocalize = prompt.AutoLocalize,
			RootLocalizationTable = prompt.RootLocalizationTable,
		}

		Hydrate(ObjectText) {
			Position = UDim2.new(0.5, textPaddingLeft - promptWidth / 2, 0, -10),
			Text = prompt.ObjectText,
			AutoLocalize = prompt.AutoLocalize,
			RootLocalizationTable = prompt.RootLocalizationTable,
		}

		PromptUI.Size = UDim2.fromOffset(promptWidth, promptHeight)
		PromptUI.SizeOffset = Vector2.new(
			prompt.UIOffset.X / PromptUI.Size.Width.Offset,
			prompt.UIOffset.Y / PromptUI.Size.Height.Offset
		)

		AspectRatioValue:set(promptWidth / promptHeight)
	end

	InputConnections[# InputConnections+1] = prompt.Changed:Connect(updateUIFromPrompt)
	updateUIFromPrompt()

	PromptUI.Adornee = prompt.Parent
	PromptUI.Parent = gui

	PromptTransparency:set(0)

	return function() -- Cleanup
		Cleanup(InputConnections)
		task.delay(0.2, Cleanup, PromptUI)
		PromptTransparency:set(1)
	end
end

local function Init()
	Hydrate(ProximityPromptService) {
		[OnEvent "PromptShown"] = function(prompt, inputType)
			if prompt.Style == Enum.ProximityPromptStyle.Default then
				prompt.Style = Enum.ProximityPromptStyle.Custom
			end

			local gui = GetScreenGui()

			local cleanupFunction = createPrompt(prompt, inputType, gui)

			prompt.PromptHidden:Wait()

			cleanupFunction()
		end
	}
end

Init()