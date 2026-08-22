local ADDON_NAME, GSF = ...

GSF.VersionCheck = {}

local hasNotifiedThisSession = false
GSF.latestKnownVersion = GSF.VERSION

-- Converts semantic version string (e.g. "1.1.0" or "v1.1.0") into integer (10100)
function GSF.VersionCheck:ParseVersion(vStr)
	if not vStr then return 0 end
	vStr = tostring(vStr):gsub("^v", "")
	local major, minor, patch = vStr:match("(%d+)%.(%d+)%.(%d+)")
	if not major then
		major, minor = vStr:match("(%d+)%.(%d+)")
		patch = 0
	end
	if not major then
		major = vStr:match("(%d+)")
		minor = 0
		patch = 0
	end
	
	major = tonumber(major) or 0
	minor = tonumber(minor) or 0
	patch = tonumber(patch) or 0

	return (major * 10000) + (minor * 100) + patch
end

-- Returns 1 if v1 > v2, 0 if v1 == v2, -1 if v1 < v2
function GSF.VersionCheck:CompareVersions(v1, v2)
	local n1 = self:ParseVersion(v1)
	local n2 = self:ParseVersion(v2)
	if n1 > n2 then return 1
	elseif n1 < n2 then return -1
	else return 0 end
end

function GSF.VersionCheck:CheckPeerVersion(peerVersion, sender)
	if not peerVersion then return end
	if self:CompareVersions(peerVersion, GSF.VERSION) > 0 then
		if self:CompareVersions(peerVersion, GSF.latestKnownVersion) > 0 then
			GSF.latestKnownVersion = peerVersion
		end

		-- Notify in chat once per session
		if not hasNotifiedThisSession then
			hasNotifiedThisSession = true
			DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff33ff99GSFHub:|r " .. GSF.L["UPDATE_AVAILABLE_CHAT"], peerVersion))
		end

		-- Notify UI header
		if GSF.MainFrame and GSF.MainFrame.ShowUpdateBadge then
			GSF.MainFrame:ShowUpdateBadge(peerVersion)
		end
	end
end

function GSF.VersionCheck:OpenUpdateDialog()
	if GSF.URLDialog then
		local title = GSF.L["UPDATE_MODAL_TITLE"]
		local msg = string.format(GSF.L["UPDATE_MODAL_MSG"], GSF.latestKnownVersion)
		GSF.URLDialog:ShowDialog(title, msg, GSF.DOWNLOAD_URL)
	end
end
