-- local CCBHeadBar = require("app.views.commonCCB.CCBHeadBar")
local CCBEscortView = require("app.views.escortView.CCBEscortView")
local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel");

local EscortView = class("EscortView", require("app.views.GameViewBase"))


function EscortView:ctor()
	-- print("这里是护送页面")
	-- local closeCallback = function () 
	-- 	App:enterScene("MainScene")
	-- end
	-- local coinCallback = function () 
	-- 	App:enterScene("ShopScene") 
	-- end
	-- local diamondCallback = function () 
	-- 	App:enterScene("ShopScene")	
	-- end

	-- self.m_headBar = CCBHeadBar:create("shopView", closeCallback, coinCallback, diamondCallback);
	-- self.m_headBar:move(display.center);
	-- self.m_headBar:movePos();
	-- self:add(self.m_headBar,100);
	self.m_ccbTitlePanel = CCBTitlePanel:create("convoy_font_tab");
	self.m_ccbTitlePanel:setPosition(display.center);
	self:addChild(self.m_ccbTitlePanel, 2, 2);

	self.m_ccbTitlePanel.onBtnBack = function ()
		App:enterScene("MainScene");
	end

	self.m_ccbEscortView = CCBEscortView:create();
	self:addContent(self.m_ccbEscortView);
end

function EscortView:updateHeadInfo()
	self.m_ccbTitlePanel:updateInfo();
end

--更新护卫商船信息
-- function EscortView:rebackToMerchantShipUpdate()
-- 	self.m_ccbEscortView:setEscortUpdate();
-- end

-- function EscortView:rebackToMerchantShipRefurbish()
-- 	self.m_ccbEscortView:refurbishArmature()
-- end

-- function EscortView:updateMoney()
-- 	self.m_headBar:UpdateInfo();
-- end

return EscortView