local MAJOR, MINOR = "AceSerializer-3.0", 5
local AceSerializer = LibStub:NewLibrary(MAJOR, MINOR)

if not AceSerializer then return end

AceSerializer.embeds = AceSerializer.embeds or {}

-- AceSerializer serializes Lua types (numbers, booleans, strings, tables) into a compact ASCII format
local function serialize(val, res)
	local t = type(val)
	if t == "nil" then
		table.insert(res, "^Z")
	elseif t == "number" then
		table.insert(res, "^N" .. tostring(val))
	elseif t == "boolean" then
		table.insert(res, val and "^B" or "^b")
	elseif t == "string" then
		local s = val:gsub("~", "~~"):gsub("%^", "~=")
		table.insert(res, "^S" .. s)
	elseif t == "table" then
		table.insert(res, "^T")
		for k, v in pairs(val) do
			serialize(k, res)
			serialize(v, res)
		end
		table.insert(res, "^t")
	else
		error(("Cannot serialize type '%s'"):format(t), 2)
	end
end

function AceSerializer:Serialize(...)
	local res = {"^1"}
	for i = 1, select("#", ...) do
		serialize(select(i, ...), res)
	end
	return table.concat(res)
end

local function deserialize(str, pos)
	local tag = str:sub(pos, pos + 1)
	if tag == "^Z" then
		return nil, pos + 2
	elseif tag == "^B" then
		return true, pos + 2
	elseif tag == "^b" then
		return false, pos + 2
	elseif tag == "^N" then
		local nextPos = str:find("%^", pos + 2)
		local numStr
		if nextPos then
			numStr = str:sub(pos + 2, nextPos - 1)
			return tonumber(numStr), nextPos
		else
			numStr = str:sub(pos + 2)
			return tonumber(numStr), #str + 1
		end
	elseif tag == "^S" then
		local nextPos = str:find("%^", pos + 2)
		local strVal
		if nextPos then
			strVal = str:sub(pos + 2, nextPos - 1)
			pos = nextPos
		else
			strVal = str:sub(pos + 2)
			pos = #str + 1
		end
		strVal = strVal:gsub("~=", "^"):gsub("~~", "~")
		return strVal, pos
	elseif tag == "^T" then
		local tbl = {}
		pos = pos + 2
		while pos <= #str do
			if str:sub(pos, pos + 1) == "^t" then
				return tbl, pos + 2
			end
			local k, v
			k, pos = deserialize(str, pos)
			v, pos = deserialize(str, pos)
			if k ~= nil then
				tbl[k] = v
			end
		end
		return tbl, pos
	else
		return nil, pos + 1
	end
end

function AceSerializer:Deserialize(str)
	if type(str) ~= "string" or str:sub(1, 2) ~= "^1" then
		return false, "Invalid serialized string format"
	end
	local pos = 3
	local results = {}
	while pos <= #str do
		local res
		res, pos = deserialize(str, pos)
		table.insert(results, res)
	end
	return true, unpack(results)
end

local mixins = {
	"Serialize",
	"Deserialize",
}

function AceSerializer:Embed(target)
	for _, v in ipairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end
