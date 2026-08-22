local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabRoster = Tab

function Tab:Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	self.frame = frame

	-- Main/Alt Section
	local mainLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	mainLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -15)
	mainLabel:SetText(GSF.L["MAIN_ALT_TITLE"])

	local mainPrompt = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	mainPrompt:SetPoint("TOPLEFT", mainLabel, "BOTTOMLEFT", 0, -6)
	mainPrompt:SetText(GSF.L["SET_MAIN_CHARACTER"])

	local mainBox = GSF.UI:CreateEditBox(frame, 160, 22)
	mainBox:SetPoint("LEFT", mainPrompt, "RIGHT", 10, 0)
	mainBox:SetText(GSF.db.mainCharacter or GSF.DB:GetPlayerName())
	self.mainBox = mainBox

	local saveMainBtn = GSF.UI:CreateButton(frame, GSF.L["SAVE_MAIN"], 90, 22)
	saveMainBtn:SetPoint("LEFT", mainBox, "RIGHT", 10, 0)
	saveMainBtn:SetScript("OnClick", function()
		local text = mainBox:GetText()
		GSF.Alts:SetMyMain(text)
		GSF.Addon:Printf("Main character updated to '%s'.", text)
		Tab:Refresh()
	end)

	-- Settings Section (Top Right)
	local toastCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	toastCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 430, -15)
	toastCheck.text:SetText(GSF.L["ENABLE_TOASTS"])
	toastCheck.text:SetFontObject("GameFontHighlightSmall")
	toastCheck:SetChecked(GSF.db.enableToasts)
	toastCheck:SetScript("OnClick", function(cb)
		GSF.db.enableToasts = cb:GetChecked()
	end)

	local soundCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	soundCheck:SetPoint("TOPLEFT", toastCheck, "BOTTOMLEFT", 0, -4)
	soundCheck.text:SetText(GSF.L["ENABLE_SOUNDS"])
	soundCheck.text:SetFontObject("GameFontHighlightSmall")
	soundCheck:SetChecked(GSF.db.enableSounds)
	soundCheck:SetScript("OnClick", function(cb)
		GSF.db.enableSounds = cb:GetChecked()
	end)

	local dropAnnounceCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	dropAnnounceCheck:SetPoint("TOPLEFT", soundCheck, "BOTTOMLEFT", 0, -4)
	dropAnnounceCheck.text:SetText(GSF.L["ANNOUNCE_DROPS_PARTY"])
	dropAnnounceCheck.text:SetFontObject("GameFontHighlightSmall")
	dropAnnounceCheck.SetChecked(dropAnnounceCheck, GSF.db.announceDropsToParty)
	dropAnnounceCheck:SetScript("OnClick", function(cb)
		GSF.db.announceDropsToParty = cb:GetChecked()
	end)

	-- Sync Action Button
	local syncBtn = GSF.UI:CreateButton(frame, GSF.L["FORCE_SYNC"], 160, 24)
	syncBtn:SetPoint("TOPLEFT", mainPrompt, "BOTTOMLEFT", 0, -16)
	syncBtn:SetScript("OnClick", function()
		if GSF.Sync then
			GSF.Sync:BroadcastHello(true)
			GSF.Addon:Print("Sync request broadcasted to guild.")
		end
	end)

	local statText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	statText:SetPoint("LEFT", syncBtn, "RIGHT", 15, 0)
	self.statText = statText

	-- Roster Table Header
	local headerBar = CreateFrame("Frame", nil, frame)
	headerBar:SetSize(700, 20)
	headerBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -120)
	if BackdropTemplateMixin then Mixin(headerBar, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(headerBar, false)
	headerBar:SetBackdropColor(0.15, 0.15, 0.20, 0.9)

	local h1 = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	h1:SetPoint("LEFT", headerBar, "LEFT", 10, 0)
	h1:SetText("Character")

	local h2 = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	h2:SetPoint("LEFT", headerBar, "LEFT", 140, 0)
	h2:SetText("Main Account")

	local h3 = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	h3:SetPoint("LEFT", headerBar, "LEFT", 260, 0)
	h3:SetText("Professions")

	local h4 = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	h4:SetPoint("RIGHT", headerBar, "RIGHT", -15, 0)
	h4:SetText("Last Seen")

	-- Roster Table Scroll
	local scrollFrame, content = GSF.UI:CreateScrollList(frame, 700, 270)
	scrollFrame:SetPoint("TOPLEFT", headerBar, "BOTTOMLEFT", 0, -4)
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 15)
	self.content = content
	self.memberRows = {}

	return frame
end

function Tab:Refresh()
	if not self.frame or not self.frame:IsShown() then return end

	local numMembers = 0
	local numRecipes = 0
	local memberList = {}

	if GSF.cache and GSF.cache.members then
		for name, data in pairs(GSF.cache.members) do
			numMembers = numMembers + 1
			table.insert(memberList, data)
			if data.professions then
				for _, p in pairs(data.professions) do
					if p.recipes then
						for _ in pairs(p.recipes) do
							numRecipes = numRecipes + 1
						end
					end
				end
			end
		end
	end

	self.statText:SetText(string.format("Cached: %d Members  •  %d Recipes", numMembers, numRecipes))

	table.sort(memberList, function(a, b)
		return (a.lastSeen or 0) > (b.lastSeen or 0)
	end)

	for _, row in ipairs(self.memberRows) do row:Hide() end

	local yOffset = 0
	for i, member in ipairs(memberList) do
		local row = self.memberRows[i]
		if not row then
			row = CreateFrame("Frame", nil, self.content)
			row:SetSize(670, 24)
			if BackdropTemplateMixin then Mixin(row, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(row, false)
			row:SetBackdropColor(0.08, 0.08, 0.12, 0.6)

			local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			name:SetPoint("LEFT", row, "LEFT", 10, 0)
			row.name = name

			local main = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			main:SetPoint("LEFT", row, "LEFT", 140, 0)
			row.main = main

			local profs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			profs:SetPoint("LEFT", row, "LEFT", 260, 0)
			profs:SetPoint("RIGHT", row, "RIGHT", -120, 0)
			profs:SetJustifyH("LEFT")
			row.profs = profs

			local lastSeen = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			lastSeen:SetPoint("RIGHT", row, "RIGHT", -15, 0)
			row.lastSeen = lastSeen

			table.insert(self.memberRows, row)
		end

		row:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -yOffset)
		
		local isOnline = (time() - (member.lastSeen or 0)) < 900
		local statusDot = isOnline and "|cff00ff00●|r" or "|cff777777●|r"

		row.name:SetText(string.format("%s %s", statusDot, member.name or "Unknown"))
		row.main:SetText(member.main or member.name or "")

		local profList = {}
		if member.professions then
			for pName, pData in pairs(member.professions) do
				table.insert(profList, string.format("%s (%d)", pName, pData.curRank or 0))
			end
		end
		row.profs:SetText(#profList > 0 and table.concat(profList, ", ") or "None recorded")

		local mins = math.floor((time() - (member.lastSeen or time())) / 60)
		if isOnline then
			row.lastSeen:SetText("|cff00ff00Online|r")
		elseif mins < 60 then
			row.lastSeen:SetText(mins .. "m ago")
		elseif mins < 1440 then
			row.lastSeen:SetText(math.floor(mins / 60) .. "h ago")
		else
			row.lastSeen:SetText(math.floor(mins / 1440) .. "d ago")
		end

		row:Show()
		yOffset = yOffset + 26
	end

	self.content:SetHeight(math.max(yOffset, 270))
end
