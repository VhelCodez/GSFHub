local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabRoster = Tab

function Tab:Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	self.frame = frame

	-- Main/Alt Section
	local mainLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
	mainLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -12)
	mainLabel:SetText(GSF.L["MAIN_ALT_TITLE"])
	self.mainLabel = mainLabel

	local mainPrompt = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	mainPrompt:SetPoint("TOPLEFT", mainLabel, "BOTTOMLEFT", 0, -8)
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
		local text = mainBox:GetText():match("^%s*(.-)%s*$")
		if text and string.len(text) >= 2 then
			GSF.Alts:SetMyMain(text)
			GSF.Addon:Printf(GSF.L["MAIN_SAVED_NOTICE"] or "Main character updated to '%s'.", text)
			Tab:Refresh()
		else
			GSF.Addon:Printf(GSF.L["MAIN_INVALID_NOTICE"] or "Invalid main character name. Minimum 2 characters required.")
		end
	end)

	-- Sync Action Button (anchored with clear vertical space)
	local syncBtn = GSF.UI:CreateButton(frame, GSF.L["FORCE_SYNC"], 150, 22)
	syncBtn:SetPoint("TOPLEFT", mainPrompt, "BOTTOMLEFT", 0, -10)
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

	-- Roster Table Header (placed at Y = -96 with 8px margin below syncBtn)
	local headerBar = CreateFrame("Frame", nil, frame)
	headerBar:SetSize(700, 20)
	headerBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -96)
	if BackdropTemplateMixin then Mixin(headerBar, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(headerBar, false)
	headerBar:SetBackdropColor(0.15, 0.15, 0.20, 0.9)

	local h1 = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	h1:SetPoint("LEFT", headerBar, "LEFT", 10, 0)
	h1:SetText(GSF.L["TABLE_CHARACTER"])
	self.h1 = h1

	local h2 = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	h2:SetPoint("LEFT", headerBar, "LEFT", 150, 0)
	h2:SetText(GSF.L["TABLE_MAIN"])
	self.h2 = h2

	local h3 = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	h3:SetPoint("LEFT", headerBar, "LEFT", 280, 0)
	h3:SetText(GSF.L["TABLE_PROFESSIONS"])
	self.h3 = h3

	local h4 = headerBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	h4:SetPoint("RIGHT", headerBar, "RIGHT", -15, 0)
	h4:SetText(GSF.L["TABLE_LAST_SEEN"])
	self.h4 = h4

	-- Roster Table Scroll
	local scrollFrame, content = GSF.UI:CreateScrollList(frame, 700, 310)
	scrollFrame:SetPoint("TOPLEFT", headerBar, "BOTTOMLEFT", 0, -4)
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 15)
	self.content = content
	self.memberRows = {}

	return frame
end

function Tab:UpdateTexts()
	if not self.frame then return end
	if self.mainLabel then self.mainLabel:SetText(GSF.L["MAIN_ALT_TITLE"]) end
	if self.mainPrompt then self.mainPrompt:SetText(GSF.L["SET_MAIN_CHARACTER"]) end
	if self.saveMainBtn then self.saveMainBtn:SetText(GSF.L["SAVE_MAIN"]) end
	if self.syncBtn then self.syncBtn:SetText(GSF.L["FORCE_SYNC"]) end
	if self.h1 then self.h1:SetText(GSF.L["TABLE_CHARACTER"]) end
	if self.h2 then self.h2:SetText(GSF.L["TABLE_MAIN"]) end
	if self.h3 then self.h3:SetText(GSF.L["TABLE_PROFESSIONS"]) end
	if self.h4 then self.h4:SetText(GSF.L["TABLE_LAST_SEEN"]) end
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
		self.syncBtn:Disable()
		self.statText:SetText(string.format("|cff888888%s|r", GSF.L["SOLO_MODE"] or "Offline Mode (No Guild)"))
	else
		self.syncBtn:Enable()
		self.statText:SetText(string.format(GSF.L["TOTAL_MEMBERS_CACHED"], numMembers, numRecipes))
	end

	if self.mainBox then
		local currentMain = (GSF.Alts and GSF.Alts:GetMyMain()) or (GSF.db and GSF.db.mainCharacter) or GSF.DB:GetPlayerName()
		self.mainBox:SetText(currentMain or "")
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
			row:SetSize(690, 24)
			if BackdropTemplateMixin then Mixin(row, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(row, false)
			row:SetBackdropColor(0.08, 0.08, 0.12, 0.6)

			local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			name:SetPoint("LEFT", row, "LEFT", 10, 0)
			row.name = name

			local main = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			main:SetPoint("LEFT", row, "LEFT", 150, 0)
			row.main = main

			local profs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			profs:SetPoint("LEFT", row, "LEFT", 280, 0)
			profs:SetPoint("RIGHT", row, "RIGHT", -120, 0)
			profs:SetJustifyH("LEFT")
			row.profs = profs

			local lastSeen = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			lastSeen:SetPoint("RIGHT", row, "RIGHT", -15, 0)
			row.lastSeen = lastSeen

			table.insert(self.memberRows, row)
		end

		row:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -yOffset)
		
		local isMe = (member.name == GSF.DB:GetPlayerName())
		local isOnline = isMe or ((time() - (member.lastSeen or 0)) < 900)
		local statusIcon = isOnline and "|TInterface\\FriendsFrame\\StatusIcon-Online:12:12:0:0|t" or "|TInterface\\FriendsFrame\\StatusIcon-Offline:12:12:0:0|t"

		local roleBadges = GSF.Roles and GSF.Roles:GetRoleBadgesString(member.name) or ""
		local nameStr = roleBadges ~= "" and string.format("%s %s %s", statusIcon, member.name or "Unknown", roleBadges) or string.format("%s %s", statusIcon, member.name or "Unknown")
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
		if isMe or isOnline then
			row.lastSeen:SetText("|cff00ff00Online|r")
		elseif mins < 60 then
			row.lastSeen:SetText(string.format(GSF.L["MINS_AGO"] or "%dm ago", mins))
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
