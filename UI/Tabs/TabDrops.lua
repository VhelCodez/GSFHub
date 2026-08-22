local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabDrops = Tab

function Tab:Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	self.frame = frame

	-- Left Header: Recent Drops
	local dropTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	dropTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -12)
	dropTitle:SetText(GSF.L["RECIPE_DROPS_TITLE"])

	local dropScroll, dropContent = GSF.UI:CreateScrollList(frame, 350, 370)
	dropScroll:SetPoint("TOPLEFT", dropTitle, "BOTTOMLEFT", -5, -8)
	self.dropContent = dropContent
	self.dropRows = {}

	-- Right Header: My Wishlist
	local wishTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	wishTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 390, -12)
	wishTitle:SetText(GSF.L["WISHLIST_TITLE"])

	local wishScroll, wishContent = GSF.UI:CreateScrollList(frame, 320, 330)
	wishScroll:SetPoint("TOPLEFT", wishTitle, "BOTTOMLEFT", -5, -8)
	self.wishContent = wishContent
	self.wishRows = {}

	-- Wishlist input bottom right
	local addBox = GSF.UI:CreateEditBox(frame, 200, 22)
	addBox:SetPoint("TOPLEFT", wishScroll, "BOTTOMLEFT", 5, -10)
	self.addBox = addBox

	local addBtn = GSF.UI:CreateButton(frame, GSF.L["ADD_TO_WISHLIST"], 90, 22)
	addBtn:SetPoint("LEFT", addBox, "RIGHT", 10, 0)
	self.addBtn = addBtn
	self.dropTitle = dropTitle
	self.wishTitle = wishTitle

	addBtn:SetScript("OnClick", function()
		local text = addBox:GetText()
		if text and text:trim() ~= "" then
			GSF.RecipeDrops:AddToWishlist(text:trim())
			addBox:SetText("")
			Tab:Refresh()
		end
	end)

	return frame
end

function Tab:UpdateTexts()
	if not self.frame then return end
	if self.dropTitle then self.dropTitle:SetText(GSF.L["RECIPE_DROPS_TITLE"]) end
	if self.wishTitle then self.wishTitle:SetText(GSF.L["WISHLIST_TITLE"]) end
	if self.addBtn then self.addBtn:SetText(GSF.L["ADD_TO_WISHLIST"]) end
	self:Refresh()
end

function Tab:Refresh()
	if not self.frame or not self.frame:IsShown() then return end

	-- Refresh Drops
	local recentDrops = GSF.cache.recentDrops or {}
	for _, row in ipairs(self.dropRows) do row:Hide() end

	local yOffset = 0
	for i, drop in ipairs(recentDrops) do
		local row = self.dropRows[i]
		if not row then
			row = CreateFrame("Frame", nil, self.dropContent)
			row:SetSize(320, 56)
			if BackdropTemplateMixin then Mixin(row, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(row, false)
			row:SetBackdropColor(0.10, 0.10, 0.14, 0.75)

			local itemText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			itemText:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -6)
			row.itemText = itemText

			local needs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			needs:SetPoint("TOPLEFT", itemText, "BOTTOMLEFT", 0, -3)
			row.needs = needs

			local timeText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			timeText:SetPoint("TOPRIGHT", row, "TOPRIGHT", -8, -6)
			row.timeText = timeText

			table.insert(self.dropRows, row)
		end

		row:SetPoint("TOPLEFT", self.dropContent, "TOPLEFT", 0, -yOffset)
		row.itemText:SetText(drop.link or drop.name or "Recipe")
		
		local needList = (drop.neededBy and #drop.neededBy > 0) and table.concat(drop.neededBy, ", ") or "None"
		if #needList > 35 then needList = needList:sub(1, 35) .. "..." end
		row.needs:SetText("Needed by: " .. needList)

		local minsAgo = math.floor((time() - (drop.timestamp or time())) / 60)
		row.timeText:SetText(minsAgo > 0 and (minsAgo .. "m ago") or "Just now")

		row:Show()
		yOffset = yOffset + 62
	end
	self.dropContent:SetHeight(math.max(yOffset, 370))

	-- Refresh Wishlist
	local wishlist = GSF.db.myWishlist or {}
	for _, row in ipairs(self.wishRows) do row:Hide() end

	local wOffset = 0
	local idx = 1
	for key, item in pairs(wishlist) do
		local row = self.wishRows[idx]
		if not row then
			row = CreateFrame("Frame", nil, self.wishContent)
			row:SetSize(295, 30)
			if BackdropTemplateMixin then Mixin(row, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(row, false)
			row:SetBackdropColor(0.12, 0.12, 0.16, 0.6)

			local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			name:SetPoint("LEFT", row, "LEFT", 8, 0)
			name:SetPoint("RIGHT", row, "RIGHT", -60, 0)
			name:SetJustifyH("LEFT")
			row.name = name

			local delBtn = GSF.UI:CreateButton(row, "X", 24, 20)
			delBtn:SetPoint("RIGHT", row, "RIGHT", -6, 0)
			row.delBtn = delBtn

			table.insert(self.wishRows, row)
		end

		row:SetPoint("TOPLEFT", self.wishContent, "TOPLEFT", 0, -wOffset)
		row.name:SetText(item.link or item.name or key)
		row.delBtn:SetScript("OnClick", function()
			GSF.RecipeDrops:RemoveFromWishlist(key)
			Tab:Refresh()
		end)

		row:Show()
		wOffset = wOffset + 34
		idx = idx + 1
	end
	self.wishContent:SetHeight(math.max(wOffset, 330))
end
