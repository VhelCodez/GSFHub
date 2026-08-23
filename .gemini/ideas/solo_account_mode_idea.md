# 💡 Idea: Solo / Non-Guild Account Mode ("Virtual Account Hub")

**Status:** Incubating / Backlog  
**Date:** 2026-08-23  

---

## 🎯 Summary & Goal
Allow **GSFHub** to be used completely for solo non-self-found or solo self-found gameplay without requiring an active World of Warcraft guild. It enables tracking professions, recipes, stockpiled reagents, wishlists, and crafting to-do tasks strictly across characters on the player's own account.

---

## 🔍 Technical Foundation
- **Local `SavedVariables` Persistence:** In World of Warcraft, `SavedVariables` (`GSFHubDB` and `GSFHubCache`) are account-wide per realm.
- Data scanned by Alt A (recipes, known patterns, bag surplus) is already stored locally on disk and is immediately accessible by Alt B upon login without requiring addon comms or P2P network sync.

---

## 💡 Proposed Features & Capabilities

### 1. Virtual Account Placeholder / Namespace
- When unguilded (or when toggling an **"Account Scope"** view filter), GSFHub assigns a virtual guild/namespace (e.g. `[Account - RealmName]` or `[Personal Hub]`).
- All account characters are automatically grouped into this virtual entity.

### 2. Cross-Alt Recipe Directory
- Look up any recipe, enchant, gem, or craft to see which of your own alts can make it and what reagents are required.

### 3. Personal Stockpile & Surplus Material Tracker
- Browse items, ores, herbs, cloth, gems, and consumables sitting across your bank alts or crafting alts.

### 4. Cross-Alt Recipe Drop Alerts
- When a recipe/pattern/schematic drops during solo farming, 5-man dungeons, or PUG raids, GSFHub alerts you if any of your other alts need to learn it.

### 5. Self Work Orders / Crafting To-Do List
- Post work orders or crafting reminders for your own alts (e.g., *"Craft 20x Super Mana Potion on Alchemist for Mage"*).

---

## 🛡️ Critical Architecture: Dynamic Mode Switching & Multi-Guild Isolation

### 1. The Challenge: Cross-Guild Twinks & Multi-Guild Accounts
A single player account often has characters in different situations:
* **Character A (Main):** In *Guild Alpha* (Progression Guild).
* **Character B (Twink/Alt):** In *Guild Beta* (Casual/Twink/PVP Guild).
* **Character C (Bank Alt):** Unguilded.

### 2. Risks to Prevent (Zero Data Pollution / Leakage)
1. **Accidental P2P Network Leaks:** Logging into Character B (*Guild Beta*) must **never** broadcast Character A's *Guild Alpha* database, crafters, or orders into *Guild Beta*'s addon comms channel (`GUILD`).
2. **Cache Pollution / Merging:** Guild Alpha's recipes and work orders must never appear in Guild Beta's guild directory.
3. **Identity Pollution:** Main/Alt associations for Guild Alpha should not erroneously publish private alt information to Guild Beta unless explicitly configured.

### 3. Proposed Segregation Architecture

```
GSFHubCache (SavedVariables)
 ├── guilds
 │    ├── ["GuildAlpha-Realm"]  --> Isolated P2P Guild Sync (Only touched when logged into Guild Alpha)
 │    └── ["GuildBeta-Realm"]   --> Isolated P2P Guild Sync (Only touched when logged into Guild Beta)
 └── account
      └── ["PersonalHub-Realm"] --> Local-only aggregation of player's OWN characters (NEVER synced over P2P)
```

* **Strict Guild Namespaces:** All guild P2P data caches are strictly keyed by `GuildName-Realm`. Active sync handlers only read from and write to the currently logged-in character's guild namespace.
* **Firewalled P2P Sync Layer:** Outgoing guild broadcast packets only serialize the current character's personal contributions and the active guild's cache. Account-level data or other guilds' caches are strictly excluded from the serialization pipeline.
* **Isolated Account Scope (Read-Only Aggregator):** The "Account Mode / Personal Hub" pulls data from the local character records of the player's own alts across all guilds/unguilded characters for private display, but this aggregated view remains 100% local and is never transmitted over addon channels.

---

## 🧭 UI & Dynamic Mode Switching

* **Active Context Switcher in UI Header:**
  - `[🌐 Guild Alpha]` (When logged in on Main)
  - `[🌐 Guild Beta]` (When logged in on Twink)
  - `[👤 My Account (All Alts)]` (Available on all characters)
* **Automatic Safe Default:**
  - If a character is in a guild ➔ Default view opens to that character's specific Guild Scope.
  - If a character is unguilded ➔ Default view opens to Account Scope (graceful fallback).
* **Instant Switching:** Users can toggle between their active Guild Scope and Account Scope without reloading the UI (`/reload`), as data stores are cleanly separated in memory.
