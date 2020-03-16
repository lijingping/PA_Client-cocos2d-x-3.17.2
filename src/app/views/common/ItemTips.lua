local ResourcesMgr = require("app.utils.ResourceMgr");


local ItemTips = class("ItemTips", cc.Node)

local itemTempList = { {item_id = 10001, count = 5000, delta = 55}, 
						{item_id = 1002, count = 32, delta = 55}, 
						{item_id = 1003, count = 12, delta = 55},
						{item_id = 1005, count = 32, delta = 55}, 
						{item_id = 2003, count = 55, delta = 55},
						{item_id = 4005, count = 66, delta = 55}, 

						-- {item_id = 2009, count = 54, delta = 55},
						-- {item_id = 3002, count = 64, delta = 55}, 
						-- {item_id = 3003, count = 67, delta = 55},
						-- {item_id = 4001, count = 74, delta = 55},
						{item_id = 4002, count = 44, delta = 55}, 
						{item_id = 4003, count = 35, delta = 55},

						{item_id = 3005, count = 99, delta = 55}, 
						{item_id = 2005, count = 11, delta = 55}
					}

function ItemTips:ctor(itemList)
	print("创建物品提示框");
	if display.resolution >= 2 then
		self:setScale(display.reduce);
	end
	print("    .............   物品提示框")
	self.m_showList = nil;
	self.m_isCanShowNext = false;
	self.m_layerGray = nil;
	self.m_showPage = 1;
	self.m_isCanRemove = false;
	if itemList == nil then
		--print("无物品列表");
		-- self.m_showList = itemTempList;
		return; 
	else
		self.m_showList = itemList;
	end

	for i = 1, #self.m_showList do
		if self.m_showList[i].delta < 0 then --增量为负数，为扣除物品，此时不显示物品提示框
			return;
		end
	end

	self:addTo(App:getRunningScene(), display.Z_ITEM_TIPS, TAG_ITEM_TIPS);
	self:setPosition(display.cx, display.cy);

	self:createTouchEvent();--添加触摸事件，并屏蔽其他界面

	local isShowPrizes = false;
	if App:getRunningSceneName() == "LotteryScene" then
		if App:getRunningScene():getViewBase().m_lotteryView:getIsRequest() then
			isShowPrizes = true;
			if #itemList == 10 then --抽奖界面，获得物品等于10个时播放，十连抽动画
				
				for k, v in ipairs(self.m_showList) do
					v.sort = math.random(1, 1000);
					v.sort = math.random(1, 1000);
				end
				table.sort(self.m_showList, function (a, b) return a.sort < b.sort; end);
			end
		end
	end	
	local delayTime = 0.5;
	if App:getRunningSceneName() == "MainScene" then
		if UserDataMgr:isExploring() == true then
			self:setVisible(false)
		end
	end

	if isShowPrizes == true then
		self:showPrizes();
	else
		local function delayTimeActionCallBack()
			self:showDialog();
		end
		self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(delayTimeActionCallBack)));
	end
end

--显示十连动画
function ItemTips:showPrizes()
	-- print("显示十连动画");
	App:getRunningScene():getViewBase().m_lotteryView:setRequestOver();

	self.m_layerGray = cc.LayerColor:create(cc.c4b(0, 0, 0, 180), 1580, 960);
	self.m_layerGray:setAnchorPoint(cc.p(0.5, 0.5));
	self.m_layerGray:ignoreAnchorPointForPosition(false);
	self:addChild(self.m_layerGray);

	--加载宝箱动画
	local armatureTreasure = ResourcesMgr:getAnimArmatureShowTreasure();
	self:addChild(armatureTreasure);
	if App:getRunningScene():getViewBase().m_isNormal == true then
		print("普通抽")
		armatureTreasure:getAnimation():play("box1");
	else
		print("特殊抽")
		armatureTreasure:getAnimation():play("box2");
		-- armatureTreasure:getAnimation():setSpeedScale(2); 动画倍数
	end

	
	armatureTreasure:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			if #self.m_showList > 1 then
				self:showPrizesItem();
			else
				self:showOneItem();
			end
		end
	end)
	--self:createConfirmButton();
end

function ItemTips:createConfirmButton()
	local backgroundButton = cc.Scale9Sprite:create("res/resources/mainView/ui_main_name2.png");  
	local labelButton = cc.Label:createWithSystemFont("", "", 30);
	self.m_confirmButton = cc.ControlButton:create(labelButton, backgroundButton); 
	self.m_confirmButton:setPreferredSize(cc.size(189, 66));
	self.m_confirmButton:setPosition(cc.p(0, -250));
	self.m_confirmButton:registerControlEventHandler(function() self:showDialog();	end, cc.CONTROL_EVENTTYPE_TOUCH_DOWN);

    self:addChild(self.m_confirmButton);
end

function ItemTips:showPrizesItem()
	--print("显示物品");
	local showIndex = 1;
	local posX = 0;
	local posY = 0;
	self.m_nodePrizeIcons = cc.Node:create();
	self:addChild(self.m_nodePrizeIcons);
	for i = 1, 10 do
		local item = self:getItemIconByID(self.m_showList[i].item_id, self.m_showList[i].delta);
		self.m_nodePrizeIcons:addChild(item);
		local posX = (math.floor(( i-(math.ceil(i/5)-1)*5 ) %6)-3)*180;
		local posY = 300 - math.ceil(i/5) * 180;
		item:setPosition(cc.p(posX, posY));
		item:setTag(i);
		item:setVisible(false);
	end

	local delayTime = 0;
	local intervalTime = 0.5;

	local function actionCallBack(node, value)
		local itemID = self.m_showList[value[1]].item_id;
		local a, b = math.modf(itemID / 1000);
		local armatureLight = nil;
		local armatureEffectCircle = nil;
		if a == 3 and itemID ~= 3901 and itemID ~= 3902 or itemID == 4001 or itemID == 4002 or itemID == 4003 or itemID == 4004 then
			armatureLight = ResourcesMgr:getAnimArmatureShowYellowLight();
			armatureEffectCircle = ResourcesMgr:getAnimArmatureShowEffectCircle();
			self.m_nodePrizeIcons:addChild(armatureEffectCircle, 50, 50);
			armatureEffectCircle:setVisible(false);
		else
			armatureLight = ResourcesMgr:getAnimArmatureShowWhiteLight();
		end
		self.m_nodePrizeIcons:addChild(armatureLight, 100, 100);
		armatureLight:getAnimation():play("anim01");
		local posX = (math.floor(( value[1]-(math.ceil(value[1]/5)-1)*5 ) %6)-3)*180;
		local posY = 300-math.ceil(value[1]/5)*180;
		armatureLight:setPosition(cc.p(posX, posY));
		-- armatureLight:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID) 
		-- 	if movementType == ccs.MovementEventType.complete then
		-- 	end
		-- end)
		armatureLight:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
			if evt == "show" then
				self.m_nodePrizeIcons:getChildByTag(value[1]):setVisible(true);
				if armatureEffectCircle then
					armatureEffectCircle:setScale(0.85);
					armatureEffectCircle:setVisible(true);
					armatureEffectCircle:getAnimation():play("anim01");
					armatureEffectCircle:setPosition(cc.p(posX, posY));
				end
			end
		end)
	end
	for i = 1, 10 do
		local sequence = cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(actionCallBack, {i}));
		self:runAction(sequence);
		delayTime = intervalTime * i;
	end
	local sequence = cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(function () self:createConfirmButton(); end));				
	self:runAction(sequence);
end

function ItemTips:showOneItem()
	local delayTime = 0.5;
	self.m_nodePrizeIcons = cc.Node:create();
	self:addChild(self.m_nodePrizeIcons);
	local item = self:getItemIconByID(self.m_showList[1].item_id, self.m_showList[1].delta);
	self.m_nodePrizeIcons:addChild(item);
	item:setVisible(false);
	local itemID = self.m_showList[1].item_id;
	local a, b = math.modf(itemID / 1000);
	local armatureLight = nil;
	local armatureEffectCircle = nil;
	if a == 3 and itemID ~= 3901 and itemID ~= 3902 or itemID == 4001 or itemID == 4002 or itemID == 4003 or itemID == 4004 then
		armatureLight = ResourcesMgr:getAnimArmatureShowYellowLight();
		armatureEffectCircle = ResourcesMgr:getAnimArmatureShowEffectCircle();
		self.m_nodePrizeIcons:addChild(armatureEffectCircle, 50, 50);
		armatureEffectCircle:setVisible(false);
	else
		armatureLight = ResourcesMgr:getAnimArmatureShowWhiteLight();
	end
	self.m_nodePrizeIcons:addChild(armatureLight, 100, 100);
	armatureLight:getAnimation():play("anim01");
	-- armatureLight:setPosition(cc.p(posX, posY));
	armatureLight:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
		if evt == "show" then
			item:setVisible(true);
			if armatureEffectCircle then
				armatureEffectCircle:setScale(0.85);
				armatureEffectCircle:setVisible(true);
				armatureEffectCircle:getAnimation():play("anim01");
				-- armatureEffectCircle:setPosition(cc.p(posX, posY));
			end
		end
	end)
	local sequence = cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(function () self:createConfirmButton(); end));				
	self:runAction(sequence);
end

function ItemTips:clearPrizes()
	if self.m_nodePrizeIcons then
		self.m_nodePrizeIcons:removeAllChildren();
		self.m_nodePrizeIcons:removeSelf();
		self.m_nodePrizeIcons = nil;
	end

	if self.m_confirmButton then
		self.m_confirmButton:removeSelf();
	end
end

--显示获得物品
function ItemTips:showDialog()
	-- print("显示获得物品");
	self:clearPrizes();
	self:stopAllActions();

	if self.m_layerGray == nil then
		self.m_layerGray = cc.LayerColor:create(cc.c4b(0, 0, 0, 150), 1580, 960);
		self.m_layerGray:setAnchorPoint(cc.p(0.5, 0.5));
		self.m_layerGray:ignoreAnchorPointForPosition(false);
		self:addChild(self.m_layerGray);
	end

	local spritetitle = cc.Sprite:create("res/resources/common/tip_item_tittle.png");
	spritetitle:setPosition(cc.p(0, 165));
	self:addChild(spritetitle);

	local spriteBg = cc.Sprite:create("res/resources/common/tip_item_bg.png");
	spriteBg:setScaleX(1.4);
	self:addChild(spriteBg);

	self.m_nodeIcons = cc.Node:create();
	self:addChild(self.m_nodeIcons);

	self:showItems();
end

function ItemTips:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)--设为true,不向下传递触摸时间
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED )

    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function ItemTips:onTouchBegan(touch, event)
	if self.m_isCanShowNext == true then
		self.m_isCanShowNext = false;
		if self.m_showPage == math.ceil(#self.m_showList / 6) then
			self.m_isCanRemove = true;
		else
			self:showNext();
		end
	end

	--print("touch began")
	return true;
end

function ItemTips:onTouchMoved(touch, event)
	
end

function ItemTips:onTouchEnded(touch, event)
	-- body
	if self.m_isCanRemove == true then
		self:removeSelf();
	end
end

function ItemTips:getItemIconByID(itemID, count)
	local node = cc.Node:create();
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);	
	--print("物品id,icon,level:", itemID, iconID, itemLevel);

	local spriteIconBg = cc.Sprite:create("res/resources/common/item_bg_"..(itemLevel+1)..".png");
	local spriteIcon = cc.Sprite:create("res/itemIcon/"..iconID..".png");
	local spriteIconFrame = cc.Sprite:create("res/resources/common/item_frame_"..(itemLevel+1)..".png");

	local labelIconName = cc.LabelTTF:create(ItemDataMgr:getItemNameByID(itemID), "", 20);
	labelIconName:setPosition(cc.p(0, -75));

	local labelIconNum = cc.LabelTTF:create(count, "", 20);
	labelIconNum:setPosition(cc.p(45, -50));
	labelIconNum:setAnchorPoint(cc.p(1, 0));

	if spriteIcon == nil then 
		print("无此物品icon", itemID);
		spriteIcon = cc.Sprite:create("res/itemIcon/99999.png");
	end
	node:addChild(spriteIconBg, 1, 1);
	node:addChild(spriteIcon, 2, 2);
	node:addChild(spriteIconFrame, 3, 3);
	node:addChild(labelIconName, 4, 4);
	node:addChild(labelIconNum, 5, 5);

	return node;
end

function ItemTips:showItems()
	self:addItemIcon();

	local delayTime = 0;
	local curShowNum = 6;
	local intervalTime = 0.2; --显示间隔时间
	local fadeinTime = 0.4; --淡入时间

	local function actionCallBack(node, value)
		--print("显示物品，item_id:", self.m_showList[(self.m_showPage - 1) * 6 + value[1]].item_id);		
		local nodeIcon = self.m_nodeIcons:getChildByTag(value[1] * self.m_showPage);
		if nodeIcon then
			nodeIcon:setVisible(true);
			nodeIcon:getChildByTag(1):setOpacity(0);
			local action1 = cc.FadeIn:create(fadeinTime);
			nodeIcon:getChildByTag(1):runAction(action1);

			nodeIcon:getChildByTag(2):setOpacity(0);
			local action2 = cc.FadeIn:create(fadeinTime);
			nodeIcon:getChildByTag(2):runAction(action2);

			nodeIcon:getChildByTag(3):setOpacity(0);
			local action3 = cc.FadeIn:create(fadeinTime);
			nodeIcon:getChildByTag(3):runAction(action3);

			nodeIcon:getChildByTag(4):setOpacity(0);
			local action4 = cc.FadeIn:create(fadeinTime);
			nodeIcon:getChildByTag(4):runAction(action4);

			nodeIcon:getChildByTag(5):setOpacity(0);
			local action5 = cc.FadeIn:create(fadeinTime);
			nodeIcon:getChildByTag(5):runAction(action5);
		end
	end

	--print("当前显示 ", #self.m_showList - (self.m_showPage-1) * 6," 个物品");
	if #self.m_showList - (self.m_showPage-1) * 6 < 6 then
		curShowNum = #self.m_showList - (self.m_showPage-1) * 6;
	end
	for i = 1, curShowNum do
		local sequence = cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(actionCallBack, {i}));
		self:runAction(sequence);
		delayTime = intervalTime*i;
	end
	if self.m_isCanShowNext == false then
		--print("显示下一次物品时间间隔", delayTime);
		local sequence = cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(function () 
			if UserDataMgr:isExploring() == false then
				self.m_isCanShowNext = true;
			end
		end));				
		self:runAction(sequence);
	end	
end

function ItemTips:showNext()
	self:stopAllActions();
	self.m_showPage = self.m_showPage + 1;
	self.m_nodeIcons:removeAllChildren();
	self:showItems();
end

function ItemTips:addItemIcon()
	local parentNodePosX = 0;
	for i = 1, 6 do
		local info = self.m_showList[(self.m_showPage - 1) * 6 + i];		
		if info then
			--print("当前显示物品id:", info.item_id);
			local nodeIcon = self:getItemIconByID(info.item_id, info.delta);
			nodeIcon:setVisible(false);
			local x = 150 * i;
			parentNodePosX = 150*(i+1);
			nodeIcon:setPosition(cc.p(x, 0));
			nodeIcon:setTag(self.m_showPage*i);
			self.m_nodeIcons:addChild(nodeIcon);
		end
	end
	self.m_nodeIcons:setPosition(-parentNodePosX/2, 0);
end

function ItemTips:setShowNext(isCanShowNext)
	self.m_isCanShowNext = isCanShowNext;
end


return ItemTips;