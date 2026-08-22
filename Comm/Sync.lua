local ADDON_NAME, GSF = ...

local AceComm = LibStub("AceComm-3.0")
local AceTimer = LibStub("AceTimer-3.0")

GSF.Sync = {}
AceComm:Embed(GSF.Sync)
AceTimer:Embed(GSF.Sync)

function GSF.Sync:Initialize()
	self:RegisterComm(GSF.COMM_PREFIX, "OnCommReceived")

	-- Schedule periodic heartbeat broadcast (every 10 mins)
	self:ScheduleRepeatingTimer("BroadcastHello", 600)
end

function GSF.Sync:SendPacket(opcode, payload, distribution, target)
	if not IsInGuild() then return end
	distribution = distribution or "GUILD"
	
	local encoded = GSF.Protocol:Encode(opcode, payload)
	if not encoded then return end
	
	self:SendCommMessage(GSF.COMM_PREFIX, encoded, distribution, target)
end

function GSF.Sync:BroadcastHello(forceQueryAll)
	if not IsInGuild() then return end
	local myName = GSF.DB:GetPlayerName()
	local myMember = GSF.cache.members[myName]

	local payload = {
		rev = GSF.cache.revisions or {},
		main = GSF.Alts:GetMain(myName),
		force = forceQueryAll or false,
	}

	self:SendPacket(GSF.OPCODE.HELLO, payload, "GUILD")
end

function GSF.Sync:RequestMemberData(targetName)
	if not targetName or targetName == GSF.DB:GetPlayerName() then return end
	self:SendPacket(GSF.OPCODE.REQ_DATA, { target = targetName }, "WHISPER", targetName)
end

function GSF.Sync:SendMyData(targetName)
	local myName = GSF.DB:GetPlayerName()
	local memberData = GSF.cache.members[myName] or {}
	
	local payload = {
		name = myName,
		main = GSF.Alts:GetMain(myName),
		class = GSF.DB:GetPlayerClass(),
		professions = memberData.professions or {},
		surplus = GSF.db.mySurplus or {},
		wishlist = GSF.db.myWishlist or {},
		orders = GSF.db.myWorkOrders or {},
		bounties = GSF.cache.bounties or {},
	}

	if targetName then
		self:SendPacket(GSF.OPCODE.RESP_DATA, payload, "WHISPER", targetName)
	else
		self:SendPacket(GSF.OPCODE.RESP_DATA, payload, "GUILD")
	end
end

function GSF.Sync:BroadcastAlt(characterName, mainName)
	self:SendPacket(GSF.OPCODE.ALT_UPDATE, {
		char = characterName,
		main = mainName,
	}, "GUILD")
end

function GSF.Sync:BroadcastBountyNew(bounty)
	self:SendPacket(GSF.OPCODE.BOUNTY_NEW, { bounty = bounty }, "GUILD")
end

function GSF.Sync:BroadcastBountyClaim(bountyId, claimer, claimerMain)
	self:SendPacket(GSF.OPCODE.BOUNTY_CLAIM, {
		id = bountyId,
		claimer = claimer,
		claimerMain = claimerMain,
	}, "GUILD")
end

function GSF.Sync:BroadcastBountyMailed(bountyId, mailedAt)
	self:SendPacket(GSF.OPCODE.BOUNTY_MAILED, {
		id = bountyId,
		mailedAt = mailedAt,
	}, "GUILD")
end

function GSF.Sync:BroadcastBountyFulfill(bountyId)
	self:SendPacket(GSF.OPCODE.BOUNTY_FULFILL, { id = bountyId }, "GUILD")
end

function GSF.Sync:BroadcastBountyCancel(bountyId)
	self:SendPacket(GSF.OPCODE.BOUNTY_CANCEL, { id = bountyId }, "GUILD")
end

function GSF.Sync:OnCommReceived(prefix, message, distribution, sender)
	if prefix ~= GSF.COMM_PREFIX then return end
	local myName = GSF.DB:GetPlayerName()
	if sender == myName then return end -- ignore echo

	local packet, err = GSF.Protocol:Decode(message)
	if not packet or not packet.op then return end

	-- Check peer addon version for updates
	if packet.addonVer and GSF.VersionCheck then
		GSF.VersionCheck:CheckPeerVersion(packet.addonVer, sender)
	end

	local op = packet.op
	local data = packet.data or {}

	if op == GSF.OPCODE.HELLO then
		-- Register that sender is online
		local member = GSF.DB:EnsureMemberRecord(sender)
		member.lastSeen = time()
		if data.main then
			GSF.Alts:SetMain(sender, data.main)
		end

		-- If peer requests forced sync or we don't have their professions, ask for them
		if data.force or not member.professions or not next(member.professions) then
			self:SendMyData(sender)
			self:RequestMemberData(sender)
		end

	elseif op == GSF.OPCODE.REQ_DATA then
		self:SendMyData(sender)

	elseif op == GSF.OPCODE.RESP_DATA then
		local targetMember = GSF.DB:EnsureMemberRecord(data.name or sender)
		targetMember.main = data.main or sender
		targetMember.class = data.class or targetMember.class
		targetMember.lastSeen = time()
		targetMember.professions = data.professions or {}
		targetMember.surplus = data.surplus or {}

		if data.main then
			GSF.Alts:SetMain(data.name or sender, data.main)
		end

		-- Merge work orders
		if data.orders then
			for orderId, order in pairs(data.orders) do
				GSF.cache.workOrders[orderId] = order
			end
		end

		-- Merge bounties
		if data.bounties then
			if not GSF.cache.bounties then GSF.cache.bounties = {} end
			for bId, b in pairs(data.bounties) do
				GSF.cache.bounties[bId] = b
			end
		end

		if GSF.MainFrame and GSF.MainFrame:IsShown() then
			GSF.MainFrame:RefreshCurrentTab()
		end

	elseif op == GSF.OPCODE.WORK_ORDER_NEW then
		if data.order and data.order.id then
			GSF.cache.workOrders[data.order.id] = data.order
			
			if GSF.Toast and GSF.db.enableToasts then
				local reqName = GSF.Alts:GetFormattedName(data.order.requester)
				GSF.Toast:ShowToast(string.format(GSF.L["ORDER_POSTED_TOAST"], data.order.item or "Item", data.order.count or 1, reqName))
			end

			if GSF.MainFrame and GSF.MainFrame:IsShown() then
				GSF.MainFrame:RefreshCurrentTab()
			end
		end

	elseif op == GSF.OPCODE.WORK_ORDER_CLAIM then
		if data.orderId and GSF.cache.workOrders[data.orderId] then
			local order = GSF.cache.workOrders[data.orderId]
			order.status = GSF.ORDER_STATUS.CLAIMED
			order.crafter = data.crafter or sender
			
			if GSF.Toast and GSF.db.enableToasts then
				GSF.Toast:ShowToast(string.format("Order for |cffffd100%s|r was claimed by |cff33ff99%s|r!", order.item or "Item", order.crafter))
			end

			if GSF.MainFrame and GSF.MainFrame:IsShown() then
				GSF.MainFrame:RefreshCurrentTab()
			end
		end

	elseif op == GSF.OPCODE.WORK_ORDER_STAT then
		if data.orderId and GSF.cache.workOrders[data.orderId] then
			GSF.cache.workOrders[data.orderId].status = data.status
			if GSF.MainFrame and GSF.MainFrame:IsShown() then
				GSF.MainFrame:RefreshCurrentTab()
			end
		end

	elseif op == GSF.OPCODE.SURPLUS_NEW then
		if data.item and data.item.id then
			local member = GSF.DB:EnsureMemberRecord(sender)
			member.surplus = member.surplus or {}
			member.surplus[data.item.id] = data.item

			if GSF.Toast and GSF.db.enableToasts then
				GSF.Toast:ShowToast(string.format(GSF.L["SURPLUS_POSTED_TOAST"], sender, data.item.name or "Item", data.item.count or 1))
			end

			if GSF.MainFrame and GSF.MainFrame:IsShown() then
				GSF.MainFrame:RefreshCurrentTab()
			end
		end

	elseif op == GSF.OPCODE.SURPLUS_REM then
		if data.itemId then
			local member = GSF.cache.members[sender]
			if member and member.surplus then
				member.surplus[data.itemId] = nil
			end
			if GSF.MainFrame and GSF.MainFrame:IsShown() then
				GSF.MainFrame:RefreshCurrentTab()
			end
		end

	elseif op == GSF.OPCODE.ALT_UPDATE then
		if data.char and data.main then
			GSF.Alts:SetMain(data.char, data.main)
			if GSF.MainFrame and GSF.MainFrame:IsShown() then
				GSF.MainFrame:RefreshCurrentTab()
			end
		end

	-- BOUNTY OPCODES
	elseif op == GSF.OPCODE.BOUNTY_NEW then
		if data.bounty and data.bounty.id then
			if not GSF.cache.bounties then GSF.cache.bounties = {} end
			GSF.cache.bounties[data.bounty.id] = data.bounty

			if GSF.Toast and GSF.db.enableToasts then
				local reqName = GSF.Alts:GetFormattedName(data.bounty.requester)
				local toastMsg = string.format(GSF.L["BOUNTY_POSTED_TOAST"] or "New Bounty: %s x%d requested by %s!", data.bounty.item, data.bounty.count, reqName)
				GSF.Toast:ShowToast(toastMsg, "Interface\\Icons\\INV_Misc_Coin_02")
			end

			if GSF.MainFrame and GSF.MainFrame:IsShown() then
				GSF.MainFrame:RefreshCurrentTab()
			end
		end

	elseif op == GSF.OPCODE.BOUNTY_CLAIM then
		if data.id and GSF.cache.bounties and GSF.cache.bounties[data.id] then
			local b = GSF.cache.bounties[data.id]
			b.status = GSF.ORDER_STATUS.CLAIMED
			b.claimer = data.claimer or sender
			b.claimerMain = data.claimerMain or data.claimer or sender

			if GSF.MainFrame and GSF.MainFrame:IsShown() then
				GSF.MainFrame:RefreshCurrentTab()
			end
		end

	elseif op == GSF.OPCODE.BOUNTY_MAILED then
		if data.id and GSF.cache.bounties and GSF.cache.bounties[data.id] then
			local b = GSF.cache.bounties[data.id]
			b.status = GSF.ORDER_STATUS.IN_TRANSIT
			b.mailedAt = data.mailedAt or time()

			if GSF.MainFrame and GSF.MainFrame:IsShown() then
				GSF.MainFrame:RefreshCurrentTab()
			end
		end

	elseif op == GSF.OPCODE.BOUNTY_FULFILL then
		if data.id and GSF.cache.bounties and GSF.cache.bounties[data.id] then
			local b = GSF.cache.bounties[data.id]
			b.status = GSF.ORDER_STATUS.COMPLETED
			b.completedAt = time()

			if GSF.MainFrame and GSF.MainFrame:IsShown() then
				GSF.MainFrame:RefreshCurrentTab()
			end
		end

	elseif op == GSF.OPCODE.BOUNTY_CANCEL then
		if data.id and GSF.cache.bounties and GSF.cache.bounties[data.id] then
			GSF.cache.bounties[data.id].status = GSF.ORDER_STATUS.CANCELLED

			if GSF.MainFrame and GSF.MainFrame:IsShown() then
				GSF.MainFrame:RefreshCurrentTab()
			end
		end
	end
end
