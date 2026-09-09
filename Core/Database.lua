local ADDON_NAME, GSF = ...

GSF.DB = {}

local defaultSettings = {
	selectedLocale = "auto",
	enableToasts = false,
	enableSounds = false,
	announceDropsToParty = true,
	autoScanOnOpen = true,
	showGoalsHUD = true,
	goalsHUDPos = { point = "TOPRIGHT", relPoint = "TOPRIGHT", x = -20, y = -180 },
	minimap = {
		hide = false,
		minimapPos = 220,
	},
	mainCharacter = "",
	wishlistByChar = {},
	goalsByChar = {},
	characterProfessionsByChar = {},
	myWorkOrders = {},
	mySurplus = {},
	myRoleTags = {},
}

local defaultCache = {
	scopes = {},
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

	-- Sync active character's professions, wishlist, and goals
	self:SyncActiveCharacterProfessions()
	self:SyncActiveCharacterWishlist()
	self:SyncActiveCharacterGoals()

	-- Normalize legacy localized profession keys (e.g. Alchimie -> Alchemy)
	if GSF.cache and GSF.cache.members then
		for _, member in pairs(GSF.cache.members) do
			if member.professions then
				self:NormalizeProfessionKeys(member.professions)
			end
		end
	end
	if GSFHubDB and GSFHubDB.characterProfessionsByChar then
		for _, profs in pairs(GSFHubDB.characterProfessionsByChar) do
			self:NormalizeProfessionKeys(profs)
		end
	end

	-- Clean expired work orders (> 7 days) in current scope
	self:CleanupExpiredOrders()

	local scopeChanged = (previousScopeKey ~= nil and previousScopeKey ~= scopeKey)
	return scopeKey, isGuild, scopeChanged
end

function GSF.DB:NormalizeProfessionKeys(profTable)
	if not profTable then return end
	local toMove = {}
	for pName, pData in pairs(profTable) do
		local canon = GSF.GetCanonicalProfession and GSF:GetCanonicalProfession(pName)
		if canon and canon ~= pName then
			table.insert(toMove, { oldKey = pName, newKey = canon, data = pData })
		end
	end
	for _, m in ipairs(toMove) do
		if not profTable[m.newKey] then
			m.data.name = m.newKey
			profTable[m.newKey] = m.data
		end
		profTable[m.oldKey] = nil
	end
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
	if not myName or myName == "" or myName == "Unknown" then
		return
	end
	local realm = GetRealmName() or "UnknownRealm"
	local charKey = string.format("%s - %s", myName, realm)

	if not GSFHubDB.characterProfessionsByChar then
		GSFHubDB.characterProfessionsByChar = {}
	end

	if not GSFHubDB.characterProfessionsByChar[charKey] then
		GSFHubDB.characterProfessionsByChar[charKey] = {}
		-- If this character already has professions in active cache, copy over
		if GSF.cache and GSF.cache.members and GSF.cache.members[myName] and GSF.cache.members[myName].professions then
			for pName, pData in pairs(GSF.cache.members[myName].professions) do
				GSFHubDB.characterProfessionsByChar[charKey][pName] = pData
			end
		end
	end

	-- Two-way restore: If active cache member record exists or is initialized, restore saved professions to runtime cache
	if GSF.cache and GSF.cache.members then
		local member = self:EnsureMemberRecord(myName)
		member.professions = member.professions or {}
		for pName, pData in pairs(GSFHubDB.characterProfessionsByChar[charKey]) do
			if not member.professions[pName] then
				member.professions[pName] = pData
			end
		end
	end

	if GSF.db then
		GSF.db.characterProfessions = GSFHubDB.characterProfessionsByChar[charKey]
	end
end

function GSF.DB:SyncActiveCharacterWishlist()
	local myName = self:GetPlayerName()
	if not myName or myName == "" or myName == "Unknown" then
		return
	end
	local realm = GetRealmName() or "UnknownRealm"
	local charKey = string.format("%s - %s", myName, realm)

	if not GSFHubDB.wishlistByChar then
		GSFHubDB.wishlistByChar = {}
	end

	if not GSFHubDB.wishlistByChar[charKey] then
		GSFHubDB.wishlistByChar[charKey] = {}
	end

	if GSF.db then
		GSF.db.myWishlist = GSFHubDB.wishlistByChar[charKey]
	end
end

function GSF.DB:SyncActiveCharacterGoals()
	local myName = self:GetPlayerName()
	if not myName or myName == "" or myName == "Unknown" then
		return
	end
	local realm = GetRealmName() or "UnknownRealm"
	local charKey = string.format("%s - %s", myName, realm)

	if not GSFHubDB.goalsByChar then
		GSFHubDB.goalsByChar = {}
	end

	if not GSFHubDB.goalsByChar[charKey] then
		GSFHubDB.goalsByChar[charKey] = {}
	end

	if GSF.db then
		GSF.db.myGoals = GSFHubDB.goalsByChar[charKey]
	end
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

	-- Apply defaults for Cache
	if not GSFHubCache.scopes then
		GSFHubCache.scopes = {}
	end

	-- Bind GSF.db
	GSF.db = GSFHubDB
	GSF.db.enableToasts = false
	GSF.db.enableSounds = false

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
			classFileName = nil,
			level = 0,
			isOnline = false,
			lastSeen = time(),
			professions = {},
			surplus = {},
			wishlist = {},
		}
	end
	local rec = GSF.cache.members[name]
	if name == self:GetPlayerName() then
		local locClass, engClass = UnitClass("player")
		if locClass and locClass ~= "" then rec.class = locClass end
		if engClass and engClass ~= "" then rec.classFileName = engClass end
		local lvl = UnitLevel("player")
		if lvl and lvl > 0 then rec.level = lvl end
		rec.isOnline = true
	end
	return rec
end

function GSF.DB:RebuildGuildCache()
	local myName = self:GetPlayerName()
	if not GSF.cache then return end

	-- Keep own member record intact
	local myMember = GSF.cache.members and GSF.cache.members[myName]

	-- Keep own active work orders
	local myOrders = {}
	if GSF.cache.workOrders then
		for id, order in pairs(GSF.cache.workOrders) do
			if order.requester == myName then
				myOrders[id] = order
			end
		end
	end

	-- Keep own active bounties
	local myBounties = {}
	if GSF.cache.bounties then
		for id, bounty in pairs(GSF.cache.bounties) do
			if bounty.requester == myName then
				myBounties[id] = bounty
			end
		end
	end

	-- Reset cache collections
	GSF.cache.members = {}
	if myMember then
		GSF.cache.members[myName] = myMember
	else
		self:EnsureMemberRecord(myName)
	end

	GSF.cache.workOrders = myOrders
	GSF.cache.bounties = myBounties
	GSF.cache.recentDrops = {}
	GSF.cache.revisions = {
		recipes = 0,
		orders = 0,
		surplus = 0,
		bounties = 0,
	}

	-- Request fresh full sync from online guild peers
	if GSF.Sync and GSF.isGuildScope and GSF.Sync.BroadcastHello then
		GSF.Sync:BroadcastHello(true)
	end

	-- Refresh active UI tab
	if GSF.MainFrame and GSF.MainFrame:IsShown() then
		GSF.MainFrame:RefreshCurrentTab()
	end

	if GSF.Addon then
		GSF.Addon:Printf(GSF.L["CACHE_REBUILT_MSG"] or "|cff33ff99Guild cache cleared. Requesting fresh data from online members...|r")
	end
end

function GSF.DB:ResetActiveCharacterData()
	local myName = self:GetPlayerName()
	local realm = GetRealmName() or "UnknownRealm"
	local charKey = string.format("%s - %s", myName, realm)

	if GSFHubDB and GSFHubDB.wishlistByChar then
		GSFHubDB.wishlistByChar[charKey] = {}
	end
	if GSFHubDB and GSFHubDB.goalsByChar then
		GSFHubDB.goalsByChar[charKey] = {}
	end
	if GSFHubDB and GSFHubDB.characterProfessionsByChar then
		GSFHubDB.characterProfessionsByChar[charKey] = {}
	end

	if GSF.cache and GSF.cache.members and GSF.cache.members[myName] then
		GSF.cache.members[myName].professions = {}
	end

	if GSF.Scanner and GSF.Scanner.ScanSkillLines then
		GSF.Scanner:ScanSkillLines()
	end

	if GSF.db then
		GSF.db.myWishlist = (GSFHubDB and GSFHubDB.wishlistByChar and GSFHubDB.wishlistByChar[charKey]) or {}
		GSF.db.myGoals = (GSFHubDB and GSFHubDB.goalsByChar and GSFHubDB.goalsByChar[charKey]) or {}
		GSF.db.characterProfessions = (GSFHubDB and GSFHubDB.characterProfessionsByChar and GSFHubDB.characterProfessionsByChar[charKey]) or {}
	end

	if GSF.GoalsHUD and GSF.GoalsHUD.Refresh then
		GSF.GoalsHUD:Refresh()
	end
	if GSF.GoalsHUD and GSF.GoalsHUD.RefreshManagerDialog then
		GSF.GoalsHUD:RefreshManagerDialog()
	end

	if GSF.MainFrame and GSF.MainFrame:IsShown() then
		GSF.MainFrame:RefreshCurrentTab()
	end

	if GSF.Addon then
		GSF.Addon:Printf(string.format(GSF.L["CHAR_RESET_MSG"] or "|cff33ff99Character data reset for %s.|r", myName))
	end
end

function GSF.DB:FactoryReset()
	local myName = self:GetPlayerName()

	-- Broadcast cancellation for any open work orders created by this player
	if GSF.cache and GSF.cache.workOrders and GSF.Sync and GSF.isGuildScope then
		for orderId, order in pairs(GSF.cache.workOrders) do
			if order.requester == myName and order.status == GSF.ORDER_STATUS.OPEN then
				GSF.Sync:SendPacket(GSF.OPCODE.WORK_ORDER_STAT, {
					orderId = orderId,
					status = GSF.ORDER_STATUS.CANCELLED,
				}, "GUILD")
			end
		end
	end

	-- Broadcast cancellation for any open bounties created by this player
	if GSF.cache and GSF.cache.bounties and GSF.Sync and GSF.isGuildScope then
		for bountyId, bounty in pairs(GSF.cache.bounties) do
			if bounty.requester == myName and bounty.status == GSF.BOUNTY_STATUS.OPEN then
				GSF.Sync:SendPacket(GSF.OPCODE.BOUNTY_CANCEL, {
					bountyId = bountyId,
				}, "GUILD")
			end
		end
	end

	-- Wipe SavedVariables
	GSFHubDB = nil
	GSFHubCache = nil

	-- Reload UI
	ReloadUI()
end
