local CCBCheckSubChairman = class("CCBCheckSubChairman", function ()
	return CCBLoader("ccbi/leagueActivity/CCBCheckSubChairman.ccbi")
end)

function CCBCheckSubChairman:ctor()
	--self.m_ccbLabelName:setString()
	--self.m_ccbLabelJoinTime:setString()
end

function CCBCheckSubChairman:onBtnClose()
	self:removeSelf();
end
function CCBCheckSubChairman:onBtnAddFriend()
	self.m_ccbNodeAddFiend:setVisible(false)

	self.m_ccbNodeChat:setVisible(true)
end
function CCBCheckSubChairman:onBtnChat()
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
function CCBCheckSubChairman:onBtnTransferChairman()
end
function CCBCheckSubChairman:onBtnKick()
end

return CCBCheckSubChairman