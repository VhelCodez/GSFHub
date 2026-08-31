local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabAtlas = Tab

local selectedResource = nil
local activeCategory = "ALL"
local activeView = "ATLAS" -- "ATLAS" or "BOUNTIES"

local function IsPlaceholderIcon(icon)
	if not icon then return true end
	if type(icon) == "number" then
		return icon == 134400 or icon == 0
	end
	return tostring(icon):find("INV_Misc_QuestionMark", 1, true) ~= nil
end

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
	searchHint:SetText(GSF.L["SEARCH_ATLAS"] or "Search materials...")
	searchBox.searchHint = searchHint
	searchBox:HookScript("OnTextChanged", function(eb)
		if eb:GetText() ~= "" then searchHint:Hide() else searchHint:Show() end
		Tab:Refresh()
	end)

	-- Category Filter Dropdown
	local catDropdown = CreateFrame("Frame", "GSFAtlasCatDropdown", frame, "UIDropDownMenuTemplate")
	catDropdown:SetPoint("LEFT", searchBox, "RIGHT", 4, -2)
	UIDropDownMenu_SetWidth(catDropdown, 130)
	self.catDropdown = catDropdown

	local function UpdateCatDropdownText()
		local name = AtlasJournal and AtlasJournal:GetCategoryInfo(activeCategory)
		UIDropDownMenu_SetText(catDropdown, name or activeCategory)
	end
	self.UpdateCatDropdownText = UpdateCatDropdownText
	UpdateCatDropdownText()

	UIDropDownMenu_Initialize(catDropdown, function(dropdown, level)
		if not AtlasJournal or not AtlasJournal.Categories then return end
		for _, cat in ipairs(AtlasJournal.Categories) do
			local info = UIDropDownMenu_CreateInfo()
			local catName, catIcon = AtlasJournal:GetCategoryInfo(cat.key)
			info.text = catName
			info.icon = catIcon
			info.value = cat.key
			info.func = function(btn)
				activeCategory = btn.value
				UIDropDownMenu_SetSelectedValue(catDropdown, btn.value)
				UpdateCatDropdownText()
				Tab:Refresh()
			end
			info.checked = (activeCategory == cat.key)
			UIDropDownMenu_AddButton(info, level)
		end
	end)

	if AtlasJournal and AtlasJournal.RegisterCallback then
		AtlasJournal:RegisterCallback("ON_DATA_READY", function()
			if Tab and Tab.Refresh and activeView == "ATLAS" then
				Tab:Refresh()
			end
		end)
	end

	-- Toggle View Buttons (Aligned to TOPRIGHT, matching height 24 of other tabs)
	local manageGoalsBtn = GSF.UI:CreateButton(frame, GSF.L["MANAGE_GOALS"] or "Goals", 90, 24)
	manageGoalsBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -12)
	self.manageGoalsBtn = manageGoalsBtn

	local bountyViewBtn = GSF.UI:CreateButton(frame, GSF.L["VIEW_BOUNTIES"] or "Bounties", 90, 24)
	bountyViewBtn:SetPoint("RIGHT", manageGoalsBtn, "LEFT", -5, 0)
	self.bountyViewBtn = bountyViewBtn

	local atlasViewBtn = GSF.UI:CreateButton(frame, GSF.L["VIEW_ATLAS"] or "Resources", 90, 24)
	atlasViewBtn:SetPoint("RIGHT", bountyViewBtn, "LEFT", -5, 0)
	self.atlasViewBtn = atlasViewBtn

	-- Hide Completed Checkbox (Aligned beside Category dropdown on Bounties view)
	local hideCompletedCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	hideCompletedCheck:SetPoint("LEFT", catDropdown, "RIGHT", -10, 2)
	hideCompletedCheck.text:SetText(GSF.L["HIDE_COMPLETED"] or "Hide Completed")
	hideCompletedCheck.text:SetFontObject("GameFontHighlightSmall")
	hideCompletedCheck.text:ClearAllPoints()
	hideCompletedCheck.text:SetPoint("LEFT", hideCompletedCheck, "RIGHT", 2, 1)
	hideCompletedCheck:SetChecked(true)
	hideCompletedCheck:Hide()
	hideCompletedCheck:SetScript("OnClick", function() Tab:Refresh() end)
	self.hideCompletedCheck = hideCompletedCheck

	local goalsHeaderLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	goalsHeaderLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -14)
	goalsHeaderLabel:Hide()
	self.goalsHeaderLabel = goalsHeaderLabel

	atlasViewBtn:SetScript("OnClick", function()
		Tab:SwitchView("ATLAS")
	end)

	bountyViewBtn:SetScript("OnClick", function()
		Tab:SwitchView("BOUNTIES")
	end)

	manageGoalsBtn:SetScript("OnClick", function()
		Tab:SwitchView("GOALS")
	end)

	-- Container for Atlas View (aligned at y = -45)
	local atlasContainer = CreateFrame("Frame", nil, frame)
	atlasContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -45)
	atlasContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
	self.atlasContainer = atlasContainer

	-- Atlas Left Scroll List
	local leftScroll, leftContent = GSF.UI:CreateScrollList(atlasContainer, 300, 370)
	leftScroll:SetPoint("TOPLEFT", atlasContainer, "TOPLEFT", 5, 0)
	leftScroll:SetPoint("BOTTOMLEFT", atlasContainer, "BOTTOMLEFT", 5, 10)
	self.leftScroll = leftScroll
	self.leftContent = leftContent
	self.resourceRows = {}

	local resourcesEmpty = leftScroll:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	resourcesEmpty:SetPoint("CENTER", leftScroll, "CENTER", 0, 0)
	resourcesEmpty:SetWidth(260)
	resourcesEmpty:SetText(GSF.L["NO_RESOURCES_FOUND"] or "Keine passenden Ressourcen gefunden.")
	resourcesEmpty:Hide()
	self.resourcesEmptyText = resourcesEmpty

	-- Atlas Right Details Pane (with 26px gutter to avoid scrollbar collision)
	local rightPane = CreateFrame("Frame", nil, atlasContainer)
	rightPane:SetPoint("TOPLEFT", leftScroll, "TOPRIGHT", 26, 0)
	rightPane:SetPoint("BOTTOMRIGHT", atlasContainer, "BOTTOMRIGHT", -5, 10)
	if BackdropTemplateMixin then Mixin(rightPane, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(rightPane, false)
	rightPane:SetBackdropColor(0.04, 0.04, 0.06, 0.7)
	self.rightPane = rightPane

	local detailIcon = rightPane:CreateTexture(nil, "ARTWORK")
	detailIcon:SetSize(40, 40)
	detailIcon:SetPoint("TOPLEFT", rightPane, "TOPLEFT", 15, -15)
	self.detailIcon = detailIcon

	local detailIconBtn = CreateFrame("Button", nil, rightPane)
	detailIconBtn:SetAllPoints(detailIcon)
	self.detailIconBtn = detailIconBtn

	local detailTitle = rightPane:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	detailTitle:SetPoint("TOPLEFT", detailIcon, "TOPRIGHT", 12, -2)
	detailTitle:SetText(GSF.L["SELECT_RESOURCE_PROMPT"] or "Select a resource to view farming data")
	self.detailTitle = detailTitle

	local detailSub = rightPane:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	detailSub:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -4)
	self.detailSub = detailSub

	local rightScroll, rightContent = GSF.UI:CreateScrollList(rightPane, 410, 260)
	rightScroll:SetPoint("TOPLEFT", rightPane, "TOPLEFT", 15, -65)
	rightScroll:SetPoint("BOTTOMRIGHT", rightPane, "BOTTOMRIGHT", -32, 45)
	if rightScroll.ScrollBar then
		rightScroll.ScrollBar:ClearAllPoints()
		rightScroll.ScrollBar:SetPoint("TOPRIGHT", rightPane, "TOPRIGHT", -8, -80)
		rightScroll.ScrollBar:SetPoint("BOTTOMRIGHT", rightPane, "BOTTOMRIGHT", -8, 55)
	end
	self.rightScroll = rightScroll
	self.rightContent = rightContent

	local contentW = 320
	rightContent:SetWidth(contentW)

	local zonesLabel = rightContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	zonesLabel:SetPoint("TOPLEFT", rightContent, "TOPLEFT", 0, 0)
	zonesLabel:SetWidth(contentW)
	zonesLabel:SetJustifyH("LEFT")
	zonesLabel:SetText(GSF.L["SRC_SOURCES_HEADER"] or "Acquisition Sources:")
	self.zonesLabel = zonesLabel

	local zonesText = rightContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	zonesText:SetPoint("TOPLEFT", zonesLabel, "BOTTOMLEFT", 0, -5)
	zonesText:SetWidth(contentW)
	zonesText:SetJustifyH("LEFT")
	zonesText:SetWordWrap(true)
	self.zonesText = zonesText

	local sourceContainer = CreateFrame("Frame", nil, rightContent)
	sourceContainer:SetPoint("TOPLEFT", zonesText, "BOTTOMLEFT", 0, -5)
	sourceContainer:SetSize(contentW, 20)
	self.sourceContainer = sourceContainer
	self.sourceButtons = {}
	self.sourceHeaders = {}

	local yieldsLabel = rightContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	yieldsLabel:SetPoint("TOPLEFT", sourceContainer, "BOTTOMLEFT", 0, -12)
	yieldsLabel:SetWidth(contentW)
	yieldsLabel:SetJustifyH("LEFT")
	yieldsLabel:SetText(GSF.L["RESOURCE_YIELDS"] or "Harvest Yields & Byproducts:")
	self.yieldsLabel = yieldsLabel

	local yieldsContainer = CreateFrame("Frame", nil, rightContent)
	yieldsContainer:SetPoint("TOPLEFT", yieldsLabel, "BOTTOMLEFT", 0, -5)
	yieldsContainer:SetSize(contentW, 24)
	self.yieldsContainer = yieldsContainer
	self.yieldButtons = {}

	local tipsLabel = rightContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	tipsLabel:SetPoint("TOPLEFT", yieldsContainer, "BOTTOMLEFT", 0, -12)
	tipsLabel:SetWidth(contentW)
	tipsLabel:SetJustifyH("LEFT")
	tipsLabel:SetText(GSF.L["FARMING_TIPS"] or "Farming Route & Tips:")
	self.tipsLabel = tipsLabel

	local tipsText = rightContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	tipsText:SetPoint("TOPLEFT", tipsLabel, "BOTTOMLEFT", 0, -5)
	tipsText:SetWidth(contentW)
	tipsText:SetJustifyH("LEFT")
	tipsText:SetWordWrap(true)
	self.tipsText = tipsText

	-- Action Buttons bottom right
	local pinBtn = GSF.UI:CreateButton(rightPane, GSF.L["PIN_TO_HUD"] or "Pin to HUD", 120, 24)
	pinBtn:SetPoint("BOTTOMLEFT", rightPane, "BOTTOMLEFT", 15, 12)
	pinBtn:Disable()
	self.pinBtn = pinBtn

	pinBtn:SetScript("OnClick", function()
		if selectedResource then
			Tab:OpenSetupModal(selectedResource, "GOAL")
		end
	end)

	local bountyBtn = GSF.UI:CreateButton(rightPane, GSF.L["POST_BOUNTY_BTN"] or "Request Bounty", 140, 24)
	bountyBtn:SetPoint("LEFT", pinBtn, "RIGHT", 10, 0)
	bountyBtn:Disable()
	self.bountyBtn = bountyBtn

	bountyBtn:SetScript("OnClick", function()
		if selectedResource then
			Tab:OpenSetupModal(selectedResource, "BOUNTY")
		end
	end)

	-- Container for Bounties View (aligned at y = -45)
	local bountiesContainer = CreateFrame("Frame", nil, frame)
	bountiesContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -45)
	bountiesContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
	bountiesContainer:Hide()
	self.bountiesContainer = bountiesContainer

	self.bountyCards = {}
	local bountyScroll, bountyContent = GSF.UI:CreateScrollList(bountiesContainer, 690, 360)
	bountyScroll:SetPoint("TOPLEFT", bountiesContainer, "TOPLEFT", 5, -5)
	bountyScroll:SetPoint("BOTTOMRIGHT", bountiesContainer, "BOTTOMRIGHT", -25, 5)
	self.bountyScroll = bountyScroll
	self.bountyContent = bountyContent

	local bountiesEmpty = bountyScroll:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	bountiesEmpty:SetPoint("CENTER", bountyScroll, "CENTER", 0, 0)
	bountiesEmpty:SetText(GSF.L["NO_BOUNTIES_FOUND"] or "Keine passenden Aufträge vorhanden.")
	bountiesEmpty:Hide()
	self.bountiesEmptyText = bountiesEmpty

	-- Container for Personal Goals View (aligned at y = -45)
	local goalsContainer = CreateFrame("Frame", nil, frame)
	goalsContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -45)
	goalsContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
	goalsContainer:Hide()
	self.goalsContainer = goalsContainer

	self.goalRows = {}
	local goalScroll, goalContent = GSF.UI:CreateScrollList(goalsContainer, 690, 360)
	goalScroll:SetPoint("TOPLEFT", goalsContainer, "TOPLEFT", 5, -5)
	goalScroll:SetPoint("BOTTOMRIGHT", goalsContainer, "BOTTOMRIGHT", -25, 5)
	self.goalScroll = goalScroll
	self.goalContent = goalContent
	goalScroll:EnableMouse(true)
	goalScroll:SetScript("OnMouseUp", function() Tab:StopDraggingGoal() end)
	goalContent:EnableMouse(true)
	goalContent:SetScript("OnMouseUp", function() Tab:StopDraggingGoal() end)

	local goalsEmpty = goalScroll:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	goalsEmpty:SetPoint("CENTER", goalScroll, "CENTER", 0, 0)
	goalsEmpty:SetText(GSF.L["NO_GOALS_LISTED"] or "No active personal goals.")
	self.goalsEmptyText = goalsEmpty

	-- Build Unified Resource Setup Modal
	self:BuildSetupModal(frame)

	frame:RegisterEvent("BAG_UPDATE")
	frame:SetScript("OnEvent", function(self, event, ...)
		if event == "BAG_UPDATE" and self:IsShown() and activeView == "BOUNTIES" then
			Tab:RefreshBounties()
		end
	end)

	return frame
end

StaticPopupDialogs["GSF_CONFIRM_FULFILL_BOUNTY_INSUFFICIENT"] = {
	text = "%s",
	button1 = GSF.L["YES"] or "Yes",
	button2 = GSF.L["CANCEL"] or "Cancel",
	OnAccept = function(dialog, data)
		if data and data.bountyId then
			if data.isDeliver then
				GSF.SupplyBounties:MarkBountyDelivered(data.bountyId, "TRADE")
			else
				GSF.SupplyBounties:FulfillBounty(data.bountyId)
			end
			Tab:Refresh()
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

function Tab:BuildSetupModal(parent)
	local modal = CreateFrame("Frame", "GSFAtlasResourceSetupModal", parent)
	modal:SetSize(400, 280)
	modal:SetPoint("CENTER", parent, "CENTER", 0, 0)
	modal:SetFrameStrata("DIALOG")
	modal:EnableMouse(true)
	if BackdropTemplateMixin then Mixin(modal, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(modal, false)
	modal:SetBackdropColor(0.08, 0.08, 0.12, 1.0)
	modal:Hide()
	self.setupModal = modal
	self.bountyModal = modal

	local blocker = CreateFrame("Frame", nil, parent)
	blocker:SetAllPoints(parent)
	blocker:SetFrameStrata("DIALOG")
	blocker:SetFrameLevel(parent:GetFrameLevel() + 50)
	if BackdropTemplateMixin then Mixin(blocker, BackdropTemplateMixin) end
	blocker:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
	blocker:SetBackdropColor(0, 0, 0, 0.6)
	blocker:EnableMouse(true)
	blocker:Hide()
	modal.blocker = blocker

	modal:SetFrameLevel(blocker:GetFrameLevel() + 5)
	modal:HookScript("OnShow", function() if modal.blocker then modal.blocker:Show() end end)
	modal:HookScript("OnHide", function() if modal.blocker then modal.blocker:Hide() end end)

	local title = modal:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", modal, "TOP", 0, -15)
	modal.title = title

	local slot = GSF.UI:CreateItemSlot(modal, 32)
	slot:SetPoint("TOPLEFT", modal, "TOPLEFT", 25, -45)
	slot:SetScript("OnReceiveDrag", nil)
	slot:SetScript("OnClick", nil)
	slot:EnableMouse(true)
	slot.noDropHint = true
	modal.slot = slot

	local nameLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
	nameLabel:SetPoint("LEFT", slot, "RIGHT", 10, 0)
	modal.nameLabel = nameLabel

	-- Title / Label Input
	local titleLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	titleLabel:SetPoint("TOPLEFT", slot, "BOTTOMLEFT", 0, -12)
	titleLabel:SetText(GSF.L["GOAL_TITLE_LABEL"] or "Title / Label:")
	modal.titleLabel = titleLabel

	local titleBox = GSF.UI:CreateEditBox(modal, 345, 22)
	titleBox:SetPoint("TOPLEFT", titleLabel, "BOTTOMLEFT", 0, -3)
	modal.titleBox = titleBox

	-- Quantity Input
	local qtyLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	qtyLabel:SetPoint("TOPLEFT", titleBox, "BOTTOMLEFT", 0, -10)
	qtyLabel:SetText(GSF.L["QUANTITY"] or "Quantity:")
	modal.qtyLabel = qtyLabel

	local qtyBox = GSF.UI:CreateEditBox(modal, 70, 22)
	qtyBox:SetPoint("LEFT", qtyLabel, "RIGHT", 10, 0)
	modal.qtyBox = qtyBox

	-- Note Input
	local noteLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	noteLabel:SetPoint("TOPLEFT", qtyLabel, "BOTTOMLEFT", 0, -10)
	noteLabel:SetText(GSF.L["NOTE"] or "Note:")
	modal.noteLabel = noteLabel

	local noteBox = GSF.UI:CreateEditBox(modal, 345, 22)
	noteBox:SetPoint("TOPLEFT", noteLabel, "BOTTOMLEFT", 0, -3)
	modal.noteBox = noteBox

	-- Inline Red Error Text
	local errorText = modal:CreateFontString(nil, "OVERLAY", "GameFontRedSmall")
	errorText:SetPoint("BOTTOMLEFT", modal, "BOTTOMLEFT", 20, 44)
	errorText:SetPoint("BOTTOMRIGHT", modal, "BOTTOMRIGHT", -20, 44)
	errorText:SetJustifyH("CENTER")
	errorText:Hide()
	modal.errorText = errorText

	qtyBox:HookScript("OnTextChanged", function()
		if modal.errorText and modal.errorText:IsShown() then
			modal.errorText:Hide()
		end
	end)

	local submitBtn = GSF.UI:CreateButton(modal, GSF.L["SUBMIT_ORDER"] or "Submit", 140, 24)
	submitBtn:SetPoint("BOTTOMLEFT", modal, "BOTTOMLEFT", 45, 14)
	modal.submitBtn = submitBtn

	local cancelBtn = GSF.UI:CreateButton(modal, GSF.L["CANCEL"] or "Cancel", 100, 24)
	cancelBtn:SetPoint("LEFT", submitBtn, "RIGHT", 20, 0)
	cancelBtn:SetScript("OnClick", function() modal:Hide() end)
	modal.cancelBtn = cancelBtn

	submitBtn:SetScript("OnClick", function()
		local countText = qtyBox:GetText()
		local count = tonumber(countText and countText:match("^%s*(.-)%s*$"))
		if not count or count < 1 or count ~= math.floor(count) then
			modal.errorText:SetText(GSF.L["INVALID_AMOUNT_ERROR"] or "Please enter a valid amount.")
			modal.errorText:Show()
			return
		end

		local notes = noteBox:GetText():trim()

		if modal.mode == "GOAL" then
			local userTitle = titleBox:GetText():trim()
			if userTitle == "" then userTitle = modal.materialName end
			if GSF.GoalsHUD then
				GSF.GoalsHUD:AddPersonalGoal(modal.materialName, userTitle, count, notes, modal.icon, modal.category, modal.editGoalId, modal.itemID)
			end
			modal:Hide()
		elseif modal.mode == "BOUNTY" then
			if GSF.SupplyBounties then
				GSF.SupplyBounties:CreateBounty(modal.materialName, count, modal.category or "General", notes, nil, modal.itemID, modal.itemLink, modal.icon)
			end
			modal:Hide()
			activeView = "BOUNTIES"
			Tab:Refresh()
		elseif modal.mode == "BOUNTY_EDIT" then
			if GSF.SupplyBounties then
				GSF.SupplyBounties:UpdateBounty(modal.editBountyId, nil, count, nil, notes)
			end
			modal:Hide()
			activeView = "BOUNTIES"
			Tab:Refresh()
		end
	end)
end

function Tab:OpenSetupModal(target, mode, editGoalId, editBountyId)
	if not self.setupModal then return end
	local modal = self.setupModal
	modal.mode = mode or "GOAL"
	modal.editGoalId = editGoalId
	modal.editBountyId = editBountyId
	modal.itemID = nil
	if modal.errorText then modal.errorText:Hide() end

	local dispName = ""
	local icon = ""
	local cat = "General"
	local initTitle = ""
	local initQty = ""
	local initNotes = ""

	if mode == "BOUNTY_EDIT" and target then
		dispName = target.item or ""
		local targetID = target.itemId or (target.itemLink and tonumber(target.itemLink:match("item:(%d+)"))) or (target.item and tonumber(target.item:match("item:(%d+)")))
		modal.itemID = targetID

		local itemIcon = target.icon
		if not itemIcon or IsPlaceholderIcon(itemIcon) then
			local qTarget = target.itemLink or targetID or target.item
			local n, l, _, _, _, _, _, _, _, t = GetItemInfo(qTarget)
			if t then
				itemIcon = t
				dispName = n or dispName
				target.itemLink = target.itemLink or l
				modal.itemID = modal.itemID or (l and tonumber(l:match("item:(%d+)")))
			end
		end
		if not itemIcon or IsPlaceholderIcon(itemIcon) then
			if targetID and AtlasJournal and AtlasJournal.GetItemDetails then
				local d = AtlasJournal:GetItemDetails(targetID)
				if d and d.icon then
					itemIcon = d.icon
					dispName = (dispName ~= "" and dispName) or d.name
					target.itemLink = target.itemLink or d.link
				end
			end
		end
		if not itemIcon or IsPlaceholderIcon(itemIcon) then
			local res = AtlasJournal and AtlasJournal:FindResource(target.item)
			if res then
				local d = AtlasJournal:GetItemDetails(res.id)
				if d and d.icon then
					itemIcon = d.icon
					target.itemLink = target.itemLink or d.link
					modal.itemID = modal.itemID or res.id
				end
			end
		end
		icon = itemIcon or "Interface\\Icons\\INV_Misc_QuestionMark"
		cat = target.category or "General"
		initTitle = target.item or ""
		initQty = tostring(target.count or "")
		initNotes = target.notes or ""

		if IsPlaceholderIcon(icon) and modal.itemID and modal.itemID >= 100 and C_Item and C_Item.RequestLoadItemDataByID then
			C_Item.RequestLoadItemDataByID(modal.itemID)
			local itm = Item and Item:CreateFromItemID(modal.itemID)
			if itm and not itm:IsItemEmpty() then
				pcall(function()
					itm:ContinueOnItemLoad(function()
						local t = itm:GetItemIcon()
						local n = itm:GetItemName()
						local l = itm:GetItemLink()
						if t and modal.slot then
							modal.slot:SetItem(n or dispName, t, l or target.itemLink, modal.itemID)
							modal.icon = t
						end
					end)
				end)
			end
		end
	elseif editGoalId and target then
		dispName = target.material or target.name or ""
		icon = target.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
		cat = target.category or "General"
		initTitle = target.title or target.name or dispName
		initQty = tostring(target.target or "")
		initNotes = target.notes or ""
		modal.itemID = target.itemID
	elseif target and (target.id or target.itemID or target.category) then
		local targetID = target.id or target.itemID
		local details = targetID and AtlasJournal and AtlasJournal:GetItemDetails(targetID)
		dispName = (details and details.name) or (AtlasJournal and AtlasJournal:GetDisplayName(target))
		icon = (details and details.icon) or target.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
		cat = target.category or "General"
		initTitle = dispName
		initQty = ""
		initNotes = ""
		modal.itemID = targetID
	else
		dispName = tostring(target or "")
		icon = "Interface\\Icons\\INV_Misc_QuestionMark"
		initTitle = dispName
		initQty = ""
		initNotes = ""
	end

	modal.materialName = dispName
	modal.icon = icon
	modal.category = cat

	local _, _, quality = GetItemInfo(target and (target.itemLink or target.itemId or target.item) or dispName)
	local qColor = quality and ITEM_QUALITY_COLORS[quality]
	local hex = qColor and qColor.hex or "|cffffd100"
	if not hex:find("^|c") then hex = "|c" .. hex end

	modal.nameLabel:SetText(string.format("%s%s|r", hex, dispName))
	modal.slot:SetItem(dispName, icon, target and target.itemLink, modal.itemID)
	modal.titleBox:SetText(initTitle)
	modal.qtyBox:SetText(initQty)
	modal.noteBox:SetText(initNotes)

	if modal.mode == "BOUNTY" or modal.mode == "BOUNTY_EDIT" then
		modal.titleLabel:Hide()
		modal.titleBox:Hide()
		modal:SetSize(400, 235)
		modal.qtyLabel:ClearAllPoints()
		modal.qtyLabel:SetPoint("TOPLEFT", modal.slot, "BOTTOMLEFT", 0, -14)
		modal.noteLabel:ClearAllPoints()
		modal.noteLabel:SetPoint("TOPLEFT", modal.qtyLabel, "BOTTOMLEFT", 0, -12)
	else -- "GOAL"
		modal.titleLabel:Show()
		modal.titleBox:Show()
		modal:SetSize(400, 290)
		modal.titleLabel:ClearAllPoints()
		modal.titleLabel:SetPoint("TOPLEFT", modal.slot, "BOTTOMLEFT", 0, -12)
		modal.qtyLabel:ClearAllPoints()
		modal.qtyLabel:SetPoint("TOPLEFT", modal.titleBox, "BOTTOMLEFT", 0, -10)
		modal.noteLabel:ClearAllPoints()
		modal.noteLabel:SetPoint("TOPLEFT", modal.qtyLabel, "BOTTOMLEFT", 0, -10)
	end

	if modal.mode == "GOAL" then
		if editGoalId then
			modal.title:SetText(string.format("|cff%s%s|r", GSF.COLORS.PRIMARY, GSF.L["EDIT_GOAL_TITLE"] or "Edit Personal Goal"))
			modal.submitBtn:SetText(GSF.L["SAVE_CHANGES"] or "Save Changes")
		else
			modal.title:SetText(string.format("|cff%s%s|r", GSF.COLORS.PRIMARY, GSF.L["SET_GOAL_TITLE"] or "Set Personal Goal"))
			modal.submitBtn:SetText(GSF.L["ADD_GOAL_BTN"] or "Add Goal")
		end
	elseif modal.mode == "BOUNTY_EDIT" then
		modal.title:SetText(string.format("|cff%s%s|r", GSF.COLORS.PRIMARY, GSF.L["EDIT_BOUNTY_TITLE"] or "Edit Bounty Request"))
		modal.submitBtn:SetText(GSF.L["SAVE_CHANGES"] or "Save Changes")
	else
		modal.title:SetText(string.format("|cff%s%s|r", GSF.COLORS.PRIMARY, GSF.L["BOUNTY_REQUEST_TITLE"] or "Request Material"))
		modal.submitBtn:SetText(GSF.L["SUBMIT_ORDER"] or "Submit")
	end

	if modal.titleLabel then modal.titleLabel:SetText(GSF.L["GOAL_TITLE_LABEL"] or "Title / Label:") end
	if modal.qtyLabel then modal.qtyLabel:SetText(GSF.L["QUANTITY"] or "Quantity:") end
	if modal.noteLabel then modal.noteLabel:SetText(GSF.L["NOTE"] or "Note:") end
	if modal.cancelBtn then modal.cancelBtn:SetText(GSF.L["CANCEL"] or "Cancel") end

	modal:Show()
end

function Tab:OpenGoalModal(goal)
	self:OpenSetupModal(goal, "GOAL", goal and goal.id)
end

function Tab:OpenBountyModal(resource)
	self:OpenSetupModal(resource, "BOUNTY")
end

function Tab:OpenBountyEditModal(bounty)
	if not bounty then return end
	self:OpenSetupModal(bounty, "BOUNTY_EDIT", nil, bounty.id)
end

function Tab:UpdateRowSelection()
	for _, row in ipairs(self.resourceRows or {}) do
		if row:IsShown() and row.resource then
			local isSelected = selectedResource and (row.resource.id == selectedResource.id)
			if isSelected then
				row:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
				row:SetBackdropColor(0.20, 0.16, 0.04, 0.85)
				if row.selBar then row.selBar:Show() end
			else
				row:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.5)
				row:SetBackdropColor(0.08, 0.08, 0.12, 0.6)
				if row.selBar then row.selBar:Hide() end
			end
		end
	end
end

function Tab:ScrollToResource(res)
	if not res or not self.leftScroll then return end
	for i, row in ipairs(self.resourceRows or {}) do
		if row:IsShown() and row.resource and row.resource.id == res.id then
			local rowTop = (i - 1) * 30
			local scrollVal = self.leftScroll:GetVerticalScroll() or 0
			local frameH = self.leftScroll:GetHeight() or 370
			if rowTop < scrollVal or (rowTop + 30) > (scrollVal + frameH) then
				local targetScroll = math.max(0, rowTop - 60)
				self.leftScroll:SetVerticalScroll(targetScroll)
				if self.leftScroll.ScrollBar then
					self.leftScroll.ScrollBar:SetValue(targetScroll)
				end
			end
			break
		end
	end
end

function Tab:SelectResource(res)
	if not res then return end
	selectedResource = res

	-- Ensure we are on the Atlas view
	if activeView ~= "ATLAS" and self.SwitchView then
		self:SwitchView("ATLAS")
	end

	-- Check if the resource is present in the currently filtered list
	local foundInList = false
	for _, r in ipairs(self.currentResources or {}) do
		if r.id == res.id then
			foundInList = true
			break
		end
	end

	-- If filtered out by search query or category, adapt filters so it is shown and highlighted!
	if not foundInList then
		local filterChanged = false
		if self.searchBox and self.searchBox:GetText() ~= "" then
			self.searchBox:SetText("")
			if self.searchBox.searchHint then self.searchBox.searchHint:Show() end
			filterChanged = true
		end
		if activeCategory ~= "ALL" and activeCategory ~= res.category then
			activeCategory = res.category or "ALL"
			if self.UpdateCatDropdownText then
				self:UpdateCatDropdownText()
			end
			filterChanged = true
		end
		if filterChanged then
			self:RefreshAtlas()
			return
		end
	end

	self:UpdateRowSelection()
	self:ScrollToResource(res)

	if self.pinBtn then self.pinBtn:Enable() end
	if self.bountyBtn then self.bountyBtn:Enable() end

	local details = AtlasJournal:GetItemDetails(res.id)
	local color = ITEM_QUALITY_COLORS[details.quality] or { hex = "ffffffff" }

	self.detailIcon:SetTexture(details.icon)
	if self.detailIconBtn then
		self.detailIconBtn:SetScript("OnEnter", function(f)
			GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
			if details.link then
				GameTooltip:SetHyperlink(details.link)
			else
				GameTooltip:SetItemByID(res.id)
			end
			GameTooltip:Show()
		end)
		self.detailIconBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
	end

	local hex = color and color.hex or "|cffffffff"
	if not hex:find("^|c") then hex = "|c" .. hex end
	self.detailTitle:SetText(string.format("%s%s|r", hex, details.name))

	local catName = AtlasJournal:GetCategoryInfo(res.category)
	local minSkill = AtlasJournal:GetMinSkill(res)
	if minSkill then
		self.detailSub:SetText(string.format("%s  •  Min Skill: |cffffd100%d|r  •  ID: |cffaaaaaa%d|r", catName, minSkill, res.id))
	else
		self.detailSub:SetText(string.format("%s  •  ID: |cffaaaaaa%d|r", catName, res.id))
	end

	-- Reset interactive buttons and headers
	for _, btn in ipairs(self.sourceButtons or {}) do btn:Hide() end
	for _, hdr in ipairs(self.sourceHeaders or {}) do
		hdr:Hide()
		if hdr.prefix then hdr.prefix:Hide() end
		if hdr.spellBtn then hdr.spellBtn:Hide() end
		if hdr.suffix then hdr.suffix:Hide() end
	end
	for _, btn in ipairs(self.yieldButtons or {}) do btn:Hide() end

	-- 1. Format Polymorphic Sources
	local textSources = {}
	local itemSources = {}
	if res.sources then
		for _, src in ipairs(res.sources) do
			if src.type == "GATHER" then
				local zones = {}
				for _, aId in ipairs(src.zones or {}) do
					table.insert(zones, AtlasJournal:GetZoneName(aId))
				end
				local zStr = #zones > 0 and table.concat(zones, ", ") or "World"
				table.insert(textSources, string.format("|cffffd100• %s|r (Skill %d):\n   %s", AtlasJournal:GetLocaleText("SRC_GATHER") or "Gathering", src.skill or 1, zStr))
			elseif src.type == "EXTRACT" then
				local zones = {}
				for _, aId in ipairs(src.zones or {}) do
					table.insert(zones, AtlasJournal:GetZoneName(aId))
				end
				local zStr = #zones > 0 and table.concat(zones, ", ") or "Outland"
				local devDetails = AtlasJournal:GetItemDetails(src.device or 23821)
				table.insert(textSources, string.format("|cffffd100• %s|r (Engi %d):\n   %s: %s\n   %s", AtlasJournal:GetLocaleText("SRC_EXTRACT") or "Gas Extraction", src.skill or 305, AtlasJournal:GetLocaleText("DEVICE_REQUIRED") or "Tool", devDetails.name or "Zapthrottle Mote Extractor", zStr))
			elseif src.type == "MOB_DROP" then
				local zones = {}
				for _, aId in ipairs(src.zones or {}) do
					table.insert(zones, AtlasJournal:GetZoneName(aId))
				end
				local zStr = #zones > 0 and table.concat(zones, ", ") or "World"
				table.insert(textSources, string.format("|cffffd100• %s|r (%s, Lvl %s):\n   %s", AtlasJournal:GetLocaleText("SRC_MOB_DROP") or "Creature Drop", src.mobType or "Mobs", src.mobLevel or "Any", zStr))
			elseif src.type == "FISH" then
				local zones = {}
				for _, aId in ipairs(src.zones or {}) do
					table.insert(zones, AtlasJournal:GetZoneName(aId))
				end
				local zStr = #zones > 0 and table.concat(zones, ", ") or "Waters"
				table.insert(textSources, string.format("|cffffd100• %s|r (Skill %d, %s):\n   %s", AtlasJournal:GetLocaleText("SRC_FISH") or "Fishing", src.skill or 1, src.school or "Open Water", zStr))
			elseif src.type == "DISENCHANT" then
				local spellID = 13262
				local spellName, _, spellIcon = GetSpellInfo(spellID)
				local qName = src.itemQuality == 4 and "|cffa335eeEpic|r" or (src.itemQuality == 3 and "|cff0070ddRare|r" or "|cff1eff00Uncommon|r")
				table.insert(itemSources, {
					prefix = string.format("|cffffd100• %s:|r", AtlasJournal:GetLocaleText("SRC_DISENCHANT") or "Disenchanting"),
					spellID = spellID,
					spellName = spellName or "Disenchant",
					spellIcon = spellIcon or "Interface\\Icons\\Spell_Holy_RemoveCurse",
					suffix = string.format("(%s, iLvl %s)", qName, src.itemLevels or "1+"),
					items = {},
				})
			elseif src.type == "INSTANCE" then
				table.insert(textSources, string.format("|cffffd100• %s|r: %s %s", AtlasJournal:GetLocaleText("SRC_INSTANCE") or "Instance Drop", src.dungeon or "", src.raid or ""))
			elseif src.type == "VENDOR" then
				table.insert(textSources, string.format("|cffffd100• %s|r: %s", AtlasJournal:GetLocaleText("SRC_VENDOR") or "Vendor Purchase", src.cost or ""))
			elseif src.type == "BYPRODUCT" then
				table.insert(itemSources, {
					title = string.format("|cffffd100• %s:|r", AtlasJournal:GetLocaleText("SRC_BYPRODUCT") or "Byproduct"),
					items = src.fromItems or {},
				})
			elseif src.type == "PROSPECT" then
				local spellID = src.spellID or 31252
				local spellName, _, spellIcon = GetSpellInfo(spellID)
				table.insert(itemSources, {
					prefix = string.format("|cffffd100• %s:|r", AtlasJournal:GetLocaleText("SRC_PROSPECT") or "Prospecting"),
					spellID = spellID,
					spellName = spellName or "Prospecting",
					spellIcon = spellIcon or "Interface\\Icons\\INV_Misc_Gem_Bloodstone_02",
					suffix = string.format("(Skill %d, 5x)", src.skill or 20),
					items = src.fromItems or {},
				})
			elseif src.type == "SMELT" then
				local spellID = src.spellID or 2656
				local spellName, _, spellIcon = GetSpellInfo(spellID)
				table.insert(itemSources, {
					prefix = string.format("|cffffd100• %s:|r", AtlasJournal:GetLocaleText("SRC_SMELT") or "Smelting"),
					spellID = spellID,
					spellName = spellName or "Smelting",
					spellIcon = spellIcon or "Interface\\Icons\\Spell_Fire_FlameBlades",
					suffix = string.format("(Skill %d)", src.skill or 1),
					items = src.fromItems or {},
				})
			elseif src.type == "TRANSMUTE" then
				local spellID = src.spellID or 28566
				local spellName, _, spellIcon = GetSpellInfo(spellID)
				local suffix = src.cooldown and string.format("(%s CD)", src.cooldown) or nil
				table.insert(itemSources, {
					prefix = string.format("|cffffd100• %s:|r", AtlasJournal:GetLocaleText("SRC_TRANSMUTE") or "Transmutation"),
					spellID = spellID,
					spellName = spellName or "Transmute",
					spellIcon = spellIcon or "Interface\\Icons\\Spell_Holy_GreaterHeal",
					suffix = suffix,
					items = src.fromItems or {},
				})
			elseif src.type == "COMBINE" then
				local titleText
				if src.yieldCount and src.yieldCount > 1 then
					titleText = string.format("|cffffd100• %s|r (%dx -> %dx):", AtlasJournal:GetLocaleText("SRC_COMBINE") or "Combine", src.count or 10, src.yieldCount)
				else
					titleText = string.format("|cffffd100• %s|r (%dx):", AtlasJournal:GetLocaleText("SRC_COMBINE") or "Combine", src.count or 10)
				end
				table.insert(itemSources, {
					title = titleText,
					items = { src.fromItem },
					itemCount = src.count,
				})
			elseif src.type == "CRAFT" then
				local spellID = src.spellID
				local spellName, _, spellIcon
				if spellID then
					spellName, _, spellIcon = GetSpellInfo(spellID)
				end
				local countPrefix = src.count and string.format("%dx ", src.count) or ""
				local yieldSuffix = (src.yieldCount and src.yieldCount > 1) and string.format(" -> %dx", src.yieldCount) or ""
				local skillStr = src.skill and string.format("Skill %d", src.skill) or nil

				local suffixParts = {}
				if countPrefix ~= "" or yieldSuffix ~= "" then
					table.insert(suffixParts, string.format("%s%s", countPrefix, yieldSuffix))
				end
				if skillStr then
					table.insert(suffixParts, skillStr)
				end
				local suffix = #suffixParts > 0 and string.format("(%s)", table.concat(suffixParts, ", ")) or nil

				if spellID then
					table.insert(itemSources, {
						prefix = string.format("|cffffd100• %s:|r", AtlasJournal:GetLocaleText("SRC_CRAFT") or "Crafting"),
						spellID = spellID,
						spellName = spellName or src.profession or "Craft",
						spellIcon = spellIcon or "Interface\\Icons\\Trade_Leatherworking",
						suffix = suffix,
						items = src.fromItems or (src.fromItem and { src.fromItem }) or {},
						itemCount = src.count,
					})
				else
					local titleText
					if src.skill then
						titleText = string.format("|cffffd100• %s|r (%s%s%s, Skill %d):", AtlasJournal:GetLocaleText("SRC_CRAFT") or "Crafting", countPrefix, src.profession or "Craft", yieldSuffix, src.skill)
					else
						titleText = string.format("|cffffd100• %s|r (%s%s%s):", AtlasJournal:GetLocaleText("SRC_CRAFT") or "Crafting", countPrefix, src.profession or "Craft", yieldSuffix)
					end
					table.insert(itemSources, {
						title = titleText,
						items = src.fromItems or (src.fromItem and { src.fromItem }) or {},
						itemCount = src.count,
					})
				end
			end
		end
	end

	-- Render text sources
	if #textSources > 0 then
		self.zonesText:SetText(table.concat(textSources, "\n\n"))
		self.zonesText:Show()
	else
		self.zonesText:SetText("")
		self.zonesText:Hide()
	end

	-- Render interactive source badges
	local nextBadgeIdx = 1
	local curSourceY = 0
	local badgeW = 156
	local badgeH = 20
	local colSpacing = 8

	if #itemSources > 0 then
		self.sourceContainer:Show()
		self.sourceContainer:ClearAllPoints()
		if self.zonesText:IsShown() then
			self.sourceContainer:SetPoint("TOPLEFT", self.zonesText, "BOTTOMLEFT", 0, -8)
		else
			self.sourceContainer:SetPoint("TOPLEFT", self.zonesLabel, "BOTTOMLEFT", 0, -5)
		end

		for gIdx, group in ipairs(itemSources) do
			local hdr = self.sourceHeaders[gIdx]
			if not hdr then
				hdr = CreateFrame("Frame", nil, self.sourceContainer)
				hdr:SetHeight(18)
				hdr:SetWidth(330)

				local prefix = hdr:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				prefix:SetJustifyH("LEFT")
				hdr.prefix = prefix

				local spellBtn = CreateFrame("Button", nil, hdr)
				spellBtn:SetHeight(16)
				local sIcon = spellBtn:CreateTexture(nil, "ARTWORK")
				sIcon:SetSize(14, 14)
				sIcon:SetPoint("LEFT", spellBtn, "LEFT", 0, 0)
				spellBtn.icon = sIcon

				local sText = spellBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				sText:SetPoint("LEFT", sIcon, "RIGHT", 4, 0)
				sText:SetJustifyH("LEFT")
				spellBtn.text = sText

				spellBtn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
				spellBtn:RegisterForClicks("LeftButtonUp")
				hdr.spellBtn = spellBtn

				local suffix = hdr:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
				suffix:SetJustifyH("LEFT")
				hdr.suffix = suffix

				table.insert(self.sourceHeaders, hdr)
			end

			hdr:ClearAllPoints()
			hdr:SetPoint("TOPLEFT", self.sourceContainer, "TOPLEFT", 0, -curSourceY)
			hdr:Show()

			if group.spellID then
				local sID = group.spellID
				hdr.prefix:ClearAllPoints()
				hdr.prefix:SetPoint("LEFT", hdr, "LEFT", 0, 0)
				hdr.prefix:SetText(group.prefix or "")
				hdr.prefix:Show()

				hdr.spellBtn:ClearAllPoints()
				hdr.spellBtn:SetPoint("LEFT", hdr.prefix, "RIGHT", 4, 0)
				hdr.spellBtn.icon:SetTexture(group.spellIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
				hdr.spellBtn.text:SetText(string.format("|cff71d5ff[%s]|r", group.spellName or "Spell"))
				local btnWidth = 14 + 4 + hdr.spellBtn.text:GetStringWidth() + 2
				hdr.spellBtn:SetSize(btnWidth, 16)
				hdr.spellBtn:Show()

				hdr.spellBtn:SetScript("OnEnter", function(b)
					GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
					local link = (GetSpellLink and GetSpellLink(sID))
					if link then
						GameTooltip:SetHyperlink(link)
					elseif GameTooltip.SetSpellByID then
						GameTooltip:SetSpellByID(sID)
					elseif GameTooltip.SetHyperlink then
						GameTooltip:SetHyperlink("spell:" .. sID)
					end
					GameTooltip:Show()
				end)
				hdr.spellBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
				hdr.spellBtn:SetScript("OnClick", function(b)
					if IsModifiedClick("CHATLINK") then
						local link = (GetSpellLink and GetSpellLink(sID))
						if not link then
							local sName = GetSpellInfo(sID)
							if sName then
								link = string.format("|cff71d5ff|Hspell:%d|h[%s]|h|r", sID, sName)
							end
						end
						if link then
							ChatEdit_InsertLink(link)
						end
					end
				end)

				if group.suffix and group.suffix ~= "" then
					hdr.suffix:ClearAllPoints()
					hdr.suffix:SetPoint("LEFT", hdr.spellBtn, "RIGHT", 4, 0)
					hdr.suffix:SetText(group.suffix)
					hdr.suffix:Show()
				else
					hdr.suffix:Hide()
				end

				curSourceY = curSourceY + 18 + 4
			else
				hdr.prefix:ClearAllPoints()
				hdr.prefix:SetPoint("LEFT", hdr, "LEFT", 0, 0)
				hdr.prefix:SetText(group.title or group.prefix or "")
				hdr.prefix:Show()
				hdr.spellBtn:Hide()
				hdr.suffix:Hide()

				curSourceY = curSourceY + hdr.prefix:GetStringHeight() + 4
			end

			if group.items and #group.items > 0 then
				for i, itemId in ipairs(group.items) do
					local btn = self.sourceButtons[nextBadgeIdx]
					if not btn then
						btn = CreateFrame("Button", nil, self.sourceContainer)
						btn:SetHeight(badgeH)
						local icon = btn:CreateTexture(nil, "ARTWORK")
						icon:SetSize(16, 16)
						icon:SetPoint("LEFT", btn, "LEFT", 0, 0)
						btn.icon = icon

						local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
						text:SetPoint("LEFT", icon, "RIGHT", 4, 0)
						text:SetPoint("RIGHT", btn, "RIGHT", -2, 0)
						text:SetJustifyH("LEFT")
						text:SetWordWrap(false)
						btn.text = text

						btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
						btn:RegisterForClicks("LeftButtonUp")
						table.insert(self.sourceButtons, btn)
					end

					local yd = AtlasJournal:GetItemDetails(itemId)
					local q = yd.quality or 1
					local color = ITEM_QUALITY_COLORS[q]
					local hex = color and color.hex or "|cffffffff"
					if not hex:find("^|c") then hex = "|c" .. hex end
					local cleanName = yd.name or string.format("Item #%d", itemId)
					local badgeLabel
					if group.itemCount and #group.items == 1 and group.itemCount > 1 then
						badgeLabel = string.format("%dx [%s%s|r]", group.itemCount, hex, cleanName)
					else
						badgeLabel = string.format("[%s%s|r]", hex, cleanName)
					end

					btn.icon:SetTexture(yd.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
					btn.text:SetText(badgeLabel)

					local col = (i - 1) % 2
					local row = math.floor((i - 1) / 2)
					btn:ClearAllPoints()
					btn:SetPoint("TOPLEFT", self.sourceContainer, "TOPLEFT", col * (badgeW + colSpacing), -(curSourceY + row * (badgeH + 4)))
					btn:SetSize(badgeW, badgeH)
					btn:Show()

					btn:SetScript("OnEnter", function(b)
						GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
						if yd.link then
							GameTooltip:SetHyperlink(yd.link)
						else
							GameTooltip:SetItemByID(itemId)
						end
						GameTooltip:Show()
					end)
					btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
					btn:SetScript("OnClick", function(b)
						if IsModifiedClick("CHATLINK") and yd.link then
							ChatEdit_InsertLink(yd.link)
						else
							local targetRes = AtlasJournal:FindResource(itemId)
							if targetRes then
								Tab:SelectResource(targetRes)
							end
						end
					end)

					nextBadgeIdx = nextBadgeIdx + 1
				end

				local totalRows = math.ceil(#group.items / 2)
				curSourceY = curSourceY + totalRows * (badgeH + 4) + 6
			else
				curSourceY = curSourceY + 2
			end
		end
		self.sourceContainer:SetHeight(curSourceY)
	else
		self.sourceContainer:Hide()
		self.sourceContainer:SetHeight(0)
	end

	-- Format Yields (Strict 2-Column Grid: max 2 yields per row)
	for _, btn in ipairs(self.yieldButtons or {}) do
		btn:Hide()
	end
	if res.yields and #res.yields > 0 then
		self.yieldsLabel:Show()
		self.yieldsContainer:Show()
		self.yieldsLabel:ClearAllPoints()
		if self.sourceContainer:IsShown() then
			self.yieldsLabel:SetPoint("TOPLEFT", self.sourceContainer, "BOTTOMLEFT", 0, -12)
		elseif self.zonesText:IsShown() then
			self.yieldsLabel:SetPoint("TOPLEFT", self.zonesText, "BOTTOMLEFT", 0, -12)
		else
			self.yieldsLabel:SetPoint("TOPLEFT", self.zonesLabel, "BOTTOMLEFT", 0, -12)
		end

		local colW = 156
		local colSpacing = 8
		local rowH = 24
		for idx, yId in ipairs(res.yields) do
			local btn = self.yieldButtons[idx]
			if not btn then
				btn = CreateFrame("Button", nil, self.yieldsContainer)
				btn:SetHeight(20)
				local icon = btn:CreateTexture(nil, "ARTWORK")
				icon:SetSize(16, 16)
				icon:SetPoint("LEFT", btn, "LEFT", 0, 0)
				btn.icon = icon

				local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				text:SetPoint("LEFT", icon, "RIGHT", 4, 0)
				text:SetPoint("RIGHT", btn, "RIGHT", -2, 0)
				text:SetJustifyH("LEFT")
				text:SetWordWrap(false)
				btn.text = text

				btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
				btn:RegisterForClicks("LeftButtonUp")
				table.insert(self.yieldButtons, btn)
			end

			local yd = AtlasJournal:GetItemDetails(yId)
			local q = yd.quality or 1
			local color = ITEM_QUALITY_COLORS[q]
			local hex = color and color.hex or "|cffffffff"
			if not hex:find("^|c") then hex = "|c" .. hex end
			local cleanName = yd.name or string.format("Item #%d", yId)

			btn.icon:SetTexture(yd.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
			btn.text:SetText(string.format("[%s%s|r]", hex, cleanName))

			local col = (idx - 1) % 2
			local rowIdx = math.floor((idx - 1) / 2)
			btn:ClearAllPoints()
			btn:SetPoint("TOPLEFT", self.yieldsContainer, "TOPLEFT", col * (colW + colSpacing), -rowIdx * rowH)
			btn:SetSize(colW, 20)
			btn:Show()

			btn:SetScript("OnEnter", function(b)
				GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
				if yd.link then
					GameTooltip:SetHyperlink(yd.link)
				else
					GameTooltip:SetItemByID(yId)
				end
				GameTooltip:Show()
			end)
			btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
			btn:SetScript("OnClick", function(b)
				if IsModifiedClick("CHATLINK") and yd.link then
					ChatEdit_InsertLink(yd.link)
				else
					local targetRes = AtlasJournal:FindResource(yId)
					if targetRes then
						Tab:SelectResource(targetRes)
					end
				end
			end)
		end
		local totalRows = math.ceil(#res.yields / 2)
		local containerHeight = totalRows * rowH
		self.yieldsContainer:SetHeight(containerHeight)
		self.tipsLabel:ClearAllPoints()
		self.tipsLabel:SetPoint("TOPLEFT", self.yieldsContainer, "BOTTOMLEFT", 0, -12)
	else
		self.yieldsLabel:Hide()
		self.yieldsContainer:Hide()
		self.yieldsContainer:SetHeight(0)
		self.tipsLabel:ClearAllPoints()
		if self.sourceContainer:IsShown() then
			self.tipsLabel:SetPoint("TOPLEFT", self.sourceContainer, "BOTTOMLEFT", 0, -12)
		elseif self.zonesText:IsShown() then
			self.tipsLabel:SetPoint("TOPLEFT", self.zonesText, "BOTTOMLEFT", 0, -12)
		else
			self.tipsLabel:SetPoint("TOPLEFT", self.zonesLabel, "BOTTOMLEFT", 0, -12)
		end
	end

	-- Format Farming Tips
	local tip = AtlasJournal:GetTip(res)
	self.tipsText:SetText(tip)

	-- Update Content Height
	local totalHeight = 20
	if self.zonesText:IsShown() then
		totalHeight = totalHeight + self.zonesText:GetStringHeight() + 8
	end
	if self.sourceContainer:IsShown() then
		totalHeight = totalHeight + self.sourceContainer:GetHeight() + 8
	end
	if self.yieldsContainer:IsShown() then
		totalHeight = totalHeight + 25 + self.yieldsContainer:GetHeight() + 8
	end
	totalHeight = totalHeight + 25 + self.tipsText:GetStringHeight() + 30
	self.rightContent:SetHeight(totalHeight)
	if self.rightScroll then
		self.rightScroll:SetVerticalScroll(0)
		if self.rightScroll.ScrollBar then
			self.rightScroll.ScrollBar:SetValue(0)
		end
		if self.rightScroll.UpdateScrollBar then
			self.rightScroll:UpdateScrollBar()
		end
	end
end

function Tab:UpdateTexts()
	if not self.frame then return end
	if self.searchLabel then self.searchLabel:SetText(GSF.L["SEARCH_ATLAS"]) end
	if self.catDropdown then
		local cat = activeCategory or "All"
		UIDropDownMenu_SetText(self.catDropdown, GSF.L["CAT_" .. cat:upper()] or cat)
	end
	if self.atlasViewBtn then self.atlasViewBtn:SetText(GSF.L["VIEW_ATLAS"]) end
	if self.bountyViewBtn then self.bountyViewBtn:SetText(GSF.L["VIEW_BOUNTIES"]) end
	if self.manageGoalsBtn then self.manageGoalsBtn:SetText(GSF.L["MANAGE_GOALS"]) end
	if self.hideCompletedCheck then self.hideCompletedCheck.text:SetText(GSF.L["HIDE_COMPLETED"] or "Hide Completed") end
	if self.zonesLabel then self.zonesLabel:SetText(GSF.L["BEST_FARMING_ZONES"]) end
	if self.yieldsLabel then self.yieldsLabel:SetText(GSF.L["RESOURCE_YIELDS"]) end
	if self.tipsLabel then self.tipsLabel:SetText(GSF.L["FARMING_TIPS"]) end
	if self.pinBtn then self.pinBtn:SetText(GSF.L["PIN_TO_HUD"]) end
	if self.bountyBtn then self.bountyBtn:SetText(GSF.L["POST_BOUNTY_BTN"]) end
	if self.resourcesEmptyText then self.resourcesEmptyText:SetText(GSF.L["NO_RESOURCES_FOUND"] or "Keine passenden Ressourcen gefunden.") end
	if self.bountiesEmptyText then self.bountiesEmptyText:SetText(GSF.L["NO_BOUNTIES_FOUND"] or "Keine passenden Aufträge vorhanden.") end
	if self.goalsEmptyText then self.goalsEmptyText:SetText(GSF.L["NO_GOALS_LISTED"] or "No active personal goals.") end
	if self.setupModal then
		if self.setupModal.titleLabel then self.setupModal.titleLabel:SetText(GSF.L["GOAL_TITLE_LABEL"] or "Title / Label:") end
		if self.setupModal.qtyLabel then self.setupModal.qtyLabel:SetText(GSF.L["QUANTITY"] or "Quantity:") end
		if self.setupModal.noteLabel then self.setupModal.noteLabel:SetText(GSF.L["NOTE"] or "Note:") end
		if self.setupModal.cancelBtn then self.setupModal.cancelBtn:SetText(GSF.L["CANCEL"] or "Cancel") end
	end
	self:Refresh()
end

function Tab:SwitchView(viewName)
	activeView = viewName or "ATLAS"
	self:Refresh()
end

function Tab:GetActiveView()
	return activeView
end

function Tab:Refresh()
	if not self.frame or not self.frame:IsShown() then return end

	if activeView == "ATLAS" then
		if self.goalsHeaderLabel then self.goalsHeaderLabel:Hide() end
		self.atlasContainer:Show()
		self.bountiesContainer:Hide()
		self.goalsContainer:Hide()
		self.searchBox:Show()
		if self.searchBox and self.searchBox.searchHint then
			self.searchBox.searchHint:SetText(GSF.L["SEARCH_ATLAS"] or "Search materials...")
		end
		self.catDropdown:Show()
		if self.hideCompletedCheck then self.hideCompletedCheck:Hide() end
		if self.atlasViewBtn then self.atlasViewBtn:SetText("|cffffd100" .. (GSF.L["VIEW_ATLAS"] or "Resource Atlas") .. "|r") end
		if self.bountyViewBtn then self.bountyViewBtn:SetText("|cffaaaaaa" .. (GSF.L["VIEW_BOUNTIES"] or "Guild Bounties") .. "|r") end
		if self.manageGoalsBtn then self.manageGoalsBtn:SetText("|cffaaaaaa" .. (GSF.L["MANAGE_GOALS"] or "Manage Goals") .. "|r") end
		self:RefreshAtlas()
	elseif activeView == "BOUNTIES" then
		if self.goalsHeaderLabel then self.goalsHeaderLabel:Hide() end
		self.atlasContainer:Hide()
		self.bountiesContainer:Show()
		self.goalsContainer:Hide()
		self.searchBox:Show()
		if self.searchBox and self.searchBox.searchHint then
			self.searchBox.searchHint:SetText(GSF.L["SEARCH_BOUNTIES"] or "Search bounties...")
		end
		self.catDropdown:Show()
		if self.hideCompletedCheck then self.hideCompletedCheck:Show() end
		if self.atlasViewBtn then self.atlasViewBtn:SetText("|cffaaaaaa" .. (GSF.L["VIEW_ATLAS"] or "Resource Atlas") .. "|r") end
		if self.bountyViewBtn then self.bountyViewBtn:SetText("|cffffd100" .. (GSF.L["VIEW_BOUNTIES"] or "Guild Bounties") .. "|r") end
		if self.manageGoalsBtn then self.manageGoalsBtn:SetText("|cffaaaaaa" .. (GSF.L["MANAGE_GOALS"] or "Manage Goals") .. "|r") end
		self:RefreshBounties()
	elseif activeView == "GOALS" then
		self.atlasContainer:Hide()
		self.bountiesContainer:Hide()
		self.goalsContainer:Show()
		self.searchBox:Hide()
		self.catDropdown:Hide()
		if self.hideCompletedCheck then self.hideCompletedCheck:Hide() end
		if self.goalsHeaderLabel then
			local count = GSF.db and GSF.db.myGoals and #GSF.db.myGoals or 0
			self.goalsHeaderLabel:SetText(string.format("|cff%s%s|r  •  |cffaaaaaa%d %s|r", GSF.COLORS.PRIMARY, GSF.L["MY_GOALS_HEADER"] or "Meine Ziele", count, GSF.L["ACTIVE_GOALS_LABEL"] or "aktiv"))
			self.goalsHeaderLabel:Show()
		end
		if self.atlasViewBtn then self.atlasViewBtn:SetText("|cffaaaaaa" .. (GSF.L["VIEW_ATLAS"] or "Resource Atlas") .. "|r") end
		if self.bountyViewBtn then self.bountyViewBtn:SetText("|cffaaaaaa" .. (GSF.L["VIEW_BOUNTIES"] or "Guild Bounties") .. "|r") end
		if self.manageGoalsBtn then self.manageGoalsBtn:SetText("|cffffd100" .. (GSF.L["MANAGE_GOALS"] or "Manage Goals") .. "|r") end
		self:RefreshGoals()
	end
end

function Tab:RefreshAtlas()
	local query = self.searchBox and self.searchBox:GetText() or ""
	local resources = AtlasJournal and AtlasJournal:Search(query, activeCategory) or {}
	self.currentResources = resources

	for _, row in ipairs(self.resourceRows) do row:Hide() end

	local yOffset = 0
	for i, res in ipairs(resources) do
		local row = self.resourceRows[i]
		if not row then
			row = CreateFrame("Button", nil, self.leftContent)
			row:SetSize(280, 28)
			if BackdropTemplateMixin then Mixin(row, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(row, false)
			row:SetBackdropColor(0.08, 0.08, 0.12, 0.6)

			local selBar = row:CreateTexture(nil, "OVERLAY")
			selBar:SetWidth(3)
			selBar:SetPoint("TOPLEFT", row, "TOPLEFT", 1, -1)
			selBar:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 1, 1)
			selBar:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
			selBar:SetVertexColor(1.0, 0.82, 0.0, 1.0)
			selBar:Hide()
			row.selBar = selBar

			local icon = row:CreateTexture(nil, "ARTWORK")
			icon:SetSize(20, 20)
			icon:SetPoint("LEFT", row, "LEFT", 6, 0)
			row.icon = icon

			local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			name:SetPoint("LEFT", icon, "RIGHT", 6, 0)
			name:SetPoint("RIGHT", row, "RIGHT", -40, 0)
			name:SetJustifyH("LEFT")
			row.name = name

			local skill = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			skill:SetPoint("RIGHT", row, "RIGHT", -6, 0)
			row.skill = skill

			table.insert(self.resourceRows, row)
		end

		row.resource = res
		row:SetPoint("TOPLEFT", self.leftContent, "TOPLEFT", 0, -yOffset)
		local details = AtlasJournal:GetItemDetails(res.id)
		local color = ITEM_QUALITY_COLORS[details.quality]
		local hex = color and color.hex or "|cffffffff"
		if not hex:find("^|c") then hex = "|c" .. hex end

		row.icon:SetTexture(details.icon)
		row.name:SetText(string.format("%s%s|r", hex, details.name))
		local minSkill = AtlasJournal:GetMinSkill(res)
		row.skill:SetText(minSkill and string.format("|cffffd100%d|r", minSkill) or "")

		local isSelected = selectedResource and (selectedResource.id == res.id)
		if isSelected then
			row:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
			row:SetBackdropColor(0.20, 0.16, 0.04, 0.85)
			if row.selBar then row.selBar:Show() end
		else
			row:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.5)
			row:SetBackdropColor(0.08, 0.08, 0.12, 0.6)
			if row.selBar then row.selBar:Hide() end
		end

		row:SetScript("OnEnter", function(selfRow)
			if not (selectedResource and selectedResource.id == res.id) then
				selfRow:SetBackdropBorderColor(0.6, 0.6, 0.7, 0.8)
				selfRow:SetBackdropColor(0.12, 0.12, 0.18, 0.7)
			end
			GameTooltip:SetOwner(selfRow, "ANCHOR_RIGHT")
			if details.link then
				GameTooltip:SetHyperlink(details.link)
			else
				GameTooltip:SetItemByID(res.id)
			end
			GameTooltip:Show()
		end)
		row:SetScript("OnLeave", function(selfRow)
			if not (selectedResource and selectedResource.id == res.id) then
				selfRow:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.5)
				selfRow:SetBackdropColor(0.08, 0.08, 0.12, 0.6)
			end
			GameTooltip:Hide()
		end)

		row:SetScript("OnClick", function()
			Tab:SelectResource(res)
		end)

		row:Show()
		yOffset = yOffset + 30
	end

	self.leftContent:SetHeight(math.max(yOffset, 1))
	if self.leftScroll and self.leftScroll.UpdateScrollBar then
		self.leftScroll:UpdateScrollBar()
	end

	if #resources == 0 then
		if self.resourcesEmptyText then self.resourcesEmptyText:Show() end
		selectedResource = nil
		if self.pinBtn then self.pinBtn:Disable() end
		if self.bountyBtn then self.bountyBtn:Disable() end
		if self.detailTitle then self.detailTitle:SetText(GSF.L["SELECT_RESOURCE_PROMPT"] or "Select a resource to view farming data") end
		if self.detailSub then self.detailSub:SetText("") end
		if self.detailIcon then self.detailIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") end
		if self.zonesText then self.zonesText:SetText("") end
		if self.yieldsText then self.yieldsText:SetText("") end
		if self.tipsText then self.tipsText:SetText("") end
	else
		if self.resourcesEmptyText then self.resourcesEmptyText:Hide() end
		local keepSelected = false
		if selectedResource then
			for _, r in ipairs(resources) do
				if r.id == selectedResource.id then
					keepSelected = true
					break
				end
			end
		end
		if keepSelected then
			self:SelectResource(selectedResource)
		else
			self:SelectResource(resources[1])
		end
	end
end

function Tab:RefreshBounties()
	local myName = GSF.DB:GetPlayerName()
	local bounties = GSF.SupplyBounties:GetActiveBounties(activeCategory)
	local query = self.searchBox and self.searchBox:GetText():lower():trim() or ""
	if query ~= "" then
		local filtered = {}
		for _, b in ipairs(bounties) do
			local itemMatch = b.item and b.item:lower():find(query, 1, true)
			local reqMatch = b.requester and b.requester:lower():find(query, 1, true)
			local noteMatch = b.notes and b.notes:lower():find(query, 1, true)
			if itemMatch or reqMatch or noteMatch then
				table.insert(filtered, b)
			end
		end
		bounties = filtered
	end

	local hideCompleted = self.hideCompletedCheck and self.hideCompletedCheck:GetChecked()

	for _, card in ipairs(self.bountyCards) do card:Hide() end

	local yOffset = 0
	local visibleIndex = 0
	for _, b in ipairs(bounties) do
		if not (hideCompleted and b.status == GSF.ORDER_STATUS.COMPLETED) then
			visibleIndex = visibleIndex + 1
			local card = self.bountyCards[visibleIndex]
			if not card then
				card = CreateFrame("Frame", nil, self.bountyContent)
				card:SetSize(660, 72)
				if BackdropTemplateMixin then Mixin(card, BackdropTemplateMixin) end
				GSF.UI:CreateBackdrop(card, false)
				card:SetBackdropColor(0.10, 0.10, 0.14, 0.75)
				card:EnableMouse(true)

				local iconSlot = GSF.UI:CreateItemSlot(card, 36)
				iconSlot:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -10)
				iconSlot:SetScript("OnReceiveDrag", nil)
				iconSlot:SetScript("OnClick", nil)
				iconSlot.noDropHint = true
				card.iconSlot = iconSlot

				local statusText = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				statusText:SetPoint("TOPRIGHT", card, "TOPRIGHT", -12, -10)
				statusText:SetJustifyH("RIGHT")
				card.statusText = statusText

				local itemText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
				itemText:SetPoint("TOPLEFT", iconSlot, "TOPRIGHT", 10, -1)
				itemText:SetPoint("RIGHT", statusText, "LEFT", -10, 0)
				itemText:SetJustifyH("LEFT")
				itemText:SetWordWrap(false)
				card.itemText = itemText

				local details = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				details:SetPoint("TOPLEFT", itemText, "BOTTOMLEFT", 0, -3)
				details:SetPoint("RIGHT", card, "RIGHT", -12, 0)
				details:SetJustifyH("LEFT")
				details:SetWordWrap(false)
				card.details = details

				local bagText = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				bagText:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 56, 12)
				bagText:SetJustifyH("LEFT")
				card.bagText = bagText

				local actionBtn = GSF.UI:CreateButton(card, GSF.L["CLAIM_BOUNTY"] or "Claim", 80, 22)
				actionBtn:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -12, 8)
				card.actionBtn = actionBtn

				local editBtn = GSF.UI:CreateButton(card, GSF.L["EDIT"] or "Edit", 75, 22)
				editBtn:SetPoint("RIGHT", actionBtn, "LEFT", -6, 0)
				card.editBtn = editBtn

				local cancelBtn = GSF.UI:CreateButton(card, GSF.L["CANCEL_ORDER"] or "Cancel", 75, 22)
				cancelBtn:SetPoint("RIGHT", editBtn, "LEFT", -6, 0)
				card.cancelBtn = cancelBtn

				local mailBtn = GSF.UI:CreateButton(card, GSF.L["MAIL"] or "Mail", 65, 22)
				mailBtn:SetPoint("RIGHT", actionBtn, "LEFT", -6, 0)
				card.mailBtn = mailBtn

				local unclaimBtn = GSF.UI:CreateButton(card, GSF.L["UNCLAIM_ORDER"] or "Release", 75, 22)
				unclaimBtn:SetPoint("RIGHT", mailBtn, "LEFT", -6, 0)
				card.unclaimBtn = unclaimBtn

				card:SetScript("OnEnter", function(self)
					if self.bountyData and self.bountyData.notes and self.bountyData.notes ~= "" then
						local noteHdr = (GSF.L["NOTE"] or "Note"):gsub("[:%s]+$", "")
						GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
						GameTooltip:AddLine(self.bountyData.item, 1, 0.82, 0)
						GameTooltip:AddLine(string.format("%s: %s", noteHdr, self.bountyData.notes), 1, 1, 1, true)
						GameTooltip:Show()
					end
				end)
				card:SetScript("OnLeave", function() GameTooltip:Hide() end)

				table.insert(self.bountyCards, card)
			end

			card:SetPoint("TOPLEFT", self.bountyContent, "TOPLEFT", 0, -yOffset)

			local isHighlighted = (self.highlightedBountyId and tostring(self.highlightedBountyId) == tostring(b.id))
			if isHighlighted then
				card:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
				card:SetBackdropColor(0.24, 0.18, 0.06, 0.92)
				if not card.highlightGlow then
					local glow = card:CreateTexture(nil, "OVERLAY", nil, 6)
					glow:SetAllPoints()
					glow:SetColorTexture(1.0, 0.82, 0.0, 0.12)
					card.highlightGlow = glow
				end
				card.highlightGlow:Show()

				if self.bountyScroll then
					local cardPos = yOffset
					C_Timer.After(0.02, function()
						local maxRange = self.bountyScroll:GetVerticalScrollRange() or 0
						if maxRange > 0 then
							local currentScroll = self.bountyScroll:GetVerticalScroll() or 0
							local viewHeight = self.bountyScroll:GetHeight() or 360
							local cardTop = cardPos
							local cardBottom = cardPos + 72

							-- Only scroll if not already comfortably visible inside viewport
							if cardTop < currentScroll or cardBottom > (currentScroll + viewHeight) then
								local targetScroll = math.min(math.max(0, cardTop - 12), maxRange)
								self.bountyScroll:SetVerticalScroll(targetScroll)
								if self.bountyScroll.ScrollBar and self.bountyScroll.ScrollBar.SetValue then
									self.bountyScroll.ScrollBar:SetValue(targetScroll)
								end
							end
						else
							-- List fits entirely without scrolling; keep scroll at top
							self.bountyScroll:SetVerticalScroll(0)
							if self.bountyScroll.ScrollBar and self.bountyScroll.ScrollBar.SetValue then
								self.bountyScroll.ScrollBar:SetValue(0)
							end
						end
					end)
				end
			else
				card:SetBackdropBorderColor(0.25, 0.25, 0.35, 0.6)
				card:SetBackdropColor(0.10, 0.10, 0.14, 0.75)
				if card.highlightGlow then
					card.highlightGlow:Hide()
				end
			end

			local isMine = (b.requester == myName)
			local isClaimer = (b.claimer == myName)
			local reqFormatted = GSF.Alts:GetFormattedName(b.requester)
			local catKey = (b.category or "GENERAL"):upper()
			local catLoc = (AtlasJournal and AtlasJournal:GetCategoryInfo(b.category)) or (GSF.L and GSF.L["CAT_" .. catKey]) or (GSF.GetLocalizedProfession and GSF:GetLocalizedProfession(b.category)) or b.category or "General"
			
			local numId = b.itemId or (b.itemLink and tonumber(b.itemLink:match("item:(%d+)"))) or (b.item and tonumber(b.item:match("item:(%d+)")))
			local _, itemLink, quality, _, _, _, _, _, _, texture = GetItemInfo(b.itemLink or numId or b.item)

			if not texture and b.icon and not IsPlaceholderIcon(b.icon) then
				texture = b.icon
			end
			if not texture and numId and AtlasJournal and AtlasJournal.GetItemDetails then
				local d = AtlasJournal:GetItemDetails(numId)
				if d and d.icon then
					texture = d.icon
					itemLink = itemLink or d.link
					quality = quality or d.quality
				end
			end
			if not texture and AtlasJournal and AtlasJournal.FindResource then
				local res = AtlasJournal:FindResource(b.item)
				if res then
					local d = AtlasJournal:GetItemDetails(res.id)
					if d and d.icon then
						texture = d.icon
						itemLink = itemLink or d.link
						quality = quality or d.quality
					end
				end
			end

			local fallbackIcon = texture or "Interface\\Icons\\INV_Misc_QuestionMark"
			card.iconSlot:SetItem(b.item, fallbackIcon, itemLink or b.itemLink, numId)

			if (not texture or IsPlaceholderIcon(fallbackIcon)) and numId and numId >= 100 and C_Item and C_Item.RequestLoadItemDataByID then
				C_Item.RequestLoadItemDataByID(numId)
				local itm = Item and Item:CreateFromItemID(numId)
				if itm and not itm:IsItemEmpty() then
					pcall(function()
						itm:ContinueOnItemLoad(function()
							local t = itm:GetItemIcon()
							local l = itm:GetItemLink()
							if t and card.iconSlot then
								card.iconSlot:SetItem(b.item, t, l or b.itemLink, numId)
							end
						end)
					end)
				end
			end

			local qColor = quality and ITEM_QUALITY_COLORS[quality]
			local hex = qColor and qColor.hex or ("|cff" .. GSF.COLORS.PRIMARY)
			if not hex:find("^|c") then hex = "|c" .. hex end

			card.itemText:SetText(string.format("%s%s|r x%d (|cffffd100%s|r)", hex, b.item, b.count or 1, catLoc))
			
			card.bountyData = b
			local noteStr = (b.notes and b.notes ~= "") and b.notes or (GSF.L["NONE"] or "None")
			local reqPrefix = GSF.L["REQUESTED_BY_LABEL"] and string.format(GSF.L["REQUESTED_BY_LABEL"], reqFormatted) or ("Requested by: " .. reqFormatted)
			local notePrefix = GSF.L["NOTE_LABEL"] and string.format(GSF.L["NOTE_LABEL"], noteStr) or ("Note: " .. noteStr)
			card.details:SetText(string.format("%s  •  %s", reqPrefix, notePrefix))

			card.bagText:Hide()
			card.actionBtn:Hide()
			card.editBtn:Hide()
			card.cancelBtn:Hide()
			card.mailBtn:Hide()
			card.unclaimBtn:Hide()

			if b.status == GSF.ORDER_STATUS.OPEN then
				card.statusText:SetText("|cff00ff00" .. (GSF.L["STATUS_OPEN"] or "OPEN") .. "|r")
				card.actionBtn:SetText(GSF.L["CLAIM_BOUNTY"] or "Claim")
				card.actionBtn:SetScript("OnClick", function()
					GSF.SupplyBounties:ClaimBounty(b.id)
					Tab:Refresh()
				end)
				card.actionBtn:Show()

				if isMine then
					card.editBtn:SetText(GSF.L["EDIT"] or "Edit")
					card.editBtn:SetScript("OnClick", function()
						Tab:OpenBountyEditModal(b)
					end)
					card.editBtn:Show()

					card.cancelBtn:SetText(GSF.L["CANCEL_ORDER"] or "Cancel")
					card.cancelBtn:SetScript("OnClick", function()
						GSF.SupplyBounties:CancelBounty(b.id)
						Tab:Refresh()
					end)
					card.cancelBtn:Show()
				end

			elseif b.status == GSF.ORDER_STATUS.CLAIMED then
				local claimerFormatted = GSF.Alts:GetFormattedName(b.claimer)
				card.statusText:SetText(string.format("|cffffd100" .. (GSF.L["STATUS_CLAIMED"] or "CLAIMED") .. "|r (%s)", claimerFormatted))

				if isClaimer then
					local reqCount = b.count or 1
					local myBagCount = 0
					if GSF.GoalsHUD and GSF.GoalsHUD.CountItemInBags then
						myBagCount = GSF.GoalsHUD:CountItemInBags(b.item, numId)
					else
						myBagCount = GetItemCount(numId or b.item) or 0
					end
					local bagColor = (myBagCount >= reqCount) and "|cff00ff00" or "|cffff7f00"
					card.bagText:SetText(string.format(GSF.L["IN_BAGS_PROGRESS"] or "In Bags: %s%d/%d|r", bagColor, myBagCount, reqCount))
					card.bagText:Show()

					if isMine then
						-- Self-Claimed Bounty (User is both requester & gatherer)
						card.actionBtn:SetText(GSF.L["COMPLETE_ORDER"] or "Complete")
						card.actionBtn:SetScript("OnClick", function()
							if myBagCount < reqCount then
								local warnText = string.format(GSF.L["CONFIRM_FULFILL_INSUFFICIENT"] or "You only have %s%d of %d|r %s in your bags.\n\nDo you still want to mark this bounty as completed?", bagColor, myBagCount, reqCount, b.item)
								StaticPopup_Show("GSF_CONFIRM_FULFILL_BOUNTY_INSUFFICIENT", warnText, nil, { bountyId = b.id, isDeliver = false })
							else
								GSF.SupplyBounties:FulfillBounty(b.id)
								Tab:Refresh()
							end
						end)
						card.actionBtn:Show()
					else
						-- Third-Party Gatherer fulfilling someone else's bounty
						card.actionBtn:SetText(GSF.L["MARK_DELIVERED"] or "Delivered")
						card.actionBtn:SetScript("OnClick", function()
							if myBagCount < reqCount then
								local warnText = string.format(GSF.L["CONFIRM_FULFILL_INSUFFICIENT"] or "You only have %s%d of %d|r %s in your bags.\n\nDo you still want to mark this bounty as completed?", bagColor, myBagCount, reqCount, b.item)
								StaticPopup_Show("GSF_CONFIRM_FULFILL_BOUNTY_INSUFFICIENT", warnText, nil, { bountyId = b.id, isDeliver = true })
							else
								GSF.SupplyBounties:MarkBountyDelivered(b.id, "TRADE")
								Tab:Refresh()
							end
						end)
						card.actionBtn:Show()

						card.mailBtn:SetText(GSF.L["MAIL"] or "Mail")
						card.mailBtn:SetScript("OnClick", function()
							if GSF.MailHelper then
								GSF.MailHelper:PrepareBountyMail(b.requester, b.id, b.item, b.count)
							end
						end)
						card.mailBtn:Show()
					end

					card.unclaimBtn:SetText(GSF.L["UNCLAIM_ORDER"] or "Release")
					card.unclaimBtn:SetScript("OnClick", function()
						GSF.SupplyBounties:UnclaimBounty(b.id)
						Tab:Refresh()
					end)
					card.unclaimBtn:Show()
				elseif isMine then
					card.actionBtn:SetText(GSF.L["CANCEL_ORDER"] or "Cancel")
					card.actionBtn:SetScript("OnClick", function()
						GSF.SupplyBounties:CancelBounty(b.id)
						Tab:Refresh()
					end)
					card.actionBtn:Show()
				end

			elseif b.status == GSF.ORDER_STATUS.IN_TRANSIT then
				local mins = math.floor((time() - (b.mailedAt or time())) / 60)
				local isTrade = (b.deliveryType == "TRADE" or b.deliveryType == "DIRECT")
				if isTrade then
					card.statusText:SetText(string.format("|cff00ccff[%s]|r (%s)", GSF.L["DELIVERY_TRADE"] or "Geliefert", GSF.Alts:GetFormattedName(b.claimer or "?")))
				else
					card.statusText:SetText(string.format("|cff00ccff[Mail] %s (%dm)|r", GSF.L["STATUS_IN_TRANSIT"] or "IN TRANSIT", mins))
				end

				if isMine then
					card.actionBtn:SetText(GSF.L["CONFIRM_RECEIVED"] or "Confirm Received")
					card.actionBtn:SetScript("OnClick", function()
						GSF.SupplyBounties:FulfillBounty(b.id)
						Tab:Refresh()
					end)
					card.actionBtn:Show()

					card.cancelBtn:SetText(GSF.L["NOT_RECEIVED"] or "Not Received")
					card.cancelBtn:SetScript("OnClick", function()
						GSF.SupplyBounties:RejectBountyDelivery(b.id)
						Tab:Refresh()
					end)
					card.cancelBtn:Show()
				elseif isClaimer then
					card.unclaimBtn:SetText(GSF.L["UNCLAIM_ORDER"] or "Release")
					card.unclaimBtn:SetScript("OnClick", function()
						GSF.SupplyBounties:UnclaimBounty(b.id)
						Tab:Refresh()
					end)
					card.unclaimBtn:Show()
				end

			elseif b.status == GSF.ORDER_STATUS.COMPLETED then
				card.statusText:SetText("|cff00ff00" .. (GSF.L["STATUS_COMPLETED"] or "COMPLETED") .. "|r")
				if isMine then
					card.actionBtn:SetText(GSF.L["DISMISS_BOUNTY"] or "Dismiss")
					card.actionBtn:SetScript("OnClick", function()
						GSF.SupplyBounties:DismissBounty(b.id)
						Tab:Refresh()
					end)
					card.actionBtn:Show()
				end
			end

			card:Show()
			yOffset = yOffset + 78
		end
	end

	if visibleIndex == 0 then
		if self.bountiesEmptyText then self.bountiesEmptyText:Show() end
	else
		if self.bountiesEmptyText then self.bountiesEmptyText:Hide() end
	end

	self.bountyContent:SetHeight(math.max(yOffset, 1))
	if self.bountyScroll and self.bountyScroll.UpdateScrollBar then
		self.bountyScroll:UpdateScrollBar()
	end
end

function Tab:GetDragFrames()
	if not self.dragGhost then
		local ghost = CreateFrame("Frame", nil, UIParent)
		ghost:SetSize(220, 34)
		ghost:SetFrameStrata("TOOLTIP")
		ghost:SetClampedToScreen(true)
		ghost:EnableMouse(false)
		if BackdropTemplateMixin then Mixin(ghost, BackdropTemplateMixin) end
		GSF.UI:CreateBackdrop(ghost, false)
		ghost:SetBackdropColor(0.12, 0.12, 0.16, 0.92)
		ghost:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)

		local icon = ghost:CreateTexture(nil, "ARTWORK")
		icon:SetSize(24, 24)
		icon:SetPoint("LEFT", ghost, "LEFT", 5, 0)
		ghost.icon = icon

		local text = ghost:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		text:SetPoint("LEFT", icon, "RIGHT", 8, 0)
		text:SetPoint("RIGHT", ghost, "RIGHT", -6, 0)
		text:SetJustifyH("LEFT")
		text:SetWordWrap(false)
		ghost.text = text

		ghost:Hide()
		self.dragGhost = ghost
	end

	if not self.dropLine then
		local line = CreateFrame("Frame", nil, self.goalContent)
		line:SetSize(650, 4)
		line:SetFrameStrata("HIGH")
		local tex = line:CreateTexture(nil, "OVERLAY")
		tex:SetAllPoints()
		tex:SetColorTexture(1.0, 0.82, 0.0, 0.95)
		line.tex = tex
		line:Hide()
		self.dropLine = line
	end

	return self.dragGhost, self.dropLine
end

function Tab:StartDraggingGoal(sourceIndex, goal)
	local ghost, dropLine = self:GetDragFrames()
	self.isDraggingGoal = true
	self.draggedGoalIndex = sourceIndex
	self.targetDropIndex = sourceIndex

	for _, r in ipairs(self.goalRows or {}) do
		if r.goalIndex == sourceIndex then
			r:SetAlpha(0.35)
		else
			r:SetAlpha(1.0)
		end
	end

	local dispTitle = goal.title or goal.name or "Resource"
	ghost.text:SetText(string.format("|cffffd100%s|r (%d)", dispTitle, goal.target or 1))

	local iconTex = goal.icon
	if IsPlaceholderIcon(iconTex) and (goal.itemID or goal.material or goal.name) then
		if goal.itemID then
			local _, _, _, _, _, _, _, _, _, t = GetItemInfo(goal.itemID)
			if t then iconTex = t end
		end
		if IsPlaceholderIcon(iconTex) then
			local res = AtlasJournal and AtlasJournal:FindResource(goal.material or goal.name)
			if res then
				local d = AtlasJournal:GetItemDetails(res.id)
				if d and d.icon then iconTex = d.icon end
			end
		end
	end
	ghost.icon:SetTexture(iconTex or "Interface\\Icons\\INV_Misc_QuestionMark")
	ghost:Show()

	ghost:SetScript("OnUpdate", function()
		Tab:UpdateDraggingGoal()
	end)

	Tab:UpdateDraggingGoal()
end

function Tab:UpdateDraggingGoal()
	if not self.isDraggingGoal then return end
	local ghost, dropLine = self:GetDragFrames()
	local rawX, rawY = GetCursorPosition()
	local uiScale = UIParent:GetEffectiveScale()
	local cursorX = rawX / uiScale
	local cursorY = rawY / uiScale

	ghost:ClearAllPoints()
	ghost:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", cursorX + 12, cursorY - 16)

	local visibleRows = {}
	for _, r in ipairs(self.goalRows or {}) do
		if r:IsShown() and r:GetTop() and r:GetBottom() then
			table.insert(visibleRows, r)
		end
	end

	if #visibleRows == 0 then
		dropLine:Hide()
		return
	end

	local rowScale = visibleRows[1]:GetEffectiveScale()
	local scaledY = rawY / rowScale

	local bestTarget = 1
	local anchorRow = visibleRows[1]
	local anchorPoint = "TOP"

	local firstTop = visibleRows[1]:GetTop()
	local lastBottom = visibleRows[#visibleRows]:GetBottom()

	if scaledY >= firstTop then
		bestTarget = 1
		anchorRow = visibleRows[1]
		anchorPoint = "TOP"
	elseif scaledY <= lastBottom then
		bestTarget = #visibleRows
		anchorRow = visibleRows[#visibleRows]
		anchorPoint = "BOTTOM"
	else
		for idx, r in ipairs(visibleRows) do
			local rTop = r:GetTop()
			local rBottom = r:GetBottom()
			local rMid = (rTop + rBottom) / 2

			if scaledY >= rBottom and scaledY <= rTop then
				if scaledY >= rMid then
					if self.draggedGoalIndex < idx then
						bestTarget = idx - 1
					else
						bestTarget = idx
					end
					anchorRow = r
					anchorPoint = "TOP"
				else
					if self.draggedGoalIndex > idx then
						bestTarget = idx + 1
					else
						bestTarget = idx
					end
					anchorRow = r
					anchorPoint = "BOTTOM"
				end
				break
			elseif idx < #visibleRows then
				local nextRow = visibleRows[idx + 1]
				local gapTop = rBottom
				local gapBottom = nextRow:GetTop()
				if scaledY <= gapTop and scaledY >= gapBottom then
					if self.draggedGoalIndex > idx then
						bestTarget = idx + 1
					else
						bestTarget = idx
					end
					anchorRow = r
					anchorPoint = "BOTTOM"
					break
				end
			end
		end
	end

	bestTarget = math.max(1, math.min(bestTarget, #visibleRows))
	self.targetDropIndex = bestTarget

	dropLine:ClearAllPoints()
	if anchorPoint == "TOP" then
		dropLine:SetPoint("CENTER", anchorRow, "TOP", 0, 2)
	else
		dropLine:SetPoint("CENTER", anchorRow, "BOTTOM", 0, -2)
	end
	dropLine:Show()

	for _, r in ipairs(visibleRows) do
		if r == anchorRow then
			r:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.9)
		else
			r:SetBackdropBorderColor(0.2, 0.8, 0.4, 0.3)
		end
	end
end

function Tab:StopDraggingGoal()
	if not self.isDraggingGoal then return end
	local ghost, dropLine = self:GetDragFrames()

	self.isDraggingGoal = false
	ghost:SetScript("OnUpdate", nil)
	ghost:Hide()
	dropLine:Hide()

	for _, r in ipairs(self.goalRows or {}) do
		r:SetAlpha(1.0)
		r:SetBackdropBorderColor(0.2, 0.8, 0.4, 0.3)
	end

	local source = self.draggedGoalIndex
	local target = self.targetDropIndex

	self.draggedGoalIndex = nil
	self.targetDropIndex = nil

	if source and target and source ~= target then
		GSF.GoalsHUD:ReorderGoal(source, target)
		Tab:RefreshGoals()
	end
end

function Tab:HighlightBounty(bountyId)
	if not bountyId then return end
	self.highlightedBountyId = tostring(bountyId)
	self:SwitchView("BOUNTIES")

	-- Clear search and reset category so the bounty is always visible
	if self.searchBox and self.searchBox:GetText() ~= "" then
		self.searchBox:SetText("")
	end
	if self.selectedCategory and self.selectedCategory ~= "ALL" and self.catDropdown then
		self.selectedCategory = "ALL"
		UIDropDownMenu_SetText(self.catDropdown, GSF.L["CAT_ALL"] or "All Categories")
	end

	self:RefreshBounties()

	if self.highlightTimer then
		self.highlightTimer:Cancel()
		self.highlightTimer = nil
	end
	self.highlightTimer = C_Timer.NewTimer(3.0, function()
		self.highlightedBountyId = nil
		self.highlightTimer = nil
		if activeView == "BOUNTIES" and self.frame and self.frame:IsShown() then
			self:RefreshBounties()
		end
	end)
end

function Tab:RefreshGoals()
	if not self.goalContent then return end
	if not GSF.db or not GSF.db.myGoals then return end

	local goals = GSF.db.myGoals
	for _, r in ipairs(self.goalRows) do r:Hide() end

	if #goals == 0 then
		if self.goalsEmptyText then self.goalsEmptyText:Show() end
	else
		if self.goalsEmptyText then self.goalsEmptyText:Hide() end
	end

	local remainingCounts = {}
	local yOffset = 0

	for i, goal in ipairs(goals) do
		local row = self.goalRows[i]
		if not row then
			row = CreateFrame("Frame", nil, self.goalContent)
			row:SetSize(660, 52)
			if BackdropTemplateMixin then Mixin(row, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(row, false)
			row:SetBackdropColor(0.10, 0.10, 0.14, 0.75)
			row:EnableMouse(true)
			row:SetScript("OnMouseUp", function()
				if Tab.isDraggingGoal then
					Tab:StopDraggingGoal()
				end
			end)

			-- Drag Handle
			local grip = CreateFrame("Button", nil, row)
			grip:SetSize(18, 36)
			grip:SetPoint("LEFT", row, "LEFT", 6, 0)
			local gripText = grip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			gripText:SetPoint("CENTER", grip, "CENTER", 0, 0)
			gripText:SetText("|cff888888::|r")
			grip:RegisterForDrag("LeftButton")
			grip:SetScript("OnDragStart", function(selfGrip)
				local pRow = selfGrip:GetParent()
				local g = GSF.db and GSF.db.myGoals and GSF.db.myGoals[pRow.goalIndex]
				if g then
					Tab:StartDraggingGoal(pRow.goalIndex, g)
				end
			end)
			grip:SetScript("OnDragStop", function()
				Tab:StopDraggingGoal()
			end)
			grip:SetScript("OnMouseUp", function()
				Tab:StopDraggingGoal()
			end)
			grip:SetScript("OnEnter", function() gripText:SetText("|cffffd100::|r") end)
			grip:SetScript("OnLeave", function() gripText:SetText("|cff888888::|r") end)
			row.grip = grip

			-- Up / Down Buttons
			local upBtn = CreateFrame("Button", nil, row)
			upBtn:SetSize(22, 16)
			upBtn:SetPoint("LEFT", grip, "RIGHT", 4, 9)
			upBtn:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
			upBtn:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down")
			upBtn:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Disabled")
			upBtn:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Highlight")
			row.upBtn = upBtn

			local downBtn = CreateFrame("Button", nil, row)
			downBtn:SetSize(22, 16)
			downBtn:SetPoint("LEFT", grip, "RIGHT", 4, -9)
			downBtn:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
			downBtn:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down")
			downBtn:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Disabled")
			downBtn:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight")
			row.downBtn = downBtn

			-- Item Icon
			local iconBtn = CreateFrame("Button", nil, row)
			iconBtn:SetSize(36, 36)
			iconBtn:SetPoint("LEFT", upBtn, "RIGHT", 8, -9)
			local icon = iconBtn:CreateTexture(nil, "ARTWORK")
			icon:SetAllPoints()
			row.icon = icon
			row.iconBtn = iconBtn

			-- Action Buttons
			local removeBtn = GSF.UI:CreateButton(row, GSF.L["REMOVE"] or "Entfernen", 75, 22)
			removeBtn:SetPoint("RIGHT", row, "RIGHT", -10, 0)
			row.removeBtn = removeBtn

			local editBtn = GSF.UI:CreateButton(row, GSF.L["EDIT"] or "Bearbeiten", 75, 22)
			editBtn:SetPoint("RIGHT", removeBtn, "LEFT", -8, 0)
			row.editBtn = editBtn

			-- Progress Bar
			local bar = CreateFrame("StatusBar", nil, row)
			bar:SetSize(140, 16)
			bar:SetPoint("RIGHT", editBtn, "LEFT", -14, 0)
			bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
			bar:SetStatusBarColor(0.2, 0.7, 0.9, 0.9)
			local barBg = bar:CreateTexture(nil, "BACKGROUND")
			barBg:SetAllPoints()
			barBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
			local barLabel = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			barLabel:SetPoint("CENTER", bar, "CENTER", 0, 0)
			row.bar = bar
			row.barLabel = barLabel

			-- Title
			local titleText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
			titleText:SetPoint("TOPLEFT", iconBtn, "TOPRIGHT", 12, -2)
			titleText:SetJustifyH("LEFT")
			titleText:SetWordWrap(false)
			row.titleText = titleText

			-- Note Icon
			local noteIcon = CreateFrame("Button", nil, row)
			noteIcon:SetSize(16, 16)
			noteIcon:SetPoint("LEFT", titleText, "RIGHT", 6, 0)
			local noteTex = noteIcon:CreateTexture(nil, "ARTWORK")
			noteTex:SetAllPoints()
			noteTex:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
			row.noteIcon = noteIcon

			-- Subtitle
			local subText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			subText:SetPoint("BOTTOMLEFT", iconBtn, "BOTTOMRIGHT", 12, 2)
			subText:SetWidth(250)
			subText:SetJustifyH("LEFT")
			subText:SetWordWrap(false)
			row.subText = subText

			table.insert(self.goalRows, row)
		end

		row:SetPoint("TOPLEFT", self.goalContent, "TOPLEFT", 0, -yOffset)
		row.goalIndex = i

		row.upBtn:SetScript("OnClick", function() GSF.GoalsHUD:MoveGoal(i, -1); Tab:RefreshGoals() end)
		row.downBtn:SetScript("OnClick", function() GSF.GoalsHUD:MoveGoal(i, 1); Tab:RefreshGoals() end)
		row.upBtn:SetEnabled(i > 1)
		row.upBtn:SetAlpha(i > 1 and 0.85 or 0.15)
		row.downBtn:SetEnabled(i < #goals)
		row.downBtn:SetAlpha(i < #goals and 0.85 or 0.15)

		local iconTex = goal.icon
		if IsPlaceholderIcon(iconTex) and (goal.itemID or goal.material or goal.name) then
			if goal.itemID then
				local _, _, _, _, _, _, _, _, _, t = GetItemInfo(goal.itemID)
				if t then iconTex = t end
			end
			if IsPlaceholderIcon(iconTex) then
				local res = AtlasJournal and AtlasJournal:FindResource(goal.material or goal.name)
				if res then
					local d = AtlasJournal:GetItemDetails(res.id)
					if d and d.icon then iconTex = d.icon end
				end
			end
		end
		row.icon:SetTexture(iconTex or "Interface\\Icons\\INV_Misc_QuestionMark")
		row.iconBtn:SetScript("OnEnter", function(btn)
			GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
			GameTooltip:SetText(goal.material or goal.name or "Resource", 1, 0.82, 0)
			GameTooltip:Show()
		end)
		row.iconBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

		-- Titles & Subtitles
		local isBounty = (goal.bountyId or goal.category == "Bounty")
		local bountyData = goal.bountyId and GSF.cache and GSF.cache.bounties and GSF.cache.bounties[goal.bountyId]

		local dispTitle = goal.title or goal.name
		row.titleText:SetText(dispTitle)
		local titleWidth = math.min(row.titleText:GetStringWidth() or 180, 230)
		row.titleText:SetWidth(titleWidth)

		if isBounty then
			local bTag = GSF.L["BOUNTY_TAG_SHORT"] or "Gilden-Auftrag"
			if bountyData then
				local req = GSF.Alts:GetFormattedName(bountyData.requester)
				local byPrefix = GSF.L["REQUESTED_BY_SHORT"] or "Von"
				row.subText:SetText(string.format("|cff00ccff[%s]|r • %s: %s", bTag, byPrefix, req))
			else
				row.subText:SetText(string.format("|cff00ccff[%s]|r", bTag))
			end
			row.subText:Show()
		elseif goal.material and goal.material ~= dispTitle then
			row.subText:SetText(goal.material)
			row.subText:Show()
		else
			row.subText:Hide()
		end

		-- FIFO Allocation
		local matKey = (goal.material or goal.name):lower():trim()
		if remainingCounts[matKey] == nil then
			remainingCounts[matKey] = GSF.GoalsHUD:CountItemInBags(goal.material or goal.name, goal.itemID)
		end
		local avail = remainingCounts[matKey]
		local target = goal.target or 1
		local allocated = math.min(avail, target)
		remainingCounts[matKey] = avail - allocated
		local pct = math.min(math.floor((allocated / target) * 100), 100)

		row.bar:SetMinMaxValues(0, target)
		row.bar:SetValue(allocated)
		if allocated >= target then
			row.bar:SetStatusBarColor(0.0, 1.0, 0.3, 0.9)
			row.barLabel:SetText(string.format("|cff00ff00%d / %d (100%%)|r", allocated, target))
		else
			row.bar:SetStatusBarColor(0.2, 0.7, 0.9, 0.9)
			row.barLabel:SetText(string.format("%d / %d (%d%%)", allocated, target, pct))
		end

		-- Note
		local goalNote = (goal.notes and goal.notes:trim() ~= "") and goal.notes or (bountyData and bountyData.notes and bountyData.notes:trim() ~= "" and bountyData.notes)
		if goalNote and goalNote:trim() ~= "" then
			row.noteIcon:Show()
			row.noteIcon:SetScript("OnEnter", function(noteBtn)
				GameTooltip:SetOwner(noteBtn, "ANCHOR_RIGHT")
				GameTooltip:AddLine(dispTitle, 1, 0.82, 0)
				GameTooltip:AddLine(GSF.L["NOTE_TOOLTIP_HEADER"] or "Goal Note:", 0.7, 0.7, 0.7)
				GameTooltip:AddLine(goalNote, 1, 1, 1, true)
				GameTooltip:Show()
			end)
			row.noteIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)
		else
			row.noteIcon:Hide()
		end

		-- Edit / View Bounty
		if isBounty then
			row.editBtn:Show()
			row.editBtn:SetText(GSF.L["VIEW_BOUNTY"] or "Auftrag")
			row.editBtn:SetScript("OnClick", function() Tab:HighlightBounty(goal.bountyId) end)
		else
			row.editBtn:Show()
			row.editBtn:SetText(GSF.L["EDIT"] or "Bearbeiten")
			row.editBtn:SetScript("OnClick", function() Tab:OpenGoalModal(goal) end)
		end

		-- Remove Button
		local gIdx, gData = i, goal
		row.removeBtn:SetText(isBounty and (GSF.L["BOUNTY_UNCLAIM"] or "Freigeben") or (GSF.L["REMOVE"] or "Entfernen"))
		row.removeBtn:SetScript("OnClick", function()
			if gData.bountyId or gData.category == "Bounty" then
				StaticPopup_Show("GSF_CONFIRM_UNCLAIM_BOUNTY", nil, nil, { index = gIdx, bountyId = gData.bountyId, itemName = gData.name })
			else
				GSF.GoalsHUD:RemoveGoal(gIdx)
				Tab:RefreshGoals()
			end
		end)

		row:Show()
		yOffset = yOffset + 56
	end

	self.goalContent:SetHeight(math.max(yOffset, 1))
	if self.goalScroll and self.goalScroll.UpdateScrollBar then
		self.goalScroll:UpdateScrollBar()
	end
end
