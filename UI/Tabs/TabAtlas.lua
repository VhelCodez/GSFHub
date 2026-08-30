local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabAtlas = Tab

local selectedResource = nil
local activeCategory = "ALL"
local activeView = "ATLAS" -- "ATLAS" or "BOUNTIES"

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
		local name = GSF.AtlasEngine and GSF.AtlasEngine:GetCategoryInfo(activeCategory)
		UIDropDownMenu_SetText(catDropdown, name or activeCategory)
	end
	UpdateCatDropdownText()

	UIDropDownMenu_Initialize(catDropdown, function(dropdown, level)
		if not GSF.AtlasCategories then return end
		for _, cat in ipairs(GSF.AtlasCategories) do
			local info = UIDropDownMenu_CreateInfo()
			local catName, catIcon = GSF.AtlasEngine:GetCategoryInfo(cat.key)
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

	local rightScroll, rightContent = GSF.UI:CreateScrollList(rightPane, 420, 260)
	rightScroll:SetPoint("TOPLEFT", rightPane, "TOPLEFT", 15, -65)
	rightScroll:SetPoint("BOTTOMRIGHT", rightPane, "BOTTOMRIGHT", -15, 45)
	self.rightScroll = rightScroll
	self.rightContent = rightContent

	local zonesLabel = rightContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	zonesLabel:SetPoint("TOPLEFT", rightContent, "TOPLEFT", 0, 0)
	zonesLabel:SetText(GSF.L["SRC_SOURCES_HEADER"] or "Acquisition Sources:")
	self.zonesLabel = zonesLabel

	local zonesText = rightContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	zonesText:SetPoint("TOPLEFT", zonesLabel, "BOTTOMLEFT", 0, -5)
	zonesText:SetWidth(410)
	zonesText:SetJustifyH("LEFT")
	self.zonesText = zonesText

	local yieldsLabel = rightContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	yieldsLabel:SetPoint("TOPLEFT", zonesText, "BOTTOMLEFT", 0, -12)
	yieldsLabel:SetText(GSF.L["RESOURCE_YIELDS"] or "Harvest Yields & Byproducts:")
	self.yieldsLabel = yieldsLabel

	local yieldsText = rightContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	yieldsText:SetPoint("TOPLEFT", yieldsLabel, "BOTTOMLEFT", 0, -5)
	yieldsText:SetWidth(410)
	yieldsText:SetJustifyH("LEFT")
	self.yieldsText = yieldsText

	local tipsLabel = rightContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	tipsLabel:SetPoint("TOPLEFT", yieldsText, "BOTTOMLEFT", 0, -12)
	tipsLabel:SetText(GSF.L["FARMING_TIPS"] or "Farming Route & Tips:")
	self.tipsLabel = tipsLabel

	local tipsText = rightContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	tipsText:SetPoint("TOPLEFT", tipsLabel, "BOTTOMLEFT", 0, -5)
	tipsText:SetWidth(410)
	tipsText:SetJustifyH("LEFT")
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

	return frame
end

function Tab:BuildSetupModal(parent)
	local modal = CreateFrame("Frame", "GSFAtlasResourceSetupModal", parent)
	modal:SetSize(400, 280)
	modal:SetPoint("CENTER", parent, "CENTER", 0, 0)
	modal:SetFrameStrata("DIALOG")
	if BackdropTemplateMixin then Mixin(modal, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(modal, false)
	modal:SetBackdropColor(0.06, 0.06, 0.08, 0.98)
	modal:Hide()
	self.setupModal = modal
	self.bountyModal = modal

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

		local userTitle = titleBox:GetText():trim()
		if userTitle == "" then userTitle = modal.materialName end
		local notes = noteBox:GetText():trim()

		if modal.mode == "GOAL" then
			if GSF.GoalsHUD then
				GSF.GoalsHUD:AddPersonalGoal(modal.materialName, userTitle, count, notes, modal.icon, modal.category, modal.editGoalId, modal.itemID)
			end
			modal:Hide()
		elseif modal.mode == "BOUNTY" then
			if GSF.SupplyBounties then
				GSF.SupplyBounties:CreateBounty(userTitle, count, modal.category or "General", notes)
			end
			modal:Hide()
			activeView = "BOUNTIES"
			Tab:Refresh()
		elseif modal.mode == "BOUNTY_EDIT" then
			if GSF.SupplyBounties then
				GSF.SupplyBounties:UpdateBounty(modal.editBountyId, userTitle, count, modal.category or "General", notes)
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
		local itemIcon = target.icon
		if not itemIcon or itemIcon:find("INV_Misc_QuestionMark") then
			local res = GSF.Atlas and GSF.Atlas:FindResource(target.item)
			if res then
				local d = GSF.AtlasEngine and GSF.AtlasEngine:GetItemDetails(res.id)
				if d and d.icon then itemIcon = d.icon end
			end
		end
		icon = itemIcon or "Interface\\Icons\\INV_Misc_QuestionMark"
		cat = target.category or "General"
		initTitle = target.item or ""
		initQty = tostring(target.count or "")
		initNotes = target.notes or ""
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
		local details = targetID and GSF.AtlasEngine and GSF.AtlasEngine:GetItemDetails(targetID)
		dispName = (details and details.name) or GSF.Atlas:GetDisplayName(target)
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

	modal.nameLabel:SetText(string.format("|cffffd100%s|r", dispName))
	modal.slot:SetItem(dispName, icon, nil, modal.itemID)
	modal.titleBox:SetText(initTitle)
	modal.qtyBox:SetText(initQty)
	modal.noteBox:SetText(initNotes)

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

function Tab:SelectResource(res)
	selectedResource = res
	if not res then return end

	if self.pinBtn then self.pinBtn:Enable() end
	if self.bountyBtn then self.bountyBtn:Enable() end

	local details = GSF.AtlasEngine:GetItemDetails(res.id)
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

	self.detailTitle:SetText(string.format("|c%s%s|r", color.hex or "ffffffff", details.name))

	local catName = GSF.AtlasEngine:GetCategoryInfo(res.category)
	local minSkill = GSF.Atlas:GetMinSkill(res)
	self.detailSub:SetText(string.format("%s  •  Min Skill: |cffffd100%d|r  •  ID: |cffaaaaaa%d|r", catName, minSkill, res.id))

	-- Format Polymorphic Sources
	local sourceLines = {}
	if res.sources then
		for _, src in ipairs(res.sources) do
			if src.type == "GATHER" then
				local zones = {}
				for _, aId in ipairs(src.zones or {}) do
					table.insert(zones, GSF.AtlasEngine:GetZoneName(aId))
				end
				local zStr = #zones > 0 and table.concat(zones, ", ") or "World"
				table.insert(sourceLines, string.format("|cffffd100• %s|r (Skill %d):\n   %s", GSF.L["SRC_GATHER"] or "Gathering", src.skill or 1, zStr))
			elseif src.type == "PROSPECT" then
				local fromNames = {}
				for _, fId in ipairs(src.fromItems or {}) do
					local d = GSF.AtlasEngine:GetItemDetails(fId)
					table.insert(fromNames, d.link or string.format("Item #%d", fId))
				end
				local spellName = GetSpellInfo(31252) or "Prospecting"
				table.insert(sourceLines, string.format("|cffffd100• %s|r (%s, Skill %d):\n   %s: %s", GSF.L["SRC_PROSPECT"] or "Prospecting", spellName, src.skill or 300, GSF.L["CRUSHED_FROM"] or "Crushed from 5x", table.concat(fromNames, ", ")))
			elseif src.type == "DISENCHANT" then
				local spellName = GetSpellInfo(13262) or "Disenchant"
				local qName = src.itemQuality == 4 and "|cffa335eeEpic|r" or (src.itemQuality == 3 and "|cff0070ddRare|r" or "|cff1eff00Uncommon|r")
				table.insert(sourceLines, string.format("|cffffd100• %s|r (%s):\n   %s (%s, iLvl %s)", GSF.L["SRC_DISENCHANT"] or "Disenchanting", spellName, GSF.L["DISENCHANTED_FROM"] or "Disenchanted from items", qName, src.itemLevels or "1+"))
			elseif src.type == "EXTRACT" then
				local zones = {}
				for _, aId in ipairs(src.zones or {}) do
					table.insert(zones, GSF.AtlasEngine:GetZoneName(aId))
				end
				local zStr = #zones > 0 and table.concat(zones, ", ") or "Outland"
				local devDetails = GSF.AtlasEngine:GetItemDetails(src.device or 23821)
				table.insert(sourceLines, string.format("|cffffd100• %s|r (Engi %d):\n   %s: %s\n   %s", GSF.L["SRC_EXTRACT"] or "Gas Extraction", src.skill or 305, GSF.L["DEVICE_REQUIRED"] or "Tool", devDetails.link or "Zapthrottle Mote Extractor", zStr))
			elseif src.type == "TRANSMUTE" then
				local fromNames = {}
				for _, fId in ipairs(src.fromItems or {}) do
					local d = GSF.AtlasEngine:GetItemDetails(fId)
					table.insert(fromNames, d.link or string.format("Item #%d", fId))
				end
				local spellName = (src.spellID and GetSpellInfo(src.spellID)) or "Transmute"
				table.insert(sourceLines, string.format("|cffffd100• %s|r (%s, %s Cooldown):\n   %s: %s", GSF.L["SRC_TRANSMUTE"] or "Transmutation", spellName, src.cooldown or "20h", GSF.L["REAGENTS"] or "Reagents", table.concat(fromNames, ", ")))
			elseif src.type == "SMELT" then
				local fromNames = {}
				for _, fId in ipairs(src.fromItems or {}) do
					local d = GSF.AtlasEngine:GetItemDetails(fId)
					table.insert(fromNames, d.link or string.format("Item #%d", fId))
				end
				local spellName = GetSpellInfo(2656) or "Smelt"
				table.insert(sourceLines, string.format("|cffffd100• %s|r (%s, Skill %d):\n   %s: %s", GSF.L["SRC_SMELT"] or "Smelting", spellName, src.skill or 1, GSF.L["REAGENTS"] or "Reagents", table.concat(fromNames, ", ")))
			elseif src.type == "COMBINE" then
				local fromD = GSF.AtlasEngine:GetItemDetails(src.fromItem)
				table.insert(sourceLines, string.format("|cffffd100• %s|r: %dx %s", GSF.L["SRC_COMBINE"] or "Combine", src.count or 10, fromD.link or "Reagent"))
			elseif src.type == "MOB_DROP" then
				local zones = {}
				for _, aId in ipairs(src.zones or {}) do
					table.insert(zones, GSF.AtlasEngine:GetZoneName(aId))
				end
				local zStr = #zones > 0 and table.concat(zones, ", ") or "World"
				table.insert(sourceLines, string.format("|cffffd100• %s|r (%s, Lvl %s):\n   %s", GSF.L["SRC_MOB_DROP"] or "Creature Drop", src.mobType or "Mobs", src.mobLevel or "Any", zStr))
			elseif src.type == "FISH" then
				local zones = {}
				for _, aId in ipairs(src.zones or {}) do
					table.insert(zones, GSF.AtlasEngine:GetZoneName(aId))
				end
				local zStr = #zones > 0 and table.concat(zones, ", ") or "Waters"
				table.insert(sourceLines, string.format("|cffffd100• %s|r (Skill %d, %s):\n   %s", GSF.L["SRC_FISH"] or "Fishing", src.skill or 1, src.school or "Open Water", zStr))
			elseif src.type == "BYPRODUCT" then
				local fromNames = {}
				for _, fId in ipairs(src.fromItems or {}) do
					local d = GSF.AtlasEngine:GetItemDetails(fId)
					table.insert(fromNames, d.link or string.format("Item #%d", fId))
				end
				table.insert(sourceLines, string.format("|cffffd100• %s|r:\n   %s", GSF.L["SRC_BYPRODUCT"] or "Byproduct", table.concat(fromNames, ", ")))
			elseif src.type == "INSTANCE" then
				table.insert(sourceLines, string.format("|cffffd100• %s|r: %s %s", GSF.L["SRC_INSTANCE"] or "Instance Drop", src.dungeon or "", src.raid or ""))
			elseif src.type == "VENDOR" then
				table.insert(sourceLines, string.format("|cffffd100• %s|r: %s", GSF.L["SRC_VENDOR"] or "Vendor Purchase", src.cost or ""))
			end
		end
	end
	self.zonesText:SetText(#sourceLines > 0 and table.concat(sourceLines, "\n\n") or (GSF.L["SRC_GATHER_DESC"] or "Farmed in the world."))

	-- Format Yields
	if res.yields and #res.yields > 0 then
		local yieldLinks = {}
		for _, yId in ipairs(res.yields) do
			local yd = GSF.AtlasEngine:GetItemDetails(yId)
			table.insert(yieldLinks, yd.link or string.format("Item #%d", yId))
		end
		self.yieldsText:SetText(table.concat(yieldLinks, "  •  "))
		self.yieldsLabel:Show()
		self.yieldsText:Show()
	else
		self.yieldsText:SetText("")
		self.yieldsLabel:Hide()
		self.yieldsText:Hide()
	end

	-- Format Farming Tips
	local tip = (res.tipKey and GSF.L[res.tipKey]) or GSF.L["NO_SPECIFIC_TIPS"] or "No specific notes."
	self.tipsText:SetText(tip)

	-- Update Content Height
	local totalHeight = 20 + self.zonesText:GetStringHeight()
	if res.yields and #res.yields > 0 then
		totalHeight = totalHeight + 25 + self.yieldsText:GetStringHeight()
	end
	totalHeight = totalHeight + 25 + self.tipsText:GetStringHeight() + 30
	self.rightContent:SetHeight(math.max(totalHeight, 260))
	if self.rightScroll and self.rightScroll.UpdateScrollBar then
		self.rightScroll:UpdateScrollBar()
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
	local query = self.searchBox:GetText()
	local resources = GSF.Atlas:Search(query, activeCategory)

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

			local icon = row:CreateTexture(nil, "ARTWORK")
			icon:SetSize(20, 20)
			icon:SetPoint("LEFT", row, "LEFT", 4, 0)
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

		row:SetPoint("TOPLEFT", self.leftContent, "TOPLEFT", 0, -yOffset)
		local details = GSF.AtlasEngine:GetItemDetails(res.id)
		local color = ITEM_QUALITY_COLORS[details.quality] or { hex = "ffffffff" }

		row.icon:SetTexture(details.icon)
		row.name:SetText(string.format("|c%s%s|r", color.hex or "ffffffff", details.name))
		local minSkill = GSF.Atlas:GetMinSkill(res)
		row.skill:SetText(minSkill > 1 and string.format("|cffffd100%d|r", minSkill) or "")

		row:SetScript("OnEnter", function(selfRow)
			GameTooltip:SetOwner(selfRow, "ANCHOR_RIGHT")
			if details.link then
				GameTooltip:SetHyperlink(details.link)
			else
				GameTooltip:SetItemByID(res.id)
			end
			GameTooltip:Show()
		end)
		row:SetScript("OnLeave", function() GameTooltip:Hide() end)

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
				card:SetSize(660, 56)
				if BackdropTemplateMixin then Mixin(card, BackdropTemplateMixin) end
				GSF.UI:CreateBackdrop(card, false)
				card:SetBackdropColor(0.10, 0.10, 0.14, 0.75)

				local itemText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
				itemText:SetPoint("TOPLEFT", card, "TOPLEFT", 12, -8)
				card.itemText = itemText

				local details = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				details:SetPoint("TOPLEFT", itemText, "BOTTOMLEFT", 0, -4)
				card.details = details

				local statusText = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
				statusText:SetPoint("TOPRIGHT", card, "TOPRIGHT", -12, -8)
				card.statusText = statusText

				local actionBtn = GSF.UI:CreateButton(card, "Claim", 95, 20)
				actionBtn:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -12, 8)
				card.actionBtn = actionBtn

				local editBtn = GSF.UI:CreateButton(card, GSF.L["EDIT"] or "Edit", 75, 20)
				editBtn:SetPoint("RIGHT", actionBtn, "LEFT", -6, 0)
				card.editBtn = editBtn

				local mailBtn = GSF.UI:CreateButton(card, GSF.L["MAIL"] or "Mail", 65, 20)
				mailBtn:SetPoint("RIGHT", actionBtn, "LEFT", -6, 0)
				card.mailBtn = mailBtn

				local unclaimBtn = GSF.UI:CreateButton(card, GSF.L["BOUNTY_UNCLAIM"] or "Unclaim", 75, 20)
				unclaimBtn:SetPoint("RIGHT", mailBtn, "LEFT", -6, 0)
				card.unclaimBtn = unclaimBtn

				table.insert(self.bountyCards, card)
			end

			card:SetPoint("TOPLEFT", self.bountyContent, "TOPLEFT", 0, -yOffset)

			local isMine = (b.requester == myName)
			local isClaimer = (b.claimer == myName)
			local reqFormatted = GSF.Alts:GetFormattedName(b.requester)
			local catLoc = GSF.L["CAT_" .. (b.category or "GENERAL"):upper()] or b.category or "General"
			card.itemText:SetText(string.format("|cff%s%s|r x%d (|cffffd100%s|r)", GSF.COLORS.PRIMARY, b.item, b.count or 1, catLoc))
			
			local noteStr = (b.notes and b.notes ~= "") and b.notes or (GSF.L["NONE"] or "None")
			local reqPrefix = GSF.L["REQUESTED_BY_LABEL"] and string.format(GSF.L["REQUESTED_BY_LABEL"], reqFormatted) or ("Requested by: " .. reqFormatted)
			local notePrefix = GSF.L["NOTE_LABEL"] and string.format(GSF.L["NOTE_LABEL"], noteStr) or ("Note: " .. noteStr)
			card.details:SetText(string.format("%s  •  %s", reqPrefix, notePrefix))

			card.unclaimBtn:Hide()
			card.mailBtn:Hide()
			card.editBtn:Hide()

			if b.status == GSF.ORDER_STATUS.OPEN then
				card.statusText:SetText("|cff00ff00" .. (GSF.L["STATUS_OPEN"] or "OPEN") .. "|r")
				if isMine then
					card.actionBtn:SetText(GSF.L["CANCEL_ORDER"] or "Cancel")
					card.actionBtn:SetScript("OnClick", function()
						GSF.SupplyBounties:CancelBounty(b.id)
						Tab:Refresh()
					end)
					card.actionBtn:Show()

					card.editBtn:SetText(GSF.L["EDIT"] or "Edit")
					card.editBtn:SetScript("OnClick", function()
						Tab:OpenBountyEditModal(b)
					end)
					card.editBtn:Show()
				else
					card.editBtn:Hide()
					card.actionBtn:SetText(GSF.L["CLAIM_BOUNTY"] or "Claim")
					card.actionBtn:SetScript("OnClick", function()
						GSF.SupplyBounties:ClaimBounty(b.id)
						Tab:Refresh()
					end)
					card.actionBtn:Show()
				end

			elseif b.status == GSF.ORDER_STATUS.CLAIMED then
				local claimerFormatted = GSF.Alts:GetFormattedName(b.claimer)
				card.statusText:SetText(string.format("|cffffd100" .. (GSF.L["STATUS_CLAIMED"] or "CLAIMED") .. "|r (%s)", claimerFormatted))

				if isClaimer then
					card.actionBtn:SetText(GSF.L["COMPLETE_ORDER"] or "Complete")
					card.actionBtn:SetScript("OnClick", function()
						GSF.SupplyBounties:FulfillBounty(b.id)
						Tab:Refresh()
					end)
					card.actionBtn:Show()

					card.mailBtn:SetText(GSF.L["MAIL"] or "Mail")
					card.mailBtn:Show()
					card.mailBtn:SetScript("OnClick", function()
						if GSF.MailHelper then
							GSF.MailHelper:PrepareBountyMail(b.requester, b.id, b.item, b.count)
						end
					end)

					card.unclaimBtn:Show()
					card.unclaimBtn:SetScript("OnClick", function()
						GSF.SupplyBounties:UnclaimBounty(b.id)
						Tab:Refresh()
					end)
				else
					card.actionBtn:Hide()
				end

			elseif b.status == GSF.ORDER_STATUS.IN_TRANSIT then
				local mins = math.floor((time() - (b.mailedAt or time())) / 60)
				card.statusText:SetText(string.format("|cff00ccff[Mail] %s (%dm)|r", GSF.L["STATUS_IN_TRANSIT"] or "IN TRANSIT", mins))

				if isMine then
					card.actionBtn:SetText(GSF.L["CONFIRM_RECEIVED"] or "Confirm Received")
					card.actionBtn:SetScript("OnClick", function()
						GSF.SupplyBounties:FulfillBounty(b.id)
						Tab:Refresh()
					end)
					card.actionBtn:Show()
				else
					card.actionBtn:Hide()
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
				else
					card.actionBtn:Hide()
				end
			else
				card.actionBtn:Hide()
			end

			card:Show()
			yOffset = yOffset + 60
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
	if (not iconTex or iconTex:find("INV_Misc_QuestionMark")) and (goal.itemID or goal.material or goal.name) then
		if goal.itemID then
			local _, _, _, _, _, _, _, _, _, t = GetItemInfo(goal.itemID)
			if t then iconTex = t end
		end
		if not iconTex or iconTex:find("INV_Misc_QuestionMark") then
			local res = GSF.Atlas and GSF.Atlas:FindResource(goal.material or goal.name)
			if res then
				local d = GSF.AtlasEngine and GSF.AtlasEngine:GetItemDetails(res.id)
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

function Tab:RefreshGoals()
	local goals = GSF.db and GSF.db.myGoals or {}
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

			-- Up / Down Buttons (Noticeably larger: 22x16)
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

			-- Item Icon (36x36)
			local iconBtn = CreateFrame("Button", nil, row)
			iconBtn:SetSize(36, 36)
			iconBtn:SetPoint("LEFT", upBtn, "RIGHT", 8, -9)
			local icon = iconBtn:CreateTexture(nil, "ARTWORK")
			icon:SetAllPoints()
			row.icon = icon
			row.iconBtn = iconBtn

			-- Action Buttons (anchored to the right)
			local removeBtn = GSF.UI:CreateButton(row, GSF.L["REMOVE"] or "Entfernen", 75, 22)
			removeBtn:SetPoint("RIGHT", row, "RIGHT", -10, 0)
			row.removeBtn = removeBtn

			local editBtn = GSF.UI:CreateButton(row, GSF.L["EDIT"] or "Bearbeiten", 75, 22)
			editBtn:SetPoint("RIGHT", removeBtn, "LEFT", -8, 0)
			row.editBtn = editBtn

			-- Progress Bar (140x16) anchored directly to the left of editBtn
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

			-- Title (wide and non-truncating)
			local titleText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
			titleText:SetPoint("TOPLEFT", iconBtn, "TOPRIGHT", 12, -2)
			titleText:SetJustifyH("LEFT")
			titleText:SetWordWrap(false)
			row.titleText = titleText

			-- Note Icon beside title
			local noteIcon = CreateFrame("Button", nil, row)
			noteIcon:SetSize(16, 16)
			noteIcon:SetPoint("LEFT", titleText, "RIGHT", 6, 0)
			local noteTex = noteIcon:CreateTexture(nil, "ARTWORK")
			noteTex:SetAllPoints()
			noteTex:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
			row.noteIcon = noteIcon

			-- Subtitle below title
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

		-- Up / Down Clicks
		row.upBtn:SetScript("OnClick", function()
			GSF.GoalsHUD:MoveGoal(i, -1)
			Tab:RefreshGoals()
		end)
		row.downBtn:SetScript("OnClick", function()
			GSF.GoalsHUD:MoveGoal(i, 1)
			Tab:RefreshGoals()
		end)
		if i == 1 then
			row.upBtn:Disable()
			row.upBtn:SetAlpha(0.15)
		else
			row.upBtn:Enable()
			row.upBtn:SetAlpha(0.85)
		end
		if i == #goals then
			row.downBtn:Disable()
			row.downBtn:SetAlpha(0.15)
		else
			row.downBtn:Enable()
			row.downBtn:SetAlpha(0.85)
		end

		-- Icon resolution
		local iconTex = goal.icon
		if (not iconTex or iconTex:find("INV_Misc_QuestionMark")) and (goal.itemID or goal.material or goal.name) then
			if goal.itemID then
				local _, _, _, _, _, _, _, _, _, t = GetItemInfo(goal.itemID)
				if t then iconTex = t end
			end
			if not iconTex or iconTex:find("INV_Misc_QuestionMark") then
				local res = GSF.Atlas and GSF.Atlas:FindResource(goal.material or goal.name)
				if res then
					local d = GSF.AtlasEngine and GSF.AtlasEngine:GetItemDetails(res.id)
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

		-- Titles
		local dispTitle = goal.title or goal.name
		row.titleText:SetText(dispTitle)
		local titleWidth = math.min(row.titleText:GetStringWidth() or 180, 230)
		row.titleText:SetWidth(titleWidth)
		if goal.material and goal.material ~= dispTitle then
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
		if goal.notes and goal.notes:trim() ~= "" then
			row.noteIcon:Show()
			row.noteIcon:SetScript("OnEnter", function(noteBtn)
				GameTooltip:SetOwner(noteBtn, "ANCHOR_RIGHT")
				GameTooltip:AddLine(dispTitle, 1, 0.82, 0)
				GameTooltip:AddLine(GSF.L["NOTE_TOOLTIP_HEADER"] or "Goal Note:", 0.7, 0.7, 0.7)
				GameTooltip:AddLine(goal.notes, 1, 1, 1, true)
				GameTooltip:Show()
			end)
			row.noteIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)
		else
			row.noteIcon:Hide()
		end

		-- Edit Button
		if goal.bountyId or goal.category == "Bounty" then
			row.editBtn:Hide()
		else
			row.editBtn:Show()
			row.editBtn:SetText(GSF.L["EDIT"] or "Bearbeiten")
			row.editBtn:SetScript("OnClick", function()
				Tab:OpenGoalModal(goal)
			end)
		end

		-- Remove Button
		local gIdx = i
		local gData = goal
		row.removeBtn:SetText(GSF.L["REMOVE"] or "Entfernen")
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
