# Phase 2 Plan: Gathering Suite & Guild Supply Chain (v1.2.0)

> **Persistent Repository Archive**: Stored in `.gemini/plans/phase_2_plan.md` for historical auditing and feature verification.

## 🎯 Phase 2 Goals & Deliverables
1. **1–375 Resource Farming Atlas (`Modules/Gathering/AtlasData.lua`):**
   - Full Vanilla (1–300) and TBC (300–375) data across Mining, Herbalism, Skinning, Elements/Primals, Cloth, and Fishing.
   - Multilingual item name resolution via native game engine `itemID`s.
2. **Crafter ➔ Gatherer Supply Chain Bounties (`Modules/SupplyChain/SupplyBounties.lua`):**
   - 1-click recipe breakdown into material requests.
   - In-Transit postal lifecycle (`📬 IN_TRANSIT`) with elapsed duration timer.
   - **3-Factor Verification Handshake:** Validates sender identity, unique `[GSF-BT:XYZ]` token, and item quantities upon mailbox opening and bag receipt.
3. **Draggable Personal Goals HUD (`UI/Widgets/GoalsHUD.lua`):**
   - Movable onscreen overlay with visual progress bars and live `BAG_UPDATE` loot counters.
4. **Guild Specialization Roles (`Core/Roles.lua`):**
   - Auto-assigned badges (`[⛏️ Miner]`, `[🌿 Herbalist]`, `[🔪 Skinner]`, `[🛠️ Crafter]`, `[✨ Master Crafter]`, `[🎣 Angler]`) rendered in Roster and tooltips.
5. **Interactive 6-Tab Interface (`UI/Tabs/TabAtlas.lua` & `UI/MainFrame.lua`):**
   - Added Tab 5: Resource Atlas & Guild Bounties with category and skill filters.
6. **100% German & English Localization:**
   - 117 keys across `enUS.lua` and `deDE.lua` (100% parity).

## 🔧 v1.2.1 & v1.2.2 Maintenance & Polish (Released)
- **v1.2.1:** Resolved modern container API queries, layout collisions, and full German key parity.
- **v1.2.2:** Added dedicated Settings view (`TabSettings.lua`), header cog button `[⚙]`, 2-way Goals HUD state synchronization, decoupled audio alerts, localized German mining vein names, German recipe drop detection, wishlist input validation, and work order editing/completion confirmation.

## 🛠️ Test Phase 2 Polish & Feature Enhancement Plan
- **Global Header & Windows**: Clean title with dynamic view subtitle (`GSFHub — <Tab>`), version moved to Settings, and `UISpecialFrames` registration so `ESC` closes the window.
- **Input Mechanics**: Universal Shift-click item paste hook (`ChatEdit_InsertLink`), drag-and-drop `ItemSlot`, 250ms debounced text resolution.
- **Tooltips**: Universal native `GameTooltip` on all item icon buttons.
- **Tab 1 (Professions)**: Fix crafter scrollbar bounding and wire `searchLabel` to live language updates.
- **Tab 2 (Work Orders)**: Widen action buttons (`Bearbeiten` / `Abbrechen` to 95px) and add ItemSlot to creation modal.
- **Tab 3 (Surplus)**: Add bag item selection highlight, filter non-tradable/soulbound items, add item preview slot.
- **Tab 4 (Drops & Wishlist)**: Fix `WISHLIST_EMPTY_PROMPT`, left scrollbar overlap, shorten add button to `+ Hinzufügen`, add ItemSlot.
- **Tab 5 (Atlas & Bounties)**: Add 8px top margin, active view button states, 20px gutter, German zone/yield/tip translations, Option B modal for bounty requests, quantity prompts for HUD pin, bounty permissions (requester cancel, claimer unclaim), remove `[]` glyphs and dummy buttons, add dismiss button and hide-completed filter checkbox.
- **Goals HUD**: Mark bounty tasks with `[Auftrag]`, enlarge `[x]` button to 16x16, and require confirmation dialog before unclaiming.
- **Tab 6 (Roster)**: Spacing re-alignment, local player online status, strip `[]` glyph, validate main char input, sync on `/gsf main`, disable sync when unguilded, align table columns to 690px.
- **Settings View**: Fix "GitHub Issues" `URLDialog:ShowDialog` Lua error, fix "Nach Updates suchen" false alarm, adjust language dropdown spacing.
