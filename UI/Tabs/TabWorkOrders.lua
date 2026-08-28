local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabWorkOrders = Tab

function Tab:Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	self.frame = frame

	-- Header Controls
	local filterProfCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	filterProfCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -12)
	filterProfCheck.text:SetText(GSF.L["FILTER_MY_PROFESSIONS"])
	filterProfCheck.text:SetFontObject("GameFontHighlightSmall")
	self.filterProfCheck = filterProfCheck

	filterProfCheck:SetScript("OnClick", function()
		Tab:Refresh()
	end)

	local newOrderBtn = GSF.UI:CreateButton(frame, "+ " .. GSF.L["CREATE_WORK_ORDER"], 150, 24)
	newOrderBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -12)
	newOrderBtn:SetScript("OnClick", function()
		Tab:OpenCreateModal()
	end)

	-- Orders Scroll List
	local scrollFrame, content = GSF.UI:CreateScrollList(frame, 700, 370)
	scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -45)
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 20)
	self.scrollFrame = scrollFrame
	self.content = content
	self.orderCards = {}

	local emptyText = scrollFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	emptyText:SetPoint("CENTER", scrollFrame, "CENTER", 0, 0)
	emptyText:SetWidth(400)
	emptyText:SetText(GSF.L["NO_ACTIVE_ORDERS"] or "No active work orders right now.")
	emptyText:Hide()
	self.emptyText = emptyText

	-- Create Order Modal Dialog
	self:BuildCreateModal(frame)

	return frame
end

function Tab:BuildCreateModal(parent)
	local modal = CreateFrame("Frame", "GSFWorkOrderModal", parent)
	modal:SetSize(380, 290)
	modal:SetPoint("CENTER", parent, "CENTER", 0, 0)
	modal:SetFrameStrata("DIALOG")
	GSF.UI:CreateBackdrop(modal, false)
	modal:SetBackdropColor(0.06, 0.06, 0.08, 0.98)
	modal:Hide()
	self.modal = modal

	local title = modal:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", modal, "TOP", 0, -15)
	title:SetText(string.format("|cff%s%s|r", GSF.COLORS.PRIMARY, GSF.L["POST_WORK_ORDER_MODAL"] or "Post Work Order"))

	-- Item Name
	local itemLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	itemLabel:SetPoint("TOPLEFT", modal, "TOPLEFT", 25, -45)
	itemLabel:SetText(GSF.L["ITEM_OR_ENCHANT"] or "Item or Enchant Name:")

	local itemBox = GSF.UI:CreateEditBox(modal, 320, 22)
	itemBox:SetPoint("TOPLEFT", itemLabel, "BOTTOMLEFT", 0, -4)
	self.modalItemBox = itemBox

	-- Quantity & Profession
	local qtyLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	qtyLabel:SetPoint("TOPLEFT", itemBox, "BOTTOMLEFT", 0, -10)
	qtyLabel:SetText(GSF.L["QUANTITY"] or "Quantity:")

	local qtyBox = GSF.UI:CreateEditBox(modal, 60, 22)
	qtyBox:SetPoint("TOPLEFT", qtyLabel, "BOTTOMLEFT", 0, -4)
	qtyBox:SetText("1")
	self.modalQtyBox = qtyBox

	local profLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	profLabel:SetPoint("LEFT", qtyLabel, "RIGHT", 40, 0)
	profLabel:SetText(GSF.L["PROFESSION"] or "Profession:")

	self.selectedProf = "Any"
	local profDropdown = CreateFrame("Button", "GSFOrderProfDropdown", modal, "UIDropDownMenuTemplate")
	profDropdown:SetPoint("TOPLEFT", profLabel, "BOTTOMLEFT", -15, 2)
	UIDropDownMenu_SetWidth(profDropdown, 140)
	UIDropDownMenu_SetText(profDropdown, GSF.L["ANY"] or "Any")
	self.modalProfDropdown = profDropdown

	local profList = {"Any", "Alchemy", "Blacksmithing", "Enchanting", "Engineering", "Leatherworking", "Tailoring", "Jewelcrafting", "Cooking", "First Aid", "Lockpicking"}
	UIDropDownMenu_Initialize(profDropdown, function(self, level)
		for _, p in ipairs(profList) do
			local info = UIDropDownMenu_CreateInfo()
			local locText = (p == "Any") and (GSF.L["ANY"] or "Any") or GSF:GetLocalizedProfession(p)
			info.text = locText
			info.value = p
			info.func = function(btn)
				Tab.selectedProf = btn.value
				UIDropDownMenu_SetSelectedValue(profDropdown, btn.value)
				UIDropDownMenu_SetText(profDropdown, locText)
			end
			info.checked = (Tab.selectedProf == p)
			UIDropDownMenu_AddButton(info, level)
		end
	end)

	-- Mats Provided Checkbox
	local matsCheck = CreateFrame("CheckButton", nil, modal, "UICheckButtonTemplate")
	matsCheck:SetPoint("TOPLEFT", qtyBox, "BOTTOMLEFT", 0, -12)
	matsCheck.text:SetText(GSF.L["WILL_PROVIDE_MATS"] or "I will provide materials")
	matsCheck.text:SetFontObject("GameFontHighlightSmall")
	matsCheck:SetChecked(true)
	self.modalMatsCheck = matsCheck

	-- Notes EditBox
	local notesLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	notesLabel:SetPoint("TOPLEFT", matsCheck, "BOTTOMLEFT", 0, -8)
	notesLabel:SetText(GSF.L["NOTES_SPECS_TIP"] or "Notes / Specs / Tip:")

	local notesBox = GSF.UI:CreateEditBox(modal, 320, 22)
	notesBox:SetPoint("TOPLEFT", notesLabel, "BOTTOMLEFT", 0, -4)
	self.modalNotesBox = notesBox

	-- Action Buttons
	local submitBtn = GSF.UI:CreateButton(modal, GSF.L["SUBMIT_ORDER"] or "Submit Order", 120, 24)
	submitBtn:SetPoint("BOTTOMLEFT", modal, "BOTTOMLEFT", 40, 15)

	submitBtn:SetScript("OnClick", function()
		local item = itemBox:GetText()
		local qty = tonumber(qtyBox:GetText()) or 1
		local prof = Tab.selectedProf or "Any"
		local mats = matsCheck:GetChecked()
		local notes = notesBox:GetText()

		if item and item:trim() ~= "" then
			GSF.WorkOrders:CreateOrder(item, qty, prof, mats, notes)
			modal:Hide()
			Tab:Refresh()
		end
	end)

	local cancelBtn = GSF.UI:CreateButton(modal, GSF.L["CANCEL"] or "Cancel", 90, 24)
	cancelBtn:SetPoint("LEFT", submitBtn, "RIGHT", 20, 0)
	cancelBtn:SetScript("OnClick", function()
		modal:Hide()
	end)
end

function Tab:OpenCreateModal(prefillItem, prefillProf)
	if not self.modal then return end
	self.modalItemBox:SetText(prefillItem or "")
	self.modalQtyBox:SetText("1")
	self.modalNotesBox:SetText("")
	self.modalMatsCheck:SetChecked(true)

	local prof = prefillProf or "Any"
	self.selectedProf = prof
	UIDropDownMenu_SetSelectedValue(self.modalProfDropdown, prof)
	local locText = (prof == "Any") and (GSF.L["ANY"] or "Any") or GSF:GetLocalizedProfession(prof)
	UIDropDownMenu_SetText(self.modalProfDropdown, locText)

	self.modal:Show()
end

function Tab:UpdateTexts()
	if not self.frame then return end
	if self.filterProfCheck then self.filterProfCheck.text:SetText(GSF.L["FILTER_MY_PROFESSIONS"]) end
	if self.newOrderBtn then self.newOrderBtn:SetText("+ " .. GSF.L["CREATE_WORK_ORDER"]) end
	self:Refresh()
end

function Tab:Refresh()
	if not self.frame or not self.frame:IsShown() then return end

	local myProfOnly = self.filterProfCheck:GetChecked()
	local orders = GSF.WorkOrders:GetOrders(myProfOnly, false)
	local myName = GSF.DB:GetPlayerName()

	for _, card in ipairs(self.orderCards) do card:Hide() end

	if #orders == 0 then
		if self.emptyText then self.emptyText:Show() end
	else
		if self.emptyText then self.emptyText:Hide() end
	end

	local yOffset = 0
	for i, order in ipairs(orders) do
		local card = self.orderCards[i]
		if not card then
			card = CreateFrame("Frame", nil, self.content)
			card:SetSize(670, 60)
			if BackdropTemplateMixin then Mixin(card, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(card, false)
			card:SetBackdropColor(0.10, 0.10, 0.14, 0.75)

			local itemText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
			itemText:SetPoint("TOPLEFT", card, "TOPLEFT", 12, -8)
			card.itemText = itemText

			local details = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			details:SetPoint("TOPLEFT", itemText, "BOTTOMLEFT", 0, -4)
			card.details = details

			local notes = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			notes:SetPoint("TOPLEFT", details, "BOTTOMLEFT", 0, -3)
			card.notes = notes

			local statusText = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			statusText:SetPoint("TOPRIGHT", card, "TOPRIGHT", -12, -8)
			card.statusText = statusText

			local actionBtn = GSF.UI:CreateButton(card, GSF.L["CLAIM_ORDER"], 80, 20)
			actionBtn:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -12, 8)
			card.actionBtn = actionBtn

			local whisperBtn = GSF.UI:CreateButton(card, GSF.L["WHISPER"] or "Whisper", 70, 20)
			whisperBtn:SetPoint("RIGHT", actionBtn, "LEFT", -6, 0)
			card.whisperBtn = whisperBtn

			table.insert(self.orderCards, card)
		end

		card:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -yOffset)

		local isMine = (order.requester == myName)
		local isCrafter = (order.crafter == myName)

		local matsStr = order.matsProvided and ("|cff00ff00" .. GSF.L["MATS_PROVIDED"] .. "|r") or ("|cffff7f00" .. GSF.L["NO_MATS"] .. "|r")
		local reqFormatted = GSF.Alts:GetFormattedName(order.requester)
		local profDisplay = (order.profession and order.profession ~= "Any") and GSF:GetLocalizedProfession(order.profession) or (GSF.L["ANY"] or "Any")
		
		card.itemText:SetText(string.format("|cff%s%s|r x%d (|cffffd100%s|r)", GSF.COLORS.PRIMARY, order.item, order.count or 1, profDisplay))
		card.details:SetText(string.format("%s %s  •  %s", GSF.L["REQUESTED_BY"] or "Requested by:", reqFormatted, matsStr))
		card.notes:SetText(order.notes ~= "" and ((GSF.L["NOTE"] or "Note:") .. " " .. order.notes) or "")

		if order.status == GSF.ORDER_STATUS.OPEN then
			card.statusText:SetText("|cff00ff00" .. GSF.L["STATUS_OPEN"] .. "|r")
			if isMine then
				card.actionBtn:SetText(GSF.L["CANCEL_ORDER"] or "Cancel")
				card.actionBtn:SetScript("OnClick", function()
					GSF.WorkOrders:CancelOrder(order.id)
					Tab:Refresh()
				end)
			else
				card.actionBtn:SetText(GSF.L["CLAIM_ORDER"] or "Claim")
				card.actionBtn:SetScript("OnClick", function()
					GSF.WorkOrders:ClaimOrder(order.id)
					Tab:Refresh()
				end)
			end
		elseif order.status == GSF.ORDER_STATUS.CLAIMED then
			local crafterFormatted = GSF.Alts:GetFormattedName(order.crafter)
			card.statusText:SetText(string.format("|cffffd100" .. GSF.L["STATUS_CLAIMED"] .. "|r (%s)", crafterFormatted))
			if isCrafter then
				card.actionBtn:SetText(GSF.L["UNCLAIM_ORDER"] or "Release")
				card.actionBtn:SetScript("OnClick", function()
					GSF.WorkOrders:UnclaimOrder(order.id)
					Tab:Refresh()
				end)
			elseif isMine then
				card.actionBtn:SetText(GSF.L["COMPLETE_ORDER"] or "Complete")
				card.actionBtn:SetScript("OnClick", function()
					GSF.WorkOrders:CompleteOrder(order.id)
					Tab:Refresh()
				end)
			else
				card.actionBtn:SetText(GSF.L["STATUS_CLAIMED"])
				card.actionBtn:SetScript("OnClick", nil)
			end
		end

		card.whisperBtn:SetText(GSF.L["WHISPER"] or "Whisper")
		if isMine then
			card.whisperBtn:Hide()
		else
			card.whisperBtn:Show()
			card.whisperBtn:SetScript("OnClick", function()
				ChatFrame_OpenChat(string.format("/w %s Hi, regarding your GSF work order for [%s]...", order.requester, order.item))
			end)
		end

		card:Show()
		yOffset = yOffset + 68
	end

	self.content:SetHeight(math.max(yOffset, 370))
end
