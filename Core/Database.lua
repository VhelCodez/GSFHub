local ADDON_NAME, GSF = ...

GSF.DB = {}

local defaultSettings = {
	selectedLocale = "auto",
	enableToasts = true,
	enableSounds = true,
	announceDropsToParty = true,
	autoScanOnOpen = true,
	showGoalsHUD = true,
	goalsHUDPos = { point = "TOPRIGHT", relPoint = "TOPRIGHT", x = -20, y = -180 },
	minimap = {
		hide = false,
		minimapPos = 220,
	},
	mainCharacter = "",
	myWishlist = {},
	myWorkOrders = {},
	mySurplus = {},
	myGoals = {},
	myRoleTags = {},
	characterProfessions = {},
}

local defaultCache = {
	guildName = "",
	realmName = "",
	members = {},
	workOrders = {},
	bounties = {},
	recentDrops = {},
	alts = {},
	revisions = {
		recipes = 0,
		orders = 0,
		surplus = 0,
		bounties = 0,
	},
}

function GSF.DB:CreateEmptyScope(scopeKey, isGuild, guildName, realmName)
	return {
		scopeKey = scopeKey,
		guildName = guildName or "",
		realmName = realmName or "",
		isGuild = isGuild or false,
		members = {},
		workOrders = {},
		bounties = {},
		recentDrops = {},
		alts = {},
		revisions = {
			recipes = 0,
			orders = 0,
			surplus = 0,
			bounties = 0,
		},
	}
end

function GSF.DB:GetActiveScopeKey()
	local realm = GetRealmName() or "UnknownRealm"
	local guild = self:GetGuildName()
	if guild and guild ~= "" then
		return string.format("Guild - %s - %s", guild, realm), true, guild, realm
	else
		local player = self:GetPlayerName() or "UnknownPlayer"
		return string.format("Solo - %s - %s", player, realm), false, "", realm
	end
end

function GSF.DB:MigrateLegacyCache()
	if not GSFHubCache then GSFHubCache = {} end
	if GSFHubCache.scopes then return end -- Already migrated to scoped schema

	GSFHubCache.scopes = {}
	local realm = GSFHubCache.realmName or GetRealmName() or "UnknownRealm"
	local legacyGuild = GSFHubCache.guildName

	if legacyGuild and legacyGuild ~= "" then
		local guildScopeKey = string.format("Guild - %s - %s", legacyGuild, realm)
		local guildScope = self:CreateEmptyScope(guildScopeKey, true, legacyGuild, realm)
		
		if GSFHubCache.members then
			for k, v in pairs(GSFHubCache.members) do
				guildScope.members[k] = v
			end
		end
		if GSFHubCache.workOrders then
			for k, v in pairs(GSFHubCache.workOrders) do
				guildScope.workOrders[k] = v
			end
		end
		if GSFHubCache.bounties then
			for k, v in pairs(GSFHubCache.bounties) do
				guildScope.bounties[k] = v
			end
		end
		if GSFHubCache.alts then
			for k, v in pairs(GSFHubCache.alts) do
				guildScope.alts[k] = v
			end
		end
		if GSFHubCache.recentDrops then
			for _, v in ipairs(GSFHubCache.recentDrops) do
				table.insert(guildScope.recentDrops, v)
			end
		end
		if GSFHubCache.revisions then
			guildScope.revisions = CopyTable(GSFHubCache.revisions)
		end
		GSFHubCache.scopes[guildScopeKey] = guildScope
	elseif GSFHubCache.members and next(GSFHubCache.members) then
		-- Legacy data was unguilded / solo
		local myName = self:GetPlayerName()
		local soloKey = string.format("Solo - %s - %s", myName, realm)
		local soloScope = self:CreateEmptyScope(soloKey, false, "", realm)
		if GSFHubCache.members then
			for k, v in pairs(GSFHubCache.members) do
				soloScope.members[k] = v
			end
		end
		if GSFHubCache.workOrders then
			for k, v in pairs(GSFHubCache.workOrders) do
				soloScope.workOrders[k] = v
			end
		end
		if GSFHubCache.bounties then
			for k, v in pairs(GSFHubCache.bounties) do
				soloScope.bounties[k] = v
			end
		end
		if GSFHubCache.alts then
			for k, v in pairs(GSFHubCache.alts) do
				soloScope.alts[k] = v
			end
		end
		GSFHubCache.scopes[soloKey] = soloScope
	end
end

function GSF.DB:UpdateScope()
	local scopeKey, isGuild, guildName, realm = self:GetActiveScopeKey()
	if not GSFHubCache.scopes then
		GSFHubCache.scopes = {}
	end
	if not GSFHubCache.scopes[scopeKey] then
		GSFHubCache.scopes[scopeKey] = self:CreateEmptyScope(scopeKey, isGuild, guildName, realm)
	end

	local previousScopeKey = GSF.activeScopeKey
	GSF.cache = GSFHubCache.scopes[scopeKey]
	GSF.activeScopeKey = scopeKey
	GSF.isGuildScope = isGuild

	-- Mirror to legacy top-level keys for backward compatibility
	GSFHubCache.guildName = GSF.cache.guildName
	GSFHubCache.realmName = GSF.cache.realmName
	GSFHubCache.members = GSF.cache.members
	GSFHubCache.workOrders = GSF.cache.workOrders
	GSFHubCache.bounties = GSF.cache.bounties
	GSFHubCache.recentDrops = GSF.cache.recentDrops
	GSFHubCache.alts = GSF.cache.alts
	GSFHubCache.revisions = GSF.cache.revisions

	-- Sync active character's professions
	self:SyncActiveCharacterProfessions()

	-- Clean expired work orders (> 7 days) in current scope
	self:CleanupExpiredOrders()

	local scopeChanged = (previousScopeKey ~= nil and previousScopeKey ~= scopeKey)
	return scopeKey, isGuild, scopeChanged
end

function GSF.DB:PruneNonGuildMembers(currentGuildMembers)
	if not currentGuildMembers or not next(currentGuildMembers) then return end
	if not GSF.cache or not GSF.isGuildScope then return end

	local realm = GetRealmName() or "UnknownRealm"

	-- 1. Prune members who are not in the guild roster
	if GSF.cache.members then
		for memberName, memberData in pairs(GSF.cache.members) do
			if not currentGuildMembers[memberName] then
				-- If this member has personal data, preserve it in their isolated solo scope
				local soloKey = string.format("Solo - %s - %s", memberName, realm)
				if not GSFHubCache.scopes[soloKey] then
					GSFHubCache.scopes[soloKey] = self:CreateEmptyScope(soloKey, false, "", realm)
				end
				GSFHubCache.scopes[soloKey].members[memberName] = memberData

				-- Expunge from active guild cache
				GSF.cache.members[memberName] = nil
			end
		end
	end

	-- 2. Prune work orders requested by members not in the guild
	if GSF.cache.workOrders then
		for orderId, order in pairs(GSF.cache.workOrders) do
			if order.requester and not currentGuildMembers[order.requester] then
				-- Preserve in requester's solo scope
				local soloKey = string.format("Solo - %s - %s", order.requester, realm)
				if not GSFHubCache.scopes[soloKey] then
					GSFHubCache.scopes[soloKey] = self:CreateEmptyScope(soloKey, false, "", realm)
				end
				GSFHubCache.scopes[soloKey].workOrders[orderId] = order

				-- Expunge from active guild cache
				GSF.cache.workOrders[orderId] = nil
			end
		end
	end

	-- 3. Prune bounties requested by members not in the guild
	if GSF.cache.bounties then
		for bountyId, bounty in pairs(GSF.cache.bounties) do
			if bounty.requester and not currentGuildMembers[bounty.requester] then
				GSF.cache.bounties[bountyId] = nil
			end
		end
	end

	-- 4. Prune alts if neither alt nor main is in the guild
	if GSF.cache.alts then
		for alt, main in pairs(GSF.cache.alts) do
			if not currentGuildMembers[alt] and not currentGuildMembers[main] then
				GSF.cache.alts[alt] = nil
			end
		end
	end
end

function GSF.DB:GetMyProfessions()
	local myName = self:GetPlayerName()
	local realm = GetRealmName() or "UnknownRealm"
	local charKey = string.format("%s - %s", myName, realm)

	if GSFHubDB and GSFHubDB.characterProfessionsByChar and GSFHubDB.characterProfessionsByChar[charKey] then
		return GSFHubDB.characterProfessionsByChar[charKey]
	end

	if GSF.cache and GSF.cache.members and GSF.cache.members[myName] and GSF.cache.members[myName].professions then
		return GSF.cache.members[myName].professions
	end

	return {}
end

function GSF.DB:SyncActiveCharacterProfessions()
	local myName = self:GetPlayerName()
	local realm = GetRealmName() or "UnknownRealm"
	local charKey = string.format("%s - %s", myName, realm)

	if not GSFHubDB.characterProfessionsByChar then
		GSFHubDB.characterProfessionsByChar = {}
	end

	-- If we have character-specific professions, point GSF.db.characterProfessions to it
	if not GSFHubDB.characterProfessionsByChar[charKey] then
		GSFHubDB.characterProfessionsByChar[charKey] = {}
		-- If this character already has professions in active cache, copy over
		if GSF.cache and GSF.cache.members and GSF.cache.members[myName] and GSF.cache.members[myName].professions then
			for pName, pData in pairs(GSF.cache.members[myName].professions) do
				GSFHubDB.characterProfessionsByChar[charKey][pName] = pData
			end
		end
	end

	GSFHubDB.characterProfessions = GSFHubDB.characterProfessionsByChar[charKey]
end

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

	-- Migrate legacy flat cache to scoped architecture
	self:MigrateLegacyCache()

	-- Bind GSF.db
	GSF.db = GSFHubDB

	-- Bind GSF.cache to active scope
	self:UpdateScope()

	-- Update active localization language
	if GSF.UpdateActiveLanguage then
		GSF:UpdateActiveLanguage()
	end
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
