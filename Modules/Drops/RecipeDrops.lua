local ADDON_NAME, GSF = ...

local AceEvent = LibStub("AceEvent-3.0")
GSF.RecipeDrops = {}
AceEvent:Embed(GSF.RecipeDrops)

GSF.RECIPE_DROP_TIMEOUT = 86400 -- 24 hours

function GSF.RecipeDrops:Initialize()
	self:RegisterEvent("CHAT_MSG_LOOT", "OnLootMessage")
	self:RegisterEvent("LOOT_OPENED", "OnLootOpened")
	self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
	self:RegisterEvent("MERCHANT_CLOSED", "OnMerchantClosed")
	self:RegisterEvent("CHAT_MSG_PARTY", "OnChatMessage")
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER", "OnChatMessage")
	self:RegisterEvent("CHAT_MSG_RAID", "OnChatMessage")
	self:RegisterEvent("CHAT_MSG_RAID_LEADER", "OnChatMessage")

	-- Hook merchant buy functions to suppress vendor bought recipes/handbooks from drops
	if not self.hookedMerchant then
		hooksecurefunc("BuyMerchantItem", function(index, count)
			GSF.RecipeDrops.lastMerchantBuyTime = GetTime()
		end)
		hooksecurefunc("BuybackItem", function(index)
			GSF.RecipeDrops.lastMerchantBuyTime = GetTime()
		end)
		self.hookedMerchant = true
	end

	self.recentPartyAnnounced = {}
	self.recentSeenDrops = {}

	self:CleanupWishlistDuplicates()
	self:PruneExpiredDrops()
end

function GSF.RecipeDrops:OnChatMessage(event, message, sender)
	if not message or not message:find("^%[GSF%]") then return end
	self.recentPartyAnnounced = self.recentPartyAnnounced or {}
	local now = GetTime()

	local itemLink = message:match("(|c%x+|Hitem:%d+:.+|h%[.-%]|h|r)")
	if itemLink then
		local itemId = tonumber(itemLink:match("item:(%d+)"))
		if itemId and itemId > 0 then
			self.recentPartyAnnounced[itemId] = now
		end
		local clean = self:CleanRecipeName(itemLink):lower()
		if clean ~= "" then
			self.recentPartyAnnounced[clean] = now
		end
	end
end

function GSF.RecipeDrops:OnMerchantShow()
	self.isAtMerchant = true
	self.lastMerchantBuyTime = GetTime()
end

function GSF.RecipeDrops:OnMerchantClosed()
	self.isAtMerchant = false
	self.lastMerchantCloseTime = GetTime()
end

function GSF.RecipeDrops:IsClassOrPetTome(name)
	if not name then return false end
	local lower = name:lower()
	if lower:find("grimoire") then return true end
	if lower:find("tome of") or lower:find("buch des") or lower:find("buch der") then return true end
	return false
end

function GSF.RecipeDrops:PruneExpiredDrops()
	if not GSF.cache or not GSF.cache.recentDrops then return end
	local now = time()
	local valid = {}
	for _, drop in ipairs(GSF.cache.recentDrops) do
		local isExpired = not drop.timestamp or ((now - drop.timestamp) >= GSF.RECIPE_DROP_TIMEOUT)
		local isTome = drop.name and self:IsClassOrPetTome(drop.name)
		local canonProf = drop.profession and GSF.GetCanonicalProfession and GSF:GetCanonicalProfession(drop.profession)
		local isValidProf = canonProf and GSF.PROFESSIONS and GSF.PROFESSIONS[canonProf]
		if not isExpired and not isTome and isValidProf then
			table.insert(valid, drop)
		end
	end
	GSF.cache.recentDrops = valid
end

function GSF.RecipeDrops:DismissDrop(index)
	if not GSF.cache or not GSF.cache.recentDrops then return end
	if index and GSF.cache.recentDrops[index] then
		table.remove(GSF.cache.recentDrops, index)
	end
end

function GSF.RecipeDrops:CleanupWishlistDuplicates()
	if not GSF.db or not GSF.db.myWishlist then return end
	local seenIds = {}
	local seenNames = {}
	local toRemove = {}

	for key, item in pairs(GSF.db.myWishlist) do
		local id = tonumber(key) or (item.link and tonumber(item.link:match("item:(%d+)"))) or item.id
		local rawName = (item.name or key):lower():gsub("|c%x+|h", ""):gsub("|h|r", ""):gsub("%[", ""):gsub("%]", ""):trim()

		if id and id > 0 then
			if seenIds[id] then
				table.insert(toRemove, key)
			else
				seenIds[id] = key
				if rawName ~= "" then seenNames[rawName] = key end
			end
		elseif rawName ~= "" then
			if seenNames[rawName] then
				table.insert(toRemove, key)
			else
				seenNames[rawName] = key
			end
		end
	end

	for _, k in ipairs(toRemove) do
		GSF.db.myWishlist[k] = nil
	end
end

function GSF.RecipeDrops:IsRecipeItem(input)
	if not input or input == "" then return false end
	if self:IsClassOrPetTome(tostring(input)) then return false end

	local itemId = tonumber(tostring(input):match("item:(%d+)")) or (type(input) == "number" and input) or (tostring(input):match("^%d+$") and tonumber(input)) or tonumber(tostring(input):match("#(%d+)"))
	if itemId and itemId > 0 then
		if C_Item and C_Item.GetItemInfoInstant then
			local _, _, _, _, _, classID = C_Item.GetItemInfoInstant(itemId)
			if classID then
				return classID == 9 or classID == (LE_ITEM_CLASS_RECIPE or 9)
			end
		end
	end

	local itemName, itemLink, _, _, _, itemType, _, _, _, _, _, classID = GetItemInfo(input)
	if itemName and self:IsClassOrPetTome(itemName) then
		return false
	end

	if classID then
		return classID == 9 or classID == (LE_ITEM_CLASS_RECIPE or 9)
	end

	if itemType == "Recipe" or itemType == "Rezept" then
		return true
	end

	local str = tostring(itemName or input)
	if str:find("^(Pattern|Plans|Schematic|Recipe|Formula|Manual|Design):") or
	   str:find("^(Muster|Pläne|Bauplan|Rezept|Formel|Handbuch|Vorlage):") or
	   str:find("%f[%a]Pattern%f[%A]") or str:find("%f[%a]Plans%f[%A]") or str:find("%f[%a]Schematic%f[%A]") or
	   str:find("%f[%a]Recipe%f[%A]") or str:find("%f[%a]Formula%f[%A]") or str:find("%f[%a]Manual%f[%A]") or
	   str:find("%f[%a]Muster%f[%A]") or str:find("%f[%a]Pläne%f[%A]") or str:find("%f[%a]Bauplan%f[%A]") or
	   str:find("%f[%a]Rezept%f[%A]") or str:find("%f[%a]Formel%f[%A]") or str:find("%f[%a]Handbuch%f[%A]") then
		return true
	end

	-- If it is a numeric ID currently loading from server, accept it tentatively
	if itemId and itemId > 0 and (tostring(input):find("Wird geladen") or tostring(input):find("Loading") or tostring(input):match("^%d+$")) then
		return true
	end

	-- Also accept if it matches a known craft recipe name in GSF's recipe index
	if GSF.RecipeBook and GSF.RecipeBook.Search then
		local results = GSF.RecipeBook:Search(str, "ALL", false)
		if results and #results > 0 then
			for _, r in ipairs(results) do
				if r.name and (r.name:lower() == str:lower() or str:lower():find(r.name:lower(), 1, true)) then
					return true
				end
			end
		end
	end

	return false
end

function GSF.RecipeDrops:AddToWishlist(input)
	if not input or input:trim() == "" then return false end
	local trimmed = input:trim()

	if not self:IsRecipeItem(trimmed) then
		if GSF.Addon then
			GSF.Addon:Print(GSF.L["WISHLIST_RECIPES_ONLY"] or "Only recipes, schematics, patterns, and formulas can be added to the recipe wishlist.")
		end
		return false
	end

	local itemId = tonumber(trimmed:match("item:(%d+)") or (trimmed:match("^%d+$") and trimmed) or trimmed:match("#(%d+)") or 0)
	local cleanQuery = trimmed:gsub("^%[", ""):gsub("%]$", ""):trim()
	local query = (itemId and itemId > 0) and itemId or cleanQuery
	local itemName, itemLink = GetItemInfo(query)

	local validLink = itemLink and (tostring(itemLink):find("|H.-|h") or tostring(itemLink):find("^item:") or tostring(itemLink):find("^spell:")) and itemLink or nil

	if not itemName then
		if itemId and itemId > 0 then
			itemName = string.format(GSF.L["ITEM_LOADING"] or "Item #%d (Loading...)", itemId)
			validLink = nil
		elseif #cleanQuery < 3 or cleanQuery:lower() == "lorem ipsum" or cleanQuery:lower() == "d" then
			if GSF.Addon then
				GSF.Addon:Print(GSF.L["WISHLIST_INVALID_INPUT"] or "Please provide a valid item link (Shift-Click) or recipe name.")
			end
			return false
		else
			itemName = cleanQuery
			validLink = nil
		end
	else
		itemName = itemName or cleanQuery
	end

	-- Robust Deduplication: Check BOTH numeric ID and normalized item name
	GSF.db.myWishlist = GSF.db.myWishlist or {}
	local targetLowerName = itemName:lower():gsub("|c%x+|h", ""):gsub("|h|r", ""):gsub("%[", ""):gsub("%]", ""):trim()

	for existingKey, existingItem in pairs(GSF.db.myWishlist) do
		local existingId = tonumber(existingKey) or (existingItem.link and tonumber(existingItem.link:match("item:(%d+)"))) or existingItem.id
		local existingName = (existingItem.name or existingKey):lower():gsub("|c%x+|h", ""):gsub("|h|r", ""):gsub("%[", ""):gsub("%]", ""):trim()

		local idMatch = (itemId and itemId > 0 and existingId and existingId == itemId)
		local nameMatch = (targetLowerName ~= "" and (existingName == targetLowerName or existingName:find(targetLowerName, 1, true) or targetLowerName:find(existingName, 1, true)))

		if idMatch or nameMatch then
			-- Already on wishlist! Upgrade existing entry if new one has better link/ID
			if itemId and itemId > 0 and not existingItem.id then
				existingItem.id = itemId
			end
			if validLink and not (existingItem.link and existingItem.link:find("item:")) then
				existingItem.link = validLink
			end
			if GSF.Addon then
				GSF.Addon:Printf(GSF.L["ALREADY_ON_WISHLIST"] or "%s is already on your wishlist.", validLink or itemName)
			end
			return false
		end
	end

	local key = (itemId and itemId > 0) and tostring(itemId) or itemName

	GSF.db.myWishlist = GSF.db.myWishlist or {}
	if GSF.db.myWishlist[key] then
		GSF.Addon:Printf(GSF.L["ALREADY_ON_WISHLIST"] or "%s is already on your wishlist.", validLink or itemName)
		return
	end

	GSF.db.myWishlist[key] = {
		name = itemName,
		link = validLink,
		id = (itemId and itemId > 0) and itemId or nil,
		addedAt = time(),
	}

	GSF.Addon:Printf(GSF.L["ADDED_TO_WISHLIST"] or "Added %s to your recipe wishlist.", validLink or itemName)

	if GSF.Sync then
		GSF.Sync:SendMyData()
	end
end

function GSF.RecipeDrops:RemoveFromWishlist(key)
	if GSF.db.myWishlist and GSF.db.myWishlist[tostring(key)] then
		local item = GSF.db.myWishlist[tostring(key)]
		GSF.db.myWishlist[tostring(key)] = nil
		GSF.Addon:Printf(GSF.L["REMOVED_FROM_WISHLIST"] or "Removed %s from wishlist.", item.link or item.name)

		if GSF.Sync then
			GSF.Sync:SendMyData()
		end
	end
end

function GSF.RecipeDrops:OnLootMessage(event, message, sender)
	if not message then return end

	-- Suppress vendor purchases from being recorded as drops
	local now = GetTime()
	if (MerchantFrame and MerchantFrame:IsShown()) or self.isAtMerchant then
		return
	end
	if self.lastMerchantBuyTime and (now - self.lastMerchantBuyTime) < 3.0 then
		return
	end
	if self.lastMerchantCloseTime and (now - self.lastMerchantCloseTime) < 2.0 then
		return
	end

	local itemLink = message:match("(|c%x+|Hitem:%d+:.+|h%[.-%]|h|r)")
	if itemLink then
		self:ProcessItemDrop(itemLink, sender or "Group")
	end
end

function GSF.RecipeDrops:OnLootOpened()
	local numItems = GetNumLootItems()
	for i = 1, numItems do
		local link = GetLootSlotLink(i)
		if link then
			self:ProcessItemDrop(link, "Loot Window")
		end
	end
end

function GSF.RecipeDrops:CleanRecipeName(rawName)
	if not rawName then return "" end
	local clean = rawName:gsub("|c%x+|h", ""):gsub("|h|r", ""):gsub("%[", ""):gsub("%]", ""):trim()
	-- Strip common prefixes (Pattern:, Recipe:, Rezept:, Vorlage:, etc.)
	local prefixes = {
		"^Pattern:%s*", "^Plans:%s*", "^Schematic:%s*", "^Recipe:%s*", "^Formula:%s*", "^Manual:%s*", "^Design:%s*",
		"^Muster:%s*", "^Pläne:%s*", "^Bauplan:%s*", "^Rezept:%s*", "^Formel:%s*", "^Handbuch:%s*", "^Vorlage:%s*",
	}
	for _, pat in ipairs(prefixes) do
		clean = clean:gsub(pat, "")
	end
	return clean:trim()
end

function GSF.RecipeDrops:ProcessItemDrop(itemLink, source)
	local itemName, _, itemQuality, _, _, itemType, itemSubType, _, _, _, _, classID = GetItemInfo(itemLink)
	if not itemName then return end

	-- Exclude class ability books & Warlock pet grimoires
	if self:IsClassOrPetTome(itemName) then
		return
	end

	local isRecipe = false
	if classID == 9 or (Enum and Enum.ItemClass and classID == Enum.ItemClass.Recipe) then
		isRecipe = true
	elseif itemType == "Recipe" or itemType == "Rezept" then
		isRecipe = true
	elseif itemName and (
		itemName:find("Pattern:") or itemName:find("Plans:") or itemName:find("Schematic:") or 
		itemName:find("Recipe:") or itemName:find("Formula:") or itemName:find("Manual:") or itemName:find("Design:") or
		itemName:find("Muster:") or itemName:find("Pläne:") or itemName:find("Bauplan:") or 
		itemName:find("Rezept:") or itemName:find("Formel:") or itemName:find("Handbuch:") or itemName:find("Vorlage:")
	) then
		isRecipe = true
	end

	if not isRecipe then return end

	local rawProf = itemSubType or "Unknown"
	local profession = GSF:GetCanonicalProfession(rawProf)
	if profession == "Book" or profession == "Unknown" or profession == "Buch" or profession == "Rezept" or not profession then
		if itemName:find("Pattern:") or itemName:find("Muster:") then profession = "Tailoring"
		elseif itemName:find("Plans:") or itemName:find("Pläne:") then profession = "Blacksmithing"
		elseif itemName:find("Schematic:") or itemName:find("Bauplan:") then profession = "Engineering"
		elseif itemName:find("Recipe:") or itemName:find("Rezept:") then profession = "Alchemy"
		elseif itemName:find("Formula:") or itemName:find("Formel:") then profession = "Enchanting"
		elseif itemName:find("Design:") or itemName:find("Vorlage:") then profession = "Jewelcrafting"
		elseif itemName:find("Manual:") or itemName:find("Handbuch:") then profession = "First Aid"
		end
	end
	profession = GSF:GetCanonicalProfession(profession) or profession

	-- Must belong to a recognized trade skill profession in GSF.PROFESSIONS
	if not GSF.PROFESSIONS or not GSF.PROFESSIONS[profession] then
		return
	end

	local cleanDropName = self:CleanRecipeName(itemName):lower()
	local itemId = tonumber(itemLink:match("item:(%d+)") or 0)
	local dropKey = (itemId and itemId > 0) and itemId or cleanDropName
	local now = GetTime()

	-- 1. Deduplication / Cooldown: Skip duplicate processing within 60 seconds
	self.recentSeenDrops = self.recentSeenDrops or {}
	if self.recentSeenDrops[dropKey] and (now - self.recentSeenDrops[dropKey]) < 60 then
		return
	end
	self.recentSeenDrops[dropKey] = now

	-- 2. Deduplicate in recentDrops cache: prevent inserting multiple times
	if GSF.cache and GSF.cache.recentDrops then
		for k = 1, math.min(10, #GSF.cache.recentDrops) do
			local prev = GSF.cache.recentDrops[k]
			if prev and (prev.cleanName == cleanDropName or (itemId and itemId > 0 and prev.link and prev.link:find("item:" .. itemId))) then
				if (time() - (prev.timestamp or 0)) < 60 then
					return
				end
			end
		end
	end

	-- Find who needs it (guild crafters with this profession who do NOT know the recipe yet)
	local neededBy = {}
	local wishlistedBy = {}

	if GSF.cache and GSF.cache.members then
		for memberName, memberData in pairs(GSF.cache.members) do
			if memberData.professions then
				-- Look up active profession on member
				local profData = memberData.professions[profession]
				if not profData then
					for pK, pV in pairs(memberData.professions) do
						if GSF:GetCanonicalProfession(pK) == profession then
							profData = pV
							break
						end
					end
				end

				if profData then
					local knows = false
					for _, r in pairs(profData.recipes or {}) do
						local rName = r.name and self:CleanRecipeName(r.name):lower() or ""
						if rName ~= "" and cleanDropName ~= "" then
							if rName == cleanDropName or rName:find(cleanDropName, 1, true) or cleanDropName:find(rName, 1, true) then
								knows = true
								break
							end
						end
					end
					if not knows then
						table.insert(neededBy, memberName)
					end
				end
			end
		end
	end

	-- Check wishlists (local player and guild members)
	local myName = GSF.DB:GetPlayerName()
	if GSF.db and GSF.db.myWishlist and (GSF.db.myWishlist[tostring(itemId)] or GSF.db.myWishlist[itemName]) then
		table.insert(wishlistedBy, myName)
	end
	if GSF.cache and GSF.cache.members then
		for memberName, memberData in pairs(GSF.cache.members) do
			if memberName ~= myName and memberData.wishlist then
				if (itemId and itemId > 0 and memberData.wishlist[tostring(itemId)]) or memberData.wishlist[itemName] then
					table.insert(wishlistedBy, memberName)
				end
			end
		end
	end

	-- Record recent drop
	local dropRecord = {
		link = itemLink,
		name = itemName,
		cleanName = cleanDropName,
		profession = profession,
		neededBy = neededBy,
		wishlistedBy = wishlistedBy,
		timestamp = time(),
		source = source,
	}

	GSF.cache.recentDrops = GSF.cache.recentDrops or {}
	table.insert(GSF.cache.recentDrops, 1, dropRecord)
	self:PruneExpiredDrops()
	if #GSF.cache.recentDrops > 30 then
		table.remove(GSF.cache.recentDrops)
	end

	-- Alert player
	if #neededBy > 0 or #wishlistedBy > 0 then
		local needStr = table.concat(neededBy, ", ")
		if #needStr > 60 then needStr = needStr:sub(1, 60) .. "..." end
		local alertMsg = string.format(GSF.L["RECIPE_DROP_ALERT"], itemLink, #neededBy, needStr ~= "" and needStr or "None")
		
		DEFAULT_CHAT_FRAME:AddMessage(alertMsg)

		if GSF.Toast and GSF.db.enableToasts then
			GSF.Toast:ShowToast(string.format("Recipe Drop: %s (|cff33ff99%d crafters need|r)", itemName, #neededBy))
		end

		-- Announce to Party/Raid if enabled (throttled across party to prevent duplicate spam)
		if GSF.db and GSF.db.announceDropsToParty and (IsInRaid() or IsInGroup()) then
			self.recentPartyAnnounced = self.recentPartyAnnounced or {}
			local lastAnnounced = self.recentPartyAnnounced[dropKey] or self.recentPartyAnnounced[cleanDropName] or 0
			if (now - lastAnnounced) >= 60 then
				self.recentPartyAnnounced[dropKey] = now
				self.recentPartyAnnounced[cleanDropName] = now
				local channel = IsInRaid() and "RAID" or "PARTY"
				local announce = string.format("[GSF] %s dropped! %d guild crafters need this: %s", itemName, #neededBy, needStr)
				SendChatMessage(announce, channel)
			end
		end
	end
end
