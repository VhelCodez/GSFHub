local ADDON_NAME, GSF = ...

local AceEvent = LibStub("AceEvent-3.0")
GSF.MailHelper = {}
AceEvent:Embed(GSF.MailHelper)

GSF.MailHelper.stagedMail = nil

function GSF.MailHelper:Initialize()
	self:RegisterEvent("MAIL_SHOW", "OnMailShow")
	self:RegisterEvent("MAIL_CLOSED", "OnMailClosed")
end

function GSF.MailHelper:PrepareMail(recipient, subject, items)
	self.stagedMail = {
		recipient = recipient,
		subject = subject or "GSF Delivery",
		items = items or {},
	}

	if MailFrame and MailFrame:IsShown() then
		self:PopulateMail()
	else
		GSF.Addon:Printf("Open any Mailbox to auto-fill mail for |cff33ff99%s|r.", recipient)
	end
end

function GSF.MailHelper:OnMailShow()
	if self.stagedMail then
		self:PopulateMail()
	end
end

function GSF.MailHelper:PopulateMail()
	if not self.stagedMail then return end
	if not MailFrame or not MailFrame:IsShown() then return end

	-- Switch to Send Mail tab (Tab 2)
	MailFrameTab2:Click()

	if SendMailNameEditBox then
		SendMailNameEditBox:SetText(self.stagedMail.recipient or "")
	end
	if SendMailSubjectEditBox then
		SendMailSubjectEditBox:SetText(self.stagedMail.subject or "GSF Delivery")
	end

	-- Stage items into mail attachments
	if self.stagedMail.items and #self.stagedMail.items > 0 then
		local mailSlot = 1
		for _, itemInfo in ipairs(self.stagedMail.items) do
			if mailSlot > 12 then break end
			local bag, slot = GSF.TradeHelper:FindItemInBags(itemInfo.name or itemInfo.link)
			if bag and slot then
				C_Container and C_Container.PickupContainerItem and C_Container.PickupContainerItem(bag, slot) or PickupContainerItem(bag, slot)
				ClickSendMailItemButton(mailSlot)
				mailSlot = mailSlot + 1
			end
		end
	end

	GSF.Addon:Printf("Mail staged for |cff33ff99%s|r!", self.stagedMail.recipient)
	self.stagedMail = nil
end

function GSF.MailHelper:OnMailClosed()
	self.stagedMail = nil
end
