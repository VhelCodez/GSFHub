# GSFHub (Guild Self-Found Hub) for WoW Classic TBC

**GSFHub** is a decentralized, peer-to-peer World of Warcraft Classic TBC addon designed specifically for **Guild Self-Found (GSF)** and **Solo Self-Found (SSF)** guilds. It provides an all-in-one suite for profession coordination, recipe lookups, crafting requests, surplus material sharing, recipe drop distribution, and alt management.

---

## 🌟 Key Features

### 1. 📖 Unified Guild Recipe Book & Search
- **Auto-Scanning:** Automatically indexes known recipes, spell IDs, and required reagents whenever you open your Trade Skill or Craft windows (Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking, Tailoring, Jewelcrafting, Cooking, First Aid, Rogue Lockpicking).
- **Offline & Online Directory:** Search any recipe, crafted item, or reagent to see which guild members can craft it, their current skill level (`375/375`), and their online status—even if they are currently offline!
- **One-Click Actions:** Whisper crafters directly or open a pre-filled Work Order with one click.

### 2. 📋 Work Orders & Crafting Requests
- **Post Work Orders:** Request items, gear, bags, enchants, or gems with quantity, notes, and a toggle for whether you provide materials.
- **Order Claiming:** Online crafters can claim orders to prevent duplicate work.
- **Smart Toast Notifications:** Crafters receive subtle toast and audio notifications when someone posts a work order matching their profession.
- **Order Lifecycle:** Track requests through `OPEN` ➔ `CLAIMED` ➔ `COMPLETED` stages.

### 3. 📦 Surplus Material Exchange & Stockpile
- **Share Surplus Materials:** Easily offer surplus ores, herbs, cloth, gems, consumables, or BoE items directly from your bags.
- **Virtual Guild Stockpile:** Browse what materials guildies have available to give away without needing a central bank alt.
- **One-Click Requests & Fast Staging:** Request items with instant whisper prompts or stage them automatically into Mail and Trade windows.

### 4. 🎲 Recipe Drop Coordinator & Wishlist
- **Loot Monitor:** Detects when recipes, patterns, plans, schematics, or formulas drop in party/raid.
- **Intelligent Matching:** Cross-references the dropped pattern against your guild's database to immediately identify which guild crafters do not know it yet.
- **Personal Wishlists:** Add coveted patterns to your wishlist so the group knows who wants them most.
- **Party/Raid Announcements:** Optional automated group chat announcements highlighting eligible crafters.

### 5. 🎭 Main & Alt Account Linking
- Set your primary Main character identity.
- In all lists, crafters and requesters are cleanly displayed as `AltName (MainName)` so everyone knows who is who.

### 6. 🔄 Decentralized P2P Sync with Offline Persistence
- Automatically synchronizes data over the hidden `GUILD` addon communication channel using compact serialization and `LibDeflate` compression.
- Data is saved in persistent `SavedVariables` (`GSFHubCache`), ensuring you have immediate offline access to all guild knowledge.

---

## 🚀 Installation

1. Download or clone this repository.
2. Copy the entire `GSFHub` folder into your World of Warcraft directory:
   ```
   World of Warcraft/_classic_/Interface/AddOns/GSFHub
   ```
3. Restart or reload World of Warcraft (`/reload`).
4. Ensure **GSFHub** is checked in your AddOns menu on the character selection screen.

---

## ⌨️ Slash Commands

| Command | Description |
| :--- | :--- |
| `/gsf` or `/gsfhub` | Toggle the main GSFHub window |
| `/gsf scan` | Force-scan the currently open profession window |
| `/gsf sync` | Request a full synchronization broadcast from online guild members |
| `/gsf main <Name>` | Set your Main character's name |
| `/gsf help` | Show in-game command help |

---

## 🖥️ UI Navigation

- **Minimap Button:** Left-click toggles the main window; right-click scans the open profession; hover over the icon to view active orders and sync status.
- **TradeSkill Frame Integration:** A dedicated **"GSF Sync"** button appears in the top-right corner of standard TradeSkill and Craft frames.
- **Tabs:**
  - **Professions:** Search recipes by name or reagent, filter by trade skill, view required reagents, and browse crafters.
  - **Work Orders:** Active requests board and "+ New Work Order" dialog.
  - **Surplus Pool:** Guild material exchange and bag item listing modal.
  - **Drops & Wishlist:** Recent group recipe drops log and personal wishlist manager.
  - **Roster & Sync:** Main/Alt linking, sync statistics, audio/toast toggles, and guild member roster.

---

## 🗺️ Roadmap & Upcoming Features

Check out our full **[ROADMAP.md](ROADMAP.md)** for detailed milestone plans.

- **v1.0.0 (Released):** Core profession directory, work orders, surplus exchange, recipe drops & P2P sync.
- **v1.1.0 (Released):** Multi-Language architecture (English & German), in-game language switcher, P2P version gossip & update reminders, and in-game diagnostic bug report helper.
- **v1.2.0 (Released):** Gathering Suite & Guild Supply Chain (1-375 Resource Farming Atlas, Crafter ➔ Gatherer bounties with in-transit mail tracking & 3-factor verification, Role hierarchy badges, and draggable Goals HUD).
- **v1.3.0+ (Next Up):** Discord integration & community-driven extensions.

---

## 🛠️ Architecture & Compatibility

- **Target Engine:** Modern WoW Classic TBC (`Interface: 20504`, compatible with modern Classic Lua/FrameXML).
- **Libraries Embedded:** `LibStub`, `CallbackHandler-1.0`, `AceAddon-3.0`, `AceEvent-3.0`, `AceComm-3.0`, `AceSerializer-3.0`, `AceTimer-3.0`, `AceConsole-3.0`, `LibDataBroker-1.1`, `LibDBIcon-1.0`, `LibDeflate`.
