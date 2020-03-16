local RankIcon = require("app.views.common.RankIcon")

local CCBLeagueApplyListCell = class("CCBLeagueApplyListCell", function ()
	return CCBLoader("ccbi/leagueActivity/CCBLeagueApplyListCell.ccbi")
end)

function CCBLeagueApplyListCell:ctor()
end

function CCBLeagueApplyListCell:setData(info)
	self.m_ccbLabelName:setString("Lv." .. info.level .. " " .. info.nickname);
	self.m_ccbLabelFight:setString(info.power);

	self.m_ccbNodeRankIcon:addChild(RankIcon:getZoomRankIcon(info.famous_num, 0.2));
	local rankSpriteLabel = RankIcon:getZoomRankIconLabel(info.famous_num, 0.3);
	self.m_ccbNodeRankIcon:addChild(rankSpriteLabel);
	rankSpriteLabel:setPosition(cc.p(0, -15));
end

function CCBLeagueApplyListCell:onBtnReject()
end

function CCBLeagueApplyListCell:onBtnAccept()
end

return CCBLeagueApplyListCell