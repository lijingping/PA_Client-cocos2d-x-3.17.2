local CCBHeadBar = require("app.views.commonCCB.CCBHeadBar")
local CCBShopView = require("app.views.shopView.CCBShopView")
local CCBAmountControl = require("app.views.shopView.CCBAmountControl");
local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel");

--------------
-- 商店界面
--------------
local ShopView = class("ShopView", require("app.views.GameViewBase"))

function ShopView:init()

	self.m_ccbShopView = CCBShopView:create()
	-- ccbShop:selectButton(1)

	self:addContent(self.m_ccbShopView)

	-- self.m_headBar = CCBHeadBar:create("shopView")
	-- self.m_headBar.onBtnClose = function()
	-- 	print("onCloseTouched")
	-- 	App:enterScene("MainScene")
	-- end
	-- self.m_headBar:move(display.center);
	-- self.m_headBar:movePos();
	-- self:add(self.m_headBar,100)
	self.m_ccbTitlePanel = CCBTitlePanel:create("shopView");
	self.m_ccbTitlePanel:setPosition(display.center);
	self:addChild(self.m_ccbTitlePanel, 2, 2);

	self.m_ccbTitlePanel.onBtnBack = function ()
		if self.m_strLastSceneName then
			App:enterScene(self.m_strLastSceneName);
		else 
			App:enterScene("MainScene");
		end
	end

	self.m_ccbBuyCountSetting = nil;
end

--设置购买数量
function ShopView:showSetAmountPopup(data, cell)
	if self.m_ccbBuyCountSetting == nil then
		self.m_ccbBuyCountSetting = CCBAmountControl:create(data, cell)
		self:addChild(self.m_ccbBuyCountSetting, 100);	
	end
end

function ShopView:closeAmountPopup()
	if self.m_ccbBuyCountSetting then
		self.m_ccbBuyCountSetting:removeSelf();
		self.m_ccbBuyCountSetting = nil;
	end
end

function ShopView:updateHeadInfo()
	self.m_ccbTitlePanel:updateInfo();
end
-- function ShopView:updateMoney()
-- 	self.m_headBar:UpdateInfo();
-- end

function ShopView:showNodeFriendship()
	self.m_ccbTitlePanel:showNodeFriendship();
end

function ShopView:hideNodeFriendship()
	self.m_ccbTitlePanel:hideNodeFriendship();
end

function ShopView:showNodeResolvePoint()
	self.m_ccbTitlePanel:showNodeResolvePoint();
end

function ShopView:hideNodeResolvePoint()
	self.m_ccbTitlePanel:hideNodeResolvePoint();
end

function ShopView:showNodeLeague()
	self.m_ccbTitlePanel:showNodeLeague();
end

function ShopView:hideNodeLeague()
	self.m_ccbTitlePanel:hideNodeLeague();
end

function ShopView:openDecompose()
	self.m_ccbShopView:onBtnDecompose();
end

function ShopView:setLastSceneName(name)
	self.m_strLastSceneName = name;
end

function ShopView:getLastSceneName()
	return self.m_strLastSceneName;
end

function ShopView:openLeague()
	self.m_ccbShopView:onBtnLeague();
end

return ShopView