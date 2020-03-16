local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel")
local CCBPackageView = require("app.views.packageView.CCBPackageView")

local PackageView = class("PackageView", require("app.views.GameViewBase"))


function PackageView:init()
	print("###PackageView:init");
	
	self.m_ccbTitlePanel = CCBTitlePanel:create("packageView");
	self.m_ccbTitlePanel:setPosition(display.center);
	self:addChild(self.m_ccbTitlePanel, 2, 2);

	self.m_ccbTitlePanel.onBtnBack = function ()
		App:enterScene("MainScene");
	end
	
	self.m_ccbPackageView = CCBPackageView:create()
	self:addContent(self.m_ccbPackageView, 1, 1);
end

function PackageView:updateHeadInfo()
	self.m_ccbTitlePanel:updateInfo();
end

return PackageView;