-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Imports
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages.Fusion)
local New = Fusion.New
local Computed = Fusion.Computed
local Spring = Fusion.Spring

return function(ParentFrame, ButtonHeldDown)
    local ActionText = New "TextLabel" {
		Name = "ActionText",
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamMedium,
		TextSize = 19,
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = ParentFrame,

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
		Parent = ParentFrame,

		TextTransparency = Spring(Computed(function()
			return ButtonHeldDown:get() and 1 or 0
		end), 30, 1)
	}

    return {ActionText, ObjectText}
end