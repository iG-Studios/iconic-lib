# Coding Conventions
*Iconic Gaming Coding conventions seek to increase clarity & readibility among code. Inspirations are from [here](https://github.com/luarocks/lua-style-guide) and [here](https://devforum.roblox.com/t/programming-guidelines-make-your-code-industry-standard/1293822). Under the assumption this is for Roblox's Luau language base*.

Go back to our guidelines [here](./index.md).

## Juxtaposition
The juxtaposition of information and instructions should be consistent to ensure that there are no problems with knowing where everything is.

At Iconic Gaming, we order information starting with (if all are applicable) module declaration, then types, constants, services, imports, types extended, variables, functions, class functions, and finally object methods. Any additional code not wrapped in a function or method after everything should be instead put into an `Init()` function which is called at the end of the script, returning nothing. If the script is a module, but `Init()` on the end of the return line.

"Types extended" are types that are generated from imports.

Imports are required modules. Before that, though, the top of the imports section should be variables for containing folders. Any variables that directly inherit from imports should be placed at the bottom.

Here is an example utilizing all data and information types:

```lua
local Class = {}
Class.__index = Class

-- Types
type Dictionary = {
    [string] : any,
}

-- Constants
local CONSTANT_A = 999
local CONSTANT_B = 111

-- Services
local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Imports
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages.Fusion)
local Module = require(script.Module)
local New = Fusion.New
local Spring = Fusion.Spring

-- Types extended
type ModuleType = typeof(ModuleType.Thing) && {
    A : number,
    B : number,
}

local function Foo()

end

local function Bar()

end

local function Init()
    Foo()
    Bar()
end

function Class.new()
    return self
end

function Class:Method()

end

return Class, Init()
```

## Indentation
Indentation should be done exclusively through the `TAB` key.

```lua
do
    do
        do
            -- Good indentation
        end
    end
end

do
   do
      do
         -- Bad indentation
      end
    end
end
```

The reason `TAB` is superior is simply because of readibility. Whitespace indicators display different things based on the type of whitespace used, and thus separating spaces from indentations is crucial for easy readibility.

Additionally, `TAB`-ing your code looks more consistent and is quicker to do.

> [!TIP]
> If you cannot use `TAB`, use **3** spaces.

## Documentation
When possible, documentation should be written using [Moonwave Format](https://eryn.io/moonwave/). Documentation can be written manually or with GitHub Copilot.

Examples:

```lua
--- @class MyClass
--- A sample class.
local MyClass = {}
MyClass.__index = MyClass
```

```lua
--- @class MyClass
--- @__index prototype
local MyClass = {}
MyClass.prototype = {}
MyClass.__index = MyClass.prototype

--- A function
function MyClass.prototype:method()
end
```

```lua
--- @deprecated v2 -- Use `goodFunction` instead.
function MyClass:badFunction()
end
```

> [!TIP]
> If the project already has documentation in a different format (or not at all), use Moonwave from then-on anyways.

## Variable and Function Styling
Variable, function, and other userdata names should match the below styles:
* Constants are written in `UPPER_CASE`.
* Constructors and other instance-class functions are written in `camelCase`.
* Ignored variables are always declared with `_`.
* Everything else is in `PascalCase`.

```lua
local CONSTANT = 5

local function Class.new(Foo : number, Bar : number)
    local VariableName = "Hello World!"

    for _, Value in ({1, 2, 3, 4, 5}) do
        print(`{Value} is the selected number!`)
    end
end
```

Keeping consistent styling improves clarity as to what the functionality of a variable is. Pascal case is preferred because it matches the Roblox style.

## Variable Naming
Bear in mind the following rules when deciding a name for any variables:
* Do not abbreviate or truncate variable or function names from their context. Names should make sense, and should not require or provoke thought into what it actually is used for. For example, `Player` is much better than `Plr`, and even better than `P`.
* Booleans can only be true or false. As such, they should be named as if they were yes or no questions. “IsAlive” sounds like a yes or no question, but “Alive” does not.
* Names should be kept in positive form, meaning that they clarify an activity or state. Examples:
  * Rename `IsDead` to `IsAlive`.
  * Rename `IsNotShooting` to `IsShooting`
  * Rename `IsIdle` to `IsMoving`
  * Renamed `DisallowedToDoThing` to `AllowedToDoThing`
  * And etc...
* If the `not` keyword is used to negate a variable more often than not and scales that way, consider renaming the variable to the inverse.
* Variables should be descriptive and verbose enough to describe a purpose and state.
* Do not reuse variable names in shared scopes.

Bad example:

```lua
local CONFIG = {s = 5}

local plrs = game:GetService("Players")
local repstore = game:GetService("ReplicatedStorage")

local pks = repstore:WaitForChild("Packages")
local fusion = require(pks.Fusion)
local n = fusion.New
local h = fusion.Hydrate
local s = fusion.Spring

local plr = plrs.LocalPlayer
local gui = plr.PlayerGui
```

Good example:
```lua
local CONFIG = {Speed = 5}

local PlayersService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages.Fusion)
local New = Fusion.New
local Hydrate = Fusion.Hydrate
local Spring = Fusion.Spring

local Player = PlayersService.LocalPlayer
local PlayerGui = Player.PlayerGui
```

> [!NOTE]
> The number one counter-argument to keeping consistent styling and good naming is "already knowing what everything does". At Iconic Gaming, that does not cut it. Whether you are working by yourself or with others, at some point in the future the code will need to be iterated upon, and in order to do so there should not be time wasted asking "what does everything do?"

## Function Naming
Like variables, functions need solid names as well. Bear the following in mind:
* Functions, when called, happen in the moment as an event. As such, they must be named as if they are in present verb form. Examples:
  * Change `AllChildren()` to `GetAllChildren()` as this clarifies that the function is a "getter" method.
  * Change `PlayerMovement()` to `MovePlayer()` as this implies the userdata a call to action rather than a state.
* Functions should clarify what data is processed and how it is processed. To do so, include terms such as the type of data, the action, etc in the naming. Examples:
  * Change `Clamp()` to `ClampNumber()` if you are clamping a number.
  * Change `Drink()` to `ConsumeDrink()`, since "Drink" can also represent an object, while "Consume" is *always* a call to action.

The general rule of thumb is to include as much description in a function name as possible without needing the use of comments or documentation.

## Userdata Delcaration
Always use the `local` keyword within any scope, including the top one. Functions have function syntax, variables have variable syntax.

```lua
Foo = 5 -- Bad

local Foo = 5 -- Good

function Bar() -- Bad
end

local Bar = function() -- Bad
end

local function Bar() -- Good
end
```

## Prototype Functionality
What exactly is "prototype functionality"? We don't know, we made that term up.

In this case, it describes what you did to make your code work. Having it "work" isn't good enough, it should make sense as to *why* it works.

* Avoid Boolean arguments that change the behavior of a function almost entirely. If you pass a boolean and it changes what the function does, then that is called “inappropriate sharing.” Duplication is superior this; create different functions that do different things, not a single function that does different things.
* Keep code to *reasonable* minimum. Do not obfuscate or keep statements on single lines. Do not overwrite code. Do not make variables if you will only use them once. Do not repeat yourself. Do not cache inline functions, such as those from the math or cframe libraries, for example; Luau includes inline caching.
* Assign variables to the smallest possible scope.
* Return in a function as soon as possible.
* Do not error unless you are in a unreturnable state of failure.

Bad example:

```lua
local Cos = math.cos
local LerpCFrame = CFrame.new().Lerp

local function DoEitherAction(Value : boolean)
    if Value then
        -- Action 1
    else
        -- Action 2
    end
end

local function ReturnSlow()
    local IsGood = ...

    -- Execute code

    return IsGood
end
```

Good example:

```lua
local function Foo()
    -- Action 1
end

local function Bar()
    -- Action 2
end

local function ReturnFast()
    local IsGood = ...

    if not IsGood then
        return
    end

    -- Execute code

    return true
end
```

## Misc Styling
* Sealed tables are reserved for constants such as configurations or settings. Modules, classes, etc are all to be declared in an unsealed table.
* Use plain `key` syntax for dictionaries when possible, but if there are any entries that cannot follow that, then use `["key"]`syntax.
* Add a trailing comma to all dictionary fields in a table, but not to the last value of an array.
* Strings are written with either plain double-quote (`"`) syntax or as an interpolated string.
* Line lengths shouldn't be ridiculous. If they are, your code has something wrong with it. Do not do single-line blocks.
* Use dot (`Table.Value`) notation for accessing values in a table when possible (as opposed to something like `Table["Value"]`).
* Put a space before and after typing a comment declaration (`--`). Comments follow standard English rules.
* Add blank lines between functions.
* Do not align variable declarations.
* Do not add spaces after the name of a function in a declaration or in its arguments.
* Files should always be named in `PascalCase`.

Bad example:
```lua
local SETTINGS = {}
SETTINGS["EntryA"] = 1
SETTINGS["EntryB"] = 2
SETTINGS["EntryC"] = 3

local Foo = {}--comment

local String = 'Hi'

local function FunctionA()
    Foo = {A = 5, B = 6, C = 7}
end
local function FunctionB()

end
print(Foo["A"])
```

Good example:
```lua
local SETTINGS = {
    EntryA = 1,
    EntryB = 2,
    EntryC = 3,
}

local Foo = {} -- Comment here

local String = "Hi"

local function FunctionA()
    Foo.A = 5
    Foo.B = 6
    Foo.C = 7
end

local function FunctionB()

end

print(Foo.A)
```

## Typing
Type a reasonable amount, nobody should guess if "Value" is a number, string, or table. Overtyping is still annoying.

Bad example:

```lua
for _, Value in Array do
    -- Thing
end
```

Good example:
```lua
for _, Value : number in Array do
    -- Thing
end
```

## OOP Format
Follow this format for writing OOP code:

```lua
local Object = {}
Object.__index = Object

function Object.new(Foo : number, Bar : string)
    local self = setmetatable({}, Object) -- UNSEALED TABLE!!!

    self.Foo = Foo
    self.Bar = Bar

    self:Init()

    return self
end

function Object:Init()
    -- Initialization
    self:Method()
end

function Object:Method()
end

return Object
```

## File Organization
Here is the file structure we use at Iconic Gaming:
* `ReplicatedFirst`
  * `./Client`
    * All client scripts
  * `./Dependencies`
    * All client modules
  * `./Assets`
    * All client assets
* `ServerScriptService`
  * `./Server`
    * All server scripts
  * `./Dependencies`
    * All server modules
* `ReplicatedStorage`
  * `./Common`
    * All shared modules
  * `./Assets`
    * All shared assets
* `ServerStorage`
  * `./Assets`
    * All server assets

## Modularization
Modularization is important to make sure that functionality is divided into isolated scopes, either through functions or modules.

Functions should be reserved for splitting functionality that is part of a larger picture in a script or module. For example, a weapon might have functions to shoot, reload, etc.

Modules are used to separate bigger things to create libraries, databases, and systems. Some examples of things that are their own modules include:
* Configurations
* Utilities
* Systems
* Frameworks
* Classes
* Etc

> [!TIP]
> Variable modularization is the smallest level of splitting up information into something more digestible. This is something you should eyeball, with the general rule of thumb being "if it's readable, it's good. Make sure to utilize variables still for repeated information.