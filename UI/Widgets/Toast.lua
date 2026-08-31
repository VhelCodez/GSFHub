local ADDON_NAME, GSF = ...

GSF.Toast = {}

local activeToasts = {}
local toastQueue = {}
local toastPool = {}
local MAX_ACTIVE_TOASTS = 3
local TOAST_DURATION = 4.5
local lastSoundTime = 0

local function CreateToastFrame()
	local f = CreateFrame("Frame", nil, UIParent)
	if BackdropTemplateMixin then Mixin(f, BackdropTemplateMixin) end
	f:SetSize(320, 48)
	f:SetFrameStrata("DIALOG")
	f:Hide()

	GSF.UI:CreateBackdrop(f, false)
	f:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
	f:SetBackdropBorderColor(0.2, 0.8, 0.4, 0.9)

	local icon = f:CreateTexture(nil, "ARTWORK")
	icon:SetSize(32, 32)
	icon:SetPoint("LEFT", f, "LEFT", 8, 0)
	icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
	f.icon = icon

	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, -2)
	title:SetText("|cff33ff99GSF Notification|r")
	f.title = title

	local msg = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	msg:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
	msg:SetPoint("RIGHT", f, "RIGHT", -10, 0)
	msg:SetJustifyH("LEFT")
	msg:SetWordWrap(false)
	f.msg = msg

	f:SetScript("OnMouseDown", function()
		GSF.Toast:DismissToast(f)
		if GSF.MainFrame and not GSF.MainFrame:IsShown() then
			GSF.UI:ToggleMainFrame()
		end
	end)

	return f
end

local function GetToastFrame()
	if #toastPool > 0 then
		return table.remove(toastPool)
	end
	return CreateToastFrame()
end

local function RepositionToasts()
	local baseTop = -120
	local spacing = 54
	for index, toast in ipairs(activeToasts) do
		toast:ClearAllPoints()
		toast:SetPoint("TOP", UIParent, "TOP", 0, baseTop - (index - 1) * spacing)
	end
end

function GSF.Toast:DismissToast(toast)
	for i, t in ipairs(activeToasts) do
		if t == toast then
			table.remove(activeToasts, i)
			break
		end
	end
	toast:Hide()
	table.insert(toastPool, toast)
	RepositionToasts()

	-- If items are waiting in the queue, pop the next one
	if #toastQueue > 0 and #activeToasts < MAX_ACTIVE_TOASTS then
		local nextItem = table.remove(toastQueue, 1)
		self:DisplayToast(nextItem.text, nextItem.iconTexture, nextItem.titleText)
	end
end

function GSF.Toast:DisplayToast(text, iconTexture, titleText)
	local toast = GetToastFrame()
	toast.title:SetText(titleText or "|cff33ff99GSF Notification|r")
	toast.msg:SetText(text or "")
	toast.icon:SetTexture(iconTexture or "Interface\\Icons\\INV_Misc_Book_09")
	toast:SetAlpha(1)
	toast:Show()

	table.insert(activeToasts, toast)
	RepositionToasts()

	C_Timer.After(TOAST_DURATION, function()
		if toast and toast:IsShown() then
			GSF.Toast:DismissToast(toast)
		end
	end)
end

function GSF.Toast:ShowToast(text, iconTexture, titleText)
	if not GSF.db then return end

	-- Play audio alert (throttled to once per 0.4s during batch operations)
	if GSF.db.enableSounds then
		local now = GetTime()
		if now - lastSoundTime > 0.4 then
			lastSoundTime = now
			PlaySound(SOUNDKIT.TELL_MESSAGE or 8959)
		end
	end

	if not GSF.db.enableToasts then return end

	if #activeToasts < MAX_ACTIVE_TOASTS then
		self:DisplayToast(text, iconTexture, titleText)
	else
		-- Queue if maximum active toasts are already shown
		table.insert(toastQueue, { text = text, iconTexture = iconTexture, titleText = titleText })
	end
end
