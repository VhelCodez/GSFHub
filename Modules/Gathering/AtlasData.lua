local ADDON_NAME, GSF = ...

GSF.Atlas = {}

local ATLAS_DB = {
	-- MINING (Skill 1 - 375)
	{
		name = "Copper Vein",
		itemID = 2770, -- Copper Ore
		category = "Mining",
		minSkill = 1,
		icon = "Interface\\Icons\\INV_Ore_Copper_01",
		zones = { "Elwynn Forest", "Durotar", "Dun Morogh", "Tirisfal Glades", "Mulgore", "Darkshore" },
		yields = "Copper Ore, Rough Stone, Malachite, Tigerseye",
		tips = "Common in all starting zones along foothills and cave entrances."
	},
	{
		name = "Tin Vein",
		itemID = 2771, -- Tin Ore
		category = "Mining",
		minSkill = 65,
		icon = "Interface\\Icons\\INV_Ore_Tin_01",
		zones = { "Westfall", "Loch Modan", "Silverpine Forest", "Darkshore", "Redridge Mountains", "Hillsbrad Foothills" },
		yields = "Tin Ore, Coarse Stone, Lesser Moonstone, Shadowgem",
		tips = "Abundant around gnoll and murloc camps in level 15-25 zones."
	},
	{
		name = "Silver Vein",
		itemID = 2775, -- Silver Ore
		category = "Mining",
		minSkill = 75,
		icon = "Interface\\Icons\\INV_Ore_Silver_01",
		zones = { "Redridge Mountains", "Wetlands", "Duskwood", "Ashenvale", "Hillsbrad Foothills" },
		yields = "Silver Ore, Lesser Moonstone, Shadowgem",
		tips = "Rare spawn replacing Tin Veins."
	},
	{
		name = "Iron Deposit",
		itemID = 2772, -- Iron Ore
		category = "Mining",
		minSkill = 125,
		icon = "Interface\\Icons\\INV_Ore_Iron_01",
		zones = { "Arathi Highlands", "Thousand Needles", "Badlands", "Desolace", "Stranglethorn Vale" },
		yields = "Iron Ore, Heavy Stone, Jade, Lesser Moonstone",
		tips = "Arathi Highlands perimeter and Badlands valley are the most efficient loops."
	},
	{
		name = "Gold Vein",
		itemID = 2776, -- Gold Ore
		category = "Mining",
		minSkill = 155,
		icon = "Interface\\Icons\\INV_Ore_Gold_01",
		zones = { "Badlands", "Arathi Highlands", "Stranglethorn Vale", "Feralas" },
		yields = "Gold Ore, Jade, Lesser Moonstone, Citrine",
		tips = "Rare spawn replacing Iron Deposits."
	},
	{
		name = "Mithril Deposit",
		itemID = 3858, -- Mithril Ore
		category = "Mining",
		minSkill = 175,
		icon = "Interface\\Icons\\INV_Ore_Mithril_02",
		zones = { "Badlands", "Tanaris", "Searing Gorge", "The Hinterlands", "Felwood", "Western Plaguelands" },
		yields = "Mithril Ore, Solid Stone, Aquamarine, Citrine, Star Ruby",
		tips = "Badlands outer canyon and Tanaris desert perimeter have highest density."
	},
	{
		name = "Truesilver Deposit",
		itemID = 7911, -- Truesilver Ore
		category = "Mining",
		minSkill = 230,
		icon = "Interface\\Icons\\INV_Ore_TrueSilver_01",
		zones = { "Winterspring", "Western Plaguelands", "Eastern Plaguelands", "Tanaris", "Searing Gorge" },
		yields = "Truesilver Ore, Star Ruby, Aquamarine",
		tips = "Rare spawn replacing Mithril Deposits and Small Thorium."
	},
	{
		name = "Small Thorium Vein",
		itemID = 10620, -- Thorium Ore
		category = "Mining",
		minSkill = 245,
		icon = "Interface\\Icons\\INV_Ore_Thorium_01",
		zones = { "Un'Goro Crater", "Felwood", "Winterspring", "Burning Steppes", "Western Plaguelands" },
		yields = "Thorium Ore, Dense Stone, Blue Sapphire, Star Ruby, Large Opal",
		tips = "Un'Goro Crater inner and outer rim loops are ideal for 245-275."
	},
	{
		name = "Rich Thorium Vein",
		itemID = 10620, -- Thorium Ore
		category = "Mining",
		minSkill = 275,
		icon = "Interface\\Icons\\INV_Ore_Thorium_02",
		zones = { "Winterspring", "Eastern Plaguelands", "Silithus", "Burning Steppes", "Un'Goro Crater" },
		yields = "Thorium Ore, Arcane Crystal, Dense Stone, Azerothian Diamond, Blue Sapphire",
		tips = "Winterspring caves and Silithus hive tunnels yield valuable Arcane Crystals."
	},
	{
		name = "Dark Iron Deposit",
		itemID = 11370, -- Dark Iron Ore
		category = "Mining",
		minSkill = 230,
		icon = "Interface\\Icons\\INV_Ore_Iron_01",
		zones = { "Blackrock Depths", "Molten Core", "Searing Gorge", "Burning Steppes" },
		yields = "Dark Iron Ore, Black Vitriol, Blood of the Mountain",
		tips = "Found inside Blackrock Mountain instances and lava beds."
	},
	{
		name = "Fel Iron Deposit",
		itemID = 23424, -- Fel Iron Ore
		category = "Mining",
		minSkill = 300,
		icon = "Interface\\Icons\\INV_Ore_FelIron",
		zones = { "Hellfire Peninsula", "Zangarmarsh", "Terokkar Forest", "Blade's Edge Mountains" },
		yields = "Fel Iron Ore, Mote of Fire, Mote of Earth, Lesser Moonstone",
		tips = "Hellfire Peninsula perimeter boundary provides the fastest 300-325 route."
	},
	{
		name = "Adamantite Deposit",
		itemID = 23425, -- Adamantite Ore
		category = "Mining",
		minSkill = 325,
		icon = "Interface\\Icons\\INV_Ore_Adamantite",
		zones = { "Nagrand", "Terokkar Forest", "Blade's Edge Mountains", "Netherstorm", "Shadowmoon Valley" },
		yields = "Adamantite Ore, Mote of Earth, Adamantite Powder",
		tips = "Nagrand mountain ranges and Blade's Edge canyons offer endless nodes."
	},
	{
		name = "Rich Adamantite Deposit",
		itemID = 23425, -- Adamantite Ore
		category = "Mining",
		minSkill = 350,
		icon = "Interface\\Icons\\INV_Ore_Adamantite",
		zones = { "Nagrand", "Shadowmoon Valley", "Netherstorm", "Blade's Edge Mountains" },
		yields = "Adamantite Ore, Mote of Earth, Rare Gems (Dawnstone, Talasite, Living Ruby)",
		tips = "Spawns in caves, plateaus, and high-level 68-70 Outland areas."
	},
	{
		name = "Khorium Vein",
		itemID = 23426, -- Khorium Ore
		category = "Mining",
		minSkill = 375,
		icon = "Interface\\Icons\\INV_Ore_Khorium",
		zones = { "Nagrand", "Netherstorm", "Shadowmoon Valley", "Blade's Edge Mountains", "Terokkar Forest" },
		yields = "Khorium Ore, Mote of Fire, Primal Might components",
		tips = "Rare spawn replacing Adamantite Deposits. Highly sought after for endgame crafts."
	},
	{
		name = "Nethercite Deposit",
		itemID = 32468, -- Nethercite Ore
		category = "Mining",
		minSkill = 350,
		icon = "Interface\\Icons\\INV_Misc_Gem_Crystal_02",
		zones = { "Shadowmoon Valley (Netherwing Ledge)" },
		yields = "Nethercite Ore (Netherwing Reputation)",
		tips = "Located on floating islands around Netherwing Ledge."
	},

	-- HERBALISM (Skill 1 - 375)
	{
		name = "Peacebloom",
		itemID = 2447,
		category = "Herbalism",
		minSkill = 1,
		icon = "Interface\\Icons\\INV_Misc_Herb_08",
		zones = { "Elwynn Forest", "Durotar", "Dun Morogh", "Tirisfal Glades", "Mulgore", "Teldrassil" },
		yields = "Peacebloom",
		tips = "Found in open grassy plains in all starting zones."
	},
	{
		name = "Silverleaf",
		itemID = 765,
		category = "Herbalism",
		minSkill = 1,
		icon = "Interface\\Icons\\INV_Misc_Herb_10",
		zones = { "Elwynn Forest", "Durotar", "Dun Morogh", "Tirisfal Glades", "Mulgore", "Teldrassil" },
		yields = "Silverleaf",
		tips = "Spawns near tree bases and forest bushes in starting areas."
	},
	{
		name = "Earthroot",
		itemID = 2449,
		category = "Herbalism",
		minSkill = 15,
		icon = "Interface\\Icons\\INV_Misc_Herb_07",
		zones = { "Westfall", "Loch Modan", "Silverpine Forest", "Darkshore", "Barrens", "Redridge" },
		yields = "Earthroot",
		tips = "Spawns along rock cliffs, hill ridges, and mountains."
	},
	{
		name = "Mageroyal",
		itemID = 785,
		category = "Herbalism",
		minSkill = 50,
		icon = "Interface\\Icons\\INV_Misc_Herb_12",
		zones = { "Westfall", "Loch Modan", "Silverpine Forest", "Darkshore", "Barrens", "Redridge" },
		yields = "Mageroyal",
		tips = "Found across lowlands and farming plains in level 10-20 zones."
	},
	{
		name = "Briarthorn",
		itemID = 2450,
		category = "Herbalism",
		minSkill = 70,
		icon = "Interface\\Icons\\INV_Misc_Herb_14",
		zones = { "Duskwood", "Redridge Mountains", "Silverpine Forest", "Barrens", "Loch Modan" },
		yields = "Briarthorn",
		tips = "Spawns under thick trees and wooden fences."
	},
	{
		name = "Stranglekelp",
		itemID = 3820,
		category = "Herbalism",
		minSkill = 85,
		icon = "Interface\\Icons\\INV_Misc_Herb_11",
		zones = { "Wetlands", "Westfall Coast", "Darkshore", "Stranglethorn Vale", "Hillsbrad Coast" },
		yields = "Stranglekelp",
		tips = "Grows entirely underwater along sea coasts and lake beds."
	},
	{
		name = "Bruiseweed",
		itemID = 2452,
		category = "Herbalism",
		minSkill = 100,
		icon = "Interface\\Icons\\INV_Misc_Herb_01",
		zones = { "Ashenvale", "Stonetalon Mountains", "Hillsbrad Foothills", "Wetlands", "Redridge" },
		yields = "Bruiseweed",
		tips = "Common near buildings, camps, and ruined walls."
	},
	{
		name = "Wild Steelbloom",
		itemID = 3355,
		category = "Herbalism",
		minSkill = 115,
		icon = "Interface\\Icons\\INV_Misc_Herb_09",
		zones = { "Arathi Highlands", "Stonetalon Mountains", "Badlands", "Stranglethorn Vale", "Thousand Needles" },
		yields = "Wild Steelbloom",
		tips = "Spawns on high cliffs, plateaus, and mountain tops."
	},
	{
		name = "Grave Moss",
		itemID = 3369,
		category = "Herbalism",
		minSkill = 120,
		icon = "Interface\\Icons\\INV_Misc_Dust_02",
		zones = { "Duskwood", "Desolace", "Scarlet Monastery (Graveyard)", "Western Plaguelands" },
		yields = "Grave Moss",
		tips = "Spawns inside cemeteries, crypts, and undead tombs. Crucial for Shadow Protection potions."
	},
	{
		name = "Kingsblood",
		itemID = 3356,
		category = "Herbalism",
		minSkill = 125,
		icon = "Interface\\Icons\\INV_Misc_Herb_03",
		zones = { "Arathi Highlands", "Stranglethorn Vale", "Ashenvale", "Wetlands", "Hillsbrad Foothills" },
		yields = "Kingsblood",
		tips = "Abundant across rolling green meadows and open fields."
	},
	{
		name = "Liferoot",
		itemID = 3357,
		category = "Herbalism",
		minSkill = 150,
		icon = "Interface\\Icons\\INV_Misc_Herb_04",
		zones = { "Stranglethorn Vale", "Wetlands", "The Hinterlands", "Dustwallow Marsh", "Hillsbrad" },
		yields = "Liferoot",
		tips = "Found directly along riverbanks, lakeshores, and wetland swamps."
	},
	{
		name = "Fadeleaf",
		itemID = 3818,
		category = "Herbalism",
		minSkill = 160,
		icon = "Interface\\Icons\\INV_Misc_Herb_17",
		zones = { "Stranglethorn Vale", "Swamp of Sorrows", "Arathi Highlands", "Badlands" },
		yields = "Fadeleaf",
		tips = "Spawns in concealed shady spots and under jungle trees. Required for Rogue Blinding Powder."
	},
	{
		name = "Goldthorn",
		itemID = 3821,
		category = "Herbalism",
		minSkill = 170,
		icon = "Interface\\Icons\\INV_Misc_Herb_15",
		zones = { "Stranglethorn Vale", "Arathi Highlands", "Dustwallow Marsh", "Feralas", "The Hinterlands" },
		yields = "Goldthorn",
		tips = "Spawns atop hills, plateaus, and mountain crests."
	},
	{
		name = "Khadgar's Whisker",
		itemID = 3358,
		category = "Herbalism",
		minSkill = 185,
		icon = "Interface\\Icons\\INV_Misc_Herb_02",
		zones = { "Stranglethorn Vale", "The Hinterlands", "Arathi Highlands", "Feralas", "Swamp of Sorrows" },
		yields = "Khadgar's Whisker",
		tips = "Dense in jungle foliage and river valleys."
	},
	{
		name = "Wintersbite",
		itemID = 3819,
		category = "Herbalism",
		minSkill = 195,
		icon = "Interface\\Icons\\INV_Misc_Herb_05",
		zones = { "Alterac Mountains" },
		yields = "Wintersbite",
		tips = "Exclusive to the snowy mountain peaks of Alterac Mountains. Key ingredient for Frost Oil/Protection."
	},
	{
		name = "Firebloom",
		itemID = 4625,
		category = "Herbalism",
		minSkill = 205,
		icon = "Interface\\Icons\\INV_Misc_Herb_19",
		zones = { "Tanaris", "Searing Gorge", "Badlands", "Blasted Lands" },
		yields = "Firebloom",
		tips = "Thrives in desert sand dunes and scorched volcanic rock."
	},
	{
		name = "Purple Lotus",
		itemID = 8831,
		category = "Herbalism",
		minSkill = 210,
		icon = "Interface\\Icons\\INV_Misc_Herb_17",
		zones = { "Tanaris", "Stranglethorn Vale", "Feralas", "Azshara", "Felwood" },
		yields = "Purple Lotus, Wildvine",
		tips = "Spawns around troll and ogre ruins. Yields valuable Wildvine for tailoring and leatherworking."
	},
	{
		name = "Arthas' Tears",
		itemID = 8836,
		category = "Herbalism",
		minSkill = 220,
		icon = "Interface\\Icons\\INV_Misc_Herb_13",
		zones = { "Western Plaguelands", "Eastern Plaguelands", "Felwood" },
		yields = "Arthas' Tears",
		tips = "Common throughout the blighted soil of the Plaguelands."
	},
	{
		name = "Sungrass",
		itemID = 8838,
		category = "Herbalism",
		minSkill = 230,
		icon = "Interface\\Icons\\INV_Misc_Herb_18",
		zones = { "The Hinterlands", "Feralas", "Azshara", "Silithus", "Eastern Plaguelands" },
		yields = "Sungrass",
		tips = "Abundant across sunny clifftops in Hinterlands and Feralas."
	},
	{
		name = "Blindweed",
		itemID = 8839,
		category = "Herbalism",
		minSkill = 235,
		icon = "Interface\\Icons\\INV_Misc_Herb_14",
		zones = { "Swamp of Sorrows", "Zul'Farrak" },
		yields = "Blindweed",
		tips = "Extremely dense in the murky waters of Swamp of Sorrows."
	},
	{
		name = "Ghost Mushroom",
		itemID = 8845,
		category = "Herbalism",
		minSkill = 245,
		icon = "Interface\\Icons\\INV_Mushroom_08",
		zones = { "The Hinterlands (Jintha'Alor caves)", "Maraudon", "Dire Maul", "Zangarmarsh (Sporeggar caves)" },
		yields = "Ghost Mushroom",
		tips = "Spawns in damp underground tunnels and dungeon caves. Essential for Elixir of Shadow Power."
	},
	{
		name = "Gromsblood",
		itemID = 8846,
		category = "Herbalism",
		minSkill = 250,
		icon = "Interface\\Icons\\INV_Misc_Herb_16",
		zones = { "Felwood", "Blasted Lands", "Desolace (Mannoroc)", "Shadowmoon Valley" },
		yields = "Gromsblood",
		tips = "Grows exclusively in demon-corrupted soils. Essential for Mighty Rage and Elixir of the Mongoose."
	},
	{
		name = "Golden Sansam",
		itemID = 13463,
		category = "Herbalism",
		minSkill = 260,
		icon = "Interface\\Icons\\INV_Misc_Herb_SansamRoot",
		zones = { "Azshara", "Feralas", "Un'Goro Crater", "Felwood", "Eastern Plaguelands" },
		yields = "Golden Sansam",
		tips = "Found in mountainous level 50-60 zones."
	},
	{
		name = "Dreamfoil",
		itemID = 13464,
		category = "Herbalism",
		minSkill = 270,
		icon = "Interface\\Icons\\INV_Misc_Herb_DreamFoil",
		zones = { "Azshara", "Silithus", "Un'Goro Crater", "Felwood", "Eastern Plaguelands" },
		yields = "Dreamfoil",
		tips = "High demand for Major Mana and Flask of Supreme Power."
	},
	{
		name = "Mountain Silversage",
		itemID = 13465,
		category = "Herbalism",
		minSkill = 280,
		icon = "Interface\\Icons\\INV_Misc_Herb_MountainSilversage",
		zones = { "Winterspring", "Silithus", "Eastern Plaguelands", "Burning Steppes", "Un'Goro Crater" },
		yields = "Mountain Silversage",
		tips = "Spawns on jagged mountain ledges in high-level zones. Essential for Elixir of the Mongoose."
	},
	{
		name = "Plaguebloom",
		itemID = 13466,
		category = "Herbalism",
		minSkill = 285,
		icon = "Interface\\Icons\\INV_Misc_Herb_PlagueBloom",
		zones = { "Western Plaguelands", "Eastern Plaguelands", "Felwood" },
		yields = "Plaguebloom",
		tips = "Plaguelands road perimeter route is the classic farming loop for raiding consumables."
	},
	{
		name = "Icecap",
		itemID = 13467,
		category = "Herbalism",
		minSkill = 290,
		icon = "Interface\\Icons\\INV_Misc_Herb_IceCap",
		zones = { "Winterspring" },
		yields = "Icecap",
		tips = "Exclusive to the frozen tundra of Winterspring. Key ingredient for Greater Arcane Elixirs."
	},
	{
		name = "Black Lotus",
		itemID = 13468,
		category = "Herbalism",
		minSkill = 300,
		icon = "Interface\\Icons\\INV_Misc_Herb_BlackLotus",
		zones = { "Eastern Plaguelands", "Western Plaguelands", "Winterspring", "Silithus", "Burning Steppes" },
		yields = "Black Lotus",
		tips = "Pinnacle classic raid herbalism node with long respawn timers. Required for all major raid Flasks."
	},
	{
		name = "Felweed",
		itemID = 22785,
		category = "Herbalism",
		minSkill = 300,
		icon = "Interface\\Icons\\INV_Misc_Herb_Felweed",
		zones = { "Hellfire Peninsula", "Zangarmarsh", "Terokkar Forest", "Blade's Edge", "Nagrand" },
		yields = "Felweed, Mote of Life, Fel Lotus",
		tips = "The base herb of Outland, found everywhere across all 7 zones."
	},
	{
		name = "Dreaming Glory",
		itemID = 22786,
		category = "Herbalism",
		minSkill = 315,
		icon = "Interface\\Icons\\INV_Misc_Herb_DreamingGlory",
		zones = { "Terokkar Forest", "Nagrand", "Blade's Edge Mountains", "Netherstorm" },
		yields = "Dreaming Glory, Mote of Life, Fel Lotus",
		tips = "Abundant across open plains in Nagrand and Terokkar. Core ingredient for Super Healing Potions."
	},
	{
		name = "Ragveil",
		itemID = 22787,
		category = "Herbalism",
		minSkill = 325,
		icon = "Interface\\Icons\\INV_Misc_Herb_Ragveil",
		zones = { "Zangarmarsh" },
		yields = "Ragveil, Mote of Life, Fel Lotus",
		tips = "Spawns underneath giant mushroom stalks across Zangarmarsh."
	},
	{
		name = "Terocone",
		itemID = 22789,
		category = "Herbalism",
		minSkill = 325,
		icon = "Interface\\Icons\\INV_Misc_Herb_Terocone",
		zones = { "Terokkar Forest" },
		yields = "Terocone, Mote of Life, Fel Lotus",
		tips = "Found exclusively at the base of trees in Terokkar Forest. Essential for Elixir of Major Agility."
	},
	{
		name = "Flame Cap",
		itemID = 22788,
		category = "Herbalism",
		minSkill = 335,
		icon = "Interface\\Icons\\INV_Misc_Herb_FlameCap",
		zones = { "Zangarmarsh (around Sporeggar & Marshlight Lake)" },
		yields = "Flame Cap",
		tips = "Gives a Fire Spell Power & melee proc on consumption. High demand for Fire Mages and Warlocks."
	},
	{
		name = "Ancient Lichen",
		itemID = 22790,
		category = "Herbalism",
		minSkill = 340,
		icon = "Interface\\Icons\\INV_Misc_Herb_AncientLichen",
		zones = { "Underbog", "The Steamvault", "Mana-Tombs", "Sethekk Halls", "Auchenai Crypts" },
		yields = "Ancient Lichen, Mote of Life, Fel Lotus",
		tips = "Spawns inside Outland dungeon instances. Rogues and stealth druids can farm solo in Underbog."
	},
	{
		name = "Netherbloom",
		itemID = 22791,
		category = "Herbalism",
		minSkill = 350,
		icon = "Interface\\Icons\\INV_Misc_Herb_Netherbloom",
		zones = { "Netherstorm" },
		yields = "Netherbloom, Mote of Life, Random Stat Buff on harvest, Fel Lotus",
		tips = "Found across all purple floating dome islands in Netherstorm."
	},
	{
		name = "Nightmare Vine",
		itemID = 22792,
		category = "Herbalism",
		minSkill = 365,
		icon = "Interface\\Icons\\INV_Misc_Herb_NightmareVine",
		zones = { "Shadowmoon Valley" },
		yields = "Nightmare Vine, Mote of Life, Fel Lotus",
		tips = "Spawns near green lava fissures and demon strongholds in Shadowmoon Valley."
	},
	{
		name = "Mana Thistle",
		itemID = 22793,
		category = "Herbalism",
		minSkill = 375,
		icon = "Interface\\Icons\\INV_Misc_Herb_ManaThistle",
		zones = { "Netherstorm", "Shadowmoon Valley", "Terokkar Forest (Skettis plateau)", "Isle of Quel'Danas" },
		yields = "Mana Thistle, Mote of Life, Fel Lotus",
		tips = "Crown herb of TBC alchemy. Required for all TBC Flasks and Super Mana Potions."
	},

	-- SKINNING & LEATHER (Skill 1 - 375)
	{
		name = "Light Leather",
		itemID = 2318,
		category = "Skinning",
		minSkill = 1,
		icon = "Interface\\Icons\\INV_Misc_LeatherScrap_01",
		zones = { "Elwynn Forest", "Durotar", "Dun Morogh", "Westfall", "Loch Modan", "Darkshore", "Silverpine" },
		yields = "Light Leather, Ruined Leather Scraps, Light Hide",
		tips = "Skinned from level 1-20 beasts (wolves, boars, bears, cats)."
	},
	{
		name = "Medium Leather",
		itemID = 2319,
		category = "Skinning",
		minSkill = 75,
		icon = "Interface\\Icons\\INV_Misc_LeatherScrap_02",
		zones = { "Wetlands", "Duskwood", "Ashenvale", "Hillsbrad Foothills", "Redridge Mountains" },
		yields = "Medium Leather, Medium Hide",
		tips = "Skinned from level 20-30 crocolisks, spiders, raptors, and wolves."
	},
	{
		name = "Heavy Leather",
		itemID = 4234,
		category = "Skinning",
		minSkill = 150,
		icon = "Interface\\Icons\\INV_Misc_LeatherScrap_03",
		zones = { "Stranglethorn Vale", "Thousand Needles", "Desolace", "Arathi Highlands", "Dustwallow Marsh" },
		yields = "Heavy Leather, Heavy Hide",
		tips = "Stranglethorn Vale raptor and panther hunting camps provide constant leather."
	},
	{
		name = "Thick Leather",
		itemID = 4304,
		category = "Skinning",
		minSkill = 200,
		icon = "Interface\\Icons\\INV_Misc_LeatherScrap_04",
		zones = { "Feralas", "Tanaris", "The Hinterlands", "Azshara", "Badlands" },
		yields = "Thick Leather, Thick Hide",
		tips = "Skinned from level 40-50 yetis, gorillas, and basilisks."
	},
	{
		name = "Rugged Leather",
		itemID = 8170,
		category = "Skinning",
		minSkill = 250,
		icon = "Interface\\Icons\\INV_Misc_LeatherScrap_05",
		zones = { "Winterspring", "Western Plaguelands", "Eastern Plaguelands", "Un'Goro Crater" },
		yields = "Rugged Leather, Rugged Hide",
		tips = "Winterspring yetis and Un'Goro dinosaurs provide steady 250-300 skillups."
	},
	{
		name = "Devilsaur Leather",
		itemID = 15417,
		category = "Skinning",
		minSkill = 300,
		icon = "Interface\\Icons\\INV_Misc_MonsterScales_04",
		zones = { "Un'Goro Crater" },
		yields = "Devilsaur Leather",
		tips = "Skinned from elite Devilsaurs roaming Un'Goro Crater. Required for Devilsaur Armor."
	},
	{
		name = "Knothide Leather",
		itemID = 21887,
		category = "Skinning",
		minSkill = 300,
		icon = "Interface\\Icons\\INV_Misc_LeatherScrap_07",
		zones = { "Hellfire Peninsula", "Nagrand", "Terokkar Forest", "Blade's Edge Mountains" },
		yields = "Knothide Leather, Knothide Leather Scraps, Fel Hide",
		tips = "Nagrand Clefthoof and Talbuk herd grinding is the most prolific source of leather in TBC."
	},
	{
		name = "Fel Scales",
		itemID = 25707,
		category = "Skinning",
		minSkill = 325,
		icon = "Interface\\Icons\\INV_Misc_MonsterScales_06",
		zones = { "Hellfire Peninsula", "Blade's Edge Mountains", "Shadowmoon Valley" },
		yields = "Fel Scales",
		tips = "Skinned from Outland basilisks, ravagers, and scorpid mobs."
	},
	{
		name = "Cobra Scales",
		itemID = 29539,
		category = "Skinning",
		minSkill = 350,
		icon = "Interface\\Icons\\INV_Misc_MonsterScales_08",
		zones = { "Shadowmoon Valley", "Nagrand (Twilight Ridge)" },
		yields = "Cobra Scales",
		tips = "Skinned from Shadow Serpents in Shadowmoon Valley. Required for Nethercobra Leg Armor."
	},
	{
		name = "Nether Dragonscales",
		itemID = 29547,
		category = "Skinning",
		minSkill = 365,
		icon = "Interface\\Icons\\INV_Misc_MonsterScales_09",
		zones = { "Shadowmoon Valley (Netherwing Ledge)", "Blade's Edge Mountains" },
		yields = "Nether Dragonscale",
		tips = "Skinned from Nether Drakes and Netherwing Whelps. Required for Dragonstrike & endgame mail."
	},
	{
		name = "Wind Scales",
		itemID = 29548,
		category = "Skinning",
		minSkill = 365,
		icon = "Interface\\Icons\\INV_Misc_MonsterScales_10",
		zones = { "Blade's Edge Mountains" },
		yields = "Wind Scales",
		tips = "Skinned from Scalewing Serpents in Blade's Edge Mountains. Used for Windscale Armor."
	},

	-- ELEMENTS & PRIMALS (Skill 1 - 375)
	{
		name = "Elemental Fire",
		itemID = 7068,
		category = "Elemental",
		minSkill = 1,
		icon = "Interface\\Icons\\Spell_Fire_Fire",
		zones = { "Arathi Highlands (Circle of East Binding)", "Un'Goro Crater", "Searing Gorge", "Molten Core" },
		yields = "Elemental Fire, Heart of Fire",
		tips = "Drops from Burning Exiles in Arathi and Fire Elementals in Un'Goro. Essential for Greater Fire Protection."
	},
	{
		name = "Elemental Earth",
		itemID = 7067,
		category = "Elemental",
		minSkill = 1,
		icon = "Interface\\Icons\\Spell_Nature_StrengthOfEarthTotem02",
		zones = { "Badlands", "Arathi Highlands", "Silithus", "Maraudon" },
		yields = "Elemental Earth, Core of Earth",
		tips = "Drops from Lesser Rock Elementals in Badlands and Earth Exiles in Arathi. Used for Greater Nature Protection."
	},
	{
		name = "Elemental Water",
		itemID = 7069,
		category = "Elemental",
		minSkill = 1,
		icon = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
		zones = { "Stranglethorn Vale", "Arathi Highlands", "Felwood", "Dustwallow Marsh" },
		yields = "Elemental Water, Globe of Water",
		tips = "Drops from Water Elementals along Arathi and Stranglethorn coastlines. Used for Greater Frost Protection."
	},
	{
		name = "Elemental Air",
		itemID = 7070,
		category = "Elemental",
		minSkill = 1,
		icon = "Interface\\Icons\\Spell_Nature_EarthBind",
		zones = { "Silithus", "Arathi Highlands", "Westfall (Dust Devils)" },
		yields = "Elemental Air, Breath of Wind",
		tips = "Drops from Dust Stormers and Whirling Invaders in Silithus."
	},
	{
		name = "Primal Fire",
		itemID = 21884,
		category = "Elemental",
		minSkill = 1,
		icon = "Interface\\Icons\\Spell_Fire_Volcano",
		zones = { "Nagrand (Elemental Plateau)", "Blade's Edge Mountains", "Shadowmoon Valley (Hand of Gul'dan)" },
		yields = "Mote of Fire (10x -> 1x Primal Fire)",
		tips = "Drops from Raging Fire-Souls on the Elemental Plateau and Enraged Fire Spirits in Shadowmoon."
	},
	{
		name = "Primal Water",
		itemID = 21885,
		category = "Elemental",
		minSkill = 1,
		icon = "Interface\\Icons\\Spell_Frost_FrostBolt02",
		zones = { "Nagrand (Elemental Plateau / Lake Sunspring)", "Terokkar Forest (Skettis Lake)", "Zangarmarsh" },
		yields = "Mote of Water (10x -> 1x Primal Water)",
		tips = "Drops from Crashing Wave-Spirits and Skettis Surgers. Can also be fished from Pure Water pools."
	},
	{
		name = "Primal Earth",
		itemID = 22452,
		category = "Elemental",
		minSkill = 1,
		icon = "Interface\\Icons\\Spell_Nature_NatureTouchGrow",
		zones = { "Nagrand (Elemental Plateau)", "Blade's Edge Mountains", "Shadowmoon Valley" },
		yields = "Mote of Earth (10x -> 1x Primal Earth)",
		tips = "Drops from Shattered Rumblers in Nagrand and is a byproduct of mining all Outland ores."
	},
	{
		name = "Primal Air",
		itemID = 22451,
		category = "Elemental",
		minSkill = 1,
		icon = "Interface\\Icons\\Spell_Nature_Cyclone",
		zones = { "Nagrand (Elemental Plateau)", "Shadowmoon Valley (Altar of Sha'tar)" },
		yields = "Mote of Air (10x -> 1x Primal Air)",
		tips = "Drops from Storming Wind-Rippers on the Elemental Plateau and Enraged Air Spirits."
	},
	{
		name = "Primal Life",
		itemID = 21886,
		category = "Elemental",
		minSkill = 1,
		icon = "Interface\\Icons\\INV_Misc_Herb_Felweed",
		zones = { "Zangarmarsh", "Terokkar Forest", "Blade's Edge Mountains" },
		yields = "Mote of Life (10x -> 1x Primal Life)",
		tips = "Drops from Bog Lords, Fungal Giants, and is a byproduct of picking all Outland herbs."
	},
	{
		name = "Primal Mana",
		itemID = 22457,
		category = "Elemental",
		minSkill = 1,
		icon = "Interface\\Icons\\Spell_Arcane_PortalIronForge",
		zones = { "Netherstorm" },
		yields = "Mote of Mana (10x -> 1x Primal Mana)",
		tips = "Drops from Mana Seekers, Mage Wraiths, and Phase Hunters in Netherstorm."
	},
	{
		name = "Primal Shadow",
		itemID = 22456,
		category = "Elemental",
		minSkill = 1,
		icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
		zones = { "Terokkar Forest (Skettis)", "Nagrand (Kil'sorrow Fortress)", "Shadowmoon Valley" },
		yields = "Mote of Shadow (10x -> 1x Primal Shadow)",
		tips = "Drops from Terokkar Shadowmancers, Void Ekes, and Dark Conclave cultists."
	},

	-- CLOTH (Skill 1 - 375)
	{
		name = "Linen Cloth",
		itemID = 2589,
		category = "Cloth",
		minSkill = 1,
		icon = "Interface\\Icons\\INV_Fabric_Linen_01",
		zones = { "Westfall", "Loch Modan", "Silverpine Forest", "Darkshore", "Barrens", "Deadmines" },
		yields = "Linen Cloth",
		tips = "Drops from level 5-18 humanoid enemies (defias, troggs, gnolls, murlocs)."
	},
	{
		name = "Wool Cloth",
		itemID = 2592,
		category = "Cloth",
		minSkill = 1,
		icon = "Interface\\Icons\\INV_Fabric_Wool_01",
		zones = { "Redridge Mountains", "Wetlands", "Duskwood", "Ashenvale", "Hillsbrad Foothills", "Shadowfang Keep" },
		yields = "Wool Cloth",
		tips = "Drops from level 18-30 humanoids and undead."
	},
	{
		name = "Silk Cloth",
		itemID = 4306,
		category = "Cloth",
		minSkill = 1,
		icon = "Interface\\Icons\\INV_Fabric_Silk_01",
		zones = { "Stranglethorn Vale", "Arathi Highlands", "Desolace", "Scarlet Monastery", "Razorfen Downs" },
		yields = "Silk Cloth",
		tips = "Scarlet Monastery (Cathedral & Armory) provides full bag loads of Silk per run."
	},
	{
		name = "Mageweave Cloth",
		itemID = 4338,
		category = "Cloth",
		minSkill = 1,
		icon = "Interface\\Icons\\INV_Fabric_Mageweave_01",
		zones = { "Tanaris", "Feralas", "The Hinterlands", "Zul'Farrak", "Blackrock Depths" },
		yields = "Mageweave Cloth",
		tips = "Zul'Farrak graveyard zombies and Hinterlands troll temples yield dense stacks."
	},
	{
		name = "Runecloth",
		itemID = 14047,
		category = "Cloth",
		minSkill = 1,
		icon = "Interface\\Icons\\INV_Fabric_Purple_01",
		zones = { "Western Plaguelands", "Eastern Plaguelands", "Felwood", "Stratholme", "Scholomance" },
		yields = "Runecloth",
		tips = "Stratholme Live/Undead side and Eastern Plaguelands undead camps."
	},
	{
		name = "Felcloth",
		itemID = 14256,
		category = "Cloth",
		minSkill = 1,
		icon = "Interface\\Icons\\INV_Fabric_Felcloth_01",
		zones = { "Felwood (Jadefire Glen)", "Azshara (Legash Encampment)", "Dire Maul East" },
		yields = "Felcloth",
		tips = "Drops from level 50-60 satyrs and demons. Essential for Mooncloth and Warlock robes."
	},
	{
		name = "Netherweave Cloth",
		itemID = 21877,
		category = "Cloth",
		minSkill = 1,
		icon = "Interface\\Icons\\INV_Fabric_Netherweave",
		zones = { "Hellfire Peninsula", "Zangarmarsh", "Terokkar Forest", "Netherstorm", "Shadowmoon Valley" },
		yields = "Netherweave Cloth",
		tips = "Drops from all humanoid Outland enemies (Orcs, Blood Elves, Broken, Ogres)."
	},

	-- FISHING (Skill 1 - 375)
	{
		name = "Brilliant Smallfish & Longjaw Mud Snapper",
		itemID = 6291,
		category = "Fishing",
		minSkill = 1,
		icon = "Interface\\Icons\\INV_Misc_Fish_04",
		zones = { "Elwynn Forest", "Durotar", "Dun Morogh", "Tirisfal Glades", "Mulgore", "Teldrassil" },
		yields = "Raw Brilliant Smallfish, Raw Longjaw Mud Snapper",
		tips = "Found in all starting area lakes, rivers, and coastal shallows."
	},
	{
		name = "Bristle Whisker Catfish",
		itemID = 6308,
		category = "Fishing",
		minSkill = 50,
		icon = "Interface\\Icons\\INV_Misc_Fish_10",
		zones = { "Westfall", "Loch Modan", "Silverpine Forest", "Redridge Mountains", "Barrens" },
		yields = "Raw Bristle Whisker Catfish",
		tips = "Inland rivers and canals in level 15-25 zones."
	},
	{
		name = "Mithril Head Trout",
		itemID = 8364,
		category = "Fishing",
		minSkill = 100,
		icon = "Interface\\Icons\\INV_Misc_Fish_19",
		zones = { "Arathi Highlands", "Stranglethorn Vale", "Ashenvale", "Hillsbrad Foothills", "Wetlands" },
		yields = "Raw Mithril Head Trout",
		tips = "Inland lakes and rivers in level 30-40 zones."
	},
	{
		name = "Raw Nightfin Snapper",
		itemID = 13759,
		category = "Fishing",
		minSkill = 150,
		icon = "Interface\\Icons\\INV_Misc_Fish_12",
		zones = { "Feralas (Jademir Lake)", "Moonglade", "Duskwood", "Azshara", "Felwood" },
		yields = "Raw Nightfin Snapper (Nightfin Soup: +8 MP5)",
		tips = "Fished predominantly between 6:00 PM and 6:00 AM server time. Essential MP5 food for healers."
	},
	{
		name = "Raw Sunscale Salmon",
		itemID = 13758,
		category = "Fishing",
		minSkill = 150,
		icon = "Interface\\Icons\\INV_Misc_Fish_15",
		zones = { "Feralas", "The Hinterlands", "Azshara", "Felwood" },
		yields = "Raw Sunscale Salmon (Poached Sunscale: +6 HP5)",
		tips = "Fished predominantly between 6:00 AM and 6:00 PM server time."
	},
	{
		name = "Winter Squid",
		itemID = 13755,
		category = "Fishing",
		minSkill = 205,
		icon = "Interface\\Icons\\INV_Misc_Fish_13",
		zones = { "Azshara (Bay of Storms)", "Tanaris (Steamwheedle Port)", "Feralas Coast" },
		yields = "Winter Squid (Grilled Squid: +10 Agility)",
		tips = "Fished from coastal ocean waters, primarily available during winter months (September to March)."
	},
	{
		name = "Raw Greater Sagefish",
		itemID = 21151,
		category = "Fishing",
		minSkill = 225,
		icon = "Interface\\Icons\\INV_Misc_Fish_08",
		zones = { "Alterac Mountains", "Silithus", "Western Plaguelands", "Felwood", "Un'Goro Crater" },
		yields = "Raw Greater Sagefish (Sagefish Delight: +6 MP5)",
		tips = "Fished from Sagefish School pools in inland freshwater lakes."
	},
	{
		name = "Spotted Feltail",
		itemID = 27422,
		category = "Fishing",
		minSkill = 300,
		icon = "Interface\\Icons\\INV_Misc_Fish_21",
		zones = { "Terokkar Forest", "Zangarmarsh", "Hellfire Peninsula (Pools of Aggonar)" },
		yields = "Spotted Feltail (Feltail Delight: +20 Stamina & Spirit)",
		tips = "Common in all Outland freshwater lakes and Feltail School pools."
	},
	{
		name = "Golden Darter",
		itemID = 27435,
		category = "Fishing",
		minSkill = 350,
		icon = "Interface\\Icons\\INV_Misc_Fish_24",
		zones = { "Terokkar Forest (Tuurem rivers and Skettis lakes)" },
		yields = "Golden Darter (Golden Fish Sticks: +44 Healing & +15 Spell Damage)",
		tips = "Golden Darter School pools along Terokkar rivers. Premier healing buff food for TBC raiding."
	},
	{
		name = "Furious Crawdad",
		itemID = 27425,
		category = "Fishing",
		minSkill = 375,
		icon = "Interface\\Icons\\INV_Misc_MonsterClaw_03",
		zones = { "Terokkar Forest (Highland Mixed School pools - Flying Mount Required)" },
		yields = "Furious Crawdad (Spicy Crawdad: +30 Stamina & Spirit)",
		tips = "Located in high mountainous lake craters in Terokkar (Blackwind Lake, Lake Jorune). Premier tank buff food."
	},
}

function GSF.Atlas:GetDisplayName(entry)
	if not entry then return "" end
	if entry.itemID then
		local itemName = GetItemInfo and GetItemInfo(entry.itemID)
		if itemName and itemName ~= "" then
			return itemName
		end
	end
	return entry.name
end

function GSF.Atlas:GetAll()
	return ATLAS_DB
end

function GSF.Atlas:GetByCategory(category)
	if not category or category == "All" then
		return ATLAS_DB
	end

	local results = {}
	for _, entry in ipairs(ATLAS_DB) do
		if entry.category:lower() == category:lower() then
			table.insert(results, entry)
		end
	end
	return results
end

function GSF.Atlas:Search(query, category)
	if not query or query:trim() == "" then
		return self:GetByCategory(category)
	end

	local lowerQ = query:lower():trim()
	local filtered = self:GetByCategory(category)
	local results = {}

	for _, entry in ipairs(filtered) do
		local dispName = self:GetDisplayName(entry):lower()
		local match = false
		if entry.name:lower():find(lowerQ, 1, true) or dispName:find(lowerQ, 1, true) then
			match = true
		elseif entry.yields:lower():find(lowerQ, 1, true) then
			match = true
		elseif entry.tips:lower():find(lowerQ, 1, true) then
			match = true
		else
			for _, z in ipairs(entry.zones) do
				if z:lower():find(lowerQ, 1, true) then
					match = true
					break
				end
			end
		end

		if match then
			table.insert(results, entry)
		end
	end

	return results
end

function GSF.Atlas:FindResource(name)
	if not name then return nil end
	local lower = name:lower():trim()
	for _, entry in ipairs(ATLAS_DB) do
		local dispName = self:GetDisplayName(entry):lower()
		if entry.name:lower():find(lower, 1, true) or dispName:find(lower, 1, true) or entry.yields:lower():find(lower, 1, true) then
			return entry
		end
	end
	return nil
end
