-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Imports
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages.Fusion)
local New = Fusion.New
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Children = Fusion.Children

return function(PromptUI, ButtonHeldDown, PromptTransparency, AspectRatioValue, CurrentBarSize, CurrentFrameScaleFactor)
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

	return {Frame, ResizeableInputFrame}
end