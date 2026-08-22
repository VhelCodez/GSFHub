local MAJOR, MINOR = "AceAddon-3.0", 13
local AceAddon, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceAddon then return end

AceAddon.addons = AceAddon.addons or {}
AceAddon.statuses = AceAddon.statuses or {}
AceAddon.embeds = AceAddon.embeds or {}

local addonprototype = {}
local addonprototype_mt = {__index = addonprototype}

function AceAddon:NewAddon(object, name, ...)
	if type(object) == "string" then
		name, object = object, nil
	end
	if type(name) ~= "string" then
		error("Usage: NewAddon([object ,] name, [lib, lib, lib, ...]): 'name' - string expected.", 2)
	end
	if self.addons[name] then
		error(("Addon '%s' already exists."):format(name), 2)
	end

	local addon = object or {}
	addon.name = name
	addon.prototype = addonprototype
	addon.defaultModuleLibraries = {}
	addon.modules = {}
	addon.orderedModules = {}

	setmetatable(addon, addonprototype_mt)
	self.addons[name] = addon

	for i = 1, select("#", ...) do
		local lib = select(i, ...)
		self:EmbedLibrary(addon, lib, false, name)
	end

	return addon
end

function AceAddon:GetAddon(name, silent)
	if not self.addons[name] and not silent then
		error(("Usage: GetAddon(name): 'name' - Cannot find an AceAddon '%s'."):format(tostring(name)), 2)
	end
	return self.addons[name]
end

function AceAddon:EmbedLibrary(addon, libname, silent, addonname)
	local lib = LibStub:GetLibrary(libname, silent)
	if not lib then return end
	if type(lib.Embed) == "function" then
		lib:Embed(addon)
	end
end

function AceAddon:EmbedLibraries(addon, ...)
	for i = 1, select("#", ...) do
		self:EmbedLibrary(addon, select(i, ...))
	end
end

function addonprototype:NewModule(name, ...)
	if self.modules[name] then
		error(("Module '%s' already exists in addon '%s'."):format(name, self.name), 2)
	end
	local module = AceAddon:NewAddon(name, ...)
	module.moduleName = name
	module.baseName = self.name
	module.parent = self
	self.modules[name] = module
	table.insert(self.orderedModules, module)
	return module
end

function addonprototype:GetModule(name, silent)
	if not self.modules[name] and not silent then
		error(("Module '%s' not found in addon '%s'."):format(tostring(name), self.name), 2)
	end
	return self.modules[name]
end

function addonprototype:GetName()
	return self.name
end

-- Initialize frame to listen to ADDON_LOADED and PLAYER_LOGIN
local frame = _G.AceAddon30Frame or CreateFrame("Frame", "AceAddon30Frame")
frame:UnregisterAllEvents()
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

local function InitializeAddon(addon)
	if addon.OnInitialize and not addon.initialized then
		addon.initialized = true
		safecall(addon.OnInitialize, addon)
	end
end

local function EnableAddon(addon)
	if not addon.enabled then
		addon.enabled = true
		if addon.OnEnable then
			safecall(addon.OnEnable, addon)
		end
		for _, mod in ipairs(addon.orderedModules) do
			EnableAddon(mod)
		end
	end
end

function safecall(func, ...)
	local ok, err = pcall(func, ...)
	if not ok and geterrorhandler() then
		geterrorhandler()(err)
	end
	return ok
end

frame:SetScript("OnEvent", function(self, event, arg1)
	if event == "PLAYER_LOGIN" then
		for _, addon in pairs(AceAddon.addons) do
			InitializeAddon(addon)
		end
		for _, addon in pairs(AceAddon.addons) do
			EnableAddon(addon)
		end
	end
end)
