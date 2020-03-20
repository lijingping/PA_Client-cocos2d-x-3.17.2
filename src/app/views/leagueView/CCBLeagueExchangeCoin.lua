local ResourceMgr = require("app.utils.ResourceMgr");
local CCBBadgesGetPath = require("app.views.leagueView.CCBBadgesGetPath");
-------------------
-- CCB主界面
-------------------
local CCBLeagueExchangeCoin = class("CCBLeagueExchangeCoin", function ()
	return CCBLoader("ccbi/leagueView/CCBLeagueExchangeCoin.ccbi")
end)

function CCBLeagueExchangeCoin:ctor(params)
	if display.resolution >= 2 then
		self.m_ccbLayerCenter:setScale(display.reduce);
    end

	self:init();
end

function CCBLeagueExchangeCoin:init()
	self.m_ccbLabelItemCost:setString(2);

	--设置滑动条
    self.m_itemCountSlider = ccui.Slider:create()    
    self.m_itemCountSlider:setScale9Enabled(true)
    self.m_itemCountSlider:setTouchEnabled(true)
    self.m_itemCountSlider:setContentSize(self.m_ccbNodeSlider:getContentSize());
    self.m_itemCountSlider:setAnchorPoint(0, 0);
    self.m_itemCountSlider:loadBarTexture(ResourceMgr:getSliderBarBg());
    self.m_itemCountSlider:loadProgressBarTexture(ResourceMgr:getSliderBar());
    self.m_itemCountSlider:loadSlidBallTextures(ResourceMgr:getSliderBall(), ResourceMgr:getSliderBall(), ResourceMgr:getSliderBall());
	self.m_itemCountSlider:setPercent(1)
        :setCapInsets(cc.rect(18, 0, 18, 0));

	self.needCountMax = UserDataMgr:getLeagueBadges();
	if self.needCountMax < 1 then
		self.needCountMax = 1;
	end
	self.m_itemCountSlider:setMaxPercent(1);
	local function changeEvent(pSender, eventType)
		if eventType == ccui.SliderEventType.percentChanged then
			local percent = pSender:getPercent();
			if percent < 1 then
				percent = 1;
				pSender:setPercent(1);
			end
			self.m_ccbLabelItemCost:setString(percent);
		end
	end
    self.m_itemCountSlider:addEventListener(changeEvent);
    self.m_ccbNodeSlider:addChild(self.m_itemCountSlider);

    self.m_ccbNodeIcon:addChild(ResourceMgr:createItemIcon(10004));
    self.m_ccbNodeBadge:addChild(ResourceMgr:createItemIcon(4011));--联盟徽章
    --self.m_ccbNodeIcon:addChild(self:createIcon(10004, 3, 3));
    --self.m_ccbNodeBadge:addChild(self:createIcon(10003, 3, 3));
end

function CCBLeagueExchangeCoin:createIcon(itemID, itemLevel, quality)
	local node = cc.Node:create();

	cc.Sprite:create(ResourceMgr:getItemBGByQuality(itemLevel))
		:addTo(node, ICON_Z_ORDER_BG, ICON_TAG_BG);
	cc.Sprite:create(ResourceMgr:getItemIconByID(ItemDataMgr:getItemIconIDByItemID(itemID)))
		:addTo(node, ICON_Z_ORDER_PIC, ICON_TAG_PIC);
	cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(quality))
		:addTo(node, ICON_Z_ORDER_FRAME, ICON_TAG_FRAME);

	return node;
end

function CCBLeagueExchangeCoin:onBtnClose()
	self:removeSelf();
end

function CCBLeagueExchangeCoin:onBtnExchange()
	CCBBadgesGetPath:create(1004);
end

function CCBLeagueExchangeCoin:onBtnSliderDown()
	local curCostCount = self.m_itemCountSlider:getPercent();
	curCostCount = curCostCount - 1;
	if curCostCount < 1 then
		curCostCount = 1;
	end
	self.m_itemCountSlider:setPercent(curCostCount);
	self.m_ccbLabelItemCost:setString(curCostCount);
end

function CCBLeagueExchangeCoin:onBtnSliderUp()
	local curCostCount = self.m_itemCountSlider:getPercent();
	curCostCount = curCostCount + 1;
	if curCostCount > self.needCountMax then
		curCostCount = self.needCountMax;
	end
	self.m_itemCountSlider:setPercent(curCostCount);
	self.m_ccbLabelItemCost:setString(curCostCount);
end

return CCBLeagueExchangeCoin