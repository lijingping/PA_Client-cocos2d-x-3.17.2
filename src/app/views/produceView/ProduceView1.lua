--local CCBHeadBar = require("app.views.commonCCB.CCBHeadBar")

local CCBProduceView1 = require("app.views.produceView.CCBProduceView1")
local ProduceView1 = class("ProduceView1", require("app.views.GameViewBase"))
local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel");

function ProduceView1:ctor()
	local closeCallback = function () App:enterScene("MainScene") end
	local coinCallback = function () App:enterScene("ShopScene") end
	local diamondCallback = function () App:enterScene("ShopScene")	end

	--self.m_headBar = CCBHeadBar:create("produceView", closeCallback, coinCallback, diamondCallback)
	--self.m_headBar:move(display.center);
	--self.m_headBar:movePos();
	--self:add(self.m_headBar, 100);
	self.m_ccbTitlePanel = CCBTitlePanel:create("produceView");
	self.m_ccbTitlePanel:setPosition(display.center);
	self:addChild(self.m_ccbTitlePanel, 2, 2);

	self.m_ccbTitlePanel.onBtnBack = function ()
		App:enterScene("MainScene");
	end

	self.m_ccbProduceView1 = CCBProduceView1:create();
	self:addChild(self.m_ccbProduceView1);
	self.m_ccbProduceView1:setPosition(display.center);	
end

function ProduceView1:updateHeadInfo()
 	self.m_ccbTitlePanel:updateInfo();
end

return ProduceView1