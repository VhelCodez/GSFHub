local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabDrops = Tab

function Tab:Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	self.frame = frame

	-- Top Bar: Standardized Search Input (Top-Left)
	local dropSearchBox = GSF.UI:CreateEditBox(frame, 150, 22)
	dropSearchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -12)
	self.dropSearchBox = dropSearchBox

	local searchHint = dropSearchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	searchHint:SetPoint("LEFT", dropSearchBox, "LEFT", 5, 0)
	searchHint:SetText(GSF.L["SEARCH_DROPS"] or "Search drops...")
	dropSearchBox.searchHint = searchHint
	dropSearchBox:HookScript("OnTextChanged", function(eb)
		if eb:GetText() ~= "" then searchHint:Hide() else searchHint:Show() end
		Tab:Refresh()
	end)

	-- Top Bar: Standardized Action Button (Top-Right)
	local addWishBtn = GSF.UI:CreateButton(frame, "+ " .. (GSF.L["ADD_TO_WISHLIST_BTN"] or "Zur Wunschliste"), 150, 24)
	addWishBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -12)
	self.addWishBtn = addWishBtn
	addWishBtn:SetScript("OnClick", function()
		Tab:OpenWishModal()
	end)

	-- Left Column Header: Recent Drops (aligned at y = -45)
	local dropTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dropTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -45)
	dropTitle:SetText(GSF.L["RECIPE_DROPS_TITLE"])
	self.dropTitle = dropTitle

	-- Right Column Header: My Wishlist (aligned at y = -45)
	local wishTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	wishTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 385, -45)
	wishTitle:SetText(GSF.L["WISHLIST_TITLE"])
	self.wishTitle = wishTitle

	-- Left Scroll List: Recent Drops
	local dropScroll, dropContent = GSF.UI:CreateScrollList(frame, 350, 360)
	dropScroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -68)
	dropScroll:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, 15)
	self.dropScroll = dropScroll
	self.dropContent = dropContent
	self.dropRows = {}

	-- Right Scroll List: My Wishlist
	local wishScroll, wishContent = GSF.UI:CreateScrollList(frame, 350, 360)
	wishScroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 385, -68)
	wishScroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 15)
	self.wishScroll = wishScroll
	self.wishContent = wishContent
	self.wishRows = {}

	-- Empty state notices (Anchored to the visible ScrollFrames, not the 1px-tall scroll children)
	local emptyDropsText = dropScroll:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	emptyDropsText:SetPoint("CENTER", dropScroll, "CENTER", 0, 0)
	emptyDropsText:SetWidth(280)
	emptyDropsText:SetJustifyH("CENTER")
	emptyDropsText:SetText(GSF.L["NO_RECIPES_FOUND"] or "No recipe drops recorded yet.")
	self.emptyDropsText = emptyDropsText

	local emptyWishText = wishScroll:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	emptyWishText:SetPoint("CENTER", wishScroll, "CENTER", 0, 0)
	emptyWishText:SetWidth(280)
	emptyWishText:SetJustifyH("CENTER")
	emptyWishText:SetText(GSF.L["WISHLIST_EMPTY_PROMPT"])
	self.emptyWishText = emptyWishText

	-- Build Wishlist Modal
	self:BuildWishModal(frame)

	return frame
end

function Tab:BuildWishModal(parent)
	local modal = CreateFrame("Frame", "GSFWishlistModal", parent)
	modal:SetSize(420, 200)
	modal:SetPoint("CENTER", parent, "CENTER", 0, 20)
	modal:SetFrameStrata("DIALOG")
	if BackdropTemplateMixin then Mixin(modal, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(modal, false)
	modal:SetBackdropColor(0.06, 0.06, 0.08, 0.98)
	modal:Hide()
	self.wishModal = modal

	local title = modal:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	title:SetPoint("TOPLEFT", modal, "TOPLEFT", 16, -14)
	title:SetText(GSF.L["ADD_TO_WISHLIST_TITLE"] or "Rezept zur Wunschliste hinzufügen")
	modal.title = title

	local closeBtn = CreateFrame("Button", nil, modal, "UIPanelCloseButton")
	closeBtn:SetPoint("TOPRIGHT", modal, "TOPRIGHT", -4, -4)

	local hint = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	hint:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
	hint:SetWidth(380)
	hint:SetJustifyH("LEFT")
	hint:SetText(GSF.L["WISHLIST_MODAL_HINT"] or "Rezept hierher ziehen oder per Shift-Klick einfügen:")
	modal.hint = hint

	-- Item Slot
	local itemSlot = GSF.UI:CreateItemSlot(modal, 32)
	itemSlot:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -16)
	modal.itemSlot = itemSlot

	-- EditBox for item name / link
	local addBox = GSF.UI:CreateEditBox(modal, 330, 24)
	addBox:SetPoint("LEFT", itemSlot, "RIGHT", 10, 0)
	modal.addBox = addBox

	GSF.UI:AttachItemPreview(addBox, itemSlot)

	-- Overwrite onItemDropped to strictly enforce recipe items
	local origOnItemDropped = itemSlot.onItemDropped
	itemSlot.onItemDropped = function(slot, name, link, texture, itemID)
		local isRecipe = GSF.RecipeDrops and GSF.RecipeDrops:IsRecipeItem(link or itemID or name)
		if not isRecipe then
			if GSF.Addon then
				GSF.Addon:Print(GSF.L["WISHLIST_RECIPES_ONLY"] or "Only recipes, schematics, patterns, and formulas can be added to the recipe wishlist.")
			end
			itemSlot:Clear()
			addBox:SetText("")
			addBox.lastItemName = nil
			addBox.lastItemLink = nil
			addBox.lastItemID = nil
			return
		end
		if origOnItemDropped then
			origOnItemDropped(slot, name, link, texture, itemID)
		end
	end

	local function SubmitWish()
		local text = addBox:GetText()
		if text and text:trim() ~= "" then
			local itemToWish = itemSlot.itemLink or addBox.lastItemLink or text:trim()
			local isRecipe = GSF.RecipeDrops and GSF.RecipeDrops:IsRecipeItem(itemToWish)
			if not isRecipe then
				if GSF.Addon then
					GSF.Addon:Print(GSF.L["WISHLIST_RECIPES_ONLY"] or "Only recipes, schematics, patterns, and formulas can be added to the recipe wishlist.")
				end
				return
			end
			local success = GSF.RecipeDrops:AddToWishlist(itemToWish)
			if success ~= false then
				modal:Hide()
				Tab:Refresh()
			end
		end
	end

	addBox:SetScript("OnEnterPressed", SubmitWish)

	-- Action Buttons at bottom
	local confirmBtn = GSF.UI:CreateButton(modal, GSF.L["ADD_TO_WISHLIST_BTN"] or "Hinzufügen", 120, 24)
	confirmBtn:SetPoint("BOTTOMRIGHT", modal, "BOTTOMRIGHT", -16, 16)
	confirmBtn:SetScript("OnClick", SubmitWish)
	modal.confirmBtn = confirmBtn

	local cancelBtn = GSF.UI:CreateButton(modal, GSF.L["CANCEL"] or "Abbrechen", 90, 24)
	cancelBtn:SetPoint("RIGHT", confirmBtn, "LEFT", -10, 0)
	cancelBtn:SetScript("OnClick", function()
		modal:Hide()
	end)
	modal.cancelBtn = cancelBtn
end

function Tab:OpenWishModal()
	if not self.wishModal then return end
	self.wishModal.itemSlot:Clear()
	self.wishModal.addBox:SetText("")
	self.wishModal.addBox.lastItemName = nil
	self.wishModal.addBox.lastItemLink = nil
	self.wishModal.addBox.lastItemID = nil
	self.wishModal:Show()
	self.wishModal.addBox:SetFocus()
end

function Tab:UpdateTexts()
	if not self.frame then return end
	if self.dropTitle then self.dropTitle:SetText(GSF.L["RECIPE_DROPS_TITLE"]) end
	if self.wishTitle then self.wishTitle:SetText(GSF.L["WISHLIST_TITLE"]) end
	if self.dropSearchBox and self.dropSearchBox.searchHint then
		self.dropSearchBox.searchHint:SetText(GSF.L["SEARCH_DROPS"] or "Search drops...")
	end
	if self.addWishBtn then self.addWishBtn:SetText("+ " .. (GSF.L["ADD_TO_WISHLIST_BTN"] or "Zur Wunschliste")) end
	if self.emptyDropsText then self.emptyDropsText:SetText(GSF.L["NO_RECIPES_FOUND"] or "No recipe drops recorded yet.") end
	if self.emptyWishText then self.emptyWishText:SetText(GSF.L["WISHLIST_EMPTY_PROMPT"]) end
	if self.wishModal then
		if self.wishModal.title then self.wishModal.title:SetText(GSF.L["ADD_TO_WISHLIST_TITLE"] or "Add Recipe to Wishlist") end
		if self.wishModal.hint then self.wishModal.hint:SetText(GSF.L["WISHLIST_MODAL_HINT"] or "Drag recipe here or Shift-Click from bags:") end
		if self.wishModal.confirmBtn then self.wishModal.confirmBtn:SetText(GSF.L["ADD_TO_WISHLIST_BTN"] or "Hinzufügen") end
		if self.wishModal.cancelBtn then self.wishModal.cancelBtn:SetText(GSF.L["CANCEL"] or "Abbrechen") end
	end
	self:Refresh()
end

function Tab:Refresh()
	if not self.frame or not self.frame:IsShown() then return end

	-- Refresh Drops
	local recentDrops = GSF.cache.recentDrops or {}
	local query = self.dropSearchBox and self.dropSearchBox:GetText():lower():trim() or ""
	if query ~= "" then
		local filtered = {}
		for _, drop in ipairs(recentDrops) do
			local itemMatch = drop.item and drop.item:lower():find(query, 1, true)
			local recMatch = drop.recipient and drop.recipient:lower():find(query, 1, true)
			local needsMatch = drop.needs and drop.needs:lower():find(query, 1, true)
			if itemMatch or recMatch or needsMatch then
				table.insert(filtered, drop)
			end
		end
		recentDrops = filtered
	end

	for _, row in ipairs(self.dropRows) do row:Hide() end

	local yOffset = 0
	for i, drop in ipairs(recentDrops) do
		local row = self.dropRows[i]
		if not row then
			row = CreateFrame("Frame", nil, self.dropContent)
			row:SetSize(320, 56)
			if BackdropTemplateMixin then Mixin(row, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(row, false)
			row:SetBackdropColor(0.10, 0.10, 0.14, 0.75)

			local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			itemText:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -6)
			row.itemText = itemText

			local needs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			needs:SetPoint("TOPLEFT", itemText, "BOTTOMLEFT", 0, -3)
			row.needs = needs

			local timeText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			timeText:SetPoint("TOPRIGHT", row, "TOPRIGHT", -8, -6)
			row.timeText = timeText

			table.insert(self.dropRows, row)
		end

		row:SetPoint("TOPLEFT", self.dropContent, "TOPLEFT", 0, -yOffset)
		row.itemText:SetText(drop.link or drop.name or "Recipe")
		
		local needList = (drop.neededBy and #drop.neededBy > 0) and table.concat(drop.neededBy, ", ") or "None"
		if #needList > 35 then needList = needList:sub(1, 35) .. "..." end
		row.needs:SetText("Needed by: " .. needList)

		local minsAgo = math.floor((time() - (drop.timestamp or time())) / 60)
		row.timeText:SetText(minsAgo > 0 and (minsAgo .. "m ago") or "Just now")

		row:Show()
		yOffset = yOffset + 62
	end

	if #recentDrops == 0 then
		if self.emptyDropsText then self.emptyDropsText:Show() end
	else
		if self.emptyDropsText then self.emptyDropsText:Hide() end
	end
	self.dropContent:SetHeight(math.max(yOffset, 1))

	-- Auto-hide drop scrollbar if list does not overflow
	local dropBar = self.dropScroll and (self.dropScroll.ScrollBar or (self.dropScroll:GetName() and _G[self.dropScroll:GetName() .. "ScrollBar"]))
	if dropBar then
		if #recentDrops == 0 or yOffset <= 370 then
			dropBar:Hide()
		else
			dropBar:Show()
		end
	end

	-- Refresh Wishlist
	local wishlist = GSF.db.myWishlist or {}
	for _, row in ipairs(self.wishRows) do row:Hide() end

	local wOffset = 0
	local idx = 1
	for key, item in pairs(wishlist) do
		local row = self.wishRows[idx]
		if not row then
			row = CreateFrame("Button", nil, self.wishContent)
			row:SetSize(320, 30)
			if BackdropTemplateMixin then Mixin(row, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(row, false)
			row:SetBackdropColor(0.12, 0.12, 0.16, 0.6)

			local icon = row:CreateTexture(nil, "ARTWORK")
			icon:SetSize(22, 22)
			icon:SetPoint("LEFT", row, "LEFT", 4, 0)
			icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			row.icon = icon

			local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			name:SetPoint("LEFT", icon, "RIGHT", 6, 0)
			name:SetPoint("RIGHT", row, "RIGHT", -36, 0)
			name:SetJustifyH("LEFT")
			row.name = name

			local delBtn = GSF.UI:CreateButton(row, "X", 24, 20)
			delBtn:SetPoint("RIGHT", row, "RIGHT", -6, 0)
			row.delBtn = delBtn

			row:EnableMouse(true)
			row:RegisterForClicks("LeftButtonUp")
			row:SetScript("OnEnter", function(self)
				if self.itemLink or self.itemID then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					if self.itemLink then
						GameTooltip:SetHyperlink(self.itemLink)
					elseif self.itemID then
						GameTooltip:SetItemByID(self.itemID)
					end
					GameTooltip:Show()
				end
			end)
			row:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
			row:SetScript("OnClick", function(self)
				if IsModifiedClick and IsModifiedClick("CHATLINK") and self.itemLink then
					ChatEdit_InsertLink(self.itemLink)
				end
			end)

			table.insert(self.wishRows, row)
		end

		row:SetPoint("TOPLEFT", self.wishContent, "TOPLEFT", 0, -wOffset)
		row.itemLink = item.link
		row.itemID = tonumber(key) or (item.link and tonumber(item.link:match("item:(%d+)")))
		row.itemName = item.name or key

		row.name:SetText(item.link or item.name or key)

		-- Resolve icon texture
		local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(item.link or row.itemID or item.name)
		if texture then
			row.icon:SetTexture(texture)
			row.icon:Show()
		elseif row.itemID and C_Item and C_Item.RequestLoadItemDataByID then
			row.icon:SetTexture("Interface\\Icons\\INV_Scroll_03")
			row.icon:Show()
			C_Item.RequestLoadItemDataByID(row.itemID)
			local itm = Item:CreateFromItemID(row.itemID)
			if itm then
				itm:ContinueOnItemLoad(function()
					local t = itm:GetItemIcon()
					if t and row.itemID == itm:GetItemID() then
						row.icon:SetTexture(t)
					end
				end)
			end
		else
			row.icon:SetTexture("Interface\\Icons\\INV_Scroll_03")
			row.icon:Show()
		end

		row.delBtn:SetScript("OnClick", function()
			GSF.RecipeDrops:RemoveFromWishlist(key)
			Tab:Refresh()
		end)

		row:Show()
		wOffset = wOffset + 34
		idx = idx + 1
	end

	if idx == 1 then
		if self.emptyWishText then self.emptyWishText:Show() end
	else
		if self.emptyWishText then self.emptyWishText:Hide() end
	end

	self.wishContent:SetHeight(math.max(wOffset, 1))

	-- Auto-hide wishlist scrollbar if list does not overflow
	local wishBar = self.wishScroll and (self.wishScroll.ScrollBar or (self.wishScroll:GetName() and _G[self.wishScroll:GetName() .. "ScrollBar"]))
	if wishBar then
		if idx <= 10 or wOffset <= 360 then
			wishBar:Hide()
		else
			wishBar:Show()
		end
	end
end
