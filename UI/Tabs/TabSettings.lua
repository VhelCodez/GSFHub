local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabSettings = Tab

-- Register confirmation dialogs
StaticPopupDialogs["GSFHUB_CONFIRM_CHAR_RESET"] = {
	text = GSF.L["CONFIRM_CHAR_RESET"] or "Are you sure you want to clear all wishlisted recipes and personal goals for this character?",
	button1 = GSF.L["YES"] or "Yes",
	button2 = GSF.L["CANCEL"] or "Cancel",
	OnAccept = function()
		if GSF.DB then
			GSF.DB:ResetActiveCharacterData()
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["GSFHUB_CONFIRM_FACTORY_RESET"] = {
	text = GSF.L["CONFIRM_FACTORY_RESET"] or "Are you sure you want to reset all GSFHub settings, cache, and local listings? This will cancel your open orders and reload your UI.",
	button1 = GSF.L["YES"] or "Yes",
	button2 = GSF.L["CANCEL"] or "Cancel",
	OnAccept = function()
		if GSF.DB then
			GSF.DB:FactoryReset()
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

function Tab:Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	self.frame = frame

	---------------------------------------------------------------------------
	-- Section 1: General & Display (Top Left)
	---------------------------------------------------------------------------
	local genCard = CreateFrame("Frame", nil, frame)
	genCard:SetSize(345, 195)
	genCard:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -12)
	if BackdropTemplateMixin then Mixin(genCard, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(genCard, false)
	genCard:SetBackdropColor(0.08, 0.08, 0.12, 0.75)
	self.genCard = genCard

	local genTitle = genCard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	genTitle:SetPoint("TOPLEFT", genCard, "TOPLEFT", 12, -10)
	genTitle:SetText(GSF.L["SETTINGS_GENERAL_DISPLAY"] or "General & Display")
	self.genTitle = genTitle

	local langLabel = genCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	langLabel:SetPoint("TOPLEFT", genTitle, "BOTTOMLEFT", 0, -8)
	langLabel:SetText(GSF.L["LANGUAGE_LABEL"] or "Language:")
	self.langLabel = langLabel

	local langDropdown = CreateFrame("Button", "GSFSettingsLangDropdown", genCard, "UIDropDownMenuTemplate")
	langDropdown:SetPoint("TOPLEFT", langLabel, "BOTTOMLEFT", -15, -6)
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

	local minimapCheck = CreateFrame("CheckButton", nil, genCard, "UICheckButtonTemplate")
	minimapCheck:SetPoint("TOPLEFT", langDropdown, "BOTTOMLEFT", 12, -2)
	minimapCheck.text:SetText(GSF.L["SHOW_MINIMAP_ICON"] or "Show Minimap Icon")
	minimapCheck.text:SetFontObject("GameFontHighlightSmall")
	minimapCheck.text:SetPoint("LEFT", minimapCheck, "RIGHT", 2, 1)
	local isMinimapHidden = GSF.db and GSF.db.minimap and GSF.db.minimap.hide
	minimapCheck:SetChecked(not isMinimapHidden)
	self.minimapCheck = minimapCheck

	minimapCheck:SetScript("OnClick", function(cb)
		local show = cb:GetChecked()
		if GSF.db and GSF.db.minimap then
			GSF.db.minimap.hide = not show
		end
		local DBIcon = LibStub("LibDBIcon-1.0", true)
		if DBIcon then
			if show then
				DBIcon:Show("GSFHub")
			else
				DBIcon:Hide("GSFHub")
			end
		end
	end)

	local goalsHUDCheck = CreateFrame("CheckButton", nil, genCard, "UICheckButtonTemplate")
	goalsHUDCheck:SetPoint("TOPLEFT", minimapCheck, "BOTTOMLEFT", 0, -2)
	goalsHUDCheck.text:SetText(GSF.L["ENABLE_GOALS_HUD"] or "Show Personal Goals HUD")
	goalsHUDCheck.text:SetFontObject("GameFontHighlightSmall")
	goalsHUDCheck.text:SetPoint("LEFT", goalsHUDCheck, "RIGHT", 2, 1)
	goalsHUDCheck:SetChecked(GSF.GoalsHUD and GSF.GoalsHUD:IsShown() or false)
	self.goalsHUDCheck = goalsHUDCheck

	goalsHUDCheck:SetScript("OnClick", function(cb)
		if GSF.GoalsHUD then
			GSF.GoalsHUD:SetShown(cb:GetChecked())
		end
	end)

	local resetPosBtn = GSF.UI:CreateButton(genCard, GSF.L["RESET_HUD_POS"] or "Reset HUD Position", 160, 22)
	resetPosBtn:SetPoint("TOPLEFT", goalsHUDCheck, "BOTTOMLEFT", 4, -4)
	self.resetPosBtn = resetPosBtn

	resetPosBtn:SetScript("OnClick", function()
		if GSF.GoalsHUD then
			GSF.GoalsHUD:ResetPosition()
			if GSF.Addon then
				GSF.Addon:Printf("|cff33ff99%s|r", GSF.L["RESET_HUD_POS"] .. ": OK")
			end
		end
	end)

	---------------------------------------------------------------------------
	-- Section 2: Data & Cache Management (Bottom Left)
	---------------------------------------------------------------------------
	local cacheCard = CreateFrame("Frame", nil, frame)
	cacheCard:SetSize(345, 175)
	cacheCard:SetPoint("TOPLEFT", genCard, "BOTTOMLEFT", 0, -10)
	if BackdropTemplateMixin then Mixin(cacheCard, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(cacheCard, false)
	cacheCard:SetBackdropColor(0.08, 0.08, 0.12, 0.75)
	self.cacheCard = cacheCard

	local cacheTitle = cacheCard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	cacheTitle:SetPoint("TOPLEFT", cacheCard, "TOPLEFT", 12, -10)
	cacheTitle:SetText(GSF.L["SETTINGS_DATA_MANAGEMENT"] or "Data & Cache Management")
	self.cacheTitle = cacheTitle

	local rebuildBtn = GSF.UI:CreateButton(cacheCard, GSF.L["REBUILD_CACHE_BTN"] or "Rebuild Guild Cache", 210, 24)
	rebuildBtn:SetPoint("TOPLEFT", cacheTitle, "BOTTOMLEFT", 0, -12)
	self.rebuildBtn = rebuildBtn

	rebuildBtn:SetScript("OnEnter", function(btn)
		GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
		GameTooltip:SetText(GSF.L["REBUILD_CACHE_BTN"] or "Rebuild Guild Cache", 1, 0.82, 0)
		GameTooltip:AddLine(GSF.L["REBUILD_CACHE_DESC"] or "Clears peer cache and requests a fresh sync from online guild members. Preserves your own listings.", 1, 1, 1, true)
		GameTooltip:Show()
	end)
	rebuildBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

	rebuildBtn:SetScript("OnClick", function()
		if GSF.DB then
			GSF.DB:RebuildGuildCache()
		end
	end)

	local resetCharBtn = GSF.UI:CreateButton(cacheCard, GSF.L["RESET_CHAR_DATA_BTN"] or "Clear Character Data", 210, 24)
	resetCharBtn:SetPoint("TOPLEFT", rebuildBtn, "BOTTOMLEFT", 0, -10)
	self.resetCharBtn = resetCharBtn

	resetCharBtn:SetScript("OnClick", function()
		StaticPopup_Show("GSFHUB_CONFIRM_CHAR_RESET")
	end)

	local factoryResetBtn = GSF.UI:CreateButton(cacheCard, GSF.L["FACTORY_RESET_BTN"] or "Full Addon Reset", 210, 24)
	factoryResetBtn:SetPoint("TOPLEFT", resetCharBtn, "BOTTOMLEFT", 0, -10)
	self.factoryResetBtn = factoryResetBtn

	factoryResetBtn:SetScript("OnClick", function()
		StaticPopup_Show("GSFHUB_CONFIRM_FACTORY_RESET")
	end)

	---------------------------------------------------------------------------
	-- Section 3: Notifications & Audio (Top Right)
	---------------------------------------------------------------------------
	local notifCard = CreateFrame("Frame", nil, frame)
	notifCard:SetSize(355, 195)
	notifCard:SetPoint("TOPLEFT", frame, "TOPLEFT", 375, -12)
	if BackdropTemplateMixin then Mixin(notifCard, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(notifCard, false)
	notifCard:SetBackdropColor(0.08, 0.08, 0.12, 0.75)
	self.notifCard = notifCard

	local notifTitle = notifCard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	notifTitle:SetPoint("TOPLEFT", notifCard, "TOPLEFT", 12, -10)
	notifTitle:SetText(GSF.L["SETTINGS_NOTIFICATIONS"] or "Notifications & Audio")
	self.notifTitle = notifTitle

	local toastCheck = CreateFrame("CheckButton", nil, notifCard, "UICheckButtonTemplate")
	toastCheck:SetPoint("TOPLEFT", notifTitle, "BOTTOMLEFT", 0, -8)
	toastCheck.text:SetText(GSF.L["ENABLE_TOASTS"])
	toastCheck.text:SetFontObject("GameFontHighlightSmall")
	toastCheck.text:SetPoint("LEFT", toastCheck, "RIGHT", 2, 1)
	toastCheck:SetChecked(GSF.db and GSF.db.enableToasts)
	self.toastCheck = toastCheck

	toastCheck:SetScript("OnClick", function(cb)
		if GSF.db then GSF.db.enableToasts = cb:GetChecked() end
	end)

	local soundCheck = CreateFrame("CheckButton", nil, notifCard, "UICheckButtonTemplate")
	soundCheck:SetPoint("TOPLEFT", toastCheck, "BOTTOMLEFT", 0, -4)
	soundCheck.text:SetText(GSF.L["ENABLE_SOUNDS"])
	soundCheck.text:SetFontObject("GameFontHighlightSmall")
	soundCheck.text:SetPoint("LEFT", soundCheck, "RIGHT", 2, 1)
	soundCheck:SetChecked(GSF.db and GSF.db.enableSounds)
	self.soundCheck = soundCheck

	soundCheck:SetScript("OnClick", function(cb)
		if GSF.db then GSF.db.enableSounds = cb:GetChecked() end
	end)

	local dropAnnounceCheck = CreateFrame("CheckButton", nil, notifCard, "UICheckButtonTemplate")
	dropAnnounceCheck:SetPoint("TOPLEFT", soundCheck, "BOTTOMLEFT", 0, -4)
	dropAnnounceCheck.text:SetText(GSF.L["ANNOUNCE_DROPS_PARTY"])
	dropAnnounceCheck.text:SetFontObject("GameFontHighlightSmall")
	dropAnnounceCheck.text:SetPoint("LEFT", dropAnnounceCheck, "RIGHT", 2, 1)
	dropAnnounceCheck:SetChecked(GSF.db and GSF.db.announceDropsToParty)
	self.dropAnnounceCheck = dropAnnounceCheck

	dropAnnounceCheck:SetScript("OnClick", function(cb)
		if GSF.db then GSF.db.announceDropsToParty = cb:GetChecked() end
	end)

	local autoScanCheck = CreateFrame("CheckButton", nil, notifCard, "UICheckButtonTemplate")
	autoScanCheck:SetPoint("TOPLEFT", dropAnnounceCheck, "BOTTOMLEFT", 0, -4)
	autoScanCheck.text:SetText(GSF.L["AUTO_SCAN_OPEN"] or "Auto-Scan Profession on Open")
	autoScanCheck.text:SetFontObject("GameFontHighlightSmall")
	autoScanCheck.text:SetPoint("LEFT", autoScanCheck, "RIGHT", 2, 1)
	autoScanCheck:SetChecked(GSF.db and GSF.db.autoScanOnOpen)
	self.autoScanCheck = autoScanCheck

	autoScanCheck:SetScript("OnClick", function(cb)
		if GSF.db then GSF.db.autoScanOnOpen = cb:GetChecked() end
	end)

	---------------------------------------------------------------------------
	-- Section 4: About & Diagnostics (Bottom Right)
	---------------------------------------------------------------------------
	local aboutCard = CreateFrame("Frame", nil, frame)
	aboutCard:SetSize(355, 175)
	aboutCard:SetPoint("TOPLEFT", notifCard, "BOTTOMLEFT", 0, -10)
	if BackdropTemplateMixin then Mixin(aboutCard, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(aboutCard, false)
	aboutCard:SetBackdropColor(0.08, 0.08, 0.12, 0.75)
	self.aboutCard = aboutCard

	local aboutTitle = aboutCard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	aboutTitle:SetPoint("TOPLEFT", aboutCard, "TOPLEFT", 12, -10)
	aboutTitle:SetText(GSF.L["SETTINGS_ABOUT"] or "About & Diagnostics")
	self.aboutTitle = aboutTitle

	local verText = aboutCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	verText:SetPoint("TOPLEFT", aboutTitle, "BOTTOMLEFT", 0, -10)
	verText:SetText(string.format(GSF.L["CURRENT_VERSION"] or "Current Version: |cff33ff99v%s|r", GSF.VERSION))
	self.verText = verText

	local updateBtn = GSF.UI:CreateButton(aboutCard, GSF.L["CHECK_UPDATES"] or "Check for Updates", 180, 22)
	updateBtn:SetPoint("TOPLEFT", verText, "BOTTOMLEFT", 0, -10)
	self.updateBtn = updateBtn

	updateBtn:SetScript("OnClick", function()
		if GSF.VersionCheck then
			GSF.VersionCheck:OpenUpdateDialog()
		end
	end)

	local bugBtn = GSF.UI:CreateButton(aboutCard, GSF.L["REPORT_BUG_BTN"], 180, 22)
	bugBtn:SetPoint("TOPLEFT", updateBtn, "BOTTOMLEFT", 0, -8)
	self.bugBtn = bugBtn

	bugBtn:SetScript("OnClick", function()
		if GSF.FeedbackDialog then
			GSF.FeedbackDialog:Show()
		end
	end)

	local issuesBtn = GSF.UI:CreateButton(aboutCard, "GitHub Issues", 180, 22)
	issuesBtn:SetPoint("TOPLEFT", bugBtn, "BOTTOMLEFT", 0, -8)
	self.issuesBtn = issuesBtn

	issuesBtn:SetScript("OnClick", function()
		if GSF.URLDialog then
			GSF.URLDialog:ShowDialog("GitHub Issues", GSF.L["FEEDBACK_LINK_LABEL"] or "GitHub Issues Link:", GSF.ISSUES_URL or "https://github.com/VhelCodez/GSFHub/issues/new/choose")
		end
	end)

	return frame
end

function Tab:UpdateTexts()
	if not self.frame then return end

	local function GetLangText(code)
		if code == "deDE" then return GSF.L["LANG_DE"]
		elseif code == "enUS" then return GSF.L["LANG_EN"]
		else return GSF.L["LANG_AUTO"] end
	end

	if self.genTitle then self.genTitle:SetText(GSF.L["SETTINGS_GENERAL_DISPLAY"] or "General & Display") end
	if self.langLabel then self.langLabel:SetText(GSF.L["LANGUAGE_LABEL"] or "Language:") end
	if self.langDropdown then
		local cur = GSF.db and GSF.db.selectedLocale or "auto"
		UIDropDownMenu_SetText(self.langDropdown, GetLangText(cur))
	end
	if self.minimapCheck then self.minimapCheck.text:SetText(GSF.L["SHOW_MINIMAP_ICON"] or "Show Minimap Icon") end
	if self.goalsHUDCheck then self.goalsHUDCheck.text:SetText(GSF.L["ENABLE_GOALS_HUD"] or "Show Personal Goals HUD") end
	if self.resetPosBtn then self.resetPosBtn:SetText(GSF.L["RESET_HUD_POS"] or "Reset HUD Position") end

	if self.cacheTitle then self.cacheTitle:SetText(GSF.L["SETTINGS_DATA_MANAGEMENT"] or "Data & Cache Management") end
	if self.rebuildBtn then self.rebuildBtn:SetText(GSF.L["REBUILD_CACHE_BTN"] or "Rebuild Guild Cache") end
	if self.resetCharBtn then self.resetCharBtn:SetText(GSF.L["RESET_CHAR_DATA_BTN"] or "Clear Character Data") end
	if self.factoryResetBtn then self.factoryResetBtn:SetText(GSF.L["FACTORY_RESET_BTN"] or "Full Addon Reset") end

	if StaticPopupDialogs["GSFHUB_CONFIRM_CHAR_RESET"] then
		StaticPopupDialogs["GSFHUB_CONFIRM_CHAR_RESET"].text = GSF.L["CONFIRM_CHAR_RESET"] or "Are you sure you want to clear all wishlisted recipes and personal goals for this character?"
		StaticPopupDialogs["GSFHUB_CONFIRM_CHAR_RESET"].button1 = GSF.L["YES"] or "Yes"
		StaticPopupDialogs["GSFHUB_CONFIRM_CHAR_RESET"].button2 = GSF.L["CANCEL"] or "Cancel"
	end
	if StaticPopupDialogs["GSFHUB_CONFIRM_FACTORY_RESET"] then
		StaticPopupDialogs["GSFHUB_CONFIRM_FACTORY_RESET"].text = GSF.L["CONFIRM_FACTORY_RESET"] or "Are you sure you want to reset all GSFHub settings, cache, and local listings? This will cancel your open orders and reload your UI."
		StaticPopupDialogs["GSFHUB_CONFIRM_FACTORY_RESET"].button1 = GSF.L["YES"] or "Yes"
		StaticPopupDialogs["GSFHUB_CONFIRM_FACTORY_RESET"].button2 = GSF.L["CANCEL"] or "Cancel"
	end

	if self.notifTitle then self.notifTitle:SetText(GSF.L["SETTINGS_NOTIFICATIONS"] or "Notifications & Audio") end
	if self.toastCheck then self.toastCheck.text:SetText(GSF.L["ENABLE_TOASTS"]) end
	if self.soundCheck then self.soundCheck.text:SetText(GSF.L["ENABLE_SOUNDS"]) end
	if self.dropAnnounceCheck then self.dropAnnounceCheck.text:SetText(GSF.L["ANNOUNCE_DROPS_PARTY"]) end
	if self.autoScanCheck then self.autoScanCheck.text:SetText(GSF.L["AUTO_SCAN_OPEN"] or "Auto-Scan Profession on Open") end

	if self.aboutTitle then self.aboutTitle:SetText(GSF.L["SETTINGS_ABOUT"] or "About & Diagnostics") end
	if self.verText then self.verText:SetText(string.format(GSF.L["CURRENT_VERSION"] or "Current Version: |cff33ff99v%s|r", GSF.VERSION)) end
	if self.updateBtn then self.updateBtn:SetText(GSF.L["CHECK_UPDATES"] or "Check for Updates") end
	if self.bugBtn then self.bugBtn:SetText(GSF.L["REPORT_BUG_BTN"]) end

	self:Refresh()
end

function Tab:Refresh()
	if not self.frame or not self.frame:IsShown() then return end

	if self.goalsHUDCheck then
		self.goalsHUDCheck:SetChecked(GSF.GoalsHUD and GSF.GoalsHUD:IsShown() or false)
	end

	if self.minimapCheck then
		local isHidden = GSF.db and GSF.db.minimap and GSF.db.minimap.hide
		self.minimapCheck:SetChecked(not isHidden)
	end

	if self.toastCheck then
		self.toastCheck:SetChecked(GSF.db and GSF.db.enableToasts)
	end

	if self.soundCheck then
		self.soundCheck:SetChecked(GSF.db and GSF.db.enableSounds)
	end

	if self.dropAnnounceCheck then
		self.dropAnnounceCheck:SetChecked(GSF.db and GSF.db.announceDropsToParty)
	end

	if self.autoScanCheck then
		self.autoScanCheck:SetChecked(GSF.db and GSF.db.autoScanOnOpen)
	end
end
