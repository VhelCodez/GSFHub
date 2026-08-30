--[[--------------------------------------------------------------------------
  AtlasJournal
  Standalone Classic & TBC Resource & Gathering Compendium Library
  Version: 1.0.0
----------------------------------------------------------------------------]]
local MAJOR, MINOR = "LibAtlasJournal-1.0", 1
local lib = LibStub and LibStub:NewLibrary(MAJOR, MINOR)

AtlasJournal = lib or AtlasJournal or {}
local Journal = AtlasJournal

Journal.version = "1.0.0"

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
        ["SRC_COMBINE"] = "Combine",
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
        ["ATLAS_TIP_32468"] = "Mined around Netherwing Ledge in Shadowmoon Valley (Netherwing reputation).",
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
        ["ATLAS_TIP_2453"] = "Crucial Rogue and Agility potion reagent; gathered from Briarthorn and Mageroyal.",
        ["ATLAS_TIP_3820"] = "Found underwater along coastlines and lakes; essential for Free Action Potions.",
        ["ATLAS_TIP_2452"] = "Common along hills and borders between low-level territories.",
        ["ATLAS_TIP_3355"] = "Spawns exclusively on high ridges, rocky summits, and mountain outcroppings.",
        ["ATLAS_TIP_3356"] = "Harvested around graveyards, crypts, and undead camps.",
        ["ATLAS_TIP_3357"] = "Abundant across level 30-40 contested zones like Arathi and Stranglethorn.",
        ["ATLAS_TIP_3358"] = "Grows near fresh water, rivers, and riverbanks in mid-level zones.",
        ["ATLAS_TIP_3818"] = "Essential for Rogue blinding powder; found hidden in bushes and tree roots.",
        ["ATLAS_TIP_3821"] = "High-value Alchemy herb found on mountain ridges and arid hills.",
        ["ATLAS_TIP_3369"] = "Common in level 40-50 zones under tree canopies.",
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
        ["ATLAS_TIP_15415"] = "Skinned from elite Devilsaurs patrolling Un'Goro Crater.",
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
        ["ATLAS_TIP_27432"] = "Caught in Skettis and high mountain lakes (requires flying mount); cooked for +30 Stamina.",
        ["ATLAS_TIP_27434"] = "Caught in Terokkar rivers; cooked into Golden Fish Sticks (+44 Healing Power).",
        ["ATLAS_TIP_27431"] = "Caught in Zangarmarsh and Nagrand lakes; cooked for +23 Spell Power.",
        ["ATLAS_TIP_27429"] = "Caught in Sporefish schools in Zangarmarsh; cooked for +20 Stamina and +8 MP5.",
        ["ATLAS_TIP_6370"] = "Fished in coastal schools; essential for Free Action Potions and Shadow Oil.",
        ["ATLAS_TIP_6371"] = "Fished in coastal schools; key reagent for Fire Oil and Fire Power elixirs.",
        ["ATLAS_TIP_13422"] = "Caught in open ocean swarms in Tanaris and Feralas; core reagent for Greater Stoneshield Potion.",
    },
    ["deDE"] = {
        ["REAGENTS_REQUIRED"] = "BenÃ¶tigte Reagenzien:",
        ["CAT_ALL"] = "Alle Kategorien",
        ["CAT_MINING"] = "Bergbau",
        ["CAT_HERBALISM"] = "KrÃ¤uterkunde",
        ["CAT_SKINNING"] = "KÃ¼rschnerei",
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
        ["SRC_EXTRACT_DESC"] = "Mit dem Partikelextraktor aus flÃ¼chtigen Gaswolken gewonnen.",
        ["SRC_TRANSMUTE"] = "Transmutation",
        ["SRC_SMELT"] = "VerhÃ¼tten",
        ["SRC_COMBINE"] = "Zusammensetzen",
        ["SRC_MOB_DROP"] = "Gegnerbeute",
        ["SRC_MOB_DROP_DESC"] = "Beute von besiegten Kreaturen.",
        ["SRC_FISH"] = "Angeln",
        ["SRC_BYPRODUCT"] = "Beifang",
        ["SRC_INSTANCE"] = "Instanz- / Raidbeute",
        ["SRC_VENDOR"] = "HÃ¤ndlerkauf",
        ["CRUSHED_FROM"] = "Sondiert aus 5x",
        ["DISENCHANTED_FROM"] = "Entzaubert aus GegenstÃ¤nden",
        ["DEVICE_REQUIRED"] = "BenÃ¶tigtes Werkzeug",
        ["REAGENTS"] = "Reagenzien",
        ["NO_SPECIFIC_TIPS"] = "Keine speziellen Hinweise.",
        ["ATLAS_TIP_2770"] = "Reichlich in allen Startgebieten entlang von BerghÃ¤ngen und HÃ¶hlen.",
        ["ATLAS_TIP_2835"] = "HÃ¤ufiger Beifang beim Abbau von Kupfervorkommen.",
        ["ATLAS_TIP_2771"] = "HÃ¤ufig bei Gnoll- und Murloc-Lagern in Stufe 15-25 Gebieten.",
        ["ATLAS_TIP_2836"] = "HÃ¤ufiger Beifang beim Abbau von Zinn- und Silbervorkommen.",
        ["ATLAS_TIP_2775"] = "Seltener Spawn, der Zinnvorkommen ersetzt.",
        ["ATLAS_TIP_2772"] = "Die RÃ¤nder des Arathihochlands und das Ã–dland sind die effizientesten Farmrouten.",
        ["ATLAS_TIP_2838"] = "HÃ¤ufiger Beifang beim Abbau von Eisen- und Goldvorkommen.",
        ["ATLAS_TIP_2776"] = "Seltener Spawn, der Eisenvorkommen ersetzt.",
        ["ATLAS_TIP_3858"] = "Ã–dland-RÃ¤nder, Sengende Schlucht und Hinterland-Klippen bieten schnelle Respawn-Raten.",
        ["ATLAS_TIP_7912"] = "Wichtiger Stein-Beifang aus Mithril- und Echtsilbervorkommen.",
        ["ATLAS_TIP_7911"] = "Seltener Spawn, der Mithrilvorkommen ersetzt.",
        ["ATLAS_TIP_11370"] = "AusschlieÃŸlich im Schwarzfels, der Sengenden Schlucht und dem Geschmolzenen Kern zu finden.",
        ["ATLAS_TIP_10620"] = "Krater von Un'Goro und Winterquell-Gebirge bieten die hÃ¶chste Dichte an Reichen Thoriumvorkommen.",
        ["ATLAS_TIP_12365"] = "Wichtiger Stein-Beifang aus Kleinen und Reichen Thoriumvorkommen.",
        ["ATLAS_TIP_23424"] = "Sehr hÃ¤ufig auf der HÃ¶llenfeuerhalbinsel; Klippen und Schluchten abfliegen.",
        ["ATLAS_TIP_23425"] = "Nagrand und Schergrat-Gebirge bieten erstklassige Sammelrouten fÃ¼r Reiche Vorkommen.",
        ["ATLAS_TIP_23426"] = "Extrem seltener Spawn, der Adamantitvorkommen in hochstufigen Scherbenwelt-Zonen ersetzt.",
        ["ATLAS_TIP_23427"] = "Seltener Beifang beim Abbau von Adamantit- und Khoriumvorkommen.",
        ["ATLAS_TIP_32468"] = "Abgebaut auf der Netherschwingenscherbe im Schattenmondtal (Netherschwingen-Ruf).",
        ["ATLAS_TIP_23436"] = "Seltener roter Edelstein, sondiert aus Adamantiterz oder in Reichen Vorkommen gefunden.",
        ["ATLAS_TIP_23437"] = "Seltener grÃ¼ner Edelstein, sondiert aus Adamantiterz oder in Khorium gefunden.",
        ["ATLAS_TIP_23438"] = "Seltener blauer Edelstein, sondiert aus Adamantiterz oder in Scherbenwelt-Vorkommen gefunden.",
        ["ATLAS_TIP_23439"] = "Seltener orangefarbener Edelstein, sondiert aus Adamantiterz oder in Reichen Vorkommen gefunden.",
        ["ATLAS_TIP_23440"] = "Seltener gelber Edelstein, sondiert aus Adamantiterz oder in Khorium gefunden.",
        ["ATLAS_TIP_23441"] = "Seltener lila Edelstein, sondiert aus Adamantiterz oder in Scherbenwelt-Vorkommen gefunden.",
        ["ATLAS_TIP_23077"] = "UngewÃ¶hnlicher roter Edelstein, leicht durch Sondieren von Teufelseisen und Adamantit zu gewinnen.",
        ["ATLAS_TIP_23079"] = "UngewÃ¶hnlicher grÃ¼ner Edelstein, sondiert aus Teufelseisen- und Adamantiterz.",
        ["ATLAS_TIP_23107"] = "UngewÃ¶hnlicher lila Edelstein, sondiert aus Teufelseisen- und Adamantiterz.",
        ["ATLAS_TIP_23112"] = "UngewÃ¶hnlicher gelber Edelstein, sondiert aus Teufelseisen- und Adamantiterz.",
        ["ATLAS_TIP_23117"] = "UngewÃ¶hnlicher blauer Edelstein, sondiert aus Teufelseisen- und Adamantiterz.",
        ["ATLAS_TIP_24243"] = "100% Beifang beim Sondieren von Adamantiterz; benÃ¶tigt fÃ¼r Quecksilberadamantit.",
        ["ATLAS_TIP_2447"] = "WÃ¤chst in der NÃ¤he von BÃ¤umen und auf offenen Wiesen in Startgebieten.",
        ["ATLAS_TIP_765"] = "WÃ¤chst am FuÃŸ von BÃ¤umen in allen Stufe 1-10 Startgebieten.",
        ["ATLAS_TIP_2449"] = "WÃ¤chst entlang von Felsformationen, Schluchten und HÃ¤ngen.",
        ["ATLAS_TIP_785"] = "Liefert hÃ¤ufig Flitzdisteln; zu finden in Stufe 10-20 Gebieten.",
        ["ATLAS_TIP_2450"] = "Hauptquelle fÃ¼r Flitzdisteln; wÃ¤chst an BaumstÃ¤mmen und Hecken.",
        ["ATLAS_TIP_2453"] = "Wichtiges Reagenz fÃ¼r Schurken und BeweglichkeitstrÃ¤nke; Beifang bei Wilddornrosen und MaguskÃ¶nigskraut.",
        ["ATLAS_TIP_3820"] = "WÃ¤chst unter Wasser an KÃ¼sten und in Seen; unentbehrlich fÃ¼r TrÃ¤nke der freien Aktion.",
        ["ATLAS_TIP_2452"] = "HÃ¤ufig an HÃ¼geln und Gebietsgrenzen niederstufiger Zonen.",
        ["ATLAS_TIP_3355"] = "WÃ¤chst ausschlieÃŸlich auf felsigen Graten, Bergkuppen und FelsvorsprÃ¼ngen.",
        ["ATLAS_TIP_3356"] = "WÃ¤chst um FriedhÃ¶fe, Gruften und Untoten-Lager.",
        ["ATLAS_TIP_3357"] = "Reichlich in umkÃ¤mpften Stufe 30-40 Zonen wie Arathi und Schlingendorntal.",
        ["ATLAS_TIP_3358"] = "WÃ¤chst an SÃ¼ÃŸwasser, FlÃ¼ssen und Ufern in mittelstufigen Gebieten.",
        ["ATLAS_TIP_3818"] = "Wichtig fÃ¼r Blendpulver der Schurken; versteckt in BÃ¼schen und Baumwurzeln.",
        ["ATLAS_TIP_3821"] = "Wertvolles Alchemie-Kraut auf BergrÃ¼cken und trockenen HÃ¼geln.",
        ["ATLAS_TIP_3369"] = "HÃ¤ufig in Stufe 40-50 Gebieten im Schatten alter BÃ¤ume.",
        ["ATLAS_TIP_3819"] = "WÃ¤chst in verschneiten Bergregionen, besonders im Alteracgebirge.",
        ["ATLAS_TIP_4625"] = "WÃ¤chst in heiÃŸen WÃ¼stengebieten wie Tanaris, Ã–dland und Sengender Schlucht.",
        ["ATLAS_TIP_8831"] = "An uralten Ruinen in Tanaris, Feralas und Azshara; liefert Wildranken.",
        ["ATLAS_TIP_8153"] = "Wichtiges Reagenz fÃ¼r RÃ¼stungen; Beifang bei Lila Lotus oder Beute von Trollen.",
        ["ATLAS_TIP_8836"] = "Verstreut in den verseuchten PestlÃ¤ndern und im Teufelswald.",
        ["ATLAS_TIP_8838"] = "Offene, sonnige Ebenen in Feralas und im Hinterland bieten die besten Sammelrouten.",
        ["ATLAS_TIP_8839"] = "Reichlich in Marschen und SÃ¼mpfen, besonders in den DÃ¼stermarschen.",
        ["ATLAS_TIP_8845"] = "WÃ¤chst in finsteren HÃ¶hlen, im Bau der Grimmtotem und im Versunkenen Tempel.",
        ["ATLAS_TIP_8846"] = "WÃ¤chst nahe DÃ¤monenlagern im Teufelswald, den VerwÃ¼steten Landen und Desolace.",
        ["ATLAS_TIP_13464"] = "HÃ¤ufig im Krater von Un'Goro und im Ã¶stlichen Teufelswald.",
        ["ATLAS_TIP_13463"] = "Zentrales Kraut fÃ¼r Raid-Elixiere; lange Sammelroute im Teufelswald und Un'Goro.",
        ["ATLAS_TIP_13465"] = "WÃ¤chst auf BergkÃ¤mmen in Winterquell und den Ã–stlichen PestlÃ¤ndern.",
        ["ATLAS_TIP_13466"] = "Sehr begehrtes FlÃ¤schchen-Kraut; RÃ¤nder der Westlichen und Ã–stlichen PestlÃ¤nder.",
        ["ATLAS_TIP_13467"] = "Exklusiv in den Schneefeldern von Winterquell; wÃ¤chst nur auf Eis und Schnee.",
        ["ATLAS_TIP_13468"] = "Extrem seltener Spawn in hochstufigen Classic-Zonen (Winterquell, Silithus, Ã–stliche PestlÃ¤nder, Brennende Steppe).",
        ["ATLAS_TIP_22785"] = "WÃ¤chst in allen Scherbenwelt-Zonen; hohe Chance auf Teufelslotus und Partikel des Lebens.",
        ["ATLAS_TIP_22786"] = "WÃ¤chst auf Klippen und Bergen auf der HÃ¶llenfeuerhalbinsel und in den WÃ¤ldern von Terokkar.",
        ["ATLAS_TIP_22787"] = "Sehr hÃ¤ufig in den Zangarmarschen rund um die riesigen PilzstÃ¤mme.",
        ["ATLAS_TIP_22788"] = "WÃ¤chst an Sporenkolonien in den Zangarmarschen; gewÃ¤hrt Feuerschaden-Buff.",
        ["ATLAS_TIP_22789"] = "WÃ¤chst am FuÃŸ groÃŸer NadelbÃ¤ume in den WÃ¤ldern von Terokkar.",
        ["ATLAS_TIP_22790"] = "WÃ¤chst in Scherbenwelt-Dungeon-Instanzen (Tiefensumpf, Dampfkammer, Auchindoun).",
        ["ATLAS_TIP_22791"] = "Reichlich in den Ã–kodomen von Nethersturm; liefert Partikel des Manas.",
        ["ATLAS_TIP_22792"] = "WÃ¤chst im Schattenmondtal; fÃ¼gt Giftschaden beim PflÃ¼cken zu und liefert Partikel des Lebens.",
        ["ATLAS_TIP_22793"] = "WÃ¤chst auf abgelegenen Hochebenen (Flugreittier erforderlich) in Terokkar, Nagrand und Nethersturm.",
        ["ATLAS_TIP_22794"] = "Seltener Bonus-Ertrag beim Sammeln von Scherbenwelt-KrÃ¤utern; Kernreagenz fÃ¼r FlÃ¤schchen.",
        ["ATLAS_TIP_2318"] = "KÃ¼rschnerbeute von Tieren in Stufe 1-15 Gebieten (WÃ¶lfe, Eber, BÃ¤ren).",
        ["ATLAS_TIP_2319"] = "KÃ¼rschnerbeute von Tieren der Stufe 15-30 in Westfall, DÃ¤mmerwald und HÃ¼gelland.",
        ["ATLAS_TIP_4234"] = "KÃ¼rschnerbeute von Raptoren, Raubkatzen und Krokilisken im Schlingendorntal und Arathi.",
        ["ATLAS_TIP_4304"] = "HÃ¤ufig bei Gorillas, Basilisken und Yetis in Feralas und Tanaris.",
        ["ATLAS_TIP_8170"] = "KÃ¼rschnerbeute von hochstufigen Wildtieren im Krater von Un'Goro und Winterquell.",
        ["ATLAS_TIP_15415"] = "KÃ¼rschnerbeute von den Elite-Teufelssauriern im Krater von Un'Goro.",
        ["ATLAS_TIP_25707"] = "Niederstufige Scherbenwelt-Lederfetzen; 5x zu einem Knotenhautleder kombinieren.",
        ["ATLAS_TIP_21887"] = "Hauptleder in TBC; reichlich von Talbuks, Grollhufen und Felshetzern in der Scherbenwelt.",
        ["ATLAS_TIP_25708"] = "KÃ¼rschnerbeute von groÃŸen Grollhufen in Nagrand und Schergrat; Kernreagenz fÃ¼r BeinrÃ¼stungen.",
        ["ATLAS_TIP_25700"] = "KÃ¼rschnerbeute von Falkenschreitern und Basilisken auf der HÃ¶llenfeuerhalbinsel und im Schattenmondtal.",
        ["ATLAS_TIP_29539"] = "KÃ¼rschnerbeute von Kobras und Schlangen in Nagrand und im Schattenmondtal.",
        ["ATLAS_TIP_29547"] = "KÃ¼rschnerbeute von Windnattern und SchimÃ¤ren im Schergrat.",
        ["ATLAS_TIP_29548"] = "KÃ¼rschnerbeute von Netherdrachen im Schattenmondtal und Nethersturm.",
        ["ATLAS_TIP_2589"] = "Beute von humanoiden Gegnern der Stufen 5-15 in allen Startgebieten.",
        ["ATLAS_TIP_2592"] = "Beute von Defias, Gnollen und Murlocs in Stufe 15-25 Gebieten.",
        ["ATLAS_TIP_4306"] = "Beute vom Syndikat, Dunkeleisenzwergen und Ogern in Stufe 25-40 Zonen.",
        ["ATLAS_TIP_4338"] = "Reichlich bei Ogern in Tanaris, Feralas und in Zul'Farrak.",
        ["ATLAS_TIP_14047"] = "Beute vom Scharlachroten Kreuzzug und der GeiÃŸel in den PestlÃ¤ndern.",
        ["ATLAS_TIP_14256"] = "Beute von hochstufigen DÃ¤monen im Teufelswald (Jaedenar) und in Azshara.",
        ["ATLAS_TIP_21877"] = "Universeller TBC-Stoff, Beute aller humanoiden und dÃ¤monischen Gegner der Scherbenwelt.",
        ["ATLAS_TIP_22574"] = "Beute von Feuerelementaren im Schergrat oder mit dem Partikelextraktor gewonnen.",
        ["ATLAS_TIP_21884"] = "Aus 10x Partikel des Feuers zusammensetzen oder per Alchemie transmutieren (20h Cooldown).",
        ["ATLAS_TIP_22578"] = "Beute von Wasserelementaren in Skettis/Nagrand, geangelt im Reinen Wasser oder extrahiert aus Gaswolken.",
        ["ATLAS_TIP_21885"] = "Aus 10x Partikel des Wassers zusammensetzen; begehrtes Reagenz fÃ¼r Zauberstoff und Verzauberungen.",
        ["ATLAS_TIP_22572"] = "Beute von Luftelementaren auf dem Elementarplateau in Nagrand oder aus Gaswirbeln extrahiert.",
        ["ATLAS_TIP_22451"] = "Aus 10x Partikel der Luft zusammensetzen; Kernbestandteil epischer Waffen und Ingenieursbrillen.",
        ["ATLAS_TIP_22573"] = "Beute von Erdelementaren in Nagrand oder Beifang beim Abbau von Scherbenwelt-Erzen.",
        ["ATLAS_TIP_22452"] = "Aus 10x Partikel der Erde zusammensetzen; wichtiges Reagenz fÃ¼r Plattenschmiede.",
        ["ATLAS_TIP_22575"] = "Beute von Sumpflords in den Zangarmarschen, aus Sumpfgas extrahiert oder Beifang bei KrÃ¤utern.",
        ["ATLAS_TIP_21886"] = "Aus 10x Partikel des Lebens zusammensetzen; Kernreagenz fÃ¼r Urmondstoff.",
        ["ATLAS_TIP_22577"] = "Beute von Leerwandlern und DÃ¤monen im Schattenmondtal oder aus Schattenwolken extrahiert.",
        ["ATLAS_TIP_22456"] = "Aus 10x Partikel des Schattens zusammensetzen; Kernreagenz fÃ¼r Schattenstoff und FÃ¤den.",
        ["ATLAS_TIP_22576"] = "Beute von Manasuchern in Nethersturm oder aus Teufelsnebel-Gaswolken extrahiert.",
        ["ATLAS_TIP_22457"] = "Aus 10x Partikel des Manas zusammensetzen; benÃ¶tigt fÃ¼r Zauberer-AusrÃ¼stung und Urmacht.",
        ["ATLAS_TIP_23571"] = "Zentrales Transmutations-Reagenz von Alchemisten mit 20 Stunden Abklingzeit.",
        ["ATLAS_TIP_23572"] = "Beute von Endbossen heroischer Dungeons und Raids; kaufbar gegen Abzeichen der Gerechtigkeit.",
        ["ATLAS_TIP_30183"] = "Beute im Schlangenschrein und Festung der StÃ¼rme; kaufbar gegen Abzeichen der Gerechtigkeit.",
        ["ATLAS_TIP_10940"] = "Entzaubert aus grÃ¼nen RÃ¼stungen und Waffen der Stufe 1-20.",
        ["ATLAS_TIP_11083"] = "Entzaubert aus grÃ¼nen AusrÃ¼stungsgegenstÃ¤nden der Stufe 21-30.",
        ["ATLAS_TIP_11137"] = "Entzaubert aus grÃ¼nen AusrÃ¼stungsgegenstÃ¤nden der Stufe 31-40.",
        ["ATLAS_TIP_11176"] = "Entzaubert aus grÃ¼nen AusrÃ¼stungsgegenstÃ¤nden der Stufe 41-50.",
        ["ATLAS_TIP_16204"] = "Entzaubert aus grÃ¼nen AusrÃ¼stungsgegenstÃ¤nden der Stufe 51-60.",
        ["ATLAS_TIP_22445"] = "Entzaubert aus grÃ¼nen RÃ¼stungen und Waffen der Scherbenwelt (Stufe 58-70).",
        ["ATLAS_TIP_22447"] = "Entzaubert aus grÃ¼nen Waffen der Stufe 58-65 in der Scherbenwelt.",
        ["ATLAS_TIP_22446"] = "Aus 3x Geringen Planar-Essenzen zusammensetzen oder Stufe 65-70 AusrÃ¼stung entzaubern.",
        ["ATLAS_TIP_22448"] = "Entzaubert aus seltenen (blauen) Dungeon- und Quest-Items der Stufe 58-66.",
        ["ATLAS_TIP_22449"] = "Entzaubert aus seltenen (blauen) Dungeon-Boss-Drops der Stufe 67-70.",
        ["ATLAS_TIP_22450"] = "Entzaubert aus epischen (lila) Items in Karazhan, Gruul, Magtheridon und Heroics.",
        ["ATLAS_TIP_20725"] = "Entzaubert aus epischen Classic-Raid-Items der Stufe 60 (MC, BWL, AQ40, Naxx).",
        ["ATLAS_TIP_27671"] = "Gekocht zu GerÃ¶steter Grollhuf (+20 StÃ¤rke); Beute von Grollhufen in Nagrand.",
        ["ATLAS_TIP_27677"] = "Gekocht zu Felshetzer-Hotdog (+40 Angriffskraft); Beute von Felshetzern.",
        ["ATLAS_TIP_27682"] = "Gekocht zu Talbuksteak (+20 Trefferwertung); Beute von Talbuks in Nagrand.",
        ["ATLAS_TIP_27681"] = "Gekocht zu SphÃ¤renburger (+20 Beweglichkeit); Beute von SphÃ¤renjÃ¤gern in Terokkar.",
        ["ATLAS_TIP_27674"] = "Gekocht zu Basilisken-Eintopf (+23 Zaubermacht); Beute von Basilisken in Terokkar.",
        ["ATLAS_TIP_27432"] = "Geangelt in Skettis und Bergseen (Flugreittier erforderlich); gekocht fÃ¼r +30 Ausdauer.",
        ["ATLAS_TIP_27434"] = "Geangelt in den FlÃ¼ssen von Terokkar; gekocht zu Goldene FischstÃ¤bchen (+44 Heilung).",
        ["ATLAS_TIP_27431"] = "Geangelt in den Seen von Zangarmarschen und Nagrand; gekocht fÃ¼r +23 Zaubermacht.",
        ["ATLAS_TIP_27429"] = "Geangelt in SporenfischschwÃ¤rmen in Zangarmarschen; gekocht fÃ¼r +20 Ausdauer und +8 MP5.",
        ["ATLAS_TIP_6370"] = "Geangelt an KÃ¼sten; unentbehrlich fÃ¼r TrÃ¤nke der freien Aktion und SchattenÃ¶l.",
        ["ATLAS_TIP_6371"] = "Geangelt an KÃ¼sten; Kernreagenz fÃ¼r FeuerÃ¶l und Elixiere der Feuermacht.",
        ["ATLAS_TIP_13422"] = "Geangelt im offenen Ozean bei Tanaris und Feralas; Kernreagenz fÃ¼r GroÃŸe SteinschildtrÃ¤nke.",
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
	if not self.Categories then
		return catKey, "Interface\\Icons\\INV_Misc_QuestionMark"
	end
	local cat = nil
	for _, c in ipairs(self.Categories) do
		if c.key == catKey then cat = c; break end
	end
	if not cat then
		return catKey, "Interface\\Icons\\INV_Misc_QuestionMark"
	end

	local name = nil
	if cat.spellID then
		name = GetSpellInfo(cat.spellID)
	elseif cat.itemClass and cat.itemSubClass then
		name = GetItemSubClassInfo(cat.itemClass, cat.itemSubClass)
	end

	if not name then
		name = self:GetLocaleText("CAT_" .. catKey) or catKey
	end

	return name, cat.icon
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
	if not entry or not entry.sources then return 1 end
	local minSkill = 999
	for _, src in ipairs(entry.sources) do
		if src.skill and src.skill > 0 and src.skill < minSkill then
			minSkill = src.skill
		end
	end
	return minSkill < 999 and minSkill or 1
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
			elseif categoryKey == "SKINNING" and (src.type == "GATHER" or src.type == "MOB_DROP") and entry.category == "SKINNING" then
				return true
			elseif categoryKey == "ENCHANTING" and src.type == "DISENCHANT" then
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