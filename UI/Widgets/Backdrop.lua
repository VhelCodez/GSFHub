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
	eb:SetSize(width or 150, height or 22)
	eb:SetAutoFocus(false)
	eb:SetFontObject("GameFontHighlightSmall")
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

function GSF.UI:CreateScrollList(parent, width, height)
	local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
	scrollFrame:SetSize(width, height)

	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetSize(width - 24, height)
	scrollFrame:SetScrollChild(content)

	return scrollFrame, content
end

-- Universal Shift-Click Hook to paste clean item names into focused GSF edit boxes
hooksecurefunc("ChatEdit_InsertLink", function(text)
	if not text then return end
	local focused = GetCurrentKeyBoardFocus()
	if focused and focused.isGSFInput then
		local cleanName = text:match("%[(.-)%]") or text
		focused:SetText(cleanName)
		focused:SetCursorPosition(string.len(cleanName))
		if focused.onItemPasted then
			focused:onItemPasted(cleanName)
		end
		return true
	end
end)

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
		if self.itemLink then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(self.itemLink)
			GameTooltip:Show()
		elseif self.itemID then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetItemByID(self.itemID)
			GameTooltip:Show()
		else
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
		self.itemLink = link
		self.itemID = itemID
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

	local function ResolveItem(text)
		if not text or text == "" then
			itemSlot:Clear()
			if callback then callback(nil) end
			return
		end
		local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(text)
		if name and texture then
			itemSlot:SetItem(name, texture, link)
			if callback then callback(name, link, texture) end
		else
			itemSlot:Clear()
			if callback then callback(nil) end
		end
	end

	editBox:HookScript("OnTextChanged", function(self, userInput)
		if not userInput then return end
		if debounceTimer then
			debounceTimer:Cancel()
		end
		local text = self:GetText():match("^%s*(.-)%s*$")
		debounceTimer = C_Timer.NewTimer(0.25, function()
			ResolveItem(text)
		end)
	end)

	editBox.onItemPasted = function(self, text)
		ResolveItem(text)
	end

	itemSlot.onItemDropped = function(slot, name, link, texture, itemID)
		editBox:SetText(name)
		if callback then callback(name, link, texture, itemID) end
	end
end

-- Generic tooltip attacher for item icon buttons
function GSF.UI:AttachItemTooltip(frame, getItemLinkFunc)
	frame:EnableMouse(true)
	frame:HookScript("OnEnter", function(self)
		local link = getItemLinkFunc and getItemLinkFunc(self)
		if link then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			if type(link) == "number" then
				GameTooltip:SetItemByID(link)
			else
				GameTooltip:SetHyperlink(link)
			end
			GameTooltip:Show()
		end
	end)
	frame:HookScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end
