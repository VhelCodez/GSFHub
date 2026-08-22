local ADDON_NAME, GSF = ...

local L = {}
GSF.L = setmetatable(L, {
	__index = function(t, k)
		return k
	end
})

-- General
L["ADDON_NAME"] = "GSFHub"
L["ADDON_TITLE"] = "Guild Self-Found Hub"
L["TAGLINE"] = "Guild Self-Found Profession & Resource Coordinator"
L["LOADED_MESSAGE"] = "Loaded successfully! Type |cff33ff99/gsf|r or click the minimap icon to open."

-- Tabs
L["TAB_PROFESSIONS"] = "Professions"
L["TAB_WORK_ORDERS"] = "Work Orders"
L["TAB_SURPLUS"] = "Surplus Pool"
L["TAB_DROPS"] = "Drops & Wishlist"
L["TAB_ROSTER"] = "Roster & Sync"

-- Professions Tab
L["SEARCH_RECIPES"] = "Search recipes, items, or reagents..."
L["FILTER_ALL_PROFESSIONS"] = "All Professions"
L["FILTER_ONLINE_ONLY"] = "Online Crafters Only"
L["CRAFTERS_KNOWN"] = "Known Crafters:"
L["REAGENTS_REQUIRED"] = "Reagents Required:"
L["NO_RECIPES_FOUND"] = "No matching recipes found."
L["NO_CRAFTERS_FOUND"] = "No guild members have learned this recipe yet."
L["SCAN_SUCCESS"] = "Scanned %d recipes for %s (Skill: %d/%d)."
L["REQUEST_CRAFT"] = "Request Craft"

-- Work Orders Tab
L["CREATE_WORK_ORDER"] = "New Work Order"
L["ACTIVE_ORDERS"] = "Active Work Orders"
L["FILTER_MY_PROFESSIONS"] = "Only My Professions"
L["ITEM_NAME"] = "Item or Enchant Name"
L["QUANTITY"] = "Quantity"
L["MATS_PROVIDED"] = "Mats Provided"
L["NOTES"] = "Notes / Tip"
L["SUBMIT_ORDER"] = "Post Work Order"
L["CLAIM_ORDER"] = "Claim Order"
L["COMPLETE_ORDER"] = "Mark Complete"
L["CANCEL_ORDER"] = "Cancel Order"
L["STATUS_OPEN"] = "OPEN"
L["STATUS_CLAIMED"] = "CLAIMED"
L["STATUS_COMPLETED"] = "COMPLETED"
L["ORDER_CLAIMED_BY"] = "Claimed by: %s"
L["NO_ACTIVE_ORDERS"] = "No active work orders right now."
L["ORDER_POSTED_TOAST"] = "New Work Order: %s x%d requested by %s!"

-- Surplus Exchange Tab
L["SURPLUS_POOL"] = "Guild Surplus Material Pool"
L["POST_SURPLUS"] = "Offer Surplus Item"
L["SEARCH_SURPLUS"] = "Search materials..."
L["CLAIM_SURPLUS"] = "Request Item"
L["NO_SURPLUS_LISTED"] = "No surplus materials currently offered."
L["SURPLUS_OFFERED_BY"] = "Offered by: %s"
L["SURPLUS_POSTED_TOAST"] = "%s offered surplus: %s x%d"

-- Drops & Wishlist Tab
L["RECIPE_DROPS_TITLE"] = "Recipe Drop Coordinator"
L["WISHLIST_TITLE"] = "My Recipe Wishlist"
L["ADD_TO_WISHLIST"] = "Add Recipe to Wishlist"
L["RECIPE_DROP_ALERT"] = "|cffff7f00[GSF Recipe Drop]|r %s dropped! %d crafters need this: %s"
L["WISHLISTED_BY"] = "Wishlisted by: %s"
L["NO_RECENT_DROPS"] = "No recipe drops recorded recently."

-- Roster & Settings Tab
L["GUILD_SYNC_STATUS"] = "Guild Synchronization Status"
L["MAIN_ALT_TITLE"] = "Main & Alt Identity"
L["SET_MAIN_CHARACTER"] = "My Main Character:"
L["SAVE_MAIN"] = "Save Main"
L["FORCE_SYNC"] = "Force Full Sync Now"
L["TOTAL_MEMBERS_CACHED"] = "Cached Guild Members: %d"
L["TOTAL_RECIPES_CACHED"] = "Total Indexed Recipes: %d"
L["ENABLE_TOASTS"] = "Enable Toast Popups"
L["ENABLE_SOUNDS"] = "Enable Audio Alerts"
L["ANNOUNCE_DROPS_PARTY"] = "Announce Recipe Drops to Party/Raid"
