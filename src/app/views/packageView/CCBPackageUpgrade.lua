local ResourceMgr = require("app.utils.ResourceMgr");
local Tips = require("app.views.common.Tips");

local CCBPackageUpgrade = class("CCBPackageUpgrade", function ()
	return CCBLoader("ccbi/packageView/CCBPackageUpgrade.ccbi")
end)

local sliderSize = cc.size(320, 30);
local redColor = cc.c3b(255, 0, 0);
local whiteColor = cc.c3b(255, 255, 255);
local itemCountLabelPos = cc.p(42, -35);

function CCBPackageUpgrade:ctor(itemID)
	if display.resolution >= 2 then
        self.m_ccbNodeCenter:setScale(display.reduce);
    end
	App:getRunningScene():addChild(self, display.Z_BLURLAYER, 200);
	self:setPosition(cc.p(display.cx, display.cy));

	self:createTouchEvent();

	self.m_itemID = itemID;
	self.m_allItemUpgradeData = table.clone(require("app.constants.item_upgrade"));
	-- dump(self.m_allItemUpgradeData);
	self.m_itemUpgradeData = nil;
	for k, v in pairs(self.m_allItemUpgradeData) do 
		if v["$item_id"] == self.m_itemID then
			self.m_itemUpgradeData = v;
		end
	end
	if self.m_itemUpgradeData == nil then
		print(" 没有此道具的升级信息，您是否搞错的对象？");
	end
	self.m_itemUpgradeMaxCount = 1;
	self.m_singleItemNeedCount = 0;
	self.m_singleItemNeedCoin = 0;
	self.m_curComposeProp = 1;

	self:setUpgradeItemIcon();
	self:createSlider();
	self:setItemDetail();
end

function CCBPackageUpgrade:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event); end, cc.Handler.EVENT_TOUCH_BEGAN);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function CCBPackageUpgrade:onTouchBegan(touch, event)
	print("   touch   ...... ");
	return true;
end

function CCBPackageUpgrade:setUpgradeItemIcon()
	-- 左边icon
	local itemLevel = ItemDataMgr:getItemLevelByID(self.m_itemID);
	local itemIconBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(itemLevel + 1));
	local itemIconID = ItemDataMgr:getItemIconIDByItemID(self.m_itemID);
	local itemIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(itemIconID));
	local itemIconFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(itemLevel + 1));
	self.m_ccbNodeLeftIcon:addChild(itemIconBg);
	self.m_ccbNodeLeftIcon:addChild(itemIcon);
	self.m_ccbNodeLeftIcon:addChild(itemIconFrame);
	local itemCountLabel = cc.LabelTTF:create();
	itemCountLabel:setFontSize(19);
	itemCountLabel:setAnchorPoint(cc.p(1, 0.5));
	self.m_ccbNodeLeftIcon:addChild(itemCountLabel, 1, 2);
	local itemNeedCountLabel = cc.LabelTTF:create();
	itemNeedCountLabel:setFontSize(19);
	itemNeedCountLabel:setAnchorPoint(cc.p(1, 0.5));
	itemNeedCountLabel:setPosition(itemCountLabelPos);
	self.m_ccbNodeLeftIcon:addChild(itemNeedCountLabel, 1, 1);

	local itemCount = ItemDataMgr:getItemCount(self.m_itemID);
	for k, v in pairs(self.m_itemUpgradeData.required_items) do 
		if v.item_id == self.m_itemID then
			self.m_singleItemNeedCount = v.count;
		else
			self.m_singleItemNeedCoin = v.count;
		end
	end
	itemNeedCountLabel:setString("/" .. self.m_singleItemNeedCount);
	local labelSize = itemNeedCountLabel:getContentSize();
	itemCountLabel:setPosition(cc.p(itemCountLabelPos.x - labelSize.width, itemCountLabelPos.y));
	itemCountLabel:setString(itemCount);
	if itemCount < self.m_singleItemNeedCount then
		itemCountLabel:setColor(redColor);
	end
	self.m_itemUpgradeMaxCount = math.floor(itemCount / self.m_singleItemNeedCount);

	-- 右边icon
	local upItemID = self.m_itemUpgradeData.target_item_id;
	local upItemLevel = ItemDataMgr:getItemLevelByID(upItemID);
	local upItemIconBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(upItemLevel + 1));
	local upItemIconID = ItemDataMgr:getItemIconIDByItemID(upItemID);
	local upItemIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(upItemIconID));
	local upItemIconFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(upItemLevel + 1));
	self.m_ccbNodeRightIcon:addChild(upItemIconBg);
	self.m_ccbNodeRightIcon:addChild(upItemIcon);
	self.m_ccbNodeRightIcon:addChild(upItemIconFrame);
	local upItemCountLabel = cc.LabelTTF:create();
	upItemCountLabel:setFontSize(19);
	upItemCountLabel:setAnchorPoint(cc.p(1, 0.5));
	upItemCountLabel:setPosition(itemCountLabelPos);
	self.m_ccbNodeRightIcon:addChild(upItemCountLabel, 1, 1);
	upItemCountLabel:setString(self.m_curComposeProp);

	local playerGoldCoin = UserDataMgr:getPlayerGoldCoin();
	local goldCoinUpItemNum = math.floor(playerGoldCoin / self.m_singleItemNeedCoin);
	if goldCoinUpItemNum < self.m_itemUpgradeMaxCount then
		self.m_itemUpgradeMaxCount = goldCoinUpItemNum;
	end

	if self.m_itemUpgradeMaxCount < 1 then
		self.m_itemUpgradeMaxCount = 1;
		local upgradePropBg = cc.Sprite:create(ResourceMgr:getPackagePropUpgradeBgGray());
		self.m_ccbNodePropUpgradeBg:addChild(upgradePropBg);
	else
		local upgradePropBg = cc.Sprite:create(ResourceMgr:getPackagePropUpgradeBgLight());
		self.m_ccbNodePropUpgradeBg:addChild(upgradePropBg);
	end

	self.m_ccbLabelGoldCount:setString(self.m_singleItemNeedCoin * self.m_curComposeProp);
end

function CCBPackageUpgrade:createSlider()
	self.m_countSlider = ccui.Slider:create();
	self.m_countSlider:setTouchEnabled(true);
	self.m_countSlider:setScale9Enabled(true);
	self.m_countSlider:setContentSize(sliderSize);
	local ballPath = ResourceMgr:getSliderBall();
	local barBgPath = ResourceMgr:getSliderBarBg();
	local barPath = ResourceMgr:getSliderBar();
	self.m_countSlider:loadBarTexture(barBgPath);
	self.m_countSlider:loadSlidBallTextures(ballPath);
	self.m_countSlider:loadProgressBarTexture(barPath);
	self.m_countSlider:setPercent(self.m_curComposeProp / self.m_itemUpgradeMaxCount * 100);
	self.m_countSlider:addEventListener(function(sender, eventType) self:moveSliderBallCallBack(sender, eventType); end);
	self.m_ccbNodeSlider:addChild(self.m_countSlider);
end

function CCBPackageUpgrade:setItemDetail()
	local itemID = self.m_itemUpgradeData.target_item_id;
	local itemName = ItemDataMgr:getItemNameByID(itemID);
	self.m_ccbLabelItemName:setString(itemName);
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	self.m_ccbLabelItemLevel:setString(Str[9015 + itemLevel]);
	--local itemCount = ItemDataMgr:getItemCount(itemID);
	self.m_ccbLabelItemCount:setString(self.m_curComposeProp);
	local itemUseLimit = ItemDataMgr:getItemUseLimitByID(itemID);
	self.m_ccbLabelItemUseLimit:setString(itemUseLimit);
	local itemBaseData = ItemDataMgr:getItemBaseInfo(itemID);
	self.m_ccbLabelItemCD:setString(itemBaseData.cd);
	self.m_ccbLabelItemDesc:setString(itemBaseData.desc);
end

function CCBPackageUpgrade:cleanNode()
	self.m_ccbNodeLeftIcon:removeAllChildren();
	self.m_ccbNodeRightIcon:removeAllChildren();
	self.m_ccbNodePropUpgradeBg:removeAllChildren();
end

function CCBPackageUpgrade:setLabelsChange()
	self.m_ccbNodeLeftIcon:getChildByTag(1):setString("/" .. self.m_curComposeProp * self.m_singleItemNeedCount);
	local labelSize = self.m_ccbNodeLeftIcon:getChildByTag(1):getContentSize();
	self.m_ccbNodeLeftIcon:getChildByTag(2):setPosition(cc.p(itemCountLabelPos.x - labelSize.width, itemCountLabelPos.y));
	self.m_ccbNodeRightIcon:getChildByTag(1):setString(self.m_curComposeProp);
	self.m_ccbLabelGoldCount:setString(self.m_singleItemNeedCoin * self.m_curComposeProp);

	self.m_ccbLabelItemCount:setString(self.m_curComposeProp);
end

function CCBPackageUpgrade:moveSliderBallCallBack(sender, eventType)
	local slider = sender;
	if eventType == ccui.SliderEventType.percentChanged then
		self.m_curComposeProp = math.floor(self.m_itemUpgradeMaxCount * slider:getPercent() * 0.01);
		if self.m_curComposeProp < 1 then
		-- 	print("   想要合成的数量  小于1  ")
			self.m_curComposeProp = 1;
			slider:setPercent(self.m_curComposeProp / self.m_itemUpgradeMaxCount * 100);
		end
		self:setLabelsChange();

	end
end

function CCBPackageUpgrade:updateItemLabelCount(count)
	self.m_ccbNodeLeftIcon:getChildByTag(2):setString(count);
	if count < self.m_singleItemNeedCount then
		self.m_ccbNodeLeftIcon:getChildByTag(2):setColor(redColor);
	else
		self.m_ccbNodeLeftIcon:getChildByTag(2):setColor(whiteColor);
	end
	local itemEnoughUpNum = math.floor(count / self.m_singleItemNeedCount);
	local coinEnoughUpNum = math.floor(UserDataMgr:getPlayerGoldCoin() / self.m_singleItemNeedCoin);
	if itemEnoughUpNum < coinEnoughUpNum then
		self.m_itemUpgradeMaxCount = itemEnoughUpNum;
	else
		self.m_itemUpgradeMaxCount = coinEnoughUpNum;
	end
	self.m_countSlider:setPercent(self.m_curComposeProp / self.m_itemUpgradeMaxCount * 100);
end

function CCBPackageUpgrade:getItemID()
	return self.m_itemID;
end

function CCBPackageUpgrade:onBtnSliderSub()
	if self.m_curComposeProp <= 1 then
		return;
	end
	self.m_curComposeProp = self.m_curComposeProp - 1;
	self:setLabelsChange();
	self.m_countSlider:setPercent(self.m_curComposeProp / self.m_itemUpgradeMaxCount * 100);
end

function CCBPackageUpgrade:onBtnSliderAdd()
	if self.m_curComposeProp >= self.m_itemUpgradeMaxCount then
		return;
	end
	self.m_curComposeProp = self.m_curComposeProp + 1;
	self:setLabelsChange();
	self.m_countSlider:setPercent(self.m_curComposeProp / self.m_itemUpgradeMaxCount * 100);
end

function CCBPackageUpgrade:onBtnUpgrade()
	local itemCount = ItemDataMgr:getItemCount(self.m_itemID);
	if itemCount < self.m_singleItemNeedCount and UserDataMgr:getPlayerGoldCoin() < self.m_singleItemNeedCoin then
		Tips:create(Str[9022]);
	elseif UserDataMgr:getPlayerGoldCoin() < self.m_singleItemNeedCoin then
		Tips:create(Str[9023]);
	elseif  itemCount < self.m_singleItemNeedCount then
		Tips:create(Str[9024]);
	else
		Network:request("game.itemsHandler.upgradeItem", {item_id = self.m_itemID, count = self.m_curComposeProp}, function (rc, data)
			print("请求道具升级")
			if data["code"] ~= 1 then
				Tips:create(Server[data.code]);
				return;
			end

			self:removeSelf();
		end)
	end
end

function CCBPackageUpgrade:onBtnClose()
	self:removeSelf();
end

return CCBPackageUpgrade;