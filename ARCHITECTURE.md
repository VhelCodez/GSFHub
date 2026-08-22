# 🏛️ GSFHub Technical Architecture & Developer Reference

**GSFHub** is a decentralized, peer-to-peer World of Warcraft Classic TBC addon designed specifically for **Guild Self-Found (GSF)** and **Solo Self-Found (SSF)** guilds. It coordinates professions, known recipes, crafting requests, surplus material sharing, recipe drops, and alt management.

---

## 🎯 Target Environment & Compatibility
- **Game Version:** World of Warcraft Classic TBC (`Interface: 20504`, compatible with modern Classic 2.5.x / 1.15+ frame engines).
- **Runtime Environment:** Lua 5.1 / Modern FrameXML with `BackdropTemplate` mixins.
- **Dependencies:** 100% self-contained. All required libraries (`LibStub`, `Ace3`, `LibDeflate`, `LibDataBroker`, `LibDBIcon`) are embedded directly in `Libs/`.

---

## 🏗️ System Architecture & Layer Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      UI Presentation Layer                  │
│   MainFrame (Tabs: Professions, WorkOrders, Surplus, Drops, │
│   Roster) • TradeSkillHook • Minimap • Toast • Dialogs      │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                       Functional Modules                    │
│   Professions (Scanner & RecipeBook) • WorkOrders           │
│   SurplusExchange • RecipeDrops • TradeHelper • MailHelper  │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                    Core, Identity & Storage                 │
│   Core.lua • Database.lua (GSFHubDB & GSFHubCache)          │
│   Alts.lua • VersionCheck.lua • Locales (Localization.lua)  │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                   Networking & Gossip Engine                │
│   Sync.lua (P2P Gossip over GUILD) • Protocol.lua           │
│   AceComm-3.0 • AceSerializer-3.0 • LibDeflate              │
└─────────────────────────────────────────────────────────────┘
```

---

## 💾 Data Persistence Model (`SavedVariables`)

### 1. `GSFHubDB` (Per-Account Local Preferences)
Stored per user account in `WTF/Account/<ACCOUNT>/SavedVariables/GSFHub.lua`:
```lua
GSFHubDB = {
    selectedLocale = "auto",            -- "auto", "enUS", "deDE"
    enableToasts = true,                -- Visual toast popups
    enableSounds = true,                -- Audio notifications
    announceDropsToParty = true,        -- Party/raid chat alerts on recipe drops
    autoScanOnOpen = true,              -- Auto-scan when opening trade skill window
    mainCharacter = "CharacterName",    -- Player's designated Main character
    minimap = {
        hide = false,
        minimapPos = 220,               -- Angle around minimap in degrees
    },
    myWishlist = {
        ["<itemId or name>"] = { name = "...", link = "...", addedAt = 1700000000 }
    },
    myWorkOrders = { ... },
    mySurplus = { ... },
    characterProfessions = { ... },     -- Local character profession snapshots
}
```

### 2. `GSFHubCache` (Guild-Wide Shared Database)
Persistent cross-session repository of all synced guild data:
```lua
GSFHubCache = {
    guildName = "Guild Name",
    realmName = "Realm Name",
    members = {
        ["MemberName"] = {
            name = "MemberName",
            main = "MainName",
            class = "MAGE",
            lastSeen = 1700000000,
            professions = {
                ["Tailoring"] = {
                    name = "Tailoring",
                    curRank = 375,
                    maxRank = 375,
                    lastScanned = 1700000000,
                    recipes = {
                        ["SpellIdOrName"] = {
                            name = "Spellstrike Hood",
                            key = 31338,
                            itemLink = "[Spellstrike Hood]",
                            recipeLink = "[Pattern: Spellstrike Hood]",
                            reagents = {
                                { name = "Spellcloth", count = 10, link = "..." },
                                { name = "Primal Nether", count = 1, link = "..." }
                            },
                            skillType = "optimal"
                        }
                    }
                }
            },
            surplus = {
                ["ItemId"] = { id = "...", name = "...", count = 20, link = "...", owner = "...", timestamp = ... }
            }
        }
    },
    workOrders = {
        ["<OrderId>"] = {
            id = "Requester-1700000000-123",
            requester = "Alice",
            crafter = "Bob",            -- nil if OPEN
            item = "Spellstrike Hood",
            count = 1,
            profession = "Tailoring",
            matsProvided = true,
            notes = "Tip included!",
            status = "OPEN",            -- OPEN, CLAIMED, COMPLETED, CANCELLED
            timestamp = 1700000000
        }
    },
    recentDrops = { ... },              -- Last 30 recipe drops recorded
    alts = {
        ["AltCharacter"] = "MainCharacter"
    },
    revisions = {
        recipes = 12,
        orders = 5,
        surplus = 8
    }
}
```

---

## 📡 P2P Gossip Protocol & Opcodes (`Comm/`)

All communications occur over the hidden WoW addon channel (`C_ChatInfo.SendAddonMessage` / `AceComm-3.0`) with prefix **`GSFHUB`**.

### Protocol Flow:
1. **Heartbeat Broadcast (`HELLO`):** Sent on login and every 10 minutes over `GUILD`. Contains local version digest and revisions.
2. **Data Synchronization (`REQ_DATA` / `RESP_DATA`):** Triggered when a peer detects an outdated record or newly online member.
3. **Payload Compression:** Lua Tables ➔ `AceSerializer-3.0` ➔ `LibDeflate:CompressDeflate` ➔ `LibDeflate:EncodeForWoWAddonChannel` (Safe 64-char printable ASCII) ➔ `AceComm-3.0` multi-part chunking.

### Opcode Reference Table:
| Opcode | Name | Distribution | Description |
| :--- | :--- | :--- | :--- |
| `HLO` | `HELLO` | `GUILD` | Heartbeat containing addon version, main character, and revision hashes |
| `RQD` | `REQ_DATA` | `WHISPER` | Targeted request for a member's full profession/recipe profile |
| `RSD` | `RESP_DATA` | `WHISPER` / `GUILD` | Delivers serialized member profile (professions, recipes, surplus) |
| `WON` | `WORK_ORDER_NEW` | `GUILD` | Broadcasts a newly submitted work order |
| `WOC` | `WORK_ORDER_CLAIM`| `GUILD` | Broadcasts that a crafter has claimed an active work order |
| `WOS` | `WORK_ORDER_STAT` | `GUILD` | Updates work order state (`COMPLETED` / `CANCELLED`) |
| `SPN` | `SURPLUS_NEW` | `GUILD` | Broadcasts new surplus material offering |
| `SPR` | `SURPLUS_REM` | `GUILD` | Removes a surplus listing |
| `SPC` | `SURPLUS_CLAIM` | `WHISPER` | Requests a listed surplus item |
| `ALT` | `ALT_UPDATE` | `GUILD` | Broadcasts Main/Alt association |
| `WLU` | `WISHLIST_UPDATE`| `GUILD` | Broadcasts recipe wishlist updates |

---

## 🧩 Functional Module Lifecycles

### 1. Profession Scanner (`Modules/Professions/Scanner.lua`)
- Hooks: `TRADE_SKILL_SHOW`, `TRADE_SKILL_UPDATE`, `CRAFT_SHOW`, `CRAFT_UPDATE`, `SKILL_LINES_CHANGED`.
- Scans all recipe lines, extracts output item links, spell IDs, reagents, and counts.
- Automatically increments `GSFHubCache.revisions.recipes` and triggers `GSF.Sync:SendMyData()`.

### 2. Recipe Search Index (`Modules/Professions/RecipeBook.lua`)
- Provides fast, multi-factor search across all guild members (online and offline).
- Indexed by: Result Item Name, Enchant Name, Required Reagent Name, Profession Type, and Online Status.

### 3. Work Order Manager (`Modules/WorkOrders/WorkOrders.lua`)
- Handles order creation, unique ID generation (`<Player>-<Timestamp>-<Random>`), claiming, completion, and 7-day expiration cleanup.

### 4. Recipe Drops Coordinator (`Modules/Drops/RecipeDrops.lua`)
- Listens to `CHAT_MSG_LOOT` and `LOOT_OPENED`.
- Detects recipe item patterns (`itemType == "Recipe"` or pattern keyword search).
- Cross-references eligible guild crafters who have not learned it yet and matching wishlists.

---

## 🚀 Release & Versioning Workflow
- Semantic versioning: `vMajor.Minor.Patch` (e.g. `v1.0.0`, `v1.1.0`).
- GitHub Action (`.github/workflows/release.yml`) triggers on tag push (`git push origin v1.X.X`), automatically builds `GSFHub-vX.X.X.zip`, and publishes a GitHub Release using native GitHub CLI.
