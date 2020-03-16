local CCBLeagueDynamicMemberCell = class("CCBLeagueDynamicMemberCell", function ()
	return CCBLoader("ccbi/leagueActivity/CCBLeagueDynamicMemberCell.ccbi")
end)

function CCBLeagueDynamicMemberCell:ctor()
end

function CCBLeagueDynamicMemberCell:setData(info)
	self.m_info = info;

	self.m_ccbLabelName:setString(info.nickname);
	self.m_ccbLabelTime:setString(info.time);
	self.m_ccbLabelDesc:setString(info.desc);
end

return CCBLeagueDynamicMemberCell