local ADDON_NAME, GSF = ...

GSF.GoalsHUD = {}

local hudFrame = nil
local goalRows = {}

local function IsPlaceholderIcon(icon)
	if not icon then return true end
	if type(icon) == "number" then
		return icon == 134400 or icon == 0
	end
	return tostring(icon):find("INV_Misc_QuestionMark", 1, true) ~= nil
end

function GSF.GoalsHUD:Initialize()
	if hudFrame then return end

	local f = CreateFrame("Frame", "GSFHubGoalsHUDFrame", UIParent)
	f:SetSize(220, 100)
	local pos = GSF.db and GSF.db.goalsHUDPos or { point = "TOPRIGHT", relPoint = "TOPRIGHT", x = -20, y = -180 }
	f:SetPoint(pos.point or "TOPRIGHT", UIParent, pos.relPoint or "TOPRIGHT", pos.x or -20, pos.y or -180)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", function(frame)
		frame:StopMovingOrSizing()
		local point, _, relPoint, x, y = frame:GetPoint()
		if GSF.db then
			GSF.db.goalsHUDPos = { point = point, relPoint = relPoint, x = x, y = y }
		end
	end)
	f:SetClampedToScreen(true)
	f:SetFrameStrata("MEDIUM")

	if BackdropTemplateMixin then Mixin(f, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(f, false)
	f:SetBackdropColor(0.06, 0.06, 0.08, 0.85)

	-- Header Title
	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	title:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -6)
	title:SetText(GSF.L["GOALS_HUD_TITLE"] or "|cff33ff99GSF Goals|r")
	f.title = title

	-- Close / Hide Button
	local hideBtn = CreateFrame("Button", nil, f)
	hideBtn:SetSize(14, 14)
	hideBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -7, -6)
	hideBtn:SetAlpha(0.75)

	local hideTex = hideBtn:CreateTexture(nil, "ARTWORK")
	hideTex:SetAllPoints()
	hideTex:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
	hideTex:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)

	local hidePushed = hideBtn:CreateTexture(nil, "ARTWORK")
	hidePushed:SetAllPoints()
	hidePushed:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
	hidePushed:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
	hideBtn:SetPushedTexture(hidePushed)

	local hideHl = hideBtn:CreateTexture(nil, "HIGHLIGHT")
	hideHl:SetAllPoints()
	hideHl:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	hideHl:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
	hideHl:SetBlendMode("ADD")
	hideBtn:SetHighlightTexture(hideHl)

	hideBtn:SetScript("OnClick", function()
		f:Hide()
	end)
	hideBtn:SetScript("OnEnter", function(btn)
		btn:SetAlpha(1.0)
		GameTooltip:SetOwner(btn, "ANCHOR_TOP")
		GameTooltip:SetText(GSF.L["HUD_CLOSE_TOOLTIP"])
		GameTooltip:Show()
	end)
	hideBtn:SetScript("OnLeave", function(btn)
		btn:SetAlpha(0.75)
		GameTooltip:Hide()
	end)

	-- Open Personal Goals Manager Button (opens Atlas tab on Meine Ziele view)
	local manageBtn = CreateFrame("Button", nil, f)
	manageBtn:SetSize(14, 14)
	manageBtn:SetPoint("RIGHT", hideBtn, "LEFT", -5, 0)
	manageBtn:SetFrameLevel(f:GetFrameLevel() + 10)
	manageBtn:EnableMouse(true)
	manageBtn:RegisterForClicks("AnyUp")
	manageBtn:SetAlpha(0.75)

	local manageTex = manageBtn:CreateTexture(nil, "ARTWORK")
	manageTex:SetAllPoints()
	manageTex:SetTexture("Interface\\Buttons\\UI-OptionsButton")

	local manageHl = manageBtn:CreateTexture(nil, "HIGHLIGHT")
	manageHl:SetAllPoints()
	manageHl:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
	manageHl:SetBlendMode("ADD")
	manageBtn:SetHighlightTexture(manageHl)

	manageBtn:SetScript("OnClick", function()
		GSF.GoalsHUD:OpenManagerDialog()
	end)
	manageBtn:SetScript("OnEnter", function(btn)
		btn:SetAlpha(1.0)
		GameTooltip:SetOwner(btn, "ANCHOR_TOP")
		GameTooltip:SetText(GSF.L["MANAGE_GOALS"] or "Manage Goals")
		GameTooltip:Show()
	end)
	manageBtn:SetScript("OnLeave", function(btn)
		btn:SetAlpha(0.75)
		GameTooltip:Hide()
	end)

	-- Scroll content
	local content = CreateFrame("Frame", nil, f)
	content:SetPoint("TOPLEFT", f, "TOPLEFT", 6, -24)
	content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -6, 6)
	f.content = content

	-- Empty state prompt
	local emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	emptyText:SetPoint("CENTER", content, "CENTER", 0, 0)
	emptyText:SetWidth(200)
	emptyText:SetJustifyH("CENTER")
	emptyText:SetText(GSF.L["HUD_EMPTY_PROMPT"] or "No active goals. Pin a resource from the Atlas!")
	f.emptyText = emptyText

	f:SetScript("OnShow", function()
		if GSF.db then GSF.db.showGoalsHUD = true end
		GSF.GoalsHUD:NotifyStateChange()
	end)
	f:SetScript("OnHide", function()
		if GSF.db then GSF.db.showGoalsHUD = false end
		GSF.GoalsHUD:NotifyStateChange()
	end)

	hudFrame = f

	-- Register Bag event listener
	local bagWatcher = CreateFrame("Frame")
	bagWatcher:RegisterEvent("BAG_UPDATE")
	bagWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
	bagWatcher:SetScript("OnEvent", function()
		if GSF.GoalsHUD and hudFrame and hudFrame:IsShown() then
			GSF.GoalsHUD:Refresh()
		end
	end)
	self.bagWatcher = bagWatcher

	if GSF.db and GSF.db.showGoalsHUD then
		hudFrame:Show()
		self:Refresh()
	else
		hudFrame:Hide()
	end
end

function GSF.GoalsHUD:AddPersonalGoal(material, title, target, notes, icon, category, editId, itemID)
	if not material or material:trim() == "" then return false, "No material" end
	if not GSF.db then return false end
	if not GSF.db.myGoals then GSF.db.myGoals = {} end

	local cleanMat = material:trim()
	local cleanTitle = (title and title:trim() ~= "") and title:trim() or cleanMat
	local numTarget = tonumber(target) or 1
	if numTarget < 1 then numTarget = 1 end

	if editId then
		for _, g in ipairs(GSF.db.myGoals) do
			if g.id == editId then
				g.material = cleanMat
				g.title = cleanTitle
				g.name = cleanTitle
				g.target = numTarget
				g.notes = notes or ""
				if icon then g.icon = icon end
				if category then g.category = category end
				if itemID then g.itemID = itemID end
				self:Refresh()
				if self.managerDialog and self.managerDialog:IsShown() then
					self:RefreshManagerDialog()
				end
				return true, g
			end
		end
	end

	local goalId = string.format("goal-%d-%d", time(), math.random(1000, 9999))
	local goal = {
		id = goalId,
		material = cleanMat,
		title = cleanTitle,
		name = cleanTitle,
		target = numTarget,
		notes = notes or "",
		icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark",
		category = category or "General",
		itemID = itemID,
		created = time(),
	}

	table.insert(GSF.db.myGoals, goal)
	if not hudFrame then self:Initialize() end
	GSF.db.showGoalsHUD = true
	hudFrame:Show()
	self:Refresh()
	if self.managerDialog and self.managerDialog:IsShown() then
		self:RefreshManagerDialog()
	end

	if GSF.Toast then
		GSF.Toast:ShowToast(string.format("Goal: %s (x%d)", cleanTitle, numTarget), icon or "Interface\\Icons\\INV_Misc_Map02")
	end

	return true, goal
end

function GSF.GoalsHUD:AddGoal(itemName, targetCount, category, bountyId)
	if not itemName or itemName:trim() == "" then return end
	if not GSF.db then return end
	if not GSF.db.myGoals then GSF.db.myGoals = {} end

	local cleanName = itemName:trim()
	local target = tonumber(targetCount) or 20

	if bountyId then
		local exists = false
		for _, g in ipairs(GSF.db.myGoals) do
			if g.bountyId == bountyId then
				g.target = target
				exists = true
				break
			end
		end
		if not exists then
			table.insert(GSF.db.myGoals, {
				id = "bounty-" .. tostring(bountyId),
				material = cleanName,
				title = cleanName,
				name = cleanName,
				target = target,
				category = category or "Bounty",
				bountyId = bountyId,
				notes = "",
				created = time(),
			})
		end
		if not hudFrame then self:Initialize() end
		GSF.db.showGoalsHUD = true
		hudFrame:Show()
		self:Refresh()
		return
	end

	self:AddPersonalGoal(cleanName, cleanName, target, "", nil, category)
end

function GSF.GoalsHUD:MoveGoal(index, direction)
	if not GSF.db or not GSF.db.myGoals then return end
	local target = index + direction
	if target < 1 or target > #GSF.db.myGoals then return end
	local temp = GSF.db.myGoals[index]
	GSF.db.myGoals[index] = GSF.db.myGoals[target]
	GSF.db.myGoals[target] = temp
	self:Refresh()
	if self.managerDialog and self.managerDialog:IsShown() then
		self:RefreshManagerDialog()
	end
end

function GSF.GoalsHUD:ReorderGoal(sourceIndex, targetIndex)
	if not GSF.db or not GSF.db.myGoals then return end
	if sourceIndex < 1 or sourceIndex > #GSF.db.myGoals then return end
	if targetIndex < 1 or targetIndex > #GSF.db.myGoals then return end
	if sourceIndex == targetIndex then return end

	local item = table.remove(GSF.db.myGoals, sourceIndex)
	table.insert(GSF.db.myGoals, targetIndex, item)
	self:Refresh()
	if self.managerDialog and self.managerDialog:IsShown() then
		self:RefreshManagerDialog()
	end
end

function GSF.GoalsHUD:RemoveGoal(index)
	if not GSF.db or not GSF.db.myGoals then return end
	table.remove(GSF.db.myGoals, index)
	self:Refresh()
	if self.managerDialog and self.managerDialog:IsShown() then
		self:RefreshManagerDialog()
	end
end

function GSF.GoalsHUD:RemoveGoalByName(name)
	if not GSF.db or not GSF.db.myGoals or not name then return end
	local lower = name:lower():trim()
	for i = #GSF.db.myGoals, 1, -1 do
		if GSF.db.myGoals[i].name:lower():trim() == lower then
			table.remove(GSF.db.myGoals, i)
		end
	end
	self:Refresh()
	if self.managerDialog and self.managerDialog:IsShown() then
		self:RefreshManagerDialog()
	end
end

function GSF.GoalsHUD:CountItemInBags(itemName, itemID)
	if itemID and tonumber(itemID) and tonumber(itemID) > 0 then
		local countById = GetItemCount(tonumber(itemID))
		if countById ~= nil then return countById end
	end
	if not itemName then return 0 end
	local nativeCount = GetItemCount(itemName)
	if nativeCount and nativeCount > 0 then return nativeCount end

	local total = 0
	local lowerName = itemName:lower():trim()
	local getNumSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
	local getItemInfo = (C_Container and C_Container.GetContainerItemInfo) or GetContainerItemInfo
	local getItemLink = (C_Container and C_Container.GetContainerItemLink) or GetContainerItemLink

	for bag = 0, 4 do
		local numSlots = getNumSlots and getNumSlots(bag) or 0
		for slot = 1, numSlots do
			local link = getItemLink and getItemLink(bag, slot)
			if link then
				local cleanLinkName = link:match("%[(.-)%]") or link
				if cleanLinkName:lower():find(lowerName, 1, true) or lowerName:find(cleanLinkName:lower(), 1, true) then
					local count = 1
					if getItemInfo then
						local itemInfo = getItemInfo(bag, slot)
						if type(itemInfo) == "table" then
							count = itemInfo.stackCount or itemInfo.count or 1
						else
							count = select(2, getItemInfo(bag, slot)) or 1
						end
					end
					total = total + count
				end
			end
		end
	end

	-- Fallback: if itemName is a node/deposit name, check primary yield / itemID from AtlasJournal
	if total == 0 and AtlasJournal and AtlasJournal.FindResource then
		local res = AtlasJournal:FindResource(itemName)
		if res then
			local resId = res.id or res.itemID
			if resId then
				local c = GetItemCount(resId)
				if c and c > 0 then return c end
			end
			local yieldItem = AtlasJournal.GetItemDisplayName and AtlasJournal:GetItemDisplayName(res)
			if yieldItem and yieldItem:lower() ~= lowerName then
				local c = GetItemCount(yieldItem)
				if c and c > 0 then return c end
			end
		end
	end

	return total
end

function GSF.GoalsHUD:Refresh()
	if not hudFrame or not hudFrame:IsShown() then return end
	if not GSF.db or not GSF.db.myGoals then return end

	hudFrame.title:SetText(GSF.L["GOALS_HUD_TITLE"] or "|cff33ff99GSF Goals|r")

	for _, r in ipairs(goalRows) do r:Hide() end

	local remainingCounts = {}
	local yOffset = 0
	for i, goal in ipairs(GSF.db.myGoals) do
		local row = goalRows[i]
		if not row then
			row = CreateFrame("Frame", nil, hudFrame.content)
			row:SetSize(208, 32)

			local bar = CreateFrame("StatusBar", nil, row)
			bar:SetSize(204, 14)
			bar:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 2, 2)
			bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
			bar:SetStatusBarColor(0.2, 0.8, 0.4, 0.9)

			local barBg = bar:CreateTexture(nil, "BACKGROUND")
			barBg:SetAllPoints()
			barBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)

			local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			label:SetPoint("TOPLEFT", row, "TOPLEFT", 2, 0)
			label:SetJustifyH("LEFT")
			label:SetWordWrap(false)
			row.label = label

			local noteIcon = CreateFrame("Button", nil, row)
			noteIcon:SetSize(12, 12)
			local noteTex = noteIcon:CreateTexture(nil, "ARTWORK")
			noteTex:SetAllPoints()
			noteTex:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
			noteIcon.tex = noteTex
			noteIcon:Hide()
			row.noteIcon = noteIcon

			local barText = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			barText:SetPoint("CENTER", bar, "CENTER", 0, 0)
			row.barText = barText

			local removeBtn = CreateFrame("Button", nil, row)
			removeBtn:SetSize(14, 14)
			removeBtn:SetPoint("TOPRIGHT", row, "TOPRIGHT", -1, 1)
			removeBtn:SetAlpha(0.35)
			local rmTex = removeBtn:CreateTexture(nil, "ARTWORK")
			rmTex:SetAllPoints()
			rmTex:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
			removeBtn:SetScript("OnEnter", function(btn)
				btn:SetAlpha(1.0)
				GameTooltip:SetOwner(btn, "ANCHOR_TOP")
				GameTooltip:SetText(GSF.L["REMOVE_GOAL_TOOLTIP"])
				GameTooltip:Show()
			end)
			removeBtn:SetScript("OnLeave", function(btn)
				btn:SetAlpha(0.35)
				GameTooltip:Hide()
			end)
			row.removeBtn = removeBtn

			row.bar = bar
			table.insert(goalRows, row)
		end

		row:SetPoint("TOPLEFT", hudFrame.content, "TOPLEFT", 0, -yOffset)

		local gIdx = i
		local gData = goal
		row.removeBtn:SetScript("OnClick", function()
			if gData.bountyId or gData.category == "Bounty" then
				StaticPopup_Show("GSF_CONFIRM_UNCLAIM_BOUNTY", nil, nil, { index = gIdx, bountyId = gData.bountyId, itemName = gData.name })
			else
				GSF.GoalsHUD:RemoveGoal(gIdx)
			end
		end)

		-- FIFO Waterfall Inventory Allocation
		local matKey = (goal.material or goal.name):lower():trim()
		if remainingCounts[matKey] == nil then
			remainingCounts[matKey] = self:CountItemInBags(goal.material or goal.name, goal.itemID)
		end

		local avail = remainingCounts[matKey]
		local target = goal.target or 1
		local allocated = math.min(avail, target)
		remainingCounts[matKey] = avail - allocated

		local pct = math.min(math.floor((allocated / target) * 100), 100)

		local isBounty = (goal.bountyId or goal.category == "Bounty")
		local tag = isBounty and ("|cffffd100" .. (GSF.L["BOUNTY_TAG"] or "[Bounty]") .. " |r") or ""
		local dispTitle = goal.title or goal.name
		row.label:SetText(string.format("%s|cffffffff%s|r", tag, dispTitle))

		local hasNotes = goal.notes and goal.notes:trim() ~= ""
		local maxTextWidth = hasNotes and 170 or 185
		row.label:SetWidth(0)
		local strWidth = row.label:GetStringWidth()
		if strWidth > maxTextWidth then
			row.label:SetWidth(maxTextWidth)
			strWidth = maxTextWidth
		else
			row.label:SetWidth(strWidth)
		end

		-- Note icon immediately following text
		if hasNotes then
			row.noteIcon:ClearAllPoints()
			row.noteIcon:SetPoint("LEFT", row.label, "RIGHT", 4, 0)
			row.noteIcon:Show()
			row.noteIcon:SetScript("OnEnter", function(selfIcon)
				GameTooltip:SetOwner(selfIcon, "ANCHOR_RIGHT")
				GameTooltip:AddLine(dispTitle, 1, 0.82, 0)
				GameTooltip:AddLine(GSF.L["NOTE_TOOLTIP_HEADER"] or "Goal Note:", 0.7, 0.7, 0.7)
				GameTooltip:AddLine(goal.notes, 1, 1, 1, true)
				GameTooltip:Show()
			end)
			row.noteIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)
		else
			row.noteIcon:Hide()
		end

		row.bar:SetMinMaxValues(0, target)
		row.bar:SetValue(allocated)

		if allocated >= target then
			row.bar:SetStatusBarColor(0.0, 1.0, 0.3, 0.9)
			row.barText:SetText(string.format("|cff00ff00%d / %d (100%%)|r", allocated, target))
		else
			row.bar:SetStatusBarColor(0.2, 0.9, 0.6, 0.9)
			row.barText:SetText(string.format("%d / %d (%d%%)", allocated, target, pct))
		end

		row:Show()
		yOffset = yOffset + 34
	end

	local count = GSF.db.myGoals and #GSF.db.myGoals or 0
	if count == 0 then
		if hudFrame.emptyText then
			hudFrame.emptyText:SetText(GSF.L["HUD_EMPTY_PROMPT"] or "No active goals. Pin a resource from the Atlas!")
			hudFrame.emptyText:Show()
		end
		hudFrame:SetHeight(65)
	else
		if hudFrame.emptyText then
			hudFrame.emptyText:Hide()
		end
		hudFrame:SetHeight(math.max(yOffset + 34, 45))
	end

	if GSF.TabAtlas and GSF.TabAtlas.RefreshGoals and GSF.TabAtlas.GetActiveView and GSF.TabAtlas:GetActiveView() == "GOALS" then
		GSF.TabAtlas:RefreshGoals()
	end
end

function GSF.GoalsHUD:IsShown()
	return (hudFrame and hudFrame:IsShown()) and true or false
end

function GSF.GoalsHUD:SetShown(show)
	if not hudFrame then self:Initialize() end
	if show then
		hudFrame:Show()
		if GSF.db then GSF.db.showGoalsHUD = true end
		self:Refresh()
	else
		hudFrame:Hide()
		if GSF.db then GSF.db.showGoalsHUD = false end
	end
	self:NotifyStateChange()
end

function GSF.GoalsHUD:Toggle()
	self:SetShown(not self:IsShown())
end

function GSF.GoalsHUD:ResetPosition()
	if not hudFrame then self:Initialize() end
	hudFrame:ClearAllPoints()
	hudFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -20, -180)
	if GSF.db then
		GSF.db.goalsHUDPos = { point = "TOPRIGHT", relPoint = "TOPRIGHT", x = -20, y = -180 }
	end
end

function GSF.GoalsHUD:NotifyStateChange()
	if GSF.TabSettings and GSF.TabSettings.goalsHUDCheck then
		GSF.TabSettings.goalsHUDCheck:SetChecked(self:IsShown())
	end
end

function GSF.GoalsHUD:GetRowUnderCursor()
	if not self.managerDialog or not self.managerDialog:IsShown() then return nil end
	local cursorX, cursorY = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	cursorY = cursorY / scale

	for _, r in ipairs(self.managerDialog.rows or {}) do
		if r:IsShown() then
			local top = r:GetTop()
			local bottom = r:GetBottom()
			if top and bottom and cursorY <= top and cursorY >= bottom then
				return r.goalIndex
			end
		end
	end
	return nil
end

function GSF.GoalsHUD:BuildManagerDialog()
	if self.managerDialog then return self.managerDialog end

	local dlg = CreateFrame("Frame", "GSFPersonalGoalsManagerDialog", UIParent)
	dlg:SetSize(560, 390)
	dlg:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	dlg:SetFrameStrata("DIALOG")
	dlg:SetMovable(true)
	dlg:EnableMouse(true)
	dlg:RegisterForDrag("LeftButton")
	dlg:SetScript("OnDragStart", dlg.StartMoving)
	dlg:SetScript("OnDragStop", dlg.StopMovingOrSizing)
	dlg:SetClampedToScreen(true)

	if BackdropTemplateMixin then Mixin(dlg, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(dlg, false)
	dlg:SetBackdropColor(0.06, 0.06, 0.08, 0.98)
	dlg:Hide()

	local title = dlg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", dlg, "TOP", 0, -14)
	title:SetText(string.format("|cff%s%s|r", GSF.COLORS.PRIMARY, GSF.L["MANAGE_GOALS_TITLE"] or "Personal Goals Manager"))
	dlg.title = title

	local closeX = CreateFrame("Button", nil, dlg, "UIPanelCloseButton")
	closeX:SetPoint("TOPRIGHT", dlg, "TOPRIGHT", -4, -4)
	closeX:SetScript("OnClick", function() dlg:Hide() end)

	local scrollFrame, content = GSF.UI:CreateScrollList(dlg, 515, 280)
	scrollFrame:SetPoint("TOPLEFT", dlg, "TOPLEFT", 20, -46)
	dlg.scrollFrame = scrollFrame
	dlg.content = content
	dlg.rows = {}

	local empty = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	empty:SetPoint("CENTER", content, "CENTER", 0, 0)
	empty:SetText(GSF.L["NO_GOALS_LISTED"] or "No active personal goals.")
	dlg.empty = empty

	local closeBtn = GSF.UI:CreateButton(dlg, GSF.L["CLOSE"] or "Close", 100, 24)
	closeBtn:SetPoint("BOTTOM", dlg, "BOTTOM", 0, 14)
	closeBtn:SetScript("OnClick", function() dlg:Hide() end)

	self.managerDialog = dlg
	return dlg
end

function GSF.GoalsHUD:OpenManagerDialog()
	if GSF.MainFrame then
		if not GSF.MainFrame.initialized then
			GSF.MainFrame:Initialize()
			GSF.MainFrame.initialized = true
		end
		GSF.MainFrame:Show()
		GSF.MainFrame:SelectTab(5)
	elseif _G["GSFHubMainFrame"] then
		_G["GSFHubMainFrame"]:Show()
	end
	if GSF.TabAtlas and GSF.TabAtlas.SwitchView then
		GSF.TabAtlas:SwitchView("GOALS")
	end
end

function GSF.GoalsHUD:RefreshManagerDialog()
	if not self.managerDialog or not self.managerDialog:IsShown() then return end
	local dlg = self.managerDialog
	local goals = GSF.db and GSF.db.myGoals or {}

	for _, r in ipairs(dlg.rows) do r:Hide() end

	if #goals == 0 then
		dlg.empty:Show()
	else
		dlg.empty:Hide()
	end

	local remainingCounts = {}
	local yOffset = 0

	for i, goal in ipairs(goals) do
		local row = dlg.rows[i]
		if not row then
			row = CreateFrame("Frame", nil, dlg.content)
			row:SetSize(510, 48)
			if BackdropTemplateMixin then Mixin(row, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(row, false)
			row:SetBackdropColor(0.10, 0.10, 0.14, 0.75)

			-- Grip Handle for Drag and Drop
			local grip = CreateFrame("Button", nil, row)
			grip:SetSize(14, 26)
			grip:SetPoint("LEFT", row, "LEFT", 6, 0)
			local gripText = grip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			gripText:SetPoint("CENTER", grip, "CENTER", 0, 0)
			gripText:SetText("|cff888888::|r")
			grip:RegisterForDrag("LeftButton")
			grip:SetScript("OnDragStart", function(selfGrip)
				local pRow = selfGrip:GetParent()
				dlg.draggedIndex = pRow.goalIndex
				pRow:SetAlpha(0.4)
			end)
			grip:SetScript("OnDragStop", function(selfGrip)
				local pRow = selfGrip:GetParent()
				pRow:SetAlpha(1.0)
				if dlg.draggedIndex then
					local targetIndex = GSF.GoalsHUD:GetRowUnderCursor()
					if targetIndex and targetIndex ~= dlg.draggedIndex then
						GSF.GoalsHUD:ReorderGoal(dlg.draggedIndex, targetIndex)
					end
					dlg.draggedIndex = nil
				end
			end)
			grip:SetScript("OnEnter", function() gripText:SetText("|cffffd100::|r") end)
			grip:SetScript("OnLeave", function() gripText:SetText("|cff888888::|r") end)
			row.grip = grip

			-- Up / Down Buttons with native Blizzard textures
			local upBtn = CreateFrame("Button", nil, row)
			upBtn:SetSize(14, 12)
			upBtn:SetPoint("LEFT", grip, "RIGHT", 3, 7)
			upBtn:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up")
			upBtn:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Down")
			upBtn:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Disabled")
			upBtn:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Highlight")
			row.upBtn = upBtn

			local downBtn = CreateFrame("Button", nil, row)
			downBtn:SetSize(14, 12)
			downBtn:SetPoint("LEFT", grip, "RIGHT", 3, -7)
			downBtn:SetNormalTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Up")
			downBtn:SetPushedTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Down")
			downBtn:SetDisabledTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Disabled")
			downBtn:SetHighlightTexture("Interface\\Buttons\\UI-ScrollBar-ScrollDownButton-Highlight")
			row.downBtn = downBtn

			-- Resource Icon
			local iconBtn = CreateFrame("Button", nil, row)
			iconBtn:SetSize(32, 32)
			iconBtn:SetPoint("LEFT", upBtn, "RIGHT", 6, -7)
			local icon = iconBtn:CreateTexture(nil, "ARTWORK")
			icon:SetAllPoints()
			row.icon = icon
			row.iconBtn = iconBtn

			-- Title and Subtitle
			local titleText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
			titleText:SetPoint("TOPLEFT", iconBtn, "TOPRIGHT", 10, -2)
			titleText:SetWidth(165)
			titleText:SetJustifyH("LEFT")
			titleText:SetWordWrap(false)
			row.titleText = titleText

			local subText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			subText:SetPoint("BOTTOMLEFT", iconBtn, "BOTTOMRIGHT", 10, 2)
			subText:SetWidth(165)
			subText:SetJustifyH("LEFT")
			subText:SetWordWrap(false)
			row.subText = subText

			-- Progress Bar
			local bar = CreateFrame("StatusBar", nil, row)
			bar:SetSize(100, 14)
			bar:SetPoint("LEFT", titleText, "RIGHT", 10, 0)
			bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
			bar:SetStatusBarColor(0.2, 0.7, 0.9, 0.9)
			local barBg = bar:CreateTexture(nil, "BACKGROUND")
			barBg:SetAllPoints()
			barBg:SetColorTexture(0.1, 0.1, 0.1, 0.8)
			local barLabel = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			barLabel:SetPoint("CENTER", bar, "CENTER", 0, 0)
			row.bar = bar
			row.barLabel = barLabel

			-- Note Icon
			local noteIcon = CreateFrame("Button", nil, row)
			noteIcon:SetSize(16, 16)
			noteIcon:SetPoint("LEFT", bar, "RIGHT", 6, 0)
			local noteTex = noteIcon:CreateTexture(nil, "ARTWORK")
			noteTex:SetAllPoints()
			noteTex:SetTexture("Interface\\Buttons\\UI-GuildScheduler-Note")
			row.noteIcon = noteIcon

			-- Action Buttons (Edit and Remove)
			local removeBtn = GSF.UI:CreateButton(row, GSF.L["REMOVE"] or "Remove", 65, 20)
			removeBtn:SetPoint("RIGHT", row, "RIGHT", -6, 0)
			row.removeBtn = removeBtn

			local editBtn = GSF.UI:CreateButton(row, GSF.L["EDIT"] or "Edit", 65, 20)
			editBtn:SetPoint("RIGHT", removeBtn, "LEFT", -6, 0)
			row.editBtn = editBtn

			table.insert(dlg.rows, row)
		end

		row:SetPoint("TOPLEFT", dlg.content, "TOPLEFT", 0, -yOffset)
		row.goalIndex = i

		-- Wire Up/Down
		row.upBtn:SetScript("OnClick", function() GSF.GoalsHUD:MoveGoal(i, -1) end)
		row.downBtn:SetScript("OnClick", function() GSF.GoalsHUD:MoveGoal(i, 1) end)
		if i == 1 then row.upBtn:Disable() row.upBtn:SetAlpha(0.3) else row.upBtn:Enable() row.upBtn:SetAlpha(1.0) end
		if i == #goals then row.downBtn:Disable() row.downBtn:SetAlpha(0.3) else row.downBtn:Enable() row.downBtn:SetAlpha(1.0) end

		-- Dynamic Icon Resolution (falls back to item info or resource if missing)
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

		-- Titles
		local dispTitle = goal.title or goal.name
		row.titleText:SetText(dispTitle)
		if goal.material and goal.material ~= dispTitle then
			row.subText:SetText(goal.material)
			row.subText:Show()
		else
			row.subText:Hide()
		end

		-- FIFO Allocation
		local matKey = (goal.material or goal.name):lower():trim()
		if remainingCounts[matKey] == nil then
			remainingCounts[matKey] = self:CountItemInBags(goal.material or goal.name, goal.itemID)
		end
		local avail = remainingCounts[matKey]
		local target = goal.target or 1
		local allocated = math.min(avail, target)
		remainingCounts[matKey] = avail - allocated

		row.bar:SetMinMaxValues(0, target)
		row.bar:SetValue(allocated)
		if allocated >= target then
			row.bar:SetStatusBarColor(0.0, 1.0, 0.3, 0.9)
			row.barLabel:SetText(string.format("|cff00ff00%d/%d|r", allocated, target))
		else
			row.bar:SetStatusBarColor(0.2, 0.7, 0.9, 0.9)
			row.barLabel:SetText(string.format("%d/%d", allocated, target))
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
			row.editBtn:SetText(GSF.L["EDIT"] or "Edit")
			row.editBtn:SetScript("OnClick", function()
				if GSF.TabAtlas then
					GSF.TabAtlas:OpenGoalModal(goal)
				end
			end)
		end

		-- Remove Button
		local gIdx = i
		local gData = goal
		row.removeBtn:SetText(GSF.L["REMOVE"] or "Remove")
		row.removeBtn:SetScript("OnClick", function()
			if gData.bountyId or gData.category == "Bounty" then
				StaticPopup_Show("GSF_CONFIRM_UNCLAIM_BOUNTY", nil, nil, { index = gIdx, bountyId = gData.bountyId, itemName = gData.name })
			else
				GSF.GoalsHUD:RemoveGoal(gIdx)
			end
		end)

		row:Show()
		yOffset = yOffset + 52
	end

	dlg.content:SetHeight(math.max(yOffset, 1))

	local scrollBar = dlg.scrollFrame and (dlg.scrollFrame.ScrollBar or (dlg.scrollFrame:GetName() and _G[dlg.scrollFrame:GetName() .. "ScrollBar"]))
	if scrollBar then
		if #goals <= 5 or yOffset <= 280 then
			scrollBar:Hide()
		else
			scrollBar:Show()
		end
	end
end

StaticPopupDialogs["GSF_CONFIRM_UNCLAIM_BOUNTY"] = {
	text = GSF.L["CONFIRM_UNCLAIM_BOUNTY"] or "Are you sure you want to unclaim this guild bounty?",
	button1 = GSF.L["YES"] or "Yes",
	button2 = GSF.L["NO"] or "No",
	OnAccept = function(self, data)
		if data then
			if data.bountyId and GSF.SupplyBounties then
				GSF.SupplyBounties:UnclaimBounty(data.bountyId)
			elseif data.index then
				GSF.GoalsHUD:RemoveGoal(data.index)
			end
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}
