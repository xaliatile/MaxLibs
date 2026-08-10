-- Made by Max

local __react = {
    __reactExeTime = os.clock(),
	__signals = {},
	__reactpool = setmetatable({
		__pool = {}
	}, {
		__call = function(self)
			local __pool = rawget(self, "__pool")

			for _, poolEntry in ipairs(__pool) do
				if typeof(poolEntry) == "RBXScriptConnection" then
					poolEntry:Disconnect()
				elseif type(poolEntry) == "table" then
					table.clear(poolEntry)
				elseif typeof(poolEntry) == "Instance" then
					poolEntry:Destroy()
				end
			end

			table.clear(__pool)
		end,

		__newindex = function(self, _, __obj : Object)
			local __pool = rawget(self, "__pool")
			table.insert(__pool, __obj)
		end
	}),

	__services = setmetatable({
		__servicesContainer = {}
	}, {
		__call = function(self, __serviceName : string)
			local __servicesContainer = rawget(self, "__servicesContainer")
			local __succeeded, __result = pcall(function()
				return game:GetService(__serviceName)
			end)

			if __succeeded then
				__servicesContainer[__serviceName] = __result
			else
				__servicesContainer[__serviceName] = __result
			end
		end,

		__index = function(self, __serviceName : string)
			local __servicesContainer = rawget(self, "__servicesContainer")
			return __servicesContainer[__serviceName]
		end
	}),

	__runners = {
		__getRepository = function(__repoLink : string)
			local __succ, __result = pcall(function()
				local __repo = game:HttpGet(__repoLink)
				return loadstring(__repo)()
			end)

			return __result, __succ
		end,

		__runIf = function(__callback : any, __statement : any)
			local __succ, __result = false, ""

			if __statement then
				__succ, __result = pcall(__callback)
			end

			return __result, __succ
		end,

        __runLgFunc = function(__callback, __callbackStr : string)
            if type(__callback) == "function" and type(__callbackStr) == "string" then
                __callback(__callbackStr)
            end
        end,

		__runPr = function(__callback : any, __cTag : string)
			local __succ, __result = pcall(__callback)

			if not __succ then
				warn(
					string.format(
						"[MAX REACT | External Error (%s) ]: %s experienced an internal error and was handled safely | Error: %s", 
						__cTag,
						__cTag,
						__result
					)
				)
			end
		end
	}
}

local __signalLib do
	__react.__services("HttpService")

	if PsmSignal then
		__signalLib = PsmSignal
	else
		__signalLib = {}
		__signalLib.__index = __signalLib

		function __signalLib.new()
			local self = setmetatable({
				__signalCallbacks = {}
			}, __signalLib)

			return self
		end

		function __signalLib:Connect(__callback : any)
			table.insert(self.__signalCallbacks, {
				__callback = __callback,
				__callbackType = "Connect",
				__callbackId = ReactLibrary.HttpService:GenerateGUID(false)
			})
		end

		function __signalLib:Once(__callback : any)
			table.insert(self.__signalCallbacks, {
				__callback = __callback,
				__callbackType = "Once",
				__callbackId = ReactLibrary.HttpService:GenerateGUID(false)
			})
		end

		function __signalLib:Fire(__args : {any})
			local __cleanedindxs = {}

			for __indx, __calldata in ipairs(self.__signalCallbacks) do
				if type(__calldata) == "table" and type(__calldata.__callback) == "function" then
					__calldata.__callback(__args)

					if __calldata.__callbackType == "Once" then
						table.insert(__cleanedindxs, __indx)
					end
				end
			end

			for __indx = #__cleanedindxs, 1, -1 do
				local _cleanedindx = __cleanedindxs[__indx]
				table.remove(self.__signalCallbacks, _cleanedindx)
			end
		end

		function __signalLib:Destroy()
			if self.__signalCallbacks then
				table.clear(self.__signalCallbacks)
			end

			table.clear(self)
			setmetatable(self, nil)
		end
	end
end

do
	__react.__signals = setmetatable({
		__customSignals = {}
	}, {
		__call = function(self, __callname : string, __calldata : {any})
			local __customSignals = rawget(self, "__customSignals")

			if __customSignals[__callname] then
				local __signalData = __customSignals[__callname]
				local __callback = rawget(__signalData, "SignalCallback")

				if type(__callback) == "function" then
					__callback(__calldata)
				end
			end
		end,

		__newindex = function(self, IndexName : string, IndexData : {any})
			local __customSignals = rawget(self, "__customSignals")

			if type(IndexData) == "table" and not __customSignals[IndexName] then
				local __signalCallback = rawget(IndexData, "__signalCallback") or function(...) return ... end

				__customSignals[IndexName] = {
					__signalCallback = __signalCallback,
					__signalId = __react.__services.HttpService:GenerateGUID(false)
				}
			end
		end
	})
	__react.__signals["DestroyingReliable"] = {
		__signalCallback = function(__calldata : {any})
			local __obj = rawget(__calldata or {}, "__obj")
			local __callback = rawget(__calldata or {}, "__callback")

			if __obj then
				local __RC = nil

				__RC = __obj:GetPropertyChangedSignal("Parent"):Connect(function()
					if __obj and __obj.Parent == nil then
						if type(__callback) == "function" then
							__callback(__obj)
							__RC:Disconnect()
							__RC = nil
						end
					end
				end)

				__react.__reactpool[__RC] = __RC
			end
		end
	}
end

function __react.HasProperty(__obj : Object, __prop : string)
    local __hasProp = pcall(function()
        return __obj[__prop]
    end)

    return __hasProp
end

function __react.Create(__className : string, __propers : {any}, __creationCallback : any)
	local __succ, __result = pcall(function()
		local __obj = Instance.new(__className)
		__propers = (__propers and __propers or {})

		local __parentValue = __propers["Parent"]
		__propers["Parent"] = nil

        if __parentValue == nil and rawget(__propers, "Parent") == nil then
			__parentValue = __obj.Parent
		end

		for __prop, __propVal in __propers do
			if __prop == "Attributes" then
				for __att, __attValue in __propVal do
					__obj:SetAttribute(__att, __attValue)
				end
			elseif __prop == "Children" then
				for _, __child in ipairs(__propVal) do
                    if __react.HasProperty(__child, "Parent") then
                    	__child.Parent = __obj
                    end
				end
			elseif __prop == "Events" then
				for __signalData, __callback in __propVal do
					local __signalName = rawget(__signalData, "SignalName")
					local __signalConnectionType = rawget(__signalData, "SignalConnectionType")

					local __RS = __obj[__signalName]

					if typeof(__RS) == "RBXScriptSignal" then
						if __signalConnectionType == "Once" then
							local __RC = __RS:Once(__callback)
							__react.__reactpool[__RC] = __RC
						else
							local __RC = __RS:Connect(__callback)
							__react.__reactpool[__RC] = __RC
						end
					end
				end
			else
				__obj[__prop] = __propVal
			end
		end

		__obj.Parent = __parentValue

		return __obj
	end)

	if __succ then
		if __creationCallback then
			__creationCallback(__result, __succ)
		end
	else
		if not __succ then
            __react.__runners.__runLgFunc(
                warn,
                string.format(
					"[MAX REACT :: Library]: Caught an exception in .Create safe call | %s",
					tostring(__result)
				)
            )
		end 
	end

	return __result
end

function __react.ApplyProperties(__obj : Object, __propers : {any})
	local __succ, __result = pcall(function()
		__propers = __propers and __propers or {}

		local __parentValue = __propers["Parent"]
		__propers["Parent"] = nil

		if __parentValue == nil and rawget(__propers, "Parent") == nil then
			__parentValue = __obj.Parent
		end

		for __prop, __propVal in __propers do
			if __prop == "Attributes" then
				for __att, __attValue in __propVal do
					__obj:SetAttribute(__att, __attValue)
				end
			elseif __prop == "Children" then
				for _, __child in ipairs(__propVal) do
					if __react.HasProperty(__child, "Parent") then
                    	__child.Parent = __obj
                    end
				end
			elseif __prop == "Events" then
				for __signalData, Callback in __propVal do
					local __signalName = rawget(__signalData, "SignalName")
					local __signalConnectionType = rawget(__signalData, "SignalConnectionType")

					local __RS = __obj[__signalName]
					local __RC = nil

					if typeof(__RS) == "RBXScriptSignal" then
						if __signalConnectionType == "Once" then
							__RC = __RS:Once(Callback)
							__react.__reactpool[__RC] = __RC
						else
							__RC = __RS:Connect(Callback)
							__react.__reactpool[__RC] = __RC
						end
					end
				end
			else
				__obj[__prop] = __propVal
			end
		end

		if __parentValue then
			__obj.Parent = __parentValue
		end
	end)

	if __succ then
		if __creationCallback then
			__creationCallback(__result, __succ)
		end
	else
		if not __succ then
			warn(
				string.format(
					"[MAX REACT :: Library]: Caught an exception in .ApplyProperties safe call | %s",
					tostring(__result)
				)
			)
		end 
	end

	return __result
end

function __react.ConnectReact(__obj : Object, __signalData : {any}, __callback : any)
	local __succ, __result = pcall(function()
		local __signalName = rawget(__signalData, "SignalName")
		local __signalConnectionType = rawget(__signalData, "SignalConnectionType")

		local __RS = __obj[__signalName]

		if typeof(__RS) == "RBXScriptSignal" then
			if __signalConnectionType == "Once" then
				__RS:Once(__callback)
			else
				__RS:Connect(__callback)
			end
		end

		return __RS
	end)

	if not __succ then
        __react.__runners.__runLgFunc(
            warn,
            string.format(
				"[MAX REACT :: Library]: Caught an exception in .ConnectReact safe call | %s",
				tostring(__result)
			)
        )
	end

	return __result, __succ
end

function __react.ConnectCustomReact(__signalData : {any})
	local __succ, __result = pcall(function()
		local __signalName = rawget(__signalData, "SignalName")
		return __react.__signals(__signalName)
	end)

	if not __succ then
		__react.__runners.__runLgFunc(
            warn,
            string.format(
				"[MAX REACT :: Library]: Caught an exception in .ConnectCustomReact safe call | %s",
				tostring(__result)
			)
        )
	end

	return __result, __succ
end

function __react.AddToJanitor(__entry : any)
	__react.__reactpool[Entry__entry] = __entry
end

function __react.CacheJanitor()
	__react.__reactpool()
end

function __react.Exit()
	__react.__reactpool()

	for _, __entry in ipairs(__react) do
		if type(__entry) == "table" then
			table.clear(__entry)
		end
	end

	table.clear(__react)
	__react = nil
end

do
    local Difference = os.clock() - __react.__reactExeTime

    __react.__runners.__runLgFunc(
        print,
        string.format(
            "[MAX REACT :: Library]: Max react initialized successfully | Took: %s %s",
            tostring(Difference),
            (Difference >= 1 and "second(s)" or "millisecond(s)")
        )
    )
end

return __react
