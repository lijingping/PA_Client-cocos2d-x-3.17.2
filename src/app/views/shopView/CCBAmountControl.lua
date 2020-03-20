--local CCBProduceSlider = require("app.views.produceView.CCBProduceSlider")
--local CCBPopWindow = require("app.views.commonCCB.CCBPopWindow");
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");
local ResourceMgr = require("app.utils.ResourceMgr");

------------------
-- 购买数量设置弹窗
------------------
local sliderSize = cc.size(310, 30);
local orangeColor = cc.c3b(255, 124, 0);
local yellowColor = cc.c3b(255, 255, 51);

local CCBAmountControl = class("CCBAmountControl", function ()
	return CCBLoader("ccbi/shopView/CCBAmountControl.ccbi")
end)

function CCBAmountControl:ctor(data, cell)
	if display.resolution >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
	self.m_data = data;
	self.m_cell = cell;
	self:setData(data)
	--BlockLayer:create():addTo(self.layer_root)
	self.m_listener = cc.EventListenerTouchOneByOne:create();
	self.m_listener:setSwallowTouches(true);
    self.m_listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_listener, self);

	self:createSlider();
end

function CCBAmountControl:updateButtonText(str)
	if self.m_richTextBtn then
		self.m_richTextBtn:removeSelf();
	end

	self.m_richTextBtn = ccui.RichText:create();

    local reimg = ccui.RichElementImage:create(2, cc.c3b(255, 255, 255), 255, "res/images/ui_gold01_button.png");
    local text = ccui.RichElementText:create(1, cc.c3b(255, 255, 255), 255, str, "font/simhei.ttf", 25);

    self.m_richTextBtn:pushBackElement(reimg);
    self.m_richTextBtn:pushBackElement(text);
	self.m_ccbNodeRichBtn:addChild(self.m_richTextBtn); 

end

function CCBAmountControl:createSlider()
    self.m_BuyCountSlider = ccui.Slider:create()
    
    self.m_BuyCountSlider:setScale9Enabled(true)
    self.m_BuyCountSlider:setTouchEnabled(true)

    self.m_BuyCountSlider:setContentSize(sliderSize);
    self.m_BuyCountSlider:setAnchorPoint(0.5, 0.5);
    local ballPath = ResourceMgr:getSliderBall();
	local barBgPath = ResourceMgr:getSliderBarBg();
	local barPath = ResourceMgr:getSliderBar();
    self.m_BuyCountSlider:loadBarTexture(barBgPath);
    self.m_BuyCountSlider:loadProgressBarTexture(barPath);
    self.m_BuyCountSlider:loadSlidBallTextures(ballPath, ballPath, ballPath);

	self.m_BuyCountSlider:setPercent(1 / self.m_maxItemBuy * 100)
        :setCapInsets(cc.rect(18, 0, 18, 0));
	-- self.m_BuyCountSlider:setMaxPercent(100);

	local function changeEvent(pSender, eventType)
		if eventType == ccui.SliderEventType.percentChanged then
			local percent = pSender:getPercent();
			self.m_amount = math.floor(self.m_maxItemBuy * percent * 0.01);
			if self.m_amount < 1 then
				self.m_amount = 1;
				pSender:setPercent(self.m_amount / self.m_maxItemBuy * 100);
			end
			
			self.m_totalCost = self.m_singleItemPrice * self.m_amount;
			self.m_ccbLabelCount:setString(Str[16010].."：".. self.m_amount);
			self.m_ccbLabelPayCount:setString(self.m_totalCost);
			-- self:updateButtonText(tostring(self.m_totalCost));
		end
	end
    self.m_BuyCountSlider:addEventListener(changeEvent);
    self.m_ccbNodeSlider:addChild(self.m_BuyCountSlider);
end

function CCBAmountControl:onBtnSliderSub()
	if self.m_amount <= 1 then
		return;
	end
	self.m_amount = self.m_amount - 1;
	self.m_BuyCountSlider:setPercent(self.m_amount / self.m_maxItemBuy * 100);
	self.m_totalCost = self.m_singleItemPrice * self.m_amount;
	self.m_ccbLabelCount:setString(Str[16010].."：".. self.m_amount);
	self.m_ccbLabelPayCount:setString(self.m_totalCost);
	-- self:updateButtonText(tostring(self.m_singleItemPrice * curBuyCount));
end

function CCBAmountControl:onBtnSliderAdd()
	if self.m_amount >= self.m_maxItemBuy then
		return;
	end
	self.m_amount = self.m_amount + 1;
	self.m_BuyCountSlider:setPercent(self.m_amount / self.m_maxItemBuy * 100);
	self.m_totalCost = self.m_singleItemPrice * self.m_amount;
	self.m_ccbLabelCount:setString(Str[16010].."：".. self.m_amount);
	self.m_ccbLabelPayCount:setString(self.m_totalCost);
	-- self:updateButtonText(tostring(self.m_singleItemPrice * curBuyCount));
end

function CCBAmountControl:setData(data)
	-- dump(data);
	local itemData = ItemDataMgr:getItemBaseInfo(data.item_id)
	-- dump(itemData);
	-- self.ccb_icon:setData(itemData)
	self:setIconAndIconBg(itemData);

	self.m_ccbLabelItemName:setString(data.name);
	local qualityColor = {[0]=cc.c3b(255, 255, 255), [1]=CCC3_TEXT_GREEN, [2]=CCC3_TEXT_BLUE, [3]=CCC3_TEXT_PURPLE, [4]=CCC3_TEXT_GOLDEN};
    self.m_ccbLabelItemName:setColor(qualityColor[itemData.level]);

	self.m_ccbLabelItemDesc:setString(data.desc);
	local payIconID = data.items[1].item_id;
	local payIconSprite = cc.Sprite:create(ResourceMgr:getItemIconByID(payIconID));
	self.m_ccbNodePayIcon:addChild(payIconSprite);
	payIconSprite:setScale(0.5);
	self.m_singleItemPrice = data.items[1].count;
	self.m_ccbLabelPayCount:setString(self.m_singleItemPrice);
	self.m_ccbLabelCount:setString(Str[16010].."：".. 1);
	self.m_amount = 1;
	self.m_totalCost = self.m_singleItemPrice;

	self.m_produceId = data.id
	self.m_itemName = data.name;
	self.m_payIconID = payIconID;

	self:setConditionLabel();
end

function CCBAmountControl:setIconAndIconBg(data)
	local spriteBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(data.level + 1));
	self.m_ccbNodeIcon:addChild(spriteBg);
	local spriteIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(data.item_icon));
	if spriteIcon == nil then
		spriteIcon = cc.Sprite:create("res/itemIcon/xxx.png");
	end
	self.m_ccbNodeIcon:addChild(spriteIcon);
	local spriteIconFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(data.level + 1));
	self.m_ccbNodeIcon:addChild(spriteIconFrame);
end

function CCBAmountControl:onBtnConfirm()
	self:onBuyClicked();
end

function CCBAmountControl:onBuyClicked()
	--local popView = nil;
	local money = UserDataMgr:getPlayerMoneyByItemID(self.m_payIconID);
	local moneyName = ItemDataMgr:getItemNameByID(self.m_payIconID);
	if money >= self.m_totalCost then
		local ccbMessageBox = CCBMessageBox:create(Str[3010], string.format(Str[4010], self.m_totalCost, moneyName, self.m_itemName), MB_YESNO)--是否花费%d钻石购买%s
		ccbMessageBox.onBtnOK = function ()
			self:pressToBuy();
			ccbMessageBox:removeSelf();
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
	else
		if self.m_payIconID == 10003 then
			Tips:create(Str[4026]);
		elseif self.m_payIconID == 10007 then
			Tips:create(Str[16007]);
		elseif self.m_payIconID == 10008 then
			Tips:create(Str[18002]);
		else
			local ccbMessageBox = CCBMessageBox:create(Str[3016], Str[4004], MB_YESNO)--钻石不足，是否前往充值页面？
			ccbMessageBox.onBtnOK = function ()
				App:enterScene("ShopScene");
			end
			ccbMessageBox.onBtnCancel = function ()
				ccbMessageBox:removeSelf();
			end
		end
	end
end

-- 购买物品
function CCBAmountControl:pressToBuy()
	Network:request("game.shopHandler.buyItem", {table_id = self.m_produceId, count = self.m_amount}, function (rc, receivedData)
			if receivedData.code ~= 1 then
				Tips:create(ServerCode[receivedData.code]);
				return;
			end			
			--Tips:create(string.format("成功购买%s个 %s !", self.m_amount, self.m_itemName))
			if self.m_data.day_limit ~= 0 then
				local info = ItemDataMgr:getBuyTimes()[self.m_produceId];
				ItemDataMgr:setBuyTimes({[self.m_produceId] = (info and info+1 or 1)});

				self.m_cell:setConditionLabel();
			end

			App:getRunningScene():getViewBase():closeAmountPopup();
	end)	
end


function CCBAmountControl:onCloseTouched()
	App:getRunningScene():getViewBase():closeAmountPopup();
	-- self:removeSelf();
end

function CCBAmountControl:setConditionLabel()
	local playerMoney = UserDataMgr:getPlayerMoneyByItemID(self.m_payIconID);
	self.m_maxItemBuy = math.floor(playerMoney / self.m_singleItemPrice);

	if self.m_data.require_alliance_level ~= 0 and self.m_data.require_alliance_level > UserDataMgr:getPlayerUnionLevel() then
		self.m_ccbLabelLeft:setString(Str[16001] .. self.m_data.require_alliance_level);
		self.m_ccbLabelLeft:setColor(orangeColor);
	elseif self.m_data.contribution ~= 0 and self.m_data.contribution > UserDataMgr:getPlayerContribution() then
		self.m_ccbLabelLeft:setString(Str[16002] .. self.m_data.contribution);
		self.m_ccbLabelLeft:setColor(orangeColor);
	elseif self.m_data.day_limit ~= 0 then
		local itemBuyTimes = ItemDataMgr:getBuyTimes()[self.m_data.id];
		itemBuyTimes = (itemBuyTimes and itemBuyTimes or 0);
		itemBuyTimes = (self.m_data.day_limit - itemBuyTimes);

		self.m_ccbLabelLeft:setString(Str[16011].."：".. itemBuyTimes);
		self.m_ccbLabelLeft:setColor(yellowColor);

		if self.m_maxItemBuy > itemBuyTimes then
			self.m_maxItemBuy = itemBuyTimes;
		end
	else
		self.m_ccbLabelLeft:setString("");
		self.m_ccbSpriteLeft:setVisible(false);
	end

	if self.m_maxItemBuy < 1 then
		self.m_maxItemBuy = 1;
	end
end

return CCBAmountControl