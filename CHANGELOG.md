# 📋 Changelog

All notable changes to **GSFHub (Guild Self-Found Hub)** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned (Phase 4 - v1.4.0)
- **Navigation Overhaul:** Hybrid Pinned + Overflow `[ ⋯ More ▼ ]` tab architecture with responsive horizontal wrapping.
- **Cross-Character Account Cooldown Alarms:** Account-wide tracking and alarms for Alchemy transmutations, Tailoring cloth weaves, and Salt Shakers.
- **Active Gatherer Radar:** Real-time presence broadcasts when guild members are farming specific zones.
- **Universal Global Search:** Omni-search bar indexing recipes, materials, crafters, bounties, and surplus.

---

## [1.3.0] - 2026-08-30

### Added
- **Universal Resource Atlas (`AtlasEngine.lua`):** New dedicated atlas query engine and cache lifecycle manager supporting cross-discipline category matching, real-time localized search, and asynchronous item data cache priming on login.
- **Pure ItemID Relational Catalog (`AtlasData.lua`):** 132 meticulously verified, relational catalog entries decoupled from static world node strings and keyed purely by Blizzard `itemID`.
- **13 Polymorphic Acquisition Source Models:** Unified structured schema representing `GATHER`, `PROSPECT`, `DISENCHANT`, `EXTRACT`, `TRANSMUTE`, `SMELT`, `COMBINE`, `MOB_DROP`, `FISH`, `BYPRODUCT`, `INSTANCE`, and `VENDOR` sources.
- **Zero-String Engine Localization:** Client API-based name, icon, spell, and zone resolution via `GetItemInfo()`, `GetSpellInfo()`, `GetItemSubClassInfo()`, and `C_Map.GetAreaInfo()` with quality color coding and interactive hyperlinks.
- **Curated Strategic Farming Tips:** 90+ localized farming routes, deposit behaviors, and high-efficiency gathering notes across Classic Azeroth and Outland in English and German (`Locales/enUS.lua` and `Locales/deDE.lua`).
- **Expanded Resource Categories:** Integrated dedicated tabs/filters for `Mining`, `Herbalism`, `Skinning`, `Cloth`, `Elemental / Primals`, `Enchanting`, `Engineering`, `Cooking & Meats`, and `Fishing`.

### Changed
- **Atlas UI Overhaul (`TabAtlas.lua`):** Re-engineered the Resource Atlas right details pane into a scrollable card container rendering multi-source acquisition breakdowns, clickable yields and byproduct tooltips, dynamic item tooltips on hover, and full quality-colored titles.
- **Goals HUD ItemID Precision (`GoalsHUD.lua`):** Updated bag tracking logic (`CountItemInBags`) to strictly query exact `GetItemCount(itemID)` when `itemID` is present, eliminating ambiguous fuzzy text false positives.

---

## [1.2.7] - 2026-08-30

### Added
- **Settings Data & Cache Management Suite (`TabSettings.lua`):** Added a dedicated Cache & Data Management panel with non-destructive cache repair and reset utilities.
- **Selective Guild Cache Rebuilder (`GSF.DB:RebuildGuildCache()`):** Purges stale peer records, foreign work orders, and foreign bounties while safely preserving the player's own active listings, followed by an immediate broadcast to download a fresh sync mesh from online guild members.
- **Active Character Data Reset (`GSF.DB:ResetActiveCharacterData()`):** Clears the active character's recipe wishlist and Goals HUD trackers with a confirmation prompt, without affecting account settings or other alts.
- **Safe Full Addon Reset (`GSF.DB:FactoryReset()`):** Ghost-order prevention engine that broadcasts cancellations for the player's open work orders and bounties to the guild before resetting local SavedVariables and reloading the UI.
- **Settings Layout Harmonization:** Unified General and Goals HUD into a balanced 195px Display card, creating symmetrical 2x2 grid alignment across all cards in the Settings view.

### Changed
- **Elimination of Legacy Technical Debt & Pure Character Scoping (`Core/Database.lua`):** Completely removed `MigrateLegacyCache()`, historical owner guessing, and flat-table fallback routines. Transitioned to pure character-scoped database architecture (`wishlistByChar`, `goalsByChar`, `characterProfessionsByChar`) with dynamic in-memory runtime binding (`GSF.db.myWishlist`, `GSF.db.myGoals`), eliminating cross-session SavedVariables root leakage and guaranteeing complete character isolation.

---

## [1.2.6] - 2026-08-30

### Fixed
- **Per-Character Recipe Wishlist Scoping (`wishlistByChar`):** Partitioned recipe wishlists by character key (`"<CharacterName> - <RealmName>"`). Pinned recipes on an engineering alt no longer bleed into newly created or other guild characters.
- **Smart Non-Destructive Wishlist Migration:** Automatically attributes legacy account-level wishlists to the character that originally created them (via work order requester history or designated main), granting new characters an immediate clean slate while preserving existing wishlists.
- **Per-Character Personal Goals Isolation (`goalsByChar`):** Partitioned `myGoals` by character so pinned Goals HUD trackers and bag counters remain isolated to each character's active inventory.
- **Peer Wishlist Loot Tracking (`RecipeDrops.lua` & `Sync.lua`):** Saved incoming member wishlists to guild cache records, enabling group recipe drop alerts to accurately flag any guild member who has the dropped recipe on their personal wishlist.

---

## [1.2.5] - 2026-08-30

### Added
- **Multi-Guild & Solo Scope Partitioning (`GSFHubCache.scopes`):** Partitioned cache storage by Scope Key (`Guild - <GuildName> - <RealmName>` and `Solo - <PlayerName> - <RealmName>`). Unguilded characters and characters in different guilds are completely isolated and never mixed together.
- **Active Guild Roster Pruning:** `GUILD_ROSTER_UPDATE` now verifies cached members against the official server roster, expunging non-guild characters, foreign work orders, bounties, and alt mappings from the guild database while preserving personal data in their respective solo scopes.
- **Per-Character Profession Scoping (`GSF.DB:GetMyProfessions()`):** Scanned trade skills are tracked per character rather than globally across the account, preventing foreign profession matches in Work Order filtering and toast alerts.

### Changed
- **P2P Gossip Network Firewall:** `GSF.Sync:SendMyData()` now strictly transmits orders and surplus created by the active character within the active guild scope, eliminating accidental broadcast of personal non-guild or cross-guild listings over addon channels.
- **Roster View Scope Polish:** Tab 6 (`TabRoster`) dynamically reflects active scope mode, showing solo status for unguilded characters and verified guild rosters for guilded members.
- **Non-Destructive Cache Migration:** Automatically migrates legacy flat cache databases into the partitioned `scopes` structure without data loss.

---

## [1.2.4] - 2026-08-29

### Added
- **Atlas Empty State Notifications:** Added centered empty state messages for View 1 Resources (`NO_RESOURCES_FOUND` / *"Keine passenden Ressourcen gefunden."*) and View 2 Bounties (`NO_BOUNTIES_FOUND` / *"Keine passenden Aufträge vorhanden."*), with automatic details pane reset on zero matches.
- **Dynamic Modal Localization:** Added `UpdateModalTexts()` across `TabWorkOrders` and `TabAtlas` so all modal dialog titles, field labels, checkboxes, and buttons refresh dynamically on language change without restarting or reopening the client.
- **Goals HUD Language Synchronization:** Hooked `GoalsHUD:Refresh()` directly into addon-wide language change events to keep HUD titles in sync with client localization.
- **Universal Input Enter/Escape Handling:** Pressing Enter or Escape now cleanly clears focus across all edit boxes throughout the addon.

### Changed
- **Professions Tab Action Bar Redesign:** Streamlined the right pane to the two primary crafting actions (`[Herstellung anfragen]` and `[Material anfordern]`), sizing both to a spacious `170px` with a `15px` central gap and `10px` side margins for zero border clipping.
- **Beute & Wunsch (Tab 4) Dual-Column Architecture:** Rebuilt layout into two symmetrical columns (Recipe Drops on the left, Personal Wishlist on the right) with a unified top search bar, `+ Zur Wunschliste` action, centered empty states, and a dedicated item slot preview modal.
- **Atlas View Navigation Buttons:** Right-aligned and standardized view toggle buttons (`[Ressourcen]`, `[Aufträge]`, `[Ziele]`) to uniform `90x24px` buttons with generous buffer margins.
- **Gilde & Sync (Tab 6) Layout Polish:** Streamlined top bar alignment, expanded the member scroll table to maximize visible roster entries, and relocated Main/Alt character linking cleanly into the bottom-left bar.
- **Goal HUD Note Icon Placement:** Dynamically measures title text width so the parchment note icon (`INV_Misc_Note_01`) tightly hugs the goal label (`Kupfererz 📜`) rather than floating at a fixed distance.
- **Goal HUD Header Button Parity:** Cropped Blizzard's transparent padding on `UI-Panel-MinimizeButton-Up` via texture coordinates (`SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)`) and standardized both Close and Settings Gear buttons to an identical `14x14px` frame size with perfectly level alignment.
- **FrameStrata Layering Hierarchy:** Configured `MainFrame` to `"HIGH"` strata with `SetToplevel(true)` and `GoalsHUD` to `"MEDIUM"` strata, preventing z-fighting and ensuring the main window cleanly layers over desktop HUD widgets.
- **Goal HUD Progress Theming:** Updated progress bar color to GSF signature teal/mint (`0.2, 0.9, 0.6`) during progress, transitioning to success green (`0.0, 1.0, 0.3`) at 100%.

### Fixed
- **Subpixel Checkbox Label Calibration:** Standardized checkbox label anchors across `Berufe`, `Aufträge`, and `Atlas` (`ClearAllPoints()` and pixel-matched offset) to produce an identical 12-pixel gap between the checkbox border and the first letter across all tabs.
- **Work Orders Layout Overlaps:** Converted category filter from a heavyweight Blizzard menu to a lightweight Frame dropdown, eliminating button collisions and dropdown clipping.
- **Surplus Tab Top Bar Alignment:** Aligned search box to standard `y = -12` and `15px` left margin matching all other tabs.
- **Item Preview Clearing on Empty Input:** Updated `AttachItemPreview` to immediately clear the preview icon slot and reset item metadata whenever the input becomes empty (supporting keyboard backspacing, right-click clears, and clear button `×` clicks).
- **Atlas View 3 (Goals) Empty State Misalignment:** Re-anchored empty notice to `goalScroll` so it sits dead-centered in the scroll area rather than clinging to the top edge.
- **Localization Parity:** Reached 100% dictionary match across 231 keys between `Locales/enUS.lua` and `Locales/deDE.lua`.

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

[Unreleased]: https://github.com/VhelCodez/GSFHub/compare/v1.2.5...HEAD
[1.2.5]: https://github.com/VhelCodez/GSFHub/compare/v1.2.4...v1.2.5
[1.2.4]: https://github.com/VhelCodez/GSFHub/compare/v1.2.3...v1.2.4
[1.2.3]: https://github.com/VhelCodez/GSFHub/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/VhelCodez/GSFHub/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/VhelCodez/GSFHub/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/VhelCodez/GSFHub/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/VhelCodez/GSFHub/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/VhelCodez/GSFHub/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/VhelCodez/GSFHub/releases/tag/v1.0.0
