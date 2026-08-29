# Phase 3 Implementation Plan: Universal Resource Atlas & Multi-Source Gathering Compendium (v1.3.0)

> **Persistent Repository Copy**: Stored in `.gemini/plans/phase_3_implementation_plan.md` to guarantee persistence across all sessions, conversations, and restarts.
The current `AtlasData.lua` suffers from an identity crisis: it mixes ground objects (*"Kupfervorkommen"*) with gathered items (*"Friedensblume"*, *"Leichtes Leder"*), uses hardcoded English strings, and requires manual translation tables for names, zones, and yields.

This overhaul completely decouples ground nodes from materials. **Every record in the Atlas becomes an inventory Material keyed by its official Blizzard `itemID`**, with zone metadata resolved via native `areaID` / `C_Map.GetAreaInfo`, categories resolved via `GetSpellInfo` / `GetItemSubClassInfo`, and byproduct yields rendered as interactive, tooltipped item links.

---

## 🎯 Architecture Pillars

### 1. Unified Polymorphic Source Schema
To capture every special acquisition detail (Mining, Herbalism byproducts, Gas Extraction, Prospecting, Disenchanting, Transmutes, Fishing) without brittle spaghetti code, every material in the catalog follows a **Polymorphic Source Architecture**:

```lua
{
    id       = 23436,                        -- Item ID (Blizzard returns Name, Icon, Quality)
    category = "MINING",                     -- Primary Category (MINING, HERBALISM, ENCHANTING, etc.)
    sources  = {                             -- Array of valid acquisition sources
        {
            type = "GATHER",                 -- Field gathering node
            skill = 325,                     -- Required skill
            zones = { 3518, 3523, 3520 },    -- AreaTable IDs (Elwynn, Nagrand, etc.)
        },
        {
            type = "PROSPECT",               -- Jewelcrafting Prospecting
            spellID = 31252,                 -- Sondieren (GetSpellInfo(31252))
            fromItems = { 23425, 23424 },    -- 5x Adamantite Ore, Fel Iron Ore
        },
    },
    yields   = nil,                          -- Optional: Byproduct Item IDs when harvesting this item
    tipKey   = "ATLAS_TIP_23436",            -- Localized strategic advice key in Locales/
}
```

#### Supported Source Types (`src.type`)
1. **`GATHER`**: Ground/Vein nodes. Contains `skill` (number) and `zones` (array of `areaID`s).
2. **`PROSPECT`**: Jewelcrafting ore crushing. Contains `spellID` (`31252`), `skill` (number), and `fromItems` (array of ore `itemID`s).
3. **`DISENCHANT`**: Item disenchanting. Contains `spellID` (`13262`), `itemQuality` (2=Green, 3=Blue, 4=Epic), and `itemLevels` (string range like `"58-70"`).
4. **`EXTRACT`**: Engineering gas clouds. Contains `device` (`23821` Zapthrottle Mote Extractor), `skill` (`305`), and `zones` (array of `areaID`s).
5. **`TRANSMUTE`**: Alchemy transmutations. Contains `spellID` (e.g. `28566` for Primal Might), `fromItems` (input `itemID`s), and `cooldown` (e.g. `"20h"`).
6. **`SMELT`**: Blacksmithing/Mining smelting. Contains `spellID` (`2656` Verhütten), `skill` (number), and `fromItems` (array of ore/bar `itemID`s).
7. **`COMBINE`**: Bag stack transforms. Contains `count` (e.g. `10`), and `fromItem` (`itemID`, e.g. 10x Partikel des Feuers -> Urfeuer, or 10x Knotenhautlederfetzen -> Knotenhautleder).
8. **`MOB_DROP`**: Creature farming (Cloth, Meats, Elementals). Contains `mobType` (e.g. `"Humanoid"`, `"Elemental"`), `mobLevel` (e.g. `"35-45"`), and `zones` (array of `areaID`s).
9. **`FISH`**: Open water & school fishing. Contains `skill` (number), `school` (optional school name), and `zones` (array of `areaID`s).
10. **`BYPRODUCT`**: Secondary yield from gathering another primary material. Contains `fromItems` (parent `itemID`s) and `zones`.
11. **`VENDOR`**: NPC purchases for static crafting reagents (Flux, Thread, Vials, Coal, Dyes) and faction currency vendors (Halaa, Sporeggar, Badges of Justice). Contains `cost` note and `zones` or `faction`.
12. **`INSTANCE`**: Heroic dungeon and raid boss drops (Urnether `23572`, Netherwirbel `30183`, Herz der Dunkelheit `32428`, Sonnenpartikel `34664`, Kernleder `17012`, Elementiumerz `18562`). Contains `dungeon` or `raid` name.
13. **`CONTAINER`**: Daily quest reward satchels and pickpocketed lockboxes (Beutel mit Angelangeltem `35348`, Schwere Schließkassette `16885`). Contains container `itemID`.

### 2. Zero-String Internationalization
| Data Point | Resolution Method | Client Output (DE / EN) |
| :--- | :--- | :--- |
| **Material Name** | `GetItemInfo(entry.id)` | `"Kupfererz"` / `"Copper Ore"` |
| **Material Icon** | `select(10, GetItemInfo(entry.id))` | `Interface\Icons\INV_Ore_Copper_01` |
| **Category Name** | `GetSpellInfo(cat.spellID)` | `"Bergbau"` / `"Mining"` |
| **Category Icon** | `select(3, GetSpellInfo(cat.spellID))` | `Interface\Icons\Trade_Mining` |
| **Zone Names** | `C_Map.GetAreaInfo(areaID)` | `"Wald von Elwynn"` / `"Elwynn Forest"` |
| **Byproduct Yields** | `select(2, GetItemInfo(yieldID))` | Clickable `[Rauer Stein]` / `[Rough Stone]` links |
| **Farming Tips** | `GSF.L[entry.tipKey]` | Curated 1-sentence strategic farming advice |

### 3. Asynchronous Cache Handling (The "Engine Gotcha" Solution)
Because `GetItemInfo(id)` returns `nil` on a cold client session before server query returns:
1. **Pre-Flight Cache Priming**: On `PLAYER_LOGIN`, GSFHub iterates over all catalog item IDs and issues background queries (`C_Item.RequestLoadItemDataByID` / `GetItemInfo`).
2. **Event Listener**: A dedicated listener registers `GET_ITEM_INFO_RECEIVED`. When an item finishes loading, it automatically triggers a debounced visual refresh of active Atlas scroll rows.
3. **Graceful Fallback**: If an item is queried while the server packet is in transit, the UI shows `Item #<ID> (Loading...)` with a standard question mark texture instead of throwing Lua errors.

---

## 🔎 Verified Data Proofs (TBC Classic Benchmark)

Every ID below is verified against World of Warcraft TBC Classic (Patch 2.5.x) database files (`Item.dbc`, `Spell.dbc`, `AreaTable.dbc`):

### 1. Categories & Spells
- **Mining**: Spell ID `2575` (`GetSpellInfo(2575)` -> *"Bergbau"* / *"Mining"*, Icon: `Trade_Mining`)
- **Herbalism**: Spell ID `2366` (`GetSpellInfo(2366)` -> *"Kräuterkunde"* / *"Herbalism"*, Icon: `Trade_Herbalism`)
- **Skinning**: Spell ID `8613` (`GetSpellInfo(8613)` -> *"Kürschnerei"* / *"Skinning"*, Icon: `INV_Misc_Pelt_Wolf_01`)
- **Fishing**: Spell ID `7620` (`GetSpellInfo(7620)` -> *"Angeln"* / *"Fishing"*, Icon: `Trade_Fishing`)
- **Enchanting / Disenchanting**: Spell ID `13262` (`GetSpellInfo(13262)` -> *"Entzaubern"* / *"Disenchant"*, Icon: `Spell_Holy_RemoveCurse`)
- **Engineering Gas Clouds**: Spell ID `4036` (`GetSpellInfo(4036)` -> *"Ingenieurskunst"* / *"Engineering"*, Icon: `Trade_Engineering`)
- **Cloth**: Item Class `7`, SubClass `5` (`GetItemSubClassInfo(7, 5)` -> *"Stoff"* / *"Cloth"*)
- **Elemental & Primals**: Item Class `7`, SubClass `10` (`GetItemSubClassInfo(7, 10)` -> *"Elementar"* / *"Elemental"*)
- **Meat (Cooking Reagents)**: Item Class `7`, SubClass `8` (`GetItemSubClassInfo(7, 8)` -> *"Fleisch"* / *"Meat"*)

### 2. Mining Materials, Stones & Raw Gems
- **Ores**:
  - `2770` - Copper Ore (Kupfererz) | Skill: 1
  - `2771` - Tin Ore (Zinnerz) | Skill: 65
  - `2775` - Silver Ore (Silbererz) | Skill: 75
  - `2772` - Iron Ore (Eisenerz) | Skill: 125
  - `2776` - Gold Ore (Golderz) | Skill: 155
  - `3858` - Mithril Ore (Mithrilerz) | Skill: 175
  - `7911` - Truesilver Ore (Echtsilbererz) | Skill: 230
  - `11370` - Dark Iron Ore (Dunkeleisenerz) | Skill: 230
  - `10620` - Thorium Ore (Thoriumerz) | Skill: 245 / 275
  - `23424` - Fel Iron Ore (Teufelseisenerz) | Skill: 300
  - `23425` - Adamantite Ore (Adamantiterz) | Skill: 325
  - `23426` - Khorium Ore (Khoriumerz) | Skill: 375
  - `23427` - Eternium Ore (Eterniumerz) | Skill: 350
  - `32468` - Nethercite Ore (Netherziterz) | Skill: 350
- **Stones (First-Class Crafting Materials)**:
  - `2835` - Rough Stone (Rauer Stein) | Skill: 1
  - `2836` - Coarse Stone (Grober Stein) | Skill: 65
  - `2838` - Heavy Stone (Schwerer Stein) | Skill: 125
  - `7912` - Solid Stone (Fester Stein) | Skill: 175
  - `12365` - Dense Stone (Verdichteter Stein) | Skill: 250
- **Classic Raw Gems (Mined & Prospected)**:
  - `774` - Malachite (Malachit) | From: Copper
  - `818` - Tigerseye (Tigerauge) | From: Copper
  - `1210` - Shadowgem (Schattengemme) | From: Tin, Silver
  - `1705` - Lesser Moonstone (Kleiner Mondstein) | From: Tin, Silver, Iron
  - `1206` - Moss Agate (Moosachat) | From: Tin, Iron
  - `929` - Jade (Jade) | From: Iron, Gold
  - `3864` - Citrine (Citrin) | From: Iron, Gold, Mithril
  - `7909` - Aquamarine (Aquamarin) | From: Mithril, Truesilver
  - `7910` - Star Ruby (Sternrubin) | From: Mithril, Thorium
  - `12799` - Large Opal (Großer Opal) | From: Thorium
  - `12361` - Blue Sapphire (Blauer Saphir) | From: Thorium
  - `12364` - Azerothian Diamond (Azeroth-Diamant) | From: Thorium
  - `12800` - Huge Emerald (Gewaltiger Smaragd) | From: Thorium
  - `11382` - Blood of the Mountain (Bergblut) | From: Dark Iron
- **TBC Rare Raw Gems (Mined & Prospected via Sondieren `31252`)**:
  - `23436` - Living Ruby (Lebendiger Rubin) | Red Gem
  - `23437` - Talasite (Talasit) | Green Gem
  - `23438` - Star of Elune (Stern der Elune) | Blue Gem
  - `23439` - Noble Topaz (Edeltopas) | Orange Gem
  - `23440` - Dawnstone (Dämmerstein) | Yellow Gem
  - `23441` - Nightseye (Nachtauge) | Purple Gem
- **TBC Uncommon Raw Gems**:
  - `23077` - Blood Garnet (Blutgranat) | Red
  - `23079` - Deep Peridot (Tiefenperidot) | Green
  - `23107` - Shadow Draenite (Schattendrawenit) | Purple
  - `23112` - Golden Draenite (Golddraenit) | Yellow
  - `23117` - Azure Moonstone (Azurmondstein) | Blue
  - `24243` - Adamantite Powder (Adamantitpulver) | 100% Prospecting byproduct

### 3. Herbalism Materials & Essential Byproducts
- **Herbalism Byproducts & Rare Yields**:
  - `2453` - Swiftthistle (Flitzdistel) | Byproduct from: Briarthorn (`2450`), Mageroyal (`785`)
  - `8153` - Wildvine (Wildranke) | Byproduct from: Purple Lotus (`8831`)
  - `22794` - Fel Lotus (Teufelslotus) | Rare drop from all Outland herbs
  - `22575` - Mote of Life (Partikel des Lebens) | Harvested directly from Outland herb nodes
  - `22576` - Mote of Mana (Partikel des Manas) | Harvested from Dreaming Glory & Netherbloom
- **Classic Herbs (1–300)**:
  - `2447` - Peacebloom (Friedensblume) | Skill: 1
  - `765` - Silverleaf (Silberblatt) | Skill: 1
  - `2449` - Earthroot (Erdwurzel) | Skill: 15
  - `785` - Mageroyal (Maguskönigskraut) | Skill: 50 | Yields: Swiftthistle (`2453`)
  - `2450` - Briarthorn (Wilddornrose) | Skill: 70 | Yields: Swiftthistle (`2453`)
  - `3820` - Stranglekelp (Würgetang) | Skill: 85
  - `2452` - Bruiseweed (Beulengras) | Skill: 100
  - `3355` - Wild Steelbloom (Wildstahlblume) | Skill: 115
  - `3356` - Grave Moss (Grabmoos) | Skill: 120
  - `3357` - Kingsblood (Königsblut) | Skill: 125
  - `3358` - Liferoot (Lebenswurz) | Skill: 150
  - `3818` - Fadeleaf (Blassblatt) | Skill: 160
  - `3821` - Goldthorn (Golddorn) | Skill: 170
  - `3369` - Khadgar's Whisker (Khadgars Schnurrbart) | Skill: 185
  - `3819` - Wintersbite (Winterbiss) | Skill: 195
  - `4625` - Firebloom (Feuerblüte) | Skill: 205
  - `8831` - Purple Lotus (Lila Lotus) | Skill: 210 | Yields: Wildvine (`8153`)
  - `8836` - Arthas' Tears (Arthas' Tränen) | Skill: 220
  - `8838` - Sungrass (Sonnengras) | Skill: 230
  - `8839` - Blindweed (Blindkraut) | Skill: 235
  - `8845` - Ghost Mushroom (Geisterpilz) | Skill: 245
  - `8846` - Gromsblood (Gromsblut) | Skill: 250
  - `13464` - Golden Sansam (Goldener Sansam) | Skill: 260
  - `13463` - Dreamfoil (Traumblatt) | Skill: 270
  - `13465` - Mountain Silversage (Bergsilbersalbei) | Skill: 280
  - `13466` - Plaguebloom (Pestblüte) | Skill: 285
  - `13467` - Icecap (Eiskappe) | Skill: 290
  - `13468` - Black Lotus (Schwarzer Lotus) | Skill: 300
- **TBC Herbs (300–375)**:
  - `22785` - Felweed (Teufelsgras) | Skill: 300 | Yields: Fel Lotus (`22794`), Mote of Life (`22575`)
  - `22786` - Dreaming Glory (Traumwinde) | Skill: 315 | Yields: Fel Lotus (`22794`), Mote of Mana (`22576`)
  - `22787` - Ragveil (Zottelkappe) | Skill: 325 | Yields: Fel Lotus (`22794`)
  - `22788` - Flame Cap (Flammenkappe) | Skill: 335
  - `22789` - Terocone (Terozapfen) | Skill: 325 | Yields: Fel Lotus (`22794`)
  - `22790` - Ancient Lichen (Urflechte) | Skill: 340 | Yields: Fel Lotus (`22794`)
  - `22791` - Netherbloom (Netherblüte) | Skill: 350 | Yields: Mote of Mana (`22576`), Fel Lotus (`22794`)
  - `22792` - Nightmare Vine (Alptraumranke) | Skill: 365 | Yields: Fel Lotus (`22794`), Mote of Life (`22575`)
  - `22793` - Mana Thistle (Manadistel) | Skill: 375 | Yields: Fel Lotus (`22794`), Mote of Mana (`22576`)
  - `22797` - Fel Blossom (Teufelsblüte) | Skill: 275

### 3b. Prospecting Integration ("Sondieren" - Spell ID `31252`)
- In addition to appearing under Mining as node drops, **Raw Gems can be prospected from raw ores**:
  - Prospecting Spell: `31252` (`GetSpellInfo(31252)` -> *"Sondieren"* / *"Prospecting"*, Icon: `INV_Misc_Gem_01`).
  - The Atlas Detail Pane for any raw gem (e.g. `[Lebendiger Rubin]` or `[Blutgranat]`) will display:
    - **Abgebaut aus:** Adamantitvorkommen, Reiches Adamantitvorkommen, Khoriumvorkommen
    - **Sondiert aus:** Teufelseisenerz (5x), Adamantiterz (5x)
  - This allows Jewelcrafters and miners to track gem acquisition whether they are out in the field mining veins or crushing stacks of ore at the anvil!

### 4. Skinning & Leathers
- `2934` - Ruined Leather Scraps (Verdorrene Lederfetzen)
- `2318` - Light Leather (Leichtes Leder)
- `2319` - Medium Leather (Mittleres Leder)
- `4234` - Heavy Leather (Schweres Leder)
- `4304` - Thick Leather (Dickes Leder)
- `8170` - Rugged Leather (Unverwüstliches Leder)
- `15415` - Devilsaur Leather (Teufelssaurierleder)
- `25707` - Knothide Leather Scraps (Knotenhautlederfetzen)
- `21887` - Knothide Leather (Knotenhautleder)
- `25700` - Fel Scales (Teufelsschuppen)
- `29539` - Cobra Scales (Kobraschuppen)
- `29547` - Wind Scales (Windschuppen)
- `29548` - Nether Dragonscales (Netherdrachenschuppen)
- `25708` - Thick Clefthoof Leather (Dickes Grollhufleder)

### 5. Cloths (Mob Drop Humanoids)
- `2589` - Linen Cloth (Leinenstoff) | Mob Level: 5–15
- `2592` - Wool Cloth (Wollstoff) | Mob Level: 15–25
- `4306` - Silk Cloth (Seidenstoff) | Mob Level: 25–40
- `4338` - Mageweave Cloth (Magiestoff) | Mob Level: 40–50
- `14047` - Runecloth (Runenstoff) | Mob Level: 50–60
- `14256` - Felcloth (Teufelsstoff) | Mob Level: 50–60 (Demons)
- `21877` - Netherweave Cloth (Netherstoff) | Mob Level: 60–70

### 6. Elementals, Primals & Motes
- **Classic**:
  - `7076` - Elemental Earth (Elementarerde)
  - `7078` - Elemental Fire (Elementarfeuer)
  - `7080` - Elemental Water (Elementarwasser)
  - `7082` - Elemental Air (Elementarluft)
  - `7077` - Essence of Earth (Essenz der Erde)
  - `7079` - Essence of Water (Essenz des Wassers)
  - `7081` - Essence of Fire (Essenz des Feuers)
  - `7082` - Essence of Air (Essenz der Luft)
  - `12803` - Essence of Undeath (Essenz des Untodes)
  - `12808` - Essence of Life (Essenz des Lebens)
- **TBC Motes & Primals**:
  - `22574` / `21884` - Mote / Primal Fire (Partikel / Urfeuer)
  - `22573` / `22452` - Mote / Primal Earth (Partikel / Urerde)
  - `22578` / `21885` - Mote / Primal Water (Partikel / Urwasser)
  - `22572` / `22451` - Mote / Primal Air (Partikel / Urluft)
  - `22575` / `21886` - Mote / Primal Life (Partikel / Urleben)
  - `22577` / `22456` - Mote / Primal Shadow (Partikel / Urschatten)
  - `22576` / `22457` - Mote / Primal Mana (Partikel / Urmana)
  - `23572` - Primal Nether (Urnether)
  - `30183` - Nether Vortex (Netherwirbel)

### 6b. Engineering Gas Cloud Harvesting (Partikelextraktor - Item ID `23821`)
- **Extraction Device**: `Zapthrottle Mote Extractor` (`23821` Partikelextraktor von Schepperknall) | Engineering 305
- **Radar Tracking**: Requires Engineering Goggles (e.g. `Ultra-Spectropic Detection Goggles`) for minimap tracking.
- **Gas Cloud Types & Locations**:
  - **Steam Clouds (Dampfwolken)** in Zangarmarsh -> `Mote of Water` (`22578`)
  - **Cinder Clouds (Aschenwolken)** in Shadowmoon Valley & Blade's Edge -> `Mote of Fire` (`22574`)
  - **Swamp Gas (Sumpfgas)** in Zangarmarsh -> `Mote of Life` (`22575`)
  - **Felmist / Gas Clouds (Teufelsnebel)** in Netherstorm -> `Mote of Mana` (`22576`)
  - **Wind Swirls (Windwirbel)** in Nagrand -> `Mote of Air` (`22572`)
  - **Shadow Clouds (Schattenwolken)** in Shadowmoon Valley -> `Mote of Shadow` (`22577`)

### 6c. Enchanting Materials via Disenchanting (Entzaubern - Spell ID `13262`)
Enchanting reagents are 100% farmed by disenchanting armor/weapons. Grouped by tier:

**Classic Dusts**:
- `10940` - **Strange Dust (Seltsamer Staub)** | Item Level: 1–20 (Green Armor/Weapons)
- `11083` - **Soul Dust (Seelenstaub)** | Item Level: 21–30 (Green Armor/Weapons)
- `11137` - **Vision Dust (Visionsstaub)** | Item Level: 31–40 (Green Armor/Weapons)
- `11176` - **Dream Dust (Traumstaub)** | Item Level: 41–50 (Green Armor/Weapons)
- `16204` - **Illusion Dust (Illusionsstaub)** | Item Level: 51–60 (Green Armor/Weapons)

**Classic Essences**:
- `10938` / `10939` - **Lesser / Greater Magic Essence (Geringe / Große Magieessenz)** | Item Level: 1–15 (Weapons)
- `10998` / `11082` - **Lesser / Greater Astral Essence (Geringe / Große Astralessenz)** | Item Level: 16–25 (Weapons)
- `11134` / `11135` - **Lesser / Greater Mystic Essence (Geringe / Große Mystikeressenz)** | Item Level: 26–35 (Weapons)
- `11174` / `11175` - **Lesser / Greater Nether Essence (Geringe / Große Netheressenz)** | Item Level: 36–45 (Weapons)
- `16202` / `16203` - **Lesser / Greater Eternal Essence (Geringe / Große ewige Essenz)** | Item Level: 46–60 (Weapons)

**Classic Shards & Crystals**:
- `10978` / `11084` - **Small / Large Glimmering Shard (Kleiner / Großer glänzender Splitter)** | Blue Items (Level 15–25)
- `11138` / `11139` - **Small / Large Glowing Shard (Kleiner / Großer leuchtender Splitter)** | Blue Items (Level 26–35)
- `11177` / `11178` - **Small / Large Radiant Shard (Kleiner / Großer strahlender Splitter)** | Blue Items (Level 36–45)
- `14343` / `14344` - **Small / Large Brilliant Shard (Kleiner / Großer brillanter Splitter)** | Blue/Epic Items (Level 46–60)
- `20725` - **Nexus Crystal (Nexuskristall)** | Classic Level 60 Epics (Molten Core, Onyxia, BWL, AQ40, Naxx)

**TBC Enchanting Materials**:
- `22445` - **Arcane Dust (Arkaner Staub)** | Outland Green items (Level 58–70)
- `22447` - **Lesser Planar Essence (Geringe Planar-Essenz)** | Outland Green weapons/armor (Level 58–65)
- `22446` - **Greater Planar Essence (Große Planar-Essenz)** | Combined (3x Lesser) or Level 65–70 Greens
- `22448` - **Small Prismatic Shard (Kleiner Prismasplitter)** | Outland Blue items (Level 58–66)
- `22449` - **Large Prismatic Shard (Großer Prismasplitter)** | Outland Dungeon Rare drops (Level 67–70)
- `22450` - **Void Crystal (Urvoidkristall)** | Outland Epic (Purple) Raid & Heroic items (Karazhan, Gruul, Magtheridon, Heroics)

### 6d. Alchemy Transmutations & High-Demand Catalyst Reagents
- **Primal Might (Urmacht - Item ID `23571`)**:
  - Recipe: `Transmute: Primal Might` (Spell ID `28566`) | Alchemy 350 | 20h Cooldown
  - Requires: 1x Primal Earth (`22452`), 1x Primal Water (`21885`), 1x Primal Air (`22451`), 1x Primal Fire (`21884`), 1x Primal Mana (`22457`).
  - Essential core reagent for all Phase 1–5 crafted weapons, armor, and epic gems.
- **Uncut Meta Gems (Alchemist Transmutes)**:
  - `25867` - **Earthstorm Diamond (Erdsturmdiamant)** | 1x Deep Peridot, 1x Shadow Draenite, 1x Golden Draenite, 2x Primal Earth, 2x Primal Water
  - `25868` - **Skyfire Diamond (Himmelsfeuerdiamant)** | 1x Blood Garnet, 1x Flame Spessarite, 1x Azure Moonstone, 2x Primal Fire, 2x Primal Air

### 6e. Tailoring Specialty Cooldown Cloths
- `21845` - **Primal Mooncloth (Urmondstoff)** | Tailoring 350 | Mooncloth Tailoring (Crafted at Moonwells in Zangarmarsh/Terokkar)
- `24271` - **Spellcloth (Zauberstoff)** | Tailoring 350 | Spellfire Tailoring (Crafted in Netherstorm ley lines)
- `24272` - **Shadowcloth (Schattenstoff)** | Tailoring 350 | Shadoweave Tailoring (Crafted at Altar of Shadows, Shadowmoon Valley)
- `14342` - **Mooncloth (Mondstoff)** | Classic 300 Tailoring (Crafted at Moonwells from Felcloth `14256`)

### 6f. Cooking Beast Meats & Specialized Raid Buff Fishing
- **Farmed Meats (Stat Buff Food Reagents)**:
  - `27671` - Clefthoof Meat (Grollhuffleisch) -> Roasted Clefthoof (+20 Strength)
  - `27677` - Ravager Flesh (Felshetzerfleisch) -> Ravager Dog (+40 Attack Power)
  - `27682` - Talbuk Venison (Talbukfleisch) -> Talbuk Steak (+20 Hit Rating)
  - `27681` - Warpstalker Meat (Sphärenjägerfleisch) -> Warp Burger (+20 Agility)
  - `27674` - Basilisk Meat (Basiliskenfleisch) -> Basilisk Stew (+23 Spell Power)
- **Specialized School Fishing (Highland Mixed Schools & Pure Water)**:
  - `27432` - Furious Crawdad (Wilder Kriecher) | Caught in Skettis / Highland pools (requires flying!) -> +30 Stamina food
  - `27434` - Golden Darter (Goldener Zackenbarsch) | Caught in Terokkar rivers -> +44 Healing food
  - `27431` - Figlamp Fish (Feigenlampen-Fisch) -> +23 Spell Power
  - `27422` - Spotted Feltail (Gefleckter Filzschwanz) -> +20 Stamina / +20 Spirit
  - `27429` - Zangarian Sporefish (Zangardornen-Sporenfisch) -> +20 Stamina / +8 MP5
  - `22578` - Mote of Water (Partikel des Wassers) | Caught directly in Pure Water schools in Nagrand & Skettis!
  - `6370` - Oily Blackmouth (Öliges Schwarzmaul) | Classic Alchemy reagent for Free Action Potion
  - `6371` - Firefin Snapper (Feuerflossenschnapper) | Classic Alchemy reagent for Fire Oil
  - `13422` - Stonescale Eel (Steinschuppenaal) | Classic Alchemy reagent for Greater Stoneshield Potion

### 7. Key Verified AreaTable IDs (`C_Map.GetAreaInfo(areaID)`)
- `12` - Elwynn Forest (Wald von Elwynn)
- `14` - Durotar (Durotar)
- `1` - Dun Morogh (Dun Morogh)
- `85` - Tirisfal Glades (Tirisfal)
- `215` - Mulgore (Mulgore)
- `141` - Teldrassil (Teldrassil)
- `40` - Westfall (Westfall)
- `38` - Loch Modan (Loch Modan)
- `130` - Silverpine Forest (Silberwald)
- `148` - Darkshore (Dunkelküste)
- `44` - Redridge Mountains (Rotkammgebirge)
- `267` - Hillsbrad Foothills (Vorgebirge des Hügellands)
- `10` - Duskwood (Dämmerwald)
- `11` - Wetlands (Sumpfland)
- `331` - Ashenvale (Eschenwald)
- `45` - Arathi Highlands (Arathihochland)
- `400` - Thousand Needles (Tausend Nadeln)
- `406` - Stonetalon Mountains (Steinkrallengebirge)
- `405` - Desolace (Desolace)
- `357` - Feralas (Feralas)
- `15` - Dustwallow Marsh (Düstermarschen)
- `440` - Tanaris (Tanaris)
- `16` - Azshara (Azshara)
- `361` - Felwood (Teufelswald)
- `490` - Un'Goro Crater (Krater von Un'Goro)
- `618` - Winterspring (Winterquell)
- `3` - Badlands (Ödland)
- `33` - Stranglethorn Vale (Schlingendorntal)
- `51` - Searing Gorge (Sengende Schlucht)
- `47` - The Hinterlands (Hinterland)
- `139` - Eastern Plaguelands (Östliche Pestländer)
- `28` - Western Plaguelands (Westliche Pestländer)
- `4` - Blasted Lands (Verwüstete Lande)
- `3430` - Eversong Woods (Immersangwald)
- `3433` - Ghostlands (Geisterlande)
- `3524` - Azuremyst Isle (Azurmythosinsel)
- `3525` - Bloodmyst Isle (Blutmythosinsel)
- **Outland**:
  - `3483` - Hellfire Peninsula (Höllenfeuerhalbinsel)
  - `3521` - Zangarmarsh (Zangarmarschen)
  - `3519` - Terokkar Forest (Wälder von Terokkar)
  - `3518` - Nagrand (Nagrand)
  - `3522` - Blade's Edge Mountains (Schergrat)
  - `3523` - Netherstorm (Nethersturm)
  - `3520` - Shadowmoon Valley (Schattenmondtal)

---

## 🔄 Downstream Impact & Required Changes (Post-Rewrite)

When the Atlas transitions to this pure ID architecture, the following dependent modules must be synchronized:

### 1. `UI/Tabs/TabAtlas.lua` (View 1: Resource List & Detail Pane)
- **Row Rendering**: Read item name and texture dynamically via `GetItemInfo(entry.id)` instead of static `entry.name` and `entry.icon`.
- **Search Filtering**: Match search box input across the client's native localized item name (e.g. typing `"Partikel des Wassers"` finds item `22578` instantly).
- **Cross-Discipline Category Filtering (`MatchesCategory`)**:
  - If a player filters by **"Angeln" (Fishing)**, items like `Partikel des Wassers` will appear because they contain a `type = "FISH"` source!
  - If a player filters by **"Ingenieurskunst" (Engineering)**, `Partikel des Wassers` will appear because it contains a `type = "EXTRACT"` source!
  - If a player filters by **"Elementar" (Elemental)**, it appears as its primary trade good class.
  - This guarantees players exploring by profession never miss multi-discipline acquisition vectors!
- **Detail Pane (`SetResource`)**:
  - Display item name with quality coloring and full native game tooltip on icon hover.
  - **Polymorphic Source Loop**: Iterates `entry.sources` to render distinct, formatted source sections:
    - `GATHER`: Renders `"Abgebaut / Gesammelt (Fertigkeit: %d)"` + zone pills via `C_Map.GetAreaInfo(areaID)`.
    - `PROSPECT`: Renders `"Sondiert aus: "` with clickable item links for each input ore (`fromItems`) via `GetSpellInfo(31252)`.
    - `DISENCHANT`: Renders `"Entzaubert aus: %s Gegenstände (Stufe %s)"` via `GetSpellInfo(13262)`.
    - `EXTRACT`: Renders `"Gaswolken-Extraktion"` with clickable link to `Zapthrottle Mote Extractor` (`device`) + zone pills.
    - `TRANSMUTE`: Renders `"Transmutiert aus: "` with clickable reagent links + cooldown note via `GetSpellInfo(spellID)`.
    - `SMELT`: Renders `"Verhüttet aus: "` with clickable ore/coal links via `GetSpellInfo(2656)`.
    - `COMBINE`: Renders `"Zusammengesetzt aus: "` (e.g. 10x Partikel des Feuers -> Urfeuer).
    - `MOB_DROP`: Renders `"Gegnerbeute: %s (Stufe %s)"` + zone pills.
    - `FISH`: Renders `"Geangelt (Fertigkeit: %d)"` + school name + zone pills.
    - `BYPRODUCT`: Renders `"Beifang beim Sammeln von: "` with clickable parent herb/ore links.
    - `VENDOR`: Renders `"Händlerkauf: "` + price / faction / token cost.
    - `INSTANCE`: Renders `"Instanzbeute: "` + dungeon / raid name.
    - `CONTAINER`: Renders `"Enthalten in: "` with clickable container link (e.g. `[Beutel mit Angelangeltem]`).
  - Render `yields` as interactive, clickable item links (with `OnEnter` displaying `GameTooltip:SetHyperlink(...)`).
  - Render `tip` via `GSF.L[entry.tipKey]`.

### 2. `UI/Widgets/GoalsHUD.lua` (Personal Goals Tracking)
- **Zero-Fuzzy Bag Counting**: Because goals pinned from Atlas now store the real `itemID` directly, `GoalsHUD` never needs fuzzy text matching between "Kupfervorkommen" and "Kupfererz"!
- Bag counts are 100% reliable via `GetItemCount(goal.itemID)`.

### 3. `Modules/SupplyChain/SupplyBounties.lua` (Atlas Material Bounties)
- Clicking *"Material anfordern"* in Atlas immediately seeds the bounty with `target.itemID` and `target.category`.
- Removes any residual conversion heuristics.

### 4. `Locales/enUS.lua` and `Locales/deDE.lua` (Localization Cleanup)
- **Delete Dead Keys**: Remove the ~120 manual German node and zone translations that are now natively rendered by the engine.
- **Add Curated Tips**: Add compact, high-value farming advice keys (`ATLAS_TIP_2770`, `ATLAS_TIP_2447`, etc.).

---

## 📋 Proposed Implementation Phasing

### Phase 1: Engine Cache & Schema Infrastructure
- Create `Modules/Gathering/AtlasEngine.lua` (or overhaul `AtlasData.lua`) with async pre-cache worker and `GET_ITEM_INFO_RECEIVED` handler.
- Define `GSF.AtlasCategories` mapping `MINING`, `HERBALISM`, `SKINNING`, `CLOTH`, `ELEMENTAL`, `FISHING` to SpellIDs and ItemClass IDs.

### Phase 2: Verified Material Catalog Population
- Populate catalog with verified IDs for Mining, Herbalism, Skinning, Cloth, Elemental, and Fishing.
- Include verified Area IDs and byproduct item IDs.

### Phase 3: TabAtlas UI Binding & Downstream Wiring
- Update `TabAtlas.lua` left scroll rows and right detail pane to consume the dynamic engine.
- Update `GoalsHUD.lua` and `SupplyBounties.lua` to leverage pure `itemID`.

### Phase 4: Localization Pruning & Verification
- Clean up dead localization strings in `enUS.lua` and `deDE.lua`.
- Run pre-flight verification script to ensure 100% TOC, syntax, and dictionary parity.

---

## Verification Plan

### Automated Verification
1. **Pre-flight Syntax & TOC Checker**: Run `deploy.ps1` to confirm zero Lua syntax breaks across all modified files.
2. **ID Integrity Script**: A scratch script verifying that no duplicate IDs or invalid category strings exist in the database.

### Manual In-Game Verification
1. Log in with a fresh character session to confirm async loading handles uncached items gracefully without UI hitches.
2. Open Atlas Tab in both German (`deDE`) and English (`enUS`):
   - Confirm all item names appear in the native client language.
   - Confirm all zone names appear in the native client language via `C_Map.GetAreaInfo`.
   - Confirm byproduct links (`[Rauer Stein]`, `[Malachit]`) show proper tooltips on hover.
3. Pin an item (`[Kupfererz]`) to Goals HUD: verify instant bag count tracking without name mismatch.
4. Click *"Material anfordern"*: verify the bounty modal opens pre-filled with the exact item icon, link, and ID.
