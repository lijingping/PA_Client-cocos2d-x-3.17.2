local CCBRateView = class("CCBRateView", function ()
	return CCBLoader("ccbi/lotteryView/CCBRateView.ccbi")
end)

function CCBRateView:ctor(listType)
	if display.resolution >= 2 then
		self.m_ccbLayerPopupWindow:setScale(display.reduce);
	end
	self:enableNodeEvents();
	self:createCoverLayer();
	self:showList(listType);
end

function CCBRateView:createCoverLayer()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
    listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);

    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerColor);
end

function CCBRateView:onBtnClose()
	self:removeSelf();
end

function CCBRateView:showList(listType)
	local spriteList = cc.Sprite:create("res/resources/lotteryView/lottery_rate" .. listType .. ".png");
    spriteList:setPosition(0, 0);
    spriteList:setAnchorPoint(0, 0);

    self.m_ccbScrollView:setContentSize(cc.size(spriteList:getContentSize().width, spriteList:getContentSize().height));
    self.m_ccbScrollView:setContentOffset(self.m_ccbScrollView:minContainerOffset());
    self.m_ccbScrollView:addChild(spriteList);
end 

return CCBRateView;