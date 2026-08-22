local ADDON_NAME, GSF = ...

GSF.Locales = {
	enUS = {},
	deDE = {},
}

-- Current active locale dictionary
local activeLocaleTable = GSF.Locales.enUS

-- Metatable proxy: looks up in active locale, falls back to enUS, then raw key
local L_mt = {
	__index = function(t, k)
		if activeLocaleTable and activeLocaleTable[k] ~= nil and activeLocaleTable[k] ~= "" then
			return activeLocaleTable[k]
		elseif GSF.Locales.enUS and GSF.Locales.enUS[k] ~= nil and GSF.Locales.enUS[k] ~= "" then
			return GSF.Locales.enUS[k]
		end
		return k
	end
}

local L = setmetatable({}, L_mt)
GSF.L = L

function GSF:GetSelectedLanguage()
	local selected = GSF.db and GSF.db.selectedLocale or "auto"
	if selected == "auto" then
		local clientLocale = GetLocale()
		if clientLocale == "deDE" then
			return "deDE"
		else
			return "enUS"
		end
	end
	return selected
end

function GSF:UpdateActiveLanguage()
	local lang = self:GetSelectedLanguage()
	if GSF.Locales[lang] then
		activeLocaleTable = GSF.Locales[lang]
	else
		activeLocaleTable = GSF.Locales.enUS
	end
end

function GSF:SetLanguage(localeCode)
	if not localeCode then return end
	if GSF.db then
		GSF.db.selectedLocale = localeCode
	end

	self:UpdateActiveLanguage()

	-- Trigger instant UI refresh if MainFrame exists
	if GSF.MainFrame then
		if GSF.MainFrame.UpdateLocalizedTexts then
			GSF.MainFrame:UpdateLocalizedTexts()
		end
		if GSF.MainFrame:IsShown() then
			GSF.MainFrame:RefreshCurrentTab()
		end
	end
end
