local ADDON_NAME, GSF = ...

local Tab = {}
GSF.TabRoster = Tab

function Tab:Create(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetAllPoints()
	self.frame = frame

	-- Search Input (Top-Left aligned)
	local searchBox = GSF.UI:CreateEditBox(frame, 150, 22)
	searchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -12)
	self.searchBox = searchBox

	local searchHint = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	searchHint:SetPoint("LEFT", searchBox, "LEFT", 5, 0)
	searchHint:SetText(GSF.L["SEARCH_MEMBERS"] or "Search members...")
	searchBox.searchHint = searchHint
	searchBox:HookScript("OnTextChanged", function(eb)
		if eb:GetText() ~= "" then searchHint:Hide() else searchHint:Show() end
		Tab:Refresh()
	end)

	-- Show Offline Members Checkbox (default false / unchecked)
	local offlineCheck = CreateFrame("CheckButton", "GSFRosterOfflineCheck", frame, "UICheckButtonTemplate")
	offlineCheck:SetPoint("LEFT", searchBox, "RIGHT", 6, -1)
	offlineCheck.text:SetText(GSF.L["SHOW_OFFLINE_MEMBERS"] or "Offline anzeigen")
	offlineCheck.text:SetFontObject("GameFontHighlightSmall")
	offlineCheck.text:ClearAllPoints()
	offlineCheck.text:SetPoint("LEFT", offlineCheck, "RIGHT", 2, 1)
	offlineCheck:SetChecked(false)
	offlineCheck:SetScript("OnClick", function()
		Tab:Refresh()
	end)
	self.offlineCheck = offlineCheck

	-- Sync Action Button (Top-Right aligned)
	local syncBtn = GSF.UI:CreateButton(frame, GSF.L["FORCE_SYNC"], 125, 24)
	syncBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -12)
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
	statText:SetPoint("RIGHT", syncBtn, "LEFT", -10, 0)
	self.statText = statText

	-- Sort state
	self.sortKey = "status"
	self.sortAsc = false

	local function CreateSortHeader(parent, text, width, point, relFrame, relPoint, x, y, sortKey, defaultAsc, justify)
		local btn = CreateFrame("Button", nil, parent)
		btn:SetSize(width, 20)
		btn:SetPoint(point, relFrame, relPoint, x, y)

		local title = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		title:SetJustifyH(justify or "LEFT")
		title:SetText(text)
		btn.title = title

		local arrow = btn:CreateTexture(nil, "OVERLAY")
		arrow:SetTexture("Interface\\Buttons\\UI-SortArrow")
		arrow:SetSize(9, 8)
		arrow:Hide()
		btn.arrow = arrow

		if (justify or "LEFT") == "RIGHT" then
			title:SetPoint("RIGHT", btn, "RIGHT", -12, 0)
			arrow:SetPoint("LEFT", title, "RIGHT", 3, 0)
		else
			title:SetPoint("LEFT", btn, "LEFT", 0, 0)
			arrow:SetPoint("LEFT", title, "RIGHT", 3, 0)
		end

		btn:SetScript("OnClick", function()
			if Tab.sortKey == sortKey then
				Tab.sortAsc = not Tab.sortAsc
			else
				Tab.sortKey = sortKey
				Tab.sortAsc = defaultAsc
			end
			Tab:Refresh()
		end)

		btn:SetScript("OnEnter", function()
			title:SetTextColor(1, 1, 1)
		end)
		btn:SetScript("OnLeave", function()
			title:SetTextColor(1, 0.82, 0)
		end)

		return btn
	end

	-- Roster Table Header (placed at Y = -45)
	local headerBar = CreateFrame("Frame", nil, frame)
	headerBar:SetSize(700, 20)
	headerBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -45)
	if BackdropTemplateMixin then Mixin(headerBar, BackdropTemplateMixin) end
	GSF.UI:CreateBackdrop(headerBar, false)
	headerBar:SetBackdropColor(0.15, 0.15, 0.20, 0.9)

	self.btnName = CreateSortHeader(headerBar, GSF.L["TABLE_CHARACTER"] or "Charakter", 145, "LEFT", headerBar, "LEFT", 8, 0, "name", true, "LEFT")
	self.btnLevel = CreateSortHeader(headerBar, GSF.L["TABLE_LEVEL"] or "Stufe", 42, "LEFT", headerBar, "LEFT", 158, 0, "level", false, "LEFT")
	self.btnClass = CreateSortHeader(headerBar, GSF.L["TABLE_CLASS"] or "Klasse", 50, "LEFT", headerBar, "LEFT", 202, 0, "class", true, "LEFT")
	self.btnMain = CreateSortHeader(headerBar, GSF.L["TABLE_MAIN"] or "Hauptcharakter", 95, "LEFT", headerBar, "LEFT", 255, 0, "main", true, "LEFT")
	self.btnProf = CreateSortHeader(headerBar, GSF.L["TABLE_PROFESSIONS"] or "Berufe", 235, "LEFT", headerBar, "LEFT", 355, 0, "prof", false, "LEFT")
	self.btnStatus = CreateSortHeader(headerBar, GSF.L["TABLE_LAST_SEEN"] or "Status", 90, "RIGHT", headerBar, "RIGHT", -36, 0, "status", false, "RIGHT")

	-- Roster Table Scroll (fills middle area down to bottom section)
	local scrollFrame, content = GSF.UI:CreateScrollList(frame, 700, 310)
	scrollFrame:SetPoint("TOPLEFT", headerBar, "BOTTOMLEFT", 0, -4)
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 52)
	self.scrollFrame = scrollFrame
	self.content = content
	self.memberRows = {}

	-- Main/Alt Section (Bottom Bar)
	local mainLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	mainLabel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, 34)
	mainLabel:SetText(GSF.L["MAIN_ALT_TITLE"])
	self.mainLabel = mainLabel

	local mainPrompt = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	mainPrompt:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, 14)
	mainPrompt:SetText(GSF.L["SET_MAIN_CHARACTER"])
	self.mainPrompt = mainPrompt

	local myName = GSF.DB:GetPlayerName()
	local mainBox = GSF.UI:CreateEditBox(frame, 140, 22)
	mainBox:SetPoint("LEFT", mainPrompt, "RIGHT", 8, 0)
	self.mainBox = mainBox

	local mainHint = mainBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	mainHint:SetPoint("LEFT", mainBox, "LEFT", 5, 0)
	mainHint:SetText(myName)
	mainBox.mainHint = mainHint

	local curMain = (GSF.Alts and GSF.Alts:GetMyMain()) or ""
	if curMain ~= "" and curMain:lower() ~= myName:lower() then
		mainBox:SetText(curMain)
		mainHint:Hide()
	else
		mainBox:SetText("")
		mainHint:Show()
	end

	mainBox:HookScript("OnTextChanged", function(eb)
		if eb:GetText() ~= "" then
			mainHint:Hide()
		else
			mainHint:Show()
		end
	end)

	local saveMainBtn = GSF.UI:CreateButton(frame, GSF.L["SAVE_MAIN"], 80, 22)
	saveMainBtn:SetPoint("LEFT", mainBox, "RIGHT", 8, 0)
	self.saveMainBtn = saveMainBtn

	local function SaveMain()
		local pName = GSF.DB:GetPlayerName()
		local text = mainBox:GetText():match("^%s*(.-)%s*$")
		if not text or text == "" or text:lower() == pName:lower() then
			GSF.Alts:SetMyMain("")
			mainBox:SetText("")
			mainHint:SetText(pName)
			mainHint:Show()
			GSF.Addon:Printf(GSF.L["MAIN_RESET_SELF_NOTICE"] or "Main character reset: You (%s) are your own main.", pName)
			Tab:Refresh()
		elseif string.len(text) >= 2 then
			GSF.Alts:SetMyMain(text)
			mainBox:SetText(text)
			mainHint:Hide()
			GSF.Addon:Printf(GSF.L["MAIN_SAVED_NOTICE"] or "Main character updated to '%s'.", text)
			Tab:Refresh()
		else
			GSF.Addon:Printf(GSF.L["MAIN_INVALID_NOTICE"] or "Invalid main character name. Minimum 2 characters required.")
		end
	end

	saveMainBtn:SetScript("OnClick", SaveMain)
	mainBox:SetScript("OnEnterPressed", function(eb)
		SaveMain()
		eb:ClearFocus()
	end)

	return frame
end

function Tab:UpdateSortHeaders()
	local headers = {
		{ btn = self.btnName, key = "name", text = GSF.L["TABLE_CHARACTER"] or "Charakter" },
		{ btn = self.btnLevel, key = "level", text = GSF.L["TABLE_LEVEL"] or "Stufe" },
		{ btn = self.btnClass, key = "class", text = GSF.L["TABLE_CLASS"] or "Klasse" },
		{ btn = self.btnMain, key = "main", text = GSF.L["TABLE_MAIN"] or "Hauptcharakter" },
		{ btn = self.btnProf, key = "prof", text = GSF.L["TABLE_PROFESSIONS"] or "Berufe" },
		{ btn = self.btnStatus, key = "status", text = GSF.L["TABLE_LAST_SEEN"] or "Status" },
	}
	for _, h in ipairs(headers) do
		if h.btn and h.btn.title then
			h.btn.title:SetText(h.text)
			if h.btn.arrow then
				if self.sortKey == h.key then
					h.btn.arrow:Show()
					if self.sortAsc then
						h.btn.arrow:SetTexCoord(0, 0.5625, 0, 1.0)
					else
						h.btn.arrow:SetTexCoord(0, 0.5625, 1.0, 0)
					end
				else
					h.btn.arrow:Hide()
				end
			end
		end
	end
end

function Tab:UpdateTexts()
	if not self.frame then return end
	if self.mainLabel then self.mainLabel:SetText(GSF.L["MAIN_ALT_TITLE"]) end
	if self.mainPrompt then self.mainPrompt:SetText(GSF.L["SET_MAIN_CHARACTER"]) end
	if self.saveMainBtn then self.saveMainBtn:SetText(GSF.L["SAVE_MAIN"]) end
	if self.syncBtn then self.syncBtn:SetText(GSF.L["FORCE_SYNC"]) end
	self:UpdateSortHeaders()
	if self.offlineCheck and self.offlineCheck.text then
		self.offlineCheck.text:SetText(GSF.L["SHOW_OFFLINE_MEMBERS"] or "Offline anzeigen")
	end
	if self.searchBox and self.searchBox.searchHint then
		self.searchBox.searchHint:SetText(GSF.L["SEARCH_MEMBERS"] or "Search members...")
	end
	self:Refresh()
end

function Tab:Refresh()
	if not self.frame or not self.frame:IsShown() then return end

	local totalMembers = 0
	local onlineCount = 0
	local numRecipes = 0
	local memberList = {}
	local isGuild = IsInGuild() and GSF.isGuildScope
	local myName = GSF.DB:GetPlayerName()
	local showOffline = self.offlineCheck and self.offlineCheck:GetChecked()

	local function IsOnline(m)
		if not m then return false end
		if m.name == myName then return true end
		if m.isOnline ~= nil then
			return (m.isOnline == true or m.isOnline == 1)
		end
		return ((time() - (m.lastSeen or 0)) < 900)
	end

	if GSF.cache and GSF.cache.members then
		for name, data in pairs(GSF.cache.members) do
			-- When in solo mode, only show the player's own record
			if isGuild or name == myName then
				totalMembers = totalMembers + 1

				local isMe = (name == myName)
				local isOnline = IsOnline(data)

				if isOnline then
					onlineCount = onlineCount + 1
				end

				if data.professions then
					for _, p in pairs(data.professions) do
						if p.recipes then
							for _ in pairs(p.recipes) do
								numRecipes = numRecipes + 1
							end
						end
					end
				end

				-- Include in display list according to offline toggle
				if showOffline or isOnline then
					table.insert(memberList, data)
				end
			end
		end
	end

	-- If in solo mode and player record isn't in cache yet, ensure it
	if not isGuild and #memberList == 0 then
		local myMember = GSF.DB:EnsureMemberRecord(myName)
		table.insert(memberList, myMember)
		totalMembers = 1
		onlineCount = 1
	end

	if not isGuild then
		self.syncBtn:Disable()
		self.statText:SetText(string.format("|cff888888%s (%s)|r", GSF.L["SOLO_MODE"] or "Offline Mode (No Guild)", myName))
	else
		self.syncBtn:Enable()
		local statFormat = GSF.L["TOTAL_MEMBERS_ONLINE_STATS_SHORT"] or "%d members (%d online, %d recipes)"
		self.statText:SetText(string.format(statFormat, totalMembers, onlineCount, numRecipes))
	end

	if self.mainBox and not self.mainBox:HasFocus() then
		local curMain = (GSF.Alts and GSF.Alts:GetMyMain()) or ""
		if curMain ~= "" and curMain:lower() ~= myName:lower() then
			self.mainBox:SetText(curMain)
			if self.mainBox.mainHint then self.mainBox.mainHint:Hide() end
		else
			self.mainBox:SetText("")
			if self.mainBox.mainHint then
				self.mainBox.mainHint:SetText(myName)
				self.mainBox.mainHint:Show()
			end
		end
	end

	self:UpdateSortHeaders()

	-- Sort members with strict weak ordering
	table.sort(memberList, function(a, b)
		local aMe = (a.name == myName)
		local bMe = (b.name == myName)

		local aRaw = tostring(a.name or "")
		local bRaw = tostring(b.name or "")
		local aNameNorm = (GSF.NormalizeSortString and GSF:NormalizeSortString(a.name)) or aRaw:lower()
		local bNameNorm = (GSF.NormalizeSortString and GSF:NormalizeSortString(b.name)) or bRaw:lower()

		if self.sortKey == "name" then
			if aMe ~= bMe then return aMe end
			if aNameNorm ~= bNameNorm then
				if self.sortAsc then
					return aNameNorm < bNameNorm
				else
					return aNameNorm > bNameNorm
				end
			elseif aRaw ~= bRaw then
				if self.sortAsc then
					return aRaw < bRaw
				else
					return aRaw > bRaw
				end
			end
		elseif self.sortKey == "level" then
			if aMe ~= bMe then return aMe end
			local aLvl = tonumber(a.level) or 0
			local bLvl = tonumber(b.level) or 0
			if aLvl ~= bLvl then
				if self.sortAsc then
					return aLvl < bLvl
				else
					return aLvl > bLvl
				end
			end
			-- Stable tie-breaker: always A-Z
			if aNameNorm ~= bNameNorm then
				return aNameNorm < bNameNorm
			elseif aRaw ~= bRaw then
				return aRaw < bRaw
			end
		elseif self.sortKey == "class" then
			if aMe ~= bMe then return aMe end
			local aClassRaw = tostring(a.class or "")
			local bClassRaw = tostring(b.class or "")
			local aClassNorm = (GSF.NormalizeSortString and GSF:NormalizeSortString(a.class)) or aClassRaw:lower()
			local bClassNorm = (GSF.NormalizeSortString and GSF:NormalizeSortString(b.class)) or bClassRaw:lower()
			if aClassNorm ~= bClassNorm then
				if self.sortAsc then
					return aClassNorm < bClassNorm
				else
					return aClassNorm > bClassNorm
				end
			end
			-- Stable tie-breaker: always A-Z
			if aNameNorm ~= bNameNorm then
				return aNameNorm < bNameNorm
			elseif aRaw ~= bRaw then
				return aRaw < bRaw
			end
		elseif self.sortKey == "main" then
			if aMe ~= bMe then return aMe end
			local aMainRaw = tostring(a.main or a.name or "")
			local bMainRaw = tostring(b.main or b.name or "")
			local aMainNorm = (GSF.NormalizeSortString and GSF:NormalizeSortString(aMainRaw)) or aMainRaw:lower()
			local bMainNorm = (GSF.NormalizeSortString and GSF:NormalizeSortString(bMainRaw)) or bMainRaw:lower()
			if aMainNorm ~= bMainNorm then
				if self.sortAsc then
					return aMainNorm < bMainNorm
				else
					return aMainNorm > bMainNorm
				end
			end
			-- Stable tie-breaker: always A-Z
			if aNameNorm ~= bNameNorm then
				return aNameNorm < bNameNorm
			elseif aRaw ~= bRaw then
				return aRaw < bRaw
			end
		elseif self.sortKey == "prof" then
			if aMe ~= bMe then return aMe end
			local aCount = 0
			local bCount = 0
			if a.professions then for _ in pairs(a.professions) do aCount = aCount + 1 end end
			if b.professions then for _ in pairs(b.professions) do bCount = bCount + 1 end end
			if aCount ~= bCount then
				if self.sortAsc then
					return aCount < bCount
				else
					return aCount > bCount
				end
			end
			-- Stable tie-breaker: always A-Z
			if aNameNorm ~= bNameNorm then
				return aNameNorm < bNameNorm
			elseif aRaw ~= bRaw then
				return aRaw < bRaw
			end
		else -- status
			local aOnline = IsOnline(a)
			local bOnline = IsOnline(b)

			if self.sortAsc then
				-- Ascending: Offline first
				if aOnline ~= bOnline then
					return not aOnline
				end
				if not aOnline then
					-- Both offline: longest offline first
					local aLast = a.lastSeen or 0
					local bLast = b.lastSeen or 0
					if aLast ~= bLast then
						return aLast < bLast
					end
				else
					-- Both online: myName first, then A-Z
					if aMe ~= bMe then return aMe end
				end
			else
				-- Descending: Online first
				if aOnline ~= bOnline then
					return aOnline
				end
				if aOnline then
					-- Both online: myName first, then A-Z
					if aMe ~= bMe then return aMe end
				else
					-- Both offline: most recently online first
					local aLast = a.lastSeen or 0
					local bLast = b.lastSeen or 0
					if aLast ~= bLast then
						return aLast > bLast
					end
				end
			end

			-- Stable tie-breaker: always A-Z
			if aNameNorm ~= bNameNorm then
				return aNameNorm < bNameNorm
			elseif aRaw ~= bRaw then
				return aRaw < bRaw
			end
		end

		return false
	end)

	local query = self.searchBox and self.searchBox:GetText():trim() or ""
	if query ~= "" then
		local normQuery = (GSF.NormalizeSortString and GSF:NormalizeSortString(query)) or query:lower()
		local filtered = {}
		for _, member in ipairs(memberList) do
			local nameNorm = (GSF.NormalizeSortString and GSF:NormalizeSortString(member.name)) or tostring(member.name or ""):lower()
			local mainNorm = (GSF.NormalizeSortString and GSF:NormalizeSortString(member.main)) or tostring(member.main or ""):lower()
			local classNorm = (GSF.NormalizeSortString and GSF:NormalizeSortString(member.class)) or tostring(member.class or ""):lower()
			local nameMatch = nameNorm:find(normQuery, 1, true)
			local mainMatch = mainNorm:find(normQuery, 1, true)
			local classMatch = classNorm:find(normQuery, 1, true)
			local profMatch = false
			if member.professions then
				for pName, _ in pairs(member.professions) do
					local locProf = GSF:GetLocalizedProfession(pName)
					local pNorm = (GSF.NormalizeSortString and GSF:NormalizeSortString(pName)) or pName:lower()
					local locNorm = (GSF.NormalizeSortString and GSF:NormalizeSortString(locProf)) or locProf:lower()
					if pNorm:find(normQuery, 1, true) or locNorm:find(normQuery, 1, true) then
						profMatch = true
						break
					end
				end
			end
			if nameMatch or mainMatch or classMatch or profMatch then
				table.insert(filtered, member)
			end
		end
		memberList = filtered
	end

	for _, row in ipairs(self.memberRows) do row:Hide() end

	local yOffset = 2
	for i, member in ipairs(memberList) do
		local row = self.memberRows[i]
		if not row then
			row = CreateFrame("Frame", nil, self.content)
			row:SetSize(674, 46)
			if BackdropTemplateMixin then Mixin(row, BackdropTemplateMixin) end
			GSF.UI:CreateBackdrop(row, false)

			-- Column 1: Character (Line 1: Status + Name, Line 2: Role Badges)
			local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			name:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -7)
			name:SetPoint("RIGHT", row, "LEFT", 155, 0)
			name:SetJustifyH("LEFT")
			row.name = name

			local badges = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			badges:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 8, 7)
			badges:SetPoint("RIGHT", row, "LEFT", 155, 0)
			badges:SetJustifyH("LEFT")
			row.badges = badges

			-- Column 2: Level & Class (Line 1: Level, Line 2: Class)
			local levelText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			levelText:SetPoint("TOPLEFT", row, "TOPLEFT", 158, -7)
			levelText:SetPoint("RIGHT", row, "LEFT", 250, 0)
			levelText:SetJustifyH("LEFT")
			row.levelText = levelText

			local classText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			classText:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 158, 7)
			classText:SetPoint("RIGHT", row, "LEFT", 250, 0)
			classText:SetJustifyH("LEFT")
			row.classText = classText

			-- Column 3: Main / Alt (Line 1: Main Name, Line 2: Main/Alt Status)
			local main = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			main:SetPoint("TOPLEFT", row, "TOPLEFT", 255, -7)
			main:SetPoint("RIGHT", row, "LEFT", 350, 0)
			main:SetJustifyH("LEFT")
			row.main = main

			local altNote = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			altNote:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 255, 7)
			altNote:SetPoint("RIGHT", row, "LEFT", 350, 0)
			altNote:SetJustifyH("LEFT")
			row.altNote = altNote

			-- Column 4: Professions (Line 1: Primary Skills, Line 2: Secondary Skills)
			local profsPrimary = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			profsPrimary:SetPoint("TOPLEFT", row, "TOPLEFT", 355, -7)
			profsPrimary:SetPoint("RIGHT", row, "RIGHT", -95, 0)
			profsPrimary:SetJustifyH("LEFT")
			row.profsPrimary = profsPrimary

			local profsSecondary = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			profsSecondary:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 355, 7)
			profsSecondary:SetPoint("RIGHT", row, "RIGHT", -95, 0)
			profsSecondary:SetJustifyH("LEFT")
			row.profsSecondary = profsSecondary

			-- Column 5: Status / Last Seen (Line 1: Online / Offline, Line 2: Time Ago)
			local statusText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			statusText:SetPoint("TOPRIGHT", row, "TOPRIGHT", -10, -7)
			statusText:SetPoint("LEFT", row, "RIGHT", -90, 0)
			statusText:SetJustifyH("RIGHT")
			row.statusText = statusText

			local lastSeen = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
			lastSeen:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -10, 7)
			lastSeen:SetPoint("LEFT", row, "RIGHT", -90, 0)
			lastSeen:SetJustifyH("RIGHT")
			row.lastSeen = lastSeen

			table.insert(self.memberRows, row)
		end

		row:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -yOffset)

		local isMe = (member.name == myName)
		local isOnline = IsOnline(member)

		-- Highlight logged-in player with golden border and warm dark background; subtle alternating rows for others
		if isMe then
			row:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.95)
			row:SetBackdropColor(0.20, 0.16, 0.06, 0.80)
		else
			row:SetBackdropBorderColor(0.25, 0.25, 0.30, 0.50)
			if (i % 2) == 0 then
				row:SetBackdropColor(0.09, 0.09, 0.13, 0.65)
			else
				row:SetBackdropColor(0.06, 0.06, 0.09, 0.50)
			end
		end

		local statusIcon = isOnline and "|TInterface\\FriendsFrame\\StatusIcon-Online:12:12:0:0|t" or "|TInterface\\FriendsFrame\\StatusIcon-Offline:12:12:0:0|t"
		local classColor = (GSF.GetClassColor and GSF:GetClassColor(member.classFileName or member.class)) or "ffffff"

		-- Col 1: Character name & badges underneath
		local coloredName = string.format("|cff%s%s|r", classColor, member.name or "Unknown")
		row.name:SetText(string.format("%s %s", statusIcon, coloredName))

		local roleBadges = GSF.Roles and GSF.Roles:GetRoleBadgesString(member.name) or ""
		row.badges:SetText(roleBadges)

		-- Col 2: Level & Class
		if member.level and tonumber(member.level) and tonumber(member.level) > 0 then
			row.levelText:SetText(string.format("Lvl %d", tonumber(member.level)))
		else
			row.levelText:SetText("|cff555555—|r")
		end

		if member.class and member.class ~= "UNKNOWN" and member.class ~= "" then
			row.classText:SetText(string.format("|cff%s%s|r", classColor, member.class))
		else
			row.classText:SetText("|cff555555—|r")
		end

		-- Col 3: Main / Alt
		local isAlt = (member.main and member.main ~= "" and member.main:lower() ~= (member.name or ""):lower())
		row.main:SetText(member.main or member.name or "")
		if isAlt then
			row.altNote:SetText("|cff888888Alt|r")
		else
			row.altNote:SetText("|cff555555Main|r")
		end

		-- Col 4: Primary & Secondary Professions (Two lines)
		local primaryList = {}
		local secondaryList = {}
		if member.professions then
			for pName, pData in pairs(member.professions) do
				local canon = GSF:GetCanonicalProfession(pName)
				local locName = GSF:GetLocalizedProfession(pName)
				local rankStr = string.format("%s (%d)", locName, pData.curRank or 0)
				local isSec = false
				if GSF.PROFESSIONS and GSF.PROFESSIONS[canon] then
					isSec = GSF.PROFESSIONS[canon].isSecondary
				elseif canon == "Cooking" or canon == "First Aid" or canon == "Fishing" or canon == "Lockpicking" then
					isSec = true
				end
				if isSec then
					table.insert(secondaryList, rankStr)
				else
					table.insert(primaryList, rankStr)
				end
			end
		end
		table.sort(primaryList)
		table.sort(secondaryList)

		if #primaryList > 0 then
			row.profsPrimary:SetText(table.concat(primaryList, ", "))
		else
			row.profsPrimary:SetText("|cff555555—|r")
		end

		if #secondaryList > 0 then
			row.profsSecondary:SetText(table.concat(secondaryList, ", "))
		else
			row.profsSecondary:SetText("")
		end

		-- Col 5: Status / Last Seen
		if isMe or isOnline then
			row.statusText:SetText("|cff00ff00Online|r")
			row.lastSeen:SetText("")
		else
			row.statusText:SetText("|cff777777Offline|r")
			row.lastSeen:SetText(GSF:FormatTimeAgo(member.lastSeen))
		end

		row:Show()
		yOffset = yOffset + 48
	end

	self.content:SetHeight(math.max(yOffset + 2, 1))
	if self.scrollFrame and self.scrollFrame.UpdateScrollBar then
		self.scrollFrame:UpdateScrollBar()
	end
end
