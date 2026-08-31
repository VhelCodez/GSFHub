local ADDON_NAME, GSF = ...

GSF.RecipeBook = {}

function GSF.RecipeBook:Search(searchText, profFilter, onlineOnly)
	local results = {}
	local seen = {}
	searchText = (searchText or ""):lower():trim()

	if not GSF.cache or not GSF.cache.members then
		return results
	end

	local isAll = (not profFilter) or (profFilter == "") or (profFilter:upper() == "ALL") or (GSF.L and profFilter == GSF.L["FILTER_ALL_PROFESSIONS"])
	local canonFilter = (not isAll) and GSF:GetCanonicalProfession(profFilter) or nil

	for memberName, memberData in pairs(GSF.cache.members) do
		local isOnline = (time() - (memberData.lastSeen or 0)) < 900 -- 15 mins considered online
		if not onlineOnly or isOnline then
			if memberData.professions then
				for profName, profData in pairs(memberData.professions) do
					local canonProf = GSF:GetCanonicalProfession(profName)
					if not canonFilter or canonProf == canonFilter then
						if profData.recipes then
							for key, recipe in pairs(profData.recipes) do
								local matches = false
								if searchText == "" then
									matches = true
								else
									-- Search recipe name
									if (recipe.name or ""):lower():find(searchText, 1, true) then
										matches = true
									-- Search reagents
									elseif recipe.reagents then
										for _, rg in ipairs(recipe.reagents) do
											if (rg.name or ""):lower():find(searchText, 1, true) then
												matches = true
												break
											end
										end
									end
								end

								if matches then
									local uid = profName .. ":" .. (recipe.name or key)
									if not seen[uid] then
										seen[uid] = {
											name = recipe.name,
											key = key,
											profession = profName,
											itemLink = recipe.itemLink,
											recipeLink = recipe.recipeLink,
											reagents = recipe.reagents or {},
											crafters = {},
										}
										table.insert(results, seen[uid])
									end

									table.insert(seen[uid].crafters, {
										name = memberName,
										main = GSF.Alts:GetMain(memberName),
										skill = profData.curRank or 0,
										maxSkill = profData.maxRank or 375,
										online = isOnline,
									})
								end
							end
						end
					end
				end
			end
		end
	end

	-- Sort alphabetical
	table.sort(results, function(a, b)
		if a.profession == b.profession then
			return (a.name or "") < (b.name or "")
		end
		return a.profession < b.profession
	end)

	return results
end

function GSF.RecipeBook:GetCraftersForSpell(spellId, recipeName, profession)
	local crafters = {}
	if not GSF.cache or not GSF.cache.members then return crafters end

	for memberName, memberData in pairs(GSF.cache.members) do
		local isOnline = (time() - (memberData.lastSeen or 0)) < 900
		if memberData.professions then
			for profName, profData in pairs(memberData.professions) do
				if not profession or profName == profession then
					if profData.recipes then
						local hasRecipe = false
						if spellId and profData.recipes[spellId] then
							hasRecipe = true
						elseif recipeName then
							for _, r in pairs(profData.recipes) do
								if r.name == recipeName then
									hasRecipe = true
									break
								end
							end
						end

						if hasRecipe then
							table.insert(crafters, {
								name = memberName,
								main = GSF.Alts:GetMain(memberName),
								skill = profData.curRank or 0,
								online = isOnline,
							})
						end
					end
				end
			end
		end
	end

	return crafters
end

function GSF.RecipeBook:WhoNeedsRecipe(recipeItemLink, profession)
	local needs = {}
	local canLearn = {}
	if not GSF.cache or not GSF.cache.members then return needs, canLearn end

	local recipeName = GetItemInfo(recipeItemLink) or recipeItemLink

	for memberName, memberData in pairs(GSF.cache.members) do
		if memberData.professions and memberData.professions[profession] then
			local prof = memberData.professions[profession]
			local alreadyKnows = false
			for _, r in pairs(prof.recipes or {}) do
				if (r.name and recipeName:find(r.name, 1, true)) or (r.itemLink and r.itemLink == recipeItemLink) then
					alreadyKnows = true
					break
				end
			end

			if not alreadyKnows then
				table.insert(canLearn, memberName)
			end
		end
	end

	return canLearn
end
