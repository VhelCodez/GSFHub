local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabProfessions = Tab

local selectedRecipe = nil

function Tab:Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	self.frame = frame

	-- Search Input
	local searchLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	searchLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -10)
	searchLabel:SetText(GSF.L["SEARCH_RECIPES"])

	local searchBox = GSF.UI:CreateEditBox(frame, 220, 22)
	searchBox:SetPoint("TOPLEFT", searchLabel, "BOTTOMLEFT", 0, -4)
	self.searchBox = searchBox

	searchBox:SetScript("OnTextChanged", function(eb)
		Tab:Refresh()
	end)

	-- Profession Dropdown / Filter
	local filterLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	filterLabel:SetPoint("LEFT", searchLabel, "RIGHT", 160, 0)
	filterLabel:SetText("Profession:")

	local currentProfFilter = GSF.L["FILTER_ALL_PROFESSIONS"]
	local filterBtn = CreateFrame("Button", nil, frame, "UIDropDownMenuTemplate")
	filterBtn:SetPoint("LEFT", searchBox, "RIGHT", 10, -2)
	UIDropDownMenu_SetWidth(filterBtn, 140)
	UIDropDownMenu_SetText(filterBtn, currentProfFilter)
	self.filterBtn = filterBtn

	local profOptions = {
		GSF.L["FILTER_ALL_PROFESSIONS"],
		"Alchemy", "Blacksmithing", "Enchanting", "Engineering",
		"Leatherworking", "Tailoring", "Jewelcrafting",
		"Cooking", "First Aid", "Lockpicking"
	}

	UIDropDownMenu_Initialize(filterBtn, function(self, level)
		for _, prof in ipairs(profOptions) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = prof
			info.value = prof
			info.func = function(btn)
				currentProfFilter = btn.value
				UIDropDownMenu_SetSelectedValue(filterBtn, btn.value)
				UIDropDownMenu_SetText(filterBtn, btn.value)
				Tab:Refresh()
			end
			info.checked = (currentProfFilter == prof)
			UIDropDownMenu_AddButton(info, level)
		end
	end)
	self.getProfFilter = function() return currentProfFilter end

	-- Online Only Checkbox
	local onlineCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	onlineCheck:SetPoint("LEFT", filterBtn, "RIGHT", 140, 2)
	onlineCheck.text:SetText(GSF.L["FILTER_ONLINE_ONLY"])
	onlineCheck.text:SetFontObject("GameFontHighlightSmall")
	self.onlineCheck = onlineCheck

	onlineCheck:SetScript("OnClick", function()
		Tab:Refresh()
	end)

	-- Left List (Recipe items)
	local leftScroll, leftContent = GSF.UI:CreateScrollList(frame, 320, 360)
	leftScroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -65)
	self.leftScroll = leftScroll
	self.leftContent = leftContent
	self.recipeButtons = {}

	-- Right Pane (Recipe Details & Crafters)
	local rightPane = CreateFrame("Frame", nil, frame)
	rightPane:SetPoint("TOPLEFT", leftScroll, "TOPRIGHT", 25, 0)
	rightPane:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 20)
	GSF.UI:CreateBackdrop(rightPane, false)
	rightPane:SetBackdropColor(0.04, 0.04, 0.06, 0.7)
	self.rightPane = rightPane

	local detailTitle = rightPane:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	detailTitle:SetPoint("TOPLEFT", rightPane, "TOPLEFT", 15, -15)
	detailTitle:SetPoint("RIGHT", rightPane, "RIGHT", -15, 0)
	detailTitle:SetJustifyH("LEFT")
	detailTitle:SetText(GSF.L["SELECT_RECIPE_PROMPT"])
	self.detailTitle = detailTitle

	local reagentsLabel = rightPane:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	reagentsLabel:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -12)
	reagentsLabel:SetText(GSF.L["REAGENTS_REQUIRED"])
	self.reagentsLabel = reagentsLabel

	local reagentsText = rightPane:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	reagentsText:SetPoint("TOPLEFT", reagentsLabel, "BOTTOMLEFT", 0, -6)
	reagentsText:SetPoint("RIGHT", rightPane, "RIGHT", -15, 0)
	reagentsText:SetJustifyH("LEFT")
	reagentsText:SetText(GSF.L["NO_EXTRA_REAGENTS"])
	self.reagentsText = reagentsText

	local craftersLabel = rightPane:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	craftersLabel:SetPoint("TOPLEFT", reagentsText, "BOTTOMLEFT", 0, -15)
	craftersLabel:SetText(GSF.L["CRAFTERS_KNOWN"])
	self.craftersLabel = craftersLabel

	local craftersScroll, craftersContent = GSF.UI:CreateScrollList(rightPane, 320, 160)
	craftersScroll:SetPoint("TOPLEFT", craftersLabel, "BOTTOMLEFT", 0, -6)
	craftersScroll:SetPoint("BOTTOMRIGHT", rightPane, "BOTTOMRIGHT", -10, 50)
	self.craftersScroll = craftersScroll
	self.craftersContent = craftersContent
	self.crafterRows = {}

	-- Action buttons bottom right
	local orderBtn = GSF.UI:CreateButton(rightPane, GSF.L["REQUEST_CRAFT"], 130, 24)
	orderBtn:SetPoint("BOTTOMLEFT", rightPane, "BOTTOMLEFT", 15, 12)
	self.orderBtn = orderBtn

	orderBtn:SetScript("OnClick", function()
		if selectedRecipe and GSF.TabWorkOrders then
			GSF.MainFrame:SelectTab(2)
			GSF.TabWorkOrders:OpenCreateModal(selectedRecipe.name, selectedRecipe.profession)
		end
	end)

	local wishlistBtn = GSF.UI:CreateButton(rightPane, GSF.L["WISHLIST_BTN"], 80, 24)
	wishlistBtn:SetPoint("LEFT", orderBtn, "RIGHT", 6, 0)
	self.wishlistBtn = wishlistBtn

	wishlistBtn:SetScript("OnClick", function()
		if selectedRecipe and GSF.RecipeDrops then
			GSF.RecipeDrops:AddToWishlist(selectedRecipe.itemLink or selectedRecipe.name)
		end
	end)

	local reqMatsBtn = GSF.UI:CreateButton(rightPane, GSF.L["REQUEST_MATS_BTN"] or "Request Mats", 110, 24)
	reqMatsBtn:SetPoint("LEFT", wishlistBtn, "RIGHT", 6, 0)
	self.reqMatsBtn = reqMatsBtn

	reqMatsBtn:SetScript("OnClick", function()
		if selectedRecipe and GSF.SupplyBounties then
			if selectedRecipe.reagents and #selectedRecipe.reagents > 0 then
				for _, r in ipairs(selectedRecipe.reagents) do
					GSF.SupplyBounties:CreateBounty(r.name, r.count, selectedRecipe.profession or "Crafting", "For " .. selectedRecipe.name)
				end
			else
				GSF.SupplyBounties:CreateBounty(selectedRecipe.name, 1, selectedRecipe.profession or "Crafting", "Recipe craft request")
			end
			if GSF.MainFrame then
				GSF.MainFrame:SelectTab(5) -- Switch to Atlas & Bounties
			end
		end
	end)

	return frame
end

function Tab:UpdateTexts()
	if not self.frame then return end
	if self.orderBtn then self.orderBtn:SetText(GSF.L["REQUEST_CRAFT"]) end
	if self.wishlistBtn then self.wishlistBtn:SetText(GSF.L["WISHLIST_BTN"]) end
	if self.reqMatsBtn then self.reqMatsBtn:SetText(GSF.L["REQUEST_MATS_BTN"] or "Request Mats") end
	if self.onlineCheck then self.onlineCheck.text:SetText(GSF.L["FILTER_ONLINE_ONLY"]) end
	if not selectedRecipe and self.detailTitle then
		self.detailTitle:SetText(GSF.L["SELECT_RECIPE_PROMPT"])
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

			table.insert(self.recipeButtons, btn)
		end

		btn:SetPoint("TOPLEFT", self.leftContent, "TOPLEFT", 0, -yOffset)
		btn.recipe = recipe
		btn.title:SetText(recipe.name or "Unknown")
		btn.tag:SetText(string.format("(%d)", #recipe.crafters))

		local profInfo = GSF.PROFESSIONS[recipe.profession]
		btn.icon:SetTexture(profInfo and profInfo.icon or "Interface\\Icons\\INV_Misc_QuestionMark")

		btn:SetScript("OnClick", function()
			Tab:SelectRecipe(recipe)
		end)

		btn:Show()
		yOffset = yOffset + 30
	end

	self.leftContent:SetHeight(math.max(yOffset, 360))

	if selectedRecipe then
		self:DisplayRecipeDetails(selectedRecipe)
	end
end

function Tab:SelectRecipe(recipe)
	selectedRecipe = recipe
	self:DisplayRecipeDetails(recipe)
end

function Tab:DisplayRecipeDetails(recipe)
	if not recipe then return end

	local profInfo = GSF.PROFESSIONS[recipe.profession]
	local headerText = string.format("|cff%s%s|r (|cffffd100%s|r)", GSF.COLORS.PRIMARY, recipe.name, recipe.profession)
	self.detailTitle:SetText(headerText)

	-- Format reagents
	local reagentLines = {}
	if recipe.reagents and #recipe.reagents > 0 then
		for _, r in ipairs(recipe.reagents) do
			local line = string.format(" - %dx %s", r.count or 1, r.name or "Reagent")
			table.insert(reagentLines, line)
		end
		self.reagentsText:SetText(table.concat(reagentLines, "\n"))
	else
		self.reagentsText:SetText("No extra materials required.")
	end

	-- Format crafters
	for _, row in ipairs(self.crafterRows) do row:Hide() end

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

			local whisperBtn = GSF.UI:CreateButton(row, "Whisper", 65, 18)
			whisperBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
			row.whisperBtn = whisperBtn

			table.insert(self.crafterRows, row)
		end

		row:SetPoint("TOPLEFT", self.craftersContent, "TOPLEFT", 0, -yOffset)
		
		local statusDot = crafter.online and "|cff00ff00●|r" or "|cff777777●|r"
		local formattedName = GSF.Alts:GetFormattedName(crafter.name)
		row.nameText:SetText(string.format("%s %s", statusDot, formattedName))
		row.skillText:SetText(string.format("[%d/%d]", crafter.skill or 0, crafter.maxSkill or 375))

		row.whisperBtn:SetScript("OnClick", function()
			ChatFrame_OpenChat(string.format("/w %s Hi, could you craft [%s]?", crafter.name, recipe.name))
		end)

		row:Show()
		yOffset = yOffset + 26
	end

	self.craftersContent:SetHeight(math.max(yOffset, 160))
end
