# Phase 0 Plan: Foundation & Core Suite Architecture (v1.0.0)

> **Persistent Repository Archive**: Stored in `.gemini/plans/phase_0_plan.md` for historical auditing and foundational feature verification.

## 🎯 Phase 0 Goals & Core Deliverables

### 1. Core Architecture & Self-Contained Libraries
- **Embedded Libs (`Libs/`):** `LibStub`, `CallbackHandler-1.0`, `Ace3` (`AceAddon-3.0`, `AceComm-3.0`, `AceConsole-3.0`, `AceEvent-3.0`, `AceSerializer-3.0`, `AceTimer-3.0`), `LibDeflate`, `LibDataBroker-1.1`, `LibDBIcon-1.0`.
- **Persistence Model:**
  - `GSFHubDB`: Per-character settings, personal wishlist, work orders, surplus offers.
  - `GSFHubCache`: Guild-wide shared cache (all member recipes, active orders, surplus, alts).

### 2. Decentralized Trade Skill Scanner & Offline Recipe Directory
- **Files:** `Modules/Professions/Scanner.lua`, `Modules/Professions/RecipeBook.lua`, `UI/Tabs/TabProfessions.lua`
- Silent background scanning of 10 trade skills: Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking, Tailoring, Jewelcrafting, Cooking, First Aid, Lockpicking.
- Instant search across all guild crafters, even when they are offline.
- Detailed reagent breakdowns with player bag counters and 1-click *"Request Craft"* work order integration.

### 3. Crafting Work Orders Board
- **Files:** `Modules/WorkOrders/WorkOrders.lua`, `UI/Tabs/TabWorkOrders.lua`
- Custom crafting and enchanting requests with material toggles (`Mats Provided` vs `No Mats`), quantity, and notes.
- Lifecycle: `OPEN` ➔ `CLAIMED` ➔ `COMPLETED` / `CANCELLED`.
- Filter by *"Only My Professions"* for quick crafter claiming.

### 4. Surplus Material Exchange Stockpile
- **Files:** `Modules/Surplus/SurplusExchange.lua`, `UI/Tabs/TabSurplus.lua`
- Direct bag-to-guild material sharing without requiring a central guild bank alt.
- 1-click *"Request"* / *"Whisper"* delivery setup.

### 5. Recipe Drop Sniffer & Personal Wishlist
- **Files:** `Modules/Drops/RecipeDrops.lua`, `UI/Tabs/TabDrops.lua`
- Monitors party/raid `CHAT_MSG_LOOT` events for recipe drops.
- Automatically matches unlearned crafters and wishlisted members and announces matches in party/raid chat.

### 6. Fast-Track Trade & Mail Staging Helpers
- **Files:** `Modules/TradeMail/TradeHelper.lua`, `Modules/TradeMail/MailHelper.lua`
- Auto-stages requested work order materials into Trade and Mail windows with 1 click.

### 7. Main / Alt Identity Management
- **Files:** `Core/Alts.lua`, `UI/Tabs/TabRoster.lua`
- Links secondary characters under a primary main name, synchronized across the guild mesh.

### 8. Decentralized P2P Networking Mesh
- **Files:** `Comm/Protocol.lua`, `Comm/Sync.lua`
- High-efficiency `AceSerializer` + `LibDeflate` compression and base64 encoding over the hidden `GUILD` addon communication channel.
- Automatic handshake on login and differential data synchronization.

### 9. Presentation Layer & Minimap Integration
- **Files:** `UI/MainFrame.lua`, `UI/Minimap.lua`, `UI/Widgets/Backdrop.lua`, `UI/Widgets/Toast.lua`
- 5-tab authentic parchment/slate main frame with draggable Minimap icon and toast popup alerts.
