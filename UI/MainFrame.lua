local ADDON_NAME, GSF = ...

local MainFrame = CreateFrame("Frame", "GSFHubMainFrame", UIParent)
GSF.MainFrame = MainFrame

local NUM_TABS = 5
local tabs = {}
local tabContents = {}
local activeTab = 1

function MainFrame:Initialize()
	self:SetSize(760, 480)
	self:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	self:SetFrameStrata("HIGH")
	self:SetMovable(true)
	self:EnableMouse(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)
	self:SetClampedToScreen(true)

	if BackdropTemplateMixin then Mixin(self, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(self, false)
	self:SetBackdropColor(0.05, 0.05, 0.07, 0.96)
	self:SetBackdropBorderColor(0.2, 0.8, 0.4, 0.8)

	-- Header Title
	local title = self:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	title:SetPoint("TOPLEFT", self, "TOPLEFT", 16, -14)
	title:SetText(string.format("|cff%s%s|r  |cffffffff%s|r", GSF.COLORS.PRIMARY, GSF.L["ADDON_TITLE"], GSF.VERSION))
	self.title = title

	-- Close Button
	local closeBtn = CreateFrame("Button", nil, self, "UIPanelCloseButton")
	closeBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", -4, -4)
	closeBtn:SetScript("OnClick", function()
		self:Hide()
	end)

	-- Container for tab contents
	local contentArea = CreateFrame("Frame", nil, self)
	contentArea:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -40)
	contentArea:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -10, 38)
	self.contentArea = contentArea

	-- Instantiate Tab modules
	tabContents[1] = GSF.TabProfessions:Create(contentArea)
	tabContents[2] = GSF.TabWorkOrders:Create(contentArea)
	tabContents[3] = GSF.TabSurplus:Create(contentArea)
	tabContents[4] = GSF.TabDrops:Create(contentArea)
	tabContents[5] = GSF.TabRoster:Create(contentArea)

	-- Create Bottom Tabs
	local tabTitles = {
		GSF.L["TAB_PROFESSIONS"],
		GSF.L["TAB_WORK_ORDERS"],
		GSF.L["TAB_SURPLUS"],
		GSF.L["TAB_DROPS"],
		GSF.L["TAB_ROSTER"],
	}

	for i = 1, NUM_TABS do
		local tab = CreateFrame("Button", "GSFHubTab" .. i, self, "CharacterFrameTabButtonTemplate")
		tab:SetID(i)
		tab:SetText(tabTitles[i])
		tab:SetScript("OnClick", function()
			MainFrame:SelectTab(i)
		end)
		if i == 1 then
			tab:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 15, 2)
		else
			tab:SetPoint("LEFT", tabs[i - 1], "RIGHT", -16, 0)
		end
		tabs[i] = tab
	end

	self:SelectTab(1)
	self:Hide()

	self:SetScript("OnShow", function()
		self:RefreshCurrentTab()
	end)
end

function MainFrame:SelectTab(id)
	activeTab = id
	for i = 1, NUM_TABS do
		if i == id then
			tabContents[i]:Show()
			PanelTemplates_SelectTab(tabs[i])
		else
			tabContents[i]:Hide()
			PanelTemplates_DeselectTab(tabs[i])
		end
	end
	self:RefreshCurrentTab()
end

function MainFrame:RefreshCurrentTab()
	if activeTab == 1 and GSF.TabProfessions then
		GSF.TabProfessions:Refresh()
	elseif activeTab == 2 and GSF.TabWorkOrders then
		GSF.TabWorkOrders:Refresh()
	elseif activeTab == 3 and GSF.TabSurplus then
		GSF.TabSurplus:Refresh()
	elseif activeTab == 4 and GSF.TabDrops then
		GSF.TabDrops:Refresh()
	elseif activeTab == 5 and GSF.TabRoster then
		GSF.TabRoster:Refresh()
	end
end

function MainFrame:Toggle()
	if not self.initialized then
		self:Initialize()
		self.initialized = true
	end

	if self:IsShown() then
		self:Hide()
	else
		self:Show()
	end
end

-- Hook into Core initialization
local coreInitTimer = C_Timer.After(0.1, function()
	if not MainFrame.initialized then
		MainFrame:Initialize()
		MainFrame.initialized = true
	end
end)
