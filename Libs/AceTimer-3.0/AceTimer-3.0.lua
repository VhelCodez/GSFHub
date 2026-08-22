local MAJOR, MINOR = "AceTimer-3.0", 17
local AceTimer = LibStub:NewLibrary(MAJOR, MINOR)

if not AceTimer then return end

AceTimer.embeds = AceTimer.embeds or {}
local activeTimers = {}

local function TimerCallback(timer)
	if not activeTimers[timer] then return end
	if not timer.looping then
		activeTimers[timer] = nil
	end

	local obj = timer.object
	local func = timer.func
	if type(func) == "string" then
		if obj and obj[func] then
			obj[func](obj, unpack(timer.args))
		end
	elseif type(func) == "function" then
		if obj then
			func(obj, unpack(timer.args))
		else
			func(unpack(timer.args))
		end
	end
end

function AceTimer:ScheduleTimer(func, delay, ...)
	local obj
	if type(func) ~= "function" and type(func) ~= "string" then
		error("Usage: ScheduleTimer([object,] func, delay, ...): 'func' - string or function expected.", 2)
	end
	if type(self) == "table" and self ~= AceTimer then
		obj = self
	end

	local timer = {
		object = obj,
		func = func,
		delay = delay,
		args = {...},
		looping = false,
	}

	activeTimers[timer] = true
	C_Timer.After(delay, function()
		TimerCallback(timer)
	end)

	return timer
end

function AceTimer:ScheduleRepeatingTimer(func, delay, ...)
	local obj
	if type(self) == "table" and self ~= AceTimer then
		obj = self
	end

	local timer = {
		object = obj,
		func = func,
		delay = delay,
		args = {...},
		looping = true,
	}

	activeTimers[timer] = true
	local ticker
	ticker = C_Timer.NewTicker(delay, function()
		if not activeTimers[timer] then
			if ticker then ticker:Cancel() end
			return
		end
		TimerCallback(timer)
	end)
	timer.ticker = ticker

	return timer
end

function AceTimer:CancelTimer(timer, silent)
	if not timer then return false end
	if activeTimers[timer] then
		activeTimers[timer] = nil
		if timer.ticker then
			timer.ticker:Cancel()
		end
		return true
	end
	return false
end

function AceTimer:CancelAllTimers()
	local obj = (type(self) == "table" and self ~= AceTimer) and self or nil
	for timer in pairs(activeTimers) do
		if not obj or timer.object == obj then
			self:CancelTimer(timer, true)
		end
	end
end

local mixins = {
	"ScheduleTimer",
	"ScheduleRepeatingTimer",
	"CancelTimer",
	"CancelAllTimers",
}

function AceTimer:Embed(target)
	for _, v in ipairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end
