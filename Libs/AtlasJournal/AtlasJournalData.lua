local MAJOR = "LibAtlasJournal-1.1"
local AtlasJournal = (LibStub and LibStub(MAJOR, true)) or AtlasJournal
if not AtlasJournal then
	AtlasJournal = {}
	if _G then _G.AtlasJournal = AtlasJournal end
end

-- ============================================================================
-- ATLAS JOURNAL MASTER RESOURCE DATA
-- Categorized trade goods, materials, gathering nodes, and acquisition data.
-- ============================================================================
AtlasJournal.Categories = {
	{ key = "ALL",        name = "All Categories",        icon = "Interface\\Icons\\INV_Misc_Book_09" },
	{ key = "MINING",     name = "Mining & Gems",         icon = "Interface\\Icons\\Trade_Mining",          spellID = 2575 },
	{ key = "HERBALISM",  name = "Herbalism",             icon = "Interface\\Icons\\Trade_Herbalism",       spellID = 2366 },
	{ key = "SKINNING",   name = "Skinning & Leather",    icon = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01", spellID = 8613 },
	{ key = "CLOTH",      name = "Cloth",                 icon = "Interface\\Icons\\INV_Fabric_Silk_02" },
	{ key = "ELEMENTAL",  name = "Elemental & Primals",   icon = "Interface\\Icons\\Spell_Fire_ElementalDevastation" },
	{ key = "ENCHANTING", name = "Enchanting Materials",  icon = "Interface\\Icons\\Trade_Engraving",       spellID = 7411 },
	{ key = "COOKING",    name = "Cooking & Meats",       icon = "Interface\\Icons\\INV_Misc_Food_15",      spellID = 2550 },
	{ key = "FISHING",    name = "Fishing",               icon = "Interface\\Icons\\Trade_Fishing",         spellID = 7620 },
}

for _, cat in ipairs(AtlasJournal.Categories) do
	AtlasJournal.Categories[cat.key] = cat
end

AtlasJournal.Data = {
	-- ========================================================================
	-- 1. MINING & GEMS (Classic & TBC Ores, Stones, Prospecting Gems)
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
		id = 2771, -- Tin Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 65, zones = { 40, 38, 130, 148, 44, 267, 3433, 3525 } },
		},
		yields = { 2836, 1210, 1705, 1206 },
		tipKey = "ATLAS_TIP_2771",
	},
{
		id = 2775, -- Silver Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 75, zones = { 44, 11, 10, 331, 267 } },
		},
		yields = { 1210, 1705, 1206 },
		tipKey = "ATLAS_TIP_2775",
	},
{
		id = 2772, -- Iron Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 125, zones = { 45, 400, 3, 405, 33 } },
		},
		yields = { 2838, 1529, 1705, 3864 },
		tipKey = "ATLAS_TIP_2772",
	},
{
		id = 2776, -- Gold Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 155, zones = { 45, 3, 33, 400, 357 } },
		},
		yields = { 1529, 1705, 3864 },
		tipKey = "ATLAS_TIP_2776",
	},
{
		id = 3858, -- Mithril Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 175, zones = { 3, 33, 440, 47, 357, 51 } },
		},
		yields = { 7912, 3864, 7909, 7910 },
		tipKey = "ATLAS_TIP_3858",
	},
{
		id = 7911, -- Truesilver Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 230, zones = { 440, 357, 47, 361, 490, 618 } },
		},
		yields = { 3864, 7909, 7910 },
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
		},
		yields = { 12365, 7910, 12799, 12364, 12361, 12800, 12363 },
		tipKey = "ATLAS_TIP_10620",
	},
{
		id = 18562, -- Elementium Ore
		category = "MINING",
		sources = {
			{ type = "MOB_DROP", mobType = "Blackwing Technician", mobLevel = "60+", zones = { 469 } },
		},
		tipKey = "ATLAS_TIP_18562",
	},
{
		id = 23424, -- Fel Iron Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 300, zones = { 3483, 3521, 3519, 3522, 3518, 3520 } },
		},
		yields = { 22573, 23077, 23079, 23107, 23112, 23117, 21929 },
		tipKey = "ATLAS_TIP_23424",
	},
{
		id = 23425, -- Adamantite Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 325, zones = { 3518, 3522, 3519, 3523, 3520 } },
		},
		yields = { 23427, 22573, 23077, 23079, 23107, 23112, 23117, 21929, 23436, 23437, 23438, 23439, 23440, 23441 },
		tipKey = "ATLAS_TIP_23425",
	},
{
		id = 32464, -- Nethercite Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 350, zones = { 3520 } },
		},
		tipKey = "ATLAS_TIP_32464",
	},
{
		id = 23426, -- Khorium Ore
		category = "MINING",
		sources = {
			{ type = "GATHER", skill = 375, zones = { 3518, 3520, 3523, 3522, 3519 } },
		},
		yields = { 23427, 22574, 22573, 23436, 23437, 23438, 23439, 23440, 23441 },
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
		id = 2835, -- Rough Stone
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 2770 }, zones = { 12, 14, 1, 85, 215, 141, 148 } },
		},
		tipKey = "ATLAS_TIP_2835",
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
		id = 2838, -- Heavy Stone
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 2772 }, zones = { 45, 400, 3, 405, 33 } },
		},
		tipKey = "ATLAS_TIP_2838",
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
		id = 12365, -- Dense Stone
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 10620 }, zones = { 490, 618, 51, 139, 28, 361 } },
		},
		tipKey = "ATLAS_TIP_12365",
	},
{
		id = 774, -- Malachite
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 2770 } },
			{ type = "PROSPECT", spellID = 31252, skill = 20, fromItems = { 2770, 2771 } },
		},
		tipKey = "ATLAS_TIP_774",
	},
{
		id = 818, -- Tigerseye
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 2770 } },
			{ type = "PROSPECT", spellID = 31252, skill = 20, fromItems = { 2770, 2771 } },
		},
		tipKey = "ATLAS_TIP_818",
	},
{
		id = 1210, -- Shadowgem
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 2771, 2775 } },
			{ type = "PROSPECT", spellID = 31252, skill = 75, fromItems = { 2771, 2775 } },
		},
		tipKey = "ATLAS_TIP_1210",
	},
{
		id = 1705, -- Lesser Moonstone
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 2771, 2775, 2772 } },
			{ type = "PROSPECT", spellID = 31252, skill = 75, fromItems = { 2771, 2775, 2772 } },
		},
		tipKey = "ATLAS_TIP_1705",
	},
{
		id = 1206, -- Moss Agate
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 2771, 2775 } },
			{ type = "PROSPECT", spellID = 31252, skill = 75, fromItems = { 2771, 2775, 2772 } },
		},
		tipKey = "ATLAS_TIP_1206",
	},
{
		id = 1529, -- Jade
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 2772, 2776 } },
			{ type = "PROSPECT", spellID = 31252, skill = 125, fromItems = { 2772, 2776, 3858 } },
		},
		tipKey = "ATLAS_TIP_1529",
	},
{
		id = 3864, -- Citrine
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 2772, 2776, 3858 } },
			{ type = "PROSPECT", spellID = 31252, skill = 125, fromItems = { 2772, 2776, 3858 } },
		},
		tipKey = "ATLAS_TIP_3864",
	},
{
		id = 7909, -- Aquamarine
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 3858, 7911 } },
			{ type = "PROSPECT", spellID = 31252, skill = 175, fromItems = { 3858, 7911, 10620 } },
		},
		tipKey = "ATLAS_TIP_7909",
	},
{
		id = 7910, -- Star Ruby
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 3858, 7911, 10620 } },
			{ type = "PROSPECT", spellID = 31252, skill = 175, fromItems = { 3858, 7911, 10620 } },
		},
		tipKey = "ATLAS_TIP_7910",
	},
{
		id = 12799, -- Large Opal
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 10620 } },
			{ type = "PROSPECT", spellID = 31252, skill = 250, fromItems = { 10620 } },
		},
		tipKey = "ATLAS_TIP_12799",
	},
{
		id = 12364, -- Huge Emerald
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 10620 } },
			{ type = "PROSPECT", spellID = 31252, skill = 250, fromItems = { 10620 } },
		},
		tipKey = "ATLAS_TIP_12364",
	},
{
		id = 12361, -- Blue Sapphire
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 10620 } },
			{ type = "PROSPECT", spellID = 31252, skill = 250, fromItems = { 10620 } },
		},
		tipKey = "ATLAS_TIP_12361",
	},
{
		id = 12800, -- Azerothian Diamond
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 10620 } },
			{ type = "PROSPECT", spellID = 31252, skill = 250, fromItems = { 10620 } },
		},
		tipKey = "ATLAS_TIP_12800",
	},
{
		id = 12363, -- Arcane Crystal
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 10620 }, zones = { 490, 618, 51, 139 } },
		},
		tipKey = "ATLAS_TIP_12363",
	},
{
		id = 11382, -- Blood of the Mountain
		category = "MINING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 11370 }, zones = { 51, 4 } },
		},
		tipKey = "ATLAS_TIP_11382",
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
		id = 21929, -- Flame Spessarite
		category = "MINING",
		sources = {
			{ type = "PROSPECT", spellID = 31252, skill = 300, fromItems = { 23424, 23425 } },
			{ type = "BYPRODUCT", fromItems = { 23424, 23425 }, zones = { 3483, 3518, 3521, 3522 } },
		},
		tipKey = "ATLAS_TIP_21929",
	},
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
		id = 24243, -- Adamantite Powder
		category = "MINING",
		sources = {
			{ type = "PROSPECT", spellID = 31252, skill = 325, fromItems = { 23425 } },
		},
		tipKey = "ATLAS_TIP_24243",
	},
{
		id = 25867, -- Earthstorm Diamond
		category = "MINING",
		sources = {
			{ type = "TRANSMUTE", spellID = 32765, cooldown = "20h", fromItems = { 23079, 23107, 23112, 22452, 21885 } },
		},
		tipKey = "ATLAS_TIP_25867",
	},
{
		id = 25868, -- Skyfire Diamond
		category = "MINING",
		sources = {
			{ type = "TRANSMUTE", spellID = 32766, cooldown = "20h", fromItems = { 23077, 21929, 23117, 21884, 22451 } },
		},
		tipKey = "ATLAS_TIP_25868",
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
		yields = { 2452 },
		tipKey = "ATLAS_TIP_785",
	},
{
		id = 2450, -- Briarthorn
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 70, zones = { 40, 38, 130, 148, 44, 267 } },
		},
		yields = { 2452 },
		tipKey = "ATLAS_TIP_2450",
	},
{
		id = 2452, -- Swiftthistle
		category = "HERBALISM",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 785, 2450 }, zones = { 40, 38, 130, 148, 44 } },
		},
		tipKey = "ATLAS_TIP_2452",
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
		id = 2453, -- Bruiseweed
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 100, zones = { 44, 11, 10, 331, 267, 406 } },
		},
		tipKey = "ATLAS_TIP_2453",
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
		id = 3369, -- Grave Moss
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 120, zones = { 10, 405, 45, 11 } },
		},
		tipKey = "ATLAS_TIP_3369",
	},
{
		id = 3356, -- Kingsblood
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 125, zones = { 45, 33, 267, 10, 11, 15, 400 } },
		},
		tipKey = "ATLAS_TIP_3356",
	},
{
		id = 3357, -- Liferoot
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 150, zones = { 33, 11, 267, 45, 47 } },
		},
		tipKey = "ATLAS_TIP_3357",
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
		id = 3358, -- Khadgar's Whisker
		category = "HERBALISM",
		sources = {
			{ type = "GATHER", skill = 185, zones = { 33, 45, 47, 15, 357 } },
		},
		tipKey = "ATLAS_TIP_3358",
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
		yields = { 22576, 22794 },
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
	-- 3. SKINNING & LEATHER (Hides, Scales, Exotic Leathers)
	-- ========================================================================
{
		id = 2934, -- Ruined Leather Scraps
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 1, zones = { 12, 14, 1, 85, 215, 141 } },
		},
		tipKey = "ATLAS_TIP_2934",
	},
	{
		id = 2318, -- Light Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 1, zones = { 12, 14, 1, 85, 215, 148, 40 } },
			{ type = "CRAFT", spellID = 2881, skill = 1, count = 3, fromItems = { 2934 } },
		},
		yields = { 783 },
		tipKey = "ATLAS_TIP_2318",
	},
{
		id = 783, -- Light Hide
		category = "SKINNING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 2318 }, zones = { 12, 14, 1, 85, 215, 141 } },
		},
		tipKey = "ATLAS_TIP_783",
	},
	{
		id = 2319, -- Medium Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 100, zones = { 40, 10, 44, 267, 331, 11 } },
			{ type = "CRAFT", spellID = 7126, skill = 100, count = 4, fromItems = { 2318 } },
		},
		yields = { 4232 },
		tipKey = "ATLAS_TIP_2319",
	},
{
		id = 4232, -- Medium Hide
		category = "SKINNING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 2319 }, zones = { 40, 38, 130, 148, 267, 10 } },
		},
		tipKey = "ATLAS_TIP_4232",
	},
	{
		id = 4234, -- Heavy Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 150, zones = { 45, 400, 33, 15, 405 } },
			{ type = "CRAFT", spellID = 7127, skill = 150, count = 5, fromItems = { 2319 } },
		},
		yields = { 4235 },
		tipKey = "ATLAS_TIP_4234",
	},
{
		id = 4235, -- Heavy Hide
		category = "SKINNING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 4234 }, zones = { 45, 33, 3, 405, 400 } },
		},
		tipKey = "ATLAS_TIP_4235",
	},
	{
		id = 4304, -- Thick Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 200, zones = { 33, 357, 47, 440, 490 } },
			{ type = "CRAFT", spellID = 7128, skill = 200, count = 6, fromItems = { 4234 } },
		},
		yields = { 8169 },
		tipKey = "ATLAS_TIP_4304",
	},
{
		id = 8169, -- Thick Hide
		category = "SKINNING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 4304 }, zones = { 357, 440, 47, 33, 490 } },
		},
		tipKey = "ATLAS_TIP_8169",
	},
	{
		id = 8170, -- Rugged Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 250, zones = { 490, 618, 361, 139, 28 } },
			{ type = "CRAFT", spellID = 10668, skill = 250, count = 6, fromItems = { 4304 } },
		},
		yields = { 8171 },
		tipKey = "ATLAS_TIP_8170",
	},
{
		id = 8171, -- Rugged Hide
		category = "SKINNING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 8170 }, zones = { 490, 618, 28, 139 } },
		},
		tipKey = "ATLAS_TIP_8171",
	},
{
		id = 15417, -- Devilsaur Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 260, zones = { 490 } },
		},
		tipKey = "ATLAS_TIP_15417",
	},
{
		id = 8167, -- Turtle Scale
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 175, zones = { 440, 47, 357 } },
		},
		tipKey = "ATLAS_TIP_8167",
	},
{
		id = 17012, -- Core Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 310, zones = { 409 } },
		},
		tipKey = "ATLAS_TIP_17012",
	},
{
		id = 15414, -- Red Dragonscale
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 240, zones = { 11 } },
		},
		tipKey = "ATLAS_TIP_15414",
	},
{
		id = 15412, -- Green Dragonscale
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 250, zones = { 1477, 8 } },
		},
		tipKey = "ATLAS_TIP_15412",
	},
{
		id = 15415, -- Blue Dragonscale
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 260, zones = { 618, 16 } },
		},
		tipKey = "ATLAS_TIP_15415",
	},
{
		id = 15416, -- Black Dragonscale
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 275, zones = { 29, 1583 } },
		},
		tipKey = "ATLAS_TIP_15416",
	},
{
		id = 15419, -- Warbear Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 275, zones = { 28, 139 } },
		},
		tipKey = "ATLAS_TIP_15419",
	},
{
		id = 25649, -- Knothide Leather Scraps
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 300, zones = { 3483, 3521 } },
		},
		tipKey = "ATLAS_TIP_25649",
	},
	{
		id = 21887, -- Knothide Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 300, zones = { 3483, 3521, 3519, 3518, 3522 } },
			{ type = "CRAFT", spellID = 32454, skill = 300, count = 5, fromItems = { 25649 } },
		},
		yields = { 25707 },
		tipKey = "ATLAS_TIP_21887",
	},
	{
		id = 23793, -- Heavy Knothide Leather
		category = "SKINNING",
		sources = {
			{ type = "CRAFT", spellID = 28590, skill = 325, count = 5, fromItems = { 21887 } },
		},
		tipKey = "ATLAS_TIP_23793",
	},
	{
		id = 25707, -- Fel Hide
		category = "SKINNING",
		sources = {
			{ type = "BYPRODUCT", fromItems = { 21887 }, zones = { 3483, 3520 } },
			{ type = "MOB_DROP", mobType = "Demons / Outland Elites", mobLevel = "65-70", zones = { 3483, 3520 } },
		},
		tipKey = "ATLAS_TIP_25707",
	},
{
		id = 25699, -- Crystal-Infused Leather
		category = "SKINNING",
		sources = {
			{ type = "GATHER", skill = 350, zones = { 3522 } },
		},
		tipKey = "ATLAS_TIP_25699",
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
	-- 4. CLOTH (Humanoid Mob Farming, Specialized Tailoring Cloths)
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
		id = 14342, -- Mooncloth
		category = "CLOTH",
		sources = {
			{ type = "TRANSMUTE", spellID = 18560, cooldown = "4d", fromItems = { 14256 } },
		},
		tipKey = "ATLAS_TIP_14342",
	},
{
		id = 21877, -- Netherweave Cloth
		category = "CLOTH",
		sources = {
			{ type = "MOB_DROP", mobType = "Humanoid", mobLevel = "60-70", zones = { 3483, 3521, 3519, 3522, 3523, 3520 } },
		},
		tipKey = "ATLAS_TIP_21877",
	},
{
		id = 21845, -- Primal Mooncloth
		category = "CLOTH",
		sources = {
			{ type = "TRANSMUTE", spellID = 26751, cooldown = "3d 20h", fromItems = { 21877, 21885, 21886 } },
		},
		tipKey = "ATLAS_TIP_21845",
	},
{
		id = 24271, -- Spellcloth
		category = "CLOTH",
		sources = {
			{ type = "TRANSMUTE", spellID = 31373, cooldown = "3d 20h", fromItems = { 21877, 21884, 22457 } },
		},
		tipKey = "ATLAS_TIP_24271",
	},
{
		id = 24272, -- Shadowcloth
		category = "CLOTH",
		sources = {
			{ type = "TRANSMUTE", spellID = 36686, cooldown = "3d 20h", fromItems = { 21877, 21884, 22456 } },
		},
		tipKey = "ATLAS_TIP_24272",
	},
	-- ========================================================================
	-- 5. ELEMENTAL & PRIMALS (Mobs, Gas Clouds, Transmutes, Fishing)
	-- ========================================================================
{
		id = 7067, -- Elemental Earth
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Earth Elemental", mobLevel = "35-45", zones = { 3, 45, 400 } },
		},
		tipKey = "ATLAS_TIP_7067",
	},
{
		id = 7068, -- Elemental Fire
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Fire Elemental", mobLevel = "35-55", zones = { 51, 490, 45 } },
		},
		tipKey = "ATLAS_TIP_7068",
	},
{
		id = 7069, -- Elemental Air
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Air Elemental", mobLevel = "35-58", zones = { 1377, 45 } },
		},
		tipKey = "ATLAS_TIP_7069",
	},
{
		id = 7070, -- Elemental Water
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Water Elemental", mobLevel = "35-55", zones = { 361, 33, 45 } },
		},
		tipKey = "ATLAS_TIP_7070",
	},
{
		id = 7075, -- Core of Earth
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Greater Earth Elemental", mobLevel = "45-55", zones = { 3, 1377, 2100 } },
		},
		tipKey = "ATLAS_TIP_7075",
	},
{
		id = 7076, -- Essence of Earth
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Earth Elemental", mobLevel = "50-60", zones = { 1377, 490 } },
			{ type = "TRANSMUTE", spellID = 17560, cooldown = "24h", fromItems = { 7080 } },
		},
		tipKey = "ATLAS_TIP_7076",
	},
{
		id = 7077, -- Heart of Fire
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Greater Fire Elemental", mobLevel = "50-60", zones = { 409, 51, 29 } },
		},
		tipKey = "ATLAS_TIP_7077",
	},
{
		id = 7078, -- Essence of Fire
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Fire Elemental", mobLevel = "50-60", zones = { 409, 490, 51 } },
			{ type = "TRANSMUTE", spellID = 17561, cooldown = "24h", fromItems = { 7076 } },
		},
		tipKey = "ATLAS_TIP_7078",
	},
{
		id = 7079, -- Globe of Water
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Greater Water Elemental", mobLevel = "45-55", zones = { 139, 361 } },
		},
		tipKey = "ATLAS_TIP_7079",
	},
{
		id = 7080, -- Essence of Water
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Water Elemental", mobLevel = "50-60", zones = { 139, 361 } },
			{ type = "TRANSMUTE", spellID = 17559, cooldown = "24h", fromItems = { 7082 } },
		},
		tipKey = "ATLAS_TIP_7080",
	},
{
		id = 7081, -- Breath of Wind
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Greater Air Elemental", mobLevel = "45-58", zones = { 1377, 28 } },
		},
		tipKey = "ATLAS_TIP_7081",
	},
{
		id = 7082, -- Essence of Air
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Air Elemental", mobLevel = "55-60", zones = { 1377 } },
			{ type = "TRANSMUTE", spellID = 17562, cooldown = "24h", fromItems = { 7078 } },
		},
		tipKey = "ATLAS_TIP_7082",
	},
{
		id = 12803, -- Essence of Life
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Living Creature / Treant", mobLevel = "50-60", zones = { 361, 490, 139 } },
			{ type = "TRANSMUTE", spellID = 17565, cooldown = "24h", fromItems = { 12808 } },
		},
		tipKey = "ATLAS_TIP_12803",
	},
{
		id = 12808, -- Essence of Undeath
		category = "ELEMENTAL",
		sources = {
			{ type = "MOB_DROP", mobType = "Undead Scourge", mobLevel = "50-60", zones = { 139, 28, 2017, 2057 } },
			{ type = "TRANSMUTE", spellID = 17563, cooldown = "24h", fromItems = { 7080 } },
		},
		tipKey = "ATLAS_TIP_12808",
	},
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
	-- 6. ENCHANTING (Disenchanting Tables, Dusts, Essences, Shards)
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
		id = 10938, -- Lesser Magic Essence
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "1-10" },
			{ type = "COMBINE", count = 1, fromItem = 10939 },
		},
		tipKey = "ATLAS_TIP_10938",
	},
{
		id = 10939, -- Greater Magic Essence
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "11-15" },
			{ type = "COMBINE", count = 3, fromItem = 10938 },
		},
		tipKey = "ATLAS_TIP_10939",
	},
{
		id = 10998, -- Lesser Astral Essence
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "16-20" },
			{ type = "COMBINE", count = 1, fromItem = 11082 },
		},
		tipKey = "ATLAS_TIP_10998",
	},
{
		id = 11082, -- Greater Astral Essence
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "21-25" },
			{ type = "COMBINE", count = 3, fromItem = 10998 },
		},
		tipKey = "ATLAS_TIP_11082",
	},
{
		id = 11134, -- Lesser Mystic Essence
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "26-30" },
			{ type = "COMBINE", count = 1, fromItem = 11135 },
		},
		tipKey = "ATLAS_TIP_11134",
	},
{
		id = 11135, -- Greater Mystic Essence
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "31-35" },
			{ type = "COMBINE", count = 3, fromItem = 11134 },
		},
		tipKey = "ATLAS_TIP_11135",
	},
{
		id = 11174, -- Lesser Nether Essence
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "36-40" },
			{ type = "COMBINE", count = 1, fromItem = 11175 },
		},
		tipKey = "ATLAS_TIP_11174",
	},
{
		id = 11175, -- Greater Nether Essence
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "41-45" },
			{ type = "COMBINE", count = 3, fromItem = 11174 },
		},
		tipKey = "ATLAS_TIP_11175",
	},
{
		id = 16202, -- Lesser Eternal Essence
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "46-50" },
			{ type = "COMBINE", count = 1, fromItem = 16203 },
		},
		tipKey = "ATLAS_TIP_16202",
	},
{
		id = 16203, -- Greater Eternal Essence
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 2, itemLevels = "51-60" },
			{ type = "COMBINE", count = 3, fromItem = 16202 },
		},
		tipKey = "ATLAS_TIP_16203",
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
		id = 10978, -- Small Glimmering Shard
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 3, itemLevels = "15-20" },
		},
		tipKey = "ATLAS_TIP_10978",
	},
{
		id = 11084, -- Large Glimmering Shard
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 3, itemLevels = "21-25" },
		},
		tipKey = "ATLAS_TIP_11084",
	},
{
		id = 11138, -- Small Glowing Shard
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 3, itemLevels = "26-30" },
		},
		tipKey = "ATLAS_TIP_11138",
	},
{
		id = 11139, -- Large Glowing Shard
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 3, itemLevels = "31-35" },
		},
		tipKey = "ATLAS_TIP_11139",
	},
{
		id = 11177, -- Small Radiant Shard
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 3, itemLevels = "36-40" },
		},
		tipKey = "ATLAS_TIP_11177",
	},
{
		id = 11178, -- Large Radiant Shard
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 3, itemLevels = "41-45" },
		},
		tipKey = "ATLAS_TIP_11178",
	},
{
		id = 14343, -- Small Brilliant Shard
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 3, itemLevels = "46-50" },
		},
		tipKey = "ATLAS_TIP_14343",
	},
	{
		id = 14344, -- Large Brilliant Shard
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 3, itemLevels = "51-60" },
			{ type = "CRAFT", spellID = 17172, skill = 250, count = 3, fromItems = { 14343 } },
		},
		tipKey = "ATLAS_TIP_14344",
	},
{
		id = 20725, -- Nexus Crystal
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 4, itemLevels = "60-80" },
		},
		tipKey = "ATLAS_TIP_20725",
	},
	{
		id = 22448, -- Small Prismatic Shard
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 3, itemLevels = "58-66" },
			{ type = "CRAFT", spellID = 42615, skill = 335, count = 1, yieldCount = 3, fromItems = { 22449 } },
		},
		tipKey = "ATLAS_TIP_22448",
	},
	{
		id = 22449, -- Large Prismatic Shard
		category = "ENCHANTING",
		sources = {
			{ type = "DISENCHANT", spellID = 13262, itemQuality = 3, itemLevels = "67-70" },
			{ type = "CRAFT", spellID = 28022, skill = 335, count = 3, fromItems = { 22448 } },
			{ type = "CRAFT", spellID = 45765, skill = 375, count = 1, yieldCount = 2, fromItems = { 22450 } },
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
	-- ========================================================================
	-- 7. COOKING & MEATS (Beasts, Birds, Specialized Cooking Reagents)
	-- ========================================================================
{
		id = 6889, -- Small Egg
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Beast / Birds", mobLevel = "1-12", zones = { 12, 40, 215, 3430 } },
		},
		tipKey = "ATLAS_TIP_6889",
	},
{
		id = 2672, -- Stringy Wolf Meat
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Wolves", mobLevel = "1-10", zones = { 12, 1, 85 } },
		},
		tipKey = "ATLAS_TIP_2672",
	},
{
		id = 769, -- Chunk of Boar Meat
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Boars", mobLevel = "1-12", zones = { 12, 1, 14, 215 } },
		},
		tipKey = "ATLAS_TIP_769",
	},
{
		id = 3173, -- Bear Meat
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Bears", mobLevel = "10-20", zones = { 38, 148, 130 } },
		},
		tipKey = "ATLAS_TIP_3173",
	},
{
		id = 3730, -- Big Bear Meat
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Bears", mobLevel = "25-40", zones = { 267, 331, 357 } },
		},
		tipKey = "ATLAS_TIP_3730",
	},
{
		id = 12184, -- Raptor Flesh
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Raptors", mobLevel = "30-45", zones = { 45, 33 } },
		},
		tipKey = "ATLAS_TIP_12184",
	},
{
		id = 12202, -- Tiger Meat
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Tigers", mobLevel = "30-45", zones = { 33 } },
		},
		tipKey = "ATLAS_TIP_12202",
	},
{
		id = 12208, -- Tender Wolf Meat
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Wolves", mobLevel = "40-55", zones = { 47, 361 } },
		},
		tipKey = "ATLAS_TIP_12208",
	},
{
		id = 20424, -- Sandworm Meat
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Silithid / Sandworms", mobLevel = "55-60", zones = { 1377 } },
		},
		tipKey = "ATLAS_TIP_20424",
	},
{
		id = 4655, -- Giant Clam Meat
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Coastal Murlocs / Nagas", mobLevel = "30-60", zones = { 440, 357, 33 } },
		},
		tipKey = "ATLAS_TIP_4655",
	},
	{
		id = 27671, -- Buzzard Meat
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Buzzards", mobLevel = "58-65", zones = { 3483, 3519 } },
		},
		tipKey = "ATLAS_TIP_27671",
	},
	{
		id = 27674, -- Ravager Flesh
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Ravagers", mobLevel = "60-67", zones = { 3483, 3522 } },
		},
		tipKey = "ATLAS_TIP_27674",
	},
	{
		id = 27677, -- Chunk of Basilisk Meat
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Basilisks", mobLevel = "63-67", zones = { 3519, 3522 } },
		},
		tipKey = "ATLAS_TIP_27677",
	},
{
		id = 27678, -- Clefthoof Meat
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Clefthoof", mobLevel = "64-67", zones = { 3518, 3522 } },
		},
		tipKey = "ATLAS_TIP_27678",
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
		id = 27682, -- Talbuk Venison
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Talbuk", mobLevel = "64-66", zones = { 3518 } },
		},
		tipKey = "ATLAS_TIP_27682",
	},
{
		id = 31671, -- Serpent Flesh
		category = "COOKING",
		sources = {
			{ type = "MOB_DROP", mobType = "Serpents & Scalewings", mobLevel = "65-70", zones = { 3522, 3523 } },
		},
		tipKey = "ATLAS_TIP_31671",
	},
{
		id = 24477, -- Jaggal Clam Meat
		category = "COOKING",
		sources = {
			{ type = "FISH", skill = 300, school = "Jaggal Clam / Fishing", zones = { 3521 } },
		},
		tipKey = "ATLAS_TIP_24477",
	},
	-- ========================================================================
	-- 8. FISHING (Classic & TBC Fish, Schools, Swarms, Alchemical Catches)
	-- ========================================================================
{
		id = 6291, -- Raw Brilliant Smallfish
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 1, school = "Open Water", zones = { 12, 14, 1, 85, 215, 141 } },
		},
		tipKey = "ATLAS_TIP_6291",
	},
{
		id = 6289, -- Raw Longjaw Mud Snapper
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 1, school = "Inland Waters", zones = { 12, 14, 40, 38, 130, 148 } },
		},
		tipKey = "ATLAS_TIP_6289",
	},
{
		id = 6303, -- Raw Slitherskin Mackerel
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 1, school = "Coastal Waters", zones = { 40, 148, 130, 14 } },
		},
		tipKey = "ATLAS_TIP_6303",
	},
{
		id = 6308, -- Raw Bristle Whisker Catfish
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 100, school = "Inland Waters", zones = { 267, 10, 11, 44, 331 } },
		},
		tipKey = "ATLAS_TIP_6308",
	},
{
		id = 6317, -- Raw Loch Frenzy
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 50, school = "Loch Modan Waters", zones = { 38 } },
		},
		tipKey = "ATLAS_TIP_6317",
	},
{
		id = 6361, -- Raw Rainbow Fin Albacore
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 80, school = "Coastal Waters", zones = { 40, 148, 11, 267, 17 } },
		},
		tipKey = "ATLAS_TIP_6361",
	},
{
		id = 6362, -- Raw Rockscale Cod
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 150, school = "Coastal Waters", zones = { 33, 440, 357, 405, 267 } },
		},
		tipKey = "ATLAS_TIP_6362",
	},
{
		id = 4603, -- Raw Spotted Yellowtail
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 225, school = "Coastal Waters", zones = { 440, 357, 16, 33 } },
		},
		tipKey = "ATLAS_TIP_4603",
	},
{
		id = 8364, -- Raw Mithril Head Trout
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 175, school = "Inland Waters", zones = { 33, 357, 47, 361, 28 } },
		},
		tipKey = "ATLAS_TIP_8364",
	},
{
		id = 13754, -- Raw Glossy Mightfish
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 275, school = "Ocean Waters", zones = { 16, 357, 440 } },
		},
		tipKey = "ATLAS_TIP_13754",
	},
{
		id = 13755, -- Winter Squid
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 250, school = "Ocean Waters (Winter / Deep Sea)", zones = { 16, 357, 440 } },
		},
		tipKey = "ATLAS_TIP_13755",
	},
{
		id = 13756, -- Raw Summer Bass
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 250, school = "Ocean Waters (Summer)", zones = { 16, 357, 440, 33 } },
		},
		tipKey = "ATLAS_TIP_13756",
	},
{
		id = 13758, -- Raw Redgill
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 205, school = "Inland Waters", zones = { 139, 361, 28 } },
		},
		tipKey = "ATLAS_TIP_13758",
	},
{
		id = 13759, -- Raw Nightfin Snapper
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 205, school = "Nightfin Snapper Swarm (18:00 - 06:00)", zones = { 357, 493, 361, 490 } },
		},
		tipKey = "ATLAS_TIP_13759",
	},
{
		id = 13760, -- Raw Sunscale Salmon
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 205, school = "Sunscale Salmon Swarm (06:00 - 18:00)", zones = { 357, 47, 361, 490 } },
		},
		tipKey = "ATLAS_TIP_13760",
	},
{
		id = 13889, -- Raw Whitescale Salmon
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 300, school = "Inland Waters", zones = { 618, 139 } },
		},
		tipKey = "ATLAS_TIP_13889",
	},
{
		id = 6522, -- Deviate Fish
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 90, school = "Deviate Fish Swarm", zones = { 17, 718 } },
		},
		tipKey = "ATLAS_TIP_6522",
	},
{
		id = 6358, -- Oily Blackmouth
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 100, school = "Oily Blackmouth School", zones = { 40, 148, 11, 33 } },
		},
		tipKey = "ATLAS_TIP_6358",
	},
{
		id = 6359, -- Firefin Snapper
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 150, school = "Firefin Snapper School", zones = { 11, 45, 33, 440, 16 } },
		},
		tipKey = "ATLAS_TIP_6359",
	},
{
		id = 13422, -- Stonescale Eel
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 205, school = "Stonescale Eel Swarm", zones = { 440, 357, 16 } },
		},
		tipKey = "ATLAS_TIP_13422",
	},
{
		id = 27422, -- Barbed Gill Trout
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 325, school = "Inland Waters", zones = { 3521, 3519 } },
		},
		tipKey = "ATLAS_TIP_27422",
	},
{
		id = 27425, -- Spotted Feltail
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 300, school = "Spotted Feltail School", zones = { 3483, 3521, 3519, 3518 } },
		},
		tipKey = "ATLAS_TIP_27425",
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
		id = 27435, -- Figlamp Fish
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 350, school = "Lake Pools", zones = { 3518 } },
		},
		tipKey = "ATLAS_TIP_27435",
	},
{
		id = 27437, -- Icefin Bluefish
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 375, school = "Bluefish School", zones = { 3518, 3523 } },
		},
		tipKey = "ATLAS_TIP_27437",
	},
{
		id = 27438, -- Golden Darter
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 375, school = "Highland Mixed School / River", zones = { 3519 } },
		},
		tipKey = "ATLAS_TIP_27438",
	},
{
		id = 27439, -- Furious Crawdad
		category = "FISHING",
		sources = {
			{ type = "FISH", skill = 430, school = "Highland Mixed School", zones = { 3519 } },
		},
		tipKey = "ATLAS_TIP_27439",
	},
}
