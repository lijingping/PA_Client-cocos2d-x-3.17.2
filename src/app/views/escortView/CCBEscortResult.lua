local ResourceMgr = require("app.utils.ResourceMgr");

local CCBEscortResult = class("CCBEscortResult", function()
	return CCBLoader("ccbi/escortView/CCBEscortResult.ccbi")
	end)

local bgFrameSize = cc.size(550, 415);
 -- 金黄色 255， 255， 0    黄色 255， 153， 0
local golden_color = cc.c3b(255, 255, 0);
local yellow_color = cc.c3b(255, 153, 0);

local escortSuccessDescriptionPosY = 22;
local escortFailDescriptionPosY = -8;
local otherGainTitleEscortPosY = -90;
local otherGainTitleLootPosY = 0;
local otherGainCoinEscortPosY = -147;
local otherGainCoinLootPosY = -87;

-- resultType 1 护送 2 打劫    nResult 1 成功 2 失败 
function  CCBEscortResult:ctor(resultType, nResult)
	if display.resolution >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
	App:getRunningScene():addChild(self);
	
	self:createTouchListener();
	self.m_resultType = resultType;
	self.m_result = nResult;

	self:setCascadeOpacityEnabled(true);
	self.m_ccbLayerColor:setCascadeOpacityEnabled(true);
	self.m_ccbNodeCenter:setCascadeOpacityEnabled(true);
	self.m_ccbNodeViewBg:setCascadeOpacityEnabled(true);
	self.m_ccbNodeViewLineBg:setCascadeOpacityEnabled(true);
	self.m_ccbNodeTitleSprite:setCascadeOpacityEnabled(true);
	self.m_ccbNodeTitleLabel:setCascadeOpacityEnabled(true);
	self.m_ccbNodeShowReward:setCascadeOpacityEnabled(true);
	self.m_ccbNodeGainItems:setCascadeOpacityEnabled(true);
	self.m_ccbNodeGainCoin:setCascadeOpacityEnabled(true);
	self.m_ccbNodeGainItem:setCascadeOpacityEnabled(true);

	self:setOpacity(0);
	local fadeInAction = cc.FadeIn:create(0.5);
	self:runAction(fadeInAction);

	local bgSprite = cc.Sprite:create(ResourceMgr:getEscortResultBg(self.m_result));
	self.m_ccbNodeViewBg:addChild(bgSprite);
	local lineSprite = cc.Sprite:create(ResourceMgr:getEscortResultTitleLine(self.m_result));
	self.m_ccbNodeViewLineBg:addChild(lineSprite);
	local resultSprite = cc.Sprite:create(ResourceMgr:getEscortResultSprite(self.m_result));
	self.m_ccbNodeTitleSprite:addChild(resultSprite);
	local labelSprite = cc.Sprite:create(ResourceMgr:getEscortResultTitle(self.m_resultType, self.m_result));
	self.m_ccbNodeTitleLabel:addChild(labelSprite);

end

function CCBEscortResult:createTouchListener()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function (touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(function (touch, event) self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function CCBEscortResult:onTouchBegan(touch, event)
	print("touch began");
	return true;
end

function CCBEscortResult:onTouchMoved(touch, event)

end

function CCBEscortResult:setViewData(data)
	-- data 结构：护送和打劫是不一样的，字段也不一样
	-- dump(data);
	if self.m_resultType == 1 then  -- 护送
		if self.m_result == 1 then  -- 胜利
			self.m_ccbLabelDescription:setString(Str[12013]);
			self.m_ccbLabelDescription:setPositionY(escortSuccessDescriptionPosY);
			self.m_ccbNodeGainItems:setVisible(true);
			-- 设置护送收益item
			for k, v in pairs(data.award_list) do 
				if v.item_id == 10001 then 
					local coinSprite = cc.Sprite:create(ResourceMgr:getItemIconByID(v.item_id));
					self.m_ccbNodeGainCoin:addChild(coinSprite);
					coinSprite:setScale(0.8);
					self.m_ccbLabelCoin:setString(v.count - data.event_award_count);
				else
					local itemSprite = cc.Sprite:create(ResourceMgr:getItemIconByID(v.item_id));
					self.m_ccbNodeGainItem:addChild(itemSprite);
					itemSprite:setScale(0.8);
					self.m_ccbLabelItemCount:setString(v.count);
				end
			end
			-- 额外收益  self.m_ccbLabelOtherCoinCount
			self.m_ccbLabelOtherCoinCount:setString(data.event_award_count);
		else
			self.m_ccbLabelDescription:setString(Str[12014]);
			self.m_ccbLabelDescription:setPositionY(escortFailDescriptionPosY);
			self.m_ccbNodeGainItems:setVisible(false);

			-- 额外收益  self.m_ccbLabelOtherCoinCount
			self.m_ccbLabelOtherCoinCount:setString(data.event_award_count);
		end
		self.m_ccbLabelOtherGainTitle:setString(Str[12015]);
		self.m_ccbLabelOtherGainTitle:setPositionY(otherGainTitleEscortPosY);
		self.m_ccbSpriteOtherCoin:setPositionY(otherGainCoinEscortPosY);
		self.m_ccbLabelOtherCoinCount:setPositionY(otherGainCoinEscortPosY);
	else
		self.m_ccbLabelDescription:setString("");
		self.m_ccbNodeGainItems:setVisible(false);
		self.m_ccbLabelOtherGainTitle:setPositionY(otherGainTitleLootPosY);
		if self.m_result == 1 then
			self.m_ccbLabelOtherGainTitle:setString(string.format(Str[12016], data.enemy_name));
			self.m_ccbSpriteOtherCoin:setVisible(true);
			self.m_ccbSpriteOtherCoin:setPositionY(otherGainCoinLootPosY);
			self.m_ccbLabelOtherCoinCount:setPositionY(otherGainCoinLootPosY);
			-- 设置打劫收益
			self.m_ccbLabelOtherCoinCount:setString(data.money);
		else
			self.m_ccbLabelOtherGainTitle:setString(string.format(Str[12017], data.enemy_name));
			self.m_ccbSpriteOtherCoin:setVisible(false);
			self.m_ccbLabelOtherCoinCount:setString("");
		end
	end
end

function CCBEscortResult:onBtnEnsure()
	self:removeSelf();
end

return CCBEscortResult;