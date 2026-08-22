# Phase 1 Plan: Multi-Language Architecture & Update Ecosystem (v1.1.0)

> **Persistent Repository Archive**: Stored in `.gemini/plans/phase_1_plan.md` for historical auditing and feature verification.

## 🎯 Phase 1 Goals & Deliverables
1. **Dynamic Multi-Language Engine (`Locales/Localization.lua`):**
   - Client language auto-detection via `GetLocale()`.
   - German on `deDE` clients, English `enUS` otherwise.
   - Metatable Fallback Proxy guaranteeing zero blank strings.
2. **Master Translation Dictionaries (`Locales/enUS.lua` & `Locales/deDE.lua`):**
   - 86 initial localization keys with 100% key parity.
3. **In-Game Language Switcher:**
   - Dropdown in Settings tab (*Auto / English / Deutsch*) with real-time UI refresh.
4. **P2P Version Gossip & Update Reminders (`Core/VersionCheck.lua`):**
   - Broadcasts addon version over P2P mesh.
   - Non-intrusive session alert and golden `[⚡ Update: vX.Y.Z]` badge.
   - 1-click selectable URL copy modal (`UI/Widgets/URLDialog.lua`).
5. **In-Game Diagnostic & Bug Report Tool (`UI/Widgets/FeedbackDialog.lua`):**
   - `/gsf bug` command generating pre-formatted GitHub issue diagnostics.
6. **Automated Blizzard Client Build Monitor:**
   - `.github/workflows/check-client-version.yml` and `.github/scripts/check_version.sh` daily checking `wago.tools` for TOC version bumps.
