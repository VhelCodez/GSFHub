local ADDON_NAME, GSF = ...

GSF.UI = {}

-- Backdrop helper ensuring 9.x/2.5.x BackdropTemplate compatibility
function GSF.UI:CreateBackdrop(frame, isParchment)
	if BackdropTemplateMixin and not frame.SetBackdrop then
		Mixin(frame, BackdropTemplateMixin)
	end

	local bg = isParchment and "Interface\\DialogFrame\\UI-DialogBox-Background" or "Interface\\Tooltips\\UI-Tooltip-Background"
	local edge = isParchment and "Interface\\DialogFrame\\UI-DialogBox-Border" or "Interface\\Tooltips\\UI-Tooltip-Border"

	frame:SetBackdrop({
		bgFile = bg,
		edgeFile = edge,
		tile = true,
		tileSize = 32,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	
	if not isParchment then
		frame:SetBackdropColor(0.08, 0.08, 0.10, 0.95)
		frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
	else
		frame:SetBackdropColor(0.9, 0.9, 0.9, 1.0)
	end
end

function GSF.UI:CreateButton(parent, text, width, height)
	local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	btn:SetSize(width or 100, height or 24)
	btn:SetText(text or "Button")
	return btn
end

function GSF.UI:CreateEditBox(parent, width, height)
	local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	local w = width or 150
	local h = height or 22
	eb:SetSize(w, h)
	eb:SetAutoFocus(false)
	eb:SetFontObject("GameFontHighlightSmall")
	eb.isGSFInput = true

	-- Clear focus on Enter or Escape by default
	eb:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
	end)
	eb:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)

	-- Right-click on editbox clears it
	eb:HookScript("OnMouseDown", function(self, button)
		if button == "RightButton" and self:GetText() ~= "" then
			self:SetText("")
			self:ClearFocus()
		end
	end)

	-- Add small inner clear 'X' button for inputs with sufficient width (>= 80px)
	if w >= 80 then
		eb:SetTextInsets(0, 18, 0, 0)
		local clearBtn = CreateFrame("Button", nil, eb)
		clearBtn:SetSize(14, 14)
		clearBtn:SetPoint("RIGHT", eb, "RIGHT", -4, 0)
		clearBtn:Hide()
		eb.clearBtn = clearBtn

		local tex = clearBtn:CreateTexture(nil, "ARTWORK")
		tex:SetAllPoints()
		tex:SetTexture("Interface\\FriendsFrame\\ClearBroadcastIcon")
		clearBtn.tex = tex

		local clearLabel = clearBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		clearLabel:SetPoint("CENTER", clearBtn, "CENTER", 0, 0)
		clearLabel:SetText("|cffaaaaaa×|r")
		clearLabel:Hide()
		clearBtn.label = clearLabel

		if not tex:GetTexture() then
			clearLabel:Show()
		end

		clearBtn:SetScript("OnEnter", function()
			clearBtn:SetAlpha(1.0)
			clearLabel:SetText("|cffffd100×|r")
		end)
		clearBtn:SetScript("OnLeave", function()
			clearBtn:SetAlpha(0.6)
			clearLabel:SetText("|cffaaaaaa×|r")
		end)
		clearBtn:SetAlpha(0.6)

		clearBtn:SetScript("OnClick", function()
			eb:SetText("")
			eb:ClearFocus()
		end)

		eb:HookScript("OnTextChanged", function(self)
			local t = self:GetText()
			if t and t ~= "" then
				clearBtn:Show()
			else
				clearBtn:Hide()
			end
		end)
	end

	return eb
end

function GSF.UI:CreateTab(parent, id, title)
	local tab = CreateFrame("Button", parent:GetName() .. "Tab" .. id, parent, "CharacterFrameTabButtonTemplate")
	tab:SetID(id)
	tab:SetText(title)
	tab:SetScript("OnClick", function()
		parent:SelectTab(id)
	end)
	return tab
end

function GSF.UI:CreateScrollList(parent, width, height, name)
	local scrollFrame = CreateFrame("ScrollFrame", name, parent, "UIPanelScrollFrameTemplate")
	scrollFrame:SetSize(width, height)
	scrollFrame.scrollBarHideable = 1

	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetSize(width - 24, height)
	scrollFrame:SetScrollChild(content)

	local scrollBar = (name and _G[name .. "ScrollBar"]) or scrollFrame.ScrollBar
	if not scrollBar then
		for _, child in ipairs({ scrollFrame:GetChildren() }) do
			if child:IsObjectType("Slider") then
				scrollBar = child
				break
			end
		end
	end
	scrollFrame.ScrollBar = scrollBar

	local function UpdateScrollBar()
		if not scrollBar then return end
		local _, maxVal = scrollBar:GetMinMaxValues()
		local contentH = content:GetHeight() or 0
		local frameH = scrollFrame:GetHeight() or 0
		local yrange = scrollFrame:GetVerticalScrollRange() or 0
		if (yrange > 1) or (maxVal and maxVal > 1) or (contentH > frameH + 2) then
			scrollBar:Show()
			scrollBar:Enable()
		else
			scrollBar:Hide()
		end
	end
	scrollFrame.UpdateScrollBar = UpdateScrollBar

	scrollFrame:HookScript("OnScrollRangeChanged", function()
		UpdateScrollBar()
	end)
	scrollFrame:HookScript("OnVerticalScroll", function()
		UpdateScrollBar()
	end)
	scrollFrame:HookScript("OnSizeChanged", function()
		UpdateScrollBar()
	end)
	scrollFrame:HookScript("OnShow", function()
		UpdateScrollBar()
	end)
	content:HookScript("OnSizeChanged", function()
		UpdateScrollBar()
	end)

	-- Initial check
	C_Timer.After(0.05, UpdateScrollBar)

	return scrollFrame, content
end

-- Universal Shift-Click Handler to paste clean item names into focused GSF edit boxes
-- Intercepts both HandleModifiedItemClick and ChatEdit_InsertLink to cancel WoW's Stack Split dialog
local orig_HandleModifiedItemClick = HandleModifiedItemClick
HandleModifiedItemClick = function(link)
	if link and IsModifiedClick and IsModifiedClick("CHATLINK") then
		local focused = GetCurrentKeyBoardFocus()
		if focused and focused.isGSFInput then
			local cleanName = link:match("%[(.-)%]") or link
			local itemID = tonumber(link:match("item:(%d+)"))
			focused.lastItemName = cleanName
			focused.lastItemLink = link
			focused.lastItemID = itemID
			focused:SetText(cleanName)
			focused:SetCursorPosition(string.len(cleanName))
			if focused.onItemPasted then
				focused:onItemPasted(cleanName, link, itemID)
			end
			return true
		end
	end
	if orig_HandleModifiedItemClick then
		return orig_HandleModifiedItemClick(link)
	end
	return false
end

local orig_ChatEdit_InsertLink = ChatEdit_InsertLink
ChatEdit_InsertLink = function(text)
	if text then
		local focused = GetCurrentKeyBoardFocus()
		if focused and focused.isGSFInput then
			local cleanName = text:match("%[(.-)%]") or text
			local itemID = tonumber(text:match("item:(%d+)"))
			focused.lastItemName = cleanName
			focused.lastItemLink = text
			focused.lastItemID = itemID
			focused:SetText(cleanName)
			focused:SetCursorPosition(string.len(cleanName))
			if focused.onItemPasted then
				focused:onItemPasted(cleanName, text, itemID)
			end
			return true
		end
	end
	if orig_ChatEdit_InsertLink then
		return orig_ChatEdit_InsertLink(text)
	end
	return false
end

-- Reusable Item Slot with Drag & Drop, Tooltip, and Texture Display
function GSF.UI:CreateItemSlot(parent, size)
	local s = size or 28
	local slot = CreateFrame("Button", nil, parent)
	slot:SetSize(s, s)

	local bg = slot:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture("Interface\\Buttons\\UI-Quickslot2")
	slot.bg = bg

	local icon = slot:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT", slot, "TOPLEFT", 2, -2)
	icon:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", -2, 2)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	slot.icon = icon

	slot:RegisterForDrag("LeftButton")

	local function HandleCursorDrop()
		local infoType, itemID, itemLink = GetCursorInfo()
		if infoType == "item" and (itemLink or itemID) then
			ClearCursor()
			local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemLink or itemID)
			if name and texture then
				slot:SetItem(name, texture, link, itemID)
				if slot.onItemDropped then
					slot:onItemDropped(name, link, texture, itemID)
				end
			end
		end
	end

	slot:SetScript("OnReceiveDrag", HandleCursorDrop)
	slot:SetScript("OnClick", HandleCursorDrop)

	slot:SetScript("OnEnter", function(self)
		local link = self.itemLink
		local validLink = link and (tostring(link):find("|H.-|h") or tostring(link):find("^item:") or tostring(link):find("^spell:"))
		if validLink then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			local ok = pcall(function() GameTooltip:SetHyperlink(link) end)
			if ok then
				GameTooltip:Show()
				return
			end
		end
		if self.itemID then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			if GetSpellInfo and GetSpellInfo(self.itemID) and not (GetItemInfo and GetItemInfo(self.itemID)) then
				local sLink = GetSpellLink and GetSpellLink(self.itemID)
				if sLink then
					pcall(function() GameTooltip:SetHyperlink(sLink) end)
				elseif GameTooltip.SetSpellByID then
					pcall(function() GameTooltip:SetSpellByID(self.itemID) end)
				else
					pcall(function() GameTooltip:SetHyperlink("spell:" .. self.itemID) end)
				end
			else
				pcall(function() GameTooltip:SetItemByID(self.itemID) end)
			end
			GameTooltip:Show()
			return
		end
		if self.itemName then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self.itemName, 1, 0.82, 0)
			if self.professionText then
				GameTooltip:AddLine(self.professionText, 0.7, 0.7, 0.7)
			end
			GameTooltip:Show()
			return
		end
		if not self.noDropHint then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(GSF.L["ITEM_SLOT_DROP_HINT"] or "Drag item here")
			GameTooltip:Show()
		end
	end)

	slot:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	function slot:SetItem(name, texture, link, itemID)
		self.itemName = name
		local validLink = link and (tostring(link):find("|H.-|h") or tostring(link):find("^item:") or tostring(link):find("^spell:")) and link or nil
		self.itemLink = validLink
		self.itemID = itemID or (validLink and tonumber(validLink:match("item:(%d+)")))
		if texture then
			self.icon:SetTexture(texture)
			self.icon:Show()
		else
			self.icon:Hide()
		end
	end

	function slot:Clear()
		self.itemName = nil
		self.itemLink = nil
		self.itemID = nil
		self.icon:SetTexture(nil)
		self.icon:Hide()
	end

	slot:Clear()
	return slot
end

-- Helper to attach 250ms debounced live item resolution and icon preview to any EditBox
function GSF.UI:AttachItemPreview(editBox, itemSlot, callback)
	editBox.isGSFInput = true
	local debounceTimer = nil

	local function ResolveItem(text, link, itemID)
		if not text or text == "" then
			itemSlot:Clear()
			if callback then callback(nil) end
			return
		end

		-- If text is purely numeric, require at least 3 digits (100+).
		-- 1 or 2 digits (e.g. "1", "99") must never be queried as item IDs.
		if text:match("^%d+$") and #text < 3 then
			itemSlot:Clear()
			editBox.lastItemName = nil
			editBox.lastItemLink = nil
			editBox.lastItemID = nil
			if callback then callback(nil) end
			return
		end

		-- 1. Check if link or text has an explicit spell/enchant reference
		local isExplicitSpell = (link and (link:match("enchant:") or link:match("spell:"))) or (text:match("enchant:") or text:match("spell:"))
		local spellId = (isExplicitSpell and (tonumber(itemID) or tonumber(text:match("enchant:(%d+)") or text:match("spell:(%d+)")) or (link and tonumber(link:match("enchant:(%d+)") or link:match("spell:(%d+)"))))) or nil
		if spellId and GetSpellInfo then
			local sName, _, sTexture = GetSpellInfo(spellId)
			local matchValid = false
			if sName and sTexture then
				if not text or text == "" or sName:lower() == text:lower() or text:lower():find(sName:lower(), 1, true) or sName:lower():find(text:lower(), 1, true) then
					matchValid = true
				end
			end
			if matchValid then
				local sLink = (GetSpellLink and GetSpellLink(spellId)) or link or string.format("|cff71d5ff|Hspell:%d|h[%s]|h|r", spellId, sName)
				itemSlot:SetItem(sName, sTexture, sLink, spellId)
				editBox.lastItemName = sName
				editBox.lastItemLink = sLink
				editBox.lastItemID = spellId
				if callback then callback(sName, sLink, sTexture, spellId) end
				return
			end
		end

		-- 2. Check if text is a raw numeric itemID with at least 3 digits (e.g. "4411", "28277")
		local rawId = (text:match("^%d+$") and #text >= 3) and tonumber(text) or nil
		-- 3. Check if text is a WoWHead script or hyperlink containing item:ID
		local scriptId = tonumber(text:match("item:(%d+)"))

		local target = link or itemID or rawId or scriptId
		if not target then
			-- 4. Check our dynamic chat/session link cache (captures whispers, guild, loot, etc.)
			if GSF.ChatLinks and GSF.ChatLinks[text:lower()] then
				target = GSF.ChatLinks[text:lower()].link or GSF.ChatLinks[text:lower()].id
			-- 5. Check AtlasJournal catalog by item name
			elseif AtlasJournal and AtlasJournal.FindResource and AtlasJournal:FindResource(text) then
				local yd = AtlasJournal:FindResource(text)
				if yd then
					target = yd.itemId or yd.link or text
				end
			-- 6. Fallback to raw text for items already in native RAM
			else
				target = text
			end
		end

		local name, itemLink, _, _, _, _, _, _, _, texture = GetItemInfo(target)
		local numId = tonumber(type(target) == "number" and target or (tostring(target):match("item:(%d+)"))) or rawId or scriptId

		if not texture and numId and AtlasJournal and AtlasJournal.GetItemDetails then
			local yd = AtlasJournal:GetItemDetails(numId)
			if yd and yd.link and yd.icon and yd.icon ~= "Interface\\Icons\\INV_Misc_QuestionMark" then
				texture = yd.icon
				name = name or yd.name or text
				itemLink = itemLink or yd.link
			end
		end

		if name and texture and texture ~= "Interface\\Icons\\INV_Misc_QuestionMark" and not (name:find("Wird geladen") or name:find("Loading")) then
			if editBox.pendingItemID then
				editBox.pendingItemID = nil
				if editBox.itemWatcherFrame then
					editBox.itemWatcherFrame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
				end
			end
			itemSlot:SetItem(name, texture, itemLink or link, numId or itemID)
			editBox.lastItemName = name
			editBox.lastItemLink = itemLink or link
			editBox.lastItemID = numId or itemID
			-- If user typed a numeric ID or pasted a WoWHead script, clean up editbox text to the real item name
			if rawId or (scriptId and text:find("/script")) then
				local cleanName = (scriptId and text:match("%[(.-)%]")) or name
				editBox:SetText(cleanName)
			end
			if callback then callback(name, itemLink or link, texture, numId or itemID) end
		elseif numId and numId >= 100 then
			-- Uncached item: display loading state and initiate reactive asynchronous resolution
			local loadingName = string.format(GSF.L["ITEM_LOADING"] or "Item #%d (Loading...)", numId)
			itemSlot:SetItem(loadingName, "Interface\\Icons\\INV_Misc_QuestionMark", nil, numId)
			editBox.lastItemName = loadingName
			editBox.lastItemLink = nil
			editBox.lastItemID = numId
			editBox.pendingItemID = numId

			if rawId or (scriptId and text:find("/script")) then
				local cleanName = (scriptId and text:match("%[(.-)%]")) or loadingName
				editBox:SetText(cleanName)
			end

			local function OnItemResolved(n, l, icon)
				if editBox.pendingItemID ~= numId then return end
				editBox.pendingItemID = nil
				if editBox.itemWatcherFrame then
					editBox.itemWatcherFrame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
				end
				if n and icon and icon ~= "Interface\\Icons\\INV_Misc_QuestionMark" then
					itemSlot:SetItem(n, icon, l, numId)
					editBox.lastItemName = n
					editBox.lastItemLink = l
					editBox.lastItemID = numId
					local cur = editBox:GetText() and editBox:GetText():trim() or ""
					if cur == tostring(numId) or cur == loadingName or cur:find("Wird geladen") or cur:find("Loading") or cur:find("^Gegenstand #%d+") or cur:find("^Item #%d+") or cur:find("/script") then
						editBox:SetText(n)
					end
					if callback then callback(n, l, icon, numId) end
				end
			end

			-- Setup event watcher frame for GET_ITEM_INFO_RECEIVED
			if not editBox.itemWatcherFrame then
				editBox.itemWatcherFrame = CreateFrame("Frame")
			end
			editBox.itemWatcherFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
			editBox.itemWatcherFrame:SetScript("OnEvent", function(f, evt, loadedID)
				if tonumber(loadedID) == numId then
					local n, l, _, _, _, _, _, _, _, icon = GetItemInfo(numId)
					if n and icon then
						OnItemResolved(n, l, icon)
					end
				end
			end)

			-- Request data load from server via C_Item and standard query
			if C_Item and C_Item.RequestLoadItemDataByID then
				C_Item.RequestLoadItemDataByID(numId)
			end
			if Item and Item.CreateFromItemID then
				local itemObj = Item:CreateFromItemID(numId)
				if itemObj and not itemObj:IsItemEmpty() and itemObj:GetItemID() then
					pcall(function()
						itemObj:ContinueOnItemLoad(function()
							local n = itemObj:GetItemName()
							local icon = itemObj:GetItemIcon()
							local l = itemObj:GetItemLink()
							if n and icon then
								OnItemResolved(n, l, icon)
							end
						end)
					end)
				end
			else
				GetItemInfo(numId)
			end
		else
			-- Check if text matches a spell name
			if GetSpellInfo and text and text ~= "" then
				local sName, _, sTexture = GetSpellInfo(text)
				if sName and sTexture then
					itemSlot:SetItem(sName, sTexture, nil, nil)
					editBox.lastItemName = sName
					if callback then callback(sName, nil, sTexture, nil) end
				end
			end
		end
	end

	editBox:HookScript("OnTextChanged", function(self, userInput)
		local rawText = self:GetText()
		local text = rawText and rawText:match("^%s*(.-)%s*$") or ""
		if text == "" then
			if debounceTimer then debounceTimer:Cancel() end
			itemSlot:Clear()
			self.lastItemName = nil
			self.lastItemLink = nil
			self.lastItemID = nil
			if self.pendingItemID then
				self.pendingItemID = nil
				if self.itemWatcherFrame then
					self.itemWatcherFrame:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
				end
			end
			if callback then callback(nil) end
			return
		end
		if not userInput then return end
		if debounceTimer then
			debounceTimer:Cancel()
		end
		local link = (self.lastItemName == text) and self.lastItemLink or nil
		local itemID = (self.lastItemName == text) and self.lastItemID or nil
		debounceTimer = C_Timer.NewTimer(0.25, function()
			ResolveItem(text, link, itemID)
		end)
	end)

	editBox.onItemPasted = function(self, text, link, itemID)
		self.lastItemName = text
		self.lastItemLink = link
		self.lastItemID = itemID
		ResolveItem(text, link, itemID)
	end

	itemSlot.onItemDropped = function(slot, name, link, texture, itemID)
		editBox:SetText(name)
		editBox.lastItemName = name
		editBox.lastItemLink = link
		editBox.lastItemID = itemID
		if callback then callback(name, link, texture, itemID) end
	end
end

-- Generic tooltip attacher for item icon buttons
function GSF.UI:AttachItemTooltip(frame, getItemLinkFunc)
	if not frame then return end
	frame:EnableMouse(true)
	local function showTip(self)
		local link = getItemLinkFunc and getItemLinkFunc(self)
		if link then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			if type(link) == "number" then
				pcall(function() GameTooltip:SetItemByID(link) end)
			elseif tostring(link):find("|H.-|h") or tostring(link):find("^item:") or tostring(link):find("^spell:") then
				pcall(function() GameTooltip:SetHyperlink(link) end)
			else
				GameTooltip:SetText(tostring(link), 1, 0.82, 0)
			end
			GameTooltip:Show()
		end
	end
	local function hideTip()
		GameTooltip:Hide()
	end

	if frame.HookScript then
		frame:HookScript("OnEnter", showTip)
		frame:HookScript("OnLeave", hideTip)
		frame:HookScript("OnHide", hideTip)
	else
		frame:SetScript("OnEnter", showTip)
		frame:SetScript("OnLeave", hideTip)
		frame:SetScript("OnHide", hideTip)
	end
end

-- Generic text tooltip attacher for buttons and UI elements
function GSF.UI:AttachTooltip(frame, text, anchor)
	if not frame then return end
	frame:EnableMouse(true)
	local function showTip(self)
		local tipText = (type(text) == "function") and text(self) or text
		if tipText and tipText ~= "" then
			GameTooltip:SetOwner(self, anchor or "ANCHOR_RIGHT")
			GameTooltip:SetText(tipText, 1, 1, 1)
			GameTooltip:Show()
		end
	end
	local function hideTip()
		GameTooltip:Hide()
	end

	if frame.HookScript then
		frame:HookScript("OnEnter", showTip)
		frame:HookScript("OnLeave", hideTip)
		frame:HookScript("OnHide", hideTip)
	else
		frame:SetScript("OnEnter", showTip)
		frame:SetScript("OnLeave", hideTip)
		frame:SetScript("OnHide", hideTip)
	end
end

