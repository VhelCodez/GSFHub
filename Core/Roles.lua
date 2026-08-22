local ADDON_NAME, GSF = ...

GSF.Roles = {}

function GSF.Roles:GetRolesForMember(memberName)
	if not memberName then return {} end
	local roles = {}

	local member = GSF.cache and GSF.cache.members and GSF.cache.members[memberName]
	local profs = member and member.professions or {}

	-- Check gatherer roles
	if profs["Mining"] and (profs["Mining"].curRank or 0) > 0 then
		table.insert(roles, GSF.ROLES.MINER)
	end

	if profs["Herbalism"] and (profs["Herbalism"].curRank or 0) > 0 then
		table.insert(roles, GSF.ROLES.HERBALIST)
	end

	if profs["Skinning"] and (profs["Skinning"].curRank or 0) > 0 then
		table.insert(roles, GSF.ROLES.SKINNER)
	end

	-- Check cooking / fishing
	if (profs["Fishing"] and (profs["Fishing"].curRank or 0) > 150) or (profs["Cooking"] and (profs["Cooking"].curRank or 0) > 150) then
		table.insert(roles, GSF.ROLES.ANGLER)
	end

	-- Check crafting & master crafter
	local isMasterCrafter = false
	local isCrafter = false
	for pName, pData in pairs(profs) do
		if pName ~= "Mining" and pName ~= "Herbalism" and pName ~= "Skinning" and pName ~= "Fishing" and pName ~= "First Aid" then
			local rank = pData.curRank or 0
			if rank >= 350 then
				isMasterCrafter = true
			elseif rank >= 75 then
				isCrafter = true
			end
		end
	end

	if isMasterCrafter then
		table.insert(roles, GSF.ROLES.MASTER_CRAFTER)
	elseif isCrafter then
		table.insert(roles, GSF.ROLES.CRAFTER)
	end

	return roles
end

function GSF.Roles:GetRoleBadgesString(memberName)
	local roles = self:GetRolesForMember(memberName)
	if #roles == 0 then return "" end

	local badges = {}
	for _, r in ipairs(roles) do
		local localizedName = GSF.L["ROLE_" .. r.name:upper():gsub("[ /]", "_")] or r.name
		table.insert(badges, string.format("|cff%s[%s]|r", r.color or "ffffff", localizedName))
	end

	return table.concat(badges, " ")
end
