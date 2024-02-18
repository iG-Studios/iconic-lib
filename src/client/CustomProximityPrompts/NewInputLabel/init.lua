local INPUT_KEY_LABELS = {
    [Enum.ProximityPromptInputType.Gamepad] = require(script.Gamepad),
    [Enum.ProximityPromptInputType.Touch] = require(script.Touch),
    ["Default"] = require(script.Keyboard),
}

return function(inputType, prompt)
    local Component = INPUT_KEY_LABELS[inputType] or INPUT_KEY_LABELS["Default"]

    return Component(prompt)
end