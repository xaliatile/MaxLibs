local ReactLibrary = {
    Signals = {},
    UserInterface = {},
    ReactPool = setmetatable({
        Pool = {}
    }, {
        __call = function(self, ServiceName : string)
            local PoolContainer = rawget(self, "Pool")

            for _, Entry in ipairs(PoolContainer) do
                if typeof(Entry) == "RBXScriptConnection" then
                    Entry:Disconnect()
                elseif type(Entry) == "table" then
                    table.clear(Entry)
                elseif typeof(Entry) == "Instance" then
                    Entry:Destroy()
                end
            end

            table.clear(PoolContainer)
        end,

        __newindex = function(self, _, Object : Object)
            local PoolContainer = rawget(self, "Pool")
            table.insert(PoolContainer, Object)
        end
    })

    Services = setmetatable({
        ServiceContainer = {}
    }, {
        __call = function(self, ServiceName : string)
            local ServiceContainer = rawget(self, "ServiceContainer")
            
            local Service = game:GetService(ServiceName)
            ServiceContainer[ServiceName] = Service
        end,

        __index = function(self, ServiceName : string)
            local ServiceContainer = rawget(self, "ServiceContainer")

            return ServiceContainer[ServiceName]
        end
    })
}

ReactLibrary.Services("HttpService")

do
    local Succeeded, Result = pcall(function()
        -- your welcome prevents skiddy devs from kicking you locally.

        local hookmeta = hookmetamethod and hookmetamethod or function(...) return ... end
        local OldFunction = nil
        local OldIndex = nil

        OldFunction = hookmeta(game, "__namecall", function(self, ...)
            local Method = getnamecallmethod()

            if Method == "Kick" then
                return
            elseif Method == "GetLogHistory" then
                return
            end

            return HookMethod(self, ...)
        end)

        OldIndex = hookmeta(game, "__index", function(self, key)
            if key == "Kick" then
                return
            elseif Method == "GetLogHistory" then
                return
            end

            return OldIndex(self, key)
        end)
    end)

    if not Succeeded then
         warn(
            string.format(
                "[REACT LIB :: Library]: Caught an exception in safe call | %s",
                tostring(Result)
            )
        )
    end
end

local SignalLibrary = PsmSignal.new() or do
    local Signal = {}
    Signal.__index = Signal

    function Signal.new()
        local self = setmetatable({
            Callbacks = {}
        }, Signal)

        return self
    end

    function Signal:Connect(Callback : any)
        table.insert(self.Callbacks, {
            Callback = Callback,
            CallbackType = "Connect",
            CallbackId = ReactLibrary.HttpService:GenerateGUID(false)
        })
    end

    function Signal:Once(Callback : any)
        table.insert(self.Callbacks, {
            Callback = Callback,
            CallbackType = "Once",
            CallbackId = ReactLibrary.HttpService:GenerateGUID(false)
        })
    end

    function Signal:Fire(Arguments : {any})
        local CleanedIndexs = {}

        for Index, CallbackData in ipairs(self.Callbacks) do
            if type(CallbackData) == "table" and type(CallbackData.Callback) == "function" then
                CallbackData.Callback(Arguments)

                if CallbackData.CallbackType == "Once" then
                    table.insert(CleanedIndexs, Index)
                end
            end
        end
        
        for Index = #CleanedIndexs, 1, -1 do
            local CleanedIndex = CleanedIndexs[Index]
            table.remove(self.Callbacks, CleanedIndex)
        end
    end

    function Signal:Destroy()
        if self.Callbacks then
            table.clear(self.Callbacks)
        end

        table.clear(self)
        setmetatable(self, nil)
    end
end

ReactLibrary.Signals = setmetatable({
    CustomSignals = {}
}, {
    __call = function(self, CallName : string, CallData : {any})
        local CustomSignals = rawget(self, "CustomSignals")

        if CustomSignals[CallName] then
            local SignalData = CustomSignals[CallName]

            local Callback = rawget(SignalData, "SignalCallback")
            local CallbackArgument = rawget(SignalData, "SignalArguments")

            if type(Callback) == "function" then
                Callback(CallData)
            end
        end
    end,

    __newindex = function(self, IndexName : string, IndexData : {any})
        local CustomSignals = rawget(self, "CustomSignals")

        if type(IndexData) == "table" and not CustomSignals[IndexName] then
            local SignalCallback = rawget(IndexData, "SignalCallback") or function(...) return ... end

            CustomSignals[IndexName] = {
                SignalCallback = SignalCallback,
                SignalId = ReactLibrary.HttpService:GenerateGUID(false)
            }
        end
    end
})

do
    ReactLibrary.Signals["DestroyingReliable"] = {
        SignalCallback = function(CallData : {any})
            local Object = rawget(CallData or {}, "Object")
            local Callback = rawget(CallData or {}, "Callback")

            if Object then
                local RBXConnection = nil

                RBXConnection = Object:GetPropertyChangedSignal("Parent"):Connect(function()
                    if Object and Object.Parent == nil then
                        if type(Callback) == "function" then
                            Callback(Object)
                            RBXConnection:Disconnect()
                            RBXConnection = nil
                        end
                    end
                end)

                ReactLibrary.ReactPool[RBXConnection] = RBXConnection
            end
        end
    }
end

function ReactLibrary.Create(ClassName : string, Properties : {any}, CreationCallback : any)
    local Succeeded, Result = pcall(function()
        local Object = Instance.new(ClassName)

        for Property, PropertyValue in Properties do
            if Property == "Attributes" then
                for Attribute, AttributeValue in PropertyValue do
                    Object:SetAttribute(Attribute, AttributeValue)
                end
            elseif Property == "Children" then
                for _, Children in ipairs(PropertyValue) do
                    Children.Parent = Object
                end
            elseif Property == "Events" then
                for SignalData, Callback in PropertyValue do
                    local SignalName = rawget(SignalData, "SignalName")
                    local SignalConnection = rawget(SignalData, "SignalConnectionType")

                    local RBXSignal = Object[SignalName]

                    if typeof(RBXSignal) == "RBXScriptSignal" then
                        if SignalConnection == "Once" then
                            local RBXConnection = RBXSignal:Once(Callback)
                            ReactLibrary.ReactPool[RBXConnection] = RBXConnection
                        else
                            local RBXConnection = RBXSignal:Connect(Callback)
                            ReactLibrary.ReactPool[RBXConnection] = RBXConnection
                        end
                    end
                end
            else
                Object[Property] = PropertyValue
            end
        end
    end)

    if Succeeded then
        CreationCallback(Result, Succeeded)
    else
        if not Succeeded then
            warn(
                string.format(
                    "[REACT LIB :: Library]: Caught an exception in safe call | %s",
                    tostring(Result)
                )
            )
        end 
    end

    return Result
end

function ReactLibrary.ApplyProperties(Object : Object, Properties : {any})
    local Succeeded, Result = pcall(function()
        for Property, PropertyValue in Properties do
            if Property == "Attributes" then
                for Attribute, AttributeValue in PropertyValue do
                    Object:SetAttribute(Attribute, AttributeValue)
                end
            elseif Property == "Children" then
                for _, Child in ipairs(PropertyValue) do
                    Child.Parent = Object
                end
            elseif Property == "Events" then
                for SignalData, Callback in PropertyValue do
                    local SignalName = rawget(SignalData, "SignalName")
                    local SignalConnection = rawget(SignalData, "SignalConnectionType")

                    local RBXSignal = Object[SignalName]

                   if typeof(RBXSignal) == "RBXScriptSignal" then
                        if SignalConnection == "Once" then
                            local RBXConnection = RBXSignal:Once(Callback)
                            ReactLibrary.ReactPool[RBXConnection] = RBXConnection
                        else
                            local RBXConnection = RBXSignal:Connect(Callback)
                            ReactLibrary.ReactPool[RBXConnection] = RBXConnection
                        end
                    end
                end
            else
                Object[Property] = PropertyValue
            end
        end
    end)

    if not Succeeded then
        warn(
            string.format(
                "[REACT LIB :: Library]: Caught an exception in safe call | %s",
                tostring(Result)
            )
        )
    end

    return Result, Succeeded
end

function ReactLibrary.ConnectReact(SignalData : string, Callback : any)
    local Succeeded, Result = pcall(function()
        local SignalName = rawget(SignalData, "SignalName")
        local SignalConnection = rawget(SignalData, "SignalConnectionType")

        local RBXSignal = Object[SignalName]

        if typeof(RBXSignal) == "RBXScriptSignal" then
            if SignalConnection == "Once" then
                RBXSignal:Once(Callback)
            else
                RBXSignal:Connect(Callback)
            end
        end
    end)

    if not Succeeded then
        warn(
            string.format(
                "[REACT LIB :: Library]: Caught an exception in safe call | %s",
                tostring(Result)
            )
        )
    end

    return Result, Succeeded
end

function ReactLibrary.ConnectCustomReact(SignalData : {any})
    local Succeeded, Result = pcall(function()
        local SignalName = rawget(SignalData, "SignalName")
        ReactLibrary.Signals(SignalName)
    end)

    if not Succeeded then
        warn(
            string.format(
                "[REACT LIB :: Library]: Caught an exception in safe call | %s",
                tostring(Result)
            )
        )
    end

    return Result, Succeeded
end

function ReactLibrary.AddToJanitor(Entry : any)
    ReactLibrary.ReactPool[Entry] = Entry
end

function ReactLibrary.CacheJanitor()
    ReactLibrary.ReactPool()
end

function ReactLibrary.Exit()
    ReactLibrary.ReactPool()
    table.clear(ReactLibrary)

    ReactLibrary = nil
end

return ReactLibrary
