local CCBLeagueFight = require("app.views.leagueFight.CCBLeagueFight");
local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel");

CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");
Tips = require("app.views.common.Tips");
---------------
-- 主界面
---------------
local LeagueFight = class("LeagueFight", require("app.views.GameViewBase"))

function LeagueFight:init()
	self.m_ccbTitlePanel = CCBTitlePanel:create("league_font2_tab");
	self.m_ccbTitlePanel:setPosition(display.center);
	self:addChild(self.m_ccbTitlePanel, 2, 2);

	self.m_ccbTitlePanel.onBtnBack = function ()
		if self.m_strLastSceneName then
			App:enterScene(self.m_strLastSceneName);
		else 
			App:enterScene("MainScene");
		end
	end

	self.m_ccbLeagueFight = CCBLeagueFight:create();
	self:addContent(self.m_ccbLeagueFight);
end

function LeagueFight:updateHeadInfo()
 	self.m_ccbTitlePanel:updateInfo();
end

function LeagueFight:setLastSceneName(name)
	self.m_strLastSceneName = name;
end

return LeagueFight