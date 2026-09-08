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
│   SurplusExchange • RecipeDrops • SupplyBounties            │
│   TradeHelper • MailHelper                                  │
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
    goalsByChar = {                     -- Pure character-scoped personal goals
        ["<CharName> - <Realm>"] = { ... }
    },
    minimap = {
        hide = false,
        minimapPos = 220,               -- Angle around minimap in degrees
    },
    wishlistByChar = {                  -- Pure character-scoped recipe wishlists
        ["<CharName> - <Realm>"] = { ... }
    },
    characterProfessionsByChar = {      -- Pure character-scoped trade skill records
        ["<CharName> - <Realm>"] = { ... }
    },
    myWorkOrders = { ... },
    mySurplus = { ... },
}
```

> [!NOTE]
> **Pure Per-Character Storage & Zero Cross-Contamination:**
> To prevent cross-character data leaks, persistent `SavedVariables` storage is strictly partitioned per character (`wishlistByChar`, `goalsByChar`, `characterProfessionsByChar`). At runtime, in-memory pointers (`GSF.db.myWishlist`, `GSF.db.myGoals`, `GSF.db.characterProfessions`) dynamically bind directly to the active character's partition upon `PLAYER_ENTERING_WORLD`. Stale account-wide root mirrors and legacy migration fallbacks have been completely eliminated.


### 2. `GSFHubCache` (Partitioned Scoped Cache Database)
Persistent cross-session repository of all synced guild and solo data, partitioned strictly by Scope Key (`Guild - <GuildName> - <RealmName>` or `Solo - <PlayerName> - <RealmName>`):
```lua
GSFHubCache = {
    scopes = {
        ["Guild - Progression Guild - Nethergarde Keep"] = {
            scopeKey = "Guild - Progression Guild - Nethergarde Keep",
            guildName = "Progression Guild",
            realmName = "Nethergarde Keep",
            isGuild = true,
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
        },
        ["Solo - BankAlt - Nethergarde Keep"] = {
            scopeKey = "Solo - BankAlt - Nethergarde Keep",
            guildName = "",
            realmName = "Nethergarde Keep",
            isGuild = false,
            members = { ... },
            workOrders = { ... },
            ...
        }
    }
}
```

> [!NOTE]
> **Dynamic Scope Binding & Zero Data Contamination:**
> Upon login or guild status update (`PLAYER_ENTERING_WORLD`, `PLAYER_GUILD_UPDATE`), `GSF.cache` is bound directly to `GSFHubCache.scopes[activeScopeKey]`. Non-guild characters and cross-guild characters are strictly firewalled into separate scopes and never appear in foreign rosters or order boards. Roster updates automatically prune non-guild members from active guild caches.

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

### 4. 1–375 Resource Farming Atlas & Standalone Library (`Libs/AtlasJournal/`)
- Decoupled, headless `LibAtlasJournal-1.1` standalone library embedded in `Libs/AtlasJournal/`.
- Pure ID-driven relational database covering 1–300 Vanilla and 300–375 TBC resources with 236 verified `itemID` records across 8 categories, 13 polymorphic source types (including `CRAFT` with input/yield tracking), and pre-flight cache priming.
- Event-driven reactive callback mechanism (`ON_DATA_READY`), self-contained embedded localization (`enUS` / `deDE`), and isolated verification suite (`Libs/AtlasJournal/verify.ps1`), ready for extraction into an independent repository at any time.

### 5. Draggable Goals HUD (`UI/Widgets/GoalsHUD.lua`)
- Onscreen overlay frame displaying visual progress bars and dynamic bag counting on `BAG_UPDATE`.

### 6. Dedicated Settings & Cache View (`UI/Tabs/TabSettings.lua`)
- Symmetrical 2x2 card-based preferences interface accessible via title bar cog `[⚙]` or `/gsf settings`.
- Provides General & Display controls, Notifications & Audio, Data & Cache Management (Guild Cache Rebuilder, Character Reset, Safe Ghost-Order-Preventing Factory Reset), and Diagnostics.

---

## 📚 External Libraries Architecture & Upstream Tracking Standard

GSFHub follows the **Tracked Vendoring** architectural pattern used by premier World of Warcraft addons (Questie, WeakAuras, Details!). All external community libraries are committed directly into `Libs/` to enable zero-setup local execution while strictly using canonical upstream releases to maintain ecosystem compatibility.

### 1. Embedded Community Libraries Directory
| Library | Version / Minor | Architectural Purpose in GSFHub |
| :--- | :--- | :--- |
| **`LibStub`** | v1.0.3 / Minor 2 | Universal library manager and version negotiator. |
| **`CallbackHandler-1.0`** | Minor 8 | Underlying pub-sub event engine for AceEvent, AceComm, LibDBIcon, and LibDataBroker. |
| **`AceAddon-3.0`** | Minor 13 | Main addon lifecycle controller (`GSFHub = AceAddon:NewAddon(...)`). Coordinates SavedVariables loading (`ADDON_LOADED`) with character entry (`PLAYER_LOGIN`). |
| **`AceEvent-3.0`** | Minor 4 | Dispatches WoW game events (`GUILD_ROSTER_UPDATE`, `PLAYER_ENTERING_WORLD`) and inter-addon messages (`SendMessage`). |
| **`AceTimer-3.0`** | Minor 17 | High-accuracy scheduler for periodic P2P heartbeat sync (`BroadcastHello` every 600s), debounced scans, and delayed UI refreshes. |
| **`AceComm-3.0` & `ChatThrottleLib`** | Minor 14 / v24 | P2P network messaging over `CHAT_MSG_ADDON` (`GUILD` channel). Automatically chunks multi-part payloads (>255 bytes) and throttles transmission to prevent server disconnects. |
| **`AceSerializer-3.0`** | Minor 5 | Serializes Lua tables (professions, orders, surplus listings, recipe drops) into compact ASCII strings for P2P sync. |
| **`AceConsole-3.0`** | Minor 7 | Registers slash commands (`/gsf`, `/gsfhub`, `/gsfcraft`) and provides `GetArgs` parsing. |
| **`LibDeflate`** | v1.0.2 / Minor 3 | Pure Lua RFC1951 DEFLATE compression and safe 64-character ASCII encoding for WoW addon channels. |
| **`LibDataBroker-1.1`** | Minor 4 | Standard data provider feed (`GSFHub_LDB`) for display bars (Titan Panel, ChocolateBar, etc.). |
| **`LibDBIcon-1.0`** | Minor 55 | Places and manages the draggable GSFHub minimap launcher button with position persistence in `GSFHubDB.minimap`. |
| **`AtlasJournal`** | `LibAtlasJournal-1.1` | Headless 1–375 Classic & TBC resource and gathering compendium library developed natively for GSFHub. |

### 2. Ecosystem Compatibility & The LibStub Lifecycle Guarantee
- **Zero-Mock Policy:** Community libraries must **never** be mocked or custom-coded under official `LibStub` names.
- **Addon Load Order Resilience:** In WoW, addons load alphabetically (`GSFHub` before `Questie`). If an early addon registers a mock library with an equal minor version, it prevents subsequent addons from loading their real libraries. GSFHub embeds canonical libraries with full event lifecycle support (`ADDON_LOADED` dispatched prior to `PLAYER_LOGIN`), ensuring zero interference with other addons.
- **Runtime Upgrades:** If another addon loads with a newer minor version, `LibStub` automatically upgrades the in-memory instance without causing errors.

### 3. Upstream Maintenance Tooling
- **Local Synchronization (`scripts/update-libs.ps1`):** A one-command PowerShell tool that shallowly clones upstream official repositories (`WoWUIDev/Ace3`, `safeteeWow/LibDeflate`, `tekkub/libdatabroker-1-1`, `Questie/LibDBIcon-1.0`), copies canonical files into `Libs/`, and executes syntax verification.
- **Continuous Integration (`.github/workflows/check-libraries.yml`):** Runs monthly in GitHub Actions, automatically checking upstream repositories for updates and opening an issue if updates or patches are published.

---

## 🚀 Release & Versioning Workflow
- Semantic versioning: `vMajor.Minor.Patch` (e.g. `v1.0.0`, `v1.1.0`, `v1.2.0`, `v1.2.1`, `v1.2.2`, `v1.2.3`, `v1.2.4`, `v1.2.5`, `v1.2.6`, `v1.2.7`, `v1.3.0`, `v1.3.1`, `v1.3.2`, `v1.3.3`, `v1.3.4`).
- GitHub Action (`.github/workflows/release.yml`) triggers on tag push (`git push origin v1.X.X`), automatically builds `GSFHub-vX.X.X.zip` containing code, `README.md`, `CHANGELOG.md`, and `LICENSE`.
