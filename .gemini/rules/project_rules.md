# Antigravity Workspace Rules & Persistent Project Memory

## 🎮 Project Identity & Scope
- **Project Name:** GSFHub (Guild Self-Found Hub)
- **Target Platform:** World of Warcraft Classic TBC (`Interface: 20506`, modern 2.5.x / 1.15+ engine).
- **Core Purpose:** Decentralized guild self-found (GSF) & SSF guild coordination: professions, recipes, work orders, surplus exchange, recipe drops, and gathering supply chain.
- **Repository:** `https://github.com/VhelCodez/GSFHub`

---

## 🏛️ Architectural Guidelines
1. **Self-Contained Packaging:**
   - Never require external addon dependencies.
   - All core libraries (`LibStub`, `CallbackHandler-1.0`, `Ace3`, `LibDeflate`, `LibDataBroker-1.1`, `LibDBIcon-1.0`) must remain embedded in `Libs/`.
2. **Persistence Separation:**
   - `GSFHubDB`: Per-account user preferences, wishlist, local snapshot.
   - `GSFHubCache`: Guild-wide shared database (member recipes, work orders, surplus items, alts, revisions).
3. **Decentralized P2P Networking:**
   - Network prefix: `GSFHUB`.
   - All payload tables must be serialized via `AceSerializer-3.0`, compressed via `LibDeflate:CompressDeflate`, and encoded for safe addon channel transmission using `LibDeflate:EncodeForWoWAddonChannel`.
4. **UI Conventions:**
   - Use `GSF.UI:CreateBackdrop(frame, isParchment)` to ensure full compatibility with modern `BackdropTemplate` / `BackdropTemplateMixin`.
   - Maintain classic parchment and modern dark dialog aesthetics.

---

## 🌐 Localization Policy
- Master dictionary is in `Locales/enUS.lua`.
- Full German translations in `Locales/deDE.lua`.
- Dynamic fallback: Any missing translation key must automatically resolve to `enUS` or raw string key without causing Lua errors.

---

## 🚀 Release & Versioning Standards
- Semantic Versioning: `vMajor.Minor.Patch` (e.g. `v1.0.0`, `v1.1.0`, `v1.2.0`).
- Releases are automated via `.github/workflows/release.yml` using native GitHub CLI `gh release create`.
- All updates must maintain `ROADMAP.md` and `ARCHITECTURE.md` synchronization.
