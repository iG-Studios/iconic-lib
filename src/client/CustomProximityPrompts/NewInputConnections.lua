-- Types
type Properties = {
    prompt: ProximityPrompt,
    ButtonHeldDown: any,
    CurrentBarSize: any,
    CurrentFrameScaleFactor: any,
    PromptTransparency: any,
    InputFrameScaleFactor: any,
}

-- Constants
local APPEAR_SOUND = "rbxassetid://10066931761"
local CLICK_SOUND = "rbxassetid://10128760939"
local HOLD_SOUND = "rbxassetid://421058925"
local TRIGGER_SOUND = "rbxassetid://10128766965"

-- Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Imports
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Hydrate = Fusion.Hydrate

--[[
	@docs PlaySound
	@desc Plays a sound with the given SoundId and optional hydrated properties
	@param SoundId : string
	@param Properties : {[string]: any}?
	@returns nil
]]

local function PlaySound(SoundId, Properties : {[string]: any}?)
	local Sound = script:FindFirstChild(SoundId)

	if not Sound then
		Sound = New "Sound" {
			Name = SoundId,
			SoundId = SoundId,
			Volume = 0.35,
			Parent = script,
		}

		if Properties then
			Hydrate(Sound)(Properties)
		end
	end

	Sound:Play()
end

--[[
	@docs StopSound
	@desc Stops the sound with the given SoundId
	@param SoundId : string
	@returns nil
]]

local function StopSound(SoundId)
	local Sound = script:FindFirstChild(SoundId)

	if Sound then
		Sound:Stop()
	end
end

--[[
	@docs NewInputConnections
	@desc Creates new input connections for the given properties
	@param Properties : Properties
	@returns {RBXScriptConnection}
]]

return function(Properties : Properties) : {RBXScriptConnection}
    local InputConnections = {}
	local HoldStart = os.clock()

	PlaySound(APPEAR_SOUND)

    InputConnections[#InputConnections + 1] = RunService.RenderStepped:Connect(function(deltaTime)
		local TimeHeldDown = os.clock() - HoldStart

		if Properties.ButtonHeldDown:get() then
			Properties.CurrentBarSize:set(math.min(Properties.CurrentBarSize:get() + deltaTime / Properties.prompt.HoldDuration, 1))

			script:FindFirstChild(HOLD_SOUND).PlaybackSpeed = 0.5 + TimeHeldDown * 1
		else
			Properties.CurrentBarSize:set(0)
		end
	end)

	if Properties.prompt.HoldDuration > 0 then
		InputConnections[#InputConnections + 1] = Properties.prompt.PromptButtonHoldBegan:Connect(function()
			HoldStart = os.clock()
			PlaySound(HOLD_SOUND, {
				Looped = true,
				Volume = 0.2,
			})
			PlaySound(CLICK_SOUND)
			Properties.ButtonHeldDown:set(true)
			Properties.CurrentFrameScaleFactor:set(Properties.InputFrameScaleFactor)
		end)

		InputConnections[#InputConnections + 1] = Properties.prompt.PromptButtonHoldEnded:Connect(function()
			StopSound(HOLD_SOUND)
			Properties.ButtonHeldDown:set(false)
			Properties.CurrentFrameScaleFactor:set(1)
		end)
	end

	InputConnections[#InputConnections + 1] = Properties.prompt.Triggered:Connect(function()
		if Properties.prompt.HoldDuration > 0 then
			PlaySound(TRIGGER_SOUND)
		else
			PlaySound(CLICK_SOUND)
		end

		--Properties.PromptTransparency:set(1)
	end)

	-- InputConnections[#InputConnections + 1] = Properties.prompt.TriggerEnded:Connect(function()
	-- 	--Properties.PromptTransparency:set(1)
	-- end)

    return InputConnections
end