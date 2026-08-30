local ADDON_NAME, GSF = ...

GSF.AtlasEngine = {}
local Engine = GSF.AtlasEngine

-- 1. Category Definitions
-- Maps category keys to native spell IDs or item classes for zero-string localization & trade skill icons
GSF.AtlasCategories = {
	{ key = "ALL", nameKey = "ALL", spellID = nil, icon = "Interface\\Icons\\INV_Misc_Book_09" },
	{ key = "MINING", spellID = 2575, icon = "Interface\\Icons\\Trade_Mining" },
	{ key = "HERBALISM", spellID = 2366, icon = "Interface\\Icons\\Trade_Herbalism" },
	{ key = "SKINNING", spellID = 8613, icon = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01" },
	{ key = "CLOTH", itemClass = 7, itemSubClass = 5, spellID = nil, icon = "Interface\\Icons\\INV_Fabric_Silk_02" },
	{ key = "ELEMENTAL", itemClass = 7, itemSubClass = 10, spellID = nil, icon = "Interface\\Icons\\Spell_Fire_FlameBlades" },
	{ key = "ENCHANTING", spellID = 13262, icon = "Interface\\Icons\\Spell_Holy_RemoveCurse" },
	{ key = "ENGINEERING", spellID = 4036, icon = "Interface\\Icons\\Trade_Engineering" },
	{ key = "COOKING", spellID = 2550, icon = "Interface\\Icons\\INV_Misc_Food_15" },
	{ key = "FISHING", spellID = 7620, icon = "Interface\\Icons\\Trade_Fishing" },
}

-- Category lookup table
local categoryMap = {}
for _, cat in ipairs(GSF.AtlasCategories) do
	categoryMap[cat.key] = cat
end

function Engine:GetCategoryInfo(catKey)
	local cat = categoryMap[catKey]
	if not cat then
		return catKey, "Interface\\Icons\\INV_Misc_QuestionMark"
	end

	local name = nil
	if cat.spellID then
		name = GetSpellInfo(cat.spellID)
	elseif cat.itemClass and cat.itemSubClass then
		name = GetItemSubClassInfo(cat.itemClass, cat.itemSubClass)
	elseif cat.nameKey and GSF.L and GSF.L[cat.nameKey] then
		name = GSF.L[cat.nameKey]
	end

	return name or catKey, cat.icon
end

-- 2. Zone Name Resolver (C_Map.GetAreaInfo)
local zoneNameCache = {}
function Engine:GetZoneName(areaID)
	if not areaID then return "" end
	if zoneNameCache[areaID] then
		return zoneNameCache[areaID]
	end

	local name = nil
	if C_Map and C_Map.GetAreaInfo then
		name = C_Map.GetAreaInfo(areaID)
	end

	if not name or name == "" then
		name = string.format("Zone #%d", areaID)
	else
		zoneNameCache[areaID] = name
	end

	return name
end

-- 3. Dynamic Item Details Resolver with Graceful Async Fallback
function Engine:GetItemDetails(itemID)
	if not itemID then return nil end
	local name, link, quality, _, _, _, _, _, _, icon = GetItemInfo(itemID)
	if name then
		return {
			name = name,
			link = link or string.format("|cffffffff[%s]|r", name),
			quality = quality or 1,
			icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark",
			loaded = true,
		}
	else
		-- Request client load
		if C_Item and C_Item.RequestLoadItemDataByID then
			C_Item.RequestLoadItemDataByID(itemID)
		end
		return {
			name = string.format(GSF.L["ITEM_LOADING"] or "Item #%d (Loading...)", itemID),
			link = string.format("|cff888888[Item #%d]|r", itemID),
			quality = 1,
			icon = "Interface\\Icons\\INV_Misc_QuestionMark",
			loaded = false,
		}
	end
end

-- 4. Pre-Flight Cache Priming
local catalogItemMap = {}
local isPrimed = false

function Engine:PrimeCatalogCache()
	if isPrimed or not GSF.AtlasData then return end
	isPrimed = true

	for _, entry in ipairs(GSF.AtlasData) do
		if entry.id then
			catalogItemMap[entry.id] = true
			if not select(1, GetItemInfo(entry.id)) then
				if C_Item and C_Item.RequestLoadItemDataByID then
					C_Item.RequestLoadItemDataByID(entry.id)
				end
			end
		end

		-- Also prime yields and source items
		if entry.yields then
			for _, yieldID in ipairs(entry.yields) do
				catalogItemMap[yieldID] = true
				if not select(1, GetItemInfo(yieldID)) and C_Item and C_Item.RequestLoadItemDataByID then
					C_Item.RequestLoadItemDataByID(yieldID)
				end
			end
		end

		if entry.sources then
			for _, src in ipairs(entry.sources) do
				if src.fromItems then
					for _, fId in ipairs(src.fromItems) do
						catalogItemMap[fId] = true
						if not select(1, GetItemInfo(fId)) and C_Item and C_Item.RequestLoadItemDataByID then
							C_Item.RequestLoadItemDataByID(fId)
						end
					end
				end
				if src.fromItem then
					catalogItemMap[src.fromItem] = true
					if not select(1, GetItemInfo(src.fromItem)) and C_Item and C_Item.RequestLoadItemDataByID then
						C_Item.RequestLoadItemDataByID(src.fromItem)
					end
				end
				if src.device then
					catalogItemMap[src.device] = true
					if not select(1, GetItemInfo(src.device)) and C_Item and C_Item.RequestLoadItemDataByID then
						C_Item.RequestLoadItemDataByID(src.device)
					end
				end
			end
		end
	end
end

-- 5. Asynchronous Event Listener & Reactive UI Refresh
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local refreshPending = false
local function TriggerDebouncedRefresh()
	if refreshPending then return end
	refreshPending = true
	C_Timer.After(0.25, function()
		refreshPending = false
		if GSF.TabAtlas and GSF.MainFrame and GSF.MainFrame:IsShown() and GSF.currentTab == "atlas" then
			if GSF.TabAtlas.RefreshResourceList then
				GSF.TabAtlas:RefreshResourceList()
			end
			if GSF.TabAtlas.selectedItem and GSF.TabAtlas.SetResource then
				GSF.TabAtlas:SetResource(GSF.TabAtlas.selectedItem)
			end
		end
	end)
end

eventFrame:SetScript("OnEvent", function(self, event, arg1)
	if event == "PLAYER_ENTERING_WORLD" then
		Engine:PrimeCatalogCache()
	elseif event == "GET_ITEM_INFO_RECEIVED" then
		local itemID = tonumber(arg1)
		if itemID and catalogItemMap[itemID] then
			TriggerDebouncedRefresh()
		end
	end
end)

-- 6. Cross-Discipline Category Filter
function Engine:MatchesCategory(entry, filterCat)
	if not filterCat or filterCat == "ALL" then
		return true
	end

	-- Direct category match
	if entry.category == filterCat then
		return true
	end

	-- Polymorphic source match
	if entry.sources then
		for _, src in ipairs(entry.sources) do
			if filterCat == "FISHING" and src.type == "FISH" then
				return true
			elseif filterCat == "ENGINEERING" and src.type == "EXTRACT" then
				return true
			elseif filterCat == "MINING" and (src.type == "GATHER" or src.type == "SMELT" or src.type == "PROSPECT") and entry.category == "MINING" then
				return true
			elseif filterCat == "HERBALISM" and src.type == "GATHER" and entry.category == "HERBALISM" then
				return true
			elseif filterCat == "ENCHANTING" and src.type == "DISENCHANT" then
				return true
			elseif filterCat == "ELEMENTAL" and (src.type == "TRANSMUTE" or src.type == "COMBINE" or src.type == "EXTRACT") and entry.category == "ELEMENTAL" then
				return true
			elseif filterCat == "COOKING" and (entry.category == "COOKING" or src.type == "FISH") then
				return true
			end
		end
	end

	return false
end

-- 7. Search Filter Across Item Name and Zone Names
function Engine:MatchesSearch(entry, searchText)
	if not searchText or searchText == "" then
		return true
	end

	local lowerSearch = searchText:lower():trim()

	-- Match item name
	local details = self:GetItemDetails(entry.id)
	if details and details.name and details.name:lower():find(lowerSearch, 1, true) then
		return true
	end

	-- Match zones
	if entry.sources then
		for _, src in ipairs(entry.sources) do
			if src.zones then
				for _, areaID in ipairs(src.zones) do
					local zName = self:GetZoneName(areaID)
					if zName and zName:lower():find(lowerSearch, 1, true) then
						return true
					end
				end
			end
		end
	end

	-- Match item ID directly if user typed a number
	if tostring(entry.id) == lowerSearch then
		return true
	end

	return false
end

-- 8. Public Interface (GSF.Atlas compatibility)
GSF.Atlas = GSF.AtlasEngine

function Engine:GetAll()
	return GSF.AtlasData or {}
end

function Engine:Search(query, category)
	local results = {}
	if not GSF.AtlasData then return results end
	for _, entry in ipairs(GSF.AtlasData) do
		if self:MatchesCategory(entry, category) and self:MatchesSearch(entry, query) then
			table.insert(results, entry)
		end
	end
	return results
end

function Engine:GetDisplayName(entry)
	if not entry then return "" end
	if type(entry) == "number" then
		local d = self:GetItemDetails(entry)
		return d and d.name or string.format("Item #%d", entry)
	end
	if entry.id then
		local d = self:GetItemDetails(entry.id)
		return d and d.name or string.format("Item #%d", entry.id)
	end
	return entry.name or ""
end

function Engine:GetItemDisplayName(entry)
	return self:GetDisplayName(entry)
end

function Engine:GetMinSkill(entry)
	if not entry or not entry.sources then return 1 end
	for _, src in ipairs(entry.sources) do
		if src.skill then return src.skill end
	end
	return 1
end

function Engine:FindResource(identifier)
	if not identifier or not GSF.AtlasData then return nil end
	local num = tonumber(identifier)
	if num then
		for _, entry in ipairs(GSF.AtlasData) do
			if entry.id == num then return entry end
		end
	end
	local lower = tostring(identifier):lower():trim()
	for _, entry in ipairs(GSF.AtlasData) do
		if tostring(entry.id) == lower then return entry end
		local d = self:GetItemDetails(entry.id)
		if d and d.name and d.name:lower() == lower then
			return entry
		end
	end
	return nil
end
