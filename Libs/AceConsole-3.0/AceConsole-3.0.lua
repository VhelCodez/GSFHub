local MAJOR, MINOR = "AceConsole-3.0", 7
local AceConsole = LibStub:NewLibrary(MAJOR, MINOR)

if not AceConsole then return end

AceConsole.embeds = AceConsole.embeds or {}
AceConsole.commands = AceConsole.commands or {}

function AceConsole:RegisterChatCommand(command, handler, persist)
	local slashId = "ACECONSOLE_" .. command:upper()
	_G["SLASH_" .. slashId .. "1"] = "/" .. command:lower()
	
	SlashCmdList[slashId] = function(msg, editBox)
		local target = self
		if type(handler) == "string" and target and target[handler] then
			target[handler](target, msg, editBox)
		elseif type(handler) == "function" then
			handler(msg, editBox)
		end
	end
	
	AceConsole.commands[command] = handler
end

function AceConsole:Print(...)
	local prefix = "|cff33ff99GSFHub:|r"
	DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, tostringall(...)))
end

function AceConsole:Printf(fmt, ...)
	local prefix = "|cff33ff99GSFHub:|r"
	DEFAULT_CHAT_FRAME:AddMessage(prefix .. " " .. string.format(fmt, ...))
end

local mixins = {
	"RegisterChatCommand",
	"Print",
	"Printf",
}

function AceConsole:Embed(target)
	for _, v in ipairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end
