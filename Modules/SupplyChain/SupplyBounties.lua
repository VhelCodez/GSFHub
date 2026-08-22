local ADDON_NAME, GSF = ...

GSF.SupplyBounties = {}

local pendingMailFulfillments = {}

function GSF.SupplyBounties:Initialize()
	-- Event frame to listen for mailbox interactions
	local f = CreateFrame("Frame")
	f:RegisterEvent("MAIL_SHOW")
	f:RegisterEvent("MAIL_INBOX_UPDATE")
	f:RegisterEvent("BAG_UPDATE")
	f:SetScript("OnEvent", function(_, event, ...)
		if event == "MAIL_SHOW" or event == "MAIL_INBOX_UPDATE" then
			GSF.SupplyBounties:ScanMailboxForBounties()
		elseif event == "BAG_UPDATE" then
			GSF.SupplyBounties:CheckBagAcquisitions()
		end
	end)
	self.eventFrame = f
end

function GSF.SupplyBounties:CreateBounty(item, count, category, notes, targetCrafter)
	if not item or item:trim() == "" then return end

	local myName = GSF.DB:GetPlayerName()
	local myMain = GSF.Alts:GetMyMain()
	local bountyId = string.format("%d-%d", time(), math.random(1000, 9999))

	local bounty = {
		id = bountyId,
		item = item:trim(),
		count = tonumber(count) or 1,
		category = category or "General",
		notes = notes or "",
		requester = myName,
		requesterMain = myMain,
		targetCrafter = targetCrafter or myName,
		claimer = nil,
		claimerMain = nil,
		status = GSF.ORDER_STATUS.OPEN,
		created = time(),
		mailedAt = nil,
		completedAt = nil,
	}

	if not GSF.cache.bounties then
		GSF.cache.bounties = {}
	end
	GSF.cache.bounties[bountyId] = bounty

	-- Broadcast over guild network
	if GSF.Sync then
		GSF.Sync:BroadcastBountyNew(bounty)
	end

	-- Notification Toast
	if GSF.Toast then
		local toastMsg = string.format(GSF.L["BOUNTY_POSTED_TOAST"] or "New Bounty: %s x%d requested by %s!", bounty.item, bounty.count, myName)
		GSF.Toast:ShowToast(toastMsg, "Interface\\Icons\\INV_Misc_Coin_02")
	end

	if GSF.TabAtlas then GSF.TabAtlas:Refresh() end
	return bounty
end

function GSF.SupplyBounties:ClaimBounty(bountyId)
	if not bountyId or not GSF.cache.bounties or not GSF.cache.bounties[bountyId] then return end
	local b = GSF.cache.bounties[bountyId]

	local myName = GSF.DB:GetPlayerName()
	b.claimer = myName
	b.claimerMain = GSF.Alts:GetMyMain()
	b.status = GSF.ORDER_STATUS.CLAIMED

	if GSF.Sync then
		GSF.Sync:BroadcastBountyClaim(bountyId, myName, b.claimerMain)
	end

	-- Add to user's Goals HUD
	if GSF.GoalsHUD then
		GSF.GoalsHUD:AddGoal(b.item, b.count, b.category or "Bounty")
	end

	if GSF.TabAtlas then GSF.TabAtlas:Refresh() end
end

function GSF.SupplyBounties:MarkBountyMailed(bountyId)
	if not bountyId or not GSF.cache.bounties or not GSF.cache.bounties[bountyId] then return end
	local b = GSF.cache.bounties[bountyId]

	b.status = GSF.ORDER_STATUS.IN_TRANSIT
	b.mailedAt = time()

	if GSF.Sync then
		GSF.Sync:BroadcastBountyMailed(bountyId, b.mailedAt)
	end

	if GSF.TabAtlas then GSF.TabAtlas:Refresh() end
end

function GSF.SupplyBounties:FulfillBounty(bountyId)
	if not bountyId or not GSF.cache.bounties or not GSF.cache.bounties[bountyId] then return end
	local b = GSF.cache.bounties[bountyId]

	b.status = GSF.ORDER_STATUS.COMPLETED
	b.completedAt = time()

	if GSF.Sync then
		GSF.Sync:BroadcastBountyFulfill(bountyId)
	end

	if GSF.Toast then
		local fulfillToast = string.format(GSF.L["BOUNTY_FULFILLED_TOAST"] or "🎉 Bounty Fulfilled: Received %s x%d!", b.item, b.count)
		GSF.Toast:ShowToast(fulfillToast, "Interface\\Icons\\Spell_Holy_SealOfSacrifice")
	end

	if GSF.TabAtlas then GSF.TabAtlas:Refresh() end
end

function GSF.SupplyBounties:CancelBounty(bountyId)
	if not bountyId or not GSF.cache.bounties or not GSF.cache.bounties[bountyId] then return end
	local b = GSF.cache.bounties[bountyId]

	b.status = GSF.ORDER_STATUS.CANCELLED

	if GSF.Sync then
		GSF.Sync:BroadcastBountyCancel(bountyId)
	end

	if GSF.TabAtlas then GSF.TabAtlas:Refresh() end
end

-- 3-Factor Verification Mail Scanner
function GSF.SupplyBounties:ScanMailboxForBounties()
	if not GSF.cache or not GSF.cache.bounties then return end
	local myName = GSF.DB:GetPlayerName()
	local numItems = GetInboxNumItems()

	for i = 1, numItems do
		local _, _, sender, subject, _, _, _, hasItem = GetInboxHeaderInfo(i)
		if sender and hasItem then
			for bId, bounty in pairs(GSF.cache.bounties) do
				-- Check if bounty is for me and in transit
				if bounty.requester == myName and (bounty.status == GSF.ORDER_STATUS.IN_TRANSIT or bounty.status == GSF.ORDER_STATUS.CLAIMED) then
					-- Factor 1: Sender identity check
					local isClaimer = (sender == bounty.claimer) or (GSF.Alts:GetMain(sender) == bounty.claimerMain)

					-- Factor 2: Token match in subject
					local tokenMatch = subject and subject:find("GSF-BT:" .. bId, 1, true)

					-- Factor 3: Check attached items
					local itemMatched = false
					for attachIdx = 1, ATTACHMENTS_MAX_RECEIVE or 16 do
						local name, _, _, count = GetInboxItem(i, attachIdx)
						if name and name:lower():find(bounty.item:lower(), 1, true) and (count or 1) >= bounty.count then
							itemMatched = true
							break
						end
					end

					if isClaimer and (tokenMatch or itemMatched) then
						pendingMailFulfillments[bId] = true
					end
				end
			end
		end
	end
end

function GSF.SupplyBounties:CheckBagAcquisitions()
	if not next(pendingMailFulfillments) then return end
	for bId in pairs(pendingMailFulfillments) do
		local bounty = GSF.cache and GSF.cache.bounties and GSF.cache.bounties[bId]
		if bounty and bounty.status ~= GSF.ORDER_STATUS.COMPLETED then
			self:FulfillBounty(bId)
		end
		pendingMailFulfillments[bId] = nil
	end
end

function GSF.SupplyBounties:GetActiveBounties(categoryFilter)
	local result = {}
	if not GSF.cache or not GSF.cache.bounties then return result end

	for _, b in pairs(GSF.cache.bounties) do
		if b.status ~= GSF.ORDER_STATUS.CANCELLED then
			if not categoryFilter or categoryFilter == "All" or b.category:lower() == categoryFilter:lower() then
				table.insert(result, b)
			end
		end
	end

	table.sort(result, function(a, b)
		-- Sort by active status first, then by creation date
		local orderVal = { OPEN = 1, CLAIMED = 2, IN_TRANSIT = 3, COMPLETED = 4 }
		local vA = orderVal[a.status] or 5
		local vB = orderVal[b.status] or 5
		if vA ~= vB then
			return vA < vB
		end
		return (a.created or 0) > (b.created or 0)
	end)

	return result
end
