local MAJOR, MINOR = "LibDBIcon-1.0", 44
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local ldb = LibStub("LibDataBroker-1.1")

lib.objects = lib.objects or {}
lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)

local defaultCoords = {0, 1, 0, 1}

local function UpdatePosition(button, position)
	local angle = math.rad(position or 225)
	local x = math.cos(angle) * 80
	local y = math.sin(angle) * 80
	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function OnDragStart(self)
	self:LockHighlight()
	self.isDragging = true
	self:SetScript("OnUpdate", function(self)
		local mx, my = Minimap:GetCenter()
		local px, py = GetCursorPosition()
		local scale = Minimap:GetEffectiveScale()
		px, py = px / scale, py / scale
		local angle = math.deg(math.atan2(py - my, px - mx))
		if angle < 0 then angle = angle + 360 end
		self.db.minimapPos = angle
		UpdatePosition(self, angle)
	end)
end

local function OnDragStop(self)
	self:SetScript("OnUpdate", nil)
	self.isDragging = false
	self:UnlockHighlight()
end

function lib:Register(name, dataobj, db)
	if not dataobj then
		dataobj = ldb:GetDataObjectByName(name)
	end
	if not dataobj then return end
	if self.objects[name] then return self.objects[name] end

	db = db or {}
	db.minimapPos = db.minimapPos or 225
	db.hide = db.hide or false

	local button = CreateFrame("Button", "LibDBIcon10_" .. name, Minimap)
	button:SetFrameStrata("MEDIUM")
	button:SetSize(31, 31)
	button:SetFrameLevel(8)
	button:RegisterForClicks("anyUp")
	button:RegisterForDrag("LeftButton")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-Button-Highlight")

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetSize(53, 53)
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetPoint("TOPLEFT")

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetSize(20, 20)
	icon:SetTexture(dataobj.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
	icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	icon:SetPoint("CENTER", 0, 0)
	button.icon = icon

	button.db = db
	button.dataobj = dataobj

	button:SetScript("OnEnter", function(self)
		if self.dataobj.OnEnter then
			self.dataobj.OnEnter(self)
		elseif self.dataobj.OnTooltipShow then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
			self.dataobj.OnTooltipShow(GameTooltip)
			GameTooltip:Show()
		end
	end)

	button:SetScript("OnLeave", function(self)
		if self.dataobj.OnLeave then
			self.dataobj.OnLeave(self)
		else
			GameTooltip:Hide()
		end
	end)

	button:SetScript("OnClick", function(self, btn)
		if self.dataobj.OnClick then
			self.dataobj.OnClick(self, btn)
		end
	end)

	button:SetScript("OnDragStart", OnDragStart)
	button:SetScript("OnDragStop", OnDragStop)

	UpdatePosition(button, db.minimapPos)

	if db.hide then
		button:Hide()
	else
		button:Show()
	end

	self.objects[name] = button
	return button
end

function lib:Show(name)
	if self.objects[name] then
		self.objects[name].db.hide = false
		self.objects[name]:Show()
	end
end

function lib:Hide(name)
	if self.objects[name] then
		self.objects[name].db.hide = true
		self.objects[name]:Hide()
	end
end

function lib:GetMinimapButton(name)
	return self.objects[name]
end
