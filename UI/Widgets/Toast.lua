local ADDON_NAME, GSF = ...

GSF.Toast = {}

local toastFrame = nil

function GSF.Toast:Initialize()
	if toastFrame then return end

	local f = CreateFrame("Frame", "GSFHubToastFrame", UIParent)
	if BackdropTemplateMixin then Mixin(f, BackdropTemplateMixin) end
	f:SetSize(320, 50)
	f:SetPoint("TOP", UIParent, "TOP", 0, -120)
	f:SetFrameStrata("DIALOG")
	f:Hide()

	GSF.UI:CreateBackdrop(f, false)
	f:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
	f:SetBackdropBorderColor(0.2, 0.8, 0.4, 0.9)

	local icon = f:CreateTexture(nil, "ARTWORK")
	icon:SetSize(32, 32)
	icon:SetPoint("LEFT", f, "LEFT", 10, 0)
	icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
	f.icon = icon

	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, 2)
	title:SetText("|cff33ff99GSF Notification|r")
	f.title = title

	local msg = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	msg:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 10, 0)
	msg:SetPoint("RIGHT", f, "RIGHT", -10, 0)
	msg:SetJustifyH("LEFT")
	msg:SetWordWrap(true)
	f.msg = msg

	f:SetScript("OnMouseDown", function()
		f:Hide()
		if GSF.MainFrame then GSF.MainFrame:Show() end
	end)

	toastFrame = f
end

function GSF.Toast:ShowToast(text, iconTexture)
	if not toastFrame then self:Initialize() end
	if not GSF.db or not GSF.db.enableToasts then return end

	toastFrame.msg:SetText(text or "")
	if iconTexture then
		toastFrame.icon:SetTexture(iconTexture)
	else
		toastFrame.icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
	end

	if GSF.db.enableSounds then
		PlaySound(SOUNDKIT.TELL_MESSAGE or 8959)
	end

	toastFrame:Show()
	toastFrame:SetAlpha(1)

	C_Timer.After(4.5, function()
		if toastFrame:IsShown() then
			toastFrame:Hide()
		end
	end)
end
