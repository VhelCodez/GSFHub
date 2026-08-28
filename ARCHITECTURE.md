# 🏛️ GSFHub Technical Architecture & Developer Reference

**GSFHub** is a decentralized, peer-to-peer World of Warcraft Classic TBC addon designed specifically for **Guild Self-Found (GSF)** and **Solo Self-Found (SSF)** guilds. It coordinates professions, known recipes, crafting requests, surplus material sharing, recipe drops, a 1–375 resource farming atlas, guild supply chain bounties, and alt management.

---

## 🎯 Target Environment & Compatibility
- **Game Version:** World of Warcraft Classic TBC (`Interface: 20506`, compatible with modern Classic 2.5.x / 1.15+ frame engines).
- **Runtime Environment:** Lua 5.1 / Modern FrameXML with `BackdropTemplate` mixins.
- **Dependencies:** 100% self-contained. All required libraries (`LibStub`, `Ace3`, `LibDeflate`, `LibDataBroker`, `LibDBIcon`) are embedded directly in `Libs/`.

---

## 🏗️ System Architecture & Layer Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│   MainFrame.lua • 6-Tab Interface (Professions, Orders,     │
│   Surplus, Drops, Atlas, Roster) • TabSettings.lua [⚙]      │
│   GoalsHUD • Minimap • Toasts • Dialogs                     │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                       Functional Modules                    │
│   Professions (Scanner & RecipeBook) • WorkOrders           │
│   SurplusExchange • RecipeDrops • AtlasData (1-375)         │
│   SupplyBounties • TradeHelper • MailHelper                 │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                    Core, Identity & Storage                 │
│   Core.lua • Database.lua (GSFHubDB & GSFHubCache)          │
│   Alts.lua • Roles.lua • VersionCheck • Localization.lua    │
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
    showGoalsHUD = true,                -- Personal Goals HUD overlay visibility
    goalsHUDPos = { point = "TOPRIGHT", x = -200, y = -150 },
    mainCharacter = "CharacterName",    -- Player's designated Main character
    myRoleTags = { "MINER", "HERBALIST" },
    myGoals = {
        ["<GoalId>"] = { id = "...", name = "Fel Iron Ore", itemID = 23424, current = 8, target = 20, icon = 134567 }
    },
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
            roles = { "CRAFTER", "MASTER_CRAFTER" },
            lastSeen = 1700000000,
            professions = {
                ["Tailoring"] = {
                    name = "Tailoring",
                    curRank = 375,
                    maxRank = 375,
                    lastScanned = 1700000000,
                    recipes = { ... }
                }
            },
            surplus = { ... }
        }
    },
    workOrders = { ... },
    bounties = {
        ["<BountyId>"] = {
            id = "BT-Requester-1700000000",
            requester = "RequesterName",
            claimer = "GathererName",
            item = "Fel Iron Ore",
            itemID = 23424,
            count = 20,
            status = "IN_TRANSIT",      -- OPEN, CLAIMED, IN_TRANSIT, COMPLETED, CANCELLED
            timestamp = 1700000000,
            mailedAt = 1700000500,
            recipe = "Fel Iron Chain Vest"
        }
    },
    recentDrops = { ... },              -- Last 30 recipe drops recorded
    alts = {
        ["AltCharacter"] = "MainCharacter"
    },
    revisions = {
        recipes = 12,
        orders = 5,
        surplus = 8,
        bounties = 4
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
| `BTN` | `BOUNTY_NEW` | `GUILD` | Broadcasts a newly posted gathering material bounty |
| `BTC` | `BOUNTY_CLAIM` | `GUILD` | Broadcasts that a gatherer claimed a bounty |
| `BTM` | `BOUNTY_MAILED` | `GUILD` | Broadcasts that materials were mailed (`IN_TRANSIT`) |
| `BTF` | `BOUNTY_FULFILL` | `GUILD` | Fulfills bounty after 3-factor mail/bag verification |
| `BTX` | `BOUNTY_CANCEL` | `GUILD` | Cancels an active bounty |

---

## 🧩 Functional Module Lifecycles

### 1. Profession Scanner (`Modules/Professions/Scanner.lua`)
- Hooks: `TRADE_SKILL_SHOW`, `TRADE_SKILL_UPDATE`, `CRAFT_SHOW`, `CRAFT_UPDATE`, `SKILL_LINES_CHANGED`.
- Scans all recipe lines, extracts output item links, spell IDs, reagents, and counts.
- Automatically increments `GSFHubCache.revisions.recipes` and triggers `GSF.Sync:SendMyData()`.

### 2. Recipe Search Index (`Modules/Professions/RecipeBook.lua`)
- Multi-factor search across all guild members (online and offline).
- Indexed by: Result Item Name, Enchant Name, Reagent Name, Profession Type, and Online Status.

### 3. Supply Chain Bounties (`Modules/SupplyChain/SupplyBounties.lua`)
- 1-click recipe breakdown turning missing crafting reagents into bounties.
- **3-Factor Handshake:** Verifies claimer name, unique `[GSF-BT:XYZ]` mail token, and stack count upon `MAIL_SHOW` and `BAG_UPDATE`.

### 4. 1–375 Resource Farming Atlas (`Modules/Gathering/AtlasData.lua`)
- Encyclopedic database covering 1–300 Vanilla and 300–375 TBC resources with native `itemID`s for automatic locale translation.

### 5. Draggable Goals HUD (`UI/Widgets/GoalsHUD.lua`)
- Onscreen overlay frame displaying visual progress bars and dynamic bag counting on `BAG_UPDATE`.

### 6. Dedicated Settings View (`UI/Tabs/TabSettings.lua`)
- Card-based preferences interface accessible via title bar cog `[⚙]` or `/gsf settings`.
- Provides two-way synchronized Goals HUD controls, independent audio alert toggles, auto-scan settings, and diagnostics.

---

## 🚀 Release & Versioning Workflow
- Semantic versioning: `vMajor.Minor.Patch` (e.g. `v1.0.0`, `v1.1.0`, `v1.2.0`, `v1.2.1`, `v1.2.2`, `v1.2.3`).
- GitHub Action (`.github/workflows/release.yml`) triggers on tag push (`git push origin v1.X.X`), automatically builds `GSFHub-vX.X.X.zip` containing code, `README.md`, `CHANGELOG.md`, and `LICENSE`.
