---------------
--  任务界面
---------------
local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel");
-- local CCBHeadBar = require("app.views.commonCCB.CCBHeadBar");
local CCBLotteryView = import(".CCBLotteryView");

local LotteryView = class("LotteryView", require("app.views.GameViewBase"));

function LotteryView:init()
	print("LotteryView:init");
	-- local closeCallback = function ()
	-- 		App:enterScene("MainScene");
	-- 	end

	-- local coinCallback = function ()
	-- 		App:enterScene("ShopScene");
	-- 	end

	-- local diamondCallback = function ()
	-- 		App:enterScene("ShopScene");
	-- 	end

	-- self.m_headBar = CCBHeadBar:create("lotteryView", closeCallback, coinCallback, diamondCallback);
	-- self.m_headBar:move(display.center);
	-- self.m_headBar:movePos();
	-- self:add(self.m_headBar,100);
	self.m_ccbTitlePanel = CCBTitlePanel:create("lotteryView");
	self.m_ccbTitlePanel:setPosition(display.center);
	self.m_ccbTitlePanel:showNodeKey();
	self.m_ccbTitlePanel:setLastSceneName("LotteryScene");
	self:addChild(self.m_ccbTitlePanel, 2, 2);

	self.m_ccbTitlePanel.onBtnBack = function ()
		App:enterScene("MainScene");
	end

	self.m_isNormal = false;

	self.m_lotteryView = CCBLotteryView:create();
	self:addContent(self.m_lotteryView);
end

function LotteryView:updateHeadInfo()
	self.m_ccbTitlePanel:updateInfo();
end
-- function LotteryView:updateMoney()
-- 	self.m_headBar:UpdateInfo();
-- end

return LotteryView;
