local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lib = ReplicatedStorage:WaitForChild("Common"):WaitForChild("lib")
local AttributeHook = require(lib:WaitForChild("AttributeHook"))

local Connections = AttributeHook.BindAttributes(workspace) {
    {
        AttributeName = "foo",
        Callback = function(foo : number)
            print("foo changed to", foo)
        end
    },

    {
        AttributeName = "bar",
        Callback = function(bar : number)
            print("bar changed to", bar)
        end
    }
}

task.delay(15, function()
    for _, Connection in pairs(Connections) do
        if Connection.Connected then
            Connection:Disconnect()
        end
    end
end)