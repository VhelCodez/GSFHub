local ADDON_NAME, GSF = ...

local AceEvent = LibStub("AceEvent-3.0")
GSF.RecipeDrops = {}
AceEvent:Embed(GSF.RecipeDrops)

function GSF.RecipeDrops:Initialize()
	self:RegisterEvent("CHAT_MSG_LOOT", "OnLootMessage")
	self:RegisterEvent("LOOT_OPENED", "OnLootOpened")
end

function GSF.RecipeDrops:AddToWishlist(itemLink)
	if not itemLink then return end
	local itemName = GetItemInfo(itemLink) or itemLink
	local itemId = tonumber(itemLink:match("item:(%d+)") or 0)
	local key = itemId > 0 and tostring(itemId) or itemName

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
	local itemName, _, itemQuality, _, _, itemType, itemSubType = GetItemInfo(itemLink)
	if not itemType or itemType ~= "Recipe" then
		-- Check if name has recipe keywords
		if not itemName or not (itemName:find("Pattern:") or itemName:find("Plans:") or itemName:find("Schematic:") or itemName:find("Recipe:") or itemName:find("Formula:") or itemName:find("Manual:")) then
			return
		end
	end

	local profession = itemSubType or "Unknown"
	if profession == "Book" or profession == "Unknown" then
		if itemName:find("Pattern:") then profession = "Tailoring"
		elseif itemName:find("Plans:") then profession = "Blacksmithing"
		elseif itemName:find("Schematic:") then profession = "Engineering"
		elseif itemName:find("Recipe:") then profession = "Alchemy"
		elseif itemName:find("Formula:") then profession = "Enchanting"
		elseif itemName:find("Design:") then profession = "Jewelcrafting"
		elseif itemName:find("Manual:") then profession = "First Aid"
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
