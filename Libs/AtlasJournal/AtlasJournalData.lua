local MAJOR = "LibAtlasJournal-1.0"
local lib = (LibStub and LibStub:GetLibrary(MAJOR, true)) or AtlasJournal or {}
AtlasJournal = lib

-- ============================================================================
-- Category Definitions (Classic & TBC Resource Classifications)
-- ============================================================================
AtlasJournal.Categories = {
	{ key = "ALL", spellID = nil, icon = "Interface\\Icons\\INV_Misc_Book_09" },
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

AtlasJournal.Data = {
	-- ========================================================================
	-- 1. MINING (Ores, Stones, Raw Gems, Bar Precursors)
	-- ========================================================================
	{
		id = 2770, -- Copper Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 1, zones = { 12, 14, 1, 85, 215, 141, 148, 3430, 3524 } },
		},
		yields = { 2835, 774, 818 },
		tipKey = "ATLAS_TIP_2770",
	},
	{
		id = 2835, -- Rough Stone
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 2770 }, zones = { 12, 14, 1, 85, 215, 141, 148 } },
		},
		tipKey = "ATLAS_TIP_2835",
	},
	{
		id = 2771, -- Tin Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 65, zones = { 40, 38, 130, 148, 44, 267, 3433, 3525 } },
			{ type = "PROSPECT", spellID = 31252, skill = 20, fromItems = { 2771 } },
		},
		yields = { 2836, 1210, 1705, 1206 },
		tipKey = "ATLAS_TIP_2771",
	},
	{
		id = 2836, -- Coarse Stone
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 2771 }, zones = { 40, 38, 130, 148, 44, 267 } },
		},
		tipKey = "ATLAS_TIP_2836",
	},
	{
		id = 2775, -- Silver Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 75, zones = { 44, 11, 10, 331, 267 } },
			{ type = "PROSPECT", spellID = 31252, skill = 75, fromItems = { 2775 } },
		},
		yields = { 1210, 1705, 1206 },
		tipKey = "ATLAS_TIP_2775",
	},
	{
		id = 2772, -- Iron Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 125, zones = { 45, 400, 3, 405, 33 } },
			{ type = "PROSPECT", spellID = 31252, skill = 125, fromItems = { 2772 } },
		},
		yields = { 2838, 929, 1705, 3864 },
		tipKey = "ATLAS_TIP_2772",
	},
	{
		id = 2838, -- Heavy Stone
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 2772 }, zones = { 45, 400, 3, 405, 33 } },
		},
		tipKey = "ATLAS_TIP_2838",
	},
	{
		id = 2776, -- Gold Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 155, zones = { 45, 3, 33, 400, 357 } },
			{ type = "PROSPECT", spellID = 31252, skill = 155, fromItems = { 2776 } },
		},
		yields = { 929, 3864 },
		tipKey = "ATLAS_TIP_2776",
	},
	{
		id = 3858, -- Mithril Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 175, zones = { 3, 33, 440, 47, 357, 51 } },
			{ type = "PROSPECT", spellID = 31252, skill = 175, fromItems = { 3858 } },
		},
		yields = { 7912, 7909, 7910, 3864 },
		tipKey = "ATLAS_TIP_3858",
	},
	{
		id = 7912, -- Solid Stone
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 3858 }, zones = { 3, 33, 440, 47, 357, 51 } },
		},
		tipKey = "ATLAS_TIP_7912",
	},
	{
		id = 7911, -- Truesilver Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 230, zones = { 440, 357, 47, 361, 490, 618 } },
			{ type = "PROSPECT", spellID = 31252, skill = 225, fromItems = { 7911 } },
		},
		yields = { 7909, 7910 },
		tipKey = "ATLAS_TIP_7911",
	},
	{
		id = 11370, -- Dark Iron Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 230, zones = { 51, 4 } },
		},
		yields = { 11382 },
		tipKey = "ATLAS_TIP_11370",
	},
	{
		id = 10620, -- Thorium Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 245, zones = { 490, 618, 51, 139, 28, 440, 361 } },
			{ type = "PROSPECT", spellID = 31252, skill = 250, fromItems = { 10620 } },
		},
		yields = { 12365, 12799, 12361, 12364, 12800, 7910 },
		tipKey = "ATLAS_TIP_10620",
	},
	{
		id = 12365, -- Dense Stone
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 10620 }, zones = { 490, 618, 51, 139, 28, 361 } },
		},
		tipKey = "ATLAS_TIP_12365",
	},
	{
		id = 23424, -- Fel Iron Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 300, zones = { 3483, 3521, 3519, 3522, 3518, 3520 } },
			{ type = "PROSPECT", spellID = 31252, skill = 300, fromItems = { 23424 } },
		},
		yields = { 23077, 23079, 23107, 23112, 23117, 23436, 23437, 23438, 23439, 23440, 23441, 22573, 22574 },
		tipKey = "ATLAS_TIP_23424",
	},
	{
		id = 23425, -- Adamantite Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 325, zones = { 3518, 3522, 3519, 3523, 3520 } },
			{ type = "PROSPECT", spellID = 31252, skill = 325, fromItems = { 23425 } },
		},
		yields = { 23077, 23079, 23107, 23112, 23117, 23436, 23437, 23438, 23439, 23440, 23441, 24243, 22573 },
		tipKey = "ATLAS_TIP_23425",
	},
	{
		id = 23426, -- Khorium Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 375, zones = { 3518, 3520, 3523, 3522, 3519 } },
		},
		yields = { 23436, 23437, 23438, 23439, 23440, 23441, 22574 },
		tipKey = "ATLAS_TIP_23426",
	},
	{
		id = 23427, -- Eternium Ore
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 23425, 23426 }, zones = { 3518, 3520, 3523, 3522 } },
		},
		tipKey = "ATLAS_TIP_23427",
	},
	{
		id = 32468, -- Nethercite Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 350, zones = { 3520 } },
		},
		tipKey = "ATLAS_TIP_32468",
	},

	-- Raw Gems (TBC Rare & Prospecting)
	{
		id = 23436, -- Living Ruby
		category = "MINING",
		sources = {
			{ type = "PROSPECT", spellID = 31252, skill = 300, fromItems = { 23424, 23425 } },
			{ type = "BYPRODUCT", fromItems = { 23425, 23426 }, zones = { 3518, 3520, 3523, 3522 } },
		},
		tipKey = "ATLAS_TIP_23436",
	},
	{
		id = 23437, -- Talasite
		category = "MINING",
		sources = {
			{ type = "PROSPECT", spellID = 31252, skill = 300, fromItems = { 23424, 23425 } },
			{ type = "BYPRODUCT", fromItems = { 23425, 23426 }, zones = { 3518, 3520, 3523, 3522 } },
		},
		tipKey = "ATLAS_TIP_23437",
	},
	{
		id = 23438, -- Star of Elune
		category = "MINING",
		sources = {
			{ type = "PROSPECT", spellID = 31252, skill = 300, fromItems = { 23424, 23425 } },
			{ type = "BYPRODUCT", fromItems = { 23425, 23426 }, zones = { 3518, 3520, 3523, 3522 } },
		},
		tipKey = "ATLAS_TIP_23438",
	},
	{
		id = 23439, -- Noble Topaz
		category = "MINING",
		sources = {
			{ type = "PROSPECT", spellID = 31252, skill = 300, fromItems = { 23424, 23425 } },
			{ type = "BYPRODUCT", fromItems = { 23425, 23426 }, zones = { 3518, 3520, 3523, 3522 } },
		},
		tipKey = "ATLAS_TIP_23439",
	},
	{
		id = 23440, -- Dawnstone
		category = "MINING",
		sources = {
			{ type = "PROSPECT", spellID = 31252, skill = 300, fromItems = { 23424, 23425 } },
			{ type = "BYPRODUCT", fromItems = { 23425, 23426 }, zones = { 3518, 3520, 3523, 3522 } },
		},
		tipKey = "ATLAS_TIP_23440",
	},
	{
		id = 23441, -- Nightseye
		category = "MINING",
		sources = {
			{ type = "PROSPECT", spellID = 31252, skill = 300, fromItems = { 23424, 23425 } },
			{ type = "BYPRODUCT", fromItems = { 23425, 23426 }, zones = { 3518, 3520, 3523, 3522 } },
		},
		tipKey = "ATLAS_TIP_23441",
	},
	{
		id = 23077, -- Blood Garnet
		category = "MINING",
		sources = {
			{ type = "PROSPECT", spellID = 31252, skill = 300, fromItems = { 23424, 23425 } },
			{ type = "BYPRODUCT", fromItems = { 23424, 23425 }, zones = { 3483, 3518, 3521, 3522 } },
		},
		tipKey = "ATLAS_TIP_23077",
	},
	{
		id = 23079, -- Deep Peridot
		category = "MINING",
		sources = {
			{ type = "PROSPECT", spellID = 31252, skill = 300, fromItems = { 23424, 23425 } },
			{ type = "BYPRODUCT", fromItems = { 23424, 23425 }, zones = { 3483, 3518, 3521, 3522 } },
		},
		tipKey = "ATLAS_TIP_23079",
	},
	{
		id = 23107, -- Shadow Draenite
		category = "MINING",
		sources = {
			{ type = "PROSPECT", spellID = 31252, skill = 300, fromItems = { 23424, 23425 } },
			{ type = "BYPRODUCT", fromItems = { 23424, 23425 }, zones = { 3483, 3518, 3521, 3522 } },
		},
		tipKey = "ATLAS_TIP_23107",
	},
	{
		id = 23112, -- Golden Draenite
		category = "MINING",
		sources = {
			{ type = "PROSPECT", spellID = 31252, skill = 300, fromItems = { 23424, 23425 } },
			{ type = "BYPRODUCT", fromItems = { 23424, 23425 }, zones = { 3483, 3518, 3521, 3522 } },
		},
		tipKey = "ATLAS_TIP_23112",
	},
	{
		id = 23117, -- Azure Moonstone
		category = "MINING",
		sources = {
			{ type = "PROSPECT", spellID = 31252, skill = 300, fromItems = { 23424, 23425 } },
			{ type = "BYPRODUCT", fromItems = { 23424, 23425 }, zones = { 3483, 3518, 3521, 3522 } },
		},
		tipKey = "ATLAS_TIP_23117",
	},
	{
		id = 24243, -- Adamantite Powder
		category = "MINING",
		sources = {
			{ type = "PROSPECT", spellID = 31252, skill = 325, fromItems = { 23425 } },
		},
		tipKey = "ATLAS_TIP_24243",
	},

	-- ========================================================================
	-- 2. HERBALISM (Classic & TBC Herbs, Lotus, Byproducts)
	-- ========================================================================
	{
		id = 2447, -- Peacebloom
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 1, zones = { 12, 14, 1, 85, 215, 141, 3430, 3524 } },
		},
		tipKey = "ATLAS_TIP_2447",
	},
	{
		id = 765, -- Silverleaf
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 1, zones = { 12, 14, 1, 85, 215, 141, 3430, 3524 } },
		},
		tipKey = "ATLAS_TIP_765",
	},
	{
		id = 2449, -- Earthroot
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 15, zones = { 40, 14, 215, 38, 130, 44 } },
		},
		tipKey = "ATLAS_TIP_2449",
	},
	{
		id = 785, -- Mageroyal
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 50, zones = { 40, 38, 130, 148, 14, 44 } },
		},
		yields = { 2453 },
		tipKey = "ATLAS_TIP_785",
	},
	{
		id = 2450, -- Briarthorn
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 70, zones = { 40, 38, 130, 148, 44, 267 } },
		},
		yields = { 2453 },
		tipKey = "ATLAS_TIP_2450",
	},
	{
		id = 2453, -- Swiftthistle
		category = "HERBALISM",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 785, 2450 }, zones = { 40, 38, 130, 148, 44 } },
		},
		tipKey = "ATLAS_TIP_2453",
	},
	{
		id = 3820, -- Stranglekelp
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 85, zones = { 40, 148, 331, 11, 33 } },
		},
		tipKey = "ATLAS_TIP_3820",
	},
	{
		id = 2452, -- Bruiseweed
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 100, zones = { 44, 11, 10, 331, 267, 406 } },
		},
		tipKey = "ATLAS_TIP_2452",
	},
	{
		id = 3355, -- Wild Steelbloom
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 115, zones = { 45, 267, 331, 10, 400, 3 } },
		},
		tipKey = "ATLAS_TIP_3355",
	},
	{
		id = 3356, -- Grave Moss
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 120, zones = { 10, 405, 45, 11 } },
		},
		tipKey = "ATLAS_TIP_3356",
	},
	{
		id = 3357, -- Kingsblood
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 125, zones = { 45, 33, 267, 10, 11, 15, 400 } },
		},
		tipKey = "ATLAS_TIP_3357",
	},
	{
		id = 3358, -- Liferoot
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 150, zones = { 33, 11, 267, 45, 47 } },
		},
		tipKey = "ATLAS_TIP_3358",
	},
	{
		id = 3818, -- Fadeleaf
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 160, zones = { 33, 3, 45, 15, 357 } },
		},
		tipKey = "ATLAS_TIP_3818",
	},
	{
		id = 3821, -- Goldthorn
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 170, zones = { 33, 45, 47, 15, 357 } },
		},
		tipKey = "ATLAS_TIP_3821",
	},
	{
		id = 3369, -- Khadgar's Whisker
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 185, zones = { 33, 45, 47, 15, 357 } },
		},
		tipKey = "ATLAS_TIP_3369",
	},
	{
		id = 3819, -- Wintersbite
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 195, zones = { 41 } },
		},
		tipKey = "ATLAS_TIP_3819",
	},
	{
		id = 4625, -- Firebloom
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 205, zones = { 440, 51, 3, 4 } },
		},
		tipKey = "ATLAS_TIP_4625",
	},
	{
		id = 8831, -- Purple Lotus
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 210, zones = { 440, 357, 16, 47 } },
		},
		yields = { 8153 },
		tipKey = "ATLAS_TIP_8831",
	},
	{
		id = 8153, -- Wildvine
		category = "HERBALISM",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 8831 }, zones = { 440, 357, 16, 47 } },
			{ type = "MOB_DROP", mobType = "Trolls", mobLevel = "35-50", zones = { 33, 47 } },
		},
		tipKey = "ATLAS_TIP_8153",
	},
	{
		id = 8836, -- Arthas' Tears
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 220, zones = { 28, 139, 361 } },
		},
		tipKey = "ATLAS_TIP_8836",
	},
	{
		id = 8838, -- Sungrass
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 230, zones = { 357, 47, 16, 361, 490 } },
		},
		tipKey = "ATLAS_TIP_8838",
	},
	{
		id = 8839, -- Blindweed
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 235, zones = { 15, 33 } },
		},
		tipKey = "ATLAS_TIP_8839",
	},
	{
		id = 8845, -- Ghost Mushroom
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 245, zones = { 47, 361, 490 } },
		},
		tipKey = "ATLAS_TIP_8845",
	},
	{
		id = 8846, -- Gromsblood
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 250, zones = { 361, 405, 4, 3483 } },
		},
		tipKey = "ATLAS_TIP_8846",
	},
	{
		id = 13464, -- Golden Sansam
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 260, zones = { 490, 361, 357, 16 } },
		},
		tipKey = "ATLAS_TIP_13464",
	},
	{
		id = 13463, -- Dreamfoil
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 270, zones = { 361, 490, 16, 618 } },
		},
		tipKey = "ATLAS_TIP_13463",
	},
	{
		id = 13465, -- Mountain Silversage
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 280, zones = { 618, 490, 361, 139 } },
		},
		tipKey = "ATLAS_TIP_13465",
	},
	{
		id = 13466, -- Plaguebloom
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 285, zones = { 28, 139, 361 } },
		},
		tipKey = "ATLAS_TIP_13466",
	},
	{
		id = 13467, -- Icecap
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 290, zones = { 618 } },
		},
		tipKey = "ATLAS_TIP_13467",
	},
	{
		id = 13468, -- Black Lotus
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 300, zones = { 618, 490, 139, 51 } },
		},
		tipKey = "ATLAS_TIP_13468",
	},
	{
		id = 22785, -- Felweed
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 300, zones = { 3483, 3521, 3519, 3522, 3518, 3520 } },
		},
		yields = { 22794, 22575 },
		tipKey = "ATLAS_TIP_22785",
	},
	{
		id = 22786, -- Dreaming Glory
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 315, zones = { 3483, 3519, 3522, 3523 } },
		},
		yields = { 22794, 22576 },
		tipKey = "ATLAS_TIP_22786",
	},
	{
		id = 22787, -- Ragveil
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 325, zones = { 3521 } },
		},
		yields = { 22794 },
		tipKey = "ATLAS_TIP_22787",
	},
	{
		id = 22788, -- Flame Cap
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 335, zones = { 3521 } },
		},
		tipKey = "ATLAS_TIP_22788",
	},
	{
		id = 22789, -- Terocone
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 325, zones = { 3519 } },
		},
		yields = { 22794 },
		tipKey = "ATLAS_TIP_22789",
	},
	{
		id = 22790, -- Ancient Lichen
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 340, zones = { 3521, 3519 } },
		},
		yields = { 22794 },
		tipKey = "ATLAS_TIP_22790",
	},
	{
		id = 22791, -- Netherbloom
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 350, zones = { 3523 } },
		},
		yields = { 22794, 22576 },
		tipKey = "ATLAS_TIP_22791",
	},
	{
		id = 22792, -- Nightmare Vine
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 365, zones = { 3520 } },
		},
		yields = { 22794, 22575 },
		tipKey = "ATLAS_TIP_22792",
	},
	{
		id = 22793, -- Mana Thistle
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 375, zones = { 3518, 3519, 3522, 3523, 3520 } },
		},
		yields = { 22794, 22576 },
		tipKey = "ATLAS_TIP_22793",
	},
	{
		id = 22794, -- Fel Lotus
		category = "HERBALISM",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 22785, 22786, 22787, 22789, 22790, 22791, 22792, 22793 }, zones = { 3483, 3521, 3519, 3518, 3522, 3523, 3520 } },
		},
		tipKey = "ATLAS_TIP_22794",
	},

	-- ========================================================================
	-- 3. SKINNING & LEATHER
	-- ========================================================================
	{
		id = 2318, -- Light Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 1, zones = { 12, 14, 1, 85, 215, 148, 40 } },
		},
		tipKey = "ATLAS_TIP_2318",
	},
	{
		id = 2319, -- Medium Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 100, zones = { 40, 10, 44, 267, 331, 11 } },
		},
		tipKey = "ATLAS_TIP_2319",
	},
	{
		id = 4234, -- Heavy Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 150, zones = { 45, 400, 33, 15, 405 } },
		},
		tipKey = "ATLAS_TIP_4234",
	},
	{
		id = 4304, -- Thick Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 200, zones = { 33, 357, 47, 440, 490 } },
		},
		tipKey = "ATLAS_TIP_4304",
	},
	{
		id = 8170, -- Rugged Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 250, zones = { 490, 618, 361, 139, 28 } },
		},
		tipKey = "ATLAS_TIP_8170",
	},
	{
		id = 15415, -- Devilsaur Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 260, zones = { 490 } },
		},
		tipKey = "ATLAS_TIP_15415",
	},
	{
		id = 25707, -- Knothide Leather Scraps
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 300, zones = { 3483, 3521 } },
		},
		tipKey = "ATLAS_TIP_25707",
	},
	{
		id = 21887, -- Knothide Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 300, zones = { 3483, 3521, 3519, 3518, 3522 } },
			{ type = "COMBINE", count = 5, fromItem = 25707 },
		},
		tipKey = "ATLAS_TIP_21887",
	},
	{
		id = 25708, -- Thick Clefthoof Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 330, zones = { 3518, 3522 } },
		},
		tipKey = "ATLAS_TIP_25708",
	},
	{
		id = 25700, -- Fel Scales
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 340, zones = { 3483, 3520 } },
		},
		tipKey = "ATLAS_TIP_25700",
	},
	{
		id = 29539, -- Cobra Scales
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 350, zones = { 3518, 3520 } },
		},
		tipKey = "ATLAS_TIP_29539",
	},
	{
		id = 29547, -- Wind Scales
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 360, zones = { 3522 } },
		},
		tipKey = "ATLAS_TIP_29547",
	},
	{
		id = 29548, -- Nether Dragonscales
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 365, zones = { 3522, 3520, 3523 } },
		},
		tipKey = "ATLAS_TIP_29548",
	},

	-- ========================================================================
	-- 4. CLOTH (Humanoid Mob Farming)
	-- ========================================================================
	{
		id = 2589, -- Linen Cloth
		category = "CLOTH",
		sources = {
			{ type = "MOB_DROP", mobType = "Humanoid", mobLevel = "5-15", zones = { 12, 14, 1, 85, 40, 130 } },
		},
		tipKey = "ATLAS_TIP_2589",
	},
	{
		id = 2592, -- Wool Cloth
		category = "CLOTH",
		sources = {
			{ type = "MOB_DROP", mobType = "Humanoid", mobLevel = "15-25", zones = { 40, 38, 130, 44, 148, 331 } },
		},
		tipKey = "ATLAS_TIP_2592",
	},
	{
		id = 4306, -- Silk Cloth
		category = "CLOTH",
		sources = {
			{ type = "MOB_DROP", mobType = "Humanoid", mobLevel = "25-40", zones = { 267, 10, 45, 400, 33 } },
		},
		tipKey = "ATLAS_TIP_4306",
	},
	{
		id = 4338, -- Mageweave Cloth
		category = "CLOTH",
		sources = {
			{ type = "MOB_DROP", mobType = "Humanoid", mobLevel = "40-50", zones = { 440, 47, 357, 33, 405 } },
		},
		tipKey = "ATLAS_TIP_4338",
	},
	{
		id = 14047, -- Runecloth
		category = "CLOTH",
		sources = {
			{ type = "MOB_DROP", mobType = "Humanoid", mobLevel = "50-60", zones = { 139, 28, 361, 618, 4 } },
		},
		tipKey = "ATLAS_TIP_14047",
	},
	{
		id = 14256, -- Felcloth
		category = "CLOTH",
		sources = {
			{ type = "MOB_DROP", mobType = "Demon", mobLevel = "50-60", zones = { 361, 16, 4 } },
		},
		tipKey = "ATLAS_TIP_14256",
	},
	{
		id = 21877, -- Netherweave Cloth
		category = "CLOTH",
		sources = {
			{ type = "MOB_DROP", mobType = "Humanoid", mobLevel = "60-70", zones = { 3483, 3521, 3519, 3522, 3523, 3520 } },
		},
		tipKey = "ATLAS_TIP_21877",
	},

	-- ========================================================================
	-- 5. ELEMENTAL & PRIMALS (Mobs, Gas Clouds, Transmutes, Fishing)
	-- ========================================================================
	{
		id = 22574, -- Mote of Fire
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Elemental", mobLevel = "65-70", zones = { 3522, 3520 } },
			{ type = "EXTRACT", device = 23821, skill = 305, zones = { 3522, 3520 } },
			{ type = "BYPRODUCT", fromItems = { 23424, 23426 }, zones = { 3483, 3520 } },
		},
		yields = { 21884 },
		tipKey = "ATLAS_TIP_22574",
	},
	{
		id = 21884, -- Primal Fire
		category = "ELEMENTAL",
		sources = {
			{ type = "COMBINE", count = 10, fromItem = 22574 },
			{ type = "TRANSMUTE", spellID = 28567, cooldown = "20h", fromItems = { 21885 } },
		},
		tipKey = "ATLAS_TIP_21884",
	},
	{
		id = 22578, -- Mote of Water
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Elemental", mobLevel = "62-70", zones = { 3521, 3518 } },
			{ type = "FISH", skill = 350, school = "Pure Water", zones = { 3518, 3519 } },
			{ type = "EXTRACT", device = 23821, skill = 305, zones = { 3521 } },
		},
		yields = { 21885 },
		tipKey = "ATLAS_TIP_22578",
	},
	{
		id = 21885, -- Primal Water
		category = "ELEMENTAL",
		sources = {
			{ type = "COMBINE", count = 10, fromItem = 22578 },
		},
		tipKey = "ATLAS_TIP_21885",
	},
	{
		id = 22572, -- Mote of Air
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Elemental", mobLevel = "64-67", zones = { 3518, 3520 } },
			{ type = "EXTRACT", device = 23821, skill = 305, zones = { 3518 } },
		},
		yields = { 22451 },
		tipKey = "ATLAS_TIP_22572",
	},
	{
		id = 22451, -- Primal Air
		category = "ELEMENTAL",
		sources = {
			{ type = "COMBINE", count = 10, fromItem = 22572 },
		},
		tipKey = "ATLAS_TIP_22451",
	},
	{
		id = 22573, -- Mote of Earth
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Elemental", mobLevel = "64-67", zones = { 3518, 3522 } },
			{ type = "BYPRODUCT", fromItems = { 23424, 23425 }, zones = { 3483, 3518, 3522 } },
		},
		yields = { 22452 },
		tipKey = "ATLAS_TIP_22573",
	},
	{
		id = 22452, -- Primal Earth
		category = "ELEMENTAL",
		sources = {
			{ type = "COMBINE", count = 10, fromItem = 22573 },
		},
		tipKey = "ATLAS_TIP_22452",
	},
	{
		id = 22575, -- Mote of Life
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Bog Lord", mobLevel = "62-65", zones = { 3521 } },
			{ type = "EXTRACT", device = 23821, skill = 305, zones = { 3521 } },
			{ type = "BYPRODUCT", fromItems = { 22785, 22792 }, zones = { 3483, 3520 } },
		},
		yields = { 21886 },
		tipKey = "ATLAS_TIP_22575",
	},
	{
		id = 21886, -- Primal Life
		category = "ELEMENTAL",
		sources = {
			{ type = "COMBINE", count = 10, fromItem = 22575 },
		},
		tipKey = "ATLAS_TIP_21886",
	},
	{
		id = 22577, -- Mote of Shadow
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Demon", mobLevel = "64-70", zones = { 3483, 3518, 3523, 3520 } },
			{ type = "EXTRACT", device = 23821, skill = 305, zones = { 3520 } },
		},
		yields = { 22456 },
		tipKey = "ATLAS_TIP_22577",
	},
	{
		id = 22456, -- Primal Shadow
		category = "ELEMENTAL",
		sources = {
			{ type = "COMBINE", count = 10, fromItem = 22577 },
		},
		tipKey = "ATLAS_TIP_22456",
	},
	{
		id = 22576, -- Mote of Mana
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Mana Aberration", mobLevel = "67-70", zones = { 3523 } },
			{ type = "EXTRACT", device = 23821, skill = 305, zones = { 3523 } },
			{ type = "BYPRODUCT", fromItems = { 22786, 22791, 22793 }, zones = { 3523, 3519 } },
		},
		yields = { 22457 },
		tipKey = "ATLAS_TIP_22576",
	},
	{
		id = 22457, -- Primal Mana
		category = "ELEMENTAL",
		sources = {
			{ type = "COMBINE", count = 10, fromItem = 22576 },
		},
		tipKey = "ATLAS_TIP_22457",
	},
	{
		id = 23571, -- Primal Might
		category = "ELEMENTAL",
		sources = {
			{ type = "TRANSMUTE", spellID = 28566, cooldown = "20h", fromItems = { 22452, 21885, 22451, 21884, 22457 } },
		},
		tipKey = "ATLAS_TIP_23571",
	},
	{
		id = 23572, -- Primal Nether
		category = "ELEMENTAL",
		sources = {
			{ type = "INSTANCE", dungeon = "Heroic Dungeons (End Bosses)", raid = "Karazhan, Gruul, Magtheridon" },
			{ type = "VENDOR", cost = "10x Badges of Justice (G'eras, Shattrath)" },
		},
		tipKey = "ATLAS_TIP_23572",
	},
	{
		id = 30183, -- Nether Vortex
		category = "ELEMENTAL",
		sources = {
			{ type = "INSTANCE", raid = "Serpentshrine Cavern & Tempest Keep" },
			{ type = "VENDOR", cost = "15x Badges of Justice" },
		},
		tipKey = "ATLAS_TIP_30183",
	},

	-- ========================================================================
	-- 6. ENCHANTING (Disenchanting Tables)
	-- ========================================================================
	{
		id = 10940, -- Strange Dust
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "1-20" },
		},
		tipKey = "ATLAS_TIP_10940",
	},
	{
		id = 11083, -- Soul Dust
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "21-30" },
		},
		tipKey = "ATLAS_TIP_11083",
	},
	{
		id = 11137, -- Vision Dust
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "31-40" },
		},
		tipKey = "ATLAS_TIP_11137",
	},
	{
		id = 11176, -- Dream Dust
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "41-50" },
		},
		tipKey = "ATLAS_TIP_11176",
	},
	{
		id = 16204, -- Illusion Dust
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "51-60" },
		},
		tipKey = "ATLAS_TIP_16204",
	},
	{
		id = 22445, -- Arcane Dust
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "58-70" },
		},
		tipKey = "ATLAS_TIP_22445",
	},
	{
		id = 22447, -- Lesser Planar Essence
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "58-65" },
		},
		tipKey = "ATLAS_TIP_22447",
	},
	{
		id = 22446, -- Greater Planar Essence
		category = "ENCHANTING",
		sources = {
			{ type = "COMBINE", count = 3, fromItem = 22447 },
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "65-70" },
		},
		tipKey = "ATLAS_TIP_22446",
	},
	{
		id = 22448, -- Small Prismatic Shard
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 3, itemLevels = "58-66" },
		},
		tipKey = "ATLAS_TIP_22448",
	},
	{
		id = 22449, -- Large Prismatic Shard
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 3, itemLevels = "67-70" },
		},
		tipKey = "ATLAS_TIP_22449",
	},
	{
		id = 22450, -- Void Crystal
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 4, itemLevels = "100-141" },
		},
		tipKey = "ATLAS_TIP_22450",
	},
	{
		id = 20725, -- Nexus Crystal
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 4, itemLevels = "60-80" },
		},
		tipKey = "ATLAS_TIP_20725",
	},

	-- ========================================================================
	-- 7. COOKING MEATS & SPECIALIZED FISHING
	-- ========================================================================
	{
		id = 27671, -- Clefthoof Meat
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Clefthoof", mobLevel = "64-67", zones = { 3518, 3522 } },
		},
		tipKey = "ATLAS_TIP_27671",
	},
	{
		id = 27677, -- Ravager Flesh
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Ravager", mobLevel = "60-67", zones = { 3483, 3522 } },
		},
		tipKey = "ATLAS_TIP_27677",
	},
	{
		id = 27682, -- Talbuk Venison
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Talbuk", mobLevel = "64-66", zones = { 3518 } },
		},
		tipKey = "ATLAS_TIP_27682",
	},
	{
		id = 27681, -- Warpstalker Meat
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Warpstalker", mobLevel = "63-70", zones = { 3519, 3523 } },
		},
		tipKey = "ATLAS_TIP_27681",
	},
	{
		id = 27674, -- Basilisk Meat
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Basilisk", mobLevel = "63-67", zones = { 3519, 3522 } },
		},
		tipKey = "ATLAS_TIP_27674",
	},
	{
		id = 27432, -- Furious Crawdad
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 430, school = "Highland Mixed School", zones = { 3519 } },
		},
		tipKey = "ATLAS_TIP_27432",
	},
	{
		id = 27434, -- Golden Darter
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 355, school = "Highland Mixed School / River", zones = { 3519 } },
		},
		tipKey = "ATLAS_TIP_27434",
	},
	{
		id = 27431, -- Figlamp Fish
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 350, school = "Lake Pools", zones = { 3521, 3518 } },
		},
		tipKey = "ATLAS_TIP_27431",
	},
	{
		id = 27429, -- Zangarian Sporefish
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 320, school = "Sporefish School", zones = { 3521 } },
		},
		tipKey = "ATLAS_TIP_27429",
	},
	{
		id = 6370, -- Oily Blackmouth
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 100, school = "Oily Blackmouth School", zones = { 40, 148, 11, 33 } },
		},
		tipKey = "ATLAS_TIP_6370",
	},
	{
		id = 6371, -- Firefin Snapper
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 150, school = "Firefin Snapper School", zones = { 11, 45, 33, 440, 16 } },
		},
		tipKey = "ATLAS_TIP_6371",
	},
	{
		id = 13422, -- Stonescale Eel
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 205, school = "Stonescale Eel Swarm", zones = { 440, 357, 16 } },
		},
		tipKey = "ATLAS_TIP_13422",
	},
}
