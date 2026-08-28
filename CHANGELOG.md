# 📋 Changelog

All notable changes to **GSFHub (Guild Self-Found Hub)** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned (Phase 3 - v1.3.0)
- **Hybrid Pinned + Overflow Navigation (`[ ⋯ More ▼ ]`):** Customizable tab bar with overflow dropdown and active label display.
- **Cross-Character Account Cooldown Alarms (`Cooldowns.lua`):** Onscreen toast & audio chime on your main when an alt's trade skill CD is ready.
- **Active Gatherer Radar (`GathererRadar.lua`):** Field farming session broadcaster and live radar board.
- **Universal Guild Material Search:** 1-box search across all surplus, trade offers, and crafter capabilities.

---

## [1.2.3] - 2026-08-29

### Added
- **Escape Key Window Close (`UISpecialFrames`):** Registered `"GSFHubMainFrame"` in `UISpecialFrames` so pressing `ESC` smoothly closes the window.
- **Dynamic Header Subtitles:** Header dynamically displays `GSFHub — <Tab Name>` (`Berufe`, `Arbeitsaufträge`, `Material-Überschuss`, `Beute & Wunschliste`, `Ressourcen-Atlas & Aufträge`, `Gilde & Synchronisation`, `Einstellungen`), updating instantly on tab switch and language change. Relocated static version display into Settings.
- **Universal Shift-Click Bag Item Paste:** Hooked `ChatEdit_InsertLink` so Shift-clicking items in bags directly inserts clean item names into any active GSF input box without opening bag stack-split dialogs.
- **Reusable Drag-and-Drop `ItemSlot` Preview:** Added Blizzard-style item icon slot supporting item drops directly from bags, native `GameTooltip`, and 250ms debounced live icon resolution.
- **Surplus Bag Selection Visual Highlight:** Added gold border highlight and active background styling to selected bag item rows in the surplus offer modal.
- **Universal Item Tooltips:** Added native `GameTooltip` support across all item icon buttons on surplus cards, work order cards, and modals.
- **Atlas Farming Localization:** Localized zone names (*Wald von Elwynn, Dun Morogh, Tirisfal, etc.*), harvest yields, and farming tips into authentic German for `deDE` clients.
- **Configurable Pin Quantity:** Added a quantity prompt dialog when clicking *"An HUD anheften"* in the Atlas (defaulting to 20).
- **Dedicated Material Request Modal (Option B):** Clicking *"Material anfordern"* opens a creation modal with item slot preview, custom quantity input (default 20), and optional notes edit box.
- **Goals HUD Bounty Distinction & Safety Prompt:** Prefixes bounty goals with `[Auftrag]`, enlarged remove `[x]` button to 16x16 pixels, and added a confirmation dialog before unclaiming an accepted bounty.
- **Bounty Lifecycle & Permission Management:**
  - Requesters can cancel (`[Abbrechen]`) their own open bounties.
  - Claimers can unclaim (`[Aufgeben]`), prepare mail (`[Mail]`), or complete (`[Abschließen]`) bounties.
  - Added `[x] Abgeschlossene ausblenden` (Hide completed) filter checkbox (checked by default).
  - Requesters can permanently purge completed bounties using the `[Entfernen]` (Dismiss) button.
- **Main Character Validation & Live Sync:** Validates minimum 2 characters on main character saves with localized notices, and dynamically refreshes the Roster input when `/gsf main <Name>` is executed.

### Fixed
- **Settings "GitHub Issues" Lua Error:** Fixed method call to `GSF.URLDialog:ShowDialog` and aliased `URLDialog.Open` for defensive API compatibility.
- **Settings Update Check False Alarm:** Updated update check logic to only open the update dialog if `latestKnownVersion > GSF.VERSION`, otherwise displaying an up-to-date confirmation toast.
- **Missing Font Glyphs (`[][]` Box Characters):** Stripped unsupported unicode bullets (`●`) and symbols (`📬`, `✅`) across roster rows, atlas bounties, and status indicators, replacing them with native Blizzard status textures.
- **UI Collisions & Padding:**
  - Fixed vertical spacing in Tab 6 (Roster), eliminating overlap between the `[Vollständiger Sync]` button and table header bar.
  - Added 8px top margin between search controls and lists in Tab 5 (Atlas), and a 26px gutter between left list and right details pane.
  - Narrowed Tab 4 (Drops & Wishlist) left scroll frame to 330px to clear right input controls.
  - Shortened wishlist button text to `"+ Hinzufügen"` / `"+ Add"` (90px).
  - Adjusted Settings language dropdown vertical anchor from `Y = +2` to `Y = -8` below label.
- **Non-Tradable Surplus Filtering:** Filtered out Soulbound items (`info.isBound`, `bindType == 1`) and quest items (`classID == 12`) from the surplus candidates scan.
- **Online Status for Local Player:** Local player in Roster tab is now guaranteed to display `Online` rather than a stale offline timestamp.
- **Unguilded Sync Button State:** Disabled the sync button with tooltip notice when not in a guild.
- **Missing Localization Key:** Defined and bound `WISHLIST_EMPTY_PROMPT` in both English and German dictionaries.

---

## [1.2.2] - 2026-08-28

### Added
- **Dedicated Settings View (`TabSettings.lua`):** Separated general configuration, goals HUD tracker settings, audio alerts, and diagnostics into a card-based settings view.
- **Top-Right Header Cog Button (`[⚙]`):** Added a global settings button in the title bar next to the close button, keeping the bottom navigation cleanly at 6 tabs.
- **Goals HUD Two-Way State Synchronization:** Direct boolean state binding with live frame show/hide events that keeps the settings checkbox in sync in real time.
- **Goals HUD Position Reset & Empty Prompt:** Added a one-click button to center the HUD and a friendly placeholder prompt when no goals are pinned.
- **Minimap Icon Visibility Setting:** Checkbox to show or hide the LibDBIcon minimap launcher button.
- **Auto-Scan on Trade Skill Open Setting:** Exposed the previously orphaned `autoScanOnOpen` toggle in the settings UI.
- **Work Order "Bearbeiten" (Edit) & Complete Confirmation:** Added an edit action for own open orders and a confirmation dialog before completing an order.
- **Mining Node Localized Names:** Localized node mapping (*Kupfervorkommen*, *Zinnvorkommen*, *Silbervorkommen*, *Eisenvorkommen*, etc.) so Atlas displays vein names rather than replacing them with ore item names.
- **German Recipe Drop Detection:** Added `classID == 9` and German recipe prefixes (*Muster:*, *Pläne:*, *Rezept:*, *Formel:*, *Vorlage:*, *Bauplan:*) to guarantee recipe drop detection on German clients.
- **Wishlist Input Validation:** Added input validation and tooltip hints to prevent random strings like `"d"` or `"Lorem Ipsum"`.
- **Streamlined Roster Tab (`TabRoster.lua`):** Raised table header to `Y = -68` and expanded scroll height to `340px` for significantly improved roster visibility.
- **Instant Language Updates:** Switching language now translates 100% of visible UI elements across all tabs live without requiring `/reload`.
- **Settings Slash Commands:** Added `/gsf settings`, `/gsf config`, and `/gsf opt`.

### Fixed
- **Decoupled Sound Alerts:** Audio alerts now play independently of visual toast frame rendering.
- **Automated Release Workflow:** Made GitHub Actions release creation idempotent, handling tag re-runs and release updates without conflicts.

---

## [1.2.1] - 2026-08-28

### Fixed
- **Lua Error in Container Queries (`TradeHelper.lua`, `SurplusExchange.lua`, `GoalsHUD.lua`):** Fixed modern Classic container API evaluation trap that caused `attempt to call a nil value` when querying empty bag slots.
- **Lua Error in Bounties (`SupplyBounties.lua`):** Implemented missing `GSF.Alts:GetMyMain()` and corrected communication module reference to `GSF.Sync`.
- **Addon Title Restored:** Preserved canonical `"GSFHub"` title across all localizations instead of localized literal translation.
- **Missing Font Glyphs (`[][]` Box Characters):** Stripped unsupported raw UTF-8 emojis from buttons, toast notifications, headers, and badge labels.
- **Bottom Tab Label Truncation:** Shortened tab titles (*Berufe, Aufträge, Überschuss, Beute & Wunsch, Atlas, Gilde & Sync*) and added `PanelTemplates_TabResize` for responsive button sizing.
- **Mining Node Icons & IDs (`AtlasData.lua`):** Corrected Copper Vein (`2770` Copper Ore), Tin Vein (`2771` Tin Ore), and Silver Vein (`2775` Silver Ore) item associations.
- **Work Order State Reset & Lifecycle (`TabWorkOrders.lua`):** Properly resets profession selection to `"Any"` on modal creation, adds cancel action for own open orders, and enables crafter release/unclaim.
- **Wishlist Duplicate Spam (`RecipeDrops.lua`):** Added duplicate item verification and localized user chat notifications.
- **Settings Layout & Sync Overflow (`TabRoster.lua`):** Arranged settings checkboxes into a 2x2 grid to prevent overlapping table headers, shortened sync button text to `"Vollständiger Sync"`, and added a clear alert when unguilded.
- **Dynamic Guild Detection (`Core.lua`):** Registered `PLAYER_GUILD_UPDATE` event and cached realm names unconditionally for unguilded players.

---

## [1.2.0] - 2026-08-22

### Added
- **1–375 Resource Farming Atlas (`AtlasData.lua`):** Complete encyclopedia of all Vanilla (1–300) and TBC (300–375) resources across Mining, Herbalism, Skinning, Elements/Primals, Cloth, and Fishing.
- **Dynamic Multilingual Item Resolution:** Automatically resolves native localized item names via game engine `itemID`s on English, German, French, and Spanish clients.
- **Crafter ➔ Gatherer Supply Chain Bounties (`SupplyBounties.lua`):** 1-click recipe breakdown turning missing crafting reagents into targeted bounties for guild gatherers.
- **In-Transit Postal Tracking:** Full postal lifecycle (`OPEN`, `CLAIMED`, `IN_TRANSIT`, `COMPLETED`) with real-time transit duration timer.
- **🛡️ 3-Factor Verification Handshake:** Automatic mail receipt detection verifying sender, token (`[GSF-BT:XYZ]`), and item quantities upon mailbox opening and bag loot.
- **🎯 Draggable Personal Goals HUD (`GoalsHUD.lua`):** Movable onscreen overlay with visual progress bars and live `BAG_UPDATE` loot counters.
- **🏷️ Guild Specialization Roles (`Core/Roles.lua`):** Auto-assigned badges (`[⛏️ Miner]`, `[🌿 Herbalist]`, `[🔪 Skinner]`, `[🛠️ Crafter]`, `[✨ Master Crafter]`, `[🎣 Angler]`) rendered in Roster and tooltips.
- **🔍 6-Tab Interface Expansion:** Added Tab 5: Resource Atlas & Guild Bounties with category and skill filters.
- **100% German & English Localization:** 117 keys across `enUS.lua` and `deDE.lua` (100% key parity).

---

## [1.1.1] - 2026-08-22

### Changed
- **Blizzard Client Compatibility:** Bumped interface TOC to `20506` for full compatibility with modern WoW Classic 2.5.6.
- **Automated CI/CD:** Resolved GitHub Actions runner deprecation warnings with Node 24 support.

---

## [1.1.0] - 2026-08-22

### Added
- **Dynamic Multi-Language Engine (`Locales/Localization.lua`):** Automatic client language detection via `GetLocale()` (defaults to German on `deDE` clients, English `enUS` otherwise).
- **In-Game Language Switcher:** Dropdown in Settings tab (*Auto / English / Deutsch*) with real-time UI refresh.
- **Authentic German Dictionary (`Locales/deDE.lua`):** Complete translations for all tabs, professions, work orders, surplus stockpile, drops, toasts, and slash commands.
- **Metatable Fallback Proxy:** Guarantees zero blank labels by seamlessly falling back to English for unlocalized keys.
- **P2P Version Gossip & Update Reminders (`Core/VersionCheck.lua`):** In-game alert when guild members run a newer version with a 1-click selectable copy modal (`UI/Widgets/URLDialog.lua`).
- **In-Game Diagnostic & Bug Report Tool (`UI/Widgets/FeedbackDialog.lua`):** `/gsf bug` command generating pre-formatted GitHub issue diagnostics.
- **Daily Blizzard Build Tracker:** Automated GitHub Actions workflow monitoring live Blizzard builds on `wago.tools`.

---

## [1.0.0] - 2026-08-22

### Added
- **Decentralized Profession Directory:** Auto-scans 10 trade skills (Alchemy, BS, Enchanting, Engi, LW, Tailoring, JC, Cooking, First Aid, Lockpicking).
- **Persistent Offline Recipe Index:** Search recipes and crafters across all guild members even when they are offline.
- **Work Orders & Crafting Requests Board:** Post crafting/enchanting requests with material toggles (`Mats Provided` vs `No Mats`) and crafter claiming.
- **Surplus Material Exchange:** Share extra materials, ores, herbs, and cloth directly from bags without a guild bank alt.
- **Recipe Drop Coordinator & Wishlist:** Detects recipe drops in party/raid, cross-references unlearned crafters and personal wishlists.
- **Fast-Track Trade & Mail Helpers:** Auto-stages crafting mats into Trade and Mail frames.
- **Main / Alt Identity Management:** Group characters under a primary main account.
- **Decentralized P2P Networking Mesh:** Peer-to-peer sync with `LibDeflate` compression over the hidden `GUILD` channel.
- **Presentation Layer:** 5-tab parchment/slate main frame with draggable Minimap icon and toast popup alerts.

[Unreleased]: https://github.com/VhelCodez/GSFHub/compare/v1.2.3...HEAD
[1.2.3]: https://github.com/VhelCodez/GSFHub/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/VhelCodez/GSFHub/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/VhelCodez/GSFHub/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/VhelCodez/GSFHub/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/VhelCodez/GSFHub/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/VhelCodez/GSFHub/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/VhelCodez/GSFHub/releases/tag/v1.0.0
