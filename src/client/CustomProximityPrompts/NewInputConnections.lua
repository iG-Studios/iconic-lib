type Properties = {
    prompt: ProximityPrompt,
    ButtonHeldDown: any,
    CurrentBarSize: any,
    CurrentFrameScaleFactor: any,
    PromptTransparency: any,
    InputFrameScaleFactor: any,
}

local RunService = game:GetService("RunService")

return function(Properties : Properties) : {RBXScriptConnection}
    local InputConnections = {}

    InputConnections[#InputConnections + 1] = RunService.RenderStepped:Connect(function(deltaTime)
		if Properties.ButtonHeldDown:get() then
			Properties.CurrentBarSize:set(math.min(Properties.CurrentBarSize:get() + deltaTime / Properties.prompt.HoldDuration, 1))
		else
			Properties.CurrentBarSize:set(0)
		end
	end)

	if Properties.prompt.HoldDuration > 0 then
		InputConnections[#InputConnections + 1] = Properties.prompt.PromptButtonHoldBegan:Connect(function()
			Properties.ButtonHeldDown:set(true)
			Properties.CurrentFrameScaleFactor:set(Properties.InputFrameScaleFactor)
		end)

		InputConnections[#InputConnections + 1] = Properties.prompt.PromptButtonHoldEnded:Connect(function()
			Properties.ButtonHeldDown:set(false)
			Properties.CurrentFrameScaleFactor:set(1)
		end)
	end

	InputConnections[#InputConnections + 1] = Properties.prompt.Triggered:Connect(function()
		Properties.PromptTransparency:set(1)
	end)

	InputConnections[#InputConnections + 1] = Properties.prompt.TriggerEnded:Connect(function()
		Properties.PromptTransparency:set(1)
	end)

    return InputConnections
end