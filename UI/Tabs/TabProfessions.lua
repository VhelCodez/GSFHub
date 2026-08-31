local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabProfessions = Tab

local selectedRecipe = nil

function Tab:Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	self.frame = frame

	-- Search Input with inline hint placeholder
	local searchBox = GSF.UI:CreateEditBox(frame, 150, 22)
	searchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -12)
	searchBox.isGSFInput = true
	self.searchBox = searchBox

	local searchHint = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	searchHint:SetPoint("LEFT", searchBox, "LEFT", 5, 0)
	searchHint:SetText(GSF.L["SEARCH_RECIPES"] or "Search recipes, items, or reagents...")
	searchBox.searchHint = searchHint
	searchBox:HookScript("OnTextChanged", function(eb)
		if eb:GetText() ~= "" then searchHint:Hide() else searchHint:Show() end
		Tab:Refresh()
	end)

	local currentProfFilter = "ALL"
	local filterBtn = CreateFrame("Button", "GSFProfFilterDropdown", frame, "UIDropDownMenuTemplate")
	filterBtn:SetPoint("LEFT", searchBox, "RIGHT", 4, -2)
	UIDropDownMenu_SetWidth(filterBtn, 125)
	UIDropDownMenu_SetText(filterBtn, GSF.L["FILTER_ALL_PROFESSIONS"])
	self.filterBtn = filterBtn

	local profKeys = {
		"Alchemy", "Blacksmithing", "Enchanting", "Engineering",
		"Leatherworking", "Tailoring", "Jewelcrafting",
		"Cooking", "First Aid", "Lockpicking"
	}

	UIDropDownMenu_Initialize(filterBtn, function(self, level)
		local allInfo = UIDropDownMenu_CreateInfo()
		allInfo.text = GSF.L["FILTER_ALL_PROFESSIONS"]
		allInfo.value = "ALL"
		allInfo.func = function(btn)
			currentProfFilter = "ALL"
			UIDropDownMenu_SetSelectedValue(filterBtn, "ALL")
			UIDropDownMenu_SetText(filterBtn, GSF.L["FILTER_ALL_PROFESSIONS"])
			Tab:Refresh()
		end
		allInfo.checked = (currentProfFilter == "ALL")
		UIDropDownMenu_AddButton(allInfo, level)

		for _, pKey in ipairs(profKeys) do
			local locName = GSF:GetLocalizedProfession(pKey)
			local info = UIDropDownMenu_CreateInfo()
			info.text = locName
			info.value = pKey
			info.func = function(btn)
				currentProfFilter = btn.value
				UIDropDownMenu_SetSelectedValue(filterBtn, btn.value)
				UIDropDownMenu_SetText(filterBtn, locName)
				Tab:Refresh()
			end
			info.checked = (currentProfFilter == pKey)
			UIDropDownMenu_AddButton(info, level)
		end
	end)
	self.getProfFilter = function() return currentProfFilter end

	-- Online Only Checkbox
	local onlineCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	onlineCheck:SetPoint("LEFT", filterBtn, "RIGHT", -10, 2)
	onlineCheck.text:SetText(GSF.L["FILTER_ONLINE_ONLY"])
	onlineCheck.text:SetFontObject("GameFontHighlightSmall")
	onlineCheck.text:ClearAllPoints()
	onlineCheck.text:SetPoint("LEFT", onlineCheck, "RIGHT", 2, 1)
	self.onlineCheck = onlineCheck

	onlineCheck:SetScript("OnClick", function()
		Tab:Refresh()
	end)

	-- Left List (Recipe items)
	local leftScroll, leftContent = GSF.UI:CreateScrollList(frame, 320, 380)
	leftScroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -45)
	self.leftScroll = leftScroll
	self.leftContent = leftContent
	self.recipeButtons = {}

	local emptyText = leftScroll:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	emptyText:SetPoint("CENTER", leftScroll, "CENTER", 0, 0)
	emptyText:SetWidth(280)
	emptyText:SetText(GSF.L["NO_RECIPES_FOUND"])
	emptyText:Hide()
	self.emptyText = emptyText

	-- Right Pane (Recipe Details & Crafters)
	local rightPane = CreateFrame("Frame", nil, frame)
	rightPane:SetPoint("TOPLEFT", leftScroll, "TOPRIGHT", 15, 0)
	rightPane:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
	GSF.UI:CreateBackdrop(rightPane, false)
	rightPane:SetBackdropColor(0.04, 0.04, 0.06, 0.7)
	self.rightPane = rightPane

	-- Detail Header Icon & Titles
	local detailIconBtn = CreateFrame("Button", nil, rightPane)
	detailIconBtn:SetSize(28, 28)
	detailIconBtn:SetPoint("TOPLEFT", rightPane, "TOPLEFT", 15, -15)
	local detailIcon = detailIconBtn:CreateTexture(nil, "ARTWORK")
	detailIcon:SetAllPoints()
	detailIconBtn.icon = detailIcon
	detailIconBtn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
	detailIconBtn:RegisterForClicks("LeftButtonUp")
	self.detailIconBtn = detailIconBtn

	local detailTitle = rightPane:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	detailTitle:SetPoint("LEFT", detailIconBtn, "RIGHT", 8, 6)
	detailTitle:SetPoint("RIGHT", rightPane, "RIGHT", -15, 0)
	detailTitle:SetJustifyH("LEFT")
	detailTitle:SetText(GSF.L["SELECT_RECIPE_PROMPT"])
	self.detailTitle = detailTitle

	local detailSub = rightPane:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	detailSub:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -2)
	detailSub:SetJustifyH("LEFT")
	self.detailSub = detailSub

	-- Reagents Section (Interactive 2-column badges)
	local reagentsLabel = rightPane:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	reagentsLabel:SetPoint("TOPLEFT", detailIconBtn, "BOTTOMLEFT", 0, -14)
	reagentsLabel:SetText(GSF.L["REAGENTS_REQUIRED"])
	self.reagentsLabel = reagentsLabel

	local reagentsContainer = CreateFrame("Frame", nil, rightPane)
	reagentsContainer:SetPoint("TOPLEFT", reagentsLabel, "BOTTOMLEFT", 0, -6)
	reagentsContainer:SetSize(325, 20)
	self.reagentsContainer = reagentsContainer
	self.reagentButtons = {}

	local noReagentsText = reagentsContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	noReagentsText:SetPoint("TOPLEFT", reagentsContainer, "TOPLEFT", 0, 0)
	noReagentsText:SetJustifyH("LEFT")
	noReagentsText:SetText(GSF.L["NO_EXTRA_REAGENTS"])
	self.noReagentsText = noReagentsText

	-- Crafters Section
	local craftersLabel = rightPane:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	craftersLabel:SetPoint("TOPLEFT", reagentsContainer, "BOTTOMLEFT", 0, -12)
	craftersLabel:SetText(GSF.L["CRAFTERS_KNOWN"])
	self.craftersLabel = craftersLabel

	local craftersScroll, craftersContent = GSF.UI:CreateScrollList(rightPane, 325, 140)
	craftersScroll:SetPoint("TOPLEFT", craftersLabel, "BOTTOMLEFT", 0, -6)
	craftersScroll:SetPoint("BOTTOMRIGHT", rightPane, "BOTTOMRIGHT", -26, 48)
	self.craftersScroll = craftersScroll
	self.craftersContent = craftersContent
	self.crafterRows = {}

	-- Action buttons bottom right (streamlined to 2 prominent, balanced buttons)
	local orderBtn = GSF.UI:CreateButton(rightPane, GSF.L["REQUEST_CRAFT"], 170, 24)
	orderBtn:SetPoint("BOTTOMLEFT", rightPane, "BOTTOMLEFT", 10, 12)
	orderBtn:Disable()
	self.orderBtn = orderBtn

	orderBtn:SetScript("OnClick", function()
		if selectedRecipe and GSF.TabWorkOrders then
			GSF.MainFrame:SelectTab(2)
			local link = selectedRecipe.itemLink or selectedRecipe.recipeLink
			local id = selectedRecipe.spellId
			if link and link:match("item:(%d+)") then
				id = tonumber(link:match("item:(%d+)"))
			end
			GSF.TabWorkOrders:OpenCreateModal(selectedRecipe.name, selectedRecipe.profession, 1, nil, true, nil, link, id)
		end
	end)

	local reqMatsBtn = GSF.UI:CreateButton(rightPane, GSF.L["REQUEST_MATS_BTN"] or "Request Mats", 170, 24)
	reqMatsBtn:SetPoint("BOTTOMRIGHT", rightPane, "BOTTOMRIGHT", -10, 12)
	reqMatsBtn:Disable()
	self.reqMatsBtn = reqMatsBtn

	reqMatsBtn:SetScript("OnClick", function()
		if selectedRecipe then
			Tab:OpenMatsModal(selectedRecipe)
		end
	end)

	-- Build Batch Materials Request Modal
	self:BuildMatsModal(frame)

	return frame
end

function Tab:UpdateTexts()
	if not self.frame then return end
	if self.searchBox and self.searchBox.searchHint then
		self.searchBox.searchHint:SetText(GSF.L["SEARCH_RECIPES"] or "Search recipes, items, or reagents...")
	end
	if self.filterBtn and self.getProfFilter then
		local cur = self.getProfFilter()
		local locText = (cur == "ALL") and GSF.L["FILTER_ALL_PROFESSIONS"] or GSF:GetLocalizedProfession(cur)
		UIDropDownMenu_SetText(self.filterBtn, locText)
	end
	if self.onlineCheck then self.onlineCheck.text:SetText(GSF.L["FILTER_ONLINE_ONLY"]) end
	if self.emptyText then self.emptyText:SetText(GSF.L["NO_RECIPES_FOUND"]) end
	if self.reagentsLabel then self.reagentsLabel:SetText(GSF.L["REAGENTS_REQUIRED"]) end
	if self.craftersLabel then self.craftersLabel:SetText(GSF.L["CRAFTERS_KNOWN"]) end
	if self.orderBtn then self.orderBtn:SetText(GSF.L["REQUEST_CRAFT"]) end
	if self.reqMatsBtn then self.reqMatsBtn:SetText(GSF.L["REQUEST_MATS_BTN"] or "Request Mats") end
	if not selectedRecipe then
		if self.detailIconBtn then self.detailIconBtn:Hide() end
		if self.detailTitle then self.detailTitle:SetText(GSF.L["SELECT_RECIPE_PROMPT"]) end
		if self.detailSub then self.detailSub:SetText("") end
		if self.noReagentsText then self.noReagentsText:SetText(GSF.L["NO_EXTRA_REAGENTS"]) end
	else
		self:DisplayRecipeDetails(selectedRecipe)
	end
	self:Refresh()
end

function Tab:Refresh()
	if not self.frame or not self.frame:IsShown() then return end

	local query = self.searchBox:GetText()
	local prof = self.getProfFilter()
	local onlineOnly = self.onlineCheck:GetChecked()

	local results = GSF.RecipeBook:Search(query, prof, onlineOnly)

	-- Recycle buttons
	for _, btn in ipairs(self.recipeButtons) do btn:Hide() end

	local yOffset = 0
	for i, recipe in ipairs(results) do
		local btn = self.recipeButtons[i]
		if not btn then
			btn = CreateFrame("Button", nil, self.leftContent)
			btn:SetSize(290, 28)
			if BackdropTemplateMixin then Mixin(btn, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(btn, false)
			btn:SetBackdropColor(0.12, 0.12, 0.16, 0.6)

			local icon = btn:CreateTexture(nil, "ARTWORK")
			icon:SetSize(20, 20)
			icon:SetPoint("LEFT", btn, "LEFT", 4, 0)
			btn.icon = icon

			local title = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			title:SetPoint("LEFT", icon, "RIGHT", 6, 0)
			title:SetPoint("RIGHT", btn, "RIGHT", -50, 0)
			title:SetJustifyH("LEFT")
			btn.title = title

			local tag = btn:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			tag:SetPoint("RIGHT", btn, "RIGHT", -6, 0)
			btn.tag = tag

			btn:RegisterForClicks("LeftButtonUp")
			table.insert(self.recipeButtons, btn)
		end

		btn:SetPoint("TOPLEFT", self.leftContent, "TOPLEFT", 0, -yOffset)
		btn.recipe = recipe

		local canon = GSF.GetCanonicalProfession and GSF:GetCanonicalProfession(recipe.profession) or recipe.profession
		local itemIcon = nil
		local q = 1
		if recipe.itemLink then
			local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(recipe.itemLink)
			itemIcon = texture
			q = quality or 1
		end
		if not itemIcon and recipe.spellId then
			local _, _, texture = GetSpellInfo(recipe.spellId)
			itemIcon = texture
		end
		local profInfo = GSF.PROFESSIONS[canon] or GSF.PROFESSIONS[recipe.profession]
		btn.icon:SetTexture(itemIcon or (profInfo and profInfo.icon) or "Interface\\Icons\\INV_Misc_QuestionMark")

		local color = ITEM_QUALITY_COLORS[q]
		local hex = (color and color.hex) or "|cffffffff"
		if not hex:find("^|c") then hex = "|c" .. hex end

		btn.title:SetText(string.format("%s%s|r", hex, recipe.name or "Unknown"))
		btn.tag:SetText(string.format("(%d)", #recipe.crafters))

		local isSelected = selectedRecipe and (selectedRecipe.name == recipe.name and selectedRecipe.profession == recipe.profession)
		if isSelected then
			btn:SetBackdropBorderColor(1.0, 0.82, 0.0, 1.0)
			btn:SetBackdropColor(0.20, 0.16, 0.04, 0.85)
		else
			btn:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.5)
			btn:SetBackdropColor(0.12, 0.12, 0.16, 0.6)
		end

		-- Recipe Tooltip on hover
		btn:SetScript("OnEnter", function(b)
			GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
			local link = recipe.recipeLink or recipe.itemLink
			if link then
				GameTooltip:SetHyperlink(link)
			elseif recipe.spellId then
				local sLink = GetSpellLink and GetSpellLink(recipe.spellId)
				if sLink then
					GameTooltip:SetHyperlink(sLink)
				elseif GameTooltip.SetSpellByID then
					GameTooltip:SetSpellByID(recipe.spellId)
				else
					GameTooltip:SetHyperlink("spell:" .. recipe.spellId)
				end
			else
				GameTooltip:SetText(recipe.name or "Unknown")
			end
			GameTooltip:Show()
		end)
		btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

		btn:SetScript("OnClick", function()
			if IsModifiedClick("CHATLINK") then
				local link = recipe.recipeLink or recipe.itemLink
				if not link and recipe.spellId then
					link = GetSpellLink and GetSpellLink(recipe.spellId)
				end
				if not link and recipe.spellId then
					local sName = GetSpellInfo(recipe.spellId)
					if sName then link = string.format("|cff71d5ff|Hspell:%d|h[%s]|h|r", recipe.spellId, sName) end
				end
				if link then
					ChatEdit_InsertLink(link)
				end
			else
				Tab:SelectRecipe(recipe)
				Tab:Refresh()
			end
		end)

		btn:Show()
		yOffset = yOffset + 30
	end

	self.leftContent:SetHeight(math.max(yOffset, 1))

	-- Auto-hide left scrollbar if content does not overflow or when empty
	local leftScrollBar = self.leftScroll and (self.leftScroll.ScrollBar or (self.leftScroll:GetName() and _G[self.leftScroll:GetName() .. "ScrollBar"]))
	if leftScrollBar then
		if #results == 0 or yOffset <= 360 then
			leftScrollBar:Hide()
		else
			leftScrollBar:Show()
		end
	end

	if #results == 0 then
		self.emptyText:Show()
	else
		self.emptyText:Hide()
	end

	if selectedRecipe then
		self:DisplayRecipeDetails(selectedRecipe)
	else
		if self.detailIconBtn then self.detailIconBtn:Hide() end
		if self.detailTitle then self.detailTitle:SetText(GSF.L["SELECT_RECIPE_PROMPT"]) end
		if self.detailSub then self.detailSub:SetText("") end
		if self.reagentsLabel then self.reagentsLabel:Hide() end
		if self.reagentsContainer then self.reagentsContainer:Hide() end
		if self.craftersLabel then self.craftersLabel:Hide() end
		if self.craftersScroll then self.craftersScroll:Hide() end
	end
end

function Tab:SelectRecipe(recipe)
	selectedRecipe = recipe
	if self.orderBtn then self.orderBtn:Enable() end
	if self.reqMatsBtn then self.reqMatsBtn:Enable() end
	self:DisplayRecipeDetails(recipe)
end

function Tab:DisplayRecipeDetails(recipe)
	if not recipe then return end

	if self.detailIconBtn then self.detailIconBtn:Show() end
	if self.reagentsLabel then self.reagentsLabel:Show() end
	if self.reagentsContainer then self.reagentsContainer:Show() end
	if self.craftersLabel then self.craftersLabel:Show() end
	if self.craftersScroll then self.craftersScroll:Show() end

	local canon = GSF.GetCanonicalProfession and GSF:GetCanonicalProfession(recipe.profession) or recipe.profession
	local locProf = GSF.GetLocalizedProfession and GSF:GetLocalizedProfession(recipe.profession) or recipe.profession

	local itemIcon = nil
	local q = 1
	if recipe.itemLink then
		local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(recipe.itemLink)
		itemIcon = texture
		q = quality or 1
	end
	if not itemIcon and recipe.spellId then
		local _, _, texture = GetSpellInfo(recipe.spellId)
		itemIcon = texture
	end
	local profInfo = GSF.PROFESSIONS[canon] or GSF.PROFESSIONS[recipe.profession]
	self.detailIconBtn.icon:SetTexture(itemIcon or (profInfo and profInfo.icon) or "Interface\\Icons\\INV_Misc_QuestionMark")

	local color = ITEM_QUALITY_COLORS[q]
	local hex = (color and color.hex) or "|cffffffff"
	if not hex:find("^|c") then hex = "|c" .. hex end

	self.detailTitle:SetText(string.format("%s%s|r", hex, recipe.name or "Unknown"))
	self.detailSub:SetText(string.format("|cffffd100%s|r  •  %s", locProf, recipe.skillType or "Recipe"))

	-- Tooltip & Shift-Click for detail header icon
	self.detailIconBtn:SetScript("OnEnter", function(b)
		GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
		local link = recipe.recipeLink or recipe.itemLink
		if link then
			GameTooltip:SetHyperlink(link)
		elseif recipe.spellId then
			local sLink = GetSpellLink and GetSpellLink(recipe.spellId)
			if sLink then
				GameTooltip:SetHyperlink(sLink)
			elseif GameTooltip.SetSpellByID then
				GameTooltip:SetSpellByID(recipe.spellId)
			else
				GameTooltip:SetHyperlink("spell:" .. recipe.spellId)
			end
		else
			GameTooltip:SetText(recipe.name or "Unknown")
		end
		GameTooltip:Show()
	end)
	self.detailIconBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.detailIconBtn:SetScript("OnClick", function()
		if IsModifiedClick("CHATLINK") then
			local link = recipe.recipeLink or recipe.itemLink
			if not link and recipe.spellId then
				link = GetSpellLink and GetSpellLink(recipe.spellId)
			end
			if not link and recipe.spellId then
				local sName = GetSpellInfo(recipe.spellId)
				if sName then link = string.format("|cff71d5ff|Hspell:%d|h[%s]|h|r", recipe.spellId, sName) end
			end
			if link then
				ChatEdit_InsertLink(link)
			end
		end
	end)

	-- Format interactive reagent badges (2-Column Grid)
	for _, btn in ipairs(self.reagentButtons or {}) do btn:Hide() end

	local reagents = recipe.reagents or {}
	local badgeW = 156
	local badgeH = 20
	local colSpacing = 8
	local rowH = 24
	local totalReagentRows = 0

	if #reagents > 0 then
		self.noReagentsText:Hide()
		for i, r in ipairs(reagents) do
			local btn = self.reagentButtons[i]
			if not btn then
				btn = CreateFrame("Button", nil, self.reagentsContainer)
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
				table.insert(self.reagentButtons, btn)
			end

			local rItemId = r.link and tonumber(r.link:match("item:(%d+)"))
			local rTexture, rQuality = nil, 1
			if r.link then
				local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(r.link)
				rTexture = texture
				rQuality = quality or 1
			end
			if not rTexture and rItemId then
				local yd = AtlasJournal and AtlasJournal.GetItemDetails and AtlasJournal:GetItemDetails(rItemId)
				if yd then
					rTexture = yd.icon
					rQuality = yd.quality or 1
				end
			end

			local qColor = ITEM_QUALITY_COLORS[rQuality]
			local rHex = (qColor and qColor.hex) or "|cffffffff"
			if not rHex:find("^|c") then rHex = "|c" .. rHex end

			btn.icon:SetTexture(rTexture or "Interface\\Icons\\INV_Misc_QuestionMark")
			local rCountStr = (r.count and r.count > 1) and string.format("%dx ", r.count) or ""
			btn.text:SetText(string.format("%s[%s%s|r]", rCountStr, rHex, r.name or "Reagent"))

			local col = (i - 1) % 2
			local row = math.floor((i - 1) / 2)
			btn:ClearAllPoints()
			btn:SetPoint("TOPLEFT", self.reagentsContainer, "TOPLEFT", col * (badgeW + colSpacing), -row * rowH)
			btn:SetSize(badgeW, badgeH)
			btn:Show()

			btn:SetScript("OnEnter", function(b)
				GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
				if r.link then
					GameTooltip:SetHyperlink(r.link)
				elseif rItemId then
					GameTooltip:SetItemByID(rItemId)
				else
					GameTooltip:SetText(r.name or "Reagent")
				end
				GameTooltip:Show()
			end)
			btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

			btn:SetScript("OnClick", function(b)
				if IsModifiedClick("CHATLINK") and r.link then
					ChatEdit_InsertLink(r.link)
				else
					local targetId = rItemId or r.name
					local targetRes = AtlasJournal and AtlasJournal.FindResource and AtlasJournal:FindResource(targetId)
					if targetRes and GSF.MainFrame and GSF.TabAtlas then
						GSF.MainFrame:SelectTab(5) -- Atlas tab
						GSF.TabAtlas:SelectResource(targetRes)
					end
				end
			end)
		end
		totalReagentRows = math.ceil(#reagents / 2)
		local containerH = totalReagentRows * rowH
		self.reagentsContainer:SetHeight(math.max(containerH, 20))
	else
		self.noReagentsText:Show()
		self.reagentsContainer:SetHeight(20)
	end

	-- Format crafters
	for _, row in ipairs(self.crafterRows) do row:Hide() end

	local myName = GSF.DB:GetPlayerName()
	local yOffset = 0
	for i, crafter in ipairs(recipe.crafters or {}) do
		local row = self.crafterRows[i]
		if not row then
			row = CreateFrame("Frame", nil, self.craftersContent)
			row:SetSize(300, 24)

			local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			nameText:SetPoint("LEFT", row, "LEFT", 0, 0)
			row.nameText = nameText

			local skillText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			skillText:SetPoint("LEFT", nameText, "RIGHT", 8, 0)
			row.skillText = skillText

			local whisperBtn = GSF.UI:CreateButton(row, GSF.L["WHISPER"] or "Whisper", 65, 18)
			whisperBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
			row.whisperBtn = whisperBtn

			table.insert(self.crafterRows, row)
		end

		row:SetPoint("TOPLEFT", self.craftersContent, "TOPLEFT", 0, -yOffset)
		
		local statusIcon = crafter.online and "|TInterface\\FriendsFrame\\StatusIcon-Online:12:12:0:0|t" or "|TInterface\\FriendsFrame\\StatusIcon-Offline:12:12:0:0|t"
		local formattedName = GSF.Alts:GetFormattedName(crafter.name)
		row.nameText:SetText(string.format("%s %s", statusIcon, formattedName))
		row.skillText:SetText(string.format("[%d/%d]", crafter.skill or 0, crafter.maxSkill or 375))

		if crafter.name == myName then
			row.whisperBtn:Hide()
		else
			row.whisperBtn:Show()
			row.whisperBtn:SetScript("OnClick", function()
				ChatFrame_OpenChat(string.format("/w %s Hi, could you craft [%s]?", crafter.name, recipe.name))
			end)
		end

		row:Show()
		yOffset = yOffset + 26
	end

	self.craftersContent:SetHeight(math.max(yOffset, 1))

	-- Auto-hide scrollbar if list does not overflow
	local scrollBar = self.craftersScroll.ScrollBar or (self.craftersScroll:GetName() and _G[self.craftersScroll:GetName() .. "ScrollBar"])
	if scrollBar then
		if not recipe.crafters or #recipe.crafters == 0 or yOffset <= 140 then
			scrollBar:Hide()
		else
			scrollBar:Show()
		end
	end
end

function Tab:BuildMatsModal(parent)
	local modal = CreateFrame("Frame", "GSFRecipeMatsModal", parent)
	modal:SetSize(420, 390)
	modal:SetPoint("CENTER", parent, "CENTER", 0, 0)
	modal:SetFrameStrata("DIALOG")
	modal:EnableMouse(true)
	if BackdropTemplateMixin then Mixin(modal, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(modal, false)
	modal:SetBackdropColor(0.08, 0.08, 0.12, 1.0)
	modal:Hide()
	self.matsModal = modal

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

	-- Modal Title
	local title = modal:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", modal, "TOP", 0, -15)
	title:SetText(string.format("|cff%s%s|r", GSF.COLORS.PRIMARY, GSF.L["REQUEST_MATS_MODAL_TITLE"] or "Materialien anfordern"))
	modal.title = title

	-- Recipe Header Banner
	local icon = modal:CreateTexture(nil, "ARTWORK")
	icon:SetSize(28, 28)
	icon:SetPoint("TOPLEFT", modal, "TOPLEFT", 22, -45)
	modal.recipeIcon = icon

	local recipeName = modal:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	recipeName:SetPoint("LEFT", icon, "RIGHT", 8, 6)
	recipeName:SetPoint("RIGHT", modal, "RIGHT", -20, 0)
	recipeName:SetJustifyH("LEFT")
	modal.recipeName = recipeName

	local recipeSub = modal:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	recipeSub:SetPoint("TOPLEFT", recipeName, "BOTTOMLEFT", 0, -2)
	recipeSub:SetJustifyH("LEFT")
	modal.recipeSub = recipeSub

	-- Crafts Multiplier Row
	local qtyLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	qtyLabel:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -14)
	qtyLabel:SetText(GSF.L["CRAFTS_COUNT_LABEL"] or "Anzahl der Herstellungen:")
	modal.qtyLabel = qtyLabel

	local qtyBox = GSF.UI:CreateEditBox(modal, 60, 22)
	qtyBox:SetPoint("LEFT", qtyLabel, "RIGHT", 8, 0)
	qtyBox:SetText("1")
	modal.qtyBox = qtyBox

	-- Select Materials Label + Toggle All
	local matsLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	matsLabel:SetPoint("TOPLEFT", qtyLabel, "BOTTOMLEFT", 0, -14)
	matsLabel:SetText(GSF.L["SELECT_MATS_LABEL"] or "Gewünschte Materialien auswählen:")
	modal.matsLabel = matsLabel

	local toggleBtn = CreateFrame("Button", nil, modal)
	toggleBtn:SetPoint("RIGHT", modal, "RIGHT", -22, 0)
	toggleBtn:SetPoint("CENTER", matsLabel, "CENTER", 0, 0)
	toggleBtn:SetSize(110, 16)
	local toggleText = toggleBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	toggleText:SetAllPoints()
	toggleText:SetJustifyH("RIGHT")
	toggleText:SetText(string.format("|cff%s%s|r", GSF.COLORS.LINK or "00c0ff", GSF.L["DESELECT_ALL"] or "Alle abwählen"))
	toggleBtn.text = toggleText
	modal.toggleBtn = toggleBtn

	-- Reagent Checklist Scroll Area
	local matsScroll, matsContent = GSF.UI:CreateScrollList(modal, 375, 120)
	matsScroll:SetPoint("TOPLEFT", matsLabel, "BOTTOMLEFT", 0, -6)
	matsScroll:SetPoint("RIGHT", modal, "RIGHT", -22, 0)
	modal.matsScroll = matsScroll
	modal.matsContent = matsContent
	modal.reagentRows = {}

	-- Notes EditBox
	local notesLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	notesLabel:SetPoint("TOPLEFT", matsScroll, "BOTTOMLEFT", 0, -10)
	notesLabel:SetText(GSF.L["NOTES_SPECS_TIP"] or "Notizen / Spezifikationen / Trinkgeld (optional):")
	modal.notesLabel = notesLabel

	local notesBox = GSF.UI:CreateEditBox(modal, 375, 22)
	notesBox:SetPoint("TOPLEFT", notesLabel, "BOTTOMLEFT", 0, -4)
	modal.notesBox = notesBox

	-- Error Notification Text
	local errorText = modal:CreateFontString(nil, "OVERLAY", "GameFontRedSmall")
	errorText:SetPoint("BOTTOMLEFT", modal, "BOTTOMLEFT", 20, 44)
	errorText:SetPoint("BOTTOMRIGHT", modal, "BOTTOMRIGHT", -20, 44)
	errorText:SetJustifyH("CENTER")
	errorText:Hide()
	modal.errorText = errorText

	-- Submit & Cancel Buttons
	local submitBtn = GSF.UI:CreateButton(modal, GSF.L["POST_BOUNTIES_BTN"] or "Aufträge erstellen", 150, 24)
	submitBtn:SetPoint("BOTTOMLEFT", modal, "BOTTOMLEFT", 50, 14)
	modal.submitBtn = submitBtn

	local cancelBtn = GSF.UI:CreateButton(modal, GSF.L["CANCEL"] or "Abbrechen", 100, 24)
	cancelBtn:SetPoint("BOTTOMRIGHT", modal, "BOTTOMRIGHT", -50, 14)
	modal.cancelBtn = cancelBtn

	cancelBtn:SetScript("OnClick", function()
		modal:Hide()
	end)

	local function UpdateReagentCounts()
		local count = tonumber(qtyBox:GetText()) or 1
		if count < 1 then count = 1 end
		for _, row in ipairs(modal.reagentRows) do
			if row:IsShown() and row.reagent then
				local perCraft = row.reagent.count or 1
				local total = perCraft * count
				row.countText:SetText(string.format("%dx  (|cffffd100%d %s|r)", total, perCraft, GSF.L["PER_CRAFT"] or "pro Stk."))
			end
		end
	end

	qtyBox:HookScript("OnTextChanged", function()
		if modal.errorText and modal.errorText:IsShown() then modal.errorText:Hide() end
		UpdateReagentCounts()
	end)

	local allSelected = true
	toggleBtn:SetScript("OnClick", function()
		allSelected = not allSelected
		for _, row in ipairs(modal.reagentRows) do
			if row:IsShown() and row.check then
				row.check:SetChecked(allSelected)
			end
		end
		toggleText:SetText(string.format("|cff%s%s|r", GSF.COLORS.LINK or "00c0ff", allSelected and (GSF.L["DESELECT_ALL"] or "Alle abwählen") or (GSF.L["SELECT_ALL"] or "Alle auswählen")))
	end)

	submitBtn:SetScript("OnClick", function()
		local recipe = modal.recipe
		if not recipe then return end

		local qty = tonumber(qtyBox:GetText()) or 1
		if qty < 1 then
			modal.errorText:SetText(GSF.L["INVALID_AMOUNT_ERROR"] or "Please enter a valid amount.")
			modal.errorText:Show()
			return
		end

		local notes = notesBox:GetText()
		notes = notes and notes:match("^%s*(.-)%s*$") or ""

		local anyChecked = false
		local reagents = recipe.reagents or {}
		if #reagents == 0 then
			anyChecked = true
			local rItemId = recipe.itemLink and tonumber(recipe.itemLink:match("item:(%d+)"))
			local rIcon = modal.recipeIcon and modal.recipeIcon:GetTexture()
			GSF.SupplyBounties:CreateBounty(recipe.name, qty, recipe.profession or "Crafting", notes ~= "" and notes or ("For " .. recipe.name), nil, rItemId, recipe.itemLink, rIcon)
		else
			for _, row in ipairs(modal.reagentRows) do
				if row:IsShown() and row.check:GetChecked() and row.reagent then
					anyChecked = true
					local perCraft = row.reagent.count or 1
					local totalCount = perCraft * qty
					local noteStr = notes ~= "" and notes or ("For " .. recipe.name .. (qty > 1 and string.format(" (%dx)", qty) or ""))
					local rItemId = row.reagent.link and tonumber(row.reagent.link:match("item:(%d+)"))
					local rIcon = row.icon and row.icon:GetTexture()
					GSF.SupplyBounties:CreateBounty(row.reagent.name, totalCount, recipe.profession or "Crafting", noteStr, nil, rItemId, row.reagent.link, rIcon)
				end
			end
		end

		if not anyChecked then
			modal.errorText:SetText(GSF.L["NO_MATS_SELECTED_ERROR"] or "Bitte wähle mindestens ein Material aus.")
			modal.errorText:Show()
			return
		end

		modal:Hide()
		if GSF.MainFrame then
			GSF.MainFrame:SelectTab(5)
		end
		if GSF.TabAtlas then
			GSF.TabAtlas:SwitchView("BOUNTIES")
		end
	end)

	return modal
end

function Tab:OpenMatsModal(recipe)
	if not self.matsModal then return end
	local modal = self.matsModal
	modal.recipe = recipe
	if modal.errorText then modal.errorText:Hide() end

	local canon = GSF.GetCanonicalProfession and GSF:GetCanonicalProfession(recipe.profession) or recipe.profession
	local locProf = GSF.GetLocalizedProfession and GSF:GetLocalizedProfession(recipe.profession) or recipe.profession

	local itemIcon = nil
	local q = 1
	if recipe.itemLink then
		local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(recipe.itemLink)
		itemIcon = texture
		q = quality or 1
	end
	if not itemIcon and recipe.spellId then
		local _, _, texture = GetSpellInfo(recipe.spellId)
		itemIcon = texture
	end
	local profInfo = GSF.PROFESSIONS[canon] or GSF.PROFESSIONS[recipe.profession]
	modal.recipeIcon:SetTexture(itemIcon or (profInfo and profInfo.icon) or "Interface\\Icons\\INV_Misc_QuestionMark")

	local color = ITEM_QUALITY_COLORS[q]
	local hex = (color and color.hex) or "|cffffffff"
	if not hex:find("^|c") then hex = "|c" .. hex end

	modal.recipeName:SetText(string.format("%s%s|r", hex, recipe.name or "Unknown"))
	modal.recipeSub:SetText(string.format("|cffffd100%s|r  •  %s", locProf, recipe.skillType or "Recipe"))

	modal.qtyBox:SetText("1")
	modal.notesBox:SetText("")

	-- Hide existing rows
	for _, r in ipairs(modal.reagentRows) do r:Hide() end

	local reagents = recipe.reagents or {}
	local yOffset = 0
	for i, reagent in ipairs(reagents) do
		local row = modal.reagentRows[i]
		if not row then
			row = CreateFrame("Frame", nil, modal.matsContent)
			row:SetSize(350, 24)

			local check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
			check:SetPoint("LEFT", row, "LEFT", 0, 0)
			check:SetSize(20, 20)
			row.check = check

			local rIcon = row:CreateTexture(nil, "ARTWORK")
			rIcon:SetSize(16, 16)
			rIcon:SetPoint("LEFT", check, "RIGHT", 4, 0)
			row.icon = rIcon

			local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			nameText:SetPoint("LEFT", rIcon, "RIGHT", 6, 0)
			nameText:SetPoint("RIGHT", row, "RIGHT", -120, 0)
			nameText:SetJustifyH("LEFT")
			nameText:SetWordWrap(false)
			row.nameText = nameText

			local countText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			countText:SetPoint("RIGHT", row, "RIGHT", 0, 0)
			countText:SetJustifyH("RIGHT")
			row.countText = countText

			row:EnableMouse(true)
			row:SetScript("OnEnter", function(self)
				if self.reagent and self.reagent.link then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetHyperlink(self.reagent.link)
					GameTooltip:Show()
				end
			end)
			row:SetScript("OnLeave", function() GameTooltip:Hide() end)

			table.insert(modal.reagentRows, row)
		end

		row.reagent = reagent
		row.check:SetChecked(true)

		local rItemId = reagent.link and tonumber(reagent.link:match("item:(%d+)"))
		local rTexture, rQuality = nil, 1
		if reagent.link then
			local _, _, quality, _, _, _, _, _, _, texture = GetItemInfo(reagent.link)
			rTexture = texture
			rQuality = quality or 1
		end
		if not rTexture and rItemId and AtlasJournal and AtlasJournal.GetItemDetails then
			local yd = AtlasJournal:GetItemDetails(rItemId)
			if yd then
				rTexture = yd.icon
				rQuality = yd.quality or 1
			end
		end

		local qColor = ITEM_QUALITY_COLORS[rQuality]
		local rHex = (qColor and qColor.hex) or "|cffffffff"
		if not rHex:find("^|c") then rHex = "|c" .. rHex end

		row.icon:SetTexture(rTexture or "Interface\\Icons\\INV_Misc_QuestionMark")
		row.nameText:SetText(string.format("%s%s|r", rHex, reagent.name or "Reagent"))
		local perCount = reagent.count or 1
		row.countText:SetText(string.format("%dx  (|cffffd100%d %s|r)", perCount, perCount, GSF.L["PER_CRAFT"] or "pro Stk."))

		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", modal.matsContent, "TOPLEFT", 0, -yOffset)
		row:Show()

		yOffset = yOffset + 24
	end

	modal.matsContent:SetHeight(math.max(yOffset, 1))

	local scrollBar = modal.matsScroll.ScrollBar or (modal.matsScroll:GetName() and _G[modal.matsScroll:GetName() .. "ScrollBar"])
	if scrollBar then
		if #reagents <= 4 then
			scrollBar:Hide()
		else
			scrollBar:Show()
		end
	end

	modal.toggleBtn.text:SetText(string.format("|cff%s%s|r", GSF.COLORS.LINK or "00c0ff", GSF.L["DESELECT_ALL"] or "Alle abwählen"))
	modal:Show()
end
