--[[--------------------------------------------------------------------------
  AtlasJournal
  Standalone Classic & TBC Resource & Gathering Compendium Library
  Version: 1.1.1
----------------------------------------------------------------------------]]
local MAJOR, MINOR = "LibAtlasJournal-1.1", 2
local lib = LibStub and LibStub:NewLibrary(MAJOR, MINOR)

-- If LibStub created a new table, preserve anything already attached to AtlasJournal (like Data or Categories)
if lib then
	if AtlasJournal then
		for k, v in pairs(AtlasJournal) do
			if lib[k] == nil then
				lib[k] = v
			end
		end
	end
	AtlasJournal = lib
else
	AtlasJournal = AtlasJournal or {}
end

local Journal = AtlasJournal

Journal.version = "1.1.1"

-- ============================================================================
-- 1. Callback System (Event-Driven Reactive Decoupling)
-- ============================================================================
Journal.callbacks = Journal.callbacks or {}

function Journal:RegisterCallback(event, handler)
	if not self.callbacks[event] then
		self.callbacks[event] = {}
	end
	table.insert(self.callbacks[event], handler)
end

function Journal:UnregisterCallback(event, handler)
	if not self.callbacks[event] then return end
	for i, h in ipairs(self.callbacks[event]) do
		if h == handler then
			table.remove(self.callbacks[event], i)
			break
		end
	end
end

function Journal:FireCallback(event, ...)
	if not self.callbacks[event] then return end
	for _, handler in ipairs(self.callbacks[event]) do
		pcall(handler, ...)
	end
end

-- ============================================================================
-- 2. Embedded Locales (Self-Contained Translations & Tips)
-- ============================================================================
Journal.Locales = {
    ["enUS"] = {
        ["REAGENTS_REQUIRED"] = "Reagents Required:",
        ["CAT_ALL"] = "All Categories",
        ["CAT_MINING"] = "Mining",
        ["CAT_HERBALISM"] = "Herbalism",
        ["CAT_SKINNING"] = "Skinning",
        ["CAT_ELEMENTAL"] = "Elemental",
        ["CAT_CLOTH"] = "Cloth",
        ["CAT_ENCHANTING"] = "Enchanting",
        ["CAT_ENGINEERING"] = "Engineering",
        ["CAT_COOKING"] = "Cooking & Meats",
        ["CAT_FISHING"] = "Fishing",
        ["ITEM_LOADING"] = "Item #%d (Loading...)",
        ["SRC_SOURCES_HEADER"] = "Acquisition Sources:",
        ["SRC_GATHER"] = "Gathering",
        ["SRC_GATHER_DESC"] = "Mined or gathered from nodes in the world.",
        ["SRC_PROSPECT"] = "Prospecting",
        ["SRC_DISENCHANT"] = "Disenchanting",
        ["SRC_EXTRACT"] = "Gas Extraction",
        ["SRC_EXTRACT_DESC"] = "Extracted from volatile gas clouds.",
        ["SRC_TRANSMUTE"] = "Transmutation",
        ["SRC_SMELT"] = "Smelting",
        ["SRC_CRAFT"] = "Crafting",
        ["SRC_COMBINE"] = "Combine",
        ["YIELDS_COUNT"] = "Yields %dx",
        ["SRC_MOB_DROP"] = "Creature Drop",
        ["SRC_MOB_DROP_DESC"] = "Farmed from defeated monsters.",
        ["SRC_FISH"] = "Fishing",
        ["SRC_BYPRODUCT"] = "Byproduct Yield",
        ["SRC_INSTANCE"] = "Dungeon / Raid Drop",
        ["SRC_VENDOR"] = "Vendor Purchase",
        ["CRUSHED_FROM"] = "Crushed from 5x",
        ["DISENCHANTED_FROM"] = "Disenchanted from items",
        ["DEVICE_REQUIRED"] = "Device required",
        ["REAGENTS"] = "Reagents",
        ["NO_SPECIFIC_TIPS"] = "No specific notes.",
        ["ATLAS_TIP_2770"] = "Abundant in all starting zones along foothills and caves.",
        ["ATLAS_TIP_2835"] = "Common byproduct when mining Copper Veins.",
        ["ATLAS_TIP_2771"] = "Abundant around gnoll and murloc camps in level 15-25 zones.",
        ["ATLAS_TIP_2836"] = "Common byproduct when mining Tin and Silver Veins.",
        ["ATLAS_TIP_2775"] = "Rare spawn replacing Tin Veins.",
        ["ATLAS_TIP_2772"] = "Arathi Highlands perimeter and Badlands valley are the most efficient loops.",
        ["ATLAS_TIP_2838"] = "Common byproduct when mining Iron and Gold Deposits.",
        ["ATLAS_TIP_2776"] = "Rare spawn replacing Iron Deposits.",
        ["ATLAS_TIP_3858"] = "Badlands perimeter, Searing Gorge, and Hinterlands cliffs provide rapid node respawns.",
        ["ATLAS_TIP_7912"] = "Essential stone byproduct from Mithril and Truesilver deposits.",
        ["ATLAS_TIP_7911"] = "Rare spawn replacing Mithril Deposits.",
        ["ATLAS_TIP_11370"] = "Found exclusively in Blackrock Mountain, Searing Gorge, and Molten Core.",
        ["ATLAS_TIP_10620"] = "Un'Goro Crater perimeter and Winterspring mountains offer the highest concentration of Rich Thorium.",
        ["ATLAS_TIP_12365"] = "Crucial stone byproduct from Small and Rich Thorium Veins.",
        ["ATLAS_TIP_23424"] = "Abundant across Hellfire Peninsula; circle the cliffs and canyons for fast respawns.",
        ["ATLAS_TIP_23425"] = "Nagrand and Blade's Edge mountains provide prime gathering loops for rich deposits.",
        ["ATLAS_TIP_23426"] = "Extremely rare node replacing Adamantite across high-level Outland zones.",
        ["ATLAS_TIP_23427"] = "Rare byproduct obtained when mining Adamantite and Khorium Veins.",
        ["ATLAS_TIP_23436"] = "Rare red gem prospected from Adamantite Ore or found in Rich Adamantite.",
        ["ATLAS_TIP_23437"] = "Rare green gem prospected from Adamantite Ore or found in Khorium.",
        ["ATLAS_TIP_23438"] = "Rare blue gem prospected from Adamantite Ore or found in Outland veins.",
        ["ATLAS_TIP_23439"] = "Rare orange gem prospected from Adamantite Ore or found in Rich Adamantite.",
        ["ATLAS_TIP_23440"] = "Rare yellow gem prospected from Adamantite Ore or found in Khorium.",
        ["ATLAS_TIP_23441"] = "Rare purple gem prospected from Adamantite Ore or found in Outland veins.",
        ["ATLAS_TIP_23077"] = "Uncommon red gem easily obtained by prospecting Fel Iron and Adamantite.",
        ["ATLAS_TIP_23079"] = "Uncommon green gem prospected from Fel Iron and Adamantite Ore.",
        ["ATLAS_TIP_23107"] = "Uncommon purple gem prospected from Fel Iron and Adamantite Ore.",
        ["ATLAS_TIP_23112"] = "Uncommon yellow gem prospected from Fel Iron and Adamantite Ore.",
        ["ATLAS_TIP_23117"] = "Uncommon blue gem prospected from Fel Iron and Adamantite Ore.",
        ["ATLAS_TIP_24243"] = "100% byproduct when prospecting Adamantite Ore; used for Mercurial Adamantite.",
        ["ATLAS_TIP_2447"] = "Grows near trees and open fields in starting zones.",
        ["ATLAS_TIP_765"] = "Found at the base of trees in all level 1-10 starting areas.",
        ["ATLAS_TIP_2449"] = "Spawns along rock formations, crags, and hillsides.",
        ["ATLAS_TIP_785"] = "Frequently yields Swiftthistle; found in level 10-20 zones.",
        ["ATLAS_TIP_2450"] = "Primary source of Swiftthistle; spawns at tree trunks and hedges.",
        ["ATLAS_TIP_2453"] = "Common along hills and borders between low-level territories.",
        ["ATLAS_TIP_3820"] = "Found underwater along coastlines and lakes; essential for Free Action Potions.",
        ["ATLAS_TIP_2452"] = "Crucial Rogue and Agility potion reagent; gathered from Briarthorn and Mageroyal.",
        ["ATLAS_TIP_3355"] = "Spawns exclusively on high ridges, rocky summits, and mountain outcroppings.",
        ["ATLAS_TIP_3356"] = "Abundant across level 30-40 contested zones like Arathi and Stranglethorn.",
        ["ATLAS_TIP_3357"] = "Grows near fresh water, rivers, and riverbanks in mid-level zones.",
        ["ATLAS_TIP_3358"] = "Common in level 40-50 zones under tree canopies.",
        ["ATLAS_TIP_3818"] = "Essential for Rogue blinding powder; found hidden in bushes and tree roots.",
        ["ATLAS_TIP_3821"] = "High-value Alchemy herb found on mountain ridges and arid hills.",
        ["ATLAS_TIP_3369"] = "Harvested around graveyards, crypts, and undead camps.",
        ["ATLAS_TIP_3819"] = "Spawns in freezing snowy terrain, notably Alterac Mountains.",
        ["ATLAS_TIP_4625"] = "Found in scorching desert zones like Tanaris, Badlands, and Searing Gorge.",
        ["ATLAS_TIP_8831"] = "Ancient ruins in Tanaris, Feralas, and Azshara; yields Wildvine.",
        ["ATLAS_TIP_8153"] = "Essential reagent for crafting gear; gathered as a byproduct of Purple Lotus or dropped by Trolls.",
        ["ATLAS_TIP_8836"] = "Scattered throughout the corrupted Plaguelands and Felwood.",
        ["ATLAS_TIP_8838"] = "Open sunny plains in Feralas and Hinterlands provide the best farming runs.",
        ["ATLAS_TIP_8839"] = "Abundant in marshlands and swamps, especially Dustwallow Marsh.",
        ["ATLAS_TIP_8845"] = "Harvested inside gloomy caves, Skulk Rock, and Sunken Temple.",
        ["ATLAS_TIP_8846"] = "Found near demon encampments in Felwood, Blasted Lands, and Desolace.",
        ["ATLAS_TIP_13464"] = "Plentiful in Un'Goro Crater and eastern Felwood.",
        ["ATLAS_TIP_13463"] = "Key raid consumable herb; extensive loop along Felwood ridges and Un'Goro.",
        ["ATLAS_TIP_13465"] = "High-altitude mountain ridges in Winterspring and Eastern Plaguelands.",
        ["ATLAS_TIP_13466"] = "High demand flask herb; Western and Eastern Plaguelands perimeters.",
        ["ATLAS_TIP_13467"] = "Exclusive to the frozen snowfields of Winterspring; 100% icy terrain.",
        ["ATLAS_TIP_13468"] = "Extremely rare; spawns in high-level Classic zones (Winterspring, Silithus, EPL, Burning Steppes).",
        ["ATLAS_TIP_22785"] = "Found across all Outland zones; high chance to yield Fel Lotus and Motes of Life.",
        ["ATLAS_TIP_22786"] = "Grows on cliffs and high terrain in Hellfire Peninsula and Terokkar Forest.",
        ["ATLAS_TIP_22787"] = "Abundant across Zangarmarsh around giant mushroom stalks.",
        ["ATLAS_TIP_22788"] = "Harvested around the spore colonies in western Zangarmarsh; grants Fire spell boost.",
        ["ATLAS_TIP_22789"] = "Spawns at the base of towering pine trees throughout Terokkar Forest.",
        ["ATLAS_TIP_22790"] = "Found inside Outland dungeon instances (Underbog, Steamvault, Auchindoun).",
        ["ATLAS_TIP_22791"] = "Plentiful on the floating eco-domes of Netherstorm; yields Mote of Mana.",
        ["ATLAS_TIP_22792"] = "Harvested in Shadowmoon Valley; damages gatherers on pickup and yields Mote of Life.",
        ["ATLAS_TIP_22793"] = "High-flying plateau herb (requires flying mount) in Terokkar, Nagrand, and Netherstorm.",
        ["ATLAS_TIP_22794"] = "Rare bonus yield obtained when harvesting any Outland herb node; core reagent for Flasks.",
        ["ATLAS_TIP_2318"] = "Skinned from beasts in level 1-15 starting zones (wolves, boars, bears).",
        ["ATLAS_TIP_2319"] = "Skinned from level 15-30 beasts in Westfall, Duskwood, and Hillsbrad.",
        ["ATLAS_TIP_4234"] = "Farmed from raptors, cats, and crocolisks in Stranglethorn Vale and Arathi.",
        ["ATLAS_TIP_4304"] = "Abundant from gorillas, basilisks, and yetis in Feralas and Tanaris.",
        ["ATLAS_TIP_8170"] = "Skinned from high-level beasts in Un'Goro Crater and Winterspring.",
        ["ATLAS_TIP_15417"] = "Skinned from elite Devilsaurs patrolling Un'Goro Crater.",
        ["ATLAS_TIP_25707"] = "Low-level Outland leather scraps; combine 5x into Knothide Leather.",
        ["ATLAS_TIP_21887"] = "Primary TBC leather; abundant from talbuks, clefthoofs, and ravagers in Outland.",
        ["ATLAS_TIP_25708"] = "Skinned from massive Clefthoofs in Nagrand and Blade's Edge; core reagent for leg armors.",
        ["ATLAS_TIP_25700"] = "Skinned from dragonhawks and basilisks in Hellfire and Shadowmoon.",
        ["ATLAS_TIP_29539"] = "Skinned from Cobras and Serpents in Nagrand and Shadowmoon Valley.",
        ["ATLAS_TIP_29547"] = "Skinned from Windserpents and Chimaeras in Blade's Edge Mountains.",
        ["ATLAS_TIP_29548"] = "Skinned from Nether Drakes in Shadowmoon Valley and Netherstorm.",
        ["ATLAS_TIP_2589"] = "Dropped by level 5-15 humanoid mobs across all starting territories.",
        ["ATLAS_TIP_2592"] = "Farmed from humanoid Defias, gnolls, and murlocs in level 15-25 areas.",
        ["ATLAS_TIP_4306"] = "Dropped by Syndicate, Dark Iron dwarfs, and Ogres in level 25-40 zones.",
        ["ATLAS_TIP_4338"] = "Abundant from Ogres in Tanaris, Feralas, and Zul'Farrak dungeon runs.",
        ["ATLAS_TIP_14047"] = "Farmed from Scarlet Crusade and Scourge humanoids in the Plaguelands.",
        ["ATLAS_TIP_14256"] = "Dropped by high-level demons in Felwood (Jaedenar) and Azshara.",
        ["ATLAS_TIP_21877"] = "Universal TBC cloth dropped by all humanoid and demonic forces across Outland.",
        ["ATLAS_TIP_22574"] = "Farmed from Fire Elementals in Blade's Edge or extracted with Mote Extractor.",
        ["ATLAS_TIP_21884"] = "Combine 10x Motes of Fire or transmute via Alchemy (20h cooldown).",
        ["ATLAS_TIP_22578"] = "Farmed from Water Elementals in Skettis / Nagrand, fished in Pure Water, or extracted from gas.",
        ["ATLAS_TIP_21885"] = "Combine 10x Motes of Water; highly prized reagent for Spellcloth and enchants.",
        ["ATLAS_TIP_22572"] = "Farmed from Air Elementals on Elemental Plateau in Nagrand or extracted from windy gas swirls.",
        ["ATLAS_TIP_22451"] = "Combine 10x Motes of Air; key component for high-end crafted weapons and engineering goggles.",
        ["ATLAS_TIP_22573"] = "Farmed from Earth Elementals in Nagrand or gathered as a byproduct of mining Outland ores.",
        ["ATLAS_TIP_22452"] = "Combine 10x Motes of Earth; essential reagent for blacksmithing plate armors.",
        ["ATLAS_TIP_22575"] = "Gathered from Bog Lords in Zangarmarsh, extracted from Swamp Gas, or harvested from herbs.",
        ["ATLAS_TIP_21886"] = "Combine 10x Motes of Life; essential component for Primal Mooncloth.",
        ["ATLAS_TIP_22577"] = "Farmed from Voidwalkers and demons in Shadowmoon Valley or extracted from Shadow Clouds.",
        ["ATLAS_TIP_22456"] = "Combine 10x Motes of Shadow; vital reagent for Shadowcloth and dark spell threads.",
        ["ATLAS_TIP_22576"] = "Farmed from Mana Seekers in Netherstorm or extracted from Arcane Felmist clouds.",
        ["ATLAS_TIP_22457"] = "Combine 10x Motes of Mana; needed for epic casters' gear and Primal Might.",
        ["ATLAS_TIP_23571"] = "Core transmutation reagent crafted by Alchemists with a 20-hour cooldown.",
        ["ATLAS_TIP_23572"] = "Dropped by heroic dungeon final bosses and raid bosses; purchasable for Badges of Justice.",
        ["ATLAS_TIP_30183"] = "Dropped in Serpentshrine Cavern and Tempest Keep; purchasable for Badges of Justice.",
        ["ATLAS_TIP_10940"] = "Disenchanted from level 1-20 green armor and weapons.",
        ["ATLAS_TIP_11083"] = "Disenchanted from level 21-30 green equipment.",
        ["ATLAS_TIP_11137"] = "Disenchanted from level 31-40 green equipment.",
        ["ATLAS_TIP_11176"] = "Disenchanted from level 41-50 green equipment.",
        ["ATLAS_TIP_16204"] = "Disenchanted from level 51-60 green equipment.",
        ["ATLAS_TIP_22445"] = "Disenchanted from Outland level 58-70 green armor and weapons.",
        ["ATLAS_TIP_22447"] = "Disenchanted from level 58-65 Outland green weapons.",
        ["ATLAS_TIP_22446"] = "Combine 3x Lesser Planar Essences or disenchant level 65-70 Outland greens.",
        ["ATLAS_TIP_22448"] = "Disenchanted from level 58-66 rare (blue) dungeon and quest items.",
        ["ATLAS_TIP_22449"] = "Disenchanted from level 67-70 rare (blue) dungeon boss drops.",
        ["ATLAS_TIP_22450"] = "Disenchanted from epic (purple) heroic and raid items in Karazhan, Gruul, and Magtheridon.",
        ["ATLAS_TIP_20725"] = "Disenchanted from level 60 classic raid epic items (MC, BWL, AQ40, Naxxramas).",
        ["ATLAS_TIP_27671"] = "Cooked into Roasted Clefthoof (+20 Strength); farmed from Clefthoofs in Nagrand.",
        ["ATLAS_TIP_27677"] = "Cooked into Ravager Dog (+40 Attack Power); farmed from Ravagers in Hellfire and Blade's Edge.",
        ["ATLAS_TIP_27682"] = "Cooked into Talbuk Steak (+20 Hit Rating); farmed from Talbuks in Nagrand.",
        ["ATLAS_TIP_27681"] = "Cooked into Warp Burger (+20 Agility); farmed from Warpstalkers in Terokkar Forest.",
        ["ATLAS_TIP_27674"] = "Cooked into Basilisk Stew (+23 Spell Power); farmed from Basilisks in Terokkar.",
        ["ATLAS_TIP_27429"] = "Caught in Sporefish schools in Zangarmarsh; cooked for +20 Stamina and +8 MP5.",
        ["ATLAS_TIP_6358"] = "Fished in coastal schools; essential for Free Action Potions and Shadow Oil.",
        ["ATLAS_TIP_6359"] = "Fished in coastal schools; key reagent for Fire Oil and Fire Power elixirs.",
        ["ATLAS_TIP_13422"] = "Caught in open ocean swarms in Tanaris and Feralas; core reagent for Greater Stoneshield Potion.",
        ["ATLAS_TIP_774"] = "Common green gem found in Copper deposits, or prospected from Copper and Tin Ore.",
        ["ATLAS_TIP_818"] = "Common brown gem found in Copper and Tin deposits, or prospected from Copper and Tin Ore.",
        ["ATLAS_TIP_1210"] = "Shadowy gem found in Tin and Silver deposits, or prospected from Tin and Silver Ore.",
        ["ATLAS_TIP_1705"] = "Glimmering gem found in Tin, Silver, and Iron deposits, or prospected from Ore.",
        ["ATLAS_TIP_1206"] = "Greenish gem found in Tin, Silver, and Iron deposits, or prospected from Ore.",
        ["ATLAS_TIP_1529"] = "Valuable green gem found in Iron, Gold, and Mithril deposits, or prospected from Ore.",
        ["ATLAS_TIP_3864"] = "Golden gem found in Iron, Gold, and Mithril deposits, or prospected from Ore.",
        ["ATLAS_TIP_7909"] = "Brilliant blue gem found in Mithril, Truesilver, and Thorium deposits, or prospected from Ore.",
        ["ATLAS_TIP_7910"] = "Fiery red gem found in Mithril, Truesilver, and Thorium deposits, or prospected from Ore.",
        ["ATLAS_TIP_12799"] = "Rare iridescent gem found in Thorium deposits, or prospected from Thorium Ore.",
        ["ATLAS_TIP_12800"] = "Äußerst seltener Diamant aus Reichen Thoriumvorkommen oder durch Sondieren.",
        ["ATLAS_TIP_12361"] = "Rare blue gem found in Thorium deposits, or prospected from Thorium Ore.",
        ["ATLAS_TIP_12364"] = "Seltener grüner Edelstein aus Thoriumvorkommen oder durch Sondieren.",
        ["ATLAS_TIP_12363"] = "Crucial catalyst for Arcanite Bars; found as a rare byproduct in Rich Thorium Veins.",
        ["ATLAS_TIP_11382"] = "Extremely rare crafting reagent found inside Dark Iron Veins in Blackrock Mountain.",
        ["ATLAS_TIP_769"] = "Harvested from boars in starting areas; roasted into Roasted Boar Meat.",
        ["ATLAS_TIP_783"] = "Rare byproduct obtained when skinning level 1-20 beasts across starting zones.",
        ["ATLAS_TIP_2672"] = "Dropped by young wolves in level 1-10 starting zones; used for early Cooking progression.",
        ["ATLAS_TIP_2934"] = "Skinned from young beasts in starting areas; combine 3x into Light Leather via Leatherworking.",
        ["ATLAS_TIP_3173"] = "Dropped by black and brown bears in level 10-20 zones like Loch Modan and Darkshore.",
        ["ATLAS_TIP_3730"] = "Farmed from ferocious bears in Hillsbrad Foothills, Ashenvale, and Feralas.",
        ["ATLAS_TIP_4232"] = "Rare hide obtained when skinning level 20-35 beasts in mid-level territories.",
        ["ATLAS_TIP_4235"] = "Uncommon hide obtained when skinning level 35-45 beasts in Arathi, Badlands, and Feralas.",
        ["ATLAS_TIP_4603"] = "Caught off coastlines in Tanaris and Feralas; staple food for level 45-60 leveling.",
        ["ATLAS_TIP_4655"] = "Gathered from Big-Mouth and Giant Clams along coasts; cooked into Clam Chowder and monster stews.",
        ["ATLAS_TIP_6289"] = "Abundant in low-level rivers and lakes; used in early stamina food recipes.",
        ["ATLAS_TIP_6291"] = "Caught in open starting waters across Azeroth; excellent for early Cooking leveling.",
        ["ATLAS_TIP_6303"] = "Caught along coastal shorelines in beginner territories.",
        ["ATLAS_TIP_6308"] = "Abundant in mid-level rivers (Duskwood, Hillsbrad, Wetlands); staple mid-tier fish.",
        ["ATLAS_TIP_6317"] = "Exclusive to the mountain waters of Loch Modan; cooked into Loch Frenzy Delight.",
        ["ATLAS_TIP_6361"] = "Found in coastal seas around level 15-30 zones; popular leveling food.",
        ["ATLAS_TIP_6362"] = "Caught in temperate coastal waters; cooked into Rockscale Cod fillets.",
        ["ATLAS_TIP_6522"] = "Caught in the three oasis pools of the Barrens and Wailing Caverns; creates Savory Deviate Delight.",
        ["ATLAS_TIP_6889"] = "Looted from low-level birds, striders, and raptors; essential ingredient for Gingerbread Cookies.",
        ["ATLAS_TIP_7067"] = "Dropped by Earth Elementals in Badlands, Arathi, and Thousand Needles; essential for Greater Nature Protection Potions.",
        ["ATLAS_TIP_7068"] = "Dropped by Fire Elementals in Searing Gorge and Un'Goro; crucial reagent for Greater Fire Protection Potions.",
        ["ATLAS_TIP_7069"] = "Dropped by Dust Devils and Wind Elementals in Silithus and Arathi; used for Agility elixirs.",
        ["ATLAS_TIP_7070"] = "Dropped by Water Elementals in Felwood and Stranglethorn; essential for Greater Frost Protection Potions.",
        ["ATLAS_TIP_7075"] = "Dropped by deep subterranean Earth Elementals in Maraudon, Badlands, and Silithus.",
        ["ATLAS_TIP_7076"] = "High-tier Classic elemental reagent from level 50+ Earth Elementals; key for Iron Counterweights and armor.",
        ["ATLAS_TIP_7077"] = "Farmed from Molten Giants and Fire Elementals in Molten Core and Searing Gorge.",
        ["ATLAS_TIP_7078"] = "Dropped by level 50+ Fire Elementals in Un'Goro Crater and Molten Core; core reagent for fiery enchants.",
        ["ATLAS_TIP_7079"] = "Farmed from higher Water Elementals in Eastern Plaguelands and Felwood lakes.",
        ["ATLAS_TIP_7080"] = "High-value elemental reagent from water elementals in Felwood; staple for Mage crafts and Flask of Supreme Power.",
        ["ATLAS_TIP_7081"] = "Harvested from roaming Cyclone Elementals in Silithus and Western Plaguelands.",
        ["ATLAS_TIP_7082"] = "Extremely valuable essence dropped by Dust Stormers in Silithus; core reagent for Enchant Weapon - Agility.",
        ["ATLAS_TIP_8167"] = "Skinned from Snapping Turtles and Sea Turtles along the coastlines of Tanaris and Hinterlands.",
        ["ATLAS_TIP_8169"] = "Rare hide obtained when skinning level 45-55 beasts in Feralas, Tanaris, and Hinterlands.",
        ["ATLAS_TIP_8171"] = "Prized hide obtained from high-level beasts in Un'Goro Crater and Winterspring; used for Core Armor Kits.",
        ["ATLAS_TIP_8364"] = "Found in higher-level inland rivers and lakes in Stranglethorn, Feralas, and Hinterlands.",
        ["ATLAS_TIP_10938"] = "Disenchanted from level 1-10 green weapons; combine 3x into Greater Magic Essence.",
        ["ATLAS_TIP_10939"] = "Disenchanted from level 11-15 green weapons, or combined from 3x Lesser Magic Essences.",
        ["ATLAS_TIP_10978"] = "Disenchanted from level 15-20 blue (rare) equipment found in Deadmines and Wailing Caverns.",
        ["ATLAS_TIP_10998"] = "Disenchanted from level 16-20 green weapons; combine 3x into Greater Astral Essence.",
        ["ATLAS_TIP_11082"] = "Disenchanted from level 21-25 green weapons, or combined from 3x Lesser Astral Essences.",
        ["ATLAS_TIP_11084"] = "Disenchanted from level 21-25 blue (rare) equipment found in Shadowfang Keep and Blackfathom Deeps.",
        ["ATLAS_TIP_11134"] = "Disenchanted from level 26-30 green weapons; combine 3x into Greater Mystic Essence.",
        ["ATLAS_TIP_11135"] = "Disenchanted from level 31-35 green weapons, or combined from 3x Lesser Mystic Essences.",
        ["ATLAS_TIP_11138"] = "Disenchanted from level 26-30 blue (rare) equipment found in Gnomeregan and Scarlet Monastery.",
        ["ATLAS_TIP_11139"] = "Disenchanted from level 31-35 blue (rare) equipment found in Razorfen Kraul and Scarlet Monastery Armory.",
        ["ATLAS_TIP_11174"] = "Disenchanted from level 36-40 green weapons; combine 3x into Greater Nether Essence.",
        ["ATLAS_TIP_11175"] = "Disenchanted from level 41-45 green weapons, or combined from 3x Lesser Nether Essences.",
        ["ATLAS_TIP_11177"] = "Disenchanted from level 36-40 blue (rare) equipment found in Uldaman and Scarlet Monastery Cathedral.",
        ["ATLAS_TIP_11178"] = "Disenchanted from level 41-45 blue (rare) equipment found in Zul'Farrak and Maraudon.",
        ["ATLAS_TIP_12184"] = "Dropped by Highland Raptors in Arathi and Stranglethorn; cooked into Roast Raptor.",
        ["ATLAS_TIP_12202"] = "Farmed from stalking tigers and panthers throughout Stranglethorn Vale.",
        ["ATLAS_TIP_12208"] = "Harvested from high-level wolves in Hinterlands and Felwood; cooked into Tender Wolf Steaks.",
        ["ATLAS_TIP_12803"] = "Harvested from corrupted plants, treants, and swamp beasts in Felwood, Un'Goro, and Dustwallow Marsh.",
        ["ATLAS_TIP_12808"] = "Dropped by Scourge and high-level undead in the Plaguelands, Stratholme, and Scholomance.",
        ["ATLAS_TIP_13754"] = "High-level sea fish found in Azshara, Feralas, and Tanaris; yields raw stamina buff.",
        ["ATLAS_TIP_13755"] = "Seasonal coastal catch available during winter months (or deep open sea); grants +10 Agility food buff.",
        ["ATLAS_TIP_13756"] = "Seasonal coastal catch available during summer months; cooked into Monster Omelets and agility food.",
        ["ATLAS_TIP_13758"] = "Caught in high-level rivers of Eastern Plaguelands and Felwood; staple 50+ consumable.",
        ["ATLAS_TIP_13759"] = "Caught predominantly at night (18:00 to 06:00); highly prized for Mana Regeneration (MP5) soup.",
        ["ATLAS_TIP_13760"] = "Caught predominantly during daytime hours (06:00 to 18:00); cooked into health restoration food.",
        ["ATLAS_TIP_13889"] = "Prized high-skill catch found in icy lakes of Winterspring and Plaguelands.",
        ["ATLAS_TIP_14342"] = "Created by Tailors at a Moonwell using 2x Felcloth (4-day cooldown); vital for high-end Classic bags and robes.",
        ["ATLAS_TIP_14343"] = "Disenchanted from level 46-50 blue (rare) equipment; combine 3x into Large Brilliant Shard via Enchanting.",
        ["ATLAS_TIP_14344"] = "Disenchanted from level 51-60 rare dungeon items (BRD, Strat, Scholo); core high-end Classic reagent.",
        ["ATLAS_TIP_15412"] = "Skinned from green dragonkin in Sunken Temple and Swamp of Sorrows.",
        ["ATLAS_TIP_15414"] = "Skinned from red dragonkin and whelps in Wetlands; key component for Dragonscale leatherworking.",
        ["ATLAS_TIP_15415"] = "Skinned from blue dragonkin in Winterspring and Azshara; needed for magical resistant mail armors.",
        ["ATLAS_TIP_15416"] = "Skinned from black dragonkin in Burning Steppes and Blackrock Spire; vital for Onyxia Scale Cloaks.",
        ["ATLAS_TIP_15419"] = "Skinned from diseased and rabid bears roaming Western and Eastern Plaguelands; used for Warbear Harness.",
        ["ATLAS_TIP_16202"] = "Disenchanted from level 46-50 green weapons; combine 3x into Greater Eternal Essence.",
        ["ATLAS_TIP_16203"] = "Disenchanted from level 51-60 green weapons, or combined from 3x Lesser Eternal Essences.",
        ["ATLAS_TIP_17012"] = "Exclusive raid leather skinned from Core Hounds and Magmadar in the Molten Core (Skinning 310 required).",
        ["ATLAS_TIP_18562"] = "Exceedingly rare ore looted from Blackwing Technicians in Blackwing Lair; required to smelt Elementium Bars for Thunderfury.",
        ["ATLAS_TIP_20424"] = "Farmed from Dredge Strikers and Sandworms in Silithus; cooked into Smoked Desert Dumplings (+20 Strength).",
        ["ATLAS_TIP_21845"] = "Woven by Mooncloth Tailors at Moonwells in Zangarmarsh or Terokkar (3d 20h cooldown); core healer set cloth.",
        ["ATLAS_TIP_21929"] = "Uncommon orange gem prospected from Fel Iron and Adamantite Ore; cut into Inscribed and Glinting gems.",
        ["ATLAS_TIP_23793"] = "Crafted by Leatherworkers (Skill 325) using 5x Knothide Leather; staple for mid-to-high tier Outland gear.",
        ["ATLAS_TIP_24271"] = "Woven by Spellfire Tailors at Netherstorm Manaforges (3d 20h cooldown); high demand for offensive casters.",
        ["ATLAS_TIP_24272"] = "Woven by Shadoweave Tailors at the Altar of Shadows in Shadowmoon Valley (3d 20h cooldown); essential for Warlocks and Priests.",
        ["ATLAS_TIP_24477"] = "Found inside Jaggal Clams fished in Zangarmarsh; cooked into Clam Bar (+20 Strength).",
        ["ATLAS_TIP_25649"] = "Low-level Outland leather scraps; combine 5x into Knothide Leather via Leatherworking.",
        ["ATLAS_TIP_25699"] = "Harvested from crystal-flayed beasts and basilisks in Blade's Edge Mountains.",
        ["ATLAS_TIP_25867"] = "Uncut meta gem transmuted by Alchemists (requires 3x Deep Peridot, 3x Shadow Draenite, 3x Golden Draenite, 2x Primal Earth, 2x Primal Water).",
        ["ATLAS_TIP_25868"] = "Uncut meta gem transmuted by Alchemists (requires 3x Blood Garnet, 3x Flame Spessarite, 3x Azure Moonstone, 2x Primal Fire, 2x Primal Air).",
        ["ATLAS_TIP_27422"] = "Common Outland river fish found in Zangarmarsh and Terokkar Forest; staple TBC food ingredient.",
        ["ATLAS_TIP_27425"] = "Abundant across inland Outland waters; key leveling fish for TBC Cooking and Stamina food.",
        ["ATLAS_TIP_27435"] = "Found in Nagrand lakes; cooked into Blackened Sporefish / Figlamp food with spell power benefits.",
        ["ATLAS_TIP_27437"] = "Fished from Bluefish schools in Nagrand and Netherstorm; cooked into Poached Bluefish (+23 Spell Power).",
        ["ATLAS_TIP_27438"] = "Fished from Highland Mixed Schools in Terokkar Forest; cooked into Golden Fish Sticks (+44 Healing Power).",
        ["ATLAS_TIP_27439"] = "Rare catch from Highland Mixed Schools in Skettis (flying mount required); cooked into Spicy Crawdad (+30 Stamina).",
        ["ATLAS_TIP_27678"] = "Farmed from roaming Clefthoof herds across Nagrand; cooked into Roasted Clefthoof (+20 Strength).",
        ["ATLAS_TIP_31671"] = "Dropped by serpents and scalewings in Blade's Edge Mountains; cooked into Crunchy Serpent (+23 Spell Power).",
        ["ATLAS_TIP_32464"] = "Mined around Netherwing Ledge and floating islands in Shadowmoon Valley (Netherwing reputation questing).",
    },
    ["deDE"] = {
        ["REAGENTS_REQUIRED"] = "Benötigte Reagenzien:",
        ["CAT_ALL"] = "Alle Kategorien",
        ["CAT_MINING"] = "Bergbau",
        ["CAT_HERBALISM"] = "Kräuterkunde",
        ["CAT_SKINNING"] = "Kürschnerei",
        ["CAT_ELEMENTAL"] = "Elementare",
        ["CAT_CLOTH"] = "Stoff",
        ["CAT_ENCHANTING"] = "Verzauberkunst",
        ["CAT_ENGINEERING"] = "Ingenieurskunst",
        ["CAT_COOKING"] = "Kochkunst & Fleisch",
        ["CAT_FISHING"] = "Angeln",
        ["ITEM_LOADING"] = "Gegenstand #%d (Wird geladen...)",
        ["SRC_SOURCES_HEADER"] = "Bezugsquellen & Vorkommen:",
        ["SRC_GATHER"] = "Sammeln",
        ["SRC_GATHER_DESC"] = "In der offenen Spielwelt an Vorkommen abgebaut oder gesammelt.",
        ["SRC_PROSPECT"] = "Sondieren",
        ["SRC_DISENCHANT"] = "Entzaubern",
        ["SRC_EXTRACT"] = "Gaswolken-Extraktion",
        ["SRC_EXTRACT_DESC"] = "Mit dem Partikelextraktor aus flüchtigen Gaswolken gewonnen.",
        ["SRC_TRANSMUTE"] = "Transmutation",
        ["SRC_SMELT"] = "Verhütten",
        ["SRC_CRAFT"] = "Herstellung",
        ["SRC_COMBINE"] = "Zusammensetzen",
        ["YIELDS_COUNT"] = "Ergibt %dx",
        ["SRC_MOB_DROP"] = "Gegnerbeute",
        ["SRC_MOB_DROP_DESC"] = "Beute von besiegten Kreaturen.",
        ["SRC_FISH"] = "Angeln",
        ["SRC_BYPRODUCT"] = "Nebenprodukt",
        ["SRC_INSTANCE"] = "Instanz- / Raidbeute",
        ["SRC_VENDOR"] = "Händlerkauf",
        ["CRUSHED_FROM"] = "Sondiert aus 5x",
        ["DISENCHANTED_FROM"] = "Entzaubert aus Gegenständen",
        ["DEVICE_REQUIRED"] = "Benötigtes Werkzeug",
        ["REAGENTS"] = "Reagenzien",
        ["NO_SPECIFIC_TIPS"] = "Keine speziellen Hinweise.",
        ["ATLAS_TIP_2770"] = "Reichlich in allen Startgebieten entlang von Berghängen und Höhlen.",
        ["ATLAS_TIP_2835"] = "Häufiges Nebenprodukt beim Abbau von Kupfervorkommen.",
        ["ATLAS_TIP_2771"] = "Häufig bei Gnoll- und Murloc-Lagern in Stufe 15-25 Gebieten.",
        ["ATLAS_TIP_2836"] = "Häufiges Nebenprodukt beim Abbau von Zinn- und Silbervorkommen.",
        ["ATLAS_TIP_2775"] = "Seltener Spawn, der Zinnvorkommen ersetzt.",
        ["ATLAS_TIP_2772"] = "Die Ränder des Arathihochlands und das Ödland sind die effizientesten Farmrouten.",
        ["ATLAS_TIP_2838"] = "Häufiges Nebenprodukt beim Abbau von Eisen- und Goldvorkommen.",
        ["ATLAS_TIP_2776"] = "Seltener Spawn, der Eisenvorkommen ersetzt.",
        ["ATLAS_TIP_3858"] = "Ödland-Ränder, Sengende Schlucht und Hinterland-Klippen bieten schnelle Respawn-Raten.",
        ["ATLAS_TIP_7912"] = "Wichtiges Nebenprodukt aus Mithril- und Echtsilbervorkommen.",
        ["ATLAS_TIP_7911"] = "Seltener Spawn, der Mithrilvorkommen ersetzt.",
        ["ATLAS_TIP_11370"] = "Ausschließlich im Schwarzfels, der Sengenden Schlucht und dem Geschmolzenen Kern zu finden.",
        ["ATLAS_TIP_10620"] = "Krater von Un'Goro und Winterquell-Gebirge bieten die höchste Dichte an Reichen Thoriumvorkommen.",
        ["ATLAS_TIP_12365"] = "Wichtiges Nebenprodukt aus Kleinen und Reichen Thoriumvorkommen.",
        ["ATLAS_TIP_23424"] = "Sehr häufig auf der Höllenfeuerhalbinsel; Klippen und Schluchten abfliegen.",
        ["ATLAS_TIP_23425"] = "Nagrand und Schergrat-Gebirge bieten erstklassige Sammelrouten für Reiche Vorkommen.",
        ["ATLAS_TIP_23426"] = "Extrem seltener Spawn, der Adamantitvorkommen in hochstufigen Scherbenwelt-Zonen ersetzt.",
        ["ATLAS_TIP_23427"] = "Seltenes Nebenprodukt beim Abbau von Adamantit- und Khoriumvorkommen.",
        ["ATLAS_TIP_23436"] = "Seltener roter Edelstein, sondiert aus Adamantiterz oder in Reichen Vorkommen gefunden.",
        ["ATLAS_TIP_23437"] = "Seltener grüner Edelstein, sondiert aus Adamantiterz oder in Khorium gefunden.",
        ["ATLAS_TIP_23438"] = "Seltener blauer Edelstein, sondiert aus Adamantiterz oder in Scherbenwelt-Vorkommen gefunden.",
        ["ATLAS_TIP_23439"] = "Seltener orangefarbener Edelstein, sondiert aus Adamantiterz oder in Reichen Vorkommen gefunden.",
        ["ATLAS_TIP_23440"] = "Seltener gelber Edelstein, sondiert aus Adamantiterz oder in Khorium gefunden.",
        ["ATLAS_TIP_23441"] = "Seltener lila Edelstein, sondiert aus Adamantiterz oder in Scherbenwelt-Vorkommen gefunden.",
        ["ATLAS_TIP_23077"] = "Ungewöhnlicher roter Edelstein, leicht durch Sondieren von Teufelseisen und Adamantit zu gewinnen.",
        ["ATLAS_TIP_23079"] = "Ungewöhnlicher grüner Edelstein, sondiert aus Teufelseisen- und Adamantiterz.",
        ["ATLAS_TIP_23107"] = "Ungewöhnlicher lila Edelstein, sondiert aus Teufelseisen- und Adamantiterz.",
        ["ATLAS_TIP_23112"] = "Ungewöhnlicher gelber Edelstein, sondiert aus Teufelseisen- und Adamantiterz.",
        ["ATLAS_TIP_23117"] = "Ungewöhnlicher blauer Edelstein, sondiert aus Teufelseisen- und Adamantiterz.",
        ["ATLAS_TIP_24243"] = "100% Nebenprodukt beim Sondieren von Adamantiterz; benötigt für Quecksilberadamantit.",
        ["ATLAS_TIP_2447"] = "Wächst in der Nähe von Bäumen und auf offenen Wiesen in Startgebieten.",
        ["ATLAS_TIP_765"] = "Wächst am Fuß von Bäumen in allen Stufe 1-10 Startgebieten.",
        ["ATLAS_TIP_2449"] = "Wächst entlang von Felsformationen, Schluchten und Hängen.",
        ["ATLAS_TIP_785"] = "Liefert häufig Flitzdisteln; zu finden in Stufe 10-20 Gebieten.",
        ["ATLAS_TIP_2450"] = "Hauptquelle für Flitzdisteln; wächst an Baumstämmen und Hecken.",
        ["ATLAS_TIP_2453"] = "Häufig an Hügeln und Grenzen zwischen niedrigstufigen Gebieten.",
        ["ATLAS_TIP_3820"] = "Wächst unter Wasser an Küsten und in Seen; unentbehrlich für Tränke der freien Aktion.",
        ["ATLAS_TIP_2452"] = "Wichtiges Reagenz für Schurken und Beweglichkeitstränke; Nebenprodukt bei Wilddornrosen und Maguskönigskraut.",
        ["ATLAS_TIP_3355"] = "Wächst ausschließlich auf felsigen Graten, Bergkuppen und Felsvorsprüngen.",
        ["ATLAS_TIP_3356"] = "Häufig in umkämpften Gebieten der Stufe 30-40 wie Arathi und Schlingendorntal.",
        ["ATLAS_TIP_3357"] = "Wächst an Süßwasser, Flüssen und Ufern in mittelstufigen Gebieten.",
        ["ATLAS_TIP_3358"] = "Häufig in Stufe 40-50 Gebieten unter Baumkronen.",
        ["ATLAS_TIP_3818"] = "Wichtig für Blendpulver der Schurken; versteckt in Büschen und Baumwurzeln.",
        ["ATLAS_TIP_3821"] = "Wertvolles Alchemie-Kraut auf Bergrücken und trockenen Hügeln.",
        ["ATLAS_TIP_3369"] = "Wächst auf Friedhöfen, Krypten und Lagern der Untoten.",
        ["ATLAS_TIP_3819"] = "Wächst in verschneiten Bergregionen, besonders im Alteracgebirge.",
        ["ATLAS_TIP_4625"] = "Wächst in heißen Wüstengebieten wie Tanaris, Ödland und Sengender Schlucht.",
        ["ATLAS_TIP_8831"] = "An uralten Ruinen in Tanaris, Feralas und Azshara; liefert Wildranken.",
        ["ATLAS_TIP_8153"] = "Wichtiges Reagenz für Rüstungen; Nebenprodukt bei Lila Lotus oder Beute von Trollen.",
        ["ATLAS_TIP_8836"] = "Verstreut in den verseuchten Pestländern und im Teufelswald.",
        ["ATLAS_TIP_8838"] = "Offene, sonnige Ebenen in Feralas und im Hinterland bieten die besten Sammelrouten.",
        ["ATLAS_TIP_8839"] = "Reichlich in Marschen und Sümpfen, besonders in den Düstermarschen.",
        ["ATLAS_TIP_8845"] = "Wächst in finsteren Höhlen, im Bau der Grimmtotem und im Versunkenen Tempel.",
        ["ATLAS_TIP_8846"] = "Wächst nahe Dämonenlagern im Teufelswald, den Verwüsteten Landen und Desolace.",
        ["ATLAS_TIP_13464"] = "Häufig im Krater von Un'Goro und im östlichen Teufelswald.",
        ["ATLAS_TIP_13463"] = "Zentrales Kraut für Raid-Elixiere; lange Sammelroute im Teufelswald und Un'Goro.",
        ["ATLAS_TIP_13465"] = "Wächst auf Bergkämmen in Winterquell und den Östlichen Pestländern.",
        ["ATLAS_TIP_13466"] = "Sehr begehrtes Fläschchen-Kraut; Ränder der Westlichen und Östlichen Pestländer.",
        ["ATLAS_TIP_13467"] = "Exklusiv in den Schneefeldern von Winterquell; wächst nur auf Eis und Schnee.",
        ["ATLAS_TIP_13468"] = "Extrem seltener Spawn in hochstufigen Classic-Zonen (Winterquell, Silithus, Östliche Pestländer, Brennende Steppe).",
        ["ATLAS_TIP_22785"] = "Wächst in allen Scherbenwelt-Zonen; hohe Chance auf Teufelslotus und Partikel des Lebens.",
        ["ATLAS_TIP_22786"] = "Wächst auf Klippen und Bergen auf der Höllenfeuerhalbinsel und in den Wäldern von Terokkar.",
        ["ATLAS_TIP_22787"] = "Sehr häufig in den Zangarmarschen rund um die riesigen Pilzstämme.",
        ["ATLAS_TIP_22788"] = "Wächst an Sporenkolonien in den Zangarmarschen; gewährt Feuerschaden-Buff.",
        ["ATLAS_TIP_22789"] = "Wächst am Fuß großer Nadelbäume in den Wäldern von Terokkar.",
        ["ATLAS_TIP_22790"] = "Wächst in Scherbenwelt-Dungeon-Instanzen (Tiefensumpf, Dampfkammer, Auchindoun).",
        ["ATLAS_TIP_22791"] = "Reichlich in den Ökodomen von Nethersturm; liefert Partikel des Manas.",
        ["ATLAS_TIP_22792"] = "Wächst im Schattenmondtal; fügt Giftschaden beim Pflücken zu und liefert Partikel des Lebens.",
        ["ATLAS_TIP_22793"] = "Wächst auf abgelegenen Hochebenen (Flugreittier erforderlich) in Terokkar, Nagrand und Nethersturm.",
        ["ATLAS_TIP_22794"] = "Seltener Bonus-Ertrag beim Sammeln von Scherbenwelt-Kräutern; Kernreagenz für Fläschchen.",
        ["ATLAS_TIP_2318"] = "Kürschnerbeute von Tieren in Stufe 1-15 Gebieten (Wölfe, Eber, Bären).",
        ["ATLAS_TIP_2319"] = "Kürschnerbeute von Tieren der Stufe 15-30 in Westfall, Dämmerwald und Hügelland.",
        ["ATLAS_TIP_4234"] = "Kürschnerbeute von Raptoren, Raubkatzen und Krokilisken im Schlingendorntal und Arathi.",
        ["ATLAS_TIP_4304"] = "Häufig bei Gorillas, Basilisken und Yetis in Feralas und Tanaris.",
        ["ATLAS_TIP_8170"] = "Kürschnerbeute von hochstufigen Wildtieren im Krater von Un'Goro und Winterquell.",
        ["ATLAS_TIP_15417"] = "Kürschnerbeute von den Elite-Teufelssauriern im Krater von Un'Goro.",
        ["ATLAS_TIP_25707"] = "Niederstufige Scherbenwelt-Lederfetzen; 5x zu einem Knotenhautleder kombinieren.",
        ["ATLAS_TIP_21887"] = "Hauptleder in TBC; reichlich von Talbuks, Grollhufen und Felshetzern in der Scherbenwelt.",
        ["ATLAS_TIP_25708"] = "Kürschnerbeute von großen Grollhufen in Nagrand und Schergrat; Kernreagenz für Beinrüstungen.",
        ["ATLAS_TIP_25700"] = "Kürschnerbeute von Falkenschreitern und Basilisken auf der Höllenfeuerhalbinsel und im Schattenmondtal.",
        ["ATLAS_TIP_29539"] = "Kürschnerbeute von Kobras und Schlangen in Nagrand und im Schattenmondtal.",
        ["ATLAS_TIP_29547"] = "Kürschnerbeute von Windnattern und Schimären im Schergrat.",
        ["ATLAS_TIP_29548"] = "Kürschnerbeute von Netherdrachen im Schattenmondtal und Nethersturm.",
        ["ATLAS_TIP_2589"] = "Beute von humanoiden Gegnern der Stufen 5-15 in allen Startgebieten.",
        ["ATLAS_TIP_2592"] = "Beute von Defias, Gnollen und Murlocs in Stufe 15-25 Gebieten.",
        ["ATLAS_TIP_4306"] = "Beute vom Syndikat, Dunkeleisenzwergen und Ogern in Stufe 25-40 Zonen.",
        ["ATLAS_TIP_4338"] = "Reichlich bei Ogern in Tanaris, Feralas und in Zul'Farrak.",
        ["ATLAS_TIP_14047"] = "Beute vom Scharlachroten Kreuzzug und der Geißel in den Pestländern.",
        ["ATLAS_TIP_14256"] = "Beute von hochstufigen Dämonen im Teufelswald (Jaedenar) und in Azshara.",
        ["ATLAS_TIP_21877"] = "Universeller TBC-Stoff, Beute aller humanoiden und dämonischen Gegner der Scherbenwelt.",
        ["ATLAS_TIP_22574"] = "Beute von Feuerelementaren im Schergrat oder mit dem Partikelextraktor gewonnen.",
        ["ATLAS_TIP_21884"] = "Aus 10x Partikel des Feuers zusammensetzen oder per Alchemie transmutieren (20h Cooldown).",
        ["ATLAS_TIP_22578"] = "Beute von Wasserelementaren in Skettis/Nagrand, geangelt im Reinen Wasser oder extrahiert aus Gaswolken.",
        ["ATLAS_TIP_21885"] = "Aus 10x Partikel des Wassers zusammensetzen; begehrtes Reagenz für Zauberstoff und Verzauberungen.",
        ["ATLAS_TIP_22572"] = "Beute von Luftelementaren auf dem Elementarplateau in Nagrand oder aus Gaswirbeln extrahiert.",
        ["ATLAS_TIP_22451"] = "Aus 10x Partikel der Luft zusammensetzen; Kernbestandteil epischer Waffen und Ingenieursbrillen.",
        ["ATLAS_TIP_22573"] = "Beute von Erdelementaren in Nagrand oder Nebenprodukt beim Abbau von Scherbenwelt-Erzen.",
        ["ATLAS_TIP_22452"] = "Aus 10x Partikel der Erde zusammensetzen; wichtiges Reagenz für Plattenschmiede.",
        ["ATLAS_TIP_22575"] = "Beute von Sumpflords in den Zangarmarschen, aus Sumpfgas extrahiert oder Nebenprodukt bei Kräutern.",
        ["ATLAS_TIP_21886"] = "Aus 10x Partikel des Lebens zusammensetzen; Kernreagenz für Urmondstoff.",
        ["ATLAS_TIP_22577"] = "Beute von Leerwandlern und Dämonen im Schattenmondtal oder aus Schattenwolken extrahiert.",
        ["ATLAS_TIP_22456"] = "Aus 10x Partikel des Schattens zusammensetzen; Kernreagenz für Schattenstoff und Fäden.",
        ["ATLAS_TIP_22576"] = "Beute von Manasuchern in Nethersturm oder aus Teufelsnebel-Gaswolken extrahiert.",
        ["ATLAS_TIP_22457"] = "Aus 10x Partikel des Manas zusammensetzen; benötigt für Zauberer-Ausrüstung und Urmacht.",
        ["ATLAS_TIP_23571"] = "Zentrales Transmutations-Reagenz von Alchemisten mit 20 Stunden Abklingzeit.",
        ["ATLAS_TIP_23572"] = "Beute von Endbossen heroischer Dungeons und Raids; kaufbar gegen Abzeichen der Gerechtigkeit.",
        ["ATLAS_TIP_30183"] = "Beute im Schlangenschrein und Festung der Stürme; kaufbar gegen Abzeichen der Gerechtigkeit.",
        ["ATLAS_TIP_10940"] = "Entzaubert aus grünen Rüstungen und Waffen der Stufe 1-20.",
        ["ATLAS_TIP_11083"] = "Entzaubert aus grünen Ausrüstungsgegenständen der Stufe 21-30.",
        ["ATLAS_TIP_11137"] = "Entzaubert aus grünen Ausrüstungsgegenständen der Stufe 31-40.",
        ["ATLAS_TIP_11176"] = "Entzaubert aus grünen Ausrüstungsgegenständen der Stufe 41-50.",
        ["ATLAS_TIP_16204"] = "Entzaubert aus grünen Ausrüstungsgegenständen der Stufe 51-60.",
        ["ATLAS_TIP_22445"] = "Entzaubert aus grünen Rüstungen und Waffen der Scherbenwelt (Stufe 58-70).",
        ["ATLAS_TIP_22447"] = "Entzaubert aus grünen Waffen der Stufe 58-65 in der Scherbenwelt.",
        ["ATLAS_TIP_22446"] = "Aus 3x Geringen Planar-Essenzen zusammensetzen oder Stufe 65-70 Ausrüstung entzaubern.",
        ["ATLAS_TIP_22448"] = "Entzaubert aus seltenen (blauen) Dungeon- und Quest-Items der Stufe 58-66.",
        ["ATLAS_TIP_22449"] = "Entzaubert aus seltenen (blauen) Dungeon-Boss-Drops der Stufe 67-70.",
        ["ATLAS_TIP_22450"] = "Entzaubert aus epischen (lila) Items in Karazhan, Gruul, Magtheridon und Heroics.",
        ["ATLAS_TIP_20725"] = "Entzaubert aus epischen Classic-Raid-Items der Stufe 60 (MC, BWL, AQ40, Naxx).",
        ["ATLAS_TIP_27671"] = "Gekocht zu Gerösteter Grollhuf (+20 Stärke); Beute von Grollhufen in Nagrand.",
        ["ATLAS_TIP_27677"] = "Gekocht zu Felshetzer-Hotdog (+40 Angriffskraft); Beute von Felshetzern.",
        ["ATLAS_TIP_27682"] = "Gekocht zu Talbuksteak (+20 Trefferwertung); Beute von Talbuks in Nagrand.",
        ["ATLAS_TIP_27681"] = "Gekocht zu Sphärenburger (+20 Beweglichkeit); Beute von Sphärenjägern in Terokkar.",
        ["ATLAS_TIP_27674"] = "Gekocht zu Basilisken-Eintopf (+23 Zaubermacht); Beute von Basilisken in Terokkar.",
        ["ATLAS_TIP_27429"] = "Geangelt in Sporenfischschwärmen in Zangarmarschen; gekocht für +20 Ausdauer und +8 MP5.",
        ["ATLAS_TIP_6358"] = "Geangelt an Küsten; unentbehrlich für Tränke der freien Aktion und Schattenöl.",
        ["ATLAS_TIP_6359"] = "Geangelt an Küsten; Kernreagenz für Feueröl und Elixiere der Feuermacht.",
        ["ATLAS_TIP_13422"] = "Geangelt im offenen Ozean bei Tanaris und Feralas; Kernreagenz für Große Steinschildtränke.",
        ["ATLAS_TIP_774"] = "Häufiger grüner Edelstein aus Kupfervorkommen oder durch Sondieren.",
        ["ATLAS_TIP_818"] = "Häufiger brauner Edelstein aus Kupfer- und Zinnvorkommen oder durch Sondieren.",
        ["ATLAS_TIP_1210"] = "Dunkler Edelstein aus Zinn- und Silbervorkommen oder durch Sondieren.",
        ["ATLAS_TIP_1705"] = "Schimmernder Edelstein aus Zinn-, Silber- und Eisenvorkommen oder durch Sondieren.",
        ["ATLAS_TIP_1206"] = "Grünlicher Edelstein aus Zinn-, Silber- und Eisenvorkommen oder durch Sondieren.",
        ["ATLAS_TIP_1529"] = "Wertvoller grüner Edelstein aus Eisen-, Gold- und Mithrilvorkommen oder durch Sondieren.",
        ["ATLAS_TIP_3864"] = "Goldgelber Edelstein aus Eisen-, Gold- und Mithrilvorkommen oder durch Sondieren.",
        ["ATLAS_TIP_7909"] = "Strahlend blauer Edelstein aus Mithril-, Echtsilber- und Thoriumvorkommen oder durch Sondieren.",
        ["ATLAS_TIP_7910"] = "Feuerroter Edelstein aus Mithril-, Echtsilber- und Thoriumvorkommen oder durch Sondieren.",
        ["ATLAS_TIP_12799"] = "Seltener schillernder Edelstein aus Thoriumvorkommen oder durch Sondieren.",
        ["ATLAS_TIP_12800"] = "Seltener grüner Edelstein aus Thoriumvorkommen oder durch Sondieren.",
        ["ATLAS_TIP_12361"] = "Seltener blauer Edelstein aus Thoriumvorkommen oder durch Sondieren.",
        ["ATLAS_TIP_12364"] = "Äußerst seltener Diamant aus Reichen Thoriumvorkommen oder durch Sondieren.",
        ["ATLAS_TIP_12363"] = "Wichtiger Katalysator für Arkanitbarren; seltener Fund in Reichen Thoriumvorkommen.",
        ["ATLAS_TIP_11382"] = "Extrem seltenes Handwerksreagenz aus Dunkeleisenvorkommen im Schwarzfels.",
        ["ATLAS_TIP_769"] = "Fällt von Wildschweinen in Startzonen; wird über offenem Feuer zu geröstetem Eberfleisch gebraten.",
        ["ATLAS_TIP_783"] = "Seltener Nebenprodukt-Balg beim Kürschnern von Stufe 1-20 Bestien in den Anfangsgebieten.",
        ["ATLAS_TIP_2672"] = "Beute von Jungwölfen in Startgebieten; ideal für die ersten Schritte in der Kochkunst.",
        ["ATLAS_TIP_2934"] = "Kürschnerei-Beute von Jungtieren in Startzonen; 3x ergeben Leichtes Leder via Lederverarbeitung.",
        ["ATLAS_TIP_3173"] = "Hinterlassen von Bären in Stufe 10-20 Zonen (Loch Modan, Dunkelküste); liefert nahrhaftes Bärensteak.",
        ["ATLAS_TIP_3730"] = "Erbeutet von mächtigen Bären im Hügelland, Eschenwald und Feralas; Zutat für saftiges Bärensteak.",
        ["ATLAS_TIP_4232"] = "Seltener Balg von Stufe 20-35 Bestien aus dem Schlingendorntal und Vorgebirge des Hügellands.",
        ["ATLAS_TIP_4235"] = "Ungewöhnlicher Balg von Stufe 35-45 Bestien in Arathi, Ödland und Schlingendorntal.",
        ["ATLAS_TIP_4603"] = "An den Küsten von Tanaris und Feralas gefischt; wichtiges Buff-Food für Stufe 45-60.",
        ["ATLAS_TIP_4655"] = "In Dickbauchmuscheln an den Küsten gefunden; gekocht zu sämiger Muschelsuppe.",
        ["ATLAS_TIP_6289"] = "Häufig in Binnengewässern der Stufe 1-20; dient zur Zubereitung nützlicher Ausdauer-Nahrung.",
        ["ATLAS_TIP_6291"] = "Geangelt in offenen Startgewässern ganz Azeroths; ideal für frühe Kochkunst-Stufen.",
        ["ATLAS_TIP_6303"] = "Wird an den Küsten der Anfangsgebiete aus dem Meer gefischt.",
        ["ATLAS_TIP_6308"] = "Häufig in Flüssen mittlerer Stufe (Dämmerwald, Hügelland, Sumpfland); vielseitiger Speisefisch.",
        ["ATLAS_TIP_6317"] = "Kommt exklusiv in den Gewässern von Loch Modan vor; wird zu Lochfrenzy-Delikatessen verarbeitet.",
        ["ATLAS_TIP_6361"] = "An den Küsten von Stufe 15-30 Zonen zu fangen; beliebt zum Steigern der Kochkunst.",
        ["ATLAS_TIP_6362"] = "Wird in Küstengewässern gefangen und zu Steinschuppenkabeljau verarbeitet.",
        ["ATLAS_TIP_6522"] = "Exklusiv in den Oasen des Brachlands und den Höhlen des Wehklagens; Zutat für pikante Deviat-Delikatessen.",
        ["ATLAS_TIP_6889"] = "Beute von Vögeln und Schreitern in Anfangsgebieten; unverzichtbare Zutat für Lebkuchen.",
        ["ATLAS_TIP_7067"] = "Beute von Erdelementaren im Ödland und Arathi; unverzichtbar für Große Naturschutztränke.",
        ["ATLAS_TIP_7068"] = "Beute von Feuerelementaren in der Sengenden Schlucht; essenziell für Große Feuerschutztränke.",
        ["ATLAS_TIP_7069"] = "Hinterlassen von Wirbelelementaren in Silithus und Arathi; Zutat für Beweglichkeitstränke.",
        ["ATLAS_TIP_7070"] = "Fällt von Wasserelementaren im Teufelswald und Schlingendorntal; Zutat für Große Frostschutztränke.",
        ["ATLAS_TIP_7075"] = "Fällt von tief unterirdischen Erdelementaren in Maraudon, dem Ödland und Silithus.",
        ["ATLAS_TIP_7076"] = "Hochstufige Essenz von Erdelementaren aus Silithus und Un'Goro; Zutat für Rüstungen und Schleifsteine.",
        ["ATLAS_TIP_7077"] = "Beute von Geschmolzenen Riesen und Feuerelementaren im Geschmolzenen Kern und der Sengenden Schlucht.",
        ["ATLAS_TIP_7078"] = "Hinterlassen von hochstufigen Feuerelementaren im Krater von Un'Goro und MC; wichtig für Feurige Waffe.",
        ["ATLAS_TIP_7079"] = "Erbeutet von Höheren Wasserelementaren an den Seen der Östlichen Pestländer und des Teufelswalds.",
        ["ATLAS_TIP_7080"] = "Wertvolle Essenz von Wasserelementaren im Teufelswald; benötigt für Fläschchen der obersten Macht.",
        ["ATLAS_TIP_7081"] = "Beute von Wirbelsturm-Elementaren in Silithus und den Westlichen Pestländern.",
        ["ATLAS_TIP_7082"] = "Hochbegehrte Essenz von Luftwirblern in Silithus; Schlüsselkomponente für Waffenverzauberung Beweglichkeit.",
        ["ATLAS_TIP_8167"] = "Gekürschnert von Schnappschildkröten an den Küsten von Tanaris und dem Hinterland.",
        ["ATLAS_TIP_8169"] = "Seltener Balg beim Häuten von Stufe 45-55 Bestien in Feralas, Tanaris und dem Hinterland.",
        ["ATLAS_TIP_8171"] = "Kostbarer Balg von Stufe 55-60 Bestien in Winterquell und Un'Goro; Zutat für Kernrüstungssets.",
        ["ATLAS_TIP_8364"] = "Häufig in Binnenseen und Flüssen höherer Stufe (Schlingendorntal, Feralas, Hinterland).",
        ["ATLAS_TIP_10938"] = "Entzaubert aus Stufe 1-10 grünen Waffen; 3x lassen sich zu einer Großen Magieessenz vereinen.",
        ["ATLAS_TIP_10939"] = "Entzaubert aus Stufe 11-15 grünen Waffen oder direkt im Inventar aus 3x Geringen Magieessenzen hergestellt.",
        ["ATLAS_TIP_10978"] = "Entzaubert aus Stufe 15-20 seltenen (blauen) Gegenständen aus Todesminen und Höhlen des Wehklagens.",
        ["ATLAS_TIP_10998"] = "Entzaubert aus Stufe 16-20 grünen Waffen; 3x lassen sich zu einer Großen Astralessenz vereinen.",
        ["ATLAS_TIP_11082"] = "Entzaubert aus Stufe 21-25 grünen Waffen oder aus 3x Geringen Astralessenzen kombiniert.",
        ["ATLAS_TIP_11084"] = "Entzaubert aus Stufe 21-25 seltenen (blauen) Gegenständen (Burg Schattenfang, Tiefschwarze Grotte).",
        ["ATLAS_TIP_11134"] = "Entzaubert aus Stufe 26-30 grünen Waffen; 3x lassen sich zu einer Großen Mystikeressenz vereinen.",
        ["ATLAS_TIP_11135"] = "Entzaubert aus Stufe 31-35 grünen Waffen oder aus 3x Geringen Mystikeressenzen kombiniert.",
        ["ATLAS_TIP_11138"] = "Entzaubert aus Stufe 26-30 seltenen (blauen) Dungeon-Gegenständen (Gnomeregan, Scharlachrotes Kloster).",
        ["ATLAS_TIP_11139"] = "Entzaubert aus Stufe 31-35 seltenen Dungeon-Gegenständen (Kral von Klingenhauer, Waffenkammer).",
        ["ATLAS_TIP_11174"] = "Entzaubert aus Stufe 36-40 grünen Waffen; 3x lassen sich zu einer Großen Netheressenz vereinen.",
        ["ATLAS_TIP_11175"] = "Entzaubert aus Stufe 41-45 grünen Waffen oder aus 3x Geringen Netheressenzen kombiniert.",
        ["ATLAS_TIP_11177"] = "Entzaubert aus Stufe 36-40 seltenen Gegenständen aus Uldaman und der Scharlachroten Kathedrale.",
        ["ATLAS_TIP_11178"] = "Entzaubert aus Stufe 41-45 seltenen Dungeon-Funden aus Zul'Farrak und Maraudon.",
        ["ATLAS_TIP_12184"] = "Beute von Raptoren im Arathihochland und Schlingendorntal; gebraten zu herzhaftem Raptorfleisch.",
        ["ATLAS_TIP_12202"] = "Erbeutet von Tigern und Panthern im Schlingendorntal; ergibt zartes Tigerfleisch.",
        ["ATLAS_TIP_12208"] = "Beute von Stufe 40-55 Wölfen im Hinterland und Teufelswald; gekocht zu Zartem Wolfssteak (+12 Ausdauer).",
        ["ATLAS_TIP_12803"] = "Beute von Baum- und Pflanzenkreaturen im Teufelswald und Un'Goro; Lebens-Transmutationen.",
        ["ATLAS_TIP_12808"] = "Hinterlassen von hochstufigen Untoten der Geißel in den Pestländern, Stratholme und Scholomance.",
        ["ATLAS_TIP_13754"] = "Hochstufiger Hochseefisch aus Azshara, Feralas und Tanaris; gewährt wertvollen Ausdauerbuff.",
        ["ATLAS_TIP_13755"] = "Saisonaler Küstenfang in den Wintermonaten; gewährt gekocht einen geschätzten +10 Beweglichkeitsbuff.",
        ["ATLAS_TIP_13756"] = "Saisonaler Sommerfang an Classic-Küsten; nahrhafter Speisefisch für hochstufige Abenteurer.",
        ["ATLAS_TIP_13758"] = "In den unheilvollen Flüssen der Östlichen Pestländer und des Teufelswalds gefischt.",
        ["ATLAS_TIP_13759"] = "Wird vor allem nachts (18:00 - 06:00) gefischt; begehrte Zutat für Mana-Regenerations-Suppe (MP5).",
        ["ATLAS_TIP_13760"] = "Wird überwiegend tagsüber (06:00 - 18:00) gefangen; liefert gekocht dauerhafte Lebensregeneration.",
        ["ATLAS_TIP_13889"] = "Edler Fang für Meisterangler in den eisigen Bergseen von Winterquell und Pestländern.",
        ["ATLAS_TIP_14342"] = "Von Schneidern an einem Mondbrunnen aus 2x Teufelsstoff gewoben (4 Tage CD); Zutat für Mondstofftaschen.",
        ["ATLAS_TIP_14343"] = "Entzaubert aus Stufe 46-50 seltenen Gegenständen; 3x lassen sich durch Verzauberkunst vereinen.",
        ["ATLAS_TIP_14344"] = "Entzaubert aus Stufe 51-60 seltenen Instanzfunden (BRD, Strat, Scholo); Kernstück von Classic-Enchants.",
        ["ATLAS_TIP_15412"] = "Erbeutet von grünen Großdrachen im Versunkenen Tempel und den Düstermarschen.",
        ["ATLAS_TIP_15414"] = "Gekürschnert von roten Drachenbruten im Sumpfland; Zutat für Drachenschuppen-Rüstungen.",
        ["ATLAS_TIP_15415"] = "Gekürschnert von blauen Drachenbruten in Winterquell und Azshara; für Frostwiderstands-Rüstung.",
        ["ATLAS_TIP_15416"] = "Von schwarzen Drachenbruten in der Brennenden Steppe gekürschnert; essenziell für Onyxiaschuppenumhänge.",
        ["ATLAS_TIP_15419"] = "Von tollwütigen Seuchenbären in den Pestländern gekürschnert; Zutat für das Kriegsbärenharnisch-Set.",
        ["ATLAS_TIP_16202"] = "Entzaubert aus Stufe 46-50 grünen Waffen; 3x lassen sich zu einer Großen ewigen Essenz vereinen.",
        ["ATLAS_TIP_16203"] = "Entzaubert aus Stufe 51-60 grünen Waffen; Kernreagenz für Classic-Waffenverzauberungen.",
        ["ATLAS_TIP_17012"] = "Exklusives Raid-Leder von Kernhunden und Magmadar im Geschmolzenen Kern (Kürschnern 310 erforderlich).",
        ["ATLAS_TIP_18562"] = "Extrem seltenes Erz von Technikern der Pechschwingen im BWL; benötigt zur Herstellung von Elementiumbarren für Donnerzorn.",
        ["ATLAS_TIP_20424"] = "Beute von Sandwürmern in Silithus; Zutat für Geräucherte Wüstenknödel (+20 Stärke, bester Melee-Buff).",
        ["ATLAS_TIP_21845"] = "Von Mondstoffschneidern an Mondbrunnen gewoben (3 Tage 20h CD); unverzichtbar für Heiler-Sets.",
        ["ATLAS_TIP_21929"] = "Ungewöhnlicher orangefarbener Edelstein aus Teufelseisen- und Adamantitvorkommen; geschliffen für Trefferwertung.",
        ["ATLAS_TIP_23793"] = "Hergestellt von Lederverarbeitern (Stufe 325) aus 5x Knotenhautleder; Basis für TBC-Rüstungssets.",
        ["ATLAS_TIP_24271"] = "Von Feuerschneidern an Nethersturm-Manaschmieden gewoben (3 Tage 20h CD); Kernstück für Magier und Hexenmeister.",
        ["ATLAS_TIP_24272"] = "Am Altar der Schatten im Schattenmondtal gewoben (3 Tage 20h CD); Spezialstoff für Schattenpriester und Hexer.",
        ["ATLAS_TIP_24477"] = "Aus Jaggalmuscheln in Zangarmarschen gefischt; Zutat für Muschelriegel (+20 Stärke).",
        ["ATLAS_TIP_25649"] = "Kürschnerei-Beute von Scherbenwelt-Bestien; 5x ergeben ein Knotenhautleder via Lederverarbeitung.",
        ["ATLAS_TIP_25699"] = "Gekürschnert von Kristallschindern und Steinhäutern im Schergrat.",
        ["ATLAS_TIP_25867"] = "Metagedelstein-Rohling, alchemistisch transmutiert aus Tiefenperidot, Schattendraenit, Golddraenit und Urmächten.",
        ["ATLAS_TIP_25868"] = "Metagedelstein-Rohling, transmutiert aus Blutgranat, Flammenspessarit, Azurmondstein, Urfeuer und Urluft.",
        ["ATLAS_TIP_27422"] = "Häufiger Flussfisch in den Zangarmarschen und Wäldern von Terokkar; wichtige Kochzutat.",
        ["ATLAS_TIP_27425"] = "Weit verbreitet in den Binnenseen der Scherbenwelt; ideal zum Steigern der Kochkunst.",
        ["ATLAS_TIP_27435"] = "In den klaren Seen von Nagrand gefischt; gekocht eine geschätzte Speise für Zauberwirker.",
        ["ATLAS_TIP_27437"] = "Aus Blauflossenschwärmen in Nagrand und Nethersturm gefischt; liefert pochiert +23 Zaubermacht.",
        ["ATLAS_TIP_27438"] = "Aus Hochland-Mischschwärmen in Terokkar gefischt; gekocht zu Goldenen Fischstäbchen (+44 Heilung).",
        ["ATLAS_TIP_27439"] = "Seltener Fang in Skettis (Flugreittier nötig); gekocht zu Würzigem Flusskrebs (+30 Ausdauer, bester Tank-Buff).",
        ["ATLAS_TIP_27678"] = "Beute von massiven Grollhufen in Nagrand; gekocht zu Geröstetem Grollhuf (+20 Stärke & Willenskraft).",
        ["ATLAS_TIP_31671"] = "Beute von Schlangen und Schuppenflüglern im Schergrat; gekocht zu Knuspriger Schlange (+23 Zaubermacht).",
        ["ATLAS_TIP_32464"] = "Auf der Netherscherbe im Schattenmondtal abgebaut; dient den Fraktionsquests der Netherschwingen.",
    },
}

function Journal:GetLocaleText(key)
	if not key then return "" end
	local loc = GetLocale()
	if self.Locales[loc] and self.Locales[loc][key] then
		return self.Locales[loc][key]
	end
	if self.Locales["enUS"] and self.Locales["enUS"][key] then
		return self.Locales["enUS"][key]
	end
	return key
end

-- ============================================================================
-- 3. Category Info Resolution
-- ============================================================================
function Journal:GetCategoryInfo(catKey)
	if not self.Categories or not catKey then
		return catKey or "", "Interface\\Icons\\INV_Misc_QuestionMark"
	end
	local cat = nil
	if type(self.Categories) == "table" then
		if self.Categories[catKey] and type(self.Categories[catKey]) == "table" then
			cat = self.Categories[catKey]
		else
			for _, c in ipairs(self.Categories) do
				if c.key == catKey then cat = c; break end
			end
		end
	end
	if not cat then
		return self:GetLocaleText("CAT_" .. tostring(catKey)) or tostring(catKey), "Interface\\Icons\\INV_Misc_QuestionMark"
	end

	local name = nil
	if cat.spellID and GetSpellInfo then
		name = GetSpellInfo(cat.spellID)
	elseif cat.itemClass and cat.itemSubClass and GetItemSubClassInfo then
		name = GetItemSubClassInfo(cat.itemClass, cat.itemSubClass)
	end

	if not name or name == "" then
		name = self:GetLocaleText("CAT_" .. tostring(catKey)) or cat.name or catKey
	end

	return name, cat.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- ============================================================================
-- 4. Item Details & Cache Management
-- ============================================================================
local itemDetailsCache = {}

function Journal:GetItemDetails(itemID)
	if not itemID or itemID == 0 then
		return { id = 0, name = "Unknown", icon = "Interface\\Icons\\INV_Misc_QuestionMark", quality = 1, link = nil }
	end
	if itemDetailsCache[itemID] then return itemDetailsCache[itemID] end

	local name, link, quality, _, _, _, _, _, _, icon = GetItemInfo(itemID)
	if name then
		local res = {
			id = itemID,
			name = name,
			link = link,
			quality = quality or 1,
			icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark",
		}
		itemDetailsCache[itemID] = res
		return res
	end

	return {
		id = itemID,
		name = string.format(self:GetLocaleText("ITEM_LOADING") or "Item #%d", itemID),
		link = nil,
		quality = 1,
		icon = "Interface\\Icons\\INV_Misc_QuestionMark",
	}
end

-- ============================================================================
-- 5. Zone & Tip Metadata Resolution
-- ============================================================================
local zoneNameCache = {}

function Journal:GetZoneName(areaID)
	if not areaID then return "World" end
	if zoneNameCache[areaID] then return zoneNameCache[areaID] end

	local name = nil
	if C_Map and C_Map.GetAreaInfo then
		name = C_Map.GetAreaInfo(areaID)
	end
	if not name and areaID == 0 then
		name = "World"
	end

	local res = name or string.format("Zone #%d", areaID)
	zoneNameCache[areaID] = res
	return res
end

function Journal:GetTip(entryOrID)
	local entry = type(entryOrID) == "table" and entryOrID or self:FindResource(entryOrID)
	if entry and entry.tipKey then
		return self:GetLocaleText(entry.tipKey)
	end
	return self:GetLocaleText("NO_SPECIFIC_TIPS") or "No specific notes."
end

function Journal:GetMinSkill(entryOrID)
	local entry = type(entryOrID) == "table" and entryOrID or self:FindResource(entryOrID)
	if not entry or not entry.sources then return nil end

	-- 1. Prioritize primary gathering / extraction / fishing sources
	for _, src in ipairs(entry.sources) do
		if (src.type == "GATHER" or src.type == "EXTRACT" or src.type == "FISH") and src.skill and src.skill > 0 then
			return src.skill
		end
	end

	-- 2. Fall back to other sources with explicit skill
	local minSkill = 999
	for _, src in ipairs(entry.sources) do
		if src.skill and src.skill > 0 and src.skill < minSkill then
			minSkill = src.skill
		end
	end
	return minSkill < 999 and minSkill or nil
end

function Journal:GetSources(entryOrID)
	local entry = type(entryOrID) == "table" and entryOrID or self:FindResource(entryOrID)
	return entry and entry.sources or {}
end

function Journal:GetYields(entryOrID)
	local entry = type(entryOrID) == "table" and entryOrID or self:FindResource(entryOrID)
	return entry and entry.yields or {}
end

-- ============================================================================
-- 6. Category & Search Filtering
-- ============================================================================
function Journal:MatchesCategory(entry, categoryKey)
	if not categoryKey or categoryKey == "ALL" or categoryKey == "All" then
		return true
	end
	if entry.category == categoryKey then
		return true
	end

	-- Cross-discipline polymorphic source resolution
	if entry.sources then
		for _, src in ipairs(entry.sources) do
			if categoryKey == "MINING" and (src.type == "GATHER" or src.type == "SMELT") and entry.category == "MINING" then
				return true
			elseif categoryKey == "HERBALISM" and src.type == "GATHER" and entry.category == "HERBALISM" then
				return true
			elseif categoryKey == "SKINNING" and (src.type == "GATHER" or src.type == "MOB_DROP" or src.type == "CRAFT") and entry.category == "SKINNING" then
				return true
			elseif categoryKey == "ENCHANTING" and (src.type == "DISENCHANT" or src.type == "CRAFT") and entry.category == "ENCHANTING" then
				return true
			elseif categoryKey == "ENGINEERING" and src.type == "EXTRACT" then
				return true
			elseif categoryKey == "FISHING" and src.type == "FISH" then
				return true
			elseif categoryKey == "COOKING" and entry.category == "COOKING" then
				return true
			elseif categoryKey == "CLOTH" and entry.category == "CLOTH" then
				return true
			elseif categoryKey == "ELEMENTAL" and (entry.category == "ELEMENTAL" or src.type == "EXTRACT" or src.type == "TRANSMUTE") then
				return true
			end
		end
	end

	return false
end

function Journal:MatchesSearch(entry, query)
	if not query or query == "" then return true end
	local q = query:lower():trim()

	local details = self:GetItemDetails(entry.id)
	if details.name and details.name:lower():find(q, 1, true) then
		return true
	end

	if tostring(entry.id):find(q, 1, true) then
		return true
	end

	if entry.sources then
		for _, src in ipairs(entry.sources) do
			if src.zones then
				for _, aId in ipairs(src.zones) do
					local zName = self:GetZoneName(aId)
					if zName and zName:lower():find(q, 1, true) then
						return true
					end
				end
			end
		end
	end

	return false
end

-- ============================================================================
-- 7. Public Query & Retrieval API
-- ============================================================================
function Journal:GetAll()
	return self.Data or {}
end

function Journal:Search(query, category)
	local results = {}
	if not self.Data then return results end
	for _, entry in ipairs(self.Data) do
		if self:MatchesCategory(entry, category) and self:MatchesSearch(entry, query) then
			table.insert(results, entry)
		end
	end
	return results
end

function Journal:FindResource(identifier)
	if not identifier or not self.Data then return nil end

	if type(identifier) == "number" then
		for _, entry in ipairs(self.Data) do
			if entry.id == identifier then return entry end
		end
		return nil
	end

	local lower = tostring(identifier):lower():trim()
	for _, entry in ipairs(self.Data) do
		local d = self:GetItemDetails(entry.id)
		if d.name and d.name:lower() == lower then
			return entry
		end
	end

	for _, entry in ipairs(self.Data) do
		local d = self:GetItemDetails(entry.id)
		if d.name and d.name:lower():find(lower, 1, true) then
			return entry
		end
	end

	return nil
end

function Journal:GetDisplayName(entry)
	if not entry then return "" end
	local id = type(entry) == "table" and entry.id or entry
	local details = self:GetItemDetails(id)
	return details.name or string.format("Item #%d", id)
end

function Journal:GetItemDisplayName(entry)
	return self:GetDisplayName(entry)
end

-- ============================================================================
-- 8. Asynchronous Cache Priming & Event Frame
-- ============================================================================
local isPrimed = false

function Journal:PrimeCache()
	if isPrimed or not self.Data then return end
	isPrimed = true

	for _, entry in ipairs(self.Data) do
		if C_Item and C_Item.RequestLoadItemDataByID then
			C_Item.RequestLoadItemDataByID(entry.id)
		else
			GetItemInfo(entry.id)
		end

		if entry.sources then
			for _, src in ipairs(entry.sources) do
				if src.fromItems then
					for _, fId in ipairs(src.fromItems) do
						if C_Item and C_Item.RequestLoadItemDataByID then
							C_Item.RequestLoadItemDataByID(fId)
						else
							GetItemInfo(fId)
						end
					end
				end
				if src.device then
					if C_Item and C_Item.RequestLoadItemDataByID then
						C_Item.RequestLoadItemDataByID(src.device)
					else
						GetItemInfo(src.device)
					end
				end
			end
		end

		if entry.yields then
			for _, yId in ipairs(entry.yields) do
				if C_Item and C_Item.RequestLoadItemDataByID then
					C_Item.RequestLoadItemDataByID(yId)
				else
					GetItemInfo(yId)
				end
			end
		end
	end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")

local refreshPending = false
eventFrame:SetScript("OnEvent", function(self, event, arg1)
	if event == "PLAYER_ENTERING_WORLD" then
		Journal:PrimeCache()
	elseif event == "GET_ITEM_INFO_RECEIVED" then
		if itemDetailsCache[arg1] then
			itemDetailsCache[arg1] = nil
		end
		if not refreshPending then
			refreshPending = true
			C_Timer.After(0.3, function()
				refreshPending = false
				Journal:FireCallback("ON_DATA_READY")
			end)
		end
	end
end)