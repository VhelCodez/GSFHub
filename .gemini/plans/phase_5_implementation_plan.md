# Phase 5 Implementation Plan: Crafting Specializations & Shared Cooldowns (v1.5.0)

> **Persistent Repository Copy**: Stored in `.gemini/plans/phase_5_implementation_plan.md` to guarantee persistence across all sessions, conversations, and restarts.

Phase 5 focuses on **Deep Profession Mastery, Shared Cooldown Tracking & Specialization Roadmaps**, coordinating high-end crafting specializations and cooldowns across the entire guild.

---

## 🎯 Phase 5 Deliverables (Problem & Solution Breakdown)

### 1. 🏷️ Profession Sub-Specializations (`Specializations.lua`)
* **The Problem:** Crafting specializations (*Shadoweave vs. Spellfire*, *Transmutation vs. Potion Master*, *Armorsmith vs. Swordsmith*) are crucial for progression, but members don't know who has which specialization.
* **The Solution:**
  - Auto-detects learned specializations from character spellbook and trade skills.
  - Displays distinct colored badges in the Roster, Professions tab, and tooltips:
    `[🧵 Tailoring: Shadoweave]`, `[🧪 Alchemy: Transmute Master]`, `[🔨 Blacksmithing: Master Swordsmith]`.

### 2. 🗺️ Specialization Planning & In-Game Quest Roadmap
* **The Problem:** Leveling crafters don't know where to start specialization quests or what materials to save up.
* **The Solution:**
  - Leveling players can pre-select an intended future specialization, displaying a `(Planned: ...)` tag in the guild roster so the guild avoids duplicate over-saturation.
  - Selecting any specialization opens an in-game guide with required character level, skill level, starting NPC coordinates, and turn-in material checklists (*4x Primal Might* for Transmutation Master).

### 3. ⏳ Shared Guild Cooldown Monitor
* **The Problem:** High-value materials (*Primal Mooncloth, Spellcloth, Shadowcloth, Primal Might transmutes, Salt Shakers*) have multi-day cooldowns. Guild members don't know which crafter has a cooldown ready right now.
* **The Solution:**
  - Live cooldown status displayed directly beside crafter names in `TabProfessions`:
    `|cff00ff00[Ready to Craft]|r` or `|cffff7f00[Cooldown: Ready in 1d 14h]|r`.
  - P2P sync broadcasts cooldown availability across the guild.

### 4. 🌐 100% German & English Localization
* Complete translations across `Locales/enUS.lua` and `Locales/deDE.lua` with 100% key parity and fallback safety.
