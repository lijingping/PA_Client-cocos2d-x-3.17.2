--local CCBHeadBar = require("app.views.commonCCB.CCBHeadBar")
local CCBProduceView2 = require("app.views.produceView.CCBProduceView2")
local Tips = require("app.views.common.Tips");
local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel");

--------------
-- 生产窗口
--------------
local ProduceWindow = class("ProduceWindow", require("app.views.GameViewBase"))

function ProduceWindow:init()
	self.m_ccbTitlePanel = CCBTitlePanel:create("produceItemView");
	self.m_ccbTitlePanel:setPosition(display.center);
	self:addChild(self.m_ccbTitlePanel, 2, 2);

	self.m_ccbTitlePanel.onBtnBack = function ()
		App:enterScene("ProduceScene1");
	end

	self.m_ccbProduceView2 = CCBProduceView2:create()
	self.m_ccbProduceView2:setPosition(display.center)
	self:add(self.m_ccbProduceView2)
end

return ProduceWindow