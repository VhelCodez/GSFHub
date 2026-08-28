local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabAtlas = Tab

local selectedResource = nil
local activeCategory = "All"
local activeView = "ATLAS" -- "ATLAS" or "BOUNTIES"

function Tab:Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	self.frame = frame

	-- Search Input
	local searchLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	searchLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -10)
	searchLabel:SetText(GSF.L["SEARCH_ATLAS"] or "Search materials, zones, or nodes...")
	self.searchLabel = searchLabel

	local searchBox = GSF.UI:CreateEditBox(frame, 190, 22)
	searchBox:SetPoint("TOPLEFT", searchLabel, "BOTTOMLEFT", 0, -4)
	self.searchBox = searchBox

	searchBox:SetScript("OnTextChanged", function()
		Tab:Refresh()
	end)

	-- Category Filter Dropdown
	local catDropdown = CreateFrame("Button", "GSFAtlasCatDropdown", frame, "UIDropDownMenuTemplate")
	catDropdown:SetPoint("LEFT", searchBox, "RIGHT", 5, -2)
	UIDropDownMenu_SetWidth(catDropdown, 120)
	UIDropDownMenu_SetText(catDropdown, GSF.L["CAT_ALL"] or "All Categories")
	self.catDropdown = catDropdown

	local categories = { "All", "Mining", "Herbalism", "Skinning", "Elemental", "Cloth", "Fishing" }
	UIDropDownMenu_Initialize(catDropdown, function(self, level)
		for _, cat in ipairs(categories) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = GSF.L["CAT_" .. cat:upper()] or cat
			info.value = cat
			info.func = function(btn)
				activeCategory = btn.value
				UIDropDownMenu_SetSelectedValue(catDropdown, btn.value)
				UIDropDownMenu_SetText(catDropdown, GSF.L["CAT_" .. btn.value:upper()] or btn.value)
				Tab:Refresh()
			end
			info.checked = (activeCategory == cat)
			UIDropDownMenu_AddButton(info, level)
		end
	end)

	-- Toggle View Buttons (Atlas vs Bounties)
	local atlasViewBtn = GSF.UI:CreateButton(frame, GSF.L["VIEW_ATLAS"] or "Resource Atlas", 130, 22)
	atlasViewBtn:SetPoint("LEFT", catDropdown, "RIGHT", 10, 2)
	self.atlasViewBtn = atlasViewBtn

	local bountyViewBtn = GSF.UI:CreateButton(frame, GSF.L["VIEW_BOUNTIES"] or "Guild Bounties", 130, 22)
	bountyViewBtn:SetPoint("LEFT", atlasViewBtn, "RIGHT", 6, 0)
	self.bountyViewBtn = bountyViewBtn

	local hideCompletedCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	hideCompletedCheck:SetPoint("LEFT", bountyViewBtn, "RIGHT", 15, 0)
	hideCompletedCheck.text:SetText(GSF.L["HIDE_COMPLETED"] or "Hide Completed")
	hideCompletedCheck.text:SetFontObject("GameFontHighlightSmall")
	hideCompletedCheck:SetChecked(true)
	hideCompletedCheck:Hide()
	hideCompletedCheck:SetScript("OnClick", function() Tab:Refresh() end)
	self.hideCompletedCheck = hideCompletedCheck

	atlasViewBtn:SetScript("OnClick", function()
		activeView = "ATLAS"
		Tab:Refresh()
	end)

	bountyViewBtn:SetScript("OnClick", function()
		activeView = "BOUNTIES"
		Tab:Refresh()
	end)

	-- Container for Atlas View (with 8px gap below top controls)
	local atlasContainer = CreateFrame("Frame", nil, frame)
	atlasContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -52)
	atlasContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
	self.atlasContainer = atlasContainer

	-- Atlas Left Scroll List
	local leftScroll, leftContent = GSF.UI:CreateScrollList(atlasContainer, 300, 370)
	leftScroll:SetPoint("TOPLEFT", atlasContainer, "TOPLEFT", 5, 0)
	leftScroll:SetPoint("BOTTOMLEFT", atlasContainer, "BOTTOMLEFT", 5, 10)
	self.leftContent = leftContent
	self.resourceRows = {}

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

	local detailTitle = rightPane:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	detailTitle:SetPoint("TOPLEFT", detailIcon, "TOPRIGHT", 12, -2)
	detailTitle:SetText(GSF.L["SELECT_RESOURCE_PROMPT"] or "Select a resource to view farming data")
	self.detailTitle = detailTitle

	local detailSub = rightPane:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	detailSub:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -4)
	self.detailSub = detailSub

	local zonesLabel = rightPane:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	zonesLabel:SetPoint("TOPLEFT", detailIcon, "BOTTOMLEFT", 0, -15)
	zonesLabel:SetText(GSF.L["BEST_FARMING_ZONES"] or "Best Farming Locations:")
	self.zonesLabel = zonesLabel

	local zonesText = rightPane:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	zonesText:SetPoint("TOPLEFT", zonesLabel, "BOTTOMLEFT", 0, -5)
	zonesText:SetPoint("RIGHT", rightPane, "RIGHT", -15, 0)
	zonesText:SetJustifyH("LEFT")
	self.zonesText = zonesText

	local yieldsLabel = rightPane:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	yieldsLabel:SetPoint("TOPLEFT", zonesText, "BOTTOMLEFT", 0, -12)
	yieldsLabel:SetText(GSF.L["RESOURCE_YIELDS"] or "Harvest Yields & Gems:")
	self.yieldsLabel = yieldsLabel

	local yieldsText = rightPane:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	yieldsText:SetPoint("TOPLEFT", yieldsLabel, "BOTTOMLEFT", 0, -5)
	yieldsText:SetPoint("RIGHT", rightPane, "RIGHT", -15, 0)
	yieldsText:SetJustifyH("LEFT")
	self.yieldsText = yieldsText

	local tipsLabel = rightPane:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	tipsLabel:SetPoint("TOPLEFT", yieldsText, "BOTTOMLEFT", 0, -12)
	tipsLabel:SetText(GSF.L["FARMING_TIPS"] or "Farming Route & Tips:")
	self.tipsLabel = tipsLabel

	local tipsText = rightPane:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	tipsText:SetPoint("TOPLEFT", tipsLabel, "BOTTOMLEFT", 0, -5)
	tipsText:SetPoint("RIGHT", rightPane, "RIGHT", -15, 0)
	tipsText:SetJustifyH("LEFT")
	self.tipsText = tipsText

	-- Action Buttons bottom right
	local pinBtn = GSF.UI:CreateButton(rightPane, GSF.L["PIN_TO_HUD"] or "Pin to HUD", 120, 24)
	pinBtn:SetPoint("BOTTOMLEFT", rightPane, "BOTTOMLEFT", 15, 12)
	pinBtn:Disable()
	self.pinBtn = pinBtn

	pinBtn:SetScript("OnClick", function()
		if selectedResource and GSF.GoalsHUD then
			local resName = GSF.Atlas:GetDisplayName(selectedResource)
			StaticPopup_Show("GSF_PIN_QUANTITY", resName, nil, { resName = resName, category = selectedResource.category })
		end
	end)

	local bountyBtn = GSF.UI:CreateButton(rightPane, GSF.L["POST_BOUNTY_BTN"] or "Request Bounty", 140, 24)
	bountyBtn:SetPoint("LEFT", pinBtn, "RIGHT", 10, 0)
	bountyBtn:Disable()
	self.bountyBtn = bountyBtn

	bountyBtn:SetScript("OnClick", function()
		if selectedResource then
			Tab:OpenBountyModal(selectedResource)
		end
	end)

	-- Container for Bounties View (with 8px gap below top controls)
	local bountiesContainer = CreateFrame("Frame", nil, frame)
	bountiesContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -52)
	bountiesContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
	bountiesContainer:Hide()
	self.bountiesContainer = bountiesContainer

	self.bountyCards = {}
	local bountyScroll, bountyContent = GSF.UI:CreateScrollList(bountiesContainer, 690, 360)
	bountyScroll:SetPoint("TOPLEFT", bountiesContainer, "TOPLEFT", 5, -5)
	bountyScroll:SetPoint("BOTTOMRIGHT", bountiesContainer, "BOTTOMRIGHT", -25, 5)
	self.bountyScroll = bountyScroll
	self.bountyContent = bountyContent

	-- Build Option B Bounty Creation Modal
	self:BuildBountyModal(frame)

	return frame
end

StaticPopupDialogs["GSF_PIN_QUANTITY"] = {
	text = "%s:\n" .. (GSF.L["PIN_HOW_MANY"] or "How many do you want to gather?"),
	button1 = GSF.L["YES"] or "OK",
	button2 = GSF.L["CANCEL"] or "Cancel",
	hasEditBox = true,
	OnShow = function(self)
		self.editBox:SetText("20")
		self.editBox:HighlightText()
		self.editBox:SetFocus()
	end,
	OnAccept = function(self, data)
		local qty = tonumber(self.editBox:GetText()) or 20
		if data and data.resName and GSF.GoalsHUD then
			GSF.GoalsHUD:AddGoal(data.resName, qty, data.category)
		end
	end,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent()
		local qty = tonumber(self:GetText()) or 20
		if data and data.resName and GSF.GoalsHUD then
			GSF.GoalsHUD:AddGoal(data.resName, qty, data.category)
		end
		parent:Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

function Tab:BuildBountyModal(parent)
	local modal = CreateFrame("Frame", "GSFAtlasBountyModal", parent)
	modal:SetSize(380, 240)
	modal:SetPoint("CENTER", parent, "CENTER", 0, 0)
	modal:SetFrameStrata("DIALOG")
	GSF.UI:CreateBackdrop(modal, false)
	modal:SetBackdropColor(0.06, 0.06, 0.08, 0.98)
	modal:Hide()
	self.bountyModal = modal

	local title = modal:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", modal, "TOP", 0, -15)
	title:SetText(string.format("|cff%s%s|r", GSF.COLORS.PRIMARY, GSF.L["BOUNTY_REQUEST_TITLE"] or "Request Material"))

	local slot = GSF.UI:CreateItemSlot(modal, 32)
	slot:SetPoint("TOPLEFT", modal, "TOPLEFT", 30, -50)
	modal.slot = slot

	local nameLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
	nameLabel:SetPoint("LEFT", slot, "RIGHT", 10, 0)
	modal.nameLabel = nameLabel

	local qtyLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	qtyLabel:SetPoint("TOPLEFT", slot, "BOTTOMLEFT", 0, -16)
	qtyLabel:SetText(GSF.L["QUANTITY"] or "Quantity:")

	local qtyBox = GSF.UI:CreateEditBox(modal, 70, 22)
	qtyBox:SetPoint("LEFT", qtyLabel, "RIGHT", 10, 0)
	qtyBox:SetText("20")
	modal.qtyBox = qtyBox

	local noteLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	noteLabel:SetPoint("TOPLEFT", qtyLabel, "BOTTOMLEFT", 0, -16)
	noteLabel:SetText(GSF.L["NOTE"] or "Note:")

	local noteBox = GSF.UI:CreateEditBox(modal, 250, 22)
	noteBox:SetPoint("LEFT", noteLabel, "RIGHT", 10, 0)
	modal.noteBox = noteBox

	local submitBtn = GSF.UI:CreateButton(modal, GSF.L["SUBMIT_ORDER"] or "Submit", 110, 24)
	submitBtn:SetPoint("BOTTOMLEFT", modal, "BOTTOMLEFT", 60, 16)
	submitBtn:SetScript("OnClick", function()
		if modal.resource and GSF.SupplyBounties then
			local res = modal.resource
			local resName = GSF.Atlas:GetDisplayName(res)
			local count = tonumber(qtyBox:GetText()) or 20
			local notes = noteBox:GetText():trim()
			GSF.SupplyBounties:CreateBounty(resName, count, res.category, notes)
			modal:Hide()
			activeView = "BOUNTIES"
			Tab:Refresh()
		end
	end)

	local cancelBtn = GSF.UI:CreateButton(modal, GSF.L["CANCEL"] or "Cancel", 90, 24)
	cancelBtn:SetPoint("LEFT", submitBtn, "RIGHT", 20, 0)
	cancelBtn:SetScript("OnClick", function() modal:Hide() end)
end

function Tab:OpenBountyModal(resource)
	if not self.bountyModal then return end
	self.bountyModal.resource = resource
	local dispName = GSF.Atlas:GetDisplayName(resource)
	self.bountyModal.nameLabel:SetText(dispName)
	self.bountyModal.slot:SetItem(dispName, resource.icon, nil, resource.itemID)
	self.bountyModal.qtyBox:SetText("20")
	self.bountyModal.noteBox:SetText("")
	self.bountyModal:Show()
end

function Tab:SelectResource(res)
	selectedResource = res
	if not res then return end

	if self.pinBtn then self.pinBtn:Enable() end
	if self.bountyBtn then self.bountyBtn:Enable() end

	local dispName = GSF.Atlas:GetDisplayName(res)
	local catLoc = GSF.L["CAT_" .. (res.category or ""):upper()] or res.category
	self.detailIcon:SetTexture(res.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
	self.detailTitle:SetText(string.format("|cff%s%s|r", GSF.COLORS.PRIMARY, dispName))
	self.detailSub:SetText(string.format("%s  •  Min Skill: |cffffd100%d|r", catLoc, res.minSkill or 1))

	local zoneLines = {}
	for _, z in ipairs(res.zones or {}) do
		local zLoc = GSF.Atlas:GetZoneDisplayName(z)
		table.insert(zoneLines, "• " .. zLoc)
	end
	self.zonesText:SetText(#zoneLines > 0 and table.concat(zoneLines, "\n") or "None")
	self.yieldsText:SetText(GSF.Atlas:GetYieldsDisplayName(res.yields) or "None")
	self.tipsText:SetText(GSF.Atlas:GetTipsDisplayName(res.tips) or "No specific notes.")
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
	if self.hideCompletedCheck then self.hideCompletedCheck.text:SetText(GSF.L["HIDE_COMPLETED"] or "Hide Completed") end
	if self.zonesLabel then self.zonesLabel:SetText(GSF.L["BEST_FARMING_ZONES"]) end
	if self.yieldsLabel then self.yieldsLabel:SetText(GSF.L["RESOURCE_YIELDS"]) end
	if self.tipsLabel then self.tipsLabel:SetText(GSF.L["FARMING_TIPS"]) end
	if self.pinBtn then self.pinBtn:SetText(GSF.L["PIN_TO_HUD"]) end
	if self.bountyBtn then self.bountyBtn:SetText(GSF.L["POST_BOUNTY_BTN"]) end
	self:Refresh()
end

function Tab:Refresh()
	if not self.frame or not self.frame:IsShown() then return end

	if activeView == "ATLAS" then
		self.atlasContainer:Show()
		self.bountiesContainer:Hide()
		if self.hideCompletedCheck then self.hideCompletedCheck:Hide() end
		if self.atlasViewBtn then self.atlasViewBtn:SetText("|cffffd100" .. (GSF.L["VIEW_ATLAS"] or "Resource Atlas") .. "|r") end
		if self.bountyViewBtn then self.bountyViewBtn:SetText("|cffaaaaaa" .. (GSF.L["VIEW_BOUNTIES"] or "Guild Bounties") .. "|r") end
		self:RefreshAtlas()
	else
		self.atlasContainer:Hide()
		self.bountiesContainer:Show()
		if self.hideCompletedCheck then self.hideCompletedCheck:Show() end
		if self.atlasViewBtn then self.atlasViewBtn:SetText("|cffaaaaaa" .. (GSF.L["VIEW_ATLAS"] or "Resource Atlas") .. "|r") end
		if self.bountyViewBtn then self.bountyViewBtn:SetText("|cffffd100" .. (GSF.L["VIEW_BOUNTIES"] or "Guild Bounties") .. "|r") end
		self:RefreshBounties()
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
		row.icon:SetTexture(res.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
		row.name:SetText(GSF.Atlas:GetDisplayName(res))
		row.skill:SetText(string.format("|cffffd100%d|r", res.minSkill or 1))

		row:SetScript("OnClick", function()
			Tab:SelectResource(res)
		end)

		row:Show()
		yOffset = yOffset + 30
	end

	self.leftContent:SetHeight(math.max(yOffset, 370))

	if not selectedResource and #resources > 0 then
		self:SelectResource(resources[1])
	end
end

function Tab:RefreshBounties()
	local myName = GSF.DB:GetPlayerName()
	local bounties = GSF.SupplyBounties:GetActiveBounties(activeCategory)
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

			if b.status == GSF.ORDER_STATUS.OPEN then
				card.statusText:SetText("|cff00ff00" .. (GSF.L["STATUS_OPEN"] or "OPEN") .. "|r")
				if isMine then
					card.actionBtn:SetText(GSF.L["CANCEL_ORDER"] or "Cancel")
					card.actionBtn:SetScript("OnClick", function()
						GSF.SupplyBounties:CancelBounty(b.id)
						Tab:Refresh()
					end)
					card.actionBtn:Show()
				else
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

	self.bountyContent:SetHeight(math.max(yOffset, 370))
end
