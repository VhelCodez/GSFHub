local ADDON_NAME, GSF = ...

GSF.COMM_PREFIX = "GSFHUB"
GSF.VERSION = "1.2.5"
GSF.PROTOCOL_VERSION = 2

-- Download & Issue Tracker URLs (CurseForge ready)
GSF.DOWNLOAD_URL = "https://github.com/VhelCodez/GSFHub/releases"
GSF.ISSUES_URL = "https://github.com/VhelCodez/GSFHub/issues/new/choose"

-- Network Protocol Opcodes
GSF.OPCODE = {
	HELLO           = "HLO",  -- Broadcast heartbeat, version, and revision digest
	REQ_DATA        = "RQD",  -- Request data diff or full member profile
	RESP_DATA       = "RSD",  -- Respond with requested profile
	WORK_ORDER_NEW  = "WON",  -- Create a new work order
	WORK_ORDER_CLAIM= "WOC",  -- Claim a work order
	WORK_ORDER_STAT = "WOS",  -- Update work order status (complete/cancel)
	SURPLUS_NEW     = "SPN",  -- List new surplus item
	SURPLUS_REM     = "SPR",  -- Remove surplus item
	SURPLUS_CLAIM   = "SPC",  -- Claim surplus item
	ALT_UPDATE      = "ALT",  -- Broadcast main/alt link
	WISHLIST_UPDATE = "WLU",  -- Broadcast wishlist changes
	BOUNTY_NEW      = "BTN",  -- Post a new gathering bounty
	BOUNTY_CLAIM    = "BTC",  -- Gatherer claims a bounty
	BOUNTY_MAILED   = "BTM",  -- Gatherer mailed mats (in transit)
	BOUNTY_FULFILL  = "BTF",  -- Requester confirmed delivery (completed)
	BOUNTY_CANCEL   = "BTX",  -- Bounty cancelled
}

-- Work Order & Bounty Statuses
GSF.ORDER_STATUS = {
	OPEN        = "OPEN",
	CLAIMED     = "CLAIMED",
	IN_TRANSIT  = "IN_TRANSIT",
	COMPLETED   = "COMPLETED",
	CANCELLED   = "CANCELLED",
}

-- Guild Specialization Roles
GSF.ROLES = {
	MINER          = { name = "Miner", icon = "Interface\\Icons\\Trade_Mining", color = "ff9966" },
	HERBALIST      = { name = "Herbalist", icon = "Interface\\Icons\\Trade_Herbalism", color = "66ff66" },
	SKINNER        = { name = "Skinner", icon = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01", color = "cc9966" },
	CRAFTER        = { name = "Crafter", icon = "Interface\\Icons\\Trade_BlackSmithing", color = "66ccff" },
	MASTER_CRAFTER = { name = "Master Crafter", icon = "Interface\\Icons\\INV_Misc_Key_04", color = "ffd100" },
	ANGLER         = { name = "Angler/Cook", icon = "Interface\\Icons\\Trade_Fishing", color = "33cccc" },
}

-- Professions Table with metadata & textures
GSF.PROFESSIONS = {
	["Alchemy"] = {
		name = "Alchemy",
		icon = "Interface\\Icons\\Trade_Alchemy",
		maxSkill = 375,
		isSecondary = false,
	},
	["Blacksmithing"] = {
		name = "Blacksmithing",
		icon = "Interface\\Icons\\Trade_BlackSmithing",
		maxSkill = 375,
		isSecondary = false,
	},
	["Enchanting"] = {
		name = "Enchanting",
		icon = "Interface\\Icons\\Trade_Engraving",
		maxSkill = 375,
		isSecondary = false,
	},
	["Engineering"] = {
		name = "Engineering",
		icon = "Interface\\Icons\\Trade_Engineering",
		maxSkill = 375,
		isSecondary = false,
	},
	["Leatherworking"] = {
		name = "Leatherworking",
		icon = "Interface\\Icons\\Trade_LeatherWorking",
		maxSkill = 375,
		isSecondary = false,
	},
	["Tailoring"] = {
		name = "Tailoring",
		icon = "Interface\\Icons\\Trade_Tailoring",
		maxSkill = 375,
		isSecondary = false,
	},
	["Jewelcrafting"] = {
		name = "Jewelcrafting",
		icon = "Interface\\Icons\\INV_Misc_Gem_02",
		maxSkill = 375,
		isSecondary = false,
	},
	["Mining"] = {
		name = "Mining",
		icon = "Interface\\Icons\\Trade_Mining",
		maxSkill = 375,
		isSecondary = false,
	},
	["Herbalism"] = {
		name = "Herbalism",
		icon = "Interface\\Icons\\Trade_Herbalism",
		maxSkill = 375,
		isSecondary = false,
	},
	["Skinning"] = {
		name = "Skinning",
		icon = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01",
		maxSkill = 375,
		isSecondary = false,
	},
	["Cooking"] = {
		name = "Cooking",
		icon = "Interface\\Icons\\INV_Misc_Food_15",
		maxSkill = 375,
		isSecondary = true,
	},
	["First Aid"] = {
		name = "First Aid",
		icon = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
		maxSkill = 375,
		isSecondary = true,
	},
	["Fishing"] = {
		name = "Fishing",
		icon = "Interface\\Icons\\Trade_Fishing",
		maxSkill = 375,
		isSecondary = true,
	},
	["Lockpicking"] = {
		name = "Lockpicking",
		icon = "Interface\\Icons\\Spell_Nature_MoonKey",
		maxSkill = 350,
		isSecondary = true,
		classOnly = "ROGUE",
	},
}

-- UI Colors
GSF.COLORS = {
	PRIMARY     = "33ff99", -- Soft emerald green
	GOLD        = "ffd100", -- Blizzard gold
	ALERT       = "ff7f00", -- Orange alert
	SUCCESS     = "00ff00", -- Bright green
	MUTED       = "888888", -- Gray
	LINK        = "00c0ff", -- Soft cyan
	ONLINE      = "00ff00",
	OFFLINE     = "777777",
	IN_TRANSIT  = "00ccff", -- Cyan in-transit mail color
}

-- Expiration limits
GSF.WORK_ORDER_TIMEOUT = 7 * 24 * 60 * 60 -- 7 days in seconds
GSF.BOUNTY_TIMEOUT = 7 * 24 * 60 * 60 -- 7 days in seconds
GSF.CACHE_RETENTION_DAYS = 30

-- Profession Normalization & Localization Helpers
local CANONICAL_PROFS = {
	["alchemy"] = "Alchemy",
	["alchemie"] = "Alchemy",
	["blacksmithing"] = "Blacksmithing",
	["schmiedekunst"] = "Blacksmithing",
	["enchanting"] = "Enchanting",
	["verzauberkunst"] = "Enchanting",
	["engineering"] = "Engineering",
	["ingenieurskunst"] = "Engineering",
	["leatherworking"] = "Leatherworking",
	["lederverarbeitung"] = "Leatherworking",
	["tailoring"] = "Tailoring",
	["schneiderei"] = "Tailoring",
	["jewelcrafting"] = "Jewelcrafting",
	["juwelenschleifen"] = "Jewelcrafting",
	["mining"] = "Mining",
	["bergbau"] = "Mining",
	["herbalism"] = "Herbalism",
	["kräuterkunde"] = "Herbalism",
	["krauterkunde"] = "Herbalism",
	["skinning"] = "Skinning",
	["kürschnerei"] = "Skinning",
	["kurschnerei"] = "Skinning",
	["cooking"] = "Cooking",
	["kochkunst"] = "Cooking",
	["first aid"] = "First Aid",
	["erste hilfe"] = "First Aid",
	["fishing"] = "Fishing",
	["angeln"] = "Fishing",
	["lockpicking"] = "Lockpicking",
	["schlösserknacken"] = "Lockpicking",
	["schlosserknacken"] = "Lockpicking",
}

function GSF:GetCanonicalProfession(name)
	if not name then return nil end
	local lower = (type(name) == "string" and name:lower() or ""):gsub("^%s*(.-)%s*$", "%1")
	return CANONICAL_PROFS[lower] or name
end

function GSF:GetLocalizedProfession(name)
	local canon = self:GetCanonicalProfession(name) or name
	local key = "PROF_" .. canon:upper():gsub("%s+", "_")
	return (GSF.L and GSF.L[key]) or canon
end

