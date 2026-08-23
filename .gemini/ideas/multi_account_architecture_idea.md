# 💡 Multi-Account & Multi-Client Architecture Idea

> **Category**: Future Architecture & Account Handling  
> **Status**: Incubating / Backlog Idea  
> **Target**: Post-Phase 3 exploration

---

## 🎯 The Scenario & Problem Statement
* **The Scenario:** Many dedicated WoW Classic players play with **multiple accounts** (e.g. `WoW1` and `WoW2` on the same Battle.net, or separate secondary accounts for crafting/banking).
* **The Technical Challenge:**
  - World of Warcraft stores `SavedVariables` per account folder:
    - `WTF/Account/<ACCOUNT_1>/SavedVariables/GSFHub.lua`
    - `WTF/Account/<ACCOUNT_2>/SavedVariables/GSFHub.lua`
  - How do we ensure cross-account alts, shared cooldown tracking, wishlist synchronization, and settings operate seamlessly across multiple accounts?

---

## 💡 Architectural Analysis & Solutions

### 1. 🌐 Natural P2P Resilience (Already Solved by Design)
* Because GSFHub is **100% Peer-to-Peer over the in-game GUILD channel**:
  - `GSFHubCache` does not rely on a shared local hard drive file.
  - When Account 2 logs into the guild, it exchanges P2P packets (`HELLO`, `REQ_DATA`, `RESP_DATA`) with the guild (and Account 1).
  - All recipe databases, active work orders, bounties, and surplus listings are **automatically synchronized across both accounts** via the in-game network!

### 2. 🔗 Cross-Account Main / Alt Linking
* **How It Works:**
  - On Account 2 (`TailorAlt`), the player sets their Main Character to `WarriorMain` (which lives on Account 1).
  - GSFHub broadcasts `ALT_UPDATE` over the guild mesh.
  - The entire guild (including Account 1) now sees `TailorAlt` grouped under `WarriorMain`.

### 3. ⏰ Cross-Account Cooldown Tracking via P2P Broadcast
* **How It Works:**
  - When Account 2 crafts *Primal Mooncloth*, GSFHub broadcasts `COOLDOWN_UPDATE` over the guild channel.
  - Account 1 (and all guild members) captures the timestamp in `GSFHubCache.guildCooldowns["TailorAlt"]`.
  - When Account 1 is logged in, the Cooldown Watcher checks both local `GSFHubDB.accountCooldowns` AND `GSFHubCache.guildCooldowns` for any alts marked as yours!
  - **Result:** You still get the on-screen alert on Account 1 even if the alt was played on Account 2!

### 4. 💾 Optional: Cross-Account Import / Export String (Settings & Wishlist Sync)
* **How It Works:**
  - A 1-click **"Copy Account Sync String"** in the Settings tab.
  - Generates a lightweight Base64 string of your personal wishlist and preferences to paste into Account 2.

---

## 📋 Evaluation & Next Steps
- This architecture fits naturally into our **P2P Gossip Network** without requiring any filesystem hacks or symlinks.
- To be refined during **Phase 4 (Specializations & Shared Cooldowns)** when shared cooldown broadcasting is implemented.
