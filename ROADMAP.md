# 🗺️ GSFHub Development Roadmap

This document outlines the version roadmap and upcoming milestones for **GSFHub (Guild Self-Found Hub)**.

---

## 📌 Release Schedule & Milestone Overview

```mermaid
graph LR
    v10["v1.0.0<br/><b>Core Suite</b><br/>(Released)"] --> v11["v1.1.0<br/><b>Multi-Language</b><br/>(Released)"]
    v11 --> v12["v1.2.3<br/><b>Gathering, Atlas & Polish</b><br/>(Released)"]
    v12 --> v13["v1.3.0<br/><b>Phase 3: Navigation & QoL</b><br/>(Next Up)"]
    v13 --> v14["v1.4.0<br/><b>Phase 4: Specializations & CDs</b><br/>(Planned)"]
    v14 --> v15["v1.5.0<br/><b>Phase 5: TBC Guild Vault</b><br/>(Planned)"]
    v15 --> v16["v1.6.0<br/><b>Phase 6: Guild Intelligence</b><br/>(Planned)"]
```

---

## 🚀 Released Milestones

### ✅ v1.2.3 - Test Phase 2 Polish & Input Enhancements *(Released)*
- [x] **Escape Key Close (`UISpecialFrames`):** Pressing `ESC` closes the window cleanly.
- [x] **Dynamic Header Subtitles:** Replaces static version display with live tab title subtitles.
- [x] **Universal Shift-Click Bag Item Paste:** Seamless bag link parsing into active GSF edit boxes without stack-splitting.
- [x] **Drag-and-Drop `ItemSlot` Preview:** Reusable Blizzard slot with 250ms debounced live icon resolution.
- [x] **Bounty Lifecycle Management:** Own bounty cancellation, gatherer unclaiming, completed bounty dismissal, and hide completed filter.
- [x] **Option B Material Request Modal:** Item preview slot, quantity input, and custom notes.
- [x] **Surplus & Atlas Polish:** Soulbound filtering, bag row selection highlight, German zone/yield localization, and layout collision fixes.

### ✅ v1.2.2 - Settings View & Quality-of-Life Polish *(Released)*
- [x] **Dedicated Settings View (`TabSettings.lua`):** Modular card layout for Language, Minimap, Goals HUD, Audio, and Diagnostics.
- [x] **Header Cog Button (`[⚙]`):** Fast 1-click access to Settings from any view while preserving 6 bottom tabs.
- [x] **Goals HUD Two-Way State Synchronization:** Live binding between UI checkbox and HUD frame events.
- [x] **Decoupled Audio Alerts:** Audio chimes play independently of visual toast frame suppression.
- [x] **Mining Node Localized Names:** Dedicated German vein name resolution (*Kupfervorkommen*, *Eisenvorkommen*, etc.).
- [x] **German Recipe Drop Detection:** `classID == 9` and German prefix support (*Muster:*, *Pläne:*, *Rezept:*).
- [x] **Work Order Editing & Completion Confirmation:** Edit own open orders and confirmation safety prompt on completion.

### ✅ v1.2.1 - Client Compatibility & UI Fixes *(Released)*
- [x] **Modern Container API Traps:** Resolved `attempt to call a nil value` across bag slot querying.
- [x] **UI Layout Collision Adjustments:** Dynamic tab resizing and layout spacing fixes.
- [x] **Full Dual-Language Key Parity:** Added complete German dictionary keys.

### ✅ v1.2.0 - Gathering Suite & Guild Supply Chain *(Released)*
- [x] **1–375 Resource Farming Atlas (`AtlasData.lua`):** Complete encyclopedia of Vanilla (1–300) and TBC (300–375) resources with native multilingual `itemID` resolution.
- [x] **Crafter ➔ Gatherer Supply Chain Bounties (`SupplyBounties.lua`):** 1-click recipe breakdown into material requests.
- [x] **In-Transit Postal Tracking:** Full postal lifecycle (`OPEN`, `CLAIMED`, `IN_TRANSIT`, `COMPLETED`) with real-time transit duration timer.
- [x] **3-Factor Verification Handshake:** Automatic mail receipt detection verifying sender, token, and item quantities upon mailbox opening and bag loot.
- [x] **Guild Role Specializations (`Roles.lua`):** Role badges (`[⛏️ Miner]`, `[🌿 Herbalist]`, `[🔪 Skinner]`, `[✨ Master Crafter]`) rendered in Roster and tooltips.
- [x] **Draggable Personal Goals HUD (`GoalsHUD.lua`):** Draggable onscreen tracker with real-time bag loot auto-counters.
- [x] **Resource Atlas UI Tab (`TabAtlas.lua`):** 6-tab expansion with category/skill filters, search, and 1-click pin/request buttons.

### ✅ v1.1.0 - Multi-Language Architecture & Version Reminders *(Released)*
- [x] **Client Auto-Detection:** Automatically detects WoW client locale via `GetLocale()` (defaults to German on `deDE` clients, English `enUS` otherwise).
- [x] **In-Game Language Switcher:** Dropdown in the Settings tab to switch between *"Auto"*, *"English"*, and *"Deutsch"* with real-time UI refresh.
- [x] **Authentic German Dictionary (`Locales/deDE.lua`):** Complete translations with guaranteed English fallback safety.
- [x] **P2P Version Gossip & Update Reminders:** In-game alert when guild members run a newer version with a 1-click copy dialog.
- [x] **In-Game Diagnostic & Bug Report Helper:** `/gsf bug` command generating pre-formatted GitHub issue diagnostics.

### ✅ v1.0.0 - Foundation & Core Suite *(Released)*
- [x] **Decentralized Profession Directory:** Auto-scans 10 trade skills.
- [x] **Persistent Offline Recipe Index:** Search recipes and crafters across all guild members even when offline.
- [x] **Work Orders & Crafting Requests Board:** Post crafting/enchanting requests with material toggles and crafter claiming.
- [x] **Surplus Material Exchange:** Share extra materials directly from bags without a guild bank alt.
- [x] **Recipe Drop Coordinator & Wishlist:** Detects recipe drops in party/raid, cross-references unlearned crafters and wishlists.
- [x] **Fast-Track Trade & Mail Helpers:** Auto-stages crafting mats into Trade and Mail frames.
- [x] **P2P Sync Engine:** Peer-to-peer sync with `LibDeflate` compression over the hidden `GUILD` channel.

---

## 🔮 Upcoming Milestones

### 🚀 Phase 3 (`v1.3.0`) - Navigation Overhaul & Personal QoL Suite *(Next Up)*
*Detailed plan:* [`.gemini/plans/phase_3_implementation_plan.md`](.gemini/plans/phase_3_implementation_plan.md)
- [ ] **Hybrid Pinned + Overflow Navigation (`[ ⋯ More ▼ ]`):** Customizable tab bar with overflow dropdown and active label display.
- [ ] **Cross-Character Account Cooldown Alarms (`Cooldowns.lua`):** Onscreen toast & audio chime on your main when an alt's trade skill CD is ready.
- [ ] **Active Gatherer Radar (`GathererRadar.lua`):** Field farming session broadcaster and live radar board.
- [ ] **Universal Guild Material Search:** 1-box search across all surplus, trade offers, and crafter capabilities.

---

### 🛠️ Phase 4 (`v1.4.0`) - Crafting Specializations & Shared Cooldowns
*Detailed plan:* [`.gemini/plans/phase_4_implementation_plan.md`](.gemini/plans/phase_4_implementation_plan.md)
- [ ] **Profession Sub-Specializations (`Specializations.lua`):** Auto-detection & badges for Tailoring, Blacksmithing, Leatherworking, Alchemy, Engineering.
- [ ] **Specialization Planning & In-Game Quest Roadmaps:** Aspirational `(Planned: ...)` tags with built-in quest walkthroughs and turn-in checklists.
- [ ] **Shared Guild Cooldown Monitor:** Live cooldown availability tags displayed next to crafter names on recipes.

---

### 🏛️ Phase 5 (`v1.5.0`) - TBC Guild Bank & Vault Automation Suite
*Detailed plan:* [`.gemini/plans/phase_5_implementation_plan.md`](.gemini/plans/phase_5_implementation_plan.md)
- [ ] **TBC Guild Vault Scanner & Remote Mirror (`GuildBankScanner.lua`):** Silent snapshot scanning with revision digests (< 1 KB) allowing remote vault browsing anywhere.
- [ ] **Smart Bank Tab Tagging & Surplus Sync (`VaultSurplus.lua`):** Designate bank tabs as surplus stockpiles (`[🏛️ Guild Vault]`) for holiday absences.
- [ ] **Direct-to-Vault Bounties & 1-Click Deposit Helper:** Restock bounties targeted for the bank vault with 1-click deposit.
- [ ] **Minimum Reserve Thresholds & Auto-Restock Alerts (`ReserveThresholds.lua`):** Configurable low-stock alerts.
- [ ] **Remote Guild Bank Browser Tab (`TabGuildBank.lua`):** Search and browse all accessible guild bank tabs.

---

### 📊 Phase 6 (`v1.6.0`) - Guild Intelligence, Economy & Social Suite
*Detailed plan:* [`.gemini/plans/phase_6_implementation_plan.md`](.gemini/plans/phase_6_implementation_plan.md)
- [ ] **Macro Economy Analytics & Intelligent Advisory (`EconomyStats.lua`):** Crafter/gatherer ratios and "Guild Needs" recommendations.
- [ ] **Streamlined Stockpile & Shortage Watcher (`StockpileWatcher.lua`):** Target vs. stock table with 1-click bounty requests.
- [ ] **Guild Recipe Knowledge Matrix & Gap Analysis (`KnowledgeMatrix.lua`):** Covered raid patterns vs. unlearned gaps with drop info.
- [ ] **Activity Ledger & Honor Roll Leaderboard (`ActivityLedger.lua`):** Decentralized live event timeline and contributor recognition.

---

## 💬 Community Feedback & Feature Requests
Have an idea or want to request a feature? Feel free to open an **[Issue](https://github.com/VhelCodez/GSFHub/issues)** or start a **[Discussion](https://github.com/VhelCodez/GSFHub/discussions)** on GitHub!
