local MAJOR, MINOR = "CallbackHandler-1.0", 7
local CallbackHandler = LibStub:NewLibrary(MAJOR, MINOR)

if not CallbackHandler then return end

local meta = {__index = function(tbl, key) tbl[key] = {} return tbl[key] end}

local function RegisterName(registry, name, target, method, ...)
	if type(target) == "string" then
		method = target
		target = nil
	end
	if type(method) == "string" then
		if not target then
			error("Usage: RegisterCallback(name, method, [arg]): target is missing or method is nil", 3)
		end
		if type(target[method]) ~= "function" then
			error("Usage: RegisterCallback(name, method, [arg]): target method is not a function", 3)
		end
	elseif type(method) ~= "function" then
		if not target or type(target) ~= "function" then
			error("Usage: RegisterCallback(name, method, [arg]): method is not a function", 3)
		end
		method = target
		target = nil
	end

	local callbacks = registry.events[name]
	if not callbacks then
		callbacks = {}
		registry.events[name] = callbacks
		if registry.OnUsed then
			registry.OnUsed(registry, name)
		end
	end

	callbacks[target or ""] = method
	if select("#", ...) > 0 then
		registry.args[name] = registry.args[name] or {}
		registry.args[name][target or ""] = {...}
	end
end

local function UnregisterName(registry, name, target)
	local callbacks = registry.events[name]
	if not callbacks then return end
	callbacks[target or ""] = nil
	if registry.args[name] then
		registry.args[name][target or ""] = nil
	end
	if not next(callbacks) then
		registry.events[name] = nil
		if registry.OnUnused then
			registry.OnUnused(registry, name)
		end
	end
end

local function Fire(registry, name, ...)
	local callbacks = registry.events[name]
	if not callbacks then return end
	for target, method in pairs(callbacks) do
		local args = registry.args[name] and registry.args[name][target]
		if type(target) == "table" then
			if args then
				method(target, name, ..., unpack(args))
			else
				method(target, name, ...)
			end
		else
			if args then
				method(name, ..., unpack(args))
			else
				method(name, ...)
			end
		end
	end
end

function CallbackHandler:New(target, RegisterNameOpt, UnregisterNameOpt, UnregisterAllNameOpt)
	local registry = {
		events = {},
		args = {},
		insertQueue = {},
	}
	registry.Fire = Fire
	target[RegisterNameOpt or "RegisterCallback"] = function(self, name, method, ...)
		RegisterName(registry, name, self, method, ...)
	end
	target[UnregisterNameOpt or "UnregisterCallback"] = function(self, name)
		UnregisterName(registry, name, self)
	end
	if UnregisterAllNameOpt then
		target[UnregisterAllNameOpt] = function(self)
			for name, callbacks in pairs(registry.events) do
				callbacks[self] = nil
				if not next(callbacks) then
					registry.events[name] = nil
					if registry.OnUnused then registry.OnUnused(registry, name) end
				end
			end
		end
	end
	return registry
end
