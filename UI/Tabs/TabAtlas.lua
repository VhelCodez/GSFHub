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

	atlasViewBtn:SetScript("OnClick", function()
		activeView = "ATLAS"
		Tab:Refresh()
	end)

	bountyViewBtn:SetScript("OnClick", function()
		activeView = "BOUNTIES"
		Tab:Refresh()
	end)

	-- Container for Atlas View
	local atlasContainer = CreateFrame("Frame", nil, frame)
	atlasContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -42)
	atlasContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
	self.atlasContainer = atlasContainer

	-- Atlas Left Scroll List
	local leftScroll, leftContent = GSF.UI:CreateScrollList(atlasContainer, 300, 370)
	leftScroll:SetPoint("TOPLEFT", atlasContainer, "TOPLEFT", 5, 0)
	leftScroll:SetPoint("BOTTOMLEFT", atlasContainer, "BOTTOMLEFT", 5, 10)
	self.leftContent = leftContent
	self.resourceRows = {}

	-- Atlas Right Details Pane
	local rightPane = CreateFrame("Frame", nil, atlasContainer)
	rightPane:SetPoint("TOPLEFT", leftScroll, "TOPRIGHT", 15, 0)
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
			GSF.GoalsHUD:AddGoal(resName, 20, selectedResource.category)
		end
	end)

	local bountyBtn = GSF.UI:CreateButton(rightPane, GSF.L["POST_BOUNTY_BTN"] or "Request Bounty", 140, 24)
	bountyBtn:SetPoint("LEFT", pinBtn, "RIGHT", 10, 0)
	bountyBtn:Disable()
	self.bountyBtn = bountyBtn

	bountyBtn:SetScript("OnClick", function()
		if selectedResource and GSF.SupplyBounties then
			local resName = GSF.Atlas:GetDisplayName(selectedResource)
			GSF.SupplyBounties:CreateBounty(resName, 20, selectedResource.category, "Needed for crafting")
			activeView = "BOUNTIES"
			Tab:Refresh()
		end
	end)

	-- Container for Bounties View
	local bountiesContainer = CreateFrame("Frame", nil, frame)
	bountiesContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -42)
	bountiesContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
	bountiesContainer:Hide()
	self.bountiesContainer = bountiesContainer

	self.bountyCards = {}
	local bountyScroll, bountyContent = GSF.UI:CreateScrollList(bountiesContainer, 700, 360)
	bountyScroll:SetPoint("TOPLEFT", bountiesContainer, "TOPLEFT", 5, -5)
	bountyScroll:SetPoint("BOTTOMRIGHT", bountiesContainer, "BOTTOMRIGHT", -5, 5)
	self.bountyScroll = bountyScroll
	self.bountyContent = bountyContent

	return frame
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
		table.insert(zoneLines, "• " .. z)
	end
	self.zonesText:SetText(#zoneLines > 0 and table.concat(zoneLines, "\n") or "None")
	self.yieldsText:SetText(res.yields or "None")
	self.tipsText:SetText(res.tips or "No specific notes.")
end

function Tab:UpdateTexts()
	if not self.frame then return end
	if self.searchLabel then self.searchLabel:SetText(GSF.L["SEARCH_ATLAS"]) end
	if self.atlasViewBtn then self.atlasViewBtn:SetText(GSF.L["VIEW_ATLAS"]) end
	if self.bountyViewBtn then self.bountyViewBtn:SetText(GSF.L["VIEW_BOUNTIES"]) end
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
		self:RefreshAtlas()
	else
		self.atlasContainer:Hide()
		self.bountiesContainer:Show()
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

	for _, card in ipairs(self.bountyCards) do card:Hide() end

	local yOffset = 0
	for i, b in ipairs(bounties) do
		local card = self.bountyCards[i]
		if not card then
			card = CreateFrame("Frame", nil, self.bountyContent)
			card:SetSize(700, 56)
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

			local actionBtn = GSF.UI:CreateButton(card, "Claim", 90, 20)
			actionBtn:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -12, 8)
			card.actionBtn = actionBtn

			local mailBtn = GSF.UI:CreateButton(card, "📬 Mail", 70, 20)
			mailBtn:SetPoint("RIGHT", actionBtn, "LEFT", -6, 0)
			card.mailBtn = mailBtn

			table.insert(self.bountyCards, card)
		end

		card:SetPoint("TOPLEFT", self.bountyContent, "TOPLEFT", 0, -yOffset)

		local reqFormatted = GSF.Alts:GetFormattedName(b.requester)
		card.itemText:SetText(string.format("|cff%s%s|r x%d (|cffffd100%s|r)", GSF.COLORS.PRIMARY, b.item, b.count or 1, b.category or "General"))
		card.details:SetText(string.format("Requested by: %s  •  Note: %s", reqFormatted, b.notes ~= "" and b.notes or "None"))

		if b.status == GSF.ORDER_STATUS.OPEN then
			card.statusText:SetText("|cff00ff00" .. (GSF.L["STATUS_OPEN"] or "OPEN") .. "|r")
			card.actionBtn:SetText(GSF.L["CLAIM_BOUNTY"] or "Claim")
			card.actionBtn:SetScript("OnClick", function()
				GSF.SupplyBounties:ClaimBounty(b.id)
				Tab:Refresh()
			end)
			card.mailBtn:Hide()

		elseif b.status == GSF.ORDER_STATUS.CLAIMED then
			local claimerFormatted = GSF.Alts:GetFormattedName(b.claimer)
			card.statusText:SetText(string.format("|cffffd100" .. (GSF.L["STATUS_CLAIMED"] or "CLAIMED") .. "|r (%s)", claimerFormatted))

			if b.claimer == myName then
				card.actionBtn:SetText(GSF.L["COMPLETE_ORDER"] or "Complete")
				card.actionBtn:SetScript("OnClick", function()
					GSF.SupplyBounties:FulfillBounty(b.id)
					Tab:Refresh()
				end)
				card.mailBtn:Show()
				card.mailBtn:SetScript("OnClick", function()
					if GSF.MailHelper then
						GSF.MailHelper:PrepareBountyMail(b.requester, b.id, b.item, b.count)
					end
				end)
			else
				card.actionBtn:SetText(GSF.L["STATUS_CLAIMED"] or "In Progress")
				card.mailBtn:Hide()
			end

		elseif b.status == GSF.ORDER_STATUS.IN_TRANSIT then
			local mins = math.floor((time() - (b.mailedAt or time())) / 60)
			card.statusText:SetText(string.format("|cff00ccff📬 %s (%dm ago)|r", GSF.L["STATUS_IN_TRANSIT"] or "IN TRANSIT", mins))

			if b.requester == myName or b.claimer == myName then
				card.actionBtn:SetText(GSF.L["CONFIRM_RECEIVED"] or "Confirm Received")
				card.actionBtn:SetScript("OnClick", function()
					GSF.SupplyBounties:FulfillBounty(b.id)
					Tab:Refresh()
				end)
			else
				card.actionBtn:SetText(GSF.L["STATUS_IN_TRANSIT"] or "In Transit")
			end
			card.mailBtn:Hide()

		elseif b.status == GSF.ORDER_STATUS.COMPLETED then
			card.statusText:SetText("|cff00ff00✅ " .. (GSF.L["STATUS_COMPLETED"] or "COMPLETED") .. "|r")
			card.actionBtn:SetText(GSF.L["STATUS_COMPLETED"] or "Done")
			card.mailBtn:Hide()
		end

		card:Show()
		yOffset = yOffset + 60
	end

	self.bountyContent:SetHeight(math.max(yOffset, 370))
end
