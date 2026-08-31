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

	local myName = GSF.DB:GetPlayerName()
	local member = GSF.DB:EnsureMemberRecord(myName)
	member.professions = member.professions or {}

	local numSkills = GetNumTradeSkills()
	if numSkills == 0 then return end

	local existing = member.professions[profName]
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
	if not existing or not existing.recipes then
		hasChanges = true
	elseif (existing.curRank ~= curRank) or (existing.maxRank ~= maxRank) or (existingCount ~= scannedCount) then
		hasChanges = true
	else
		for k in pairs(recipes) do
			if not existing.recipes[k] then
				hasChanges = true
				break
			end
		end
	end

	member.professions[profName] = {
		name = profName,
		curRank = curRank,
		maxRank = maxRank,
		lastScanned = time(),
		recipes = recipes,
	}

	if GSF.DB and GSF.DB.SyncActiveCharacterProfessions then
		GSF.DB:SyncActiveCharacterProfessions()
	elseif GSF.db and GSF.db.characterProfessions then
		GSF.db.characterProfessions[profName] = member.professions[profName]
	end

	if hasChanges or isManual then
		GSF.cache.revisions.recipes = (GSF.cache.revisions.recipes or 0) + 1
		GSF.Addon:Printf(GSF.L["SCAN_SUCCESS"], scannedCount, profName, curRank, maxRank)

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

	local myName = GSF.DB:GetPlayerName()
	local member = GSF.DB:EnsureMemberRecord(myName)
	member.professions = member.professions or {}

	local numCrafts = GetNumCrafts()
	if numCrafts == 0 then return end

	local existing = member.professions[craftName]
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
	if not existing or not existing.recipes then
		hasChanges = true
	elseif ((existing.curRank or 0) ~= (curRank or 0)) or ((existing.maxRank or 0) ~= (maxRank or 375)) or (existingCount ~= scannedCount) then
		hasChanges = true
	else
		for k in pairs(recipes) do
			if not existing.recipes[k] then
				hasChanges = true
				break
			end
		end
	end

	member.professions[craftName] = {
		name = craftName,
		curRank = curRank or 0,
		maxRank = maxRank or 375,
		lastScanned = time(),
		recipes = recipes,
	}

	if GSF.DB and GSF.DB.SyncActiveCharacterProfessions then
		GSF.DB:SyncActiveCharacterProfessions()
	elseif GSF.db and GSF.db.characterProfessions then
		GSF.db.characterProfessions[craftName] = member.professions[craftName]
	end

	if hasChanges or isManual then
		GSF.cache.revisions.recipes = (GSF.cache.revisions.recipes or 0) + 1
		GSF.Addon:Printf(GSF.L["SCAN_SUCCESS"], scannedCount, craftName, curRank or 0, maxRank or 375)

		if GSF.Sync then
			GSF.Sync:SendMyData()
		end
	end
end

function GSF.Scanner:ScanSkillLines()
	local myName = GSF.DB:GetPlayerName()
	local member = GSF.DB:EnsureMemberRecord(myName)
	member.professions = member.professions or {}

	local numSkills = GetNumSkillLines()
	for i = 1, numSkills do
		local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank = GetSkillLineInfo(i)
		if not isHeader and skillName and GSF.PROFESSIONS[skillName] then
			if not member.professions[skillName] then
				member.professions[skillName] = {
					name = skillName,
					curRank = skillRank,
					maxRank = skillMaxRank,
					recipes = {},
				}
			else
				member.professions[skillName].curRank = skillRank
				member.professions[skillName].maxRank = skillMaxRank
			end
		end
	end
end
