# GSFHub (Guild Self-Found Hub) for WoW Classic TBC

[![Latest Release](https://img.shields.io/github/v/release/VhelCodez/GSFHub?color=blue&label=Release)](https://github.com/VhelCodez/GSFHub/releases)
[![WoW Classic](https://img.shields.io/badge/WoW%20Classic-TBC%202.5.6%20(20506)-orange.svg)](https://wago.tools)
[![Locales](https://img.shields.io/badge/Locales-English%20%7C%20Deutsch-brightgreen.svg)](Locales/)
[![Web Guide](https://img.shields.io/badge/Web%20Guide-Live%20Docs-9333ea.svg)](https://vhelcodez.github.io/GSFHub/)
[![Blizzard Sync](https://img.shields.io/github/actions/workflow/status/VhelCodez/GSFHub/check-client-version.yml?label=Blizzard%20Sync)](https://github.com/VhelCodez/GSFHub/actions)
[![License](https://img.shields.io/github/license/VhelCodez/GSFHub?color=yellow)](LICENSE)

**GSFHub** is a decentralized, peer-to-peer World of Warcraft Classic TBC addon designed specifically for **Guild Self-Found (GSF)** and **Solo Self-Found (SSF)** guilds. It provides an all-in-one suite for profession coordination, recipe lookups, crafting requests, surplus material sharing, recipe drop distribution, and alt management.

👉 **[Explore the Interactive Web Guide & Documentation](https://vhelcodez.github.io/GSFHub/)**

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

### 6. 🔄 Decentralized P2P Sync with Multi-Guild & Solo Isolation
- Automatically synchronizes data over the hidden `GUILD` addon communication channel using compact serialization and `LibDeflate` compression.
- Data is saved in partitioned persistent `SavedVariables` (`GSFHubCache.scopes`), strictly isolating your guild knowledge from unguilded characters or characters in other guilds.
- Non-guild characters and non-guild orders are firewalled and never leaked to guildmates.

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
| `/gsf settings` | Open addon settings and preferences |
| `/gsf atlas` | Open Resource Farming Atlas & Bounties |
| `/gsf hud` | Toggle onscreen Goals HUD tracker |
| `/gsf scan` | Force-scan the currently open profession window |
| `/gsf sync` | Request a full synchronization broadcast from online guild members |
| `/gsf main <Name>` | Set your Main character's name |
| `/gsf bug` | Open bug report and diagnostic modal |
| `/gsf help` | Show in-game command help |

---

## 🖥️ UI Navigation

- **Header Cog Button (`[⚙]`):** Convenient 1-click shortcut in the top-right header next to Close to toggle the dedicated Settings view from anywhere.
- **Minimap Button:** Left-click toggles the main window; right-click scans the open profession; hover over the icon to view active orders and sync status.
- **TradeSkill Frame Integration:** A dedicated **"GSF Sync"** button appears in the top-right corner of standard TradeSkill and Craft frames.
- **Tabs:**
  - **Professions:** Search recipes by name or reagent, filter by trade skill, view required reagents, and browse crafters.
  - **Work Orders:** Active requests board, "+ New Work Order" dialog, and order editing for own open orders.
  - **Surplus Pool:** Guild material exchange and bag item listing modal.
  - **Drops & Wishlist:** Recent group recipe drops log and personal wishlist manager.
  - **Resource Atlas:** 1–375 pure ID-driven encyclopedic catalog powered by the decoupled `AtlasJournal` (`LibAtlasJournal-1.0`) library, with 13 polymorphic acquisition sources (mining, herbalism, skinning, disenchanting, gas extraction, transmutes, mob drops, fishing), zero-string client API localization, and 1-click Pin to HUD.
  - **Roster & Sync:** Role badges, Main/Alt linking, sync statistics, and expanded guild member roster table.
  - **Settings (`[⚙]`):** Symmetrical 2x2 preferences grid featuring Language selector, minimap toggle, decoupled audio alerts, auto-scan on open, Goals HUD settings with position reset, and Data & Cache Management (Rebuild Guild Cache, Clear Character Data, Safe Full Reset).

---

## 🗺️ Roadmap & Upcoming Features

Check out our full **[ROADMAP.md](ROADMAP.md)** for detailed milestone plans.

- **v1.0.0 (Released):** Core profession directory, work orders, surplus exchange, recipe drops & P2P sync.
- **v1.1.0 (Released):** Multi-Language architecture (English & German), in-game language switcher, P2P version gossip & update reminders, and in-game diagnostic bug report helper.
- **v1.2.0 (Released):** Gathering Suite & Guild Supply Chain (1–375 Resource Atlas, Bounties with in-transit mail tracking & 3-Factor Handshake, Role hierarchy badges, and draggable Goals HUD).
- **v1.2.1 (Released):** Critical container API fixes, UI layout collision adjustments, and localization parity.
- **v1.2.2 (Released):** Dedicated Settings view via header cog, Goals HUD two-way state sync, decoupled audio alerts, localized node names, German drop detection, and live translations.
- **v1.2.3 (Released):** Test Phase 2 live test polish: universal Shift-click paste & drag-and-drop `ItemSlot` preview, Escape key close, bounty lifecycle & Option B request modal, surplus soulbound filter, Atlas German localization, and layout collision fixes.
- **v1.2.4 (Released):** Comprehensive UI Harmonization: pixel-calibrated 12px checkbox gaps, Beute & Wunsch dual-column redesign, symmetrical Professions action bar, right-aligned Atlas navigation, empty state indicators across all views, dynamic modal localization, FrameStrata layering, and Goal HUD note/button parity.
- **v1.2.5 (Released):** Multi-Guild & Solo Character Scope Isolation: Partitioned cache database by Guild and Solo scope keys, automated guild roster verification and non-guild member pruning, P2P network sync firewall, and per-character profession scoping.
- **v1.2.6 (Released):** Character Scope Isolation for Wishlists & Goals: Partitioned recipe wishlists and personal goals by character key (`wishlistByChar` & `goalsByChar`), smart non-destructive legacy migration, and peer wishlist drop tracking.
- **v1.2.7 (Released):** Settings Data & Cache Management Suite: Non-destructive guild cache rebuilder, active character data reset, safe ghost-order-preventing factory reset, symmetrical Settings view layout, and pure character scoping with complete elimination of legacy migration technical debt.
- **v1.3.0 (Released):** Universal Resource Atlas & Multi-Source Gathering Compendium (Pure ID-driven relational schema, 13 polymorphic source types, cross-discipline filtering, and complete Classic & TBC gathering data).
- **v1.4.0 (Next Up):** Navigation Overhaul (Hybrid Pinned + Overflow `[ ⋯ More ▼ ]`), Cross-Character Account Cooldown Alarms, Active Gatherer Radar & Universal Search.
- **v1.5.0 (Planned):** Crafting Specializations, Specialization Planning with In-Game Quest Roadmaps, Shared Guild Cooldown Monitor.
- **v1.6.0 (Planned):** TBC Guild Bank & Vault Suite (Silent Snapshot Scanner, Remote Mirror, Smart Tab Surplus Sync, Reserve Alerts).
- **v1.7.0 (Planned):** Guild Intelligence, Macro Economy Analytics, Streamlined Stockpile Shortage Watcher & Activity Honor Roll.

---

## 🛠️ Architecture & Compatibility

- **Target Engine:** Modern WoW Classic TBC (`Interface: 20506`, compatible with modern Classic Lua/FrameXML).
- **Libraries Embedded:** `LibStub`, `CallbackHandler-1.0`, `AceAddon-3.0`, `AceEvent-3.0`, `AceComm-3.0`, `AceSerializer-3.0`, `AceTimer-3.0`, `AceConsole-3.0`, `LibDataBroker-1.1`, `LibDBIcon-1.0`, `LibDeflate`.
