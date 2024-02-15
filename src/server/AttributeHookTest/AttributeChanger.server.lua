local RunService = game:GetService("RunService")
local LastTick = os.clock()

RunService.Heartbeat:Connect(function()
    local CurrentTick = os.clock()

    if CurrentTick - LastTick >= 1 then
        LastTick = CurrentTick
        
        workspace:SetAttribute("foo", math.random(1, 100))
        workspace:SetAttribute("bar", math.random(1, 100))
    end
end)