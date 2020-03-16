local ResourceMgr = require("app.utils.ResourceMgr");
local PackageIcon = require("app.views.packageView.PackageIcon")
local Tips = require("app.views.common.Tips");
local CCBPackageUpgrade = require("app.views.packageView.CCBPackageUpgrade");
local CCBCommonGetPath = require("app.views.commonCCB.CCBCommonGetPath");

local CCBPackageView = class("CCBPackageView", function ()
	return CCBLoader("ccbi/packageView/CCBPackageView.ccbi")
end)

SHOW_TAB_1 = 1;
SHOW_TAB_2 = 2;
SHOW_TAB_3 = 3;
SHOW_TAB_4 = 4;

local itemDescTitleUpPosY = 102;
local itemDescTitleDownPosY = 32;
local itemDescUpPosY = 76;
local itemDescDownPosY = 6;

local itemUseNumTipPos = cc.p(-42, -36);
local itemUseNumTipSize = cc.size(18, 18);
local equipItemCountBgPos = cc.p(13, -35);
local equipItemCountPos = cc.p(42, -35);

local equipState = 10;
local normalState = 11;

function CCBPackageView:ctor()
	--self.m_ccbNodeCenter:getChildByTag(1);
	if display.resolution >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
		self.m_ccbNodeBottom:setScale(display.reduce);
	end
	self.m_showList = {};
	self.m_showList[SHOW_TAB_1] = {};
	self.m_showList[SHOW_TAB_2] = {};
	self.m_showList[SHOW_TAB_3] = {};
	self.m_showList[SHOW_TAB_4] = {};

	self.m_showTableIndex = 1;
	self.m_ccbBtnTab1:setEnabled(false);
	self.m_tableViewPage = 1;
	self.m_nodeItemIcons = {};
	self.m_curSelectItemID = -1;

	ItemDataMgr:setDeleteItemID(0);

	self.m_isEquipItemShow = true;
	self.m_state = normalState;
	
	local moveBy = cc.MoveBy:create(0.3, cc.p(-8,0));
	self.m_ccbSpriteArrowLeft:runAction( cc.RepeatForever:create( cc.Sequence:create( moveBy, moveBy:reverse() ) ) );

	local moveBy2 = cc.MoveBy:create(0.3, cc.p(8,0));
	self.m_ccbSpriteArrowRight:runAction( cc.RepeatForever:create( cc.Sequence:create( moveBy2, moveBy2:reverse() ) ) );

	self:createTouchEvent();
	self:filterShowList();
	self.m_curSelectItemIndex = 1;
	self.m_curSelectItemID = self.m_showList[self.m_showTableIndex][self.m_curSelectItemIndex].id;

	self:showDetailLabels(true);
	self:setItemDetail();

	self:createTableView();

	self:setArrowShow();
	self:showEquipItem(true);
	self:setEquipSlotIcon();
	self:showEquipSlotSelectSprite();
end

function CCBPackageView:filterShowList()
	local allItems = ItemDataMgr:getAllItems();
	-- {
 --          "button_type" = 0
 --          "cd"          = 15
 --          "desc"        = "强制使能量体位置发生变化"
 --          "equipable"   = 1
 --          "id"          = 1309
 --          "item_icon"   = 1309
 --          "item_origin" = {
 --              "origin_1" = "1"
 --          }
 --          "item_target" = 7
 --          "level"       = 3
 --          "name"        = "能量跃迁"
 --          "type"        = 1
 --          "use_limit"   = 3
 --      }
	for k, v in pairs(allItems) do
		local itemInfo = ItemDataMgr:getItemBaseInfo(k);
		
		if itemInfo.type == 1 then
			--print("list1:", itemInfo.id);
			table.insert(self.m_showList[SHOW_TAB_1], itemInfo);
		elseif itemInfo.type == 2 then
			table.insert(self.m_showList[SHOW_TAB_3], itemInfo);
		elseif itemInfo.type == 3 or itemInfo.type == 4 or itemInfo.type == 5 then
			table.insert(self.m_showList[SHOW_TAB_2], itemInfo);
		else
			table.insert(self.m_showList[SHOW_TAB_4], itemInfo);
		end
	end
	for i = 1, 4 do
		table.sort(self.m_showList[i], function (info1, info2)
			return info1.id < info2.id;
		end);
	end
end

function CCBPackageView:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.m_ccbNodeTouch)
end

function CCBPackageView:onTouchBegan(touch, event)
	self.m_lastMovePos = cc.p(0, 0);
	local touchPos = touch:getLocation();
	self.m_touchTableViewBeginPos = self.m_ccbNodeView:convertToNodeSpace(touchPos);
	if self.m_touchTableViewBeginPos.x < 0		
		or self.m_touchTableViewBeginPos.x > self.m_ccbNodeView:getContentSize().width 
		or self.m_touchTableViewBeginPos.y < 0
		or self.m_touchTableViewBeginPos.y > self.m_ccbNodeView:getContentSize().height then
		return false;
	end

	return true;
end

function CCBPackageView:onTouchMoved(touch, event)
	local touchPos = touch:getLocation();
	self.m_touchTableViewMovePos = self.m_ccbNodeView:convertToNodeSpace(touchPos);
	if self.m_lastMovePos.x ~= 0 then
		local offsetX = self.m_tableView:getContentOffset().x + (self.m_touchTableViewMovePos.x - self.m_lastMovePos.x)*1.3;
		self.m_tableView:setContentOffset(cc.p(offsetX, 0));
	end
	self.m_lastMovePos = self.m_touchTableViewMovePos;
end

function CCBPackageView:onTouchEnded(touch, event)
	self.m_lastMovePos = cc.p(0, 0)
	local touchPos = touch:getLocation();
	self.m_touchTableViewEndPos = self.m_ccbNodeView:convertToNodeSpace(touchPos);

	local offsetX = (self.m_touchTableViewEndPos.x - self.m_touchTableViewBeginPos.x) * 1.3;
	if math.abs(offsetX) > self.m_ccbNodeView:getContentSize().width * 0.3 then
		if offsetX < 0 then
			self:turnPage(1);
		else 
			self:turnPage(-1);
		end
	else
		self:turnPage(0);
	end

	if math.abs(offsetX) < 15 then
		-- for i = 1,18 do
		-- 	if self.m_nodeItemIcons[i] then
		-- 		if cc.rectContainsPoint(self.m_nodeItemIcons[i]:getBoundingBox(), self.m_touchTableViewEndPos) then
							
		-- 			self.m_curSelectItemID = self.m_nodeItemIcons[i]:getItemID();
		-- 			self:setSelectItem();
		-- 			print("点击到第", i, "个, id:", self.m_curSelectItemID);
		-- 		end
		-- 	end
		-- end
		-- for k, v in pairs(self.m_nodeItemIcons) do
		-- 	if cc.rectContainsPoint(v:getBoundingBox(), self.m_touchTableViewEndPos) then	
		-- 		self.m_curSelectItemID = k;
		-- 		self:setSelectItem();
		-- 	end
		-- end
		for i = 1 + 18 * (self.m_tableViewPage - 1), 18 * (self.m_tableViewPage) do 
			if cc.rectContainsPoint(self.m_nodeItemIcons[i]:getBoundingBox(), self.m_touchTableViewEndPos) then
				if self.m_nodeItemIcons[i]:getItemID() ~= 0 then
					if self.m_curSelectItemID == self.m_nodeItemIcons[i]:getItemID() then
						print("    is the same    self.m_curSelectItemID     ");
						return;
					end
					self.m_curSelectItemIndex = i;
					self.m_curSelectItemID = self.m_nodeItemIcons[i]:getItemID();
					self:setSelectItem();
					self:setItemDetail();

					if not self.m_ccbNodeItemDetail:isVisible() then
						self:showDetailLabels(true);
					end
					self:showEquipSlotSelectSprite();
				end
				break;
			end
		end
	else
		print("滑动过大取消选择");
	end
	
end

function CCBPackageView:turnPage(param)
	self.m_tableViewPage = self.m_tableViewPage + param;
	if self.m_tableViewPage == 0 then
		self.m_tableViewPage = 1;
	end
	if self.m_tableViewPage > math.ceil(#self.m_showList[self.m_showTableIndex]/18) then
		self.m_tableViewPage = math.ceil(#self.m_showList[self.m_showTableIndex]/18);
	end		
	self.m_tableView:setContentOffset(cc.p((self.m_tableViewPage-1) * (-self.m_ccbNodeView:getContentSize().width), 0), true);

	self:setArrowShow();
end

function CCBPackageView:setArrowShow()
	if self.m_tableViewPage == 1 then
		self.m_ccbSpriteArrowLeft:setVisible(false);
	else
		self.m_ccbSpriteArrowLeft:setVisible(true);
	end

	if self.m_tableViewPage == math.ceil(#self.m_showList[self.m_showTableIndex]/18) then
		self.m_ccbSpriteArrowRight:setVisible(false);
	else
		self.m_ccbSpriteArrowRight:setVisible(true);
	end	
end

function CCBPackageView:setSelectItem()
	-- if node then
	-- 	node:setSelectState(true);
	-- end	
	for k, v in pairs(self.m_nodeItemIcons) do
		v:setSelectState(false);
		if self.m_curSelectItemID == v:getItemID() then
			v:setSelectState(true);
		end
	end
end

function CCBPackageView:setUnselectItem(node)
	-- if node then
	-- 	node:setSelectState(false);
	-- end
end

function CCBPackageView:createTableView()
	self.m_tableView = cc.TableView:create(self.m_ccbNodeView:getContentSize());
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL);
    self.m_tableView:setBounceable(false);
    self.m_tableView:setTouchEnabled(false);
    self.m_ccbNodeView:addChild(self.m_tableView);

   	self.m_tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx) end, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end, cc.TABLECELL_SIZE_AT_INDEX)
    self.m_tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    self.m_tableView:reloadData()
end

function CCBPackageView:cellSizeForTable(table, idx)
	return self.m_ccbNodeView:getContentSize().width, self.m_ccbNodeView:getContentSize().height;
end

function CCBPackageView:tableCellAtIndex(table,idx)
	local cell = table:dequeueCell();

	if cell == nil then
		cell = cc.TableViewCell:new();
		for i = 1, 18 do
			if self.m_showList[self.m_showTableIndex][i+18*idx] then
				self.m_nodeItemIcons[i+18*idx] = PackageIcon:create(self.m_showList[self.m_showTableIndex][i+18*idx].id);
				--self.m_nodeItemIcons[self.m_showList[self.m_showTableIndex][i+18*idx].id] = self.m_nodeItemIcons[i];
			else
				self.m_nodeItemIcons[i+18*idx] = PackageIcon:create();
			end
			if self.m_nodeItemIcons[i+18*idx] then
				self.m_nodeItemIcons[i + 18 * idx]:setTag(100 + i);
				cell:addChild(self.m_nodeItemIcons[i+18*idx]);
				local posX = 70;
				local posY = 65;
				if i < 7 then
					posX = posX + 122 * (i - 1);
					posY = posY + 250;
				elseif i < 13 then
					posX = posX + 122 * (i - 7);
					posY = posY + 125;
				else 
					posX = posX + 122 * (i - 13);
				end
				self.m_nodeItemIcons[i+18*idx]:setPosition(cc.p(posX, posY));
			end
		end
	else
		for i = 1, 18 do
			-- if not self.m_nodeItemIcons[i + 18 * idx] then
				self.m_nodeItemIcons[i + 18 * idx] = cell:getChildByTag(100 + i);
			-- end
			if self.m_showList[self.m_showTableIndex][i+18*idx] then
				self.m_nodeItemIcons[i + 18 * idx]:changeInfo(self.m_showList[self.m_showTableIndex][i+18*idx].id);
				--self.m_nodeItemIcons[self.m_showList[self.m_showTableIndex][i+18*idx].id] = self.m_nodeItemIcons[i];
			else
				self.m_nodeItemIcons[i + 18 * idx]:changeToNone();
			end
		end
	end

	-- self:setArrowShow();
	self:setSelectItem();
	return cell;
end

function CCBPackageView:numberOfCellsInTableView(table)
	local pageCount = math.ceil(#self.m_showList[self.m_showTableIndex]/18);
	if pageCount == 0 then
		return 1;
	else
		return pageCount;
	end
end

function CCBPackageView:setItemDetail()
	local itemData = ItemDataMgr:getItemBaseInfo(self.m_curSelectItemID);
	local itemName = itemData.name;
	self.m_ccbLabelName:setString(itemName);
	local itemLevel = itemData.level;
	self.m_ccbLabelLevel:setString(Str[9015 + itemLevel]);
	local itemCount = ItemDataMgr:getItemCount(itemData.id);
	self.m_ccbLabelCount:setString(itemCount);-- .. Str[10007]
	if self.m_showTableIndex == 1 then
		self.m_ccbLabelRow3:setVisible(true);
		self.m_ccbLabelRow4:setVisible(true);
		local useLimit = itemData.use_limit;
		self.m_ccbLabelUseLimit:setString(useLimit);-- .. Str[9020]
		local cd = itemData.cd;
		self.m_ccbLabelCD:setString(cd .. "s");
		self.m_ccbLabelItemDescTitle:setPositionY(itemDescTitleDownPosY);
		self.m_ccbLabelDesc:setPositionY(itemDescDownPosY);
		-- self.m_ccbSpriteBtnUpgrade:setVisible(true);
		-- self.m_ccbSpriteBtnUse:setVisible(false);
		local btnUpgradeSprite = self.m_ccbNodeItemDetail:getChildByTag(11);
		if btnUpgradeSprite == nil then
			btnUpgradeSprite = cc.Sprite:create(ResourceMgr:getPackageUpgradeBtnSprite());
			local posX = self.m_ccbBtnUpgrade:getPositionX();
			local posY = self.m_ccbBtnUpgrade:getPositionY(); 
			self.m_ccbNodeItemDetail:addChild(btnUpgradeSprite, 1, 11);
			btnUpgradeSprite:setPosition(posX, posY);
		end
		local btnUseSprite = self.m_ccbNodeItemDetail:getChildByTag(12);
		if btnUseSprite ~= nil then
			btnUseSprite:removeFromParent();
			btnUseSprite = nil;
		end
	else
		self.m_ccbLabelRow3:setVisible(false);
		self.m_ccbLabelRow4:setVisible(false);
		self.m_ccbLabelUseLimit:setString("");
		self.m_ccbLabelCD:setString("");
		self.m_ccbLabelItemDescTitle:setPositionY(itemDescTitleUpPosY);
		self.m_ccbLabelDesc:setPositionY(itemDescUpPosY);
		-- self.m_ccbSpriteBtnUpgrade:setVisible(false);
		-- self.m_ccbSpriteBtnUse:setVisible(true);
		local btnUpgradeSprite = self.m_ccbNodeItemDetail:getChildByTag(11);
		if btnUpgradeSprite ~= nil then
			btnUpgradeSprite:removeFromParent();
			btnUpgradeSprite = nil;
		end
		local btnUseSprite = self.m_ccbNodeItemDetail:getChildByTag(12);
		if btnUseSprite == nil then
			btnUseSprite = cc.Sprite:create(ResourceMgr:getPackageUseBtnSprite());
			local posX = self.m_ccbBtnUpgrade:getPositionX();
			local posY = self.m_ccbBtnUpgrade:getPositionY(); 
			self.m_ccbNodeItemDetail:addChild(btnUseSprite, 1, 12);
			btnUseSprite:setPosition(posX, posY);
		end
	end
	local itemDesc = itemData.desc;
	self.m_ccbLabelDesc:setString(itemDesc);
end

function CCBPackageView:setEquipSlotIcon()
	local equipItemData = ItemDataMgr:getAllEquipSlot();
	-- dump(equipItemData);
-- 			{
--               1 = 1004
--               2 = 1104
--               3 = 1107
--               4 = 1204
--               5 = 1304
--           }
 	for i = 1, 5 do 
 		local itemID = equipItemData[i];
 		local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);
 		if itemID ~= -1 then
 			self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(1):removeAllChildren();
	 		local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	 		local itemIconBg = cc.Sprite:create(ResourceMgr:getPackageEquipSlotBg(itemLevel));
	 		self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(1):addChild(itemIconBg);
	 		local itemIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(iconID));
	 		self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(1):addChild(itemIcon);
	 		self:setEquipSlotCount(itemID, i);
	 	end
 	end
end
-- tag 1 数量（黑）背景； 2 数量label； 3 耗尽标志； 4 转换标志
function CCBPackageView:setEquipSlotCount(itemID, pos)
	local node = nil;
	if self.m_ccbNodeBottom:getChildByTag(pos):getChildByTag(1):getChildByTag(1) then
		node = self.m_ccbNodeBottom:getChildByTag(pos):getChildByTag(1):getChildByTag(1);
		node:removeAllChildren();
	else
		node = cc.Node:create();
		self.m_ccbNodeBottom:getChildByTag(pos):getChildByTag(1):addChild(node, 1, 1);
	end

	local itemCount = ItemDataMgr:getItemCount(itemID);
	local itemUseLimit = ItemDataMgr:getItemUseLimitByID(itemID);

	for i = 1, itemUseLimit do 
		local tipUseSprite = nil;
		if i <= itemCount then
			tipUseSprite = cc.Sprite:create(ResourceMgr:getPackageUseItemHigh());
		else
			tipUseSprite = cc.Sprite:create(ResourceMgr:getPackageUseItemLow());
		end
		node:addChild(tipUseSprite);
		tipUseSprite:setPosition(cc.p(itemUseNumTipPos.x, itemUseNumTipPos.y + itemUseNumTipSize.height * (i - 1)));
	end
	local countLabel = cc.LabelTTF:create();
	countLabel:setFontSize(16);
	countLabel:setColor(cc.WHITE);
	node:addChild(countLabel, 2, 2);
	countLabel:setAnchorPoint(cc.p(1, 0.5));
	countLabel:setPosition(equipItemCountPos);
	if itemCount > 0 then
		local countBg = cc.Sprite:create(ResourceMgr:getItemCountBg());
		countBg:setPosition(equipItemCountBgPos);
		node:addChild(countBg, 1, 1);
		countLabel:setString(itemCount);
	else
		countLabel:setString("");
		local useUpSprite = cc.Sprite:create(ResourceMgr:getItemUseUpMark());
		node:addChild(useUpSprite, 3, 3);
	end
end

-- 切换道具类型的装备道具栏显示
function CCBPackageView:showEquipItem(show)
	if show then
		if not self.m_isEquipItemShow then
			for i = 1, 5 do 
				self.m_ccbNodeBottom:getChildByTag(i):setVisible(show);
			end
			self.m_ccbBtnEquip:setEnabled(show);
		end
		if self.m_ccbNodeEquipBtn:getChildByTag(1) == nil then
			local equipBtnSprite = cc.Sprite:create(ResourceMgr:getPackageEquipBtnEquip());
			self.m_ccbNodeEquipBtn:addChild(equipBtnSprite, 1, 1);
		end
		if self.m_ccbNodeTip:isVisible() then
			self.m_ccbNodeTip:setVisible(false);
		end
	else
		if self.m_isEquipItemShow then
			for i = 1, 5 do 
				self.m_ccbNodeBottom:getChildByTag(i):setVisible(show);
			end
			self.m_ccbBtnEquip:setEnabled(show);
			self.m_ccbNodeEquipBtn:removeAllChildren();
			self.m_ccbNodeTip:setVisible(true);
		end
	end
	self.m_isEquipItemShow = show;
end

-- 设置标题栏三个按钮的显示
function CCBPackageView:setTabBtnVisible(visible)
	for i = 2, 4 do 
		self.m_ccbNodeCenter:getChildByTag(i):setVisible(visible);
	end
end

-- 设置装备按钮图片显示
function CCBPackageView:changeBtnSpriteByState(state)
	self.m_ccbNodeEquipBtn:removeAllChildren();
	if state == normalState then
		local equipBtnSprite = cc.Sprite:create(ResourceMgr:getPackageEquipBtnEquip());
		self.m_ccbNodeEquipBtn:addChild(equipBtnSprite, 1, 1);
	elseif state == equipState then
		local completeBtnSprite = cc.Sprite:create(ResourceMgr:getPackageEquipBtnComplete());
		self.m_ccbNodeEquipBtn:addChild(completeBtnSprite, 2, 2);
	end
end

-- 设置详细介绍栏的显示
function CCBPackageView:showDetailLabels(show)
	self.m_ccbSpriteTipEquipLabel:setVisible(not show);
	self.m_ccbNodeItemDetail:setVisible(show);
end

-- 显示物品选中状态(例：tag为10 是转换标志 ; tag 为11 选中框)
function CCBPackageView:showEquipSlotSelectSprite()
	local equipItemData = ItemDataMgr:getAllEquipSlot();
	if self.m_state == normalState then
		for i = 1, 5 do
			if self.m_curSelectItemID == equipItemData[i] then
				if self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(11) == nil then
					local selectSprite = cc.Sprite:create(ResourceMgr:getItemSelectFrame());
					self.m_ccbNodeBottom:getChildByTag(i):addChild(selectSprite, 2, 11);
				end
			else
				if self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(11) then
					self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(11):removeSelf();
					-- self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(11) = nil;
				end
			end
		end
	elseif self.m_state == equipState then
		for i = 1, 5 do 
			if self.m_curSelectItemID == equipItemData[i] then
				if self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(10) then
					self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(10):removeSelf();
					-- self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(10) = nil;
				end
				if self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(11) == nil then
					local selectSprite = cc.Sprite:create(ResourceMgr:getItemSelectFrame());
					self.m_ccbNodeBottom:getChildByTag(i):addChild(selectSprite, 2, 11);
				end
			else
				if self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(10) == nil then
					local changeSprite = cc.Sprite:create(ResourceMgr:getChangeSign());
					self.m_ccbNodeBottom:getChildByTag(i):addChild(changeSprite, 2, 10);
				end
				if self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(11) then
					self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(11):removeSelf();
					-- self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(11) = nil;
				end
			end
		end
	end
end

-- 点击物品按钮响应（两个状态）
function CCBPackageView:selectEquipSlotItemByPos(pos)
	local equipItemData = ItemDataMgr:getAllEquipSlot();
	
	if self.m_state == equipState then
		if self.m_curSelectItemID ~= -1 and self.m_curSelectItemID ~= equipItemData[pos] then
			if self.m_ccbNodeBottom:getChildByTag(pos):getChildByTag(10) then
				self.m_ccbNodeBottom:getChildByTag(pos):removeChildByTag(10);
			end
			self:playItemChangeTouchAnim(pos);
			Network:request("game.itemsHandler.replace_equip", {target = 1, item_id = self.m_curSelectItemID, position = pos}, function (rc, receiveData)
				print(" packageView=========请求物品装备与替换 =========");
				if receiveData["code"] ~= 1 then
					Tips:create(ServerCode[receiveData.code]);
					return;
				end
				dump(receiveData);
				ItemDataMgr:setEquipList(receiveData.equip_list[1]);
				self:playItemChangeAnim(pos);
			end);
			return;
		end
	end
	if self.m_curSelectItemID == equipItemData[pos] then
		if ItemDataMgr:getItemCount(self.m_curSelectItemID) > 0 then
			local offsetPage = math.floor((self.m_curSelectItemIndex - 1) / 18);
			self.m_tableViewPage = offsetPage + 1;
			self:turnPage(0);
		end
		return;
	end
	self.m_curSelectItemID = equipItemData[pos];
	self:showEquipSlotSelectSprite();
	self.m_curSelectItemIndex = 0;
	for k, v in pairs(self.m_showList[self.m_showTableIndex]) do 
		if v.id == self.m_curSelectItemID then
			self.m_curSelectItemIndex = k;
			break;
		end
	end
	self:setItemDetail();
	if not self.m_ccbNodeItemDetail:isVisible() then
		self:showDetailLabels(true);
	end

	self:reloadDataWithOffset();
	if ItemDataMgr:getItemCount(self.m_curSelectItemID) > 0 then
		local offsetPage = math.floor((self.m_curSelectItemIndex - 1) / 18);
		self.m_tableViewPage = offsetPage + 1;
		self:turnPage(0);
	end
end

function CCBPackageView:returnViewAfterChangeEquipSlot()
	self.m_curSelectItemID = -1;
	self.m_curSelectItemIndex = 0;
	self:showDetailLabels(false);
	self:recoverEquipSlotNormalShow();
	self:setEquipSlotIcon();

	self:reloadDataWithOffset();
end

-- 装备栏正常显示
function CCBPackageView:recoverEquipSlotNormalShow()
	for i = 1, 5 do 
		if self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(10) then
			self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(10):removeSelf();
			-- self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(10) = nil;
		end
		if self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(11) then
			self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(11):removeSelf();
			-- self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(11) = nil;
		end
	end
end

function CCBPackageView:reloadDataWithOffset()
	local offset = self.m_tableView:getContentOffset();
	self.m_tableView:reloadData();
	self.m_tableView:setContentOffset(offset);
end

function CCBPackageView:updateViewOfDataUpdate(items)
	local equipItemData = ItemDataMgr:getAllEquipSlot();
	for i = 1, #items do 
		if items[i].count == items[i].delta then
			self:insertNewItem(items[i].item_id);
			if ItemDataMgr:getDeleteItemID() == items[i].item_id - 1 then
				self.m_curSelectItemID = items[i].item_id;
				self:setItemDetail();
				ItemDataMgr:setDeleteItemID(0);
			end
		elseif items[i].count == 0 then
			-- 更新表
			table.remove(self.m_showList[self.m_showTableIndex], self.m_curSelectItemIndex);
			self.m_curSelectItemID = self.m_showList[self.m_showTableIndex][self.m_curSelectItemIndex].id;
			self:setItemDetail();
			ItemDataMgr:setDeleteItemID(items[i].item_id);
		elseif items[i].item_id == self.m_curSelectItemID then
			local itemCount = ItemDataMgr:getItemCount(self.m_curSelectItemID);
			self.m_ccbLabelCount:setString(itemCount);
		end
		for j = 1, 5 do
			if equipItemData[j] == items[i].item_id then
				self:setEquipSlotCount(equipItemData[j], j);
				break;
			end
		end
	end
	self:showEquipSlotSelectSprite();
	self:reloadDataWithOffset();
end

function CCBPackageView:insertNewItem(itemID)
	local itemInfo = ItemDataMgr:getItemBaseInfo(itemID);
	local tableIndex = 0;
	if itemInfo.type == 1 then
		table.insert(self.m_showList[SHOW_TAB_1], itemInfo);
		tableIndex = SHOW_TAB_1;
	elseif itemInfo.type == 2 then
		table.insert(self.m_showList[SHOW_TAB_3], itemInfo);
		tableIndex = SHOW_TAB_3;
	elseif itemInfo.type == 3 or itemInfo.type == 4 or itemInfo.type == 5 then
		table.insert(self.m_showList[SHOW_TAB_2], itemInfo);
		tableIndex = SHOW_TAB_2;
	else
		table.insert(self.m_showList[SHOW_TAB_4], itemInfo);
		tableIndex = SHOW_TAB_4;
	end
	table.sort(self.m_showList[tableIndex], function(a, b)
		return a.id < b.id;
	end);
end

-- 点击按钮恢复数据（选中类型头一个）
function CCBPackageView:pressBtnRecoverData()
	self.m_tableViewPage = 1;
	self.m_nodeItemIcons = {};
	self:setArrowShow();
	self.m_curSelectItemIndex = 1;
	self.m_curSelectItemID = self.m_showList[self.m_showTableIndex][self.m_curSelectItemIndex].id;
	self:setItemDetail();
end

function CCBPackageView:onBtnTab1()
	self.m_showTableIndex = 1;
	self.m_ccbBtnTab1:setEnabled(false);

	self.m_ccbBtnTab2:setEnabled(true);
	self.m_ccbBtnTab3:setEnabled(true);
	self.m_ccbBtnTab4:setEnabled(true);
	self:pressBtnRecoverData();
	self:recoverEquipSlotNormalShow();
	self:showEquipItem(true);

	self.m_tableView:reloadData();
end

function CCBPackageView:onBtnTab2()
	self.m_showTableIndex = 2;
	self.m_ccbBtnTab2:setEnabled(false);

	self.m_ccbBtnTab1:setEnabled(true);
	self.m_ccbBtnTab3:setEnabled(true);
	self.m_ccbBtnTab4:setEnabled(true);
	self:pressBtnRecoverData();
	self:showEquipItem(false);
	self.m_tableView:reloadData();
end

function CCBPackageView:onBtnTab3()
	self.m_showTableIndex = 3;
	self.m_ccbBtnTab3:setEnabled(false);

	self.m_ccbBtnTab1:setEnabled(true);
	self.m_ccbBtnTab2:setEnabled(true);
	self.m_ccbBtnTab4:setEnabled(true);
	self:pressBtnRecoverData();
	self:showEquipItem(false);

	self.m_tableView:reloadData();
end

function CCBPackageView:onBtnTab4()
	self.m_showTableIndex = 4;
	self.m_ccbBtnTab4:setEnabled(false);

	self.m_ccbBtnTab1:setEnabled(true);
	self.m_ccbBtnTab2:setEnabled(true);
	self.m_ccbBtnTab3:setEnabled(true);
	self:pressBtnRecoverData();
	self:showEquipItem(false);

	self.m_tableView:reloadData();
end

-- button_type :0 无；1 升级道具；2 直接使用；3 前往炮台界面；4 前往战舰界面；5 前往生产界面
function CCBPackageView:onBtnUpgrade()
	local itemButtonType = ItemDataMgr:getItemBaseInfo(self.m_curSelectItemID).button_type;
	if itemButtonType == 0 then
		if self.m_showTableIndex == 1 then
			Tips:create(Str[9021]);
		end
	elseif itemButtonType == 1 then
		-- print("  升级  道具  ~~~ ")
		if ItemDataMgr:getItemCount(self.m_curSelectItemID) < 1 then
			Tips:create(Str[9025]);
			return;
		end
		CCBPackageUpgrade:create(self.m_curSelectItemID);
	elseif itemButtonType == 2 then
		-- 使用
		Network:request("game.itemsHandler.use_buff_item", {item_id = self.m_curSelectItemID}, function(rc, receiveData)
			print(" --------使用道具，直接响应--------");
			if receiveData.code ~= 1 then
				Tips:create(ServerCode[receiveData.code]);
				return;
			end
			-- dump(receiveData);
			if self.m_curSelectItemID == 4007 then
				UserDataMgr:setLeftTimeDoubleFriendship(receiveData.remain_second);
			elseif self.m_curSelectItemID == 4008 then
				UserDataMgr:setLeftTimeDoubleFloater(receiveData.remain_second);
			end

			Tips:create(Str[10016]);
		end)
	elseif itemButtonType == 3 or itemButtonType == 4 then
		App:enterScene("ShipScene");
	elseif itemButtonType == 5 then
		App:enterScene("ProduceScene1");
	elseif itemButtonType == 6 then
		App:enterScene("LotteryScene");
	elseif itemButtonType == 7 then
		local escort_level_limit = 10;
		if UserDataMgr:getPlayerLevel() < escort_level_limit then
			Tips:create(Str[11005]..escort_level_limit);
		else
			App:enterScene("EscortScene");
		end
	end
end

function CCBPackageView:onBtnPath()
	CCBCommonGetPath:create(self.m_curSelectItemID);
end

function CCBPackageView:onBtnEquip()
	self:recoverEquipSlotNormalShow();
	if self.m_state == normalState then
		self.m_state = equipState;
		self:setTabBtnVisible(false);
		self.m_curSelectItemIndex = 0;
		self.m_curSelectItemID = -1;
		self:showDetailLabels(false);
		self:playEquipSlotStateAnim();
	elseif self.m_state == equipState then
		self.m_state = normalState;
		self:setTabBtnVisible(true);
		self.m_curSelectItemIndex = 1;
		self.m_curSelectItemID = self.m_showList[self.m_showTableIndex][self.m_curSelectItemIndex].id;
		self:showDetailLabels(true);
		self:setItemDetail();
		self:showEquipSlotSelectSprite();
		self:removeSlotStateAnim();
	end
	self:changeBtnSpriteByState(self.m_state);
	self:reloadDataWithOffset();
	self:turnPage(0);
end

-- function CCBPackageView:onBtnConfirm()
	
-- end

function CCBPackageView:onBtnEquipPos1()
	self:selectEquipSlotItemByPos(1);
end

function CCBPackageView:onBtnEquipPos2()
	self:selectEquipSlotItemByPos(2);
end

function CCBPackageView:onBtnEquipPos3()
	self:selectEquipSlotItemByPos(3);
end

function CCBPackageView:onBtnEquipPos4()
	self:selectEquipSlotItemByPos(4);
end

function CCBPackageView:onBtnEquipPos5()
	self:selectEquipSlotItemByPos(5);
end

function CCBPackageView:onBtnLeftArrow()
	self:turnPage(-1);
end

function CCBPackageView:onBtnRightArrow()
	self:turnPage(1);
end

function CCBPackageView:playItemChangeTouchAnim(pos)
	local itemChangeTouchAnim = ResourceMgr:getIconChangeAnimTouch();
	self.m_ccbNodeBottom:getChildByTag(pos):addChild(itemChangeTouchAnim, 3);
	itemChangeTouchAnim:getAnimation():play("anim01");
	itemChangeTouchAnim:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			itemChangeTouchAnim:removeSelf();
			itemChangeTouchAnim = nil;
		end
	end)
end

function CCBPackageView:playItemChangeAnim(pos)
	local itemChangeAnim = ResourceMgr:getIconChangeAnim();
	self.m_ccbNodeBottom:getChildByTag(pos):addChild(itemChangeAnim, 3);
	itemChangeAnim:getAnimation():play("anim01");
	itemChangeAnim:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			itemChangeAnim:removeSelf();
			itemChangeAnim = nil;
		end
	end)
	itemChangeAnim:getAnimation():setFrameEventCallFunc(function( bone, event, originFrameIndex, currentFrameIndex )
		if event == "change_item" then
			self:returnViewAfterChangeEquipSlot();
		end
	end)
end

function CCBPackageView:playEquipSlotStateAnim()
	for i = 1, 5 do 
		if self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(13) == nil then
			local slotAnim = ResourceMgr:getPackageEquipSlotAnim();
			self.m_ccbNodeBottom:getChildByTag(i):addChild(slotAnim, 2, 13);
			slotAnim:getAnimation():play("anim01");
		end
	end
end

function CCBPackageView:removeSlotStateAnim()
	for i = 1, 5 do 
		if self.m_ccbNodeBottom:getChildByTag(i):getChildByTag(13) then
			self.m_ccbNodeBottom:getChildByTag(i):removeChildByTag(13);
		end
	end
end

function CCBPackageView:onBtnDecompose()
	App:enterScene("DecomposeScene");
end

return CCBPackageView