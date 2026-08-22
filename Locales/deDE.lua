local ADDON_NAME, GSF = ...

local L = GSF.Locales.deDE

-- General & Header
L["ADDON_NAME"] = "GSFHub"
L["ADDON_TITLE"] = "Gilden-Selbstversorger-Hub"
L["TAGLINE"] = "Koordinator für Gilden-Selbstversorger, Berufe & Ressourcen"
L["LOADED_MESSAGE"] = "Erfolgreich geladen! Tippe |cff33ff99/gsf|r oder klicke auf das Minikarten-Symbol, um das Fenster zu öffnen."

-- Tabs
L["TAB_PROFESSIONS"] = "Berufe"
L["TAB_WORK_ORDERS"] = "Arbeitsaufträge"
L["TAB_SURPLUS"] = "Überschusslager"
L["TAB_DROPS"] = "Beute & Wunschliste"
L["TAB_ATLAS"] = "Ressourcen-Atlas"
L["TAB_ROSTER"] = "Gilde & Synchronisation"

-- Professions Tab
L["SEARCH_RECIPES"] = "Rezepte, Gegenstände oder Reagenzien suchen..."
L["FILTER_ALL_PROFESSIONS"] = "Alle Berufe"
L["FILTER_ONLINE_ONLY"] = "Nur Online-Handwerker"
L["CRAFTERS_KNOWN"] = "Bekannte Handwerker:"
L["REAGENTS_REQUIRED"] = "Benötigte Reagenzien:"
L["NO_RECIPES_FOUND"] = "Keine passenden Rezepte gefunden."
L["NO_CRAFTERS_FOUND"] = "Kein Gildenmitglied hat dieses Rezept bisher erlernt."
L["SCAN_SUCCESS"] = "%d Rezepte für %s gescannt (Fertigkeit: %d/%d)."
L["REQUEST_CRAFT"] = "Herstellung anfragen"
L["WISHLIST_BTN"] = "Wunschliste"
L["REQUEST_MATS_BTN"] = "Material anfordern"
L["SELECT_RECIPE_PROMPT"] = "Wähle ein Rezept aus, um Handwerker & Reagenzien anzuzeigen"
L["NO_EXTRA_REAGENTS"] = "Keine zusätzlichen Materialien erforderlich."

-- Work Orders Tab
L["CREATE_WORK_ORDER"] = "Neuer Arbeitsauftrag"
L["ACTIVE_ORDERS"] = "Aktive Arbeitsaufträge"
L["FILTER_MY_PROFESSIONS"] = "Nur meine Berufe"
L["ITEM_NAME"] = "Gegenstand oder Verzauberung"
L["QUANTITY"] = "Anzahl"
L["MATS_PROVIDED"] = "Material gestellt"
L["NO_MATS"] = "Kein Material"
L["NOTES"] = "Notizen / Trinkgeld"
L["SUBMIT_ORDER"] = "Auftrag aufgeben"
L["CLAIM_ORDER"] = "Annehmen"
L["COMPLETE_ORDER"] = "Abschließen"
L["CANCEL_ORDER"] = "Abbrechen"
L["STATUS_OPEN"] = "OFFEN"
L["STATUS_CLAIMED"] = "IN ARBEIT"
L["STATUS_IN_TRANSIT"] = "POST UNTERWEGS"
L["STATUS_COMPLETED"] = "ABGESCHLOSSEN"
L["STATUS_CANCELLED"] = "ABGEBROCHEN"
L["CONFIRM_RECEIVED"] = "Erhalt bestätigen"
L["ORDER_CLAIMED_BY"] = "Angenommen von: %s"
L["NO_ACTIVE_ORDERS"] = "Aktuell keine aktiven Arbeitsaufträge."
L["ORDER_POSTED_TOAST"] = "Neuer Auftrag: %s x%d angefragt von %s!"

-- Surplus Exchange Tab
L["SURPLUS_POOL"] = "Gilden-Material-Überschusslager"
L["POST_SURPLUS"] = "Überschuss anbieten"
L["SEARCH_SURPLUS"] = "Materialien suchen..."
L["CLAIM_SURPLUS"] = "Anfragen"
L["REMOVE_SURPLUS"] = "Entfernen"
L["NO_SURPLUS_LISTED"] = "Aktuell keine überschüssigen Materialien angeboten."
L["SURPLUS_OFFERED_BY"] = "Angeboten von: %s"
L["SURPLUS_POSTED_TOAST"] = "%s bietet Überschuss an: %s x%d"
L["OFFER_MODAL_TITLE"] = "Überschüssiges Material anbieten"
L["SELECT_BAG_ITEM"] = "Wähle einen Gegenstand aus deinen Taschen:"

-- Drops & Wishlist Tab
L["RECIPE_DROPS_TITLE"] = "Rezept-Beutekoordinator"
L["WISHLIST_TITLE"] = "Meine Rezept-Wunschliste"
L["ADD_TO_WISHLIST"] = "Link hinzufügen"
L["RECIPE_DROP_ALERT"] = "|cffff7f00[GSF Rezept-Beute]|r %s ist gefallen! %d Handwerker benötigen dies: %s"
L["WISHLISTED_BY"] = "Auf Wunschliste von: %s"
L["NO_RECENT_DROPS"] = "Kürzlich keine Rezeptfunde verzeichnet."
L["JUST_NOW"] = "Gerade eben"
L["MINS_AGO"] = "vor %d Min."

-- Resource Atlas & Bounties Tab
L["SEARCH_ATLAS"] = "Materialien, Vorkommen oder Zonen suchen..."
L["VIEW_ATLAS"] = "🗺️ Ressourcen-Atlas"
L["VIEW_BOUNTIES"] = "📦 Gilden-Aufträge"
L["SELECT_RESOURCE_PROMPT"] = "Wähle eine Ressource aus, um Farm-Details zu sehen"
L["BEST_FARMING_ZONES"] = "Beste Farm-Gebiete:"
L["RESOURCE_YIELDS"] = "Ertrag & Edelsteine:"
L["FARMING_TIPS"] = "Farm-Route & Hinweise:"
L["PIN_TO_HUD"] = "🎯 An HUD anheften"
L["POST_BOUNTY_BTN"] = "📜 Material anfordern"
L["CLAIM_BOUNTY"] = "Auftrag annehmen"
L["BOUNTY_POSTED_TOAST"] = "Neuer Materialauftrag: %s x%d von %s!"
L["BOUNTY_FULFILLED_TOAST"] = "🎉 Auftrag erfüllt: %s x%d erhalten!"
L["CAT_ALL"] = "Alle Kategorien"
L["CAT_MINING"] = "Bergbau"
L["CAT_HERBALISM"] = "Kräuterkunde"
L["CAT_SKINNING"] = "Kürschnerei"
L["CAT_ELEMENTAL"] = "Elementare"
L["CAT_CLOTH"] = "Stoff"
L["CAT_FISHING"] = "Angeln"

-- Goals HUD
L["ENABLE_GOALS_HUD"] = "Persönliches Ziele-HUD anzeigen"
L["GOALS_HUD_TITLE"] = "🎯 GSF Farm-Ziele"

-- Specialization Roles
L["ROLE_MINER"] = "Bergmann"
L["ROLE_HERBALIST"] = "Kräuterkundiger"
L["ROLE_SKINNER"] = "Kürschner"
L["ROLE_CRAFTER"] = "Handwerker"
L["ROLE_MASTER_CRAFTER"] = "Meisterhandwerker"
L["ROLE_ANGLER_COOK"] = "Angler/Koch"

-- Roster & Settings Tab
L["GUILD_SYNC_STATUS"] = "Gilden-Synchronisationsstatus"
L["MAIN_ALT_TITLE"] = "Hauptcharakter & Twinks (Alts)"
L["SET_MAIN_CHARACTER"] = "Mein Hauptcharakter:"
L["SAVE_MAIN"] = "Speichern"
L["FORCE_SYNC"] = "Jetzt vollständige Synchronisation anfordern"
L["TOTAL_MEMBERS_CACHED"] = "Gespeichert: %d Mitglieder  •  %d Rezepte"
L["ENABLE_TOASTS"] = "Toast-Benachrichtigungen aktivieren"
L["ENABLE_SOUNDS"] = "Audio-Hinweise aktivieren"
L["ANNOUNCE_DROPS_PARTY"] = "Rezeptfunde in Gruppe/Schlachtzug ansagen"
L["AUTO_SCAN_OPEN"] = "Beruf beim Öffnen automatisch scannen"
L["TABLE_CHARACTER"] = "Charakter"
L["TABLE_MAIN"] = "Hauptcharakter"
L["TABLE_PROFESSIONS"] = "Berufe"
L["TABLE_LAST_SEEN"] = "Zuletzt online"

-- Language Settings
L["LANGUAGE_LABEL"] = "Sprache / Language:"
L["LANG_AUTO"] = "Automatisch (Client-Sprache)"
L["LANG_EN"] = "English (enUS)"
L["LANG_DE"] = "Deutsch (deDE)"

-- Version Updates & P2P Gossip
L["UPDATE_AVAILABLE_CHAT"] = "Eine neuere Version (|cffffd100v%s|r) ist verfügbar! Bitte aktualisiere GSFHub, um die neuesten Funktionen zu nutzen."
L["UPDATE_BADGE"] = "Update: v%s"
L["UPDATE_MODAL_TITLE"] = "GSFHub-Update verfügbar"
L["UPDATE_MODAL_MSG"] = "Eine neuere Version von GSFHub (|cff33ff99v%s|r) ist verfügbar.\nDrücke Strg+C, um den Download-Link zu kopieren:"

-- Bug Report & Feedback
L["REPORT_BUG_BTN"] = "🐛 Fehler melden / 💡 Vorschlag"
L["FEEDBACK_MODAL_TITLE"] = "Fehler melden oder Vorschlag einreichen"
L["FEEDBACK_MODAL_MSG"] = "Kopiere den Diagnoseblock unten (Strg+C) und füge ihn in GitHub Issues ein:"
L["FEEDBACK_LINK_LABEL"] = "GitHub Issues Link:"
L["COPY_DONE"] = "In die Zwischenablage kopiert!"
L["CLOSE"] = "Schließen"
