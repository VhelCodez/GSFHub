local ADDON_NAME, GSF = ...

GSF.DB = {}

local defaultSettings = {
	selectedLocale = "auto",
	enableToasts = true,
	enableSounds = true,
	announceDropsToParty = true,
	autoScanOnOpen = true,
	minimap = {
		hide = false,
		minimapPos = 220,
	},
	mainCharacter = "",
	myWishlist = {},
	myWorkOrders = {},
	mySurplus = {},
	characterProfessions = {},
}

local defaultCache = {
	guildName = "",
	realmName = "",
	members = {},
	workOrders = {},
	recentDrops = {},
	alts = {},
	revisions = {
		recipes = 0,
		orders = 0,
		surplus = 0,
	},
}

function GSF.DB:Initialize()
	-- Initialize global SavedVariables tables
	if not GSFHubDB then
		GSFHubDB = {}
	end
	if not GSFHubCache then
		GSFHubCache = {}
	end

	-- Apply defaults for DB
	for k, v in pairs(defaultSettings) do
		if GSFHubDB[k] == nil then
			if type(v) == "table" then
				GSFHubDB[k] = CopyTable(v)
			else
				GSFHubDB[k] = v
			end
		end
	end

	-- Apply defaults for Cache
	for k, v in pairs(defaultCache) do
		if GSFHubCache[k] == nil then
			if type(v) == "table" then
				GSFHubCache[k] = CopyTable(v)
			else
				GSFHubCache[k] = v
			end
		end
	end

	-- Bind to GSF instance
	GSF.db = GSFHubDB
	GSF.cache = GSFHubCache

	-- Update active localization language
	if GSF.UpdateActiveLanguage then
		GSF:UpdateActiveLanguage()
	end

	-- Clean expired work orders (> 7 days)
	self:CleanupExpiredOrders()
end

function GSF.DB:CleanupExpiredOrders()
	local now = time()
	if not GSF.cache or not GSF.cache.workOrders then return end
	
	for orderId, order in pairs(GSF.cache.workOrders) do
		if (now - (order.timestamp or 0)) > GSF.WORK_ORDER_TIMEOUT then
			if order.status == GSF.ORDER_STATUS.OPEN then
				order.status = GSF.ORDER_STATUS.CANCELLED
			end
		end
	end
end

function GSF.DB:GetPlayerName()
	local name, _ = UnitName("player")
	return name or "Unknown"
end

function GSF.DB:GetGuildName()
	local gName, _, _ = GetGuildInfo("player")
	return gName
end

function GSF.DB:GetPlayerClass()
	local _, class = UnitClass("player")
	return class
end

function GSF.DB:EnsureMemberRecord(name)
	if not GSF.cache.members[name] then
		GSF.cache.members[name] = {
			name = name,
			main = name,
			class = "UNKNOWN",
			lastSeen = time(),
			professions = {},
			surplus = {},
		}
	end
	return GSF.cache.members[name]
end
