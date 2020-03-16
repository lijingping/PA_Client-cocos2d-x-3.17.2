local CCBCheckChairman = class("CCBCheckChairman", function ()
	return CCBLoader("ccbi/leagueActivity/CCBCheckChairman.ccbi")
end)

function CCBCheckChairman:ctor()
	--self.m_ccbLabelName:setString()
	--self.m_ccbLabelJoinTime:setString()
end

function CCBCheckChairman:onBtnClose()
	self:removeSelf();
end
function CCBCheckChairman:onBtnAddFriend()
	self.m_ccbNodeAddFiend:setVisible(false)

	self.m_ccbNodeChat:setVisible(true)
end
function CCBCheckChairman:onBtnChat()
	local info = {
		famous_num= 0,
		icon= "default",
		level= 1,
		m_curSystemTime= 1566443313,
		nickname="迪克欧尔佳",
		online= false,
		power= 44895,
		sort= 4489500,
		uid="cfcde2685d5df26942564a3bbb9e6db3",
		wish_item_id= 2906
	}
	App:getRunningScene():getViewBase():showChatDialogbox(info);

	self:onBtnClose()
end
function CCBCheckChairman:onBtnAppointSubChairman()
	self.m_ccbNodeAppointSubChairman:setVisible(false)
	self.m_ccbNodeCancellAppoint:setVisible(true)
end
function CCBCheckChairman:onBtnCancellAppoint()
	self.m_ccbNodeAppointSubChairman:setVisible(true)
	self.m_ccbNodeCancellAppoint:setVisible(false)
end
function CCBCheckChairman:onBtnTransferChairman()
end
function CCBCheckChairman:onBtnKick()
end

return CCBCheckChairman