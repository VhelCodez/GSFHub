local ADDON_NAME, GSF = ...

local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibStub("LibDeflate")

GSF.Protocol = {}

function GSF.Protocol:Encode(opcode, payload)
	if not opcode then return nil end
	local packet = {
		op = opcode,
		ver = GSF.PROTOCOL_VERSION,
		addonVer = GSF.VERSION,
		sender = GSF.DB:GetPlayerName(),
		data = payload or {},
		time = time(),
	}
	
	local serialized = AceSerializer:Serialize(packet)
	if not serialized then return nil end
	
	local compressed = LibDeflate:CompressDeflate(serialized)
	local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
	return encoded
end

function GSF.Protocol:Decode(rawMessage)
	if type(rawMessage) ~= "string" or rawMessage == "" then
		return nil, "Empty message"
	end
	
	local decoded = LibDeflate:DecodeForWoWAddonChannel(rawMessage)
	if not decoded then
		return nil, "Failed to decode base64"
	end
	
	local decompressed = LibDeflate:DecompressDeflate(decoded)
	if not decompressed then
		return nil, "Failed to decompress payload"
	end
	
	local ok, packet = AceSerializer:Deserialize(decompressed)
	if not ok or type(packet) ~= "table" then
		return nil, "Failed to deserialize packet"
	end
	
	return packet
end
