local CCBLeagueUpgrade = require("app.views.leagueView.CCBLeagueUpgrade");
local CCBLeagueExchangeCoin = require("app.views.leagueView.CCBLeagueExchangeCoin");
local league_upgrade = require("app.constants.league_upgrade_exchange");
local LeagueConsts = require("app.views.leagueView.LeagueConsts");
-------------------
-- CCB主界面
-------------------
local CCBLeagueExchange = class("CCBLeagueExchange", function ()
	return CCBLoader("ccbi/leagueView/CCBLeagueExchange.ccbi")
end)

function CCBLeagueExchange:ctor(params)
	if display.resolution >= 2 then
		self.m_ccbLayerCenter:setScale(display.reduce);
    end

    self.m_params = params;

	self:init();
end

function CCBLeagueExchange:init()
	self:enableNodeEvents();

	local level = UserDataMgr:getLeagueBuildLevel()[LeagueConsts.EXCHANGE];
	self.m_data = clone(league_upgrade[tostring(level)])
	self.m_ccbLabelLevel:setString(level);
	--self.m_ccbLabelExchange:setString();

	self.m_isHighestLevel = (level >= table.nums(league_upgrade))
	self.m_ccbNodeUpgrade:setVisible(not self.m_isHighestLevel);
	self.m_ccbNodeLimitLevel:setVisible(self.m_isHighestLevel);
end

function CCBLeagueExchange:onEnter()
end

function CCBLeagueExchange:onExit()
end

function CCBLeagueExchange:onBtnClose()
	self:removeSelf();
end

function CCBLeagueExchange:onBtnExchange()
	App:getRunningScene():addChild(CCBLeagueExchangeCoin:create());
end
 
function CCBLeagueExchange:onBtnUpgrade()
	App:getRunningScene():addChild(CCBLeagueUpgrade:create(
		{mapIndex = self.m_params.mapIndex, conf_data = self.m_data,
		isHighestLevel = self.m_isHighestLevel,
		upgrade_conf_data = clone(league_upgrade[tostring(self.m_data.level+1)])}));
	
	self:onBtnClose();
end

function CCBLeagueExchange:onBtnLimitLevel()
	Tips:create(Str[24011]);
end

return CCBLeagueExchange