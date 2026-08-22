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

## 📋 Governance, Planning & Execution Policies (CRITICAL)

### 1. 📁 Implementation Plan Persistence Policy
- **Standardized Naming Format:** Every phase's implementation plan must be stored inside **`.gemini/plans/`** using the unified naming convention:
  `phase_<N>_implementation_plan.md` (e.g. `phase_0_implementation_plan.md`, `phase_1_implementation_plan.md`, `phase_2_implementation_plan.md`, `phase_3_implementation_plan.md`).
- **Real-Time Synchronization:** Whenever an implementation plan is created, discussed, expanded, or modified during planning, the corresponding file in `.gemini/plans/` MUST be updated immediately in real time to reflect all new decisions, features, and refinements.
- **No Lost Context:** This ensures that all requirements, problem-solution breakdowns, and planned feature sets survive resets, new chat sessions, and context truncation.

### 2. 🚦 Explicit Implementation Authorization Policy
- **Strict No-Assumption Rule:** Do NOT start writing or modifying functional source code based on perceived approval or assumptions.
- **Explicit Instruction Required:** The agent must ALWAYS wait until the user gives an explicit, unambiguous command to begin implementation (e.g., *"You may start implementing"*, *"Proceed with implementation"*).

### 3. 🔒 Explicit Git Commit & Push Authorization Policy
- **Staging Allowed:** Staging changed files (`git add`) during development and verification is permitted.
- **Commit & Push Strictly Restricted:** NEVER execute `git commit`, `git tag`, or `git push` unless the user explicitly reviews the changes and gives explicit permission to commit and push.

### 4. ❓ Ambiguity & Option-Based Clarification Policy
- **Proactive Clarification:** Whenever there is room for interpretation, multiple valid UX/technical approaches, or uncertainty in design requirements, the agent must NEVER make unilateral assumptions.
- **Option Presentation:** The agent must proactively stop, clearly present the available options with trade-offs and a recommended path, and let the user make the final decision.

### 5. 🗺️ Roadmap & Documentation Synchronization Policy
- **Real-Time Roadmap Sync:** Whenever phase plans are created, restructured, completed, or updated, both **`ROADMAP.md`** and **`README.md`** MUST be updated in real time to reflect the latest release state, mermaid diagram, and upcoming milestones.
- **Documentation Integrity:** Ensures public repository documentation always mirrors the internal `.gemini/plans/` architecture.

### 6. 🛡️ Non-Destructive Data Migration & Backward Compatibility Policy
- When modifying `Database.lua` or core modules, NEVER delete or break existing SavedVariables keys (`myWishlist`, `characterProfessions`, `alts`, `myGoals`, `myWorkOrders`).
- Upgrading to a new release must always preserve existing player data with zero corruption.

### 7. 🧪 Automated 3-Step Pre-Flight Verification Policy
- Before presenting any phase as completed, the agent must run the automated verification suite:
  1. **Syntax & Bracket Integrity:** Validate all `.lua` files for 0 bracket/parenthesis mismatches.
  2. **Localization Parity:** Check 100% key match between `enUS.lua` and `deDE.lua`.
  3. **TOC Manifest Check:** Verify all files exist on disk and are registered in `GSFHub.toc` in correct dependency order.

### 8. 🌐 Strict Dual-Language Parity Policy
- Never introduce a UI string, label, button, toast, or alert in `Locales/enUS.lua` without simultaneously adding its authentic German translation in `Locales/deDE.lua`.
- Guarantees German client players always experience a 100% localized interface with zero untranslated English placeholders.

### 9. 🗜️ Zero-Lag P2P Network Bandwidth Throttling Policy
- Every network packet (Radar broadcasts, Cooldown updates, Guild Vault hashes) must strictly use `LibDeflate` compression and differential syncing (only broadcasting when data actually changes).
- Never broadcast uncompressed tables or flood guild chat channels.

### 10. 📑 Live Walkthrough & CHANGELOG Maintenance Policy
- Whenever a phase or patch is completed and prepared for release, both **`walkthrough.md`** and **`CHANGELOG.md`** MUST be updated immediately with structured `[Added]`, `[Changed]`, `[Fixed]`, and `[Compatibility]` sections.
- Guarantees that CurseForge, Wago, and GitHub Releases always have clean, professional, user-facing release notes ready for players.

### 11. 📝 Conventional Commits Standard Policy
- **Mandatory Format:** All Git commit messages MUST follow the **Conventional Commits v1.0.0** specification: `<type>(<optional-scope>): <short description in present tense>`.
- **Standard Types:**
  - `feat`: New user-facing feature (correlates with SemVer MINOR).
  - `fix`: Bug fix or patch (correlates with SemVer PATCH).
  - `docs`: Documentation, README, guides, licenses, phase plans.
  - `ci`: GitHub Actions workflows, deployment scripts, CI/CD configuration.
  - `refactor`: Code reorganization without changing functional behavior.
  - `perf`: Performance or memory optimizations.
  - `test`: Automated verification scripts or unit tests.
  - `chore`: Tooling or non-functional maintenance.
- **Auto-Closing Integration:** Always append closing keywords (e.g. `(closes #<id>)` or `(fixes #<id>)`) when resolving an open GitHub Issue.
