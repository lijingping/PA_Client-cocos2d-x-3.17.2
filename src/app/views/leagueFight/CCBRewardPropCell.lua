local ResourceMgr = require("app.utils.ResourceMgr");

local CCBRewardPropCell = class("CCBRewardPropCell", function()
	return CCBLoader("ccbi/leagueFight/CCBRewardPropCell");
end)


function CCBRewardPropCell:ctor()
end

function CCBRewardPropCell:setData(info)
	self.m_ccbSpriteID:setVisible(info.id <= 3);
	if info.id <= 3 then
		self.m_ccbSpriteID:setTexture(string.format("resources/domainBattleView/boss_icon_rank%d.png", info.id));
	end
	self.m_ccbLabelID:setString(info.id);

	self.m_ccbLabelName:setString(info.name);
	self.m_ccbLabelScore:setString(info.score);
	self.m_ccbLabelPower:setString(info.power);

	self.m_ccbSpriteRank:setTexture(ResourceMgr:getLeagueBadgeByIconID(info.iconID));
end

return CCBRewardPropCell;