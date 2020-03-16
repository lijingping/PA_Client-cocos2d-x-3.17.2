local CCBLeagueUpgrade = require("app.views.leagueView.CCBLeagueUpgrade");
local league_upgrade = require("app.constants.league_upgrade_base");
local LeagueConsts = require("app.views.leagueView.LeagueConsts");
-------------------
-- CCB主界面
-------------------
local CCBLeagueBase = class("CCBLeagueBase", function ()
	return CCBLoader("ccbi/leagueView/CCBLeagueBase.ccbi")
end)

function CCBLeagueBase:ctor(params)
	if display.resolution >= 2 then
		self.m_ccbLayerCenter:setScale(display.reduce);
    end

    self.m_params = params;

	self:init();
end

function CCBLeagueBase:init()
	self:enableNodeEvents();

	local level = UserDataMgr:getLeagueBuildLevel()[LeagueConsts.BASE];
	self.m_data = clone(league_upgrade[tostring(level)])
	self.m_ccbLabelLevel:setString(level);
	self.m_ccbLabelLevelLimit:setString(self.m_data.upgrade_limit);
	self.m_ccbLabelMemberLimit:setString(self.m_data.member_limit);

	self.m_isHighestLevel = (level >= table.nums(league_upgrade))
	self.m_ccbNodeUpgrade:setVisible(not self.m_isHighestLevel);
	self.m_ccbNodeLimitLevel:setVisible(self.m_isHighestLevel);
end

function CCBLeagueBase:onEnter()
end

function CCBLeagueBase:onExit()
end

function CCBLeagueBase:onBtnClose()
	self:removeSelf();
end

function CCBLeagueBase:onBtnEnterLeague()
	self:onBtnClose();
	
	App:getRunningScene():getViewBase():createActivity();
end
 
function CCBLeagueBase:onBtnUpgrade()
	App:getRunningScene():addChild(CCBLeagueUpgrade:create(
		{mapIndex = self.m_params.mapIndex, conf_data = self.m_data,
		isHighestLevel = self.m_isHighestLevel,
		upgrade_conf_data = clone(league_upgrade[tostring(self.m_data.level+1)])}));
	
	self:onBtnClose();
end

function CCBLeagueBase:onBtnLimitLevel()
	Tips:create(Str[24011]);
end

return CCBLeagueBase