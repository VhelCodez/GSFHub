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
	btn:SetSize(68, 16)
	local xOffset = -52
	local closeBtn = _G["TradeSkillFrameCloseButton"] or (TradeSkillFrame and TradeSkillFrame.CloseButton)
	if closeBtn and closeBtn.GetPoint then
		local _, _, _, closeX = closeBtn:GetPoint(1)
		if closeX and closeX <= -25 then
			xOffset = -68
		end
	end
	btn:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", xOffset, -15)
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
	btn:SetSize(68, 16)
	local xOffset = -52
	local closeBtn = _G["CraftFrameCloseButton"] or (CraftFrame and CraftFrame.CloseButton)
	if closeBtn and closeBtn.GetPoint then
		local _, _, _, closeX = closeBtn:GetPoint(1)
		if closeX and closeX <= -25 then
			xOffset = -68
		end
	end
	btn:SetPoint("TOPRIGHT", CraftFrame, "TOPRIGHT", xOffset, -15)
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
