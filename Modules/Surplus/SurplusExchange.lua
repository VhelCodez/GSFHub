local ADDON_NAME, GSF = ...

GSF.Surplus = {}

function GSF.Surplus:PostItem(itemLink, count, notes, existingEntryId)
	if not itemLink then return false, "No item provided" end
	local itemName, _, itemQuality, _, _, itemType, itemSubType, _, _, itemTexture = GetItemInfo(itemLink)
	itemName = itemName or itemLink
	local itemId = tonumber(itemLink:match("item:(%d+)") or 0)
	if itemId == 0 then itemId = itemName end

	local myName = GSF.DB:GetPlayerName()
	local member = GSF.DB:EnsureMemberRecord(myName)
	member.surplus = member.surplus or {}

	local entryId = existingEntryId or string.format("%s-%d-%d", myName, time(), math.random(100, 999))

	local entry = {
		id = tostring(entryId),
		itemId = itemId,
		name = itemName,
		count = tonumber(count) or 1,
		link = itemLink,
		quality = itemQuality or 1,
		type = itemType or "Material",
		subType = itemSubType or "",
		texture = itemTexture or "Interface\\Icons\\INV_Misc_QuestionMark",
		notes = notes or "",
		owner = myName,
		timestamp = time(),
	}

	member.surplus[entry.id] = entry
	GSF.db.mySurplus[entry.id] = entry
	GSF.cache.revisions.surplus = (GSF.cache.revisions.surplus or 0) + 1

	if GSF.Sync then
		GSF.Sync:SendPacket(GSF.OPCODE.SURPLUS_NEW, { item = entry }, "GUILD")
	end

	return true, entry
end

function GSF.Surplus:RemoveItem(itemId)
	local myName = GSF.DB:GetPlayerName()
	local member = GSF.cache.members[myName]
	if member and member.surplus then
		member.surplus[tostring(itemId)] = nil
	end
	GSF.db.mySurplus[tostring(itemId)] = nil
	GSF.cache.revisions.surplus = (GSF.cache.revisions.surplus or 0) + 1

	if GSF.Sync then
		GSF.Sync:SendPacket(GSF.OPCODE.SURPLUS_REM, { itemId = tostring(itemId) }, "GUILD")
	end
end

function GSF.Surplus:GetAllSurplus(searchText, ownerFilter)
	local results = {}
	searchText = (searchText or ""):lower():trim()

	if not GSF.cache or not GSF.cache.members then return results end

	for memberName, memberData in pairs(GSF.cache.members) do
		if not ownerFilter or ownerFilter == "" or ownerFilter == memberName then
			if memberData.surplus then
				for id, item in pairs(memberData.surplus) do
					local matches = false
					if searchText == "" then
						matches = true
					elseif (item.name or ""):lower():find(searchText, 1, true) or (item.notes or ""):lower():find(searchText, 1, true) then
						matches = true
					end

					if matches then
						table.insert(results, item)
					end
				end
			end
		end
	end

	table.sort(results, function(a, b)
		return (a.timestamp or 0) > (b.timestamp or 0)
	end)

	return results
end

function GSF.Surplus:GetBagItems()
	local bagItems = {}
	local getNumSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
	local getItemInfo = (C_Container and C_Container.GetContainerItemInfo) or GetContainerItemInfo
	local getItemLink = (C_Container and C_Container.GetContainerItemLink) or GetContainerItemLink

	for bag = 0, 4 do
		local numSlots = getNumSlots and getNumSlots(bag) or 0
		for slot = 1, numSlots do
			local link = getItemLink and getItemLink(bag, slot)
			if link then
				local isBound = false
				local count = 1
				if getItemInfo then
					local info = getItemInfo(bag, slot)
					if type(info) == "table" then
						count = info.stackCount or info.count or 1
						isBound = info.isBound or false
					else
						count = select(2, getItemInfo(bag, slot)) or 1
					end
				end

				-- Check bindType and quest item class
				local _, _, _, _, _, _, _, _, _, _, _, classID, _, bindType = GetItemInfo(link)
				-- bindType == 1 (BoP / Bind on Pickup), classID == 12 (Quest item)
				if not isBound and bindType ~= 1 and classID ~= 12 then
					table.insert(bagItems, {
						bag = bag,
						slot = slot,
						link = link,
						id = tonumber(link:match("item:(%d+)")),
						count = count,
					})
				end
			end
		end
	end
	return bagItems
end
