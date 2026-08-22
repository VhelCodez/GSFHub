local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabSurplus = Tab

function Tab:Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	self.frame = frame

	-- Search & Filter Controls
	local searchLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	searchLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -10)
	searchLabel:SetText(GSF.L["SEARCH_SURPLUS"])

	local searchBox = GSF.UI:CreateEditBox(frame, 220, 22)
	searchBox:SetPoint("TOPLEFT", searchLabel, "BOTTOMLEFT", 0, -4)
	self.searchBox = searchBox

	searchBox:SetScript("OnTextChanged", function(eb)
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
	title:SetText("|cff33ff99Offer Surplus Material|r")

	local bagLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	bagLabel:SetPoint("TOPLEFT", modal, "TOPLEFT", 20, -45)
	bagLabel:SetText("Select an item from your bags:")

	local bagScroll, bagContent = GSF.UI:CreateScrollList(modal, 370, 160)
	bagScroll:SetPoint("TOPLEFT", bagLabel, "BOTTOMLEFT", 0, -6)
	self.bagContent = bagContent
	self.bagItemButtons = {}

	local selectedBagItem = nil

	local qtyLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	qtyLabel:SetPoint("TOPLEFT", bagScroll, "BOTTOMLEFT", 0, -12)
	qtyLabel:SetText("Quantity:")

	local qtyBox = GSF.UI:CreateEditBox(modal, 60, 22)
	qtyBox:SetPoint("TOPLEFT", qtyLabel, "BOTTOMLEFT", 0, -4)
	qtyBox:SetText("1")
	self.modalQtyBox = qtyBox

	local notesLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	notesLabel:SetPoint("LEFT", qtyLabel, "RIGHT", 40, 0)
	notesLabel:SetText("Notes (Optional):")

	local notesBox = GSF.UI:CreateEditBox(modal, 240, 22)
	notesBox:SetPoint("TOPLEFT", notesLabel, "BOTTOMLEFT", 0, -4)
	self.modalNotesBox = notesBox

	local postBtn = GSF.UI:CreateButton(modal, "Offer Item", 120, 24)
	postBtn:SetPoint("BOTTOMLEFT", modal, "BOTTOMLEFT", 40, 15)
	postBtn:SetScript("OnClick", function()
		if selectedBagItem then
			local count = tonumber(qtyBox:GetText()) or selectedBagItem.count or 1
			local notes = notesBox:GetText()
			GSF.Surplus:PostItem(selectedBagItem.link, count, notes)
			modal:Hide()
			Tab:Refresh()
		end
	end)

	local cancelBtn = GSF.UI:CreateButton(modal, "Cancel", 90, 24)
	cancelBtn:SetPoint("LEFT", postBtn, "RIGHT", 20, 0)
	cancelBtn:SetScript("OnClick", function() modal:Hide() end)

	self.selectBagItem = function(item)
		selectedBagItem = item
		qtyBox:SetText(tostring(item.count or 1))
	end
end

function Tab:OpenOfferModal()
	if not self.modal then return end
	local bagItems = GSF.Surplus:GetBagItems()

	for _, btn in ipairs(self.bagItemButtons) do btn:Hide() end

	local yOffset = 0
	for i, item in ipairs(bagItems) do
		local btn = self.bagItemButtons[i]
		if not btn then
			btn = CreateFrame("Button", nil, self.bagContent)
			btn:SetSize(340, 24)
			if BackdropTemplateMixin then Mixin(btn, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(btn, false)
			btn:SetBackdropColor(0.12, 0.12, 0.16, 0.6)

			local icon = btn:CreateTexture(nil, "ARTWORK")
			icon:SetSize(18, 18)
			icon:SetPoint("LEFT", btn, "LEFT", 3, 0)
			btn.icon = icon

			local name = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			name:SetPoint("LEFT", icon, "RIGHT", 6, 0)
			name:SetPoint("RIGHT", btn, "RIGHT", -40, 0)
			name:SetJustifyH("LEFT")
			btn.name = name

			local count = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			count:SetPoint("RIGHT", btn, "RIGHT", -6, 0)
			btn.count = count

			table.insert(self.bagItemButtons, btn)
		end

		btn:SetPoint("TOPLEFT", self.bagContent, "TOPLEFT", 0, -yOffset)
		
		local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(item.link)
		btn.icon:SetTexture(texture or "Interface\\Icons\\INV_Misc_QuestionMark")
		btn.name:SetText(item.link)
		btn.count:SetText("x" .. (item.count or 1))

		btn:SetScript("OnClick", function()
			Tab.selectBagItem(item)
		end)

		btn:Show()
		yOffset = yOffset + 26
	end

	self.bagContent:SetHeight(math.max(yOffset, 160))
	self.modalNotesBox:SetText("")
	self.modal:Show()
end

function Tab:Refresh()
	if not self.frame or not self.frame:IsShown() then return end

	local query = self.searchBox:GetText()
	local items = GSF.Surplus:GetAllSurplus(query)
	local myName = GSF.DB:GetPlayerName()

	for _, card in ipairs(self.surplusCards) do card:Hide() end

	local yOffset = 0
	for i, item in ipairs(items) do
		local card = self.surplusCards[i]
		if not card then
			card = CreateFrame("Frame", nil, self.content)
			card:SetSize(670, 52)
			if BackdropTemplateMixin then Mixin(card, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(card, false)
			card:SetBackdropColor(0.10, 0.10, 0.14, 0.75)

			local icon = card:CreateTexture(nil, "ARTWORK")
			icon:SetSize(36, 36)
			icon:SetPoint("LEFT", card, "LEFT", 8, 0)
			card.icon = icon

			local name = card:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
			name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -2)
			card.name = name

			local details = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			details:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -4)
			card.details = details

			local actionBtn = GSF.UI:CreateButton(card, "Request", 80, 20)
			actionBtn:SetPoint("RIGHT", card, "RIGHT", -12, 0)
			card.actionBtn = actionBtn

			local mailBtn = GSF.UI:CreateButton(card, "Mail", 60, 20)
			mailBtn:SetPoint("RIGHT", actionBtn, "LEFT", -6, 0)
			card.mailBtn = mailBtn

			table.insert(self.surplusCards, card)
		end

		card:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -yOffset)
		
		card.icon:SetTexture(item.texture or "Interface\\Icons\\INV_Misc_QuestionMark")
		card.name:SetText(string.format("%s x%d", item.link or item.name, item.count or 1))

		local ownerFormatted = GSF.Alts:GetFormattedName(item.owner)
		local noteStr = item.notes ~= "" and ("  •  " .. item.notes) or ""
		card.details:SetText(string.format("Offered by: %s%s", ownerFormatted, noteStr))

		if item.owner == myName then
			card.actionBtn:SetText("Remove")
			card.actionBtn:SetScript("OnClick", function()
				GSF.Surplus:RemoveItem(item.id)
				Tab:Refresh()
			end)
			card.mailBtn:Hide()
		else
			card.actionBtn:SetText("Whisper")
			card.actionBtn:SetScript("OnClick", function()
				ChatFrame_OpenChat(string.format("/w %s Hi, could I please get the surplus [%s] you listed in GSFHub?", item.owner, item.name))
			end)
			card.mailBtn:Show()
			card.mailBtn:SetScript("OnClick", function()
				if GSF.MailHelper then
					GSF.MailHelper:PrepareMail(item.owner, "GSF Surplus Request: " .. item.name)
				end
			end)
		end

		card:Show()
		yOffset = yOffset + 58
	end

	self.content:SetHeight(math.max(yOffset, 370))
end
