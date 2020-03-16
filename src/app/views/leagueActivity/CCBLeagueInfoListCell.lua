local RankIcon = require("app.views.common.RankIcon")
local CCBCheckChairman = require("app.views.leagueActivity.CCBCheckChairman");
local CCBCheckSubChairman = require("app.views.leagueActivity.CCBCheckSubChairman");
local CCBCheckMember = require("app.views.leagueActivity.CCBCheckMember");

local CCBLeagueInfoListCell = class("CCBLeagueInfoListCell", function ()
	return CCBLoader("ccbi/leagueActivity/CCBLeagueInfoListCell.ccbi")
end)

function CCBLeagueInfoListCell:ctor()
end

function CCBLeagueInfoListCell:setData(info)
	self.m_info = info;

	self.m_ccbLabelName:setString("Lv." .. info.level .. " " .. info.nickname);
	self:showStateIsOnline(info.loginTime, info.online);
	self.m_ccbLabelFight:setString(info.power);
	self.m_ccbLabelTotalDonate:setString(info.power);
	self.m_ccbLabelWeekDonate:setString(info.power);
	self.m_ccbNodeRankIcon:addChild(RankIcon:getZoomRankIcon(info.famous_num, 0.2));
	local rankSpriteLabel = RankIcon:getZoomRankIconLabel(info.famous_num, 0.3);
	self.m_ccbNodeRankIcon:addChild(rankSpriteLabel);
	rankSpriteLabel:setPosition(cc.p(0, -15));

	self.m_ccbScaleNoSelected:setVisible(not info.isChairman);
	self.m_ccbScaleSelected:setVisible(info.isChairman);
	if info.isChairman or info.isSubChairman then
		self.m_ccbSpritePosition:setTexture(
			info.isChairman and "res/resources/leagueActivity/league_frame1_part2.png"
				 or "res/resources/leagueActivity/league_frame2_part2.png")
		:setVisible(true);
	else
		self.m_ccbSpritePosition:setVisible(false);
	end
end

function CCBLeagueInfoListCell:showStateIsOnline(loginTime, isOnline)
	if loginTime then
		self.m_ccbSpriteOnline:setVisible(false);
		self.m_ccbSpriteOffline:setVisible(false);
		self.m_ccbScale9SpriteMask:setVisible(true);
		self.m_ccbLabelLoginTime:setString(loginTime);
	elseif isOnline then
		self.m_ccbSpriteOnline:setVisible(true);
		self.m_ccbSpriteOffline:setVisible(false);
		self.m_ccbScale9SpriteMask:setVisible(false);
	else
		self.m_ccbSpriteOnline:setVisible(false);
		self.m_ccbSpriteOffline:setVisible(true);
		self.m_ccbScale9SpriteMask:setVisible(true);
	end
	self.m_ccbLabelLoginTime:setVisible(loginTime ~= nil)
end

function CCBLeagueInfoListCell:onBtnCheck()
	local random = math.random(1, 3)
	if 1 == random then
		App:getRunningScene():addChild(CCBCheckChairman:create());
	elseif 2 == random then
		App:getRunningScene():addChild(CCBCheckSubChairman:create());
	else
		App:getRunningScene():addChild(CCBCheckMember:create());
	end
end

return CCBLeagueInfoListCell