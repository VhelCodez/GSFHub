local ADDON_NAME, GSF = ...

GSF.WorkOrders = {}

function GSF.WorkOrders:CreateOrder(itemName, count, profession, matsProvided, notes)
	if not itemName or itemName:trim() == "" then return false, "Item name required" end
	local myName = GSF.DB:GetPlayerName()
	
	local orderId = string.format("%s-%d-%d", myName, time(), math.random(100, 999))
	local order = {
		id = orderId,
		requester = myName,
		crafter = nil,
		item = itemName:trim(),
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
