local ResourceMgr = require("app.utils.ResourceMgr");

local CCBFightRecordListCell = class("CCBFightRecordListCell", function()
	return CCBLoader("ccbi/leagueFight/CCBFightRecordListCell");
end)


function CCBFightRecordListCell:ctor()
end

function CCBFightRecordListCell:setData(info)
	self.m_ccbSpriteRank:setTexture(ResourceMgr:getLeagueBadgeByIconID(info.iconID));

	self.m_ccbLabelName:setString(info.nickname);
	self.m_ccbLabelInfo:setString(info.info);
	self.m_ccbLabelResult:setString(info.result):setColor(info.resultColor);
	self.m_ccbLabelScore:setString(info.score);
	self.m_ccbLabelTime:setString(info.time);

	self.m_ccbSpriteBg:setVisible(info.id%2 == 0);

end

return CCBFightRecordListCell;