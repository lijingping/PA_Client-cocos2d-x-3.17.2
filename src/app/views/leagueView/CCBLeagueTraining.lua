local ResourceMgr = require("app.utils.ResourceMgr");
local CCBLeagueUpgrade = require("app.views.leagueView.CCBLeagueUpgrade");
local league_upgrade = require("app.constants.league_upgrade_training");
local LeagueConsts = require("app.views.leagueView.LeagueConsts");
-------------------
-- CCB主界面
-------------------
local CCBLeagueTraining = class("CCBLeagueTraining", function ()
	return CCBLoader("ccbi/leagueView/CCBLeagueTraining.ccbi")
end)

function CCBLeagueTraining:ctor(params)
	if display.resolution >= 2 then
		self.m_ccbLayerCenter:setScale(display.reduce);
    end

    self.m_params = params;

	self:init();
end

function CCBLeagueTraining:init()
	self:enableNodeEvents();

	--强化芯片
	self.m_ccbSpriteIcon:setTexture(ResourceMgr:getItemIconByID(4002))
		:setScale(0.8);

	local level = UserDataMgr:getLeagueBuildLevel()[LeagueConsts.TRAINING];
	self.m_data = clone(league_upgrade[tostring(level)])
	self.m_ccbLabelLevel:setString(level);
	self.m_ccbLabelAddAwd:setString(string.format("%d%%", self.m_data.exp_reward*100));
	--self.m_ccbLabelAdd:setString();

	self.m_isHighestLevel = (level >= table.nums(league_upgrade))
	self.m_ccbNodeUpgrade:setVisible(not self.m_isHighestLevel);
	self.m_ccbNodeLimitLevel:setVisible(self.m_isHighestLevel);
end

function CCBLeagueTraining:onEnter()
end

function CCBLeagueTraining:onExit()
end

function CCBLeagueTraining:onBtnClose()
	self:removeSelf();
end

function CCBLeagueTraining:onBtnEnterLeague()
end
 
function CCBLeagueTraining:onBtnUpgrade()
	App:getRunningScene():addChild(CCBLeagueUpgrade:create(
		{mapIndex = self.m_params.mapIndex, conf_data = self.m_data,
		isHighestLevel = self.m_isHighestLevel,
		upgrade_conf_data = clone(league_upgrade[tostring(self.m_data.level+1)])}));
	
	self:onBtnClose();
end

function CCBLeagueTraining:onBtnLimitLevel()
	Tips:create(Str[24011]);
end

return CCBLeagueTraining