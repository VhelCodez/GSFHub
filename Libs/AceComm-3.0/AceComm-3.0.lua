local MAJOR, MINOR = "AceComm-3.0", 9
local AceComm = LibStub:NewLibrary(MAJOR, MINOR)

if not AceComm then return end

local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0")
local AceEvent = LibStub:GetLibrary("AceEvent-3.0")

AceComm.embeds = AceComm.embeds or {}
AceComm.messages = AceComm.messages or {}
AceComm.prefixes = AceComm.prefixes or {}

local function OnUsed(registry, prefix)
	if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
		C_ChatInfo.RegisterAddonMessagePrefix(prefix)
	elseif RegisterAddonMessagePrefix then
		RegisterAddonMessagePrefix(prefix)
	end
	AceComm.prefixes[prefix] = true
end

local function OnUnused(registry, prefix)
	AceComm.prefixes[prefix] = nil
end

AceComm.messages = CallbackHandler:New(AceComm, "RegisterComm", "UnregisterComm", "UnregisterAllComm")
AceComm.messages.OnUsed = OnUsed
AceComm.messages.OnUnused = OnUnused

if not AceComm.frame then
	local frame = CreateFrame("Frame", "AceComm30Frame")
	AceComm.frame = frame
	AceEvent:Embed(AceComm)
	
	AceComm:RegisterEvent("CHAT_MSG_ADDON", function(event, prefix, message, distribution, sender)
		if AceComm.prefixes[prefix] then
			-- Remove realm name if from same realm
			local shortSender = sender
			local name, realm = strsplit("-", sender, 2)
			local myRealm = GetRealmName()
			if realm and realm == myRealm then
				shortSender = name
			end
			AceComm.messages:Fire(prefix, message, distribution, shortSender)
		end
	end)
end

function AceComm:SendCommMessage(prefix, text, distribution, target, prio)
	if not prefix or not text then
		error("Usage: SendCommMessage(prefix, text, distribution[, target]): 'prefix' and 'text' expected.", 2)
	end
	distribution = distribution or "GUILD"
	
	-- Chunking if text exceeds 255 chars
	local maxLen = 250
	if #text <= maxLen then
		if C_ChatInfo and C_ChatInfo.SendAddonMessage then
			C_ChatInfo.SendAddonMessage(prefix, text, distribution, target)
		elseif SendAddonMessage then
			SendAddonMessage(prefix, text, distribution, target)
		end
	else
		-- Multi-part packet
		local totalParts = math.ceil(#text / maxLen)
		local msgId = math.random(1000, 9999)
		for i = 1, totalParts do
			local chunk = text:sub((i - 1) * maxLen + 1, i * maxLen)
			local packet = ("!CH:%d:%d:%d:%s"):format(msgId, i, totalParts, chunk)
			if C_ChatInfo and C_ChatInfo.SendAddonMessage then
				C_ChatInfo.SendAddonMessage(prefix, packet, distribution, target)
			elseif SendAddonMessage then
				SendAddonMessage(prefix, packet, distribution, target)
			end
		end
	end
end

local mixins = {
	"RegisterComm",
	"UnregisterComm",
	"UnregisterAllComm",
	"SendCommMessage",
}

function AceComm:Embed(target)
	for _, v in ipairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end
