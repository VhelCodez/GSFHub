# Multi-Guild & Solo Character Scope Isolation (v1.2.5)

> **Persistent Repository Copy**: Stored in `.gemini/plans/phase_2_5_scope_isolation_plan.md` per project governance rules.

## 🎯 Summary & Goal
Eliminate cross-character and cross-guild data contamination. Guild characters must strictly interact with and view their specific guild's data (`Guild - <GuildName> - <RealmName>`), while unguilded characters operate in an isolated personal space (`Solo - <PlayerName> - <RealmName>`). Non-guild characters and non-guild work orders must never appear in a guild roster or order board, and must never be broadcast over P2P network channels.

---

## 🔍 Root Cause Analysis
1. `GSFHubCache` was stored as a single flat table in `SavedVariables` (`WTF/Account/<ACCOUNT>/SavedVariables/GSFHub.lua`), which is account-wide across all characters.
2. `GSFHubCache.members`, `GSFHubCache.workOrders`, `GSFHubCache.bounties`, and `GSFHubCache.alts` accumulated records from any character played on the account.
3. `GUILD_ROSTER_UPDATE` only inserted or updated members, never pruning characters who are not part of the active guild.
4. `GSFHubDB.myWorkOrders` and `GSFHubDB.mySurplus` were stored at the global account level, and `Comm/Sync.lua:SendMyData()` blindly transmitted all of `GSFHubDB.myWorkOrders` to whatever guild the player was currently logged into.
5. `GSFHubDB.characterProfessions` was stored globally at the account root, so logging into an alt caused profession filters to match other characters' trade skills.

---

## 🛡️ Architecture & Implementation Breakdown

### 1. Scope Key Generation (`GSF.DB:GetActiveScopeKey`)
- **Guild Scope:** `"Guild - <GuildName> - <RealmName>"` (when `IsInGuild()` is true and guild name is available).
- **Solo Scope:** `"Solo - <PlayerName> - <RealmName>"` (when `IsInGuild()` is false or unguilded).

### 2. Scoped Cache Container (`GSFHubCache.scopes`)
- `GSFHubCache.scopes[scopeKey]` contains:
  - `scopeKey`: string
  - `guildName`: string
  - `realmName`: string
  - `isGuild`: boolean
  - `members`: table of member records
  - `workOrders`: table of work orders
  - `bounties`: table of bounties
  - `recentDrops`: table of drops
  - `alts`: table of alt mappings
  - `revisions`: table of revision numbers
- `GSF.cache` is dynamically bound to `GSFHubCache.scopes[scopeKey]`. Downstream modules continue reading `GSF.cache.*` transparently.

### 3. Non-Destructive Legacy Migration (`GSF.DB:MigrateLegacyCache`)
- If legacy flat keys exist in `GSFHubCache` without `scopes`:
  - Identify whether legacy data belonged to a guild or solo session.
  - Partition unguilded characters and their requested orders into their own `Solo - <PlayerName> - <RealmName>` scope.
  - Populate `GSFHubCache.scopes`.
  - Maintain legacy flat keys as clean mirrors for backward compatibility.

### 4. Active Guild Pruning (`GSF.DB:PruneNonGuildMembers`)
- Upon `GUILD_ROSTER_UPDATE` with `GetNumGuildMembers() > 0`:
  - Collect exact roster set from `GetGuildRosterInfo(i)`.
  - Prune any member from `GSF.cache.members` who is not in the guild roster.
  - Prune any order from `GSF.cache.workOrders` whose `requester` is not in the guild roster.
  - Prune any bounty from `GSF.cache.bounties` whose `requester` is not in the guild roster.
  - Prune invalid alt mappings from `GSF.cache.alts`.

### 5. P2P Network Firewall (`Comm/Sync.lua`)
- `SendMyData()` only gathers orders from `GSF.cache.workOrders` where `order.requester == myName`.
- `SendMyData()` only gathers surplus from `GSF.cache.members[myName].surplus`.
- Strict network guard: No packet transmission if `not IsInGuild()` or `not GSF.isGuildScope`.

### 6. Per-Character Profession Scoping
- Scanned professions are stored per-character (`GSF.cache.members[myName].professions` and `GSF.DB:GetMyProfessions()`).
- `WorkOrders.lua` filters strictly against current character's professions.
