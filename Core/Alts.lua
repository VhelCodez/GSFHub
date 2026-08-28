local ADDON_NAME, GSF = ...

GSF.Alts = {}

function GSF.Alts:GetMain(characterName)
	if not characterName then return "Unknown" end
	if GSF.cache and GSF.cache.alts and GSF.cache.alts[characterName] then
		return GSF.cache.alts[characterName]
	end
	return characterName
end

function GSF.Alts:SetMain(characterName, mainName)
	if not characterName or not mainName then return end
	if not GSF.cache.alts then
		GSF.cache.alts = {}
	end
	GSF.cache.alts[characterName] = mainName
	
	-- Update local member record if exists
	if GSF.cache.members[characterName] then
		GSF.cache.members[characterName].main = mainName
	end
end

function GSF.Alts:GetMyMain()
	local myName = GSF.DB:GetPlayerName()
	if GSF.db and GSF.db.mainCharacter and GSF.db.mainCharacter:trim() ~= "" then
		return GSF.db.mainCharacter:trim()
	end
	return self:GetMain(myName)
end

function GSF.Alts:SetMyMain(mainName)
	local myName = GSF.DB:GetPlayerName()
	mainName = (mainName and mainName:trim() ~= "") and mainName:trim() or myName
	GSF.db.mainCharacter = mainName
	self:SetMain(myName, mainName)
	
	-- Broadcast to guild
	if GSF.Sync then
		GSF.Sync:BroadcastAlt(myName, mainName)
	end
end

function GSF.Alts:GetFormattedName(characterName)
	local main = self:GetMain(characterName)
	if main and main ~= characterName and main ~= "" then
		return string.format("%s (|cff%s%s|r)", characterName, GSF.COLORS.GOLD, main)
	end
	return characterName
end

function GSF.Alts:GetAltsForMain(mainName)
	local alts = {}
	if not GSF.cache.alts then return alts end
	for alt, main in pairs(GSF.cache.alts) do
		if main == mainName then
			table.insert(alts, alt)
		end
	end
	return alts
end
