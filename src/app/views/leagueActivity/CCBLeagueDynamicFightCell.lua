local CCBLeagueDynamicFightCell = class("CCBLeagueDynamicFightCell", function ()
	return CCBLoader("ccbi/leagueActivity/CCBLeagueDynamicFightCell.ccbi")
end)

function CCBLeagueDynamicFightCell:ctor()
end

function CCBLeagueDynamicFightCell:setData(info)
	self.m_info = info;

	self.m_ccbLabelTime:setString(info.time);
	self.m_ccbLabelDesc:setString(info.desc);
end

return CCBLeagueDynamicFightCell