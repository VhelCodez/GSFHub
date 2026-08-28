local ADDON_NAME, GSF = ...

GSF.GoalsHUD = {}

local hudFrame = nil
local goalRows = {}

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
	hideBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -6, -6)
	local hideTex = hideBtn:CreateTexture(nil, "ARTWORK")
	hideTex:SetAllPoints()
	hideTex:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
	hideBtn:SetScript("OnClick", function()
		f:Hide()
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

function GSF.GoalsHUD:AddGoal(itemName, targetCount, category)
	if not itemName or itemName:trim() == "" then return end
	if not GSF.db then return end
	if not GSF.db.myGoals then GSF.db.myGoals = {} end

	local cleanName = itemName:trim()
	local target = tonumber(targetCount) or 20

	-- Check if goal already exists, if so update target
	local exists = false
	for _, g in ipairs(GSF.db.myGoals) do
		if g.name:lower() == cleanName:lower() then
			g.target = target
			exists = true
			break
		end
	end

	if not exists then
		table.insert(GSF.db.myGoals, {
			name = cleanName,
			target = target,
			category = category or "General",
		})
	end

	if not hudFrame then self:Initialize() end
	GSF.db.showGoalsHUD = true
	hudFrame:Show()
	self:Refresh()

	if GSF.Toast then
		GSF.Toast:ShowToast(string.format("Goal Pinned: %s (x%d)", cleanName, target), "Interface\\Icons\\INV_Misc_Map02")
	end
end

function GSF.GoalsHUD:RemoveGoal(index)
	if not GSF.db or not GSF.db.myGoals then return end
	table.remove(GSF.db.myGoals, index)
	self:Refresh()
end

function GSF.GoalsHUD:CountItemInBags(itemName)
	if not itemName then return 0 end
	local total = 0
	local lowerName = itemName:lower()

	local getNumSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
	local getItemInfo = (C_Container and C_Container.GetContainerItemInfo) or GetContainerItemInfo
	local getItemLink = (C_Container and C_Container.GetContainerItemLink) or GetContainerItemLink

	for bag = 0, 4 do
		local numSlots = getNumSlots and getNumSlots(bag) or 0
		for slot = 1, numSlots do
			local link = getItemLink and getItemLink(bag, slot)
			if link and link:lower():find(lowerName, 1, true) then
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
	return total
end

function GSF.GoalsHUD:Refresh()
	if not hudFrame or not hudFrame:IsShown() then return end
	if not GSF.db or not GSF.db.myGoals then return end

	hudFrame.title:SetText(GSF.L["GOALS_HUD_TITLE"] or "|cff33ff99GSF Goals|r")

	for _, r in ipairs(goalRows) do r:Hide() end

	local yOffset = 0
	for i, goal in ipairs(GSF.db.myGoals) do
		local row = goalRows[i]
		if not row then
			row = CreateFrame("Frame", nil, hudFrame.content)
			row:SetSize(208, 30)

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
			row.label = label

			local barText = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			barText:SetPoint("CENTER", bar, "CENTER", 0, 0)
			row.barText = barText

			local removeBtn = CreateFrame("Button", nil, row)
			removeBtn:SetSize(12, 12)
			removeBtn:SetPoint("TOPRIGHT", row, "TOPRIGHT", -2, 0)
			local rmTex = removeBtn:CreateTexture(nil, "ARTWORK")
			rmTex:SetAllPoints()
			rmTex:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
			removeBtn:SetScript("OnClick", function()
				GSF.GoalsHUD:RemoveGoal(i)
			end)

			row.bar = bar
			table.insert(goalRows, row)
		end

		row:SetPoint("TOPLEFT", hudFrame.content, "TOPLEFT", 0, -yOffset)

		local curCount = self:CountItemInBags(goal.name)
		local target = goal.target or 1
		local pct = math.min(math.floor((curCount / target) * 100), 100)

		row.label:SetText(string.format("|cffffffff%s|r", goal.name))
		row.bar:SetMinMaxValues(0, target)
		row.bar:SetValue(math.min(curCount, target))

		if curCount >= target then
			row.bar:SetStatusBarColor(0.0, 1.0, 0.3, 0.9)
			row.barText:SetText(string.format("|cff00ff00%d / %d (100%%)|r", curCount, target))
		else
			row.bar:SetStatusBarColor(0.2, 0.7, 0.9, 0.9)
			row.barText:SetText(string.format("%d / %d (%d%%)", curCount, target, pct))
		end

		row:Show()
		yOffset = yOffset + 32
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
