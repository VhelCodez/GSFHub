local ADDON_NAME, GSF = ...

GSF.WorkOrders = {}

function GSF.WorkOrders:ValidateOrder(itemName, count, profession, itemLink, itemId)
	if not itemName or itemName:trim() == "" then
		return false, GSF.L["ORDER_ERROR_NAME_TOO_SHORT"] or "Please enter a valid item name, recipe, or description."
	end
	local trimmed = itemName:trim()

	-- Rule 6: Minimum length and spam guard
	if #trimmed < 3 then
		return false, GSF.L["ORDER_ERROR_NAME_TOO_SHORT"] or "Please enter at least 3 characters."
	end
	local lowerTrimmed = trimmed:lower()
	if lowerTrimmed == "asdf" or lowerTrimmed == "test" or lowerTrimmed == "lorem ipsum" or lowerTrimmed == "..." then
		return false, GSF.L["ORDER_ERROR_NAME_TOO_SHORT"] or "Please enter a valid item name."
	end

	-- Rule 5: Quantity check (1 to 1000)
	local numCount = tonumber(count)
	if not numCount or numCount < 1 or numCount > 1000 or numCount ~= math.floor(numCount) then
		return false, GSF.L["ORDER_ERROR_QUANTITY"] or "Please specify a valid quantity between 1 and 1000."
	end

	-- Extract ID and query item info
	local numId = tonumber(itemId) or tonumber(trimmed:match("item:(%d+)")) or (trimmed:match("^%d+$") and #trimmed >= 3 and tonumber(trimmed))
	local query = (numId and numId > 0) and numId or (itemLink or trimmed)
	local name, link, quality, _, _, itemType, itemSubType, _, _, _, _, classID, subclassID, bindType = GetItemInfo(query)

	-- If it was entered as a numeric ID that is invalid in game database
	if numId and numId > 0 and not name and C_Item and C_Item.DoesItemExistByID and not C_Item.DoesItemExistByID(numId) then
		return false, string.format(GSF.L["ORDER_ERROR_UNKNOWN_ID"] or "Item ID %s does not exist.", tostring(numId))
	end

	-- If item info is available, validate physical mechanics
	if name or classID then
		local isEnchant = (profession == "Enchanting") or 
			trimmed:find("Verzaubern") or trimmed:find("Enchant%s") or 
			trimmed:find("Formel:") or trimmed:find("Formula:")

		-- Rule 3: Grey Junk, Quest Items, Keys, Currencies
		if classID == 12 or classID == 13 or classID == 10 or (quality and quality == 0) then
			return false, GSF.L["ORDER_ERROR_INVALID_ITEM"] or "Quest items, junk, and keys cannot be requested as work orders."
		end

		-- Rule 1: BoP (Bind on Pickup) Items (crafters cannot trade BoP items in Classic)
		if bindType == 1 and not isEnchant and profession ~= "Lockpicking" then
			return false, GSF.L["ORDER_ERROR_BOP"] or "This item is Bind on Pickup (BoP) and cannot be traded by a crafter."
		end

		-- Rule 2: Raw Gathering Resources (Ores, Herbs, Raw Cloth, Raw Leather)
		local lower = (name or trimmed):lower()
		local isRawGathering = false

		-- Raw Herbs (subclass 9 in trade goods)
		if classID == 7 and subclassID == 9 then
			isRawGathering = true
		-- Raw Ores & Raw Stones (Metal & Stone subclass 1 or 7)
		elseif (classID == 7 and (subclassID == 1 or subclassID == 7)) and (
			lower:find("erz") or lower:find(" ore") or lower:find("stein") or lower:find(" stone")
		) and not lower:find("barren") and not lower:find(" bar") and not lower:find("schleifstein") and not lower:find("grindstone") and not lower:find("wetzen") and not lower:find("weightstone") then
			isRawGathering = true
		-- Raw Cloth (Cloth subclass 12)
		elseif (classID == 7 and subclassID == 12) and not lower:find("ballen") and not lower:find("bolt") then
			isRawGathering = true
		-- Raw Leather / Unworked Pelts (Leather subclass 6)
		elseif (classID == 7 and subclassID == 6) and (lower:find("fell") or lower:find("pelt") or lower:find("fetzen") or lower:find("scraps")) then
			isRawGathering = true
		end

		if isRawGathering then
			return false, GSF.L["ORDER_ERROR_RAW_MAT"] or "This is a raw gathering resource. Please create a guild bounty in the Atlas instead!"
		end
	end

	return true
end

function GSF.WorkOrders:CreateOrder(itemName, count, profession, matsProvided, notes, itemLink, itemId)
	local valid, err = self:ValidateOrder(itemName, count, profession, itemLink, itemId)
	if not valid then return false, err end
	local myName = GSF.DB:GetPlayerName()
	
	local orderId = string.format("%s-%d-%d", myName, time(), math.random(100, 999))
	local order = {
		id = orderId,
		requester = myName,
		crafter = nil,
		item = itemName:trim(),
		itemLink = itemLink,
		itemId = tonumber(itemId),
		count = tonumber(count) or 1,
		profession = profession or "Any",
		matsProvided = matsProvided or false,
		notes = notes or "",
		status = GSF.ORDER_STATUS.OPEN,
		timestamp = time(),
	}

	GSF.cache.workOrders[orderId] = order
	GSF.db.myWorkOrders[orderId] = order

	-- Broadcast new order
	if GSF.Sync then
		GSF.Sync:SendPacket(GSF.OPCODE.WORK_ORDER_NEW, { order = order }, "GUILD")
	end

	return true, order
end

function GSF.WorkOrders:ClaimOrder(orderId)
	local order = GSF.cache.workOrders[orderId]
	if not order then return false end
	local myName = GSF.DB:GetPlayerName()

	order.status = GSF.ORDER_STATUS.CLAIMED
	order.crafter = myName

	if GSF.Sync then
		GSF.Sync:SendPacket(GSF.OPCODE.WORK_ORDER_CLAIM, {
			orderId = orderId,
			crafter = myName,
		}, "GUILD")
	end

	return true
end

function GSF.WorkOrders:CompleteOrder(orderId)
	local order = GSF.cache.workOrders[orderId]
	if not order then return false end

	order.status = GSF.ORDER_STATUS.COMPLETED

	if GSF.Sync then
		GSF.Sync:SendPacket(GSF.OPCODE.WORK_ORDER_STAT, {
			orderId = orderId,
			status = GSF.ORDER_STATUS.COMPLETED,
		}, "GUILD")
	end

	return true
end

function GSF.WorkOrders:UnclaimOrder(orderId)
	local order = GSF.cache.workOrders[orderId]
	if not order then return false end

	order.status = GSF.ORDER_STATUS.OPEN
	order.crafter = nil

	if GSF.Sync then
		GSF.Sync:SendPacket(GSF.OPCODE.WORK_ORDER_STAT, {
			orderId = orderId,
			status = GSF.ORDER_STATUS.OPEN,
		}, "GUILD")
	end

	return true
end

function GSF.WorkOrders:CancelOrder(orderId)
	local order = GSF.cache.workOrders[orderId]
	if not order then return false end

	order.status = GSF.ORDER_STATUS.CANCELLED

	if GSF.Sync then
		GSF.Sync:SendPacket(GSF.OPCODE.WORK_ORDER_STAT, {
			orderId = orderId,
			status = GSF.ORDER_STATUS.CANCELLED,
		}, "GUILD")
	end

	return true
end

function GSF.WorkOrders:GetOrders(filterMyProfessions, includeCompleted)
	local list = {}
	if not GSF.cache or not GSF.cache.workOrders then return list end

	local myProfessions = GSF.db.characterProfessions or {}

	for id, order in pairs(GSF.cache.workOrders) do
		local include = true
		if not includeCompleted and (order.status == GSF.ORDER_STATUS.COMPLETED or order.status == GSF.ORDER_STATUS.CANCELLED) then
			include = false
		end

		if include and filterMyProfessions and order.profession and order.profession ~= "Any" then
			if not myProfessions[order.profession] then
				include = false
			end
		end

		if include then
			table.insert(list, order)
		end
	end

	table.sort(list, function(a, b)
		return (a.timestamp or 0) > (b.timestamp or 0)
	end)

	return list
end

function GSF.WorkOrders:OnOrderReceived(order, sender)
	if not order then return end
	local myName = GSF.DB:GetPlayerName()
	if sender == myName then return end

	-- Check if player can craft this
	local myProfs = GSF.db.characterProfessions or {}
	local isRelevant = (order.profession == "Any" or myProfs[order.profession] ~= nil)

	if isRelevant and GSF.db.enableToasts and GSF.Toast then
		local text = string.format(GSF.L["ORDER_POSTED_TOAST"], order.item, order.count, sender)
		GSF.Toast:ShowToast(text)
	end
end
