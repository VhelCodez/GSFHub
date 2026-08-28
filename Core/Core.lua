local ADDON_NAME, GSF = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceEvent = LibStub("AceEvent-3.0")
local AceTimer = LibStub("AceTimer-3.0")
local AceConsole = LibStub("AceConsole-3.0")

local GSFHub = AceAddon:NewAddon("GSFHub", "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
GSF.Addon = GSFHub

function GSFHub:OnInitialize()
	-- Initialize Database & Cache
	GSF.DB:Initialize()

	-- Register Slash Commands
	self:RegisterChatCommand("gsf", "HandleSlashCommand")
	self:RegisterChatCommand("gsfhub", "HandleSlashCommand")
	self:RegisterChatCommand("gsfcraft", "HandleSlashCommand")

	self:Print(string.format(GSF.L["LOADED_MESSAGE"]))
end

function GSFHub:OnEnable()
	-- Register core game events
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	self:RegisterEvent("PLAYER_GUILD_UPDATE")

	-- Initialize Minimap Button
	if GSF.Minimap then
		GSF.Minimap:Initialize()
	end

	-- Initialize Network Sync
	if GSF.Sync then
		GSF.Sync:Initialize()
	end

	-- Initialize Modules
	if GSF.Scanner then
		GSF.Scanner:Initialize()
	end

	if GSF.RecipeDrops then
		GSF.RecipeDrops:Initialize()
	end

	if GSF.TradeSkillHook then
		GSF.TradeSkillHook:Initialize()
	end

	if GSF.TradeHelper then
		GSF.TradeHelper:Initialize()
	end

	if GSF.MailHelper then
		GSF.MailHelper:Initialize()
	end

	if GSF.SupplyBounties then
		GSF.SupplyBounties:Initialize()
	end

	if GSF.GoalsHUD then
		GSF.GoalsHUD:Initialize()
	end
end

function GSFHub:PLAYER_ENTERING_WORLD()
	GSF.cache.realmName = GetRealmName()
	local guild = GSF.DB:GetGuildName()
	if guild then
		GSF.cache.guildName = guild
		if GSF.Sync then
			-- Stagger initial sync to allow guild channel to connect
			self:ScheduleTimer(function()
				GSF.Sync:BroadcastHello()
			end, 3)
		end
	else
		GSF.cache.guildName = ""
	end
end

function GSFHub:PLAYER_GUILD_UPDATE()
	local guild = GSF.DB:GetGuildName()
	if guild and guild ~= "" and guild ~= GSF.cache.guildName then
		GSF.cache.guildName = guild
		if GSF.Sync then
			self:ScheduleTimer(function()
				GSF.Sync:BroadcastHello()
			end, 3)
		end
	elseif not guild then
		GSF.cache.guildName = ""
	end
end

function GSFHub:GUILD_ROSTER_UPDATE()
	if IsInGuild() then
		local numMembers = GetNumGuildMembers()
		for i = 1, numMembers do
			local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline = GetGuildRosterInfo(i)
			if name then
				local shortName = strsplit("-", name, 2)
				local member = GSF.DB:EnsureMemberRecord(shortName)
				if isOnline then
					member.lastSeen = time()
				end
			end
		end
	end
end

function GSFHub:HandleSlashCommand(input)
	local args = {}
	for word in string.gmatch(input or "", "%S+") do
		table.insert(args, word)
	end
	local cmd = (args[1] or ""):lower()

	if cmd == "" or cmd == "ui" or cmd == "toggle" then
		if GSF.MainFrame then
			GSF.MainFrame:Toggle()
		end
	elseif cmd == "scan" then
		if GSF.Scanner then
			GSF.Scanner:ScanCurrentWindow()
		else
			self:Print("Trade skill scanner not ready.")
		end
	elseif cmd == "sync" then
		if not IsInGuild() then
			self:Printf("|cffff9900%s|r", GSF.L["NO_GUILD_WARNING"] or "You are not currently in a guild. Guild synchronization is disabled.")
		elseif GSF.Sync then
			GSF.Sync:BroadcastHello(true)
			self:Print("Broadcasting synchronization request to guild...")
		end
	elseif cmd == "settings" or cmd == "config" or cmd == "options" or cmd == "opt" then
		if GSF.MainFrame then
			GSF.MainFrame:Show()
			GSF.MainFrame:OpenSettings()
		end
	elseif cmd == "main" and args[2] then
		GSF.Alts:SetMyMain(args[2])
		self:Printf("Main character set to '%s'.", args[2])
	elseif cmd == "bug" or cmd == "report" or cmd == "issue" then
		if GSF.FeedbackDialog then
			GSF.FeedbackDialog:Show()
		end
	elseif cmd == "update" then
		if GSF.VersionCheck then
			GSF.VersionCheck:OpenUpdateDialog()
		end
	elseif cmd == "lang" or cmd == "language" then
		if args[2] then
			GSF:SetLanguage(args[2])
			self:Printf("Language set to '%s'.", args[2])
		else
			self:Printf("Current language: %s (Auto: %s)", GSF:GetSelectedLanguage(), GetLocale())
		end
	elseif cmd == "version" or cmd == "ver" then
		self:Printf("GSFHub Version %s (Protocol v%d)", GSF.VERSION, GSF.PROTOCOL_VERSION)
	elseif cmd == "hud" or cmd == "goals" then
		if GSF.GoalsHUD then
			GSF.GoalsHUD:Toggle()
		end
	elseif cmd == "atlas" or cmd == "gathering" or cmd == "mats" then
		if GSF.MainFrame then
			GSF.MainFrame:Show()
			GSF.MainFrame:SelectTab(5)
		end
	elseif cmd == "help" then
		self:Print("Available Commands:")
		print("  |cff33ff99/gsf|r - Toggle main interface")
		print("  |cff33ff99/gsf settings|r - Open addon configuration & settings")
		print("  |cff33ff99/gsf atlas|r - Open Resource Farming Atlas & Bounties")
		print("  |cff33ff99/gsf hud|r - Toggle onscreen Goals HUD tracker")
		print("  |cff33ff99/gsf scan|r - Scan currently open profession window")
		print("  |cff33ff99/gsf sync|r - Request full synchronization from guild")
		print("  |cff33ff99/gsf main <Name>|r - Set your main character name")
		print("  |cff33ff99/gsf bug|r - Open bug report & diagnostics modal")
		print("  |cff33ff99/gsf lang <auto|enUS|deDE>|r - Switch language")
	else
		if GSF.MainFrame then
			GSF.MainFrame:Toggle()
		end
	end
end
