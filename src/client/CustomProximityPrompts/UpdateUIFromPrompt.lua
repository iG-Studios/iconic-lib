-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

-- Imports
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages.Fusion)
local Hydrate = Fusion.Hydrate

return function(prompt, PromptUI, AspectRatioValue, ActionText, ObjectText)
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