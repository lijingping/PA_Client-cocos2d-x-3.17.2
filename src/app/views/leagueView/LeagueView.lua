local CCBLeagueView = require("app.views.leagueView.CCBLeagueView");
local CCBLeagueApply = require("app.views.leagueView.CCBLeagueApply");
local CCBLeagueActivity = require("app.views.leagueActivity.CCBLeagueActivity");
local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel");

local CCBChatDialogbox = require("app.views.friendView.CCBChatDialogbox");

CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");
Tips = require("app.views.common.Tips");
---------------
-- 主界面
---------------
local LeagueView = class("LeagueView", require("app.views.GameViewBase"))

function LeagueView:init()
	self.m_ccbTitlePanel = CCBTitlePanel:create("league_font_tab");
	self.m_ccbTitlePanel:setPosition(display.center);
	self.m_ccbTitlePanel:showNodeLeague();
	self.m_ccbTitlePanel:setLastSceneName("LeagueScene");
	self:addChild(self.m_ccbTitlePanel, 2, 2);

	self.m_ccbTitlePanel.onBtnBack = function ()
		if self.m_ccbLeagueActivity then
			self.m_ccbLeagueActivity:removeSelf();
			self.m_ccbLeagueActivity = nil;
		else
			App:enterScene("MainScene");
		end
	end

	if UserDataMgr:getPlayerUnionLevel() <= 0 then
		self.m_ccbLeagueApply = CCBLeagueApply:create();
		self:addContent(self.m_ccbLeagueApply);
	else
		self:createView();
	end
end

function LeagueView:updateHeadInfo()
 	self.m_ccbTitlePanel:updateInfo();
end

function LeagueView:createView()
	self.m_ccbLeagueView = CCBLeagueView:create();
	self:addContent(self.m_ccbLeagueView);
end

function LeagueView:createActivity()
	self.m_ccbLeagueActivity = CCBLeagueActivity:create();
	self:addContent(self.m_ccbLeagueActivity);
end

function LeagueView:showChatDialogbox(info)
	local chatDialogbox = CCBChatDialogbox:create(info);
	chatDialogbox:setName("ChatDialogbox");
	App:getRunningScene():addChild(chatDialogbox);
end

return LeagueView