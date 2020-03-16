local ResourceMgr = require("app.utils.ResourceMgr");
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");
local Tips = require("app.views.common.Tips");
local itemTips = require("app.views.common.ItemTips");

local table_insert = table.insert;
local table_sort = table.sort;
local table_remove = table.remove;
local SHOW_TAB_1 = 1;
local SHOW_TAB_2 = 2;
local SHOW_TAB_3 = 3;
local SHOW_TAB_MAX = 3;

local RESOLVE_POINT_ITEM_ID = 10008;

local CCBDecomposeView = class("CCBDecomposeView", function()
	return CCBLoader("ccbi/decomposeView/CCBDecomposeView.ccbi")
end)

function CCBDecomposeView:ctor()
	if display.resolution >= 2 then
        self:setScale(display.reduce);
    end
	self.m_curSelectIconIndex = -1;
	self.m_lastSelectIcon = nil;

	self.m_nDecomposeMaxCount = 1;
	self.m_nResolveCost = 1;
	self.m_nResolvePoint = 1;

	self.m_ccbLabelDesc.copyPosy = self.m_ccbLabelDesc:getPositionY();
	self.m_ccbLabelInfoDesc.copyPosy = self.m_ccbLabelInfoDesc:getPositionY();

	self:createTouchEvent();

	self.m_showList = {};
	self.m_btnSlot = {}
	for i=1,SHOW_TAB_MAX do
		self.m_showList[i] = {};
		self.m_btnSlot[i] = self.m_ccbNodeSlot:getChildByTag(i)
	end

	self:filterShowList();

	self:createSlider();

	self.m_showSlotIndex = 1;
	self:createTableView();
	self:onBtnSlot(self.m_showSlotIndex);

	--self:flushSelectedItemSlot();

	self.m_ccbNodeProduceIcon:addChild(self:getDecomposeItemIconWithScale(RESOLVE_POINT_ITEM_ID, 0.8));
end

function CCBDecomposeView:getDecomposeItemIconWithScale(itemID, rate)
	local node = cc.Node:create();
	
	local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);

	local itemLevel = 1;
	cc.Sprite:create(ResourceMgr:getItemBGByQuality(itemLevel)):addTo(node);
	cc.Sprite:create(ResourceMgr:getItemIconByID(iconID)):addTo(node);
	cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(itemLevel)):addTo(node);

	node:setScale(rate);

	return node;
end

function CCBDecomposeView:filterShowList()
	local allItems = ItemDataMgr:getAllItems();
	for k, v in pairs(allItems) do
		local itemInfo = clone(ItemDataMgr:getItemBaseInfo(k));
		itemInfo.count = clone(v.count);
		if itemInfo.type == 1 then
			table_insert(self.m_showList[SHOW_TAB_1], itemInfo);
		elseif itemInfo.type == 2 then
			table_insert(self.m_showList[SHOW_TAB_2], itemInfo);
		elseif itemInfo.type == 3 or itemInfo.type == 4 or itemInfo.type == 5 then
			table_insert(self.m_showList[SHOW_TAB_3], itemInfo);
		end
	end

	for i = 1, SHOW_TAB_MAX do
		table_sort(self.m_showList[i], function (info1, info2)
			return info1.id < info2.id;
		end);
	end
end

function CCBDecomposeView:flushItemViewTipVisible()
	local isHave = #self.m_showList[self.m_showSlotIndex] > 0;
	self.m_ccbLabelItemViewTip:setVisible(not isHave);
end

function CCBDecomposeView:onBtnSlot(index)
	self.m_btnSlot[self.m_showSlotIndex]:setEnabled(true);
	self.m_btnSlot[index]:setEnabled(false);

	self.m_showSlotIndex = index;
	self:flushItemViewTipVisible();

	self.m_lastSelectIcon = nil;
	self.m_tableView:reloadData();

	self.m_ccbSpriteSlotArrow:setPositionY(self.m_btnSlot[index]:getPositionY());

	if #self.m_showList[self.m_showSlotIndex] <= 0 then
		self:flushSelectedItemSlot();
	else
		self.m_ccbSpriteLight:setVisible(true);
	end
end

function CCBDecomposeView:onBtnSlot1()
	self:onBtnSlot(1)
end

function CCBDecomposeView:onBtnSlot2()
	self:onBtnSlot(2)
end

function CCBDecomposeView:onBtnSlot3()
	self:onBtnSlot(3)
end

function CCBDecomposeView:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:registerScriptHandler(function (touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN);
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerTouch);
end

function CCBDecomposeView:onTouchBegan(touch, event)
	self.m_touchPos = touch:getLocation();
	return true;
end

function CCBDecomposeView:createTableView()
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

function CCBDecomposeView:tableCellTouched(table, cell)
	local touchCellPos = cell:convertToNodeSpace(self.m_touchPos);

	local item1 = cell:getChildByTag(1);
	local item2 = cell:getChildByTag(2);
	local curSelectIcon = nil;	
	if item1 and cc.rectContainsPoint(item1:getBoundingBox(), touchCellPos) then
		curSelectIcon = item1;
		self.m_curSelectIconIndex = cell:getIdx() * 2 + 1;
	elseif item2 and cc.rectContainsPoint(item2:getBoundingBox(), touchCellPos) then
		curSelectIcon = item2;
		if self.m_showList[self.m_showSlotIndex][cell:getIdx()*2+2] then
			self.m_curSelectIconIndex = cell:getIdx() * 2 + 2;
		else
			return;
		end
	else
		return;
	end

	--显示和移除选中特效
	ResourceMgr:setFormulationIconState(self.m_lastSelectIcon, false);
	ResourceMgr:setFormulationIconState(curSelectIcon, true);	
	self.m_lastSelectIcon = curSelectIcon;

	if self.m_curSelectIconIndex then
		self:showInfoByIconIndex(self.m_curSelectIconIndex);
	end
end

function CCBDecomposeView:cellSizeForTable(table, idx)
	return 220, 132;
end

function CCBDecomposeView:tableCellAtIndex(table, idx)
	local data = self.m_showList[self.m_showSlotIndex]
	local cell = table:dequeueCell();
	local data1 = data[2*idx+1];
	local data2 = data[2*idx+2];
	if cell == nil then
		cell = cc.TableViewCell:create();
		local item1 = ResourceMgr:createDecompseFormulationIcon(data1.id, data1.count);
		if item1 then
			item1:setPosition(cc.p(70, 65));
			cell:addChild(item1, 1, 1);

			if self.m_lastSelectIcon == nil then --创建界面后将第一个设为选中状态
				self.m_lastSelectIcon = item1;
				self.m_curSelectIconIndex = 2 * idx + 1;
				ResourceMgr:setFormulationIconState(item1, true);
				self:showInfoByIconIndex(2 * idx + 1);
			end
		end

		local item2 = ResourceMgr:createDecompseFormulationIcon(data2 and data2.id or data1.id, data2 and data2.count or data1.count);
		if item2 then
			item2:setPosition(cc.p(200, 65));
			item2:setVisible(data2 ~= nil);
			cell:addChild(item2, 2, 2);
		end
	else
		local item1 = cell:getChildByTag(1);
		if item1 then
			ResourceMgr:changeDecompseFormulationIcon(item1, data1.id, data1.count);

			if self.m_lastSelectIcon == nil then --将第一个设为选中状态
				self.m_lastSelectIcon = item1;
				self.m_curSelectIconIndex = 2 * idx + 1;
				ResourceMgr:setFormulationIconState(item1, true);
				self:showInfoByIconIndex(2 * idx + 1);
			else
				ResourceMgr:setFormulationIconState(item1, (self.m_curSelectIconIndex == 2 * idx + 1));
			end
		end

		local item2 = cell:getChildByTag(2);
		if item2 then
			if data2 then
				ResourceMgr:changeDecompseFormulationIcon(item2, data2.id, data2.count);	
				ResourceMgr:setFormulationIconState(item2, (self.m_curSelectIconIndex == 2 * idx + 2));

				item2:setVisible(true);
			else
				item2:setVisible(false); 
			end
		end
	end

	return cell;
end

function CCBDecomposeView:numberOfCellsInTableView(table)
	return math.ceil(#self.m_showList[self.m_showSlotIndex]/2);
end

function CCBDecomposeView:showInfoByIconIndex(iconIndex)
	--道具描述
	local data = self.m_showList[self.m_showSlotIndex][iconIndex];
	local itemID = data.id;
	local itemBaseInfo = ItemDataMgr:getItemBaseInfo(itemID)
	local itemLevel = itemBaseInfo.level;
	local qualityColor = {CCC3_TEXT_GREEN, CCC3_TEXT_BLUE, CCC3_TEXT_PURPLE, CCC3_TEXT_GOLDEN};
	local qualityText = {Str[20005], Str[20006], Str[20007]};
	self.m_ccbLabelInfoName:setColor(qualityColor[itemLevel]);
	self.m_ccbLabelInfoName:setString(itemBaseInfo.name);
	self.m_ccbLabelInfoLevel:setString(qualityText[itemLevel]);
	self.m_ccbLabelInfoCount:setString(data.count);
	self.m_ccbLabelInfoUseTimes:setString(itemBaseInfo.use_limit..Str[20008]);
	self.m_ccbLabelInfoCooldown:setString(itemBaseInfo.cd ..Str[20009]);
	self.m_ccbLabelInfoDesc:setString(itemBaseInfo.desc);
	self.m_ccbNodeItemIcon:addChild(ResourceMgr:getDecompseSlotsIconWithScale(itemID));

	self.m_ccbNodeItemInfo:setVisible(true);

	self.m_nResolvePoint = itemBaseInfo.resolve_point;
	self.m_nResolveCost = itemBaseInfo.resolve_cost;
	self.m_nDecomposeMaxCount = math.floor(UserDataMgr:getPlayerGoldCoin()/itemBaseInfo.resolve_cost);
	self.m_ccbLabelCostMoney:setColor(self.m_nDecomposeMaxCount <= 0 and cc.RED or cc.WHITE);
	if self.m_nDecomposeMaxCount <= 0 then
		self.m_nDecomposeMaxCount = 1;
	end

	if self.m_nDecomposeMaxCount > data.count then
		self.m_nDecomposeMaxCount = data.count;
	end
	self.m_countSlider:setMaxPercent(self.m_nDecomposeMaxCount):setTouchEnabled(true);
	self:changeDecomposeCount(1);

	self.m_ccbSpriteLight:setVisible(true);

	local isBattle = (self.m_showSlotIndex == SHOW_TAB_1);
	if isBattle then
		self.m_ccbLabelDesc:setPositionY(self.m_ccbLabelDesc.copyPosy);
		self.m_ccbLabelInfoDesc:setPositionY(self.m_ccbLabelInfoDesc.copyPosy);
	else		
		self.m_ccbLabelDesc:setPositionY(self.m_ccbLabelInfoCount:getPositionY()-52);
		self.m_ccbLabelInfoDesc:setPositionY(self.m_ccbLabelDesc:getPositionY()-28);
	end
	self.m_ccbLabelUseTimes:setVisible(isBattle);
	self.m_ccbLabelCooldown:setVisible(isBattle);
	self.m_ccbLabelInfoUseTimes:setVisible(isBattle);
	self.m_ccbLabelInfoCooldown:setVisible(isBattle);
end

function CCBDecomposeView:flushSelectedItemSlot()
	self.m_ccbNodeItemIcon:removeAllChildren();
	self.m_ccbNodeItemInfo:setVisible(false);

	self.m_nDecomposeMaxCount = 1;
	self.m_countSlider:setMaxPercent(self.m_nDecomposeMaxCount)

	ResourceMgr:setFormulationIconState(self.m_lastSelectIcon, false);
	self.m_curSelectIconIndex = -1;

	self.m_countSlider:setPercent(0):setTouchEnabled(false);
	self.m_ccbLabelItemCount:setString("");
	self.m_ccbLabelCostMoney:setString(0);
	self.m_ccbLabelResolvePoint:setString(0);

	self.m_ccbLabelCostMoney:setColor(cc.WHITE);
	self.m_ccbSpriteLight:setVisible(false);
end

function CCBDecomposeView:createSlider()
    self.m_countSlider = ccui.Slider:create();
    
    self.m_countSlider:setScale9Enabled(true);
    self.m_countSlider:setTouchEnabled(false);

    self.m_countSlider:setContentSize(self.m_ccbNodeSlider:getContentSize());
    self.m_countSlider:setAnchorPoint(0, 0);
    self.m_countSlider:loadBarTexture(ResourceMgr:getSliderBarBg());
    self.m_countSlider:loadProgressBarTexture(ResourceMgr:getSliderBar());
    self.m_countSlider:loadSlidBallTextures(ResourceMgr:getSliderBall(), ResourceMgr:getSliderBall(), ResourceMgr:getSliderBall());

	self.m_countSlider:setPercent(1);
	self.m_countSlider:setMaxPercent(self.m_nDecomposeMaxCount);

	local function changeEvent(pSender, eventType)
		if eventType == ccui.SliderEventType.percentChanged then
			local percent = pSender:getPercent();
			if percent < 1 then
				percent = 1;
			end
			self:changeDecomposeCount(percent);
		end
	end
    self.m_countSlider:addEventListener(changeEvent);
    self.m_ccbNodeSlider:addChild(self.m_countSlider);
end

function CCBDecomposeView:changeDecomposeCount(count)
	if self.m_curSelectIconIndex <= -1 then
		return
	end

	if count < 1 then
		count = 1;
	elseif count > self.m_nDecomposeMaxCount then
		count = self.m_nDecomposeMaxCount;
	end
	self.m_countSlider:setPercent(count);
	self.m_ccbLabelItemCount:setString(Str[10013].."："..count);
	self.m_ccbLabelResolvePoint:setString(count*self.m_nResolvePoint);

	self.m_ccbLabelCostMoney:setString(count*self.m_nResolveCost);
end

function CCBDecomposeView:onBtnSliderDown()
	self:changeDecomposeCount(self.m_countSlider:getPercent() - 1);
end

function CCBDecomposeView:onBtnSliderUp()
	self:changeDecomposeCount(self.m_countSlider:getPercent() + 1);
end

function CCBDecomposeView:showTimeFormat(time)
	local hour = math.floor(time / 3600);
	local minute = math.floor((time % 3600) / 60);
	local second = time % 60;
	return string.format("%02d:%02d:%02d", hour, minute, second);
end

function CCBDecomposeView:onBtnDecompose()
	if self.m_curSelectIconIndex <= -1 then
		local ccbMessageBox = CCBMessageBox:create(Str[3004], Str[18001], MB_OK);
		ccbMessageBox.onBtnOK = function ()
			ccbMessageBox:removeSelf();
		end
		return;
	end

	if UserDataMgr:getPlayerGoldCoin() < tonumber(self.m_ccbLabelCostMoney:getString()) then
		local ccbMessageBox = CCBMessageBox:create(Str[3004], Str[4051], MB_OKCANCEL);
		ccbMessageBox.onBtnOK = function ()
			App:enterScene("ShopScene");
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
	else
		local function request()
			local data = self.m_showList[self.m_showSlotIndex][self.m_curSelectIconIndex];
			Network:request("game.itemsHandler.decompose_items", {items = {{item_id=data["id"], count=self.m_countSlider:getPercent()}}}, function(rc, receiveData)
				if receiveData.code ~= 1 then
					Tips:create(ServerCode[receiveData.code]);
					return;
				end

				itemTips:create({{item_id=RESOLVE_POINT_ITEM_ID, delta=tonumber(self.m_ccbLabelResolvePoint:getString())}});

				local count = tonumber(self.m_ccbLabelInfoCount:getString()) - self.m_countSlider:getPercent();
				if count <= 0 then
					table_remove(self.m_showList[self.m_showSlotIndex], self.m_curSelectIconIndex);
				else
					self.m_showList[self.m_showSlotIndex][self.m_curSelectIconIndex].count = count;
				end

				self:flushSelectedItemSlot();
				self:flushItemViewTipVisible();
				self.m_tableView:reloadData();
			end);
		end
		if self.m_armature == nil then
			self.m_armature = ResourceMgr:getAnimArmatureByNameOnDecompose("disintegration_fx");
			self.m_armature:setPosition(self.m_ccbSpriteItemBg:getContentSize().width/2+5, 
				self.m_ccbSpriteItemBg:getContentSize().height/2+12);
			self.m_ccbSpriteItemBg:addChild(self.m_armature);
		end
		self.m_armature:getAnimation():play("anim01");
		self.m_armature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				if movementID == "anim01" then
					request();
				end
			end
		end)
		self.m_armature:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
			if evt == "hide" then
				local node = self.m_ccbNodeItemIcon:getChildren()[1];
				local time = 0.2;
				node:getChildByTag(ICON_TAG_PIC):runAction(cc.FadeOut:create(time));
				node:getChildByTag(ICON_TAG_FRAME):runAction(cc.FadeOut:create(time));

				node:getChildByTag(ICON_TAG_BG):runAction(cc.Sequence:create(cc.FadeOut:create(time), cc.CallFunc:create(function()
					self.m_ccbLabelItemCount:setString("");
				end)));
			end
		end)
	end
end

function CCBDecomposeView:onBtnRecharge()
	Audio:playEffect(11, false, 1, 0, 1);

	local viewBase = App:enterScene("ShopScene"):getViewBase();
	viewBase:openDecompose();
	viewBase:setLastSceneName("DecomposeScene");
end

return CCBDecomposeView