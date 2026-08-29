local ADDON_NAME, GSF = ...

local AceEvent = LibStub("AceEvent-3.0")
GSF.RecipeDrops = {}
AceEvent:Embed(GSF.RecipeDrops)

function GSF.RecipeDrops:Initialize()
	self:RegisterEvent("CHAT_MSG_LOOT", "OnLootMessage")
	self:RegisterEvent("LOOT_OPENED", "OnLootOpened")
	self:CleanupWishlistDuplicates()
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

	local itemId = tonumber(tostring(input):match("item:(%d+)")) or (type(input) == "number" and input) or (tostring(input):match("^%d+$") and tonumber(input))
	if itemId and itemId > 0 then
		if C_Item and C_Item.GetItemInfoInstant then
			local _, _, _, _, _, classID = C_Item.GetItemInfoInstant(itemId)
			if classID then
				return classID == 9 or classID == (LE_ITEM_CLASS_RECIPE or 9)
			end
		end
	end

	local itemName, itemLink, _, _, _, itemType, _, _, _, _, _, classID = GetItemInfo(input)
	if classID then
		return classID == 9 or classID == (LE_ITEM_CLASS_RECIPE or 9)
	end

	if itemType == "Recipe" or itemType == "Rezept" then
		return true
	end

	local str = tostring(itemName or input)
	if str:find("^(Pattern|Plans|Schematic|Recipe|Formula|Manual|Design|Book):") or
	   str:find("^(Muster|Pläne|Bauplan|Rezept|Formel|Handbuch|Vorlage|Buch):") or
	   str:find("%f[%a]Pattern%f[%A]") or str:find("%f[%a]Plans%f[%A]") or str:find("%f[%a]Schematic%f[%A]") or
	   str:find("%f[%a]Recipe%f[%A]") or str:find("%f[%a]Formula%f[%A]") or str:find("%f[%a]Manual%f[%A]") or
	   str:find("%f[%a]Muster%f[%A]") or str:find("%f[%a]Pläne%f[%A]") or str:find("%f[%a]Bauplan%f[%A]") or
	   str:find("%f[%a]Rezept%f[%A]") or str:find("%f[%a]Formel%f[%A]") or str:find("%f[%a]Handbuch%f[%A]") then
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

	local itemId = tonumber(trimmed:match("item:(%d+)") or (trimmed:match("^%d+$") and trimmed) or 0)
	local query = (itemId and itemId > 0) and itemId or trimmed
	local itemName, itemLink = GetItemInfo(query)

	if not itemName and itemId == 0 then
		if #trimmed < 3 or trimmed:lower() == "lorem ipsum" or trimmed:lower() == "d" then
			if GSF.Addon then
				GSF.Addon:Print(GSF.L["WISHLIST_INVALID_INPUT"] or "Please provide a valid item link (Shift-Click) or recipe name.")
			end
			return false
		end
		itemName = trimmed
		itemLink = trimmed
	else
		itemName = itemName or trimmed
		itemLink = itemLink or trimmed
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
			if itemLink and itemLink:find("item:") and not (existingItem.link and existingItem.link:find("item:")) then
				existingItem.link = itemLink
			end
			if GSF.Addon then
				GSF.Addon:Printf(GSF.L["ALREADY_ON_WISHLIST"] or "%s is already on your wishlist.", itemLink or itemName)
			end
			return false
		end
	end

	local key = (itemId and itemId > 0) and tostring(itemId) or itemName

	GSF.db.myWishlist = GSF.db.myWishlist or {}
	if GSF.db.myWishlist[key] then
		GSF.Addon:Printf(GSF.L["ALREADY_ON_WISHLIST"] or "%s is already on your wishlist.", itemLink)
		return
	end

	GSF.db.myWishlist[key] = {
		name = itemName,
		link = itemLink,
		addedAt = time(),
	}

	GSF.Addon:Printf(GSF.L["ADDED_TO_WISHLIST"] or "Added %s to your recipe wishlist.", itemLink)

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

function GSF.RecipeDrops:ProcessItemDrop(itemLink, source)
	local itemName, _, itemQuality, _, _, itemType, itemSubType, _, _, _, _, classID = GetItemInfo(itemLink)

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

	local profession = itemSubType or "Unknown"
	if profession == "Book" or profession == "Unknown" or profession == "Buch" or profession == "Rezept" then
		if itemName:find("Pattern:") or itemName:find("Muster:") then profession = "Tailoring"
		elseif itemName:find("Plans:") or itemName:find("Pläne:") then profession = "Blacksmithing"
		elseif itemName:find("Schematic:") or itemName:find("Bauplan:") then profession = "Engineering"
		elseif itemName:find("Recipe:") or itemName:find("Rezept:") then profession = "Alchemy"
		elseif itemName:find("Formula:") or itemName:find("Formel:") then profession = "Enchanting"
		elseif itemName:find("Design:") or itemName:find("Vorlage:") then profession = "Jewelcrafting"
		elseif itemName:find("Manual:") or itemName:find("Handbuch:") then profession = "First Aid"
		end
	end

	-- Find who needs it
	local neededBy = {}
	local wishlistedBy = {}

	if GSF.cache and GSF.cache.members then
		for memberName, memberData in pairs(GSF.cache.members) do
			if memberData.professions and memberData.professions[profession] then
				local knows = false
				for _, r in pairs(memberData.professions[profession].recipes or {}) do
					if r.name and itemName:find(r.name, 1, true) then
						knows = true
						break
					end
				end
				if not knows then
					table.insert(neededBy, memberName)
				end
			end
		end
	end

	-- Check wishlists
	local itemId = tonumber(itemLink:match("item:(%d+)") or 0)
	if GSF.db.myWishlist and (GSF.db.myWishlist[tostring(itemId)] or GSF.db.myWishlist[itemName]) then
		table.insert(wishlistedBy, GSF.DB:GetPlayerName())
	end

	-- Record recent drop
	local dropRecord = {
		link = itemLink,
		name = itemName,
		profession = profession,
		neededBy = neededBy,
		wishlistedBy = wishlistedBy,
		timestamp = time(),
		source = source,
	}

	GSF.cache.recentDrops = GSF.cache.recentDrops or {}
	table.insert(GSF.cache.recentDrops, 1, dropRecord)
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

		-- Announce to Party/Raid if enabled
		if GSF.db.announceDropsToParty and (IsInRaid() or IsInGroup()) then
			local channel = IsInRaid() and "RAID" or "PARTY"
			local announce = string.format("[GSF] %s dropped! %d guild crafters need this: %s", itemName, #neededBy, needStr)
			SendChatMessage(announce, channel)
		end
	end
end
