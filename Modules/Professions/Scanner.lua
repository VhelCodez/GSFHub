local ADDON_NAME, GSF = ...

local AceEvent = LibStub("AceEvent-3.0")
GSF.Scanner = {}
AceEvent:Embed(GSF.Scanner)

function GSF.Scanner:Initialize()
	self:RegisterEvent("TRADE_SKILL_SHOW", "OnTradeSkillShow")
	self:RegisterEvent("TRADE_SKILL_UPDATE", "OnTradeSkillUpdate")
	self:RegisterEvent("CRAFT_SHOW", "OnCraftShow")
	self:RegisterEvent("CRAFT_UPDATE", "OnCraftUpdate")
	self:RegisterEvent("SKILL_LINES_CHANGED", "OnSkillLinesChanged")

	-- Scan character skills on init
	self:ScanSkillLines()
end

local scanTimers = {}

function GSF.Scanner:ScheduleTradeSkillScan(isManual)
	if scanTimers["TradeSkill"] then
		scanTimers["TradeSkill"]:Cancel()
		scanTimers["TradeSkill"] = nil
	end
	scanTimers["TradeSkill"] = C_Timer.NewTimer(0.3, function()
		scanTimers["TradeSkill"] = nil
		if TradeSkillFrame and TradeSkillFrame:IsShown() then
			GSF.Scanner:ScanTradeSkill(isManual)
		end
	end)
end

function GSF.Scanner:ScheduleCraftScan(isManual)
	if scanTimers["Craft"] then
		scanTimers["Craft"]:Cancel()
		scanTimers["Craft"] = nil
	end
	scanTimers["Craft"] = C_Timer.NewTimer(0.3, function()
		scanTimers["Craft"] = nil
		if CraftFrame and CraftFrame:IsShown() then
			GSF.Scanner:ScanCraft(isManual)
		end
	end)
end

function GSF.Scanner:OnTradeSkillShow()
	if GSF.db and GSF.db.autoScanOnOpen then
		self:ScheduleTradeSkillScan(false)
	end
end

function GSF.Scanner:OnTradeSkillUpdate()
	if TradeSkillFrame and TradeSkillFrame:IsShown() and GSF.db and GSF.db.autoScanOnOpen then
		self:ScheduleTradeSkillScan(false)
	end
end

function GSF.Scanner:OnCraftShow()
	if GSF.db and GSF.db.autoScanOnOpen then
		self:ScheduleCraftScan(false)
	end
end

function GSF.Scanner:OnCraftUpdate()
	if CraftFrame and CraftFrame:IsShown() and GSF.db and GSF.db.autoScanOnOpen then
		self:ScheduleCraftScan(false)
	end
end

function GSF.Scanner:OnSkillLinesChanged()
	self:ScanSkillLines()
end

function GSF.Scanner:ScanCurrentWindow()
	if TradeSkillFrame and TradeSkillFrame:IsShown() then
		self:ScanTradeSkill(true)
	elseif CraftFrame and CraftFrame:IsShown() then
		self:ScanCraft(true)
	else
		self:ScanSkillLines()
		GSF.Addon:Print("Scanned character skill lines. Open a Trade Skill window to scan full recipes.")
	end
end

function GSF.Scanner:ScanTradeSkill(isManual)
	local profName, curRank, maxRank = GetTradeSkillLine()
	if not profName or profName == "UNKNOWN" or profName == "" then return end

	local canonName = (GSF.GetCanonicalProfession and GSF:GetCanonicalProfession(profName)) or profName
	local myName = GSF.DB:GetPlayerName()
	local member = GSF.DB:EnsureMemberRecord(myName)
	member.professions = member.professions or {}

	local numSkills = GetNumTradeSkills()
	if numSkills == 0 then return end

	local existing = member.professions[canonName] or member.professions[profName]
	local existingCount = 0
	if existing and existing.recipes then
		for _ in pairs(existing.recipes) do existingCount = existingCount + 1 end
	end

	local recipes = {}
	local scannedCount = 0

	for i = 1, numSkills do
		local skillName, skillType, numAvailable, isExpanded, altVerb = GetTradeSkillInfo(i)
		if skillType ~= "header" and skillName then
			local itemLink = GetTradeSkillItemLink(i)
			local recipeLink = GetTradeSkillRecipeLink(i)
			local spellId = nil
			if recipeLink then
				spellId = tonumber(recipeLink:match("enchant:(%d+)") or recipeLink:match("spell:(%d+)"))
			end
			local key = spellId or skillName

			local reagents = {}
			local numReagents = GetTradeSkillNumReagents(i)
			for r = 1, numReagents do
				local rName, rTexture, rCount, rPlayerCount = GetTradeSkillReagentInfo(i, r)
				local rLink = GetTradeSkillReagentItemLink(i, r)
				if rName then
					table.insert(reagents, {
						name = rName,
						count = rCount or 1,
						link = rLink,
					})
				end
			end

			recipes[key] = {
				name = skillName,
				key = key,
				spellId = spellId,
				itemLink = itemLink,
				recipeLink = recipeLink,
				reagents = reagents,
				skillType = skillType,
			}
			scannedCount = scannedCount + 1
		end
	end

	local hasChanges = false
	local newRecipesFound = false
	if not existing or not existing.recipes then
		hasChanges = true
		if scannedCount > 0 then
			newRecipesFound = true
		end
	elseif (existing.curRank ~= curRank) or (existing.maxRank ~= maxRank) or (existingCount ~= scannedCount) then
		hasChanges = true
		for k in pairs(recipes) do
			if not existing.recipes[k] then
				newRecipesFound = true
				break
			end
		end
	else
		for k in pairs(recipes) do
			if not existing.recipes[k] then
				hasChanges = true
				newRecipesFound = true
				break
			end
		end
	end

	-- Clean up legacy localized key if present
	if profName ~= canonName and member.professions[profName] then
		member.professions[profName] = nil
	end

	member.professions[canonName] = {
		name = canonName,
		curRank = curRank,
		maxRank = maxRank,
		lastScanned = time(),
		recipes = recipes,
	}

	if GSF.DB and GSF.DB.SyncActiveCharacterProfessions then
		GSF.DB:SyncActiveCharacterProfessions()
	elseif GSF.db and GSF.db.characterProfessions then
		GSF.db.characterProfessions[canonName] = member.professions[canonName]
	end

	if hasChanges or isManual then
		GSF.cache.revisions.recipes = (GSF.cache.revisions.recipes or 0) + 1

		-- Only print to chat on manual scan or when newly learned recipes are discovered
		if isManual or newRecipesFound then
			local displayName = (GSF.GetLocalizedProfession and GSF:GetLocalizedProfession(canonName)) or profName
			GSF.Addon:Printf(GSF.L["SCAN_SUCCESS"], scannedCount, displayName, curRank, maxRank)
		end

		if GSF.Sync then
			GSF.Sync:SendMyData()
		end
	end
end

function GSF.Scanner:ScanCraft(isManual)
	local craftName, curRank, maxRank = GetCraftDisplaySkillLine()
	if not craftName or craftName == "" then
		craftName = "Enchanting"
	end

	local canonName = (GSF.GetCanonicalProfession and GSF:GetCanonicalProfession(craftName)) or craftName
	local myName = GSF.DB:GetPlayerName()
	local member = GSF.DB:EnsureMemberRecord(myName)
	member.professions = member.professions or {}

	local numCrafts = GetNumCrafts()
	if numCrafts == 0 then return end

	local existing = member.professions[canonName] or member.professions[craftName]
	local existingCount = 0
	if existing and existing.recipes then
		for _ in pairs(existing.recipes) do existingCount = existingCount + 1 end
	end

	local recipes = {}
	local scannedCount = 0

	for i = 1, numCrafts do
		local craftSkillName, craftSubSpellName, craftType, numAvailable, isExpanded = GetCraftInfo(i)
		if craftType ~= "header" and craftSkillName then
			local itemLink = GetCraftItemLink(i)
			local spellId = tonumber(itemLink and itemLink:match("enchant:(%d+)") or itemLink and itemLink:match("spell:(%d+)"))
			local key = spellId or craftSkillName

			local reagents = {}
			local numReagents = GetCraftNumReagents(i)
			for r = 1, numReagents do
				local rName, rTexture, rCount, rPlayerCount = GetCraftReagentInfo(i, r)
				local rLink = GetCraftReagentItemLink(i, r)
				if rName then
					table.insert(reagents, {
						name = rName,
						count = rCount or 1,
						link = rLink,
					})
				end
			end

			recipes[key] = {
				name = craftSkillName,
				key = key,
				spellId = spellId,
				itemLink = itemLink,
				reagents = reagents,
				skillType = craftType,
			}
			scannedCount = scannedCount + 1
		end
	end

	local hasChanges = false
	local newRecipesFound = false
	if not existing or not existing.recipes then
		hasChanges = true
		if scannedCount > 0 then
			newRecipesFound = true
		end
	elseif ((existing.curRank or 0) ~= (curRank or 0)) or ((existing.maxRank or 0) ~= (maxRank or 375)) or (existingCount ~= scannedCount) then
		hasChanges = true
		for k in pairs(recipes) do
			if not existing.recipes[k] then
				newRecipesFound = true
				break
			end
		end
	else
		for k in pairs(recipes) do
			if not existing.recipes[k] then
				hasChanges = true
				newRecipesFound = true
				break
			end
		end
	end

	-- Clean up legacy localized key if present
	if craftName ~= canonName and member.professions[craftName] then
		member.professions[craftName] = nil
	end

	member.professions[canonName] = {
		name = canonName,
		curRank = curRank or 0,
		maxRank = maxRank or 375,
		lastScanned = time(),
		recipes = recipes,
	}

	if GSF.DB and GSF.DB.SyncActiveCharacterProfessions then
		GSF.DB:SyncActiveCharacterProfessions()
	elseif GSF.db and GSF.db.characterProfessions then
		GSF.db.characterProfessions[canonName] = member.professions[canonName]
	end

	if hasChanges or isManual then
		GSF.cache.revisions.recipes = (GSF.cache.revisions.recipes or 0) + 1

		-- Only print to chat on manual scan or when newly learned recipes are discovered
		if isManual or newRecipesFound then
			GSF.Addon:Printf(GSF.L["SCAN_SUCCESS"], scannedCount, craftName, curRank or 0, maxRank or 375)
		end

		if GSF.Sync then
			GSF.Sync:SendMyData()
		end
	end
end

function GSF.Scanner:ScanSkillLines()
	local myName = GSF.DB:GetPlayerName()
	if not myName or myName == "" or myName == "Unknown" then return end

	local member = GSF.DB:EnsureMemberRecord(myName)
	member.professions = member.professions or {}

	local realm = GetRealmName() or "UnknownRealm"
	local charKey = string.format("%s - %s", myName, realm)
	local charSaved = GSFHubDB and GSFHubDB.characterProfessionsByChar and GSFHubDB.characterProfessionsByChar[charKey]

	local activeSkillNames = {}
	local hasChanges = false

	local numSkills = GetNumSkillLines()
	if numSkills and numSkills > 0 then
		for i = 1, numSkills do
			local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank = GetSkillLineInfo(i)
			if not isHeader and skillName then
				local canonName = (GSF.GetCanonicalProfession and GSF:GetCanonicalProfession(skillName)) or skillName
				if canonName and GSF.PROFESSIONS[canonName] then
					activeSkillNames[canonName] = true
					activeSkillNames[skillName] = true

					local existing = member.professions[canonName] or member.professions[skillName]
					if not existing then
						local recipes = {}
						if charSaved then
							if charSaved[canonName] and charSaved[canonName].recipes then
								recipes = charSaved[canonName].recipes
							elseif charSaved[skillName] and charSaved[skillName].recipes then
								recipes = charSaved[skillName].recipes
							end
						end
						member.professions[canonName] = {
							name = canonName,
							curRank = skillRank,
							maxRank = skillMaxRank,
							recipes = recipes,
						}
						-- Clean up duplicate non-canonical key if present
						if skillName ~= canonName and member.professions[skillName] then
							member.professions[skillName] = nil
						end
						hasChanges = true
					else
						-- Ensure canonical key is used
						if member.professions[skillName] and skillName ~= canonName then
							member.professions[canonName] = member.professions[skillName]
							member.professions[skillName] = nil
						end
						member.professions[canonName].name = canonName
						if (member.professions[canonName].curRank ~= skillRank) or (member.professions[canonName].maxRank ~= skillMaxRank) then
							member.professions[canonName].curRank = skillRank
							member.professions[canonName].maxRank = skillMaxRank
							hasChanges = true
						end
					end
				end
			end
		end

		-- Prune unlearned professions that are no longer active on this character
		for profName in pairs(member.professions) do
			local canonKey = (GSF.GetCanonicalProfession and GSF:GetCanonicalProfession(profName)) or profName
			if not activeSkillNames[profName] and not activeSkillNames[canonKey] then
				member.professions[profName] = nil
				if charSaved then
					if charSaved[profName] then charSaved[profName] = nil end
					if charSaved[canonKey] then charSaved[canonKey] = nil end
				end
				hasChanges = true
			end
		end

		-- Also clean up any abandoned professions in persistent character partition
		if charSaved then
			for profName in pairs(charSaved) do
				local canonKey = (GSF.GetCanonicalProfession and GSF:GetCanonicalProfession(profName)) or profName
				if not activeSkillNames[profName] and not activeSkillNames[canonKey] then
					charSaved[profName] = nil
					hasChanges = true
				end
			end
		end
	end

	if GSF.DB and GSF.DB.SyncActiveCharacterProfessions then
		GSF.DB:SyncActiveCharacterProfessions()
	end

	if hasChanges then
		GSF.cache.revisions.recipes = (GSF.cache.revisions.recipes or 0) + 1
		if GSF.Sync and GSF.isGuildScope then
			GSF.Sync:SendMyData()
		end
		if GSF.MainFrame and GSF.MainFrame:IsShown() then
			GSF.MainFrame:RefreshCurrentTab()
		end
	end
end
