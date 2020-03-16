
-----------------
-- 战舰界面-新
-----------------
local CCBShipMainView = require("app.views.shipView.CCBShipMainView");


local ShipMainView = class("ShipMainView", require("app.views.GameViewBase"))
local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel");

-- function ShipMainView:ctor()

-- 	print("ShipMainView:ctor()....1 ");
-- 	self:init();
-- end

function ShipMainView:init()
	-- print("shipMainView:init")
	self.m_ccbShipMainView = CCBShipMainView:create();
	self:addContent(self.m_ccbShipMainView);

	self.m_ccbTitlePanel = CCBTitlePanel:create("shipView");
	self.m_ccbTitlePanel:setPosition(display.center);
	self:addChild(self.m_ccbTitlePanel, 2, 2);

	self.m_ccbTitlePanel.onBtnBack = function ()
		App:enterScene("MainScene");
	end
end

-- 更换战舰皮肤上的炮塔
function ShipMainView:updateEquipFort()
	-- print("ShipMainView:updataEquipFort")
	self.m_ccbShipMainView:resetShipFortData();
	self.m_ccbShipMainView:resetFortsDataOfReload(); -- 这边只为刷新炮台的TableView，更直接的说法是为了显示“已装备”这个图标
end

function ShipMainView:updateHeadInfo()
	self.m_ccbTitlePanel:updateInfo();
end

-- function ShipMainView:updataShipFortData()
-- 	self.m_ccbShipMainView:resetShipFortData();
-- end

-- function ShipMainView:updataShipViewAfterUnlock()
-- 	self.m_ccbShipMainView:playUnlockSkinAnim();
-- end

-- -- 响应属性窗口的装备按钮的点击事件(装备炮台，晃动炮台)
-- function ShipMainView:shakeToEquipFort()
-- 	self.m_ccbShipMainView:shakeToEquipFort();
-- end

-- function ShipMainView:backToMainScene()
-- 	App:enterScene("MainScene");
-- end

-- -- 交换炮台失败后，让炮台回复能动的状态
-- function ShipMainView:rebackToCreateMoveFort()
-- 	self.m_ccbShipMainView:rebackToCreateMoveFort();
-- end

-- function ShipMainView:updateShipProperty()
-- 	-- print("ShipMainView:updateShipProperty")
-- 	if self.m_popupView ~= nil then
-- 		self.m_popupView:updateShipProperty()
-- 	end
-- end

return ShipMainView