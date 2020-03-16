local ResourceMgr = require("app.utils.ResourceMgr");
-------------------
-- CCB主界面
-------------------
local CCBLeagueApplyCell = class("CCBLeagueApplyCell", function()
	return CCBLoader("ccbi/leagueView/CCBLeagueApplyCell.ccbi")
end)

function CCBLeagueApplyCell:ctor()
	if display.resolution >= 2 then
		self:setScale(display.reduce);
	end
end

function CCBLeagueApplyCell:flushData(data)
	self.m_ccbLabelID:setString(data.id)
	self.m_ccbLabelName:setString(data.name)
	self.m_ccbLabelLevel:setString(data.level)
	self.m_ccbLabelFight:setString(data.power)
	self.m_ccbLabelMember:setString(data.member_count .."/" .. data.member_limit)
	self.m_ccbLabelState:setString((data.state == 1) and "自由加入" or "需要审批")
	self.m_ccbSpriteRank:setTexture(ResourceMgr:getLeagueBadgeByIconID(data.iconID));
end

function CCBLeagueApplyCell:setSelectedVisible(isVisible)
	self.m_ccbSpriteSelected:setVisible(isVisible);
end

function CCBLeagueApplyCell:setApplyVisible(isVisible)
	self.m_ccbSpriteApply:setVisible(isVisible);
end

return CCBLeagueApplyCell;