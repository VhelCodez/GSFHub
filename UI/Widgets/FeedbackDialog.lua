local ADDON_NAME, GSF = ...

GSF.FeedbackDialog = {}

local feedbackFrame = nil
local lastCapturedError = nil

function GSF.FeedbackDialog:SetLastError(err)
	lastCapturedError = err
end

function GSF.FeedbackDialog:GenerateDiagnosticReport(customError)
	local myName = GSF.DB:GetPlayerName()
	local myClass = GSF.DB:GetPlayerClass()
	local myLevel = UnitLevel("player")
	local myRealm = GetRealmName()
	local myGuild = GSF.DB:GetGuildName() or "None"
	local clientLocale = GetLocale()
	local addonLocale = GSF:GetSelectedLanguage()

	-- Get player professions
	local profLines = {}
	local myMember = GSF.cache and GSF.cache.members and GSF.cache.members[myName]
	if myMember and myMember.professions then
		for pName, pData in pairs(myMember.professions) do
			table.insert(profLines, string.format("%s (%d/%d)", pName, pData.curRank or 0, pData.maxRank or 375))
		end
	end
	local profsStr = #profLines > 0 and table.concat(profLines, ", ") or "None"

	-- Get cache stats
	local numMembers = 0
	local numRecipes = 0
	if GSF.cache and GSF.cache.members then
		for _, m in pairs(GSF.cache.members) do
			numMembers = numMembers + 1
			if m.professions then
				for _, p in pairs(m.professions) do
					if p.recipes then
						for _ in pairs(p.recipes) do
							numRecipes = numRecipes + 1
						end
					end
				end
			end
		end
	end

	local errText = customError or lastCapturedError or "None reported"

	local report = string.format(
		"### GSFHub Diagnostic Data\n" ..
		"- **Addon Version:** v%s\n" ..
		"- **Client Locale:** %s (Addon Language: %s)\n" ..
		"- **Character:** Level %d %s (Realm: %s, Guild: %s)\n" ..
		"- **Professions:** %s\n" ..
		"- **Cached Guild Stats:** %d Members, %d Indexed Recipes\n" ..
		"- **Recent Error Details:** %s",
		GSF.VERSION,
		clientLocale,
		addonLocale,
		myLevel,
		myClass,
		myRealm,
		myGuild,
		profsStr,
		numMembers,
		numRecipes,
		errText
	)

	return report
end

function GSF.FeedbackDialog:Initialize()
	if feedbackFrame then return end

	local f = CreateFrame("Frame", "GSFFeedbackDialogFrame", UIParent)
	if BackdropTemplateMixin then Mixin(f, BackdropTemplateMixin) end
	f:SetSize(520, 360)
	f:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
	f:SetFrameStrata("DIALOG")
	GSF.UI:CreateBackdrop(f, false)
	f:SetBackdropColor(0.06, 0.06, 0.08, 0.98)
	f:Hide()

	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", f, "TOP", 0, -16)
	title:SetText(GSF.L["FEEDBACK_MODAL_TITLE"])
	f.title = title

	local msg = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	msg:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -45)
	msg:SetPoint("RIGHT", f, "RIGHT", -20, 0)
	msg:SetJustifyH("LEFT")
	msg:SetText(GSF.L["FEEDBACK_MODAL_MSG"])
	f.msg = msg

	-- Scrollable text area for diagnostics
	local scrollFrame, content = GSF.UI:CreateScrollList(f, 475, 170)
	scrollFrame:SetPoint("TOPLEFT", msg, "BOTTOMLEFT", 0, -10)

	local editBox = CreateFrame("EditBox", nil, content)
	editBox:SetSize(450, 160)
	editBox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
	editBox:SetMultiLine(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject("GameFontHighlightSmall")
	editBox:SetScript("OnEscapePressed", function(eb) f:Hide() end)
	f.diagEditBox = editBox

	-- Link Section
	local linkLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	linkLabel:SetPoint("TOPLEFT", scrollFrame, "BOTTOMLEFT", 0, -12)
	linkLabel:SetText(GSF.L["FEEDBACK_LINK_LABEL"])
	f.linkLabel = linkLabel

	local linkEditBox = GSF.UI:CreateEditBox(f, 475, 22)
	linkEditBox:SetPoint("TOPLEFT", linkLabel, "BOTTOMLEFT", 0, -4)
	linkEditBox:SetText(GSF.ISSUES_URL)
	linkEditBox:SetScript("OnEscapePressed", function(eb) f:Hide() end)
	f.linkEditBox = linkEditBox

	local closeBtn = GSF.UI:CreateButton(f, GSF.L["CLOSE"], 100, 24)
	closeBtn:SetPoint("BOTTOM", f, "BOTTOM", 0, 12)
	closeBtn:SetScript("OnClick", function() f:Hide() end)

	feedbackFrame = f
end

function GSF.FeedbackDialog:Show(customError)
	if not feedbackFrame then self:Initialize() end

	feedbackFrame.title:SetText(GSF.L["FEEDBACK_MODAL_TITLE"])
	feedbackFrame.msg:SetText(GSF.L["FEEDBACK_MODAL_MSG"])
	feedbackFrame.linkLabel:SetText(GSF.L["FEEDBACK_LINK_LABEL"])

	local report = self:GenerateDiagnosticReport(customError)
	feedbackFrame.diagEditBox:SetText(report)
	feedbackFrame.linkEditBox:SetText(GSF.ISSUES_URL)

	feedbackFrame:Show()
	feedbackFrame.diagEditBox:HighlightText()
	feedbackFrame.diagEditBox:SetFocus()
end
