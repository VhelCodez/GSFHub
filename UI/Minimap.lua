local ADDON_NAME, GSF = ...

local LDB = LibStub("LibDataBroker-1.1")
local DBIcon = LibStub("LibDBIcon-1.0")

GSF.Minimap = {}

function GSF.Minimap:Initialize()
	local dataObj = LDB:NewDataObject("GSFHub", {
		type = "launcher",
		text = "GSFHub",
		icon = "Interface\\Icons\\INV_Misc_Book_09",
		OnClick = function(self, button)
			if button == "RightButton" then
				if GSF.Scanner then
					GSF.Scanner:ScanCurrentWindow()
				end
			else
				if GSF.MainFrame then
					GSF.MainFrame:Toggle()
				end
			end
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine("|cff33ff99GSFHub|r " .. GSF.VERSION)
			tooltip:AddLine(GSF.L["TAGLINE"], 0.7, 0.7, 0.7)
			tooltip:AddLine(" ")

			local guild = GSF.cache.guildName ~= "" and GSF.cache.guildName or "No Guild"
			tooltip:AddDoubleLine("Guild:", "|cffffd100" .. guild .. "|r")

			local numMembers = 0
			if GSF.cache.members then
				for _ in pairs(GSF.cache.members) do numMembers = numMembers + 1 end
			end
			tooltip:AddDoubleLine("Cached Members:", tostring(numMembers))

			local openOrders = 0
			if GSF.cache.workOrders then
				for _, o in pairs(GSF.cache.workOrders) do
					if o.status == GSF.ORDER_STATUS.OPEN then
						openOrders = openOrders + 1
					end
				end
			end
			tooltip:AddDoubleLine("Open Work Orders:", "|cff00ff00" .. tostring(openOrders) .. "|r")

			tooltip:AddLine(" ")
			tooltip:AddLine("|cff33ff99Left-Click:|r Toggle Main Window", 0.8, 0.8, 0.8)
			tooltip:AddLine("|cff33ff99Right-Click:|r Scan Open Profession Window", 0.8, 0.8, 0.8)
		end,
	})

	DBIcon:Register("GSFHub", dataObj, GSF.db.minimap)
end
