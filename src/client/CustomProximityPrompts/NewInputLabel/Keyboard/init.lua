-- Constants
local KEYBOARD_BUTTON_IMAGE = require(script.KeyboardButtonImage)
local KEYBOARD_BUTTON_ICON_MAPPING = require(script.KeyboardButtonIconMapping)
local KEYCODE_TO_TEXT_MAPPING = require(script.KeyCodeToTextMapping)

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Imports
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages.Fusion)
local New = Fusion.New

return function(prompt)
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
    
    return AddedChildren
end