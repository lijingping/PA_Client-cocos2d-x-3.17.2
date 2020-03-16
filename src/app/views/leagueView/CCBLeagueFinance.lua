local CCBLeagueUpgrade = require("app.views.leagueView.CCBLeagueUpgrade");
local league_upgrade = require("app.constants.league_upgrade_finance");
local LeagueConsts = require("app.views.leagueView.LeagueConsts");
-------------------
-- CCB主界面
-------------------
local CCBLeagueFinance = class("CCBLeagueFinance", function ()
	return CCBLoader("ccbi/leagueView/CCBLeagueFinance.ccbi")
end)

function CCBLeagueFinance:ctor(params)
	if display.resolution >= 2 then
		self.m_ccbLayerCenter:setScale(display.reduce);
    end

    self.m_params = params;

	self:init();
end

function CCBLeagueFinance:init()
	self:enableNodeEvents();

	local level = UserDataMgr:getLeagueBuildLevel()[LeagueConsts.FINANCE];
	self.m_data = clone(league_upgrade[tostring(level)])
	self.m_ccbLabelLevel:setString(level);
	self.m_ccbLabelAddAwd:setString(string.format("+%d%%", self.m_data.coin_reward*100));
	--self.m_ccbLabelAdd:setString();

	self.m_isHighestLevel = (level >= table.nums(league_upgrade))
	self.m_ccbNodeUpgrade:setVisible(not self.m_isHighestLevel);
	self.m_ccbNodeLimitLevel:setVisible(self.m_isHighestLevel);
end

function CCBLeagueFinance:onEnter()
end

function CCBLeagueFinance:onExit()
end

function CCBLeagueFinance:onBtnClose()
	self:removeSelf();
end

function CCBLeagueFinance:onBtnEnterLeague()
end
 
function CCBLeagueFinance:onBtnUpgrade()
	App:getRunningScene():addChild(CCBLeagueUpgrade:create(
		{mapIndex = self.m_params.mapIndex, conf_data = self.m_data,
		isHighestLevel = self.m_isHighestLevel,
		upgrade_conf_data = clone(league_upgrade[tostring(self.m_data.level+1)])}));
	
	self:onBtnClose();
end

function CCBLeagueFinance:onBtnLimitLevel()
	Tips:create(Str[24011]);
end

return CCBLeagueFinance