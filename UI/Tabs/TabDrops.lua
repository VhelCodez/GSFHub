local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabDrops = Tab

function Tab:Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	self.frame = frame
	self.pendingItems = {}

	frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	frame:SetScript("OnEvent", function(f, event, itemID)
		if event == "GET_ITEM_INFO_RECEIVED" and itemID then
			local num = tonumber(itemID)
			if Tab.pendingItems and Tab.pendingItems[num] then
				Tab.pendingItems[num] = nil
				if f:IsShown() then
					Tab:Refresh()
				end
			end
		end
	end)

	-- Top Bar: Standardized Search Input (Top-Left)
	local dropSearchBox = GSF.UI:CreateEditBox(frame, 150, 22)
	dropSearchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -12)
	self.dropSearchBox = dropSearchBox

	local searchHint = dropSearchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	searchHint:SetPoint("LEFT", dropSearchBox, "LEFT", 5, 0)
	searchHint:SetText(GSF.L["SEARCH_DROPS"] or "Search drops...")
	dropSearchBox.searchHint = searchHint
	dropSearchBox:HookScript("OnTextChanged", function(eb)
		if eb:GetText() ~= "" then searchHint:Hide() else searchHint:Show() end
		Tab:Refresh()
	end)

	-- Top Bar: Standardized Action Button (Top-Right)
	local addWishBtn = GSF.UI:CreateButton(frame, "+ " .. (GSF.L["ADD_TO_WISHLIST_BTN"] or "Zur Wunschliste"), 150, 24)
	addWishBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -12)
	self.addWishBtn = addWishBtn
	addWishBtn:SetScript("OnClick", function()
		Tab:OpenWishModal()
	end)

	-- Left Column Header: Recent Drops (aligned at y = -45)
	local dropTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	dropTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -45)
	dropTitle:SetText(GSF.L["RECIPE_DROPS_TITLE"])
	self.dropTitle = dropTitle

	-- Right Column Header: My Wishlist (aligned at y = -45)
	local wishTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	wishTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 385, -45)
	wishTitle:SetText(GSF.L["WISHLIST_TITLE"])
	self.wishTitle = wishTitle

	-- Left Scroll List: Recent Drops
	local dropScroll, dropContent = GSF.UI:CreateScrollList(frame, 350, 360)
	dropScroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -68)
	dropScroll:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, 15)
	self.dropScroll = dropScroll
	self.dropContent = dropContent
	self.dropRows = {}

	-- Right Scroll List: My Wishlist
	local wishScroll, wishContent = GSF.UI:CreateScrollList(frame, 350, 360)
	wishScroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 385, -68)
	wishScroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 15)
	self.wishScroll = wishScroll
	self.wishContent = wishContent
	self.wishRows = {}

	-- Empty state notices (Anchored to the visible ScrollFrames, not the 1px-tall scroll children)
	local emptyDropsText = dropScroll:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	emptyDropsText:SetPoint("CENTER", dropScroll, "CENTER", 0, 0)
	emptyDropsText:SetWidth(280)
	emptyDropsText:SetJustifyH("CENTER")
	emptyDropsText:SetText(GSF.L["NO_RECIPES_FOUND"] or "No recipe drops recorded yet.")
	self.emptyDropsText = emptyDropsText

	local emptyWishText = wishScroll:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	emptyWishText:SetPoint("CENTER", wishScroll, "CENTER", 0, 0)
	emptyWishText:SetWidth(280)
	emptyWishText:SetJustifyH("CENTER")
	emptyWishText:SetText(GSF.L["WISHLIST_EMPTY_PROMPT"])
	self.emptyWishText = emptyWishText

	-- Build Wishlist Modal
	self:BuildWishModal(frame)

	return frame
end

function Tab:BuildWishModal(parent)
	local modal = CreateFrame("Frame", "GSFWishlistModal", parent)
	modal:SetSize(420, 200)
	modal:SetPoint("CENTER", parent, "CENTER", 0, 20)
	modal:SetFrameStrata("DIALOG")
	if BackdropTemplateMixin then Mixin(modal, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(modal, false)
	modal:SetBackdropColor(0.06, 0.06, 0.08, 0.98)
	modal:Hide()
	self.wishModal = modal

	local title = modal:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	title:SetPoint("TOPLEFT", modal, "TOPLEFT", 16, -14)
	title:SetText(GSF.L["ADD_TO_WISHLIST_TITLE"] or "Rezept zur Wunschliste hinzufügen")
	modal.title = title

	local closeBtn = CreateFrame("Button", nil, modal, "UIPanelCloseButton")
	closeBtn:SetPoint("TOPRIGHT", modal, "TOPRIGHT", -4, -4)

	local hint = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	hint:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
	hint:SetWidth(380)
	hint:SetJustifyH("LEFT")
	hint:SetText(GSF.L["WISHLIST_MODAL_HINT"] or "Rezept hierher ziehen oder per Shift-Klick einfügen:")
	modal.hint = hint

	-- Item Slot
	local itemSlot = GSF.UI:CreateItemSlot(modal, 32)
	itemSlot:SetPoint("TOPLEFT", hint, "BOTTOMLEFT", 0, -16)
	modal.itemSlot = itemSlot

	-- EditBox for item name / link
	local addBox = GSF.UI:CreateEditBox(modal, 330, 24)
	addBox:SetPoint("LEFT", itemSlot, "RIGHT", 10, 0)
	modal.addBox = addBox

	GSF.UI:AttachItemPreview(addBox, itemSlot)

	-- Overwrite onItemDropped to strictly enforce recipe items
	local origOnItemDropped = itemSlot.onItemDropped
	itemSlot.onItemDropped = function(slot, name, link, texture, itemID)
		local isRecipe = GSF.RecipeDrops and GSF.RecipeDrops:IsRecipeItem(link or itemID or name)
		if not isRecipe then
			if GSF.Addon then
				GSF.Addon:Print(GSF.L["WISHLIST_RECIPES_ONLY"] or "Only recipes, schematics, patterns, and formulas can be added to the recipe wishlist.")
			end
			itemSlot:Clear()
			addBox:SetText("")
			addBox.lastItemName = nil
			addBox.lastItemLink = nil
			addBox.lastItemID = nil
			return
		end
		if origOnItemDropped then
			origOnItemDropped(slot, name, link, texture, itemID)
		end
	end

	local function SubmitWish()
		local text = addBox:GetText()
		if text and text:trim() ~= "" then
			local itemToWish = itemSlot.itemLink or addBox.lastItemLink or (addBox.lastItemID and tostring(addBox.lastItemID)) or text:trim()
			local isRecipe = GSF.RecipeDrops and GSF.RecipeDrops:IsRecipeItem(itemToWish)
			if not isRecipe then
				if GSF.Addon then
					GSF.Addon:Print(GSF.L["WISHLIST_RECIPES_ONLY"] or "Only recipes, schematics, patterns, and formulas can be added to the recipe wishlist.")
				end
				return
			end
			local success = GSF.RecipeDrops:AddToWishlist(itemToWish)
			if success ~= false then
				modal:Hide()
				Tab:Refresh()
			end
		end
	end

	addBox:SetScript("OnEnterPressed", SubmitWish)

	-- Action Buttons at bottom
	local confirmBtn = GSF.UI:CreateButton(modal, GSF.L["ADD_TO_WISHLIST_BTN"] or "Hinzufügen", 120, 24)
	confirmBtn:SetPoint("BOTTOMRIGHT", modal, "BOTTOMRIGHT", -16, 16)
	confirmBtn:SetScript("OnClick", SubmitWish)
	modal.confirmBtn = confirmBtn

	local cancelBtn = GSF.UI:CreateButton(modal, GSF.L["CANCEL"] or "Abbrechen", 90, 24)
	cancelBtn:SetPoint("RIGHT", confirmBtn, "LEFT", -10, 0)
	cancelBtn:SetScript("OnClick", function()
		modal:Hide()
	end)
	modal.cancelBtn = cancelBtn

	modal:HookScript("OnHide", function()
		itemSlot:Clear()
		addBox:SetText("")
		addBox.lastItemName = nil
		addBox.lastItemLink = nil
		addBox.lastItemID = nil
		if addBox.pendingItemID then
			addBox.pendingItemID = nil
			if addBox.itemWatcherFrame then
				addBox.itemWatcherFrame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
			end
		end
	end)
end

function Tab:OpenWishModal()
	if not self.wishModal then return end
	self.wishModal.itemSlot:Clear()
	self.wishModal.addBox:SetText("")
	self.wishModal.addBox.lastItemName = nil
	self.wishModal.addBox.lastItemLink = nil
	self.wishModal.addBox.lastItemID = nil
	if self.wishModal.addBox.pendingItemID then
		self.wishModal.addBox.pendingItemID = nil
		if self.wishModal.addBox.itemWatcherFrame then
			self.wishModal.addBox.itemWatcherFrame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
		end
	end
	self.wishModal:Show()
	self.wishModal.addBox:SetFocus()
end

function Tab:UpdateTexts()
	if not self.frame then return end
	if self.dropTitle then self.dropTitle:SetText(GSF.L["RECIPE_DROPS_TITLE"]) end
	if self.wishTitle then self.wishTitle:SetText(GSF.L["WISHLIST_TITLE"]) end
	if self.dropSearchBox and self.dropSearchBox.searchHint then
		self.dropSearchBox.searchHint:SetText(GSF.L["SEARCH_DROPS"] or "Search drops...")
	end
	if self.addWishBtn then self.addWishBtn:SetText("+ " .. (GSF.L["ADD_TO_WISHLIST_BTN"] or "Zur Wunschliste")) end
	if self.emptyDropsText then self.emptyDropsText:SetText(GSF.L["NO_RECIPES_FOUND"] or "No recipe drops recorded yet.") end
	if self.emptyWishText then self.emptyWishText:SetText(GSF.L["WISHLIST_EMPTY_PROMPT"]) end
	if self.wishModal then
		if self.wishModal.title then self.wishModal.title:SetText(GSF.L["ADD_TO_WISHLIST_TITLE"] or "Add Recipe to Wishlist") end
		if self.wishModal.hint then self.wishModal.hint:SetText(GSF.L["WISHLIST_MODAL_HINT"] or "Drag recipe here or Shift-Click from bags:") end
		if self.wishModal.confirmBtn then self.wishModal.confirmBtn:SetText(GSF.L["ADD_TO_WISHLIST_BTN"] or "Hinzufügen") end
		if self.wishModal.cancelBtn then self.wishModal.cancelBtn:SetText(GSF.L["CANCEL"] or "Abbrechen") end
	end
	self:Refresh()
end

function Tab:Refresh()
	if not self.frame or not self.frame:IsShown() then return end

	-- Prune expired drops before rendering
	if GSF.RecipeDrops and GSF.RecipeDrops.PruneExpiredDrops then
		GSF.RecipeDrops:PruneExpiredDrops()
	end

	-- Refresh Drops
	local allDrops = GSF.cache.recentDrops or {}
	local recentDrops = {}
	local query = self.dropSearchBox and self.dropSearchBox:GetText():lower():trim() or ""

	for originalIdx, drop in ipairs(allDrops) do
		local dropName = drop.cleanName or drop.name or ""
		local prof = drop.profession or ""
		local matches = true
		if query ~= "" then
			matches = dropName:lower():find(query, 1, true) or
			          prof:lower():find(query, 1, true) or
			          (drop.neededBy and table.concat(drop.neededBy, " "):lower():find(query, 1, true)) or
			          (drop.wishlistedBy and table.concat(drop.wishlistedBy, " "):lower():find(query, 1, true))
		end
		if matches then
			table.insert(recentDrops, { drop = drop, originalIdx = originalIdx })
		end
	end

	for _, card in ipairs(self.dropRows) do card:Hide() end

	local yOffset = 0
	for i, entry in ipairs(recentDrops) do
		local drop = entry.drop
		local originalIdx = entry.originalIdx
		local card = self.dropRows[i]
		if not card then
			card = CreateFrame("Frame", nil, self.dropContent)
			card:SetSize(324, 64)
			if BackdropTemplateMixin then Mixin(card, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(card, false)
			card:SetBackdropColor(0.10, 0.10, 0.14, 0.85)

			-- Left 36x36px Item Slot
			local itemSlot = GSF.UI:CreateItemSlot(card, 36)
			itemSlot:SetPoint("TOPLEFT", card, "TOPLEFT", 8, -8)
			card.itemSlot = itemSlot

			-- Relative Time text top right
			local timeText = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			timeText:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -8)
			timeText:SetJustifyH("RIGHT")
			card.timeText = timeText

			-- Dismiss [X] button bottom right
			local dismissBtn = GSF.UI:CreateButton(card, "X", 22, 20)
			dismissBtn:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -8, 7)
			GSF.UI:AttachTooltip(dismissBtn, GSF.L["DISMISS_DROP"] or "Dismiss drop")
			card.dismissBtn = dismissBtn

			-- Header: Item Name / Link
			local itemText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			itemText:SetPoint("TOPLEFT", itemSlot, "TOPRIGHT", 8, 1)
			itemText:SetPoint("RIGHT", timeText, "LEFT", -6, 0)
			itemText:SetJustifyH("LEFT")
			itemText:SetWordWrap(false)
			card.itemText = itemText

			-- Profession Badge / Subtitle
			local profBadge = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			profBadge:SetPoint("TOPLEFT", itemText, "BOTTOMLEFT", 0, -2)
			profBadge:SetPoint("RIGHT", card, "RIGHT", -34, 0)
			profBadge:SetJustifyH("LEFT")
			profBadge:SetWordWrap(false)
			card.profBadge = profBadge

			-- Needed By / Wishlist details
			local details = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			details:SetPoint("TOPLEFT", profBadge, "BOTTOMLEFT", 0, -2)
			details:SetPoint("RIGHT", dismissBtn, "LEFT", -6, 0)
			details:SetJustifyH("LEFT")
			details:SetWordWrap(false)
			card.details = details

			table.insert(self.dropRows, card)
		end

		card:SetPoint("TOPLEFT", self.dropContent, "TOPLEFT", 0, -yOffset)

		-- Resolve Item and Rarity for slot
		local itemId = tonumber(drop.link and drop.link:match("item:(%d+)")) or tonumber(drop.name and drop.name:match("item:(%d+)")) or tonumber(drop.name and drop.name:match("#(%d+)"))
		local name, itemLink, quality, _, _, _, _, _, _, texture = GetItemInfo(drop.link or drop.name or itemId)
		if not texture and itemId and AtlasJournal and AtlasJournal.GetItemDetails then
			local yd = AtlasJournal:GetItemDetails(itemId)
			if yd and yd.link and yd.icon and yd.icon ~= "Interface\\Icons\\INV_Misc_QuestionMark" then
				texture = yd.icon
				name = name or yd.name
				itemLink = itemLink or yd.link
			end
		end

		card.itemSlot:SetItem(name or drop.name or "Recipe", texture or "Interface\\Icons\\INV_Scroll_03", itemLink or drop.link, itemId)

		-- Format Header and Profession Badge
		local profDisplay = (drop.profession and drop.profession ~= "Unknown") and GSF:GetLocalizedProfession(drop.profession) or (GSF.L["ANY"] or "Any")
		card.itemText:SetText(itemLink or drop.link or drop.name or "Recipe")
		card.profBadge:SetText(string.format("|cffffd100[%s]|r", profDisplay))

		-- Format Needed / Wishlisted crafters
		local needList = (drop.neededBy and #drop.neededBy > 0) and table.concat(drop.neededBy, ", ") or nil
		local wishList = (drop.wishlistedBy and #drop.wishlistedBy > 0) and table.concat(drop.wishlistedBy, ", ") or nil
		local detailStr = ""
		if needList then
			if #needList > 35 then needList = needList:sub(1, 35) .. "..." end
			detailStr = string.format(GSF.L["NEEDED_BY"] or "Needed by: %s", "|cff00ff00" .. needList .. "|r")
		elseif wishList then
			if #wishList > 35 then wishList = wishList:sub(1, 35) .. "..." end
			detailStr = string.format(GSF.L["WISHLISTED_BY"] or "Wishlist: %s", "|cff33ccff" .. wishList .. "|r")
		else
			detailStr = "|cff888888" .. (GSF.L["NO_CRAFTERS_NEED"] or "All crafters know this") .. "|r"
		end
		card.details:SetText(detailStr)

		-- Format time using standardized GSF:FormatTimeAgo
		card.timeText:SetText(GSF:FormatTimeAgo(drop.timestamp))

		-- Dismiss Action
		card.dismissBtn:SetScript("OnClick", function()
			GameTooltip:Hide()
			GSF.RecipeDrops:DismissDrop(originalIdx)
			Tab:Refresh()
		end)

		card:Show()
		yOffset = yOffset + 68
	end

	if #recentDrops == 0 then
		if self.emptyDropsText then self.emptyDropsText:Show() end
	else
		if self.emptyDropsText then self.emptyDropsText:Hide() end
	end
	self.dropContent:SetHeight(math.max(yOffset, 1))

	-- Auto-hide drop scrollbar if list does not overflow
	local dropBar = self.dropScroll and (self.dropScroll.ScrollBar or (self.dropScroll:GetName() and _G[self.dropScroll:GetName() .. "ScrollBar"]))
	if dropBar then
		local frameH = self.dropScroll:GetHeight() or 360
		if #recentDrops == 0 or yOffset <= frameH then
			dropBar:Hide()
		else
			dropBar:Show()
		end
	end

	-- Refresh Wishlist
	local wishlist = GSF.db.myWishlist or {}
	for _, row in ipairs(self.wishRows) do row:Hide() end

	local wOffset = 0
	local idx = 1
	for key, item in pairs(wishlist) do
		local row = self.wishRows[idx]
		if not row then
			row = CreateFrame("Button", nil, self.wishContent)
			row:SetSize(320, 30)
			if BackdropTemplateMixin then Mixin(row, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(row, false)
			row:SetBackdropColor(0.12, 0.12, 0.16, 0.6)

			local icon = row:CreateTexture(nil, "ARTWORK")
			icon:SetSize(22, 22)
			icon:SetPoint("LEFT", row, "LEFT", 4, 0)
			icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			row.icon = icon

			local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			name:SetPoint("LEFT", icon, "RIGHT", 6, 0)
			name:SetPoint("RIGHT", row, "RIGHT", -36, 0)
			name:SetJustifyH("LEFT")
			row.name = name

			local delBtn = GSF.UI:CreateButton(row, "X", 24, 20)
			delBtn:SetPoint("RIGHT", row, "RIGHT", -6, 0)
			GSF.UI:AttachTooltip(delBtn, GSF.L["REMOVE_FROM_WISHLIST"] or GSF.L["REMOVE"] or "Remove")
			row.delBtn = delBtn

			row:EnableMouse(true)
			row:RegisterForClicks("LeftButtonUp")
			row:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				local link = self.itemLink
				local validLink = link and (tostring(link):find("|H.-|h") or tostring(link):find("^item:") or tostring(link):find("^spell:")) and link
				local shown = false
				if validLink then
					shown = pcall(function() GameTooltip:SetHyperlink(validLink) end)
				end
				if not shown and self.itemID then
					shown = pcall(function() GameTooltip:SetItemByID(self.itemID) end)
				end
				if not shown then
					GameTooltip:SetText(self.itemName or (link and tostring(link):gsub("|c%x+", ""):gsub("|r", "")) or "Recipe", 1, 0.82, 0)
				end
				GameTooltip:Show()
			end)
			row:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
			row:SetScript("OnClick", function(self)
				local link = self.itemLink
				local validLink = link and (tostring(link):find("|H.-|h") or tostring(link):find("^item:") or tostring(link):find("^spell:")) and link
				if IsModifiedClick and IsModifiedClick("CHATLINK") and validLink then
					ChatEdit_InsertLink(validLink)
				end
			end)

			table.insert(self.wishRows, row)
		end

		row:SetPoint("TOPLEFT", self.wishContent, "TOPLEFT", 0, -wOffset)
		local cleanName = (item.name or key or ""):gsub("^%[", ""):gsub("%]$", ""):trim()
		local rawLink = item.link
		local validLink = rawLink and (tostring(rawLink):find("|H.-|h") or tostring(rawLink):find("^item:") or tostring(rawLink):find("^spell:")) and rawLink or nil

		-- Clean up invalid link in database if stored previously as plain text
		if item.link and not validLink then
			item.link = nil
		end

		row.itemID = item.id or tonumber(key) or (rawLink and tonumber(rawLink:match("item:(%d+)"))) or (cleanName:match("#(%d+)") and tonumber(cleanName:match("#(%d+)")))
		row.itemName = (item.name and item.name ~= "") and item.name or cleanName
		row.itemLink = validLink

		-- Try resolving from local cache
		local rName, rLink, _, _, _, _, _, _, _, texture = GetItemInfo(validLink or row.itemID or cleanName)
		if not rName and cleanName ~= "" then
			local bareName = cleanName:gsub("^(Muster|Pläne|Bauplan|Rezept|Formel|Handbuch|Vorlage|Buch):%s*", ""):trim()
			if GSF.RecipeBook and GSF.RecipeBook.Search then
				local res = GSF.RecipeBook:Search(bareName, "ALL", false)
				if res and res[1] then
					local foundLink = res[1].itemLink or res[1].recipeLink
					if foundLink and tonumber(foundLink:match("item:(%d+)")) then
						row.itemID = tonumber(foundLink:match("item:(%d+)"))
						rName, rLink, _, _, _, _, _, _, _, texture = GetItemInfo(row.itemID)
					end
				end
			end
		end

		if rName and texture then
			row.itemLink = rLink or validLink
			row.itemName = rName
			row.name:SetText(rLink or rName)
			row.icon:SetTexture(texture)
			row.icon:Show()

			-- Upgrade database entry if it had placeholder or missing link
			if (not item.name or item.name ~= rName or item.name:find("Wird geladen") or item.name:find("Loading")) and rName then
				item.name = rName
			end
			if rLink and (not item.link or not item.link:find("|H")) then
				item.link = rLink
			end
			if row.itemID and not item.id then
				item.id = row.itemID
			end
		else
			-- Uncached: show loading placeholder or current item name
			local isPlaceholder = not item.name or item.name:find("Wird geladen") or item.name:find("Loading") or item.name:match("^%d+$")
			local dispName = isPlaceholder and string.format(GSF.L["ITEM_LOADING"] or "Item #%d (Loading...)", row.itemID or 0) or (validLink or item.name or cleanName or key)
			row.name:SetText(dispName)
			row.icon:SetTexture("Interface\\Icons\\INV_Scroll_03")
			row.icon:Show()

			if row.itemID then
				self.pendingItems = self.pendingItems or {}
				self.pendingItems[row.itemID] = true

				if C_Item and C_Item.RequestLoadItemDataByID then
					C_Item.RequestLoadItemDataByID(row.itemID)
				end

				if Item and Item.CreateFromItemID then
					local itm = Item:CreateFromItemID(row.itemID)
					if itm and not itm:IsItemEmpty() and itm:GetItemID() then
						pcall(function()
							itm:ContinueOnItemLoad(function()
								local t = itm:GetItemIcon()
								local n = itm:GetItemName()
								local l = itm:GetItemLink()
								if row.itemID == itm:GetItemID() then
									if t then row.icon:SetTexture(t) end
									if n then
										row.name:SetText(l or n)
										row.itemLink = l or row.itemLink
										row.itemName = n
										if GSF.db.myWishlist and GSF.db.myWishlist[key] then
											GSF.db.myWishlist[key].name = n
											if l and l:find("|H") then
												GSF.db.myWishlist[key].link = l
											end
											GSF.db.myWishlist[key].id = row.itemID
										end
									end
								end
							end)
						end)
					end
				else
					GetItemInfo(row.itemID)
				end
			end
		end

		row.delBtn:SetScript("OnClick", function()
			GameTooltip:Hide()
			GSF.RecipeDrops:RemoveFromWishlist(key)
			Tab:Refresh()
		end)

		row:Show()
		wOffset = wOffset + 34
		idx = idx + 1
	end

	if idx == 1 then
		if self.emptyWishText then self.emptyWishText:Show() end
	else
		if self.emptyWishText then self.emptyWishText:Hide() end
	end

	self.wishContent:SetHeight(math.max(wOffset, 1))

	-- Auto-hide wishlist scrollbar if list does not overflow
	local wishBar = self.wishScroll and (self.wishScroll.ScrollBar or (self.wishScroll:GetName() and _G[self.wishScroll:GetName() .. "ScrollBar"]))
	if wishBar then
		local frameH = self.wishScroll:GetHeight() or 360
		if idx <= 1 or wOffset <= frameH then
			wishBar:Hide()
		else
			wishBar:Show()
		end
	end
end
