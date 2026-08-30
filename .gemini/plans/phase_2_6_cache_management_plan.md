# Phase 2.6 Implementation Plan: Settings Cache & Data Management Suite (v1.2.7)

> **Persistent Repository Copy**: Stored in `.gemini/plans/phase_2_6_cache_management_plan.md` per project governance rules.

## 🎯 Summary & Purpose
Provide players and guild officers with intuitive, safe, and powerful cache management tools directly in the Settings view (`TabSettings.lua`). Enable users to resolve stale or desynchronized peer data, reset active character state (wishlists & goals), or execute a safe factory reset that prevents "ghost orders" across the decentralized peer-to-peer network.

---

## 🔍 The Problem
1. In a decentralized P2P addon without a central server, corrupted or stale peer data (e.g. from an alt or old test session) can linger in `GSFHubCache`.
2. Users had no UI mechanism to purge cache data without manually finding and deleting `WTF/Account/<ACCOUNT>/SavedVariables/GSFHub.lua` from Windows Explorer.
3. Blindly deleting SavedVariables causes "ghost" work orders and bounties: other guild members retain the orders because the author never sent cancellation (`CANCELLED`) opcodes over the network.
4. Users could not reset an active character's wishlist or Goals HUD independently without wiping the entire account.

---

## 🛡️ Architecture & Implementation Breakdown

### 1. 🔄 Non-Destructive Guild Cache Rebuilder (`GSF.DB:RebuildGuildCache()`)
- **Safe Selective Purge:** Clears peer member records, foreign work orders, foreign bounties, and recent drop logs.
- **Author Protection:** Preserves the player's own active work orders, bounties, surplus items, professions, and wishlists.
- **Immediate Re-Sync:** Automatically requests a fresh sync broadcast (`REQ_DATA`) from all online guild peers over the `GUILD` channel, repopulating the guild database with a pristine snapshot in seconds.

### 2. 🧹 Active Character Reset (`GSF.DB:ResetActiveCharacterData()`)
- Targets *only* the active character (`wishlistByChar[charKey] = {}` and `goalsByChar[charKey] = {}`).
- Preserves all other characters, guild cache, and global preferences.
- Confirmed via native `StaticPopupDialogs` modal.

### 3. ⚠️ Safe Factory Reset (`GSF.DB:FactoryReset()`)
- **Ghost Order Prevention:** Scans all open work orders and bounties created by the player and broadcasts cancellation (`WOS` / `BTX`) opcodes to the guild first.
- Wipes `GSFHubDB` and `GSFHubCache` back to a clean installation state.
- Automatically calls `ReloadUI()`.
- Protected by a confirmation modal.

### 4. 🎛️ Settings View Harmonization (`UI/Tabs/TabSettings.lua`)
- **Card 1 (Top Left):** `General & Display` (Language dropdown, Show Minimap Icon, Show Personal Goals HUD, Reset HUD Position).
- **Card 2 (Top Right):** `Notifications & Audio` (Toasts, Sounds, Party Drop Announcements, Auto-Scan).
- **Card 3 (Bottom Left):** `Data & Cache Management` (`[🔄 Rebuild Guild Cache]`, `[🧹 Clear Character Data]`, `[⚠️ Full Addon Reset]`).
- **Card 4 (Bottom Right):** `About & Diagnostics` (Version display, Update check, Bug report dialog, GitHub Issues).

### 5. 🌐 100% Dual-Language Parity
- All button labels, confirmation dialogs, and system chat messages localized across `Locales/enUS.lua` and `Locales/deDE.lua`.
