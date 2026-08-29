local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabSurplus = Tab

function Tab:Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	self.frame = frame

	-- Search Input with inline hint placeholder
	local searchBox = GSF.UI:CreateEditBox(frame, 150, 22)
	searchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -12)
	self.searchBox = searchBox

	local searchHint = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	searchHint:SetPoint("LEFT", searchBox, "LEFT", 5, 0)
	searchHint:SetText(GSF.L["SEARCH_SURPLUS"] or "Search materials...")
	searchBox.searchHint = searchHint
	searchBox:HookScript("OnTextChanged", function(eb)
		if eb:GetText() ~= "" then searchHint:Hide() else searchHint:Show() end
		Tab:Refresh()
	end)

	local offerBtn = GSF.UI:CreateButton(frame, "+ " .. GSF.L["POST_SURPLUS"], 150, 24)
	offerBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -12)
	offerBtn:SetScript("OnClick", function()
		Tab:OpenOfferModal()
	end)

	-- Surplus Scroll List
	local scrollFrame, content = GSF.UI:CreateScrollList(frame, 700, 370)
	scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -45)
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 20)
	self.scrollFrame = scrollFrame
	self.content = content
	self.surplusCards = {}

	local emptyText = scrollFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	emptyText:SetPoint("CENTER", scrollFrame, "CENTER", 0, 0)
	emptyText:SetWidth(400)
	emptyText:SetText(GSF.L["NO_SURPLUS_LISTED"] or "No surplus materials currently offered.")
	emptyText:Hide()
	self.emptyText = emptyText

	-- Offer Modal
	self:BuildOfferModal(frame)

	return frame
end

function Tab:BuildOfferModal(parent)
	local modal = CreateFrame("Frame", "GSFSurplusModal", parent)
	modal:SetSize(420, 360)
	modal:SetPoint("CENTER", parent, "CENTER", 0, 0)
	modal:SetFrameStrata("DIALOG")
	GSF.UI:CreateBackdrop(modal, false)
	modal:SetBackdropColor(0.06, 0.06, 0.08, 0.98)
	modal:Hide()
	self.modal = modal

	local title = modal:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", modal, "TOP", 0, -15)
	title:SetText(string.format("|cff%s%s|r", GSF.COLORS.PRIMARY, GSF.L["OFFER_MODAL_TITLE"] or "Offer Surplus Material"))
	self.modalTitle = title

	local bagLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	bagLabel:SetPoint("TOPLEFT", modal, "TOPLEFT", 20, -45)
	bagLabel:SetText(GSF.L["SELECT_BAG_ITEM"] or "Select an item from your bags:")

	local bagSearchBox = GSF.UI:CreateEditBox(modal, 130, 20)
	bagSearchBox:SetPoint("TOPRIGHT", modal, "TOPRIGHT", -25, -42)
	self.bagSearchBox = bagSearchBox

	local searchHint = bagSearchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	searchHint:SetPoint("LEFT", bagSearchBox, "LEFT", 5, 0)
	searchHint:SetText(GSF.L["FILTER_BAG_ITEMS"] or "Filter bag...")
	self.bagSearchHint = searchHint

	bagSearchBox:HookScript("OnTextChanged", function(eb)
		local t = eb:GetText()
		if t and t ~= "" then
			searchHint:Hide()
		else
			searchHint:Show()
		end
		Tab:PopulateBagList(t)
	end)

	local bagScroll, bagContent = GSF.UI:CreateScrollList(modal, 370, 160)
	bagScroll:SetPoint("TOPLEFT", bagLabel, "BOTTOMLEFT", 0, -6)
	self.bagScroll = bagScroll
	self.bagContent = bagContent
	self.bagItemButtons = {}

	local selectedBagItem = nil

	local itemSlot = GSF.UI:CreateItemSlot(modal, 28)
	itemSlot:SetPoint("TOPLEFT", bagScroll, "BOTTOMLEFT", 10, -26)
	itemSlot:SetScript("OnReceiveDrag", nil)
	itemSlot:SetScript("OnClick", nil)
	itemSlot:EnableMouse(true)
	itemSlot.noDropHint = true
	self.modalItemSlot = itemSlot

	local qtyBox = GSF.UI:CreateEditBox(modal, 55, 22)
	qtyBox:SetPoint("LEFT", itemSlot, "RIGHT", 10, 0)
	qtyBox:SetText("")
	qtyBox:HookScript("OnTextChanged", function()
		if Tab.modalErrorText and Tab.modalErrorText:IsShown() then
			Tab.modalErrorText:Hide()
			Tab:UpdateBagInfoText()
		end
	end)
	self.modalQtyBox = qtyBox

	local qtyLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	qtyLabel:SetPoint("BOTTOMLEFT", qtyBox, "TOPLEFT", 0, 4)
	qtyLabel:SetText(GSF.L["QUANTITY"] or "Quantity:")

	local notesBox = GSF.UI:CreateEditBox(modal, 235, 22)
	notesBox:SetPoint("LEFT", qtyBox, "RIGHT", 15, 0)
	notesBox:SetText("")
	self.modalNotesBox = notesBox

	local notesLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	notesLabel:SetPoint("BOTTOMLEFT", notesBox, "TOPLEFT", 0, 4)
	notesLabel:SetText(GSF.L["NOTES_SPECS_TIP"] or GSF.L["NOTES"] or "Notes:")

	local errorText = modal:CreateFontString(nil, "OVERLAY", "GameFontRedSmall")
	errorText:SetPoint("BOTTOMLEFT", modal, "BOTTOMLEFT", 20, 44)
	errorText:SetPoint("BOTTOMRIGHT", modal, "BOTTOMRIGHT", -20, 44)
	errorText:SetJustifyH("CENTER")
	errorText:Hide()
	self.modalErrorText = errorText

	local bagInfoText = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	bagInfoText:SetPoint("BOTTOMLEFT", modal, "BOTTOMLEFT", 20, 44)
	bagInfoText:SetPoint("BOTTOMRIGHT", modal, "BOTTOMRIGHT", -20, 44)
	bagInfoText:SetJustifyH("CENTER")
	bagInfoText:SetTextColor(0.65, 0.65, 0.70)
	bagInfoText:Hide()
	self.modalBagInfoText = bagInfoText

	local postBtn = GSF.UI:CreateButton(modal, GSF.L["OFFER_ITEM_BTN"] or "Offer Item", 165, 24)
	postBtn:SetPoint("BOTTOMLEFT", modal, "BOTTOMLEFT", 65, 15)
	self.modalPostBtn = postBtn
	postBtn:SetScript("OnClick", function()
		if not Tab.selectedBagItem then
			if Tab.modalBagInfoText then Tab.modalBagInfoText:Hide() end
			if Tab.modalErrorText then
				Tab.modalErrorText:SetText(GSF.L["SELECT_BAG_ITEM_ERROR"] or "Please select an item from your bags first.")
				Tab.modalErrorText:Show()
			end
			return
		end
		local countText = qtyBox:GetText()
		local count = tonumber(countText and countText:match("^%s*(.-)%s*$"))
		if not count or count < 1 or count > 99999 or count ~= math.floor(count) then
			if Tab.modalBagInfoText then Tab.modalBagInfoText:Hide() end
			if Tab.modalErrorText then
				Tab.modalErrorText:SetText(GSF.L["SURPLUS_ERROR_QUANTITY"] or "Please enter a valid quantity between 1 and 99999.")
				Tab.modalErrorText:Show()
			end
			return
		end
		local notes = notesBox:GetText()

		-- If editing an existing surplus entry, pass editId to update in place
		local editId = Tab.editSurplusId
		Tab.editSurplusId = nil

		GSF.Surplus:PostItem(Tab.selectedBagItem.link, count, notes, editId)

		modal:Hide()
		Tab:Refresh()
	end)

	local cancelBtn = GSF.UI:CreateButton(modal, GSF.L["CANCEL"] or "Cancel", 100, 24)
	cancelBtn:SetPoint("LEFT", postBtn, "RIGHT", 15, 0)
	cancelBtn:SetScript("OnClick", function()
		Tab.editSurplusId = nil
		modal:Hide()
	end)

	self.selectBagItem = function(item, clickedBtn)
		Tab.selectedBagItem = item
		if Tab.modalErrorText then Tab.modalErrorText:Hide() end
		for _, b in ipairs(self.bagItemButtons) do
			b:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
			b:SetBackdropColor(0.10, 0.10, 0.14, 0.7)
		end
		if clickedBtn then
			clickedBtn:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
			clickedBtn:SetBackdropColor(0.25, 0.22, 0.10, 0.9)
		end
		local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(item.link or item.id)
		itemSlot:SetItem(item.link, texture, item.link, item.id)
		qtyBox:SetText(tostring(item.count or 1))
		Tab:UpdateBagInfoText()
	end
end

function Tab:UpdateBagInfoText()
	if not self.modalBagInfoText then return end
	if self.modalErrorText and self.modalErrorText:IsShown() then
		self.modalBagInfoText:Hide()
		return
	end
	if Tab.selectedBagItem then
		local bagTotal = GetItemCount(Tab.selectedBagItem.link or Tab.selectedBagItem.id) or 0
		self.modalBagInfoText:SetText(string.format(GSF.L["SURPLUS_BAG_COUNT_HINT"] or "You currently have %d in your bags.", bagTotal))
		self.modalBagInfoText:Show()
	else
		self.modalBagInfoText:Hide()
	end
end

function Tab:CreateBagItemButton()
	local btn = CreateFrame("Button", nil, self.bagContent)
	btn:SetSize(345, 30)
	if BackdropTemplateMixin then Mixin(btn, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(btn, false)

	local icon = btn:CreateTexture(nil, "ARTWORK")
	icon:SetSize(20, 20)
	icon:SetPoint("LEFT", btn, "LEFT", 6, 0)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	btn.icon = icon

	local name = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	name:SetPoint("LEFT", icon, "RIGHT", 8, 0)
	name:SetPoint("RIGHT", btn, "RIGHT", -48, 0)
	name:SetJustifyH("LEFT")
	btn.name = name

	local count = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	count:SetPoint("RIGHT", btn, "RIGHT", -8, 0)
	btn.count = count

	btn:SetScript("OnEnter", function(self)
		if self.itemData and self.itemData.link then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(self.itemData.link)
			GameTooltip:Show()
		elseif self.itemData and self.itemData.id then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetItemByID(self.itemData.id)
			GameTooltip:Show()
		end
		if Tab.selectedBagItem ~= self.itemData then
			self:SetBackdropColor(0.18, 0.18, 0.24, 0.85)
		end
	end)

	btn:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		if Tab.selectedBagItem == self.itemData then
			self:SetBackdropColor(0.25, 0.22, 0.10, 0.9)
			self:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
		else
			self:SetBackdropColor(0.10, 0.10, 0.14, 0.7)
			self:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
		end
	end)

	btn:SetScript("OnClick", function(self)
		Tab.selectBagItem(self.itemData, self)
	end)

	table.insert(self.bagItemButtons, btn)
	return btn
end

function Tab:PopulateBagList(filterText)
	filterText = (filterText or ""):lower():trim()
	for _, btn in ipairs(self.bagItemButtons) do btn:Hide() end

	local yOffset = 0
	local visibleCount = 0
	for _, item in ipairs(self.currentBagItems or {}) do
		local itemName = (item.link and item.link:match("%[(.-)%]")) or item.name or ""
		if filterText == "" or itemName:lower():find(filterText, 1, true) then
			visibleCount = visibleCount + 1
			local btn = self.bagItemButtons[visibleCount]
			if not btn then
				btn = self:CreateBagItemButton()
			end

			btn.itemData = item
			btn:SetPoint("TOPLEFT", self.bagContent, "TOPLEFT", 0, -yOffset)

			local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(item.link or item.id)
			btn.icon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")
			btn.name:SetText(item.link or item.name or ("Item " .. tostring(item.id)))
			btn.count:SetText(string.format("|cffffd100x%d|r", item.count or 1))

			local isSelected = false
			if Tab.selectedBagItem then
				if Tab.selectedBagItem == item then
					isSelected = true
				elseif Tab.selectedBagItem.id and item.id and Tab.selectedBagItem.id == item.id then
					isSelected = true
				elseif Tab.selectedBagItem.link and item.link and (
					Tab.selectedBagItem.link == item.link or 
					(Tab.selectedBagItem.link:match("item:(%d+)") and item.link:match("item:(%d+)") and 
					 Tab.selectedBagItem.link:match("item:(%d+)") == item.link:match("item:(%d+)"))
				) then
					isSelected = true
				end
			end

			if isSelected then
				Tab.selectedBagItem = item
				btn:SetBackdropColor(0.25, 0.22, 0.10, 0.9)
				btn:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
			else
				btn:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.8)
				btn:SetBackdropColor(0.10, 0.10, 0.14, 0.7)
			end

			btn:Show()
			yOffset = yOffset + 34
		end
	end

	self.bagContent:SetHeight(math.max(yOffset, 1))

	-- Auto-hide bag scrollbar if items fit without scrolling
	local bagBar = self.bagScroll and (self.bagScroll.ScrollBar or (self.bagScroll:GetName() and _G[self.bagScroll:GetName() .. "ScrollBar"]))
	if bagBar then
		if visibleCount <= 4 or yOffset <= 160 then
			bagBar:Hide()
			bagBar:SetAlpha(0)
		else
			bagBar:Show()
			bagBar:SetAlpha(1)
		end
	end
end

function Tab:OpenOfferModal(editItem)
	if not self.modal then return end
	if self.modalErrorText then self.modalErrorText:Hide() end
	if self.bagSearchBox then self.bagSearchBox:SetText("") end
	if self.bagSearchHint then self.bagSearchHint:Show() end

	self.currentBagItems = GSF.Surplus:GetBagItems()

	if editItem then
		self.editSurplusId = tostring(editItem.id)
		if self.modalTitle then
			self.modalTitle:SetText(string.format("|cff%s%s|r", GSF.COLORS.PRIMARY, GSF.L["EDIT_SURPLUS_TITLE"] or "Edit Surplus Material"))
		end
		if self.modalPostBtn then
			self.modalPostBtn:SetText(GSF.L["SAVE_CHANGES"] or "Save Changes")
		end

		Tab.selectedBagItem = {
			link = editItem.link,
			id = tonumber(editItem.itemId) or tonumber(editItem.id) or (editItem.link and tonumber(editItem.link:match("item:(%d+)"))),
			count = editItem.count,
			name = editItem.name,
		}

		local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(editItem.link or editItem.id)
		if self.modalItemSlot then
			self.modalItemSlot:SetItem(editItem.name or editItem.link, texture or editItem.texture, editItem.link, editItem.id)
		end
		self.modalQtyBox:SetText(tostring(editItem.count or 1))
		self.modalNotesBox:SetText(editItem.notes or "")
		self:UpdateBagInfoText()
	else
		self.editSurplusId = nil
		if self.modalTitle then
			self.modalTitle:SetText(string.format("|cff%s%s|r", GSF.COLORS.PRIMARY, GSF.L["OFFER_MODAL_TITLE"] or "Offer Surplus Material"))
		end
		if self.modalPostBtn then
			self.modalPostBtn:SetText(GSF.L["OFFER_ITEM_BTN"] or "Offer Item")
		end

		Tab.selectedBagItem = nil
		self.modalQtyBox:SetText("")
		self.modalNotesBox:SetText("")
		if self.modalItemSlot then self.modalItemSlot:Clear() end
		if self.modalBagInfoText then self.modalBagInfoText:Hide() end
	end

	self:PopulateBagList("")
	self.modal:Show()
end

function Tab:UpdateTexts()
	if not self.frame then return end
	if self.searchBox and self.searchBox.searchHint then
		self.searchBox.searchHint:SetText(GSF.L["SEARCH_SURPLUS"] or "Search materials...")
	end
	if self.offerBtn then self.offerBtn:SetText("+ " .. GSF.L["POST_SURPLUS"]) end
	if self.emptyText then self.emptyText:SetText(GSF.L["NO_SURPLUS_LISTED"] or "No surplus materials currently offered.") end
	self:Refresh()
end

function Tab:Refresh()
	if not self.frame or not self.frame:IsShown() then return end

	local query = self.searchBox:GetText()
	local items = GSF.Surplus:GetAllSurplus(query)
	local myName = GSF.DB:GetPlayerName()

	for _, card in ipairs(self.surplusCards) do card:Hide() end

	if #items == 0 then
		if self.emptyText then self.emptyText:Show() end
	else
		if self.emptyText then self.emptyText:Hide() end
	end

	local yOffset = 0
	for i, item in ipairs(items) do
		local card = self.surplusCards[i]
		if not card then
			card = CreateFrame("Frame", nil, self.content)
			card:SetSize(670, 52)
			if BackdropTemplateMixin then Mixin(card, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(card, false)
			card:SetBackdropColor(0.10, 0.10, 0.14, 0.75)

			local iconBtn = CreateFrame("Button", nil, card)
			iconBtn:SetSize(36, 36)
			iconBtn:SetPoint("LEFT", card, "LEFT", 8, 0)
			card.iconBtn = iconBtn

			local icon = iconBtn:CreateTexture(nil, "ARTWORK")
			icon:SetAllPoints()
			card.icon = icon

			iconBtn:SetScript("OnEnter", function(self)
				if card.itemLink and card.itemLink:find("item:") then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetHyperlink(card.itemLink)
					GameTooltip:Show()
				elseif card.itemId then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetItemByID(card.itemId)
					GameTooltip:Show()
				elseif card.itemLink then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetText(card.itemLink, 1, 0.82, 0)
					GameTooltip:Show()
				end
			end)
			iconBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
			iconBtn:SetScript("OnClick", function(self)
				if IsModifiedClick and IsModifiedClick("CHATLINK") and card.itemLink then
					ChatEdit_InsertLink(card.itemLink)
				end
			end)

			local name = card:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
			name:SetPoint("TOPLEFT", iconBtn, "TOPRIGHT", 10, -2)
			card.name = name

			local details = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			details:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -4)
			card.details = details

			local actionBtn = GSF.UI:CreateButton(card, GSF.L["CLAIM_SURPLUS"], 90, 20)
			actionBtn:SetPoint("RIGHT", card, "RIGHT", -12, 0)
			card.actionBtn = actionBtn

			local editBtn = GSF.UI:CreateButton(card, GSF.L["EDIT"] or "Edit", 70, 20)
			editBtn:SetPoint("RIGHT", actionBtn, "LEFT", -6, 0)
			card.editBtn = editBtn

			local mailBtn = GSF.UI:CreateButton(card, GSF.L["MAIL"] or "Mail", 60, 20)
			mailBtn:SetPoint("RIGHT", actionBtn, "LEFT", -6, 0)
			card.mailBtn = mailBtn

			table.insert(self.surplusCards, card)
		end

		card:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -yOffset)
		card.itemLink = item.link or item.name
		
		card.icon:SetTexture(item.texture or "Interface\\Icons\\INV_Misc_QuestionMark")
		card.name:SetText(string.format("%s x%d", item.link or item.name, item.count or 1))

		local ownerFormatted = GSF.Alts:GetFormattedName(item.owner)
		local noteStr = item.notes ~= "" and ("  •  " .. item.notes) or ""
		card.details:SetText(string.format(GSF.L["SURPLUS_OFFERED_BY"] .. "%s", ownerFormatted, noteStr))

		if item.owner == myName then
			card.actionBtn:SetText(GSF.L["REMOVE_SURPLUS"])
			card.actionBtn:SetScript("OnClick", function()
				GSF.Surplus:RemoveItem(item.id)
				Tab:Refresh()
			end)
			card.editBtn:Show()
			card.editBtn:SetScript("OnClick", function()
				Tab:OpenOfferModal(item)
			end)
			card.mailBtn:Hide()
		else
			card.actionBtn:SetText(GSF.L["CLAIM_SURPLUS"])
			card.actionBtn:SetScript("OnClick", function()
				ChatFrame_OpenChat(string.format("/w %s Hi, could I please get the surplus [%s] you listed in GSFHub?", item.owner, item.name))
			end)
			card.editBtn:Hide()
			card.mailBtn:Show()
			card.mailBtn:SetText(GSF.L["MAIL"] or "Mail")
			card.mailBtn:SetScript("OnClick", function()
				if GSF.MailHelper then
					GSF.MailHelper:PrepareMail(item.owner, "GSF Surplus Request: " .. item.name)
				end
			end)
		end

		card:Show()
		yOffset = yOffset + 58
	end

	self.content:SetHeight(math.max(yOffset, 1))

	-- Auto-hide scrollbar if items do not overflow
	local scrollBar = self.scrollFrame and (self.scrollFrame.ScrollBar or (self.scrollFrame:GetName() and _G[self.scrollFrame:GetName() .. "ScrollBar"]))
	if scrollBar then
		if #items <= 6 or yOffset <= 370 then
			scrollBar:Hide()
		else
			scrollBar:Show()
		end
	end
end
