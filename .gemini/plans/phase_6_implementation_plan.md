# Phase 6 Implementation Plan: TBC Guild Bank & Vault Automation Suite (v1.6.0)

> **Persistent Repository Copy**: Stored in `.gemini/plans/phase_6_implementation_plan.md` to guarantee persistence across all sessions, conversations, and restarts.

Phase 6 focuses on **TBC Guild Bank Integration, Remote Vault Browsing & Restock Logistics**, bridging real-time player bags with long-term centralized guild storage.

---

## 🎯 Phase 6 Deliverables (Problem & Solution Breakdown)

### 1. 🏛️ Automated Guild Vault Scanner & Remote Mirror (`GuildBankScanner.lua`)
* **The Problem:** Players must travel to a major city bank in Shattrath or Ironforge to see what is inside the Guild Bank.
* **The Solution:**
  - Whenever any guild member opens the Guild Bank (`GUILDBANKFRAME_OPENED`), GSFHub silently snapshots all accessible tabs and items.
  - Uses **Revision Digest Hashing** to ensure compressed updates are only sent when items actually change (< 1 KB data, zero network lag).
  - Every guild member can browse the full Guild Bank remotely from anywhere in the world!

### 2. 🏷️ Smart Tab Tagging & Automatic Surplus Integration (`VaultSurplus.lua`)
* **The Problem:** Guild banks become messy dumping grounds, and items placed in the vault don't automatically appear in surplus searches.
* **The Solution:**
  - Officers assign Smart Roles to tabs (e.g. *Tab 1: Surplus Herbs*, *Tab 2: Surplus Ores*).
  - Items in tagged tabs are automatically listed in the Surplus Stockpile as `[🏛️ Guild Vault]`.
  - When players go on holiday, they simply deposit their extra materials into the vault, and the guild can see and request them anytime!

### 3. 📦 Direct-to-Vault Bounties & 1-Click Deposit Helper
* **The Problem:** Gathering materials for the general guild stockpile causes mail clutter when mailed to individual officers.
* **The Solution:**
  - Bounties can be targeted to **"Guild Bank (Tab X)"**.
  - When the gatherer visits any Guild Vault, GSFHub displays a **"1-Click Deposit Bounty Mats"** button that moves the farmed stacks directly into the designated bank tab and completes the bounty automatically.

### 4. 📉 Minimum Reserve Thresholds & Auto-Restock Alerts (`ReserveThresholds.lua`)
* **The Problem:** The guild unexpectedly runs out of critical reagents (*Primal Fire*, *Terocone*, *Adamantite Bars*) without anyone noticing until the bank is empty.
* **The Solution:**
  - Officers define minimum stock targets (e.g. *Always keep 40x Primal Fire in Vault*).
  - Displays low-stock alerts and provides a 1-click **"Post Restock Bounty"** button to replenish supplies.

### 5. 🔍 Remote Guild Bank Browser Tab (`TabGuildBank.lua`)
* Dedicated UI tab to search and browse all guild bank tabs with item counts, quality borders, and tooltip hovers.

### 6. 🌐 100% German & English Localization
* Complete translations across `Locales/enUS.lua` and `Locales/deDE.lua` with 100% key parity and fallback safety.
