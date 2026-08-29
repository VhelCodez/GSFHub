local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabWorkOrders = Tab

function Tab:Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	self.frame = frame

	-- Header Controls: Search Box, Category Dropdown, Only My Professions Checkbox, Create Order Button
	local searchBox = GSF.UI:CreateEditBox(frame, 150, 22)
	searchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -12)
	self.searchBox = searchBox

	local searchHint = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	searchHint:SetPoint("LEFT", searchBox, "LEFT", 5, 0)
	searchHint:SetText(GSF.L["SEARCH_ORDERS"] or "Search orders...")
	searchBox.searchHint = searchHint
	searchBox:HookScript("OnTextChanged", function(eb)
		if eb:GetText() ~= "" then searchHint:Hide() else searchHint:Show() end
		Tab:Refresh()
	end)

	local currentCategory = "ALL"
	local catDropdown = CreateFrame("Frame", "GSFWorkOrderCatDropdown", frame, "UIDropDownMenuTemplate")
	catDropdown:SetPoint("LEFT", searchBox, "RIGHT", 4, -2)
	UIDropDownMenu_SetWidth(catDropdown, 125)
	UIDropDownMenu_SetText(catDropdown, GSF.L["FILTER_ALL_PROFESSIONS"] or "All Professions")
	self.catDropdown = catDropdown

	local profKeys = {
		"Alchemy", "Blacksmithing", "Enchanting", "Engineering",
		"Leatherworking", "Tailoring", "Jewelcrafting",
		"Cooking", "First Aid", "Lockpicking"
	}

	UIDropDownMenu_Initialize(catDropdown, function(self, level)
		local allInfo = UIDropDownMenu_CreateInfo()
		allInfo.text = GSF.L["FILTER_ALL_PROFESSIONS"] or "All Professions"
		allInfo.value = "ALL"
		allInfo.func = function(btn)
			currentCategory = "ALL"
			UIDropDownMenu_SetSelectedValue(catDropdown, "ALL")
			UIDropDownMenu_SetText(catDropdown, GSF.L["FILTER_ALL_PROFESSIONS"] or "All Professions")
			Tab:Refresh()
		end
		allInfo.checked = (currentCategory == "ALL")
		UIDropDownMenu_AddButton(allInfo, level)

		for _, pKey in ipairs(profKeys) do
			local locName = GSF:GetLocalizedProfession(pKey)
			local info = UIDropDownMenu_CreateInfo()
			info.text = locName
			info.value = pKey
			info.func = function(btn)
				currentCategory = btn.value
				UIDropDownMenu_SetSelectedValue(catDropdown, btn.value)
				UIDropDownMenu_SetText(catDropdown, locName)
				Tab:Refresh()
			end
			info.checked = (currentCategory == pKey)
			UIDropDownMenu_AddButton(info, level)
		end
	end)
	self.getCategory = function() return currentCategory end

	local filterProfCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	filterProfCheck:SetPoint("LEFT", catDropdown, "RIGHT", -10, 2)
	filterProfCheck.text:SetText(GSF.L["FILTER_MY_PROFESSIONS"])
	filterProfCheck.text:SetFontObject("GameFontHighlightSmall")
	filterProfCheck.text:ClearAllPoints()
	filterProfCheck.text:SetPoint("LEFT", filterProfCheck, "RIGHT", 1, 1)
	filterProfCheck:SetScript("OnClick", function()
		Tab:Refresh()
	end)
	self.filterProfCheck = filterProfCheck

	local newOrderBtn = GSF.UI:CreateButton(frame, "+ " .. GSF.L["CREATE_WORK_ORDER"], 160, 24)
	newOrderBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -12)
	self.newOrderBtn = newOrderBtn
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
	modal:SetSize(400, 310)
	modal:SetPoint("CENTER", parent, "CENTER", 0, 0)
	modal:SetFrameStrata("DIALOG")
	GSF.UI:CreateBackdrop(modal, false)
	modal:SetBackdropColor(0.06, 0.06, 0.08, 0.98)
	modal:Hide()
	self.modal = modal

	local title = modal:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", modal, "TOP", 0, -15)
	title:SetText(string.format("|cff%s%s|r", GSF.COLORS.PRIMARY, GSF.L["POST_WORK_ORDER_MODAL"] or "Post Work Order"))
	modal.title = title

	-- Item Name & Slot
	local itemLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	itemLabel:SetPoint("TOPLEFT", modal, "TOPLEFT", 25, -45)
	itemLabel:SetText(GSF.L["ITEM_OR_ENCHANT"] or "Item or Enchant Name:")
	modal.itemLabel = itemLabel

	local itemSlot = GSF.UI:CreateItemSlot(modal, 28)
	itemSlot:SetPoint("TOPLEFT", itemLabel, "BOTTOMLEFT", 0, -4)
	self.modalItemSlot = itemSlot

	local itemBox = GSF.UI:CreateEditBox(modal, 286, 22)
	itemBox:SetPoint("LEFT", itemSlot, "RIGHT", 6, 0)
	self.modalItemBox = itemBox

	GSF.UI:AttachItemPreview(itemBox, itemSlot, function(name, link, texture, itemID)
		if name then
			-- If user typed a raw numeric ID, replace the editbox text with the clean item name
			if itemBox:GetText():match("^%d+$") then
				itemBox:SetText(name)
			end

			-- Auto-detect profession if obvious and dropdown is currently on "Any"
			local detectedProf = GSF.DetectProfessionForItem and GSF:DetectProfessionForItem(link or itemID or name)
			if detectedProf and (Tab.selectedProf == "Any" or not Tab.selectedProf) then
				Tab.selectedProf = detectedProf
				UIDropDownMenu_SetSelectedValue(self.modalProfDropdown, detectedProf)
				local locText = GSF:GetLocalizedProfession(detectedProf)
				UIDropDownMenu_SetText(self.modalProfDropdown, locText)
			end
		end
	end)

	-- Quantity & Profession
	local qtyLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	qtyLabel:SetPoint("TOPLEFT", itemSlot, "BOTTOMLEFT", 0, -10)
	qtyLabel:SetText(GSF.L["QUANTITY"] or "Quantity:")
	modal.qtyLabel = qtyLabel

	local qtyBox = GSF.UI:CreateEditBox(modal, 60, 22)
	qtyBox:SetPoint("TOPLEFT", qtyLabel, "BOTTOMLEFT", 0, -4)
	qtyBox:SetText("1")
	self.modalQtyBox = qtyBox

	local profLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	profLabel:SetPoint("LEFT", qtyLabel, "RIGHT", 40, 0)
	profLabel:SetText(GSF.L["PROFESSION"] or "Profession:")
	modal.profLabel = profLabel

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
	modal.notesLabel = notesLabel

	local notesBox = GSF.UI:CreateEditBox(modal, 340, 22)
	notesBox:SetPoint("TOPLEFT", notesLabel, "BOTTOMLEFT", 0, -4)
	self.modalNotesBox = notesBox

	-- Error Notification Text
	local errorText = modal:CreateFontString(nil, "OVERLAY", "GameFontRedSmall")
	errorText:SetPoint("BOTTOMLEFT", modal, "BOTTOMLEFT", 20, 44)
	errorText:SetPoint("BOTTOMRIGHT", modal, "BOTTOMRIGHT", -20, 44)
	errorText:SetJustifyH("CENTER")
	errorText:Hide()
	self.modalErrorText = errorText

	-- Action Buttons
	local submitBtn = GSF.UI:CreateButton(modal, GSF.L["SUBMIT_ORDER"] or "Submit Order", 120, 24)
	submitBtn:SetPoint("BOTTOMLEFT", modal, "BOTTOMLEFT", 50, 15)
	modal.submitBtn = submitBtn

	submitBtn:SetScript("OnClick", function()
		local item = itemBox:GetText()
		item = item and item:match("^%s*(.-)%s*$") or ""
		local qty = tonumber(qtyBox:GetText()) or 1
		local prof = Tab.selectedProf or "Any"
		local mats = matsCheck:GetChecked()
		local notes = notesBox:GetText()

		-- Only use resolvedName if the input box has an ID, script, or link!
		-- If user typed custom text (e.g. "I need potions for my mage"), do NOT overwrite with an old item name!
		local hasNumericOrLink = item:match("^%d+$") or item:find("/script") or item:find("item:")
		if hasNumericOrLink and itemSlot.itemName and itemSlot.itemName ~= "" then
			item = itemSlot.itemName
		end

		-- If the slot has no item (e.g. custom text or cleared), itemLink and itemID MUST be nil!
		local itemLink = (itemSlot.itemName and itemSlot.itemName ~= "") and (itemSlot.itemLink or itemBox.lastItemLink) or nil
		local itemID = (itemSlot.itemName and itemSlot.itemName ~= "") and (itemSlot.itemID or itemBox.lastItemID) or nil
		if not itemSlot.itemName or itemSlot.itemName == "" then
			itemLink = nil
			itemID = nil
			itemBox.lastItemLink = nil
			itemBox.lastItemID = nil
		end

		-- Validate order against mechanics rules
		local valid, err = GSF.WorkOrders:ValidateOrder(item, qty, prof, itemLink, itemID)
		if not valid then
			if Tab.modalErrorText then
				Tab.modalErrorText:SetText(err)
				Tab.modalErrorText:Show()
			end
			if GSF.Addon then
				GSF.Addon:Print("|cffff5555" .. err .. "|r")
			end
			return
		end

		if Tab.modalErrorText then Tab.modalErrorText:Hide() end

		if Tab.editOrderId then
			GSF.WorkOrders:CancelOrder(Tab.editOrderId)
			Tab.editOrderId = nil
		end
		GSF.WorkOrders:CreateOrder(item, qty, prof, mats, notes, itemLink, itemID)
		modal:Hide()
		Tab:Refresh()
	end)

	local cancelBtn = GSF.UI:CreateButton(modal, GSF.L["CANCEL"] or "Cancel", 90, 24)
	cancelBtn:SetPoint("LEFT", submitBtn, "RIGHT", 20, 0)
	cancelBtn:SetScript("OnClick", function()
		Tab.editOrderId = nil
		if Tab.modalErrorText then Tab.modalErrorText:Hide() end
		modal:Hide()
	end)
	modal.cancelBtn = cancelBtn
end

StaticPopupDialogs["GSF_CONFIRM_COMPLETE_ORDER"] = {
	text = GSF.L["CONFIRM_COMPLETE_ORDER"] or "Are you sure you want to mark this order as completed?",
	button1 = GSF.L["YES"] or "Yes",
	button2 = GSF.L["NO"] or "No",
	OnAccept = function(dialog, data)
		if data and data.orderId then
			GSF.WorkOrders:CompleteOrder(data.orderId)
			Tab:Refresh()
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

function Tab:UpdateModalTexts()
	if not self.modal then return end
	local modal = self.modal
	local isEdit = (self.editOrderId ~= nil)
	if modal.title then
		local titleText = isEdit and (GSF.L["EDIT_ORDER"] or "Edit Work Order") or (GSF.L["POST_WORK_ORDER_MODAL"] or "Post Work Order")
		modal.title:SetText(string.format("|cff%s%s|r", GSF.COLORS.PRIMARY, titleText))
	end
	if modal.itemLabel then modal.itemLabel:SetText(GSF.L["ITEM_OR_ENCHANT"] or "Item or Enchant Name:") end
	if modal.qtyLabel then modal.qtyLabel:SetText(GSF.L["QUANTITY"] or "Quantity:") end
	if modal.profLabel then modal.profLabel:SetText(GSF.L["PROFESSION"] or "Profession:") end
	if self.modalMatsCheck and self.modalMatsCheck.text then
		self.modalMatsCheck.text:SetText(GSF.L["WILL_PROVIDE_MATS"] or "I will provide materials")
	end
	if modal.notesLabel then modal.notesLabel:SetText(GSF.L["NOTES_SPECS_TIP"] or "Notes / Specs / Tip:") end
	if modal.submitBtn then
		local btnText = isEdit and (GSF.L["SAVE_CHANGES"] or "Save Changes") or (GSF.L["SUBMIT_ORDER"] or "Submit Order")
		modal.submitBtn:SetText(btnText)
	end
	if modal.cancelBtn then modal.cancelBtn:SetText(GSF.L["CANCEL"] or "Cancel") end
	if self.modalProfDropdown then
		local cur = self.selectedProf or "Any"
		local loc = (cur == "Any") and (GSF.L["ANY"] or "Any") or GSF:GetLocalizedProfession(cur)
		UIDropDownMenu_SetText(self.modalProfDropdown, loc)
	end
end

function Tab:OpenCreateModal(prefillItem, prefillProf, prefillQty, prefillNotes, prefillMats, editOrderId, prefillLink, prefillId)
	if not self.modal then return end
	if self.modalErrorText then self.modalErrorText:Hide() end
	self.editOrderId = editOrderId
	self:UpdateModalTexts()
	self.modalItemBox:SetText(prefillItem or "")
	self.modalQtyBox:SetText(tostring(prefillQty or 1))
	self.modalNotesBox:SetText(prefillNotes or "")
	self.modalMatsCheck:SetChecked(prefillMats ~= false)

	self.modalItemSlot:Clear()
	self.modalItemBox.lastItemName = nil
	self.modalItemBox.lastItemLink = nil
	self.modalItemBox.lastItemID = nil

	-- Trigger item resolution exactly like the create flow
	local queryTarget = prefillLink or prefillId or (prefillItem and prefillItem:match("item:(%d+)") and tonumber(prefillItem:match("item:(%d+)"))) or prefillItem
	if queryTarget and queryTarget ~= "" then
		local numId = tonumber(prefillId) or tonumber(type(queryTarget) == "number" and queryTarget or (tostring(queryTarget):match("item:(%d+)")))
		local name, itemLink, _, _, _, _, _, _, _, texture = GetItemInfo(queryTarget)

		if name and texture then
			self.modalItemSlot:SetItem(name, texture, itemLink or prefillLink, numId or (itemLink and tonumber(itemLink:match("item:(%d+)"))))
			self.modalItemBox.lastItemName = name
			self.modalItemBox.lastItemLink = itemLink or prefillLink
			self.modalItemBox.lastItemID = numId or (itemLink and tonumber(itemLink:match("item:(%d+)")))
		elseif numId and numId >= 100 and C_Item and C_Item.RequestLoadItemDataByID and Item and Item.CreateFromItemID then
			C_Item.RequestLoadItemDataByID(numId)
			local item = Item:CreateFromItemID(numId)
			if item and not item:IsItemEmpty() and item:GetItemID() then
				pcall(function()
					item:ContinueOnItemLoad(function()
						local n = item:GetItemName()
						local icon = item:GetItemIcon()
						local l = item:GetItemLink()
						if icon and self.modalItemSlot then
							self.modalItemSlot:SetItem(n or prefillItem, icon, l or prefillLink, numId)
							self.modalItemBox.lastItemName = n or prefillItem
							self.modalItemBox.lastItemLink = l or prefillLink
							self.modalItemBox.lastItemID = numId
						end
					end)
				end)
			end
		end
	end

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
	if self.searchBox and self.searchBox.searchHint then
		self.searchBox.searchHint:SetText(GSF.L["SEARCH_ORDERS"] or "Search orders...")
	end
	if self.catDropdown then
		local cur = self.getCategory and self.getCategory() or "ALL"
		if cur == "ALL" then
			UIDropDownMenu_SetText(self.catDropdown, GSF.L["FILTER_ALL_PROFESSIONS"] or "All Professions")
		else
			local locName = GSF:GetLocalizedProfession(cur)
			UIDropDownMenu_SetText(self.catDropdown, locName)
		end
	end
	if self.newOrderBtn then self.newOrderBtn:SetText("+ " .. GSF.L["CREATE_WORK_ORDER"]) end
	if self.emptyText then self.emptyText:SetText(GSF.L["NO_ACTIVE_ORDERS"] or "No active work orders.") end
	self:UpdateModalTexts()
	self:Refresh()
end

function Tab:Refresh()
	if not self.frame or not self.frame:IsShown() then return end

	local myProfOnly = self.filterProfCheck:GetChecked()
	local orders = GSF.WorkOrders:GetOrders(myProfOnly, false)
	local myName = GSF.DB:GetPlayerName()

	local selectedCat = self.getCategory and self.getCategory() or "ALL"
	if selectedCat ~= "ALL" then
		local filtered = {}
		for _, o in ipairs(orders) do
			if o.profession == selectedCat then
				table.insert(filtered, o)
			end
		end
		orders = filtered
	end

	local query = self.searchBox and self.searchBox:GetText():lower():trim() or ""
	if query ~= "" then
		local filtered = {}
		for _, o in ipairs(orders) do
			local itemMatch = o.item and o.item:lower():find(query, 1, true)
			local reqMatch = o.requester and o.requester:lower():find(query, 1, true)
			local crafterMatch = o.crafter and o.crafter:lower():find(query, 1, true)
			local noteMatch = o.notes and o.notes:lower():find(query, 1, true)
			local profName = o.profession or ""
			local locProf = (GSF.GetLocalizedProfession and GSF:GetLocalizedProfession(profName)) or (GSF.L and GSF.L["PROF_" .. profName:upper()]) or profName
			local profMatch = (profName ~= "" and profName:lower():find(query, 1, true)) or (locProf ~= "" and locProf:lower():find(query, 1, true))
			if itemMatch or reqMatch or crafterMatch or noteMatch or profMatch then
				table.insert(filtered, o)
			end
		end
		orders = filtered
	end

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

			local iconSlot = GSF.UI:CreateItemSlot(card, 40)
			iconSlot:SetPoint("LEFT", card, "LEFT", 10, 0)
			iconSlot:SetScript("OnReceiveDrag", nil)
			iconSlot:SetScript("OnClick", function(self)
				if IsModifiedClick and IsModifiedClick("CHATLINK") and self.itemLink then
					ChatEdit_InsertLink(self.itemLink)
				end
			end)
			card.iconSlot = iconSlot

			local itemText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
			itemText:SetPoint("TOPLEFT", iconSlot, "TOPRIGHT", 10, -1)
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

			local actionBtn = GSF.UI:CreateButton(card, GSF.L["CLAIM_ORDER"], 95, 22)
			actionBtn:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -12, 8)
			card.actionBtn = actionBtn

			local whisperBtn = GSF.UI:CreateButton(card, GSF.L["WHISPER"] or "Whisper", 95, 22)
			whisperBtn:SetPoint("RIGHT", actionBtn, "LEFT", -8, 0)
			card.whisperBtn = whisperBtn

			table.insert(self.orderCards, card)
		end

		card:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -yOffset)

		-- If order doesn't have an itemId yet (e.g. older order), try to resolve it from cache or chatlinks
		if not order.itemId and order.item then
			local rawId = tonumber(order.item:match("item:(%d+)"))
			if rawId then
				order.itemId = rawId
			elseif GSF.ChatLinks and GSF.ChatLinks[order.item:lower()] then
				local cached = GSF.ChatLinks[order.item:lower()]
				order.itemId = cached.id
				order.itemLink = cached.link
			end
		end

		card.iconSlot.professionText = (order.profession and order.profession ~= "Any") and GSF:GetLocalizedProfession(order.profession) or nil

		-- Resolve icon texture and tooltip for the card
		local _, itemLink, _, _, _, _, _, _, _, texture = GetItemInfo(order.itemLink or order.itemId or order.item)
		if texture then
			card.iconSlot:SetItem(order.item, texture, itemLink or order.itemLink, order.itemId)
		else
			local profInfo = order.profession and GSF.PROFESSIONS[order.profession]
			local fallbackIcon = profInfo and profInfo.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
			card.iconSlot:SetItem(order.item, fallbackIcon, order.itemLink, order.itemId)
			if order.itemId and C_Item and C_Item.RequestLoadItemDataByID then
				local itm = Item:CreateFromItemID(order.itemId)
				if itm and not itm:IsItemEmpty() and itm:GetItemID() then
					pcall(function()
						itm:ContinueOnItemLoad(function()
							local t = itm:GetItemIcon()
							local l = itm:GetItemLink()
							if t and card.iconSlot then
								card.iconSlot:SetItem(order.item, t, l or order.itemLink, order.itemId)
							end
						end)
					end)
				end
			end
		end

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
				card.whisperBtn:SetText(GSF.L["EDIT"] or "Edit")
				card.whisperBtn:Show()
				card.whisperBtn:SetScript("OnClick", function()
					Tab:OpenCreateModal(order.item, order.profession, order.count, order.notes, order.matsProvided, order.id, order.itemLink, order.itemId)
				end)
			else
				card.actionBtn:SetText(GSF.L["CLAIM_ORDER"] or "Claim")
				card.actionBtn:SetScript("OnClick", function()
					GSF.WorkOrders:ClaimOrder(order.id)
					Tab:Refresh()
				end)
				card.whisperBtn:SetText(GSF.L["WHISPER"] or "Whisper")
				card.whisperBtn:Show()
				card.whisperBtn:SetScript("OnClick", function()
					ChatFrame_OpenChat(string.format("/w %s Hi, regarding your GSF work order for [%s]...", order.requester, order.item))
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
					StaticPopup_Show("GSF_CONFIRM_COMPLETE_ORDER", nil, nil, { orderId = order.id })
				end)
			else
				card.actionBtn:SetText(GSF.L["STATUS_CLAIMED"])
				card.actionBtn:SetScript("OnClick", nil)
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
		end

		card:Show()
		yOffset = yOffset + 68
	end

	self.content:SetHeight(math.max(yOffset, 1))

	-- Auto-hide scrollbar if orders don't overflow
	local scrollBar = self.scrollFrame and (self.scrollFrame.ScrollBar or (self.scrollFrame:GetName() and _G[self.scrollFrame:GetName() .. "ScrollBar"]))
	if scrollBar then
		if #orders <= 5 or yOffset <= 370 then
			scrollBar:Hide()
		else
			scrollBar:Show()
		end
	end
end
