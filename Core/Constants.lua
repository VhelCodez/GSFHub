local ADDON_NAME, GSF = ...

GSF.COMM_PREFIX = "GSFHUB"
GSF.VERSION = "1.0.0"
GSF.PROTOCOL_VERSION = 1

-- Network Protocol Opcodes
GSF.OPCODE = {
	HELLO           = "HLO",  -- Broadcast heartbeat and revision digest
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
}

-- Work Order Statuses
GSF.ORDER_STATUS = {
	OPEN      = "OPEN",
	CLAIMED   = "CLAIMED",
	COMPLETED = "COMPLETED",
	CANCELLED = "CANCELLED",
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
}

-- Expiration limits
GSF.WORK_ORDER_TIMEOUT = 7 * 24 * 60 * 60 -- 7 days in seconds
GSF.CACHE_RETENTION_DAYS = 30
