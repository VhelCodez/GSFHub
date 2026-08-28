local ADDON_NAME, GSF = ...

GSF.URLDialog = {}

local dialogFrame = nil

function GSF.URLDialog:Initialize()
	if dialogFrame then return end

	local f = CreateFrame("Frame", "GSFURLDialogFrame", UIParent)
	if BackdropTemplateMixin then Mixin(f, BackdropTemplateMixin) end
	f:SetSize(440, 160)
	f:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
	f:SetFrameStrata("DIALOG")
	GSF.UI:CreateBackdrop(f, false)
	f:SetBackdropColor(0.06, 0.06, 0.08, 0.98)
	f:Hide()

	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", f, "TOP", 0, -16)
	title:SetText("|cff33ff99Link|r")
	f.title = title

	local msg = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	msg:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -45)
	msg:SetPoint("RIGHT", f, "RIGHT", -20, 0)
	msg:SetJustifyH("CENTER")
	f.msg = msg

	local editBox = GSF.UI:CreateEditBox(f, 380, 24)
	editBox:SetPoint("TOP", msg, "BOTTOM", 0, -12)
	editBox:SetScript("OnEscapePressed", function(eb) f:Hide() end)
	f.editBox = editBox

	local closeBtn = GSF.UI:CreateButton(f, GSF.L["CLOSE"], 90, 22)
	closeBtn:SetPoint("BOTTOM", f, "BOTTOM", 0, 14)
	closeBtn:SetScript("OnClick", function() f:Hide() end)

	dialogFrame = f
end

function GSF.URLDialog:ShowDialog(titleText, msgText, urlText)
	if not dialogFrame then self:Initialize() end

	dialogFrame.title:SetText(titleText or "|cff33ff99Link|r")
	dialogFrame.msg:SetText(msgText or "Press Ctrl+C to copy the link below:")
	dialogFrame.editBox:SetText(urlText or "")
	dialogFrame:Show()
	dialogFrame.editBox:HighlightText()
	dialogFrame.editBox:SetFocus()
end

GSF.URLDialog.Open = GSF.URLDialog.ShowDialog
