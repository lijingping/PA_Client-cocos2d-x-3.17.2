local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel");
local CCBDomainBattle = require("app.views.domainBattleView.CCBDomainBattleView");

local DomainBattleView = class("DomainBattleView", require("app.views.GameViewBase"));

function DomainBattleView:ctor()
	self.m_ccbTitlePanel = CCBTitlePanel:create("domainView");
	self.m_ccbTitlePanel:setPosition(display.center);
	self:addChild(self.m_ccbTitlePanel, 2, 2);

	self.m_ccbTitlePanel.onBtnBack = function ()
		App:enterScene("MainScene");
	end

	self.m_ccbDomainView = CCBDomainBattle:create();
	self:addContent(self.m_ccbDomainView);

end

function DomainBattleView:setViewData(data)
	self.m_ccbDomainView:setDomainData(data);
end

function DomainBattleView:updateHeadInfo()
	self.m_ccbTitlePanel:updateInfo();
end

return DomainBattleView;