local ADDON_NAME, GSF = ...

local L = GSF.Locales.enUS

-- General & Header
L["ADDON_NAME"] = "GSFHub"
L["ADDON_TITLE"] = "Guild Self-Found Hub"
L["TAGLINE"] = "Guild Self-Found Profession & Resource Coordinator"
L["LOADED_MESSAGE"] = "Loaded successfully! Type |cff33ff99/gsf|r or click the minimap icon to open."

-- Tabs
L["TAB_PROFESSIONS"] = "Professions"
L["TAB_WORK_ORDERS"] = "Work Orders"
L["TAB_SURPLUS"] = "Surplus Pool"
L["TAB_DROPS"] = "Drops & Wishlist"
L["TAB_ATLAS"] = "Resource Atlas"
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
L["WISHLIST_BTN"] = "Wishlist"
L["REQUEST_MATS_BTN"] = "Request Mats"
L["SELECT_RECIPE_PROMPT"] = "Select a recipe to view crafters & reagents"
L["NO_EXTRA_REAGENTS"] = "No extra materials required."

-- Work Orders Tab
L["CREATE_WORK_ORDER"] = "New Work Order"
L["ACTIVE_ORDERS"] = "Active Work Orders"
L["FILTER_MY_PROFESSIONS"] = "Only My Professions"
L["ITEM_NAME"] = "Item or Enchant Name"
L["QUANTITY"] = "Quantity"
L["MATS_PROVIDED"] = "Mats Provided"
L["NO_MATS"] = "No Mats"
L["NOTES"] = "Notes / Tip"
L["SUBMIT_ORDER"] = "Submit Order"
L["CLAIM_ORDER"] = "Claim"
L["COMPLETE_ORDER"] = "Complete"
L["CANCEL_ORDER"] = "Cancel"
L["STATUS_OPEN"] = "OPEN"
L["STATUS_CLAIMED"] = "CLAIMED"
L["STATUS_IN_TRANSIT"] = "IN TRANSIT"
L["STATUS_COMPLETED"] = "COMPLETED"
L["STATUS_CANCELLED"] = "CANCELLED"
L["CONFIRM_RECEIVED"] = "Confirm Received"
L["ORDER_CLAIMED_BY"] = "Claimed by: %s"
L["NO_ACTIVE_ORDERS"] = "No active work orders right now."
L["ORDER_POSTED_TOAST"] = "New Work Order: %s x%d requested by %s!"

-- Surplus Exchange Tab
L["SURPLUS_POOL"] = "Guild Surplus Material Pool"
L["POST_SURPLUS"] = "Offer Surplus Item"
L["SEARCH_SURPLUS"] = "Search materials..."
L["CLAIM_SURPLUS"] = "Request"
L["REMOVE_SURPLUS"] = "Remove"
L["NO_SURPLUS_LISTED"] = "No surplus materials currently offered."
L["SURPLUS_OFFERED_BY"] = "Offered by: %s"
L["SURPLUS_POSTED_TOAST"] = "%s offered surplus: %s x%d"
L["OFFER_MODAL_TITLE"] = "Offer Surplus Material"
L["SELECT_BAG_ITEM"] = "Select an item from your bags:"

-- Drops & Wishlist Tab
L["RECIPE_DROPS_TITLE"] = "Recipe Drop Coordinator"
L["WISHLIST_TITLE"] = "My Recipe Wishlist"
L["ADD_TO_WISHLIST"] = "Add Link"
L["RECIPE_DROP_ALERT"] = "|cffff7f00[GSF Recipe Drop]|r %s dropped! %d crafters need this: %s"
L["WISHLISTED_BY"] = "Wishlisted by: %s"
L["NO_RECENT_DROPS"] = "No recipe drops recorded recently."
L["JUST_NOW"] = "Just now"
L["MINS_AGO"] = "%dm ago"

-- Resource Atlas & Bounties Tab
L["SEARCH_ATLAS"] = "Search materials, nodes, or zones..."
L["VIEW_ATLAS"] = "🗺️ Resource Atlas"
L["VIEW_BOUNTIES"] = "📦 Guild Bounties"
L["SELECT_RESOURCE_PROMPT"] = "Select a resource to view farming data"
L["BEST_FARMING_ZONES"] = "Best Farming Locations:"
L["RESOURCE_YIELDS"] = "Harvest Yields & Gems:"
L["FARMING_TIPS"] = "Farming Route & Tips:"
L["PIN_TO_HUD"] = "🎯 Pin to HUD"
L["POST_BOUNTY_BTN"] = "📜 Request Bounty"
L["CLAIM_BOUNTY"] = "Claim Bounty"
L["BOUNTY_POSTED_TOAST"] = "New Bounty: %s x%d requested by %s!"
L["BOUNTY_FULFILLED_TOAST"] = "🎉 Bounty Fulfilled: Received %s x%d!"
L["CAT_ALL"] = "All Categories"
L["CAT_MINING"] = "Mining"
L["CAT_HERBALISM"] = "Herbalism"
L["CAT_SKINNING"] = "Skinning"
L["CAT_ELEMENTAL"] = "Elemental"
L["CAT_CLOTH"] = "Cloth"
L["CAT_FISHING"] = "Fishing"

-- Goals HUD
L["ENABLE_GOALS_HUD"] = "Show Personal Goals HUD"
L["GOALS_HUD_TITLE"] = "🎯 GSF Farming Goals"

-- Specialization Roles
L["ROLE_MINER"] = "Miner"
L["ROLE_HERBALIST"] = "Herbalist"
L["ROLE_SKINNER"] = "Skinner"
L["ROLE_CRAFTER"] = "Crafter"
L["ROLE_MASTER_CRAFTER"] = "Master Crafter"
L["ROLE_ANGLER_COOK"] = "Angler/Cook"

-- Roster & Settings Tab
L["GUILD_SYNC_STATUS"] = "Guild Synchronization Status"
L["MAIN_ALT_TITLE"] = "Main & Alt Identity"
L["SET_MAIN_CHARACTER"] = "My Main Character:"
L["SAVE_MAIN"] = "Save Main"
L["FORCE_SYNC"] = "Force Full Sync Now"
L["TOTAL_MEMBERS_CACHED"] = "Cached: %d Members  •  %d Recipes"
L["ENABLE_TOASTS"] = "Enable Toast Popups"
L["ENABLE_SOUNDS"] = "Enable Audio Alerts"
L["ANNOUNCE_DROPS_PARTY"] = "Announce Drops to Party/Raid"
L["AUTO_SCAN_OPEN"] = "Auto-Scan Profession on Open"
L["TABLE_CHARACTER"] = "Character"
L["TABLE_MAIN"] = "Main Account"
L["TABLE_PROFESSIONS"] = "Professions"
L["TABLE_LAST_SEEN"] = "Last Seen"

-- Language Settings
L["LANGUAGE_LABEL"] = "Language / Sprache:"
L["LANG_AUTO"] = "Auto (Client Locale)"
L["LANG_EN"] = "English (enUS)"
L["LANG_DE"] = "Deutsch (deDE)"

-- Version Updates & P2P Gossip
L["UPDATE_AVAILABLE_CHAT"] = "A newer version (|cffffd100v%s|r) is available! Please update GSFHub to get the latest features."
L["UPDATE_BADGE"] = "Update: v%s"
L["UPDATE_MODAL_TITLE"] = "GSFHub Update Available"
L["UPDATE_MODAL_MSG"] = "A newer version of GSFHub (|cff33ff99v%s|r) is available.\nPress Ctrl+C to copy the download link:"

-- Bug Report & Feedback
L["REPORT_BUG_BTN"] = "🐛 Report Bug / 💡 Suggestion"
L["FEEDBACK_MODAL_TITLE"] = "Report Bug or Suggestion"
L["FEEDBACK_MODAL_MSG"] = "Copy the diagnostic block below (Ctrl+C) and paste it into GitHub Issues:"
L["FEEDBACK_LINK_LABEL"] = "GitHub Issues Link:"
L["COPY_DONE"] = "Copied to clipboard!"
L["CLOSE"] = "Close"
