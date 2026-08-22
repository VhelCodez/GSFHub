local ADDON_NAME, GSF = ...

local AceEvent = LibStub("AceEvent-3.0")
GSF.TradeHelper = {}
AceEvent:Embed(GSF.TradeHelper)

GSF.TradeHelper.stagedItems = nil
GSF.TradeHelper.targetTradePartner = nil

function GSF.TradeHelper:Initialize()
	self:RegisterEvent("TRADE_SHOW", "OnTradeShow")
	self:RegisterEvent("TRADE_CLOSED", "OnTradeClosed")
end

function GSF.TradeHelper:PrepareTrade(targetName, items)
	self.targetTradePartner = targetName
	self.stagedItems = items
	
	-- Target player if nearby
	if targetName and UnitExists(targetName) then
		TargetUnit(targetName)
		InitiateTrade("target")
	else
		GSF.Addon:Printf("Initiate trade with |cff33ff99%s|r to auto-stage items.", targetName or "player")
	end
end

function GSF.TradeHelper:OnTradeShow()
	local partnerName = UnitName("NPC") or UnitName("target")
	if not partnerName then return end

	if self.targetTradePartner and partnerName:lower() == self.targetTradePartner:lower() and self.stagedItems then
		self:PopulateTradeFrame()
	end
end

function GSF.TradeHelper:PopulateTradeFrame()
	if not self.stagedItems then return end
	local tradeSlot = 1

	for _, itemInfo in ipairs(self.stagedItems) do
		if tradeSlot > 6 then break end
		local bag, slot = self:FindItemInBags(itemInfo.name or itemInfo.link)
		if bag and slot then
			C_Container and C_Container.PickupContainerItem and C_Container.PickupContainerItem(bag, slot) or PickupContainerItem(bag, slot)
			ClickTradeButton(tradeSlot)
			tradeSlot = tradeSlot + 1
		end
	end

	self.stagedItems = nil
	self.targetTradePartner = nil
end

function GSF.TradeHelper:FindItemInBags(itemIdentifier)
	if not itemIdentifier then return nil end
	local searchName = (itemIdentifier:match("%[(.+)%]") or itemIdentifier):lower()

	for bag = 0, 4 do
		local numSlots = C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerNumSlots(bag) or GetContainerNumSlots(bag)
		for slot = 1, numSlots do
			local link = C_Container and C_Container.GetContainerItemLink and C_Container.GetContainerItemLink(bag, slot) or GetContainerItemLink(bag, slot)
			if link then
				local name = (GetItemInfo(link) or ""):lower()
				if name == searchName or (link:lower():find(searchName, 1, true)) then
					return bag, slot
				end
			end
		end
	end
	return nil
end

function GSF.TradeHelper:OnTradeClosed()
	-- Clean staged items if window closed
	self.stagedItems = nil
	self.targetTradePartner = nil
end
