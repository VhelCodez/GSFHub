local ADDON_NAME, GSF = ...

local AceEvent = LibStub("AceEvent-3.0")
GSF.TradeSkillHook = {}
AceEvent:Embed(GSF.TradeSkillHook)

function GSF.TradeSkillHook:Initialize()
	self:RegisterEvent("ADDON_LOADED", "OnAddonLoaded")
	if TradeSkillFrame then self:HookTradeSkill() end
	if CraftFrame then self:HookCraft() end
end

function GSF.TradeSkillHook:OnAddonLoaded(event, addon)
	if addon == "Blizzard_TradeSkillUI" then
		self:HookTradeSkill()
	elseif addon == "Blizzard_CraftUI" then
		self:HookCraft()
	end
end

function GSF.TradeSkillHook:HookTradeSkill()
	if not TradeSkillFrame or TradeSkillFrame.gsfBtn then return end

	local btn = CreateFrame("Button", "TradeSkillFrameGSFButton", TradeSkillFrame, "UIPanelButtonTemplate")
	btn:SetSize(76, 18)
	btn:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -36, -14)
	btn:SetText("GSF Hub")
	btn:SetScript("OnClick", function()
		if GSF.Scanner then
			GSF.Scanner:ScanTradeSkill(true)
		end
		if GSF.MainFrame then
			GSF.MainFrame:Show()
			GSF.MainFrame:SelectTab(1)
		end
	end)

	TradeSkillFrame.gsfBtn = btn
end

function GSF.TradeSkillHook:HookCraft()
	if not CraftFrame or CraftFrame.gsfBtn then return end

	local btn = CreateFrame("Button", "CraftFrameGSFButton", CraftFrame, "UIPanelButtonTemplate")
	btn:SetSize(76, 18)
	btn:SetPoint("TOPRIGHT", CraftFrame, "TOPRIGHT", -36, -14)
	btn:SetText("GSF Hub")
	btn:SetScript("OnClick", function()
		if GSF.Scanner then
			GSF.Scanner:ScanCraft(true)
		end
		if GSF.MainFrame then
			GSF.MainFrame:Show()
			GSF.MainFrame:SelectTab(1)
		end
	end)

	CraftFrame.gsfBtn = btn
end
