--[[
    Usage: local Import, Query, GetContents = _G.GetQueryMethods()
    OR: local Import, Query, GetContents = require(Path.To.Queries).GetQueryMethods()
]]

-- Constants
local SOURCE_LOOKUP_TIMEOUT = 5

--[=[
    Returns the path of the file that called the function.

    @param Traceback string
    @return string
]=]

local function GetTracebackAsPath(Traceback : string) : string
    local PathBreakdown = string.split(Traceback, "\n")
    local PathRaw = PathBreakdown[#PathBreakdown - 1]
    local Path = string.sub(PathRaw, 1, string.find(PathRaw, ":", 1, true) - 1):gsub(" ", ""):gsub("\t", ""):gsub("%.", `/`)

    return Path
end

--[=[
    Converts a path to a source object, may yeild if the source object does not exist explicitly.

    @param Path string
    @param HighestSource Instance?
    @return Instance
    @yields
]=]

local function ConvertPathToSource(Path : string, HighestSource : Instance?)
    if Path:sub(Path:len(), Path:len()) == "/" then
        Path = Path:sub(1, Path:len() - 1)
    end

    local IsHighestLevel = if Path:sub(1, 1) == "." then true else false
    local Source = if IsHighestLevel then HighestSource else game

    for _, ObjectName in string.split(Path, "/") do
        local LastSource = Source
        
        if ObjectName == "" then
            Source = game
        elseif ObjectName == "." then
            Source = HighestSource
        elseif ObjectName == ".." then
            Source = Source.Parent
        else
            Source = Source:FindFirstChild(ObjectName) or Source:WaitForChild(ObjectName, SOURCE_LOOKUP_TIMEOUT)
        end

        if not Source then
            error(`{LastSource:GetFullName():gsub("%.", `/`)}/{ObjectName} does not exist`)
        end
    end

    return Source
end

--[=[
    Imports a module from a path, may require the module if it is a ModuleScript.

    @param Path string
    @return any
]=]

function _G.Import(Path: string)
    local Traceback = debug.traceback()
    local SourcePath = GetTracebackAsPath(Traceback)
    local Source = ConvertPathToSource(SourcePath)
    local Result = ConvertPathToSource(Path, Source)

    return if Result:IsA("ModuleScript") then
        require(Result)
    else
        Result
end

--[=[
    Queries a module from a path under the assumption that the module is a function.

    @param QueryName string
    @param ... any
    @return any
]=]

function _G.Query(QueryName: string, ...)
    QueryName = `_query{QueryName}`

    local Query = game:FindFirstChild(QueryName, true)
    local SearchBegin = os.clock()

    while not Query or os.clock() - SearchBegin >= SOURCE_LOOKUP_TIMEOUT do
        Query = game:FindFirstChild(QueryName)
        task.wait()
    end

    if Query then
        return require(Query)(...)
    end
end

--[=[
    Returns the contents of a package.
    If the package is an instance, it returns the required module children.
    If the package is a table or required module, it returns a function to specify keys to return.

    @param Package {[string] : any?} | Instance
    @return {[string] : any?} | function
]=]

function _G.GetContents(Package : {[string] : any?} | Instance)
    if typeof(Package) == "Instance" then
        local PackageContents = {}

        for _, Child in ipairs(Package:GetChildren()) do
            if Child:IsA("ModuleScript") then
                PackageContents[Child.Name] = require(Child)
            end
        end

        return PackageContents
    end

    return function(PackageContents : {[number] : any?})
        local Contents = {}

        for Index, Value in ipairs(PackageContents) do
            Contents[Index] = Package[Value]
        end

        return unpack(Contents)
    end
end

--[=[
    Returns the query methods.

    @return {any}
]=]

function _G.GetQueryMethods()
    return _G.GetContents(_G) {"Import", "Query", "GetContents"}
end

return _G