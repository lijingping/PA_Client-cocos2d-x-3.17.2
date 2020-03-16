local ResourceMgr = require("app.utils.ResourceMgr")
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox")

local CCBProduceView2 = class("CCBProduceView2", function()
	return CCBLoader("ccbi/produceView/CCBProduceView2.ccbi")
end)

function CCBProduceView2:ctor()
	if display.resolution >= 2 then
		self:setScale(display.reduce);
	end
	self.m_curSelectIconIndex = -1;
	self.m_curSelectIcon = nil;
	self.m_lastSelectIcon = nil;
	self.m_canProduceMaxCount = 100000;
	self.m_isMoneyEnough = true;
	self.m_isMaterialEnough = true;

	self:createTouchEvent();

	self.m_tableShowList = ProduceDataMgr:getProduceFormulation();
	self:createTableView();
	self:createSlider();
end

function CCBProduceView2:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:registerScriptHandler(function (touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN);
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerTouch);
end

function CCBProduceView2:onTouchBegan(touch, event)
	self.m_touchPos = touch:getLocation();
	return true;
end

function CCBProduceView2:createTableView()
	local tableSize = self.m_ccbNodeItemView:getContentSize();
	self.m_tableView = cc.TableView:create(tableSize);
    self.m_tableView:setDelegate();
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
    self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.m_ccbNodeItemView:addChild(self.m_tableView);
    
    --注册响应函数
    self.m_tableView:registerScriptHandler(function(table, cell) self:tableCellTouched(table, cell); end, cc.TABLECELL_TOUCHED);
    self.m_tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx); end, cc.TABLECELL_SIZE_FOR_INDEX);
    self.m_tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx); end, cc.TABLECELL_SIZE_AT_INDEX);
    self.m_tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table); end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);
    self.m_tableView:reloadData();
end

function CCBProduceView2:tableCellTouched(table, cell)
	local touchCellPos = cell:convertToNodeSpace(self.m_touchPos);

	local item1 = cell:getChildByTag(1);
	local item2 = cell:getChildByTag(2);	
	if item1 and cc.rectContainsPoint(item1:getBoundingBox(), touchCellPos) then
		self.m_curSelectIcon = item1;
		self.m_curSelectIconIndex = cell:getIdx() * 2 + 1;
	elseif item2 and cc.rectContainsPoint(item2:getBoundingBox(), touchCellPos) then
		self.m_curSelectIcon = item2;
		if self.m_tableShowList[cell:getIdx()*2+2] then
			self.m_curSelectIconIndex = cell:getIdx() * 2 + 2;
		else
			return;
		end
	else
		return;
	end

	--显示和移除选中特效
	if self.m_curSelectIcon then
		ResourceMgr:setFormulationIconState(self.m_lastSelectIcon, false);		
		ResourceMgr:setFormulationIconState(self.m_curSelectIcon, true);	
		self.m_lastSelectIcon = self.m_curSelectIcon;
	end	

	self:showInfoByIconIndex(self.m_curSelectIconIndex);
end

function CCBProduceView2:cellSizeForTable(table, idx)
	return 220, 132;
end

function CCBProduceView2:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell();
	if cell == nil then
		cell = cc.TableViewCell:create();

		local item1 = ResourceMgr:createProduceFormulationIcon(self.m_tableShowList[2*idx+1]["$item_id"]);
		if item1 then
			item1:setPosition(cc.p(70, 65));
			cell:addChild(item1, 1, 1);
			if self.m_lastSelectIcon == nil then --创建界面后将第一个设为选中状态
				self.m_lastSelectIcon = item1;
				self.m_curSelectIcon = item1;
				self.m_curSelectIconIndex = 2 * idx + 1;
				ResourceMgr:setFormulationIconState(item1, true);
				self:showInfoByIconIndex(2 * idx + 1);
			end
		end
		if self.m_tableShowList[2*idx+2] then
			local item2 = ResourceMgr:createProduceFormulationIcon(self.m_tableShowList[2*idx+2]["$item_id"]);
			if item2 then
				item2:setPosition(cc.p(200, 65));	
				cell:addChild(item2, 2, 2);
			end
		end
	else
		local item1 = cell:getChildByTag(1)
		ResourceMgr:changeProduceFormulationIcon(item1, self.m_tableShowList[2*idx+1]["$item_id"]);
		if self.m_curSelectIconIndex == 2 * idx + 1 then
			ResourceMgr:setFormulationIconState(item1, true);
		else
			ResourceMgr:setFormulationIconState(item1, false);
		end

		local item2 = cell:getChildByTag(2);
		if self.m_tableShowList[2*idx+2] then
			ResourceMgr:changeProduceFormulationIcon(item2, self.m_tableShowList[2*idx+2]["$item_id"]);	
			if self.m_curSelectIconIndex == 2 * idx + 2 then
				ResourceMgr:setFormulationIconState(item2, true);
			else
				ResourceMgr:setFormulationIconState(item2, false);
			end
			item2:setVisible(true);
		else
			item2:setVisible(false);
		end
	end

	return cell;
end

function CCBProduceView2:numberOfCellsInTableView(table)
	return math.ceil(#ProduceDataMgr:getProduceFormulation()/2);
end

function CCBProduceView2:showInfoByIconIndex(iconIndex)
	--道具描述
	local itemID = self.m_tableShowList[iconIndex]["$item_id"];
	local itemBaseInfo = ItemDataMgr:getItemBaseInfo(itemID)
	local itemLevel = itemBaseInfo.level;
	local qualityColor = {CCC3_TEXT_GREEN, CCC3_TEXT_BLUE, CCC3_TEXT_PURPLE};
	local qualityText = {Str[20005], Str[20006], Str[20007]};
	self.m_ccbLabelInfoName:setColor(qualityColor[itemLevel]):setString(itemBaseInfo.name);
	self.m_ccbLabelItemName:setColor(qualityColor[itemLevel]):setString(itemBaseInfo.name);

	self.m_ccbLabelInfoLevel:setString(qualityText[itemLevel]);
	self.m_ccbLabelInfoCount:setString(ItemDataMgr:getItemCount(itemID));
	self.m_ccbLabelInfoUseTimes:setString(itemBaseInfo.use_limit..Str[20008]);
	self.m_ccbLabelInfoCooldown:setString(itemBaseInfo.cd ..Str[20009]);
	self.m_ccbLabelInfoDesc:setString(itemBaseInfo.desc);
	self.m_ccbNodeSlotsPorduceIcon:addChild(ResourceMgr:getSlotsIconWithScale(itemID));

	--生产材料的显示
	local requireItemList = self.m_tableShowList[iconIndex].required_items;
	self.m_canProduceMaxCount = 100000;
	self.m_isMaterialEnough = true;
	local scale = 0.8;
	for i = 1, 4 do
		local nodeSlots = self.m_ccbNodeSlots:getChildByTag(i)
		if nodeSlots then
			local slotsIcon = ResourceMgr:getSlotsIconWithScale(requireItemList[i].item_id, scale);
			nodeSlots:addChild(slotsIcon, -1);
			--拥有的数量
			local haveCount = ItemDataMgr:getItemCount(requireItemList[i].item_id);
			local needCount = requireItemList[i].count;
			nodeSlots:getChildByTag(11):setString(haveCount .. "/");
			--生产的数量，初始为1
			local needCountNode = nodeSlots:getChildByTag(12):setString(needCount);
			--计算生产材料数量是否足够生产
			local canProduceCount = math.floor(haveCount / needCount);
			if canProduceCount < self.m_canProduceMaxCount then
				self.m_canProduceMaxCount = canProduceCount;
			end
			if canProduceCount == 0 then
				self.m_isMaterialEnough = false;
				needCountNode:setColor(cc.RED);
			else
				needCountNode:setColor(cc.WHITE);
			end

			local countBg = cc.Sprite:create(ResourceMgr:getItemCountBg())
			countBg:setAnchorPoint(cc.p(1, 0));

			local spriteIconFrame = slotsIcon:getChildByTag(ICON_TAG_FRAME);
			local pos = cc.p(spriteIconFrame:getPositionX(), spriteIconFrame:getPositionY());
			pos.x = pos.x + spriteIconFrame:getContentSize().width*(1-spriteIconFrame:getAnchorPoint().x)*scale;
			pos.y = pos.y + spriteIconFrame:getContentSize().height*(0-spriteIconFrame:getAnchorPoint().y)*scale;
			countBg:setScale(scale):setPosition(pos.x, pos.y);
			slotsIcon:addChild(countBg, ICON_Z_ORDER_COUNT_BG, ICON_TAG_COUNT_BG);
		end
	end
	--计算金币是否足够生产
	local canProduceCount2 = math.floor(UserDataMgr:getPlayerGoldCoin() / requireItemList[5].count)
	if canProduceCount2 < self.m_canProduceMaxCount then
		self.m_canProduceMaxCount = canProduceCount2;
	end
	if canProduceCount2 == 0 then
		self.m_isMoneyEnough = false;
		self.m_ccbLabelCostMoney:setColor(cc.RED);
	else
		self.m_isMoneyEnough = true;
		self.m_ccbLabelCostMoney:setColor(cc.WHITE);
	end

	--最大生产数量最少为1，不显示0，道具不足则显示提示框
	if self.m_canProduceMaxCount == 0 then
		self.m_canProduceMaxCount = 1;
	end

	self.m_ccbLabelCostMoney:setString(requireItemList[5].count);
	self.m_ccbLabelCostTime:setString(self:showTimeFormat(self.m_tableShowList[iconIndex].time));
	self.m_ccbLabelSilderPercent:setString(Str[10013] .. "：".. 1);
	if self.m_produceCountSlider then
		self.m_produceCountSlider:setMaxPercent(self.m_canProduceMaxCount);		
		self.m_produceCountSlider:setPercent(1);
	end

	self.m_ccbSpriteCanProduce:setVisible(self.m_isMaterialEnough == true and self.m_isMoneyEnough == true)
	self.m_ccbSpriteNoCanProduce:setVisible(not self.m_ccbSpriteCanProduce:isVisible())
end

function CCBProduceView2:createSlider()
    self.m_produceCountSlider = ccui.Slider:create()
    
    self.m_produceCountSlider:setScale9Enabled(true)
    self.m_produceCountSlider:setTouchEnabled(true)

    self.m_produceCountSlider:setContentSize(self.m_ccbNodeSlider:getContentSize());
    self.m_produceCountSlider:setAnchorPoint(0, 0);
    self.m_produceCountSlider:loadBarTexture(ResourceMgr:getSliderBarBg());
    self.m_produceCountSlider:loadProgressBarTexture(ResourceMgr:getSliderBar());
    self.m_produceCountSlider:loadSlidBallTextures(ResourceMgr:getSliderBall(), ResourceMgr:getSliderBall(), ResourceMgr:getSliderBall());

	self.m_produceCountSlider:setPercent(1);
	self.m_produceCountSlider:setMaxPercent(self.m_canProduceMaxCount);

	local function changeEvent(pSender, eventType)
		if eventType == ccui.SliderEventType.percentChanged then
			local percent = pSender:getPercent();
			if percent < 1 then
				percent = 1;
			end
			self:changeProduceCount(percent);
		end
	end
    self.m_produceCountSlider:addEventListener(changeEvent);
    self.m_ccbNodeSlider:addChild(self.m_produceCountSlider);
end

function CCBProduceView2:changeProduceCount(curCount)
	for i = 1, 4 do
		local nodeSlots = self.m_ccbNodeSlots:getChildByTag(i);
		nodeSlots:getChildByTag(12):setString(self.m_tableShowList[self.m_curSelectIconIndex].required_items[i].count * curCount);
	end

	self.m_produceCountSlider:setPercent(curCount);
	self.m_ccbLabelCostMoney:setString(self.m_tableShowList[self.m_curSelectIconIndex].required_items[5].count * curCount);
	self.m_ccbLabelCostTime:setString(self:showTimeFormat(self.m_tableShowList[self.m_curSelectIconIndex].time * curCount));
	self.m_ccbLabelSilderPercent:setString(Str[10013] .. "：".. curCount);	
end

function CCBProduceView2:onBtnSliderDown()
	local curProduceCount = self.m_produceCountSlider:getPercent();
	curProduceCount = curProduceCount - 1;
	if curProduceCount < 1 then
		curProduceCount = 1;
	end
	self:changeProduceCount(curProduceCount);
end

function CCBProduceView2:onBtnSliderUp()
	local curProduceCount = self.m_produceCountSlider:getPercent();
	curProduceCount = curProduceCount + 1;
	if curProduceCount > self.m_canProduceMaxCount then
		curProduceCount = self.m_canProduceMaxCount;
	end
	self:changeProduceCount(curProduceCount);
end

function CCBProduceView2:showTimeFormat(time)
	local hour = math.floor(time / 3600);
	local minute = math.floor((time % 3600) / 60);
	local second = time % 60;
	return string.format("%02d:%02d:%02d", hour, minute, second);
end

function CCBProduceView2:onBtnProduce()
	if self.m_isMoneyEnough == false then
		local ccbMessageBox = CCBMessageBox:create(Str[3004], Str[4051], MB_OKCANCEL);
		ccbMessageBox.onBtnOK = function ()
			App:enterScene("ShopScene");
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end

	elseif self.m_isMaterialEnough == false then
		local ccbMessageBox = CCBMessageBox:create(Str[3004], Str[4052], MB_OK);
		ccbMessageBox.onBtnOK = function ()
			ccbMessageBox:removeSelf();
		end
	else
		local itemID = self.m_tableShowList[self.m_curSelectIconIndex]["$item_id"];
		local produceCount = self.m_produceCountSlider:getPercent();

		Network:request("game.itemsHandler.produceItem", {item_id = itemID, count = produceCount, queue_id = ProduceDataMgr:getCurProducePos() - 1}, function(rc, receiveData)
			if receiveData.code ~= 1 then
				print("server error code", receiveData.code)
				return;
			end
			App:enterScene("ProduceScene1")
		end);
	end
end



return CCBProduceView2