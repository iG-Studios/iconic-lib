--[[
    @doc AttributeHook
    @credit Iconic Gaming LLC

    @description
    A module that allows you to bind to attribute changes on an object and execute a callback when the attribute changes.
    All connections are automatically disconnected when the object is destroyed or have its parent set to nil.

    @example

    local AttributeHook = require(MODULE_PATH.AttributeHook)
    local Player = Players.LocalPlayer

    local Connections = AttributeHook.BindAttributes(Player) {
        {
            AttributeName = "Health",
            Callback = function(Health : number)
                print("Health changed to", Health)
            end
        },

        {
            AttributeName = "MaxHealth",
            Callback = function(MaxHealth : number)
                print("MaxHealth changed to", MaxHealth)
            end
        }
    }

    -- Later on

    for _, Connection in pairs(Connections) do
        Connection:Disconnect()
    end
]]

local AttributeHook = {}

-- Types
type AttributeData = {
    Object : Instance,
    AttributeName : string,
    Callback : (...any) -> nil,
}

type AttributeBundle = {
    [number] : {
        AttributeName : string,
        Callback : (...any) -> nil,
    }
}

-- Public methods

--[[
    @doc AttributeHook.NewBind
    @param AttributeData : AttributeData
    @returns RBXScriptConnection
    @desc Creates a new bind for an attribute
]]

function AttributeHook.NewBind(AttributeData : AttributeData) : RBXScriptConnection
    local Object = AttributeData.Object
    local AttributeName = AttributeData.AttributeName
    local Callback = AttributeData.Callback

    local function OnAttributeChanged(InitValue : any?)
        local Value = InitValue or Object:GetAttribute(AttributeName)
        Callback(Value)
    end

    local RBXScriptConnection = Object:GetAttributeChangedSignal(AttributeName):Connect(OnAttributeChanged)

    task.spawn(OnAttributeChanged, Object:GetAttribute(AttributeName))

    Object.AncestryChanged:Connect(function()
        if not Object:IsDescendantOf(game) then
            RBXScriptConnection:Disconnect()
        end
    end)

    return RBXScriptConnection
end

--[[
    @doc AttributeHook.BindAttributes
    @param Object : Instance
    @returns ([number] : {AttributeName : string, Callback : (any...) -> nil}) -> {RBXScriptConnection}
]]

function AttributeHook.BindAttributes(Object : Instance) 
    return function(AttributeBundle : AttributeBundle) : {RBXScriptConnection}
        local Connections : {RBXScriptConnection} = {}

        for _, AttributeData in pairs(AttributeBundle) do
            Connections[#Connections + 1] = AttributeHook.NewBind {
                Object = Object,
                AttributeName = AttributeData.AttributeName,
                Callback = AttributeData.Callback,
            }
        end

        Object.AncestryChanged:Connect(function()
            if not Object:IsDescendantOf(game) then
                for Index, Connection in pairs(Connections) do
                    if Connection.Connected then
                        Connection:Disconnect()
                    end

                    Connections[Index] = nil
                end
            end
        end)

        return Connections
    end
end

return AttributeHook