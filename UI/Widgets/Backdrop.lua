local ADDON_NAME, GSF = ...

GSF.UI = {}

-- Backdrop helper ensuring 9.x/2.5.x BackdropTemplate compatibility
function GSF.UI:CreateBackdrop(frame, isParchment)
	if BackdropTemplateMixin and not frame.SetBackdrop then
		Mixin(frame, BackdropTemplateMixin)
	end

	local bg = isParchment and "Interface\\DialogFrame\\UI-DialogBox-Background" or "Interface\\Tooltips\\UI-Tooltip-Background"
	local edge = isParchment and "Interface\\DialogFrame\\UI-DialogBox-Border" or "Interface\\Tooltips\\UI-Tooltip-Border"

	frame:SetBackdrop({
		bgFile = bg,
		edgeFile = edge,
		tile = true,
		tileSize = 32,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	
	if not isParchment then
		frame:SetBackdropColor(0.08, 0.08, 0.10, 0.95)
		frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
	else
		frame:SetBackdropColor(0.9, 0.9, 0.9, 1.0)
	end
end

function GSF.UI:CreateButton(parent, text, width, height)
	local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	btn:SetSize(width or 100, height or 24)
	btn:SetText(text or "Button")
	return btn
end

function GSF.UI:CreateEditBox(parent, width, height)
	local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	eb:SetSize(width or 150, height or 22)
	eb:SetAutoFocus(false)
	eb:SetFontObject("GameFontHighlightSmall")
	return eb
end

function GSF.UI:CreateTab(parent, id, title)
	local tab = CreateFrame("Button", parent:GetName() .. "Tab" .. id, parent, "CharacterFrameTabButtonTemplate")
	tab:SetID(id)
	tab:SetText(title)
	tab:SetScript("OnClick", function()
		parent:SelectTab(id)
	end)
	return tab
end

function GSF.UI:CreateScrollList(parent, width, height)
	local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
	scrollFrame:SetSize(width, height)

	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetSize(width - 24, height)
	scrollFrame:SetScrollChild(content)

	return scrollFrame, content
end
