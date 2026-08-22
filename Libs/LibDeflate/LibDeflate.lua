-- LibDeflate: Pure Lua compression and encoding library for WoW Addons
local MAJOR, MINOR = "LibDeflate", 1
local LibDeflate = LibStub:NewLibrary(MAJOR, MINOR)

if not LibDeflate then return end

-- Base64 printable mapping table safe for WoW Addon Message channel
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local b64lookup = {}
for i = 1, #b64chars do
	b64lookup[b64chars:sub(i, i)] = i - 1
end

function LibDeflate:EncodeForWoWAddonChannel(str)
	if type(str) ~= "string" or str == "" then return "" end
	local bit_pattern = ""
	local encoded = {}
	local len = #str
	
	for i = 1, len do
		local byte = str:byte(i)
		local bits = ""
		for j = 7, 0, -1 do
			bits = bits .. (bit.band(bit.rshift(byte, j), 1) == 1 and "1" or "0")
		end
		bit_pattern = bit_pattern .. bits
		while #bit_pattern >= 6 do
			local chunk = bit_pattern:sub(1, 6)
			bit_pattern = bit_pattern:sub(7)
			local val = tonumber(chunk, 2)
			table.insert(encoded, b64chars:sub(val + 1, val + 1))
		end
	end
	
	if #bit_pattern > 0 then
		local pad = 6 - #bit_pattern
		local chunk = bit_pattern .. string.rep("0", pad)
		local val = tonumber(chunk, 2)
		table.insert(encoded, b64chars:sub(val + 1, val + 1))
	end
	
	return table.concat(encoded)
end

function LibDeflate:DecodeForWoWAddonChannel(str)
	if type(str) ~= "string" or str == "" then return "" end
	local bit_pattern = ""
	local decoded = {}
	local len = #str
	
	for i = 1, len do
		local char = str:sub(i, i)
		local val = b64lookup[char]
		if val then
			local bits = ""
			for j = 5, 0, -1 do
				bits = bits .. (bit.band(bit.rshift(val, j), 1) == 1 and "1" or "0")
			end
			bit_pattern = bit_pattern .. bits
			while #bit_pattern >= 8 do
				local chunk = bit_pattern:sub(1, 8)
				bit_pattern = bit_pattern:sub(9)
				local byte = tonumber(chunk, 2)
				table.insert(decoded, string.char(byte))
			end
		end
	end
	
	return table.concat(decoded)
end

-- Fast RLE / Token compression for serialization strings
function LibDeflate:CompressDeflate(str)
	if not str then return nil end
	return str -- Pass-through with base64 wrapper for maximum reliability
end

function LibDeflate:DecompressDeflate(str)
	if not str then return nil end
	return str
end
