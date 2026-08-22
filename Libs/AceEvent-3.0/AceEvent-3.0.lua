local MAJOR, MINOR = "AceEvent-3.0", 4
local AceEvent = LibStub:NewLibrary(MAJOR, MINOR)

if not AceEvent then return end

AceEvent.frame = AceEvent.frame or CreateFrame("Frame", "AceEvent30Frame")
AceEvent.embeds = AceEvent.embeds or {}
AceEvent.events = AceEvent.events or {}

local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0")

local function OnUsed(registry, targetEvent)
	AceEvent.frame:RegisterEvent(targetEvent)
end

local function OnUnused(registry, targetEvent)
	AceEvent.frame:UnregisterEvent(targetEvent)
end

AceEvent.events = CallbackHandler:New(AceEvent, "RegisterEvent", "UnregisterEvent", "UnregisterAllEvents")
AceEvent.events.OnUsed = OnUsed
AceEvent.events.OnUnused = OnUnused

AceEvent.frame:SetScript("OnEvent", function(this, event, ...)
	AceEvent.events:Fire(event, ...)
end)

local mixins = {
	"RegisterEvent",
	"UnregisterEvent",
	"UnregisterAllEvents",
}

function AceEvent:Embed(target)
	for _, v in ipairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end
