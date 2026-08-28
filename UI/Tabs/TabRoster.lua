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
	self.mainLabel = mainLabel

	local mainPrompt = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	mainPrompt:SetPoint("TOPLEFT", mainLabel, "BOTTOMLEFT", 0, -6)
	mainPrompt:SetText(GSF.L["SET_MAIN_CHARACTER"])
	self.mainPrompt = mainPrompt

	local mainBox = GSF.UI:CreateEditBox(frame, 140, 22)
	mainBox:SetPoint("LEFT", mainPrompt, "RIGHT", 10, 0)
	mainBox:SetText(GSF.db and GSF.db.mainCharacter or GSF.DB:GetPlayerName())
	self.mainBox = mainBox

	local saveMainBtn = GSF.UI:CreateButton(frame, GSF.L["SAVE_MAIN"], 80, 22)
	saveMainBtn:SetPoint("LEFT", mainBox, "RIGHT", 8, 0)
	self.saveMainBtn = saveMainBtn

	saveMainBtn:SetScript("OnClick", function()
		local text = mainBox:GetText()
		GSF.Alts:SetMyMain(text)
		GSF.Addon:Printf("Main character updated to '%s'.", text)
		Tab:Refresh()
	end)

	-- Sync Action Button
	local syncBtn = GSF.UI:CreateButton(frame, GSF.L["FORCE_SYNC"], 150, 22)
	syncBtn:SetPoint("TOPLEFT", mainPrompt, "BOTTOMLEFT", 0, -12)
	self.syncBtn = syncBtn

	syncBtn:SetScript("OnClick", function()
		if not IsInGuild() then
			GSF.Addon:Printf("|cffff9900%s|r", GSF.L["NO_GUILD_WARNING"] or "You are not currently in a guild. Guild synchronization is disabled.")
			return
		end
		if GSF.Sync then
			GSF.Sync:BroadcastHello(true)
			GSF.Addon:Print("Sync request broadcasted to guild.")
		end
	end)

	local statText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	statText:SetPoint("LEFT", syncBtn, "RIGHT", 12, 0)
	self.statText = statText

	-- Bug Report / Feedback Button (Left under sync)
	local bugBtn = GSF.UI:CreateButton(frame, GSF.L["REPORT_BUG_BTN"], 200, 22)
	bugBtn:SetPoint("TOPLEFT", syncBtn, "BOTTOMLEFT", 0, -8)
	self.bugBtn = bugBtn

	bugBtn:SetScript("OnClick", function()
		if GSF.FeedbackDialog then
			GSF.FeedbackDialog:Show()
		end
	end)

	-- Settings Section (Top Right)
	local langLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	langLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 430, -12)
	langLabel:SetText(GSF.L["LANGUAGE_LABEL"])
	self.langLabel = langLabel

	local langDropdown = CreateFrame("Button", "GSFLangDropdown", frame, "UIDropDownMenuTemplate")
	langDropdown:SetPoint("TOPLEFT", langLabel, "BOTTOMLEFT", -15, 2)
	UIDropDownMenu_SetWidth(langDropdown, 160)
	self.langDropdown = langDropdown

	local function GetLangText(code)
		if code == "deDE" then return GSF.L["LANG_DE"]
		elseif code == "enUS" then return GSF.L["LANG_EN"]
		else return GSF.L["LANG_AUTO"] end
	end

	local curLocale = GSF.db and GSF.db.selectedLocale or "auto"
	UIDropDownMenu_SetText(langDropdown, GetLangText(curLocale))

	local langOptions = {
		{ text = GSF.L["LANG_AUTO"], value = "auto" },
		{ text = GSF.L["LANG_EN"], value = "enUS" },
		{ text = GSF.L["LANG_DE"], value = "deDE" },
	}

	UIDropDownMenu_Initialize(langDropdown, function(self, level)
		for _, opt in ipairs(langOptions) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = opt.text
			info.value = opt.value
			info.func = function(btn)
				GSF:SetLanguage(btn.value)
				UIDropDownMenu_SetSelectedValue(langDropdown, btn.value)
				UIDropDownMenu_SetText(langDropdown, GetLangText(btn.value))
				Tab:UpdateTexts()
			end
			info.checked = ((GSF.db and GSF.db.selectedLocale or "auto") == opt.value)
			UIDropDownMenu_AddButton(info, level)
		end
	end)

	-- 2-column layout for checkboxes to keep well clear of table header at Y = -135
	local toastCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	toastCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 425, -54)
	toastCheck.text:SetText(GSF.L["ENABLE_TOASTS"])
	toastCheck.text:SetFontObject("GameFontHighlightSmall")
	toastCheck.text:SetPoint("LEFT", toastCheck, "RIGHT", 2, 1)
	toastCheck:SetChecked(GSF.db and GSF.db.enableToasts)
	self.toastCheck = toastCheck

	toastCheck:SetScript("OnClick", function(cb)
		GSF.db.enableToasts = cb:GetChecked()
	end)

	local soundCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	soundCheck:SetPoint("TOPLEFT", toastCheck, "BOTTOMLEFT", 0, -4)
	soundCheck.text:SetText(GSF.L["ENABLE_SOUNDS"])
	soundCheck.text:SetFontObject("GameFontHighlightSmall")
	soundCheck.text:SetPoint("LEFT", soundCheck, "RIGHT", 2, 1)
	soundCheck:SetChecked(GSF.db and GSF.db.enableSounds)
	self.soundCheck = soundCheck

	soundCheck:SetScript("OnClick", function(cb)
		GSF.db.enableSounds = cb:GetChecked()
	end)

	local dropAnnounceCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	dropAnnounceCheck:SetPoint("TOPLEFT", frame, "TOPLEFT", 565, -54)
	dropAnnounceCheck.text:SetText(GSF.L["ANNOUNCE_DROPS_PARTY"])
	dropAnnounceCheck.text:SetFontObject("GameFontHighlightSmall")
	dropAnnounceCheck.text:SetPoint("LEFT", dropAnnounceCheck, "RIGHT", 2, 1)
	dropAnnounceCheck:SetChecked(GSF.db and GSF.db.announceDropsToParty)
	self.dropAnnounceCheck = dropAnnounceCheck

	dropAnnounceCheck:SetScript("OnClick", function(cb)
		GSF.db.announceDropsToParty = cb:GetChecked()
	end)

	local goalsHUDCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	goalsHUDCheck:SetPoint("TOPLEFT", dropAnnounceCheck, "BOTTOMLEFT", 0, -4)
	goalsHUDCheck.text:SetText(GSF.L["ENABLE_GOALS_HUD"] or "Show Goals HUD")
	goalsHUDCheck.text:SetFontObject("GameFontHighlightSmall")
	goalsHUDCheck.text:SetPoint("LEFT", goalsHUDCheck, "RIGHT", 2, 1)
	goalsHUDCheck:SetChecked(GSF.db and GSF.db.showGoalsHUD)
	self.goalsHUDCheck = goalsHUDCheck

	goalsHUDCheck:SetScript("OnClick", function(cb)
		if GSF.GoalsHUD then
			GSF.GoalsHUD:Toggle()
		end
	end)

	-- Roster Table Header
	local headerBar = CreateFrame("Frame", nil, frame)
	headerBar:SetSize(700, 20)
	headerBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -135)
	if BackdropTemplateMixin then Mixin(headerBar, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(headerBar, false)
	headerBar:SetBackdropColor(0.15, 0.15, 0.20, 0.9)

	local h1 = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	h1:SetPoint("LEFT", headerBar, "LEFT", 10, 0)
	h1:SetText(GSF.L["TABLE_CHARACTER"])
	self.h1 = h1

	local h2 = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	h2:SetPoint("LEFT", headerBar, "LEFT", 140, 0)
	h2:SetText(GSF.L["TABLE_MAIN"])
	self.h2 = h2

	local h3 = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	h3:SetPoint("LEFT", headerBar, "LEFT", 260, 0)
	h3:SetText(GSF.L["TABLE_PROFESSIONS"])
	self.h3 = h3

	local h4 = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	h4:SetPoint("RIGHT", headerBar, "RIGHT", -15, 0)
	h4:SetText(GSF.L["TABLE_LAST_SEEN"])
	self.h4 = h4

	-- Roster Table Scroll
	local scrollFrame, content = GSF.UI:CreateScrollList(frame, 700, 250)
	scrollFrame:SetPoint("TOPLEFT", headerBar, "BOTTOMLEFT", 0, -4)
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 15)
	self.content = content
	self.memberRows = {}

	return frame
end

function Tab:UpdateTexts()
	if not self.frame then return end
	self.mainLabel:SetText(GSF.L["MAIN_ALT_TITLE"])
	self.mainPrompt:SetText(GSF.L["SET_MAIN_CHARACTER"])
	self.saveMainBtn:SetText(GSF.L["SAVE_MAIN"])
	self.syncBtn:SetText(GSF.L["FORCE_SYNC"])
	self.bugBtn:SetText(GSF.L["REPORT_BUG_BTN"])
	self.langLabel:SetText(GSF.L["LANGUAGE_LABEL"])
	self.toastCheck.text:SetText(GSF.L["ENABLE_TOASTS"])
	self.soundCheck.text:SetText(GSF.L["ENABLE_SOUNDS"])
	self.dropAnnounceCheck.text:SetText(GSF.L["ANNOUNCE_DROPS_PARTY"])
	if self.goalsHUDCheck then self.goalsHUDCheck.text:SetText(GSF.L["ENABLE_GOALS_HUD"] or "Show Goals HUD") end
	self.h1:SetText(GSF.L["TABLE_CHARACTER"])
	self.h2:SetText(GSF.L["TABLE_MAIN"])
	self.h3:SetText(GSF.L["TABLE_PROFESSIONS"])
	self.h4:SetText(GSF.L["TABLE_LAST_SEEN"])
	self:Refresh()
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

	if not IsInGuild() then
		self.statText:SetText(string.format("|cff888888%s|r", GSF.L["SOLO_MODE"] or "Offline Mode (No Guild)"))
	else
		self.statText:SetText(string.format(GSF.L["TOTAL_MEMBERS_CACHED"], numMembers, numRecipes))
	end

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

		local roleBadges = GSF.Roles and GSF.Roles:GetRoleBadgesString(member.name) or ""
		local nameStr = roleBadges ~= "" and string.format("%s %s %s", statusDot, member.name or "Unknown", roleBadges) or string.format("%s %s", statusDot, member.name or "Unknown")
		row.name:SetText(nameStr)
		row.main:SetText(member.main or member.name or "")

		local profList = {}
		if member.professions then
			for pName, pData in pairs(member.professions) do
				local locName = GSF:GetLocalizedProfession(pName)
				table.insert(profList, string.format("%s (%d)", locName, pData.curRank or 0))
			end
		end
		row.profs:SetText(#profList > 0 and table.concat(profList, ", ") or (GSF.L["NONE"] or "None"))

		local mins = math.floor((time() - (member.lastSeen or time())) / 60)
		if isOnline then
			row.lastSeen:SetText("|cff00ff00Online|r")
		elseif mins < 60 then
			row.lastSeen:SetText(string.format(GSF.L["MINS_AGO"], mins))
		elseif mins < 1440 then
			row.lastSeen:SetText(math.floor(mins / 60) .. "h")
		else
			row.lastSeen:SetText(math.floor(mins / 1440) .. "d")
		end

		row:Show()
		yOffset = yOffset + 26
	end

	self.content:SetHeight(math.max(yOffset, 250))
end
