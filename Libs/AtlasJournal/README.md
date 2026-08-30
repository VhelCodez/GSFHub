# 📖 AtlasJournal (`LibAtlasJournal-1.0`)

**AtlasJournal** is a standalone, lightweight, and zero-string-localized gathering compendium and resource reference engine for World of Warcraft Classic (Vanilla 1–300) and The Burning Crusade (300–375).

## ✨ Features
- **132 Verified Relational Material Entries:** Meticulously cataloged items keyed strictly by official Blizzard `itemID`.
- **13 Polymorphic Acquisition Source Types:** Mined nodes, herbs, prospecting, disenchanting, gas extraction, transmutes, smelted bars, monster drops, fishing, byproducts, instances, vendors, and combines.
- **Zero-String Engine Localization:** Native client resolution via `GetItemInfo()`, `GetSpellInfo()`, and `C_Map.GetAreaInfo()`.
- **Embedded Multilingual Support:** Built-in English and German tooltips, source labels, and 90+ curated strategic farming notes.
- **Asynchronous Cache Priming:** Recursively requests item data on `PLAYER_ENTERING_WORLD` with debounced `ON_DATA_READY` callback events.
- **LibStub Compatible:** Registers as `LibAtlasJournal-1.0` if `LibStub` is present; falls back to global `AtlasJournal`.

## 🚀 Quick Start for Addon Developers

### 1. Register Callback
```lua
AtlasJournal:RegisterCallback("ON_DATA_READY", function()
    print("AtlasJournal item cache refreshed from server!")
end)
```

### 2. Search & Query Resources
```lua
-- Search for a material across active category
local results = AtlasJournal:Search("Adamantite", "MINING")

-- Get polymorphic sources for an item
local sources = AtlasJournal:GetSources(23425) -- Adamantite Ore
for _, src in ipairs(sources) do
    if src.type == "GATHER" then
        print("Gather in zones: " .. table.concat(src.zones, ", "))
    end
end

-- Get localized farming tips
local tip = AtlasJournal:GetTip(23425)
print(tip)
```
