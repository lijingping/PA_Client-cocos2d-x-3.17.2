local CCBLeagueUpgrade = require("app.views.leagueView.CCBLeagueUpgrade");
local league_upgrade = require("app.constants.league_upgrade_research");
local LeagueConsts = require("app.views.leagueView.LeagueConsts");
-------------------
-- CCB主界面
-------------------
local CCBLeagueResearch = class("CCBLeagueResearch", function ()
	return CCBLoader("ccbi/leagueView/CCBLeagueResearch.ccbi")
end)

function CCBLeagueResearch:ctor(params)
	if display.resolution >= 2 then
		self.m_ccbLayerCenter:setScale(display.reduce);
    end

    self.m_params = params;

	self:init();
end

function CCBLeagueResearch:init()
	self:enableNodeEvents();

	local level = UserDataMgr:getLeagueBuildLevel()[LeagueConsts.RESEARCH];
	self.m_data = clone(league_upgrade[tostring(level)])
	self.m_ccbLabelLevel:setString(level);
	self.m_ccbLabelTime:setString(self.m_data.time);

	self.m_isHighestLevel = (level >= table.nums(league_upgrade))
	self.m_ccbNodeUpgrade:setVisible(not self.m_isHighestLevel);
	self.m_ccbNodeLimitLevel:setVisible(self.m_isHighestLevel);

	self.m_ccbBtnReward:setVisible(true);
	self.m_ccbNodeResearching:setVisible(false);	
end

function CCBLeagueResearch:onEnter()
end

function CCBLeagueResearch:onExit()
	if self.m_updateScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_updateScheduler);
		self.m_updateScheduler = nil;
	end
end

function CCBLeagueResearch:onBtnClose()
	self:removeSelf();
end

function CCBLeagueResearch:onBtnResearching()
	self.m_ccbBtnReward:setVisible(true);
	self.m_ccbNodeResearching:setVisible(false);
end

function CCBLeagueResearch:onBtnResearch()
end

function CCBLeagueResearch:showTimeFormat(time)
	local hour = math.floor(time / 3600);
	local minute = math.floor((time % 3600) / 60);
	local second = time % 60;
	return string.format("%02d:%02d:%02d", hour, minute, second);	
end
function CCBLeagueResearch:onBtnReward()
	self.m_ccbBtnReward:setVisible(false);
	self.m_ccbNodeResearching:setVisible(true);

	self:onExit();
	self.m_showProduceLeftTime = 20;
	if self.m_updateScheduler == nil then
		self.m_updateScheduler = self:getScheduler():scheduleScriptFunc(function() 
			self.m_showProduceLeftTime = self.m_showProduceLeftTime - 1;
			--时间计算到0，关闭窗口
			if self.m_showProduceLeftTime < 0 then
				self:onBtnReward();
				return;
			end

			self.m_ccbLabelLeftTime:setString(self:showTimeFormat(self.m_showProduceLeftTime));
		end, 1, false);
	end
end
 
function CCBLeagueResearch:onBtnUpgrade()
	App:getRunningScene():addChild(CCBLeagueUpgrade:create(
		{mapIndex = self.m_params.mapIndex, conf_data = self.m_data,
		isHighestLevel = self.m_isHighestLevel,
		upgrade_conf_data = clone(league_upgrade[tostring(self.m_data.level+1)])}));
	
	self:onBtnClose();
end

function CCBLeagueResearch:onBtnLimitLevel()
	Tips:create(Str[24011]);
end

return CCBLeagueResearch