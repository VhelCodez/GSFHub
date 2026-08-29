# Phase 7 Implementation Plan: Guild Intelligence, Economy & Social Suite (v1.7.0)

> **Persistent Repository Copy**: Stored in `.gemini/plans/phase_7_implementation_plan.md` to guarantee persistence across all sessions, conversations, and restarts.

Phase 7 focuses on **Macro Guild Analytics, Recipe Gap Analysis & Social Honor Recognition**, providing guild leaders and members with rich insights into self-sufficiency and celebrating community contributors.

---

## 🎯 Phase 7 Deliverables (Problem & Solution Breakdown)

### 1. 📊 Macro Economy Analytics & Intelligent Advisory (`EconomyStats.lua`)
* **The Problem:** Guild leaders lack a high-level view of guild self-sufficiency, and new members don't know which profession would help the guild most.
* **The Solution:**
  - Macro metrics: Crafter vs. Gatherer ratios, profession counts, and specialization distributions.
  - **Intelligent Advisory Engine ("Guild Needs"):** Analyzes under-represented professions and missing specializations to recommend optimal professions for leveling characters and alts (*"⭐ High Demand: Spellfire Tailor, Potion Master, Skinner"*).

### 2. 📦 Streamlined Stockpile & Shortage Watcher (`StockpileWatcher.lua`)
* **The Problem:** Heavy raid checklists are clunky and over-engineered.
* **The Solution:**
  - Fast, zero-clutter watchlist tracking pinned materials:
    `[ Item ] • [ Target ] • [ In Vault ] • [ In Surplus ] • [ Deficit / Status ] • [ 1-Click Request ]`
  - Instantly reveals guild shortages at a glance with 1-click bounty requests.

### 3. 📜 Guild Recipe Knowledge Matrix & Gap Analysis (`KnowledgeMatrix.lua`)
* **The Problem:** Officers don't know which crucial raid/dungeon recipes the guild is completely missing, leading to uncoordinated farming.
* **The Solution:**
  - Tracks premier endgame patterns, formulas, and plans (*Mongoose, Spellstrike, Belt of the Black Eagle, Greater Fire Protection*).
  - Shows 🟢 **Covered** (with crafter names) vs. 🔴 **Guild Gap** (with drop location, mob name, and drop rate).

### 4. 📈 Guild Activity Ledger & Honor Roll Leaderboard (`ActivityLedger.lua`)
* **The Problem:** Guild leaders want a live audit trail of economic activity, and dedicated crafters and gatherers deserve recognition.
* **The Solution:**
  - **Live Activity Feed:** Decentralized timeline in the overview (*“Theron crafted Lionheart Helm for Elara (15m ago)”*).
  - **Honor Roll Leaderboard:** Weekly and monthly recognition for top crafters, top gatherers, and top surplus donors.

### 5. 🌐 100% German & English Localization
* Complete translations across `Locales/enUS.lua` and `Locales/deDE.lua` with 100% key parity and fallback safety.
