local CCBHeadBar = require("app.views.commonCCB.CCBHeadBar")
local CCBMailView = require("app.views.mailView.CCBMailView")
local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel");
-------------
-- 邮件界面
-------------
local MailView = class("MailView", require("app.views.GameViewBase"))

function MailView:init()

	-- local closeCallback = function () 
	-- 	App:enterScene("MainScene")
	-- end
	-- local coinCallback = function () 
	-- 	App:enterScene("ShopScene") 
	-- end
	-- local diamondCallback = function () 
	-- 	App:enterScene("ShopScene")	
	-- end

	-- self.headBar = CCBHeadBar:create("mailView", closeCallback, coinCallback, diamondCallback)
	-- self.headBar:move(display.center)
	-- self.headBar:movePos();
	-- self:add(self.headBar,100)
	self.m_ccbTitlePanel = CCBTitlePanel:create("mailView");
	self.m_ccbTitlePanel:setPosition(display.center);
	self:addChild(self.m_ccbTitlePanel, 2, 2);

	self.m_ccbTitlePanel.onBtnBack = function ()
		App:enterScene("MainScene");
	end

	self.m_ccbMailView = CCBMailView:create()
	self:addContent(self.m_ccbMailView)
end

-- 获取到数据
-- function MailView:setMailListData(data)
-- 	self.m_ccbMailView:setData(data);
-- end

-- 接收邮件附件
function MailView:resetMailListDataOfReceive()
	self.m_ccbMailView:reloadMailListData()
end

-- 接收所有邮件
-- function MailView:setReceiveAllPresentData(data)

-- 	-- self:addChild(self.m_ccbMailView:setAllPresentData(data), 100);
-- end

-- 新邮件来了，提示小红点
-- function MailView:setHintByNewMailData(data)
-- 	self.m_ccbMailView:setHintByNewMailData(data)
-- end

function MailView:updateHeadInfo()
	self.m_ccbTitlePanel:updateInfo();
end

return MailView