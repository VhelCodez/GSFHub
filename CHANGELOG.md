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

[Unreleased]: https://github.com/VhelCodez/GSFHub/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/VhelCodez/GSFHub/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/VhelCodez/GSFHub/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/VhelCodez/GSFHub/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/VhelCodez/GSFHub/releases/tag/v1.0.0
