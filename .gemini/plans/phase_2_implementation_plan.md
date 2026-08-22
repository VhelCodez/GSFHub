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
