-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

-- Imports
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages.Fusion)
local Hydrate = Fusion.Hydrate

--[[
    @docs UpdateUIFromPrompt
    @desc Updates the UI of the prompt based on the prompt's properties and text size
    @param Prompt : ProximityPrompt
    @param PromptUI : BillboardGui
    @param AspectRatioValue : any
    @param ActionText : TextLabel
    @param ObjectText : TextLabel
    @returns nil
]]

return function(Prompt : ProximityPrompt, PromptUI : BillboardGui, AspectRatioValue : any, ActionText : TextLabel, ObjectText : TextLabel)
    local actionTextSize = TextService:GetTextSize(
        Prompt.ActionText,
        19,
        Enum.Font.GothamMedium,
        Vector2.new(1000, 1000)
    )

    local objectTextSize = TextService:GetTextSize(
        Prompt.ObjectText,
        14,
        Enum.Font.GothamMedium,
        Vector2.new(1000, 1000)
    )

    local maxTextWidth = math.max(actionTextSize.X, objectTextSize.X)
    local promptHeight = 72
    local promptWidth = 72
    local textPaddingLeft = 72

    if
        (Prompt.ActionText ~= nil and Prompt.ActionText ~= "")
        or (Prompt.ObjectText ~= nil and Prompt.ObjectText ~= "")
    then
        promptWidth = maxTextWidth + textPaddingLeft + 24
    end

    local actionTextYOffset = 0
    if Prompt.ObjectText ~= nil and Prompt.ObjectText ~= "" then
        actionTextYOffset = 9
    end

    Hydrate(ActionText) {
        Position = UDim2.new(0.5, textPaddingLeft - promptWidth / 2, 0, actionTextYOffset),
        Text = Prompt.ActionText,
        AutoLocalize = Prompt.AutoLocalize,
        RootLocalizationTable = Prompt.RootLocalizationTable,
    }

    Hydrate(ObjectText) {
        Position = UDim2.new(0.5, textPaddingLeft - promptWidth / 2, 0, -10),
        Text = Prompt.ObjectText,
        AutoLocalize = Prompt.AutoLocalize,
        RootLocalizationTable = Prompt.RootLocalizationTable,
    }

    PromptUI.Size = UDim2.fromOffset(promptWidth, promptHeight)
    PromptUI.SizeOffset = Vector2.new(
        Prompt.UIOffset.X / PromptUI.Size.Width.Offset,
        Prompt.UIOffset.Y / PromptUI.Size.Height.Offset
    )

    AspectRatioValue:set(promptWidth / promptHeight)
end