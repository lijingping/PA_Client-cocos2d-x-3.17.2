--local CCBHeadBar = require("app.views.commonCCB.CCBHeadBar")
---------------
--  复仇名单
---------------

local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel")
local CCBRevengeView = require("app.views.revengeView.CCBRevengeView")
--local CCBWaittingRevengePopup = require("app.views.revengeView.CCBWaittingRevengePopup")


local RevengeView = class("RevengeView", require("app.views.GameViewBase"))

function RevengeView:init()
	print("#################RevengeView:init()");

	self.m_ccbTitlePanel = CCBTitlePanel:create("revengeView");
	self.m_ccbTitlePanel:setPosition(display.center);
	self:addChild(self.m_ccbTitlePanel, 2, 2);

	self.m_ccbTitlePanel.onBtnBack = function ()
		App:enterScene("MainScene");
	end
	
	self.m_ccbRevengeView = CCBRevengeView:create()
	self:addContent(self.m_ccbRevengeView)
end

return RevengeView