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

	-- Lightweight chat link listener to resolve any item whispered, looted, or linked in chat
	GSF.ChatLinks = GSF.ChatLinks or {}
	local function SniffChatMessage(_, msg)
		if not msg then return end
		for link in msg:gmatch("|c%x+|Hitem:%d+.-|h%[.-%]|h|r") do
			local name = link:match("%[(.-)%]")
			local id = tonumber(link:match("item:(%d+)"))
			if name and id then
				GSF.ChatLinks[name:lower()] = { id = id, link = link }
			end
		end
	end

	self:RegisterEvent("CHAT_MSG_WHISPER", SniffChatMessage)
	self:RegisterEvent("CHAT_MSG_WHISPER_INFORM", SniffChatMessage)
	self:RegisterEvent("CHAT_MSG_GUILD", SniffChatMessage)
	self:RegisterEvent("CHAT_MSG_PARTY", SniffChatMessage)
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER", SniffChatMessage)
	self:RegisterEvent("CHAT_MSG_RAID", SniffChatMessage)
	self:RegisterEvent("CHAT_MSG_RAID_LEADER", SniffChatMessage)
	self:RegisterEvent("CHAT_MSG_SAY", SniffChatMessage)
	self:RegisterEvent("CHAT_MSG_LOOT", SniffChatMessage)

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
	local scopeKey, isGuild, scopeChanged = GSF.DB:UpdateScope()

	if isGuild then
		-- Request fresh guild roster from server
		if C_GuildInfo and C_GuildInfo.GuildRoster then
			C_GuildInfo.GuildRoster()
		elseif GuildRoster then
			GuildRoster()
		end

		if GSF.Sync then
			-- Stagger initial sync to allow guild channel to connect
			self:ScheduleTimer(function()
				GSF.Sync:BroadcastHello()
			end, 3)
		end
	end

	if GSF.MainFrame and GSF.MainFrame:IsShown() then
		GSF.MainFrame:RefreshCurrentTab()
	end
end

function GSFHub:PLAYER_GUILD_UPDATE()
	local scopeKey, isGuild, scopeChanged = GSF.DB:UpdateScope()
	if scopeChanged then
		if isGuild then
			if C_GuildInfo and C_GuildInfo.GuildRoster then
				C_GuildInfo.GuildRoster()
			elseif GuildRoster then
				GuildRoster()
			end

			if GSF.Sync then
				self:ScheduleTimer(function()
					GSF.Sync:BroadcastHello()
				end, 3)
			end
		end

		if GSF.MainFrame and GSF.MainFrame:IsShown() then
			GSF.MainFrame:RefreshCurrentTab()
		end
	end
end

function GSFHub:GUILD_ROSTER_UPDATE()
	if IsInGuild() then
		local numMembers = GetNumGuildMembers()
		if numMembers == 0 then return end

		local currentGuildMembers = {}
		for i = 1, numMembers do
			local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline = GetGuildRosterInfo(i)
			if name then
				local shortName = strsplit("-", name, 2)
				currentGuildMembers[shortName] = true
				local member = GSF.DB:EnsureMemberRecord(shortName)
				if isOnline then
					member.lastSeen = time()
				end
				if classDisplayName and classDisplayName ~= "" then
					member.class = classDisplayName
				end
			end
		end

		-- Prune characters and work orders that do not belong to this guild
		GSF.DB:PruneNonGuildMembers(currentGuildMembers)

		if GSF.MainFrame and GSF.MainFrame:IsShown() then
			GSF.MainFrame:RefreshCurrentTab()
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
		self:Printf(GSF.L["MAIN_SAVED_NOTICE"] or "Main character updated to '%s'.", args[2])
		if GSF.TabRoster and GSF.TabRoster.frame and GSF.TabRoster.frame:IsShown() then
			GSF.TabRoster:Refresh()
		end
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

-- Automatically detect the associated profession for an item, enchant, or recipe
function GSF:DetectProfessionForItem(input)
	if not input or input == "" then return nil end

	local itemId = tonumber(tostring(input):match("item:(%d+)")) or (type(input) == "number" and input) or (tostring(input):match("^%d+$") and tonumber(input))
	local itemName, itemLink, _, _, _, itemType, itemSubType, _, _, _, _, classID, subclassID = GetItemInfo(input)

	-- 1. Recipe class (classID == 9)
	if classID == 9 or (C_Item and itemId and select(6, C_Item.GetItemInfoInstant(itemId)) == 9) then
		local sub = subclassID or (C_Item and itemId and select(7, C_Item.GetItemInfoInstant(itemId)))
		if sub == 1 then return "Leatherworking"
		elseif sub == 2 then return "Tailoring"
		elseif sub == 3 then return "Engineering"
		elseif sub == 4 then return "Blacksmithing"
		elseif sub == 5 then return "Cooking"
		elseif sub == 6 then return "Alchemy"
		elseif sub == 7 then return "First Aid"
		elseif sub == 8 then return "Enchanting"
		elseif sub == 10 then return "Jewelcrafting"
		end
	end

	-- 2. Enchanting detection (keywords and enchants)
	local str = tostring(itemName or input)
	if str:find("Enchant%s") or str:find("Verzaubern") or str:find("Formel:") or str:find("Formula:") or str:find("Brillant") or str:find("Glänzend") or str:find("Hervorragend") then
		return "Enchanting"
	end

	-- 3. Check GSF Recipe Index (scanned guild recipes & defaults)
	if GSF.RecipeBook and GSF.RecipeBook.Search then
		local clean = str:gsub("^%[", ""):gsub("%]$", ""):match("^(.-)%s*%(%d+%)") or str:gsub("^%[", ""):gsub("%]$", "")
		local results = GSF.RecipeBook:Search(clean, "ALL", false)
		if results and #results > 0 then
			for _, r in ipairs(results) do
				if r.profession and r.profession ~= "ALL" then
					return r.profession
				end
			end
		end
	end

	-- 4. Check Subtypes (Potions, Gems, Armor)
	if itemType == "Consumable" or itemType == "Verbrauchbar" then
		if itemSubType == "Potion" or itemSubType == "Elixir" or itemSubType == "Flask" or
		   itemSubType == "Trank" or itemSubType == "Elixier" or itemSubType == "Fläschchen" then
			return "Alchemy"
		elseif itemSubType == "Food & Drink" or itemSubType == "Essen & Trinken" then
			return "Cooking"
		elseif itemSubType == "Bandage" or itemSubType == "Verband" then
			return "First Aid"
		end
	elseif itemType == "Gem" or itemType == "Edelstein" then
		return "Jewelcrafting"
	elseif itemType == "Armor" or itemType == "Rüstung" then
		if itemSubType == "Cloth" or itemSubType == "Stoff" then
			return "Tailoring"
		elseif itemSubType == "Leather" or itemSubType == "Leder" then
			return "Leatherworking"
		elseif itemSubType == "Plate" or itemSubType == "Platte" or itemSubType == "Mail" or itemSubType == "Schwere Rüstung" then
			return "Blacksmithing"
		end
	end

	-- 5. Name heuristics
	if str:find("Muster:") or str:find("Pattern:") then
		return (str:find("Leder") or str:find("Leather") or str:find("Kürschner")) and "Leatherworking" or "Tailoring"
	elseif str:find("Pläne:") or str:find("Plans:") then
		return "Blacksmithing"
	elseif str:find("Bauplan:") or str:find("Schematic:") then
		return "Engineering"
	elseif str:find("Rezept:") or str:find("Recipe:") then
		return (str:find("Trank") or str:find("Elixier") or str:find("Öl") or str:find("Transmut")) and "Alchemy" or "Cooking"
	end

	return nil
end
