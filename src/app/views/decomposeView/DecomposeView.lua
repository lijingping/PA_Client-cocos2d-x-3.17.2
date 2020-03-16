local CCBDecomposeView = require("app.views.decomposeView.CCBDecomposeView");
local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel");
--------------
--分解窗口
--------------
local DecomposeView = class("DecomposeView", require("app.views.GameViewBase"))

function DecomposeView:init()
	self.m_ccbTitlePanel = CCBTitlePanel:create("resolve_font_title");
	self.m_ccbTitlePanel:setPosition(display.center);
	self.m_ccbTitlePanel:showNodeResolvePoint()
	self:addChild(self.m_ccbTitlePanel, 2, 2);

	self.m_ccbTitlePanel.onBtnBack = function ()
		App:enterScene("PackageScene");
	end

	self.m_ccbDecomposeView = CCBDecomposeView:create();
	self.m_ccbDecomposeView:setPosition(display.center);
	self:add(self.m_ccbDecomposeView);
end

function DecomposeView:updateHeadInfo()
 	self.m_ccbTitlePanel:updateInfo();
end

return DecomposeView