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

local function InferResourceCategory(itemName, categoryHint)
	local resolvedCat = nil

	-- 1. Check AtlasJournal database first
	if AtlasJournal and AtlasJournal.FindResource and itemName then
		local res = AtlasJournal:FindResource(itemName:trim())
		if res and res.category then
			return res.category
		end
	end

	-- 2. Map profession hints to AtlasJournal category keys
	if categoryHint and categoryHint ~= "General" and categoryHint ~= "Crafting" then
		local canon = GSF.GetCanonicalProfession and GSF:GetCanonicalProfession(categoryHint) or categoryHint
		local profToCat = {
			Tailoring = "CLOTH",
			Leatherworking = "LEATHER",
			Skinning = "LEATHER",
			Blacksmithing = "ORE_STONE",
			Mining = "ORE_STONE",
			Engineering = "ORE_STONE",
			Herbalism = "HERB",
			Alchemy = "HERB",
			Enchanting = "ENCHANTING",
			Cooking = "MEAT_FISH",
			Fishing = "MEAT_FISH",
			Jewelcrafting = "SPECIAL",
		}
		if profToCat[canon] then
			resolvedCat = profToCat[canon]
		end
	end

	-- 3. Name-based keyword heuristics for vendor items and intermediate craft materials
	if (not resolvedCat or resolvedCat == "General" or resolvedCat == "Crafting") and itemName then
		local low = itemName:lower()
		if low:find("faden") or low:find("thread") or low:find("bleich") or low:find("bleach") or low:find("dye") or low:find("färbe") or low:find("stoff") or low:find("cloth") or low:find("ballen") or low:find("bolt") or low:find("seide") or low:find("silk") or low:find("wolle") or low:find("wool") or low:find("leinen") or low:find("linen") or low:find("magiegewirkt") or low:find("mageweave") or low:find("runenstoff") or low:find("runecloth") then
			resolvedCat = "CLOTH"
		elseif low:find("flussmittel") or low:find("flux") or low:find("erz") or low:find("ore") or low:find("barren") or low:find("bar") or low:find("stein") or low:find("stone") or low:find("schleif") or low:find("rohr") or low:find("tube") or low:find("kupfer") or low:find("copper") or low:find("bronze") or low:find("eisen") or low:find("iron") or low:find("mithril") or low:find("thorium") or low:find("silber") or low:find("silver") or low:find("gold") then
			resolvedCat = "ORE_STONE"
		elseif low:find("leder") or low:find("leather") or low:find("balg") or low:find("hide") or low:find("salz") or low:find("salt") or low:find("pelz") or low:find("fur") or low:find("fell") or low:find("schuppen") or low:find("scale") then
			resolvedCat = "LEATHER"
		elseif low:find("phiole") or low:find("vial") or low:find("kraut") or low:find("herb") or low:find("blüte") or low:find("bloom") or low:find("lotus") or low:find("blatt") or low:find("leaf") or low:find("wurzel") or low:find("root") or low:find("gras") or low:find("weed") then
			resolvedCat = "HERB"
		elseif low:find("staub") or low:find("dust") or low:find("essenz") or low:find("essence") or low:find("splitter") or low:find("shard") or low:find("kristall") or low:find("crystal") or low:find("rute") or low:find("rod") then
			resolvedCat = "ENCHANTING"
		elseif low:find("fleisch") or low:find("meat") or low:find("fisch") or low:find("fish") or low:find("gewürz") or low:find("spice") or low:find("ei") or low:find("egg") or low:find("muschel") or low:find("clam") then
			resolvedCat = "MEAT_FISH"
		elseif low:find("feuer") or low:find("fire") or low:find("wasser") or low:find("water") or low:find("erde") or low:find("earth") or low:find("luft") or low:find("air") or low:find("elementar") or low:find("elemental") or low:find("urfeuer") or low:find("urwasser") or low:find("primal") or low:find("flüchtig") or low:find("mote") then
			resolvedCat = "ELEMENTAL"
		end
	end

	return resolvedCat or categoryHint or "General"
end

function GSF.SupplyBounties:CreateBounty(item, count, category, notes, targetCrafter, itemId, itemLink, icon)
	if not item or item:trim() == "" then return end

	local myName = GSF.DB:GetPlayerName()
	local myMain = GSF.Alts:GetMyMain()
	local bountyId = string.format("%d-%d", time(), math.random(1000, 9999))

	local cleanItem = item:trim()
	local numId = tonumber(itemId) or (itemLink and tonumber(itemLink:match("item:(%d+)"))) or (cleanItem:match("item:(%d+)") and tonumber(cleanItem:match("item:(%d+)")))
	local resolvedCat = InferResourceCategory(cleanItem, category)

	-- Resolve item details, texture, and link
	local itemIcon = icon
	local itemName = cleanItem
	local resolvedLink = itemLink

	local n, l, _, _, _, _, _, _, _, t = GetItemInfo(resolvedLink or numId or cleanItem)
	if t then
		itemIcon = itemIcon or t
		itemName = n or itemName
		resolvedLink = resolvedLink or l
		numId = numId or (l and tonumber(l:match("item:(%d+)")))
	end

	if not itemIcon and numId and AtlasJournal and AtlasJournal.GetItemDetails then
		local d = AtlasJournal:GetItemDetails(numId)
		if d and d.icon then
			itemIcon = d.icon
			itemName = itemName or d.name
			resolvedLink = resolvedLink or d.link
		end
	end

	if not itemIcon and AtlasJournal and AtlasJournal.FindResource then
		local res = AtlasJournal:FindResource(cleanItem)
		if res and res.id then
			local d = AtlasJournal:GetItemDetails(res.id)
			if d and d.icon then
				itemIcon = d.icon
				resolvedLink = resolvedLink or d.link
				numId = numId or d.id or res.id
			end
		end
	end

	if (not itemIcon or itemIcon == "") and numId and numId >= 100 and C_Item and C_Item.RequestLoadItemDataByID then
		C_Item.RequestLoadItemDataByID(numId)
	end

	local bounty = {
		id = bountyId,
		item = itemName,
		itemId = numId,
		itemLink = resolvedLink,
		icon = itemIcon,
		count = tonumber(count) or 1,
		category = resolvedCat,
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
		GSF.Toast:ShowToast(toastMsg, bounty.icon or "Interface\\Icons\\INV_Misc_Coin_02")
	end

	if GSF.TabAtlas then GSF.TabAtlas:Refresh() end
	return bounty
end

function GSF.SupplyBounties:UpdateBounty(bountyId, newItem, newCount, newCategory, newNotes)
	if not bountyId or not GSF.cache.bounties or not GSF.cache.bounties[bountyId] then return end
	local b = GSF.cache.bounties[bountyId]
	if b.status ~= GSF.ORDER_STATUS.OPEN then return end
	if newItem and newItem ~= "" then
		b.item = newItem:trim()
		b.category = InferResourceCategory(b.item, newCategory or b.category)
		local n, l, _, _, _, _, _, _, _, t = GetItemInfo(b.itemLink or b.itemId or b.item)
		if t then
			b.icon = t
			b.item = n or b.item
			b.itemLink = l or b.itemLink
			b.itemId = b.itemId or (l and tonumber(l:match("item:(%d+)")))
		end
	elseif newCategory then
		b.category = newCategory
	end
	if newCount then b.count = tonumber(newCount) or b.count end
	b.notes = newNotes or ""
	b.updatedAt = time()

	if GSF.Sync then
		GSF.Sync:BroadcastBountyNew(b)
	end
	if GSF.TabAtlas then GSF.TabAtlas:Refresh() end
	return b
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
		GSF.GoalsHUD:AddGoal(b.item, b.count, b.category or "Bounty", b.id, b.icon, b.itemId)
	end

	if GSF.TabAtlas then GSF.TabAtlas:Refresh() end
end

function GSF.SupplyBounties:MarkBountyMailed(bountyId)
	if not bountyId or not GSF.cache.bounties or not GSF.cache.bounties[bountyId] then return end
	local b = GSF.cache.bounties[bountyId]

	b.status = GSF.ORDER_STATUS.IN_TRANSIT
	b.mailedAt = time()
	b.deliveryType = "MAIL"

	if GSF.Sync then
		GSF.Sync:BroadcastBountyMailed(bountyId, b.mailedAt)
	end

	if GSF.TabAtlas then GSF.TabAtlas:Refresh() end
end

function GSF.SupplyBounties:MarkBountyDelivered(bountyId, deliveryType)
	if not bountyId or not GSF.cache.bounties or not GSF.cache.bounties[bountyId] then return end
	local b = GSF.cache.bounties[bountyId]

	b.status = GSF.ORDER_STATUS.IN_TRANSIT
	b.mailedAt = time()
	b.deliveryType = deliveryType or "DIRECT"

	if GSF.Sync then
		GSF.Sync:BroadcastBountyMailed(bountyId, b.mailedAt)
	end

	if GSF.Toast then
		local myName = GSF.DB:GetPlayerName()
		local msg = string.format(GSF.L["BOUNTY_DELIVERED_TOAST"] or "%s marked %s x%d as delivered!", myName, b.item, b.count)
		GSF.Toast:ShowToast(msg, b.icon or "Interface\\Icons\\INV_Misc_Gift_01")
	end

	if GSF.TabAtlas then GSF.TabAtlas:Refresh() end
end

function GSF.SupplyBounties:RejectBountyDelivery(bountyId)
	if not bountyId or not GSF.cache.bounties or not GSF.cache.bounties[bountyId] then return end
	local b = GSF.cache.bounties[bountyId]

	b.claimer = nil
	b.claimerMain = nil
	b.status = GSF.ORDER_STATUS.OPEN
	b.mailedAt = nil
	b.deliveryType = nil

	if GSF.Sync then
		GSF.Sync:BroadcastBountyNew(b)
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
		local fulfillToast = string.format(GSF.L["BOUNTY_FULFILLED_TOAST"] or "Bounty Fulfilled: Received %s x%d!", b.item, b.count)
		GSF.Toast:ShowToast(fulfillToast, "Interface\\Icons\\Spell_Holy_SealOfSacrifice")
	end

	-- Remove from local GoalsHUD if present
	if GSF.GoalsHUD then
		GSF.GoalsHUD:RemoveGoal(b.id)
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

	-- Remove from local GoalsHUD if present
	if GSF.GoalsHUD then
		GSF.GoalsHUD:RemoveGoal(b.id)
	end

	if GSF.TabAtlas then GSF.TabAtlas:Refresh() end
end

function GSF.SupplyBounties:UnclaimBounty(bountyId)
	if not bountyId or not GSF.cache.bounties or not GSF.cache.bounties[bountyId] then return end
	local b = GSF.cache.bounties[bountyId]

	b.claimer = nil
	b.claimerMain = nil
	b.status = GSF.ORDER_STATUS.OPEN

	if GSF.Sync then
		GSF.Sync:BroadcastBountyNew(b)
	end

	-- Remove from local GoalsHUD if present
	if GSF.GoalsHUD then
		GSF.GoalsHUD:RemoveGoal(b.id)
	end

	if GSF.TabAtlas then GSF.TabAtlas:Refresh() end
end

function GSF.SupplyBounties:DismissBounty(bountyId)
	if not bountyId or not GSF.cache.bounties then return end
	GSF.cache.bounties[bountyId] = nil
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

	local isAll = (not categoryFilter) or (categoryFilter == "") or (categoryFilter:upper() == "ALL") or (GSF.L and categoryFilter == GSF.L["CAT_ALL"])
	local filterCanon = (not isAll) and (GSF.GetCanonicalProfession and GSF:GetCanonicalProfession(categoryFilter) or categoryFilter)

	for _, b in pairs(GSF.cache.bounties) do
		if b.status ~= GSF.ORDER_STATUS.CANCELLED then
			if isAll then
				table.insert(result, b)
			else
				local bCat = b.category or ""
				local bCanon = GSF.GetCanonicalProfession and GSF:GetCanonicalProfession(bCat) or bCat
				local match = (bCat:lower() == categoryFilter:lower()) or 
				              (bCanon:lower() == categoryFilter:lower()) or 
				              (filterCanon and bCanon:lower() == filterCanon:lower()) or
				              (bCat:upper() == categoryFilter:upper())
				
				-- Match AtlasJournal category keys with profession/category names
				if not match and categoryFilter:upper() == "ENCHANTING" and bCanon:lower() == "enchanting" then match = true end
				if not match and categoryFilter:upper() == "CLOTH" and bCanon:lower() == "tailoring" then match = true end
				if not match and categoryFilter:upper() == "LEATHER" and (bCanon:lower() == "leatherworking" or bCanon:lower() == "skinning") then match = true end
				if not match and categoryFilter:upper() == "ORE_STONE" and (bCanon:lower() == "mining" or bCanon:lower() == "blacksmithing" or bCanon:lower() == "engineering") then match = true end
				if not match and categoryFilter:upper() == "HERB" and (bCanon:lower() == "herbalism" or bCanon:lower() == "alchemy") then match = true end
				if not match and categoryFilter:upper() == "MEAT_FISH" and (bCanon:lower() == "cooking" or bCanon:lower() == "fishing") then match = true end

				if match then
					table.insert(result, b)
				end
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
