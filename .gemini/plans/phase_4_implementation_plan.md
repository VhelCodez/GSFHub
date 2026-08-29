# Phase 4 Implementation Plan: Navigation Overhaul & Personal QoL Suite (v1.4.0)

> **Persistent Repository Copy**: Stored in `.gemini/plans/phase_4_implementation_plan.md` to guarantee persistence across all sessions, conversations, and restarts.

Phase 4 focuses on **Daily UI Fluidity, Cross-Character Convenience & Real-Time Gathering Tools**, delivering high-impact quality-of-life enhancements directly to the player's day-to-day experience.

---

## 🎯 Phase 4 Deliverables (Problem & Solution Breakdown)

### 1. 🧭 Hybrid Pinned + Overflow Navigation Bar (`[ ⋯ More ▼ ]`)
* **The Problem:** As GSFHub expands, adding more tabs causes button crowding or text truncation on lower screen resolutions. Purely hiding tabs makes them unreachable for casual players who don't memorize chat slash commands.
* **The Solution:**
  - Players can pin their favorite 4–5 tabs to the primary bar.
  - Unpinned tabs live inside an intuitive **`[ ⋯ More ▼ ]`** dropdown button on the right edge.
  - Clicking `[ ⋯ More ▼ ]` opens a popup menu listing all unpinned tabs (e.g. *Recipe Drops*, *Roster & Settings*), making **every single tab 100% accessible via mouse**.
  - When an overflow tab is active (via mouse or slash command like `/gsf drops`), the button turns gold and displays the active tab label (`[ ⋯ 🎁 Drops ▼ ]`), providing 100% visual clarity.
  - Includes a simple checkbox list in Settings to customize which tabs are pinned.

### 2. ⏰ Cross-Character Account Cooldown Alarms (`Cooldowns.lua`)
* **The Problem:** In World of Warcraft, addons cannot see what an offline alt is doing. When a player crafts *Primal Mooncloth* or a *Primal Might Transmute* on a Tailoring/Alchemy Alt, they forget when the multi-day cooldown expires and must constantly log out to check.
* **The Solution:**
  - When an Alt crafts a cooldown item, GSFHub records the exact expiration timestamp in the account-wide `GSFHubDB`.
  - When the player is playing on their Main character in a dungeon or raid, GSFHub calculates the remaining time and sets a background timer.
  - The exact moment the cooldown expires, GSFHub rings a gentle chime and displays an on-screen toast popup:
    `⏰ Alt Cooldown Ready: [AltName]'s Primal Mooncloth is now available to craft!`

### 3. 📡 Active Gatherer Radar (`GathererRadar.lua`)
* **The Problem:** Crafters needing materials in real-time don't know if a guild gatherer is already out in the field farming.
* **The Solution:**
  - Gatherers can toggle an active farming broadcast (*"Farming Nagrand: Ores & Primals"*).
  - Displays a real-time **Gathering Radar** board showing who is currently out in the world farming.
  - Crafters can 1-click whisper or send priority bounties directly to the active farmer.

### 4. 🔎 Universal Guild Material Search
* **The Problem:** Searching across multiple tabs (Surplus, Crafters, Work Orders) to see if anyone has a specific material or can craft a bar is tedious.
* **The Solution:**
  - A single search bar that simultaneously queries all surplus listings, active trade offers, and crafter capabilities with unified results.

### 5. 🌐 100% German & English Localization
* Complete translations across `Locales/enUS.lua` and `Locales/deDE.lua` with 100% key parity and fallback safety.

---

## 🛠️ File Architecture Plan

```
GSFHub/
├── Core/
│   ├── Constants.lua           -- Version 1.4.0, opcodes for Gatherer Radar (RADAR_START, RADAR_STOP)
│   ├── Database.lua            -- Account cooldowns & pinned navigation tabs settings
│   └── Core.lua                -- Initialize Cooldown alarms, Radar & slash commands
├── Modules/
│   ├── Professions/
│   │   └── Cooldowns.lua        -- Account cooldown alarm watcher & timer engine
│   └── Gathering/
│       └── GathererRadar.lua    -- Field farming session broadcaster & live radar
├── UI/
│   ├── Tabs/
│   │   ├── TabAtlas.lua         -- Integrated with Gatherer Radar & Universal Search
│   │   └── TabRoster.lua        -- Added tab pinning customizer in Settings
│   └── MainFrame.lua            -- Hybrid Pinned + [ ⋯ More ▼ ] overflow navigation bar
└── Locales/
    ├── enUS.lua                 -- English dictionary for Phase 3
    └── deDE.lua                 -- German dictionary for Phase 3
```
