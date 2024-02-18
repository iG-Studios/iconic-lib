-- Constants
local GAMEPAD_BUTTON_IMAGE = require(script.GamepadButtonImage)

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Imports
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages.Fusion)
local New = Fusion.New

return function(prompt)
    if not GAMEPAD_BUTTON_IMAGE[prompt.GamepadKeyCode] then
        return
    end

    return {
        New "ImageLabel" {
            Name = "ButtonImage",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(24, 24),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 1,
            ImageTransparency = 1,
            Image = GAMEPAD_BUTTON_IMAGE[prompt.GamepadKeyCode],
        }
    }
end