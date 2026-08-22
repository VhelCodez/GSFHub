local MAJOR, MINOR = "LibDataBroker-1.1", 4
local ldb = LibStub:NewLibrary(MAJOR, MINOR)
if not ldb then return end

ldb.dataobjs = ldb.dataobjs or {}
ldb.callbacks = ldb.callbacks or LibStub:GetLibrary("CallbackHandler-1.0"):New(ldb)

local dataobj_mt = {
	__newindex = function(self, key, value)
		rawset(self, key, value)
		ldb.callbacks:Fire("LibDataBroker_AttributeChanged", self.name, key, value, self)
		ldb.callbacks:Fire("LibDataBroker_AttributeChanged_" .. self.name, self.name, key, value, self)
		ldb.callbacks:Fire("LibDataBroker_AttributeChanged_" .. self.name .. "_" .. key, self.name, key, value, self)
	end
}

function ldb:NewDataObject(name, dataobj)
	if self.dataobjs[name] then
		error(("Data object '%s' already exists."):format(name), 2)
	end
	dataobj = dataobj or {}
	dataobj.name = name
	setmetatable(dataobj, dataobj_mt)
	self.dataobjs[name] = dataobj
	self.callbacks:Fire("LibDataBroker_DataObjectCreated", name, dataobj)
	return dataobj
end

function ldb:GetDataObjectByName(name)
	return self.dataobjs[name]
end

function ldb:DataObjectIterator()
	return pairs(self.dataobjs)
end
