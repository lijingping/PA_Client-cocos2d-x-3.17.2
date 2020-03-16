local rankAwardTable = require("app.constants.rank_award");
local ResourceMgr = require("app.utils.ResourceMgr");
local DescripProp = require("app.views.common.DescripProp");

local CCBRewardProp = class("CCBRewardProp", function()
	return CCBLoader("ccbi/domainBattleView/CCBRewardProp");
end)

local lineSpritePosY = -20;
local rankLineHeight = 50;

local whiteColor = cc.c3b(255, 255, 255);
local goldColor = cc.c3b(255, 255, 0);
local pinkColor = cc.c3b(255, 102, 255);
local blueColor = cc.c3b(0, 204, 255);
local grayColor = cc.c3b(204, 204, 204);

function CCBRewardProp:ctor(playerRank)
	-- print(" 创建 显示 领取奖励页面 ", playerRank);

	if display.resolution  >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
	self:createListener();

	self.m_playerRank = playerRank;

	self.m_rankAwardData = table.clone(rankAwardTable);
	self.m_awardTableSize = 0;
	table.sort(self.m_rankAwardData, function(a, b)
		return a.id < b.id;
	end)
	-- dump(self.m_rankAwardData);
	for k, v in pairs(self.m_rankAwardData) do 
		self.m_awardTableSize = self.m_awardTableSize + 1;
	end
	-- print("  table 的长度 ", self.m_awardTableSize);
	self.m_ccbDescripProp = nil;

	self.m_rankLabelPosX = self.m_ccbLabelPlayerRank:getPositionX();
	self.m_nameLabelPosX = self.m_ccbLabelPlayerName:getPositionX();
	self.m_damageLabelPosX = self.m_ccbLabelPlayerDamage:getPositionX();
	self.m_perLabelPosX = self.m_ccbLabelPlayerDamagePer:getPositionX();

	self:createTableViewAward();
end

function CCBRewardProp:setData(data, playerInfo)
	-- dump(data);
	self.m_playerRankData = data.rank_info;
	self:createTableViewRank();
	self:setPlayerSelfData(playerInfo);
end

function CCBRewardProp:createListener()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event); end, cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event); end, cc.Handler.EVENT_TOUCH_MOVED);
	listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event); end, cc.Handler.EVENT_TOUCH_ENDED);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerTouch);
end

function CCBRewardProp:onTouchBegan(touch, event)
	-- self.m_beganPos = touch:getLocation();
	-- dump(self.m_beganPos);

	if self.m_showDescScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_showDescScheduler);
		self.m_showDescScheduler = nil;
	end
	if self.m_ccbDescripProp then
		self.m_ccbDescripProp:removeSelf();
		self.m_ccbDescripProp = nil;
	end
	return true;
end

function CCBRewardProp:onTouchMoved(touch, event)

end

function CCBRewardProp:onTouchEnded(touch, event)

end

function CCBRewardProp:createTableViewAward()
	local awardListSize = self.m_ccbNodeAwardTable:getContentSize();
	local cellBgSpriteSize = cc.Sprite:create(ResourceMgr:getDomainAwardRedBg()):getContentSize();
	local lineSize = cc.Sprite:create(ResourceMgr:getDomainNameLine()):getContentSize();
	self.m_cellSizeHeight = cellBgSpriteSize.height + lineSize.height;
	self.m_cellSizeWidth = awardListSize.width;

	self.m_awardTableView = cc.TableView:create(awardListSize)
	self.m_awardTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)  -- vertical 滚动方向：上下
	self.m_awardTableView:setDelegate()
	self.m_awardTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)  -- 填充方向：上到下
	self.m_ccbNodeAwardTable:addChild(self.m_awardTableView)
	-- self.m_awardTableView:setTouchEnabled(false);

	self.m_awardTableView:registerScriptHandler(function(table, cell) return self:awardTableCellTouched(table, cell); end, cc.TABLECELL_TOUCHED)
	self.m_awardTableView:registerScriptHandler(function(table, idx) return self:awardCellSizeForTable(table, idx); end, cc.TABLECELL_SIZE_FOR_INDEX)
	self.m_awardTableView:registerScriptHandler(function(table, idx) return self:awardTableCellAtIndex(table, idx); end, cc.TABLECELL_SIZE_AT_INDEX)
	self.m_awardTableView:registerScriptHandler(function(table) return self:awardNumberOfCellsInTableView(table); end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self.m_awardTableView:registerScriptHandler(function(table, cell) return self:awardTableCellHighLight(table, cell); end, cc.TABLECELL_HIGH_LIGHT);
	self.m_awardTableView:registerScriptHandler(function(table) return self:scrollViewDidScroll(table); end, cc.SCROLLVIEW_SCRIPT_SCROLL);
	self.m_awardTableView:registerScriptHandler(function(table, cell) return self:awardTableCellUnHighLight(table, cell); end, cc.TABLECELL_UNHIGH_LIGHT);

	self.m_awardTableView:reloadData()

	-- dump(self.m_awardTableView);
end

--触摸Cell
function CCBRewardProp:awardTableCellTouched(table, cell)
	-- print("table  touch   1111")
	-- local cellItem = cell:getChildByTag(110);

	-- table:reloadData();

	if self.m_showDescScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_showDescScheduler);
		self.m_showDescScheduler = nil;
	end
	if self.m_ccbDescripProp then
		self.m_ccbDescripProp:removeSelf();
		self.m_ccbDescripProp = nil;
	end
end

function CCBRewardProp:awardTableCellHighLight(table, cell)
	-- print("     high light   状态响应  ");
	
	self.m_showDescTime = 0;
	self.m_tableOffset = table:getContentOffset();
	-- print("cell X ", cell:getChildByTag(110):getPositionX(), "  cell Y ", cell:getChildByTag(110):getPositionY())
	self.m_spacePos = cell:convertToWorldSpace(cc.p(cell:getChildByTag(110):getPositionX(), cell:getChildByTag(110):getPositionY()));
	-- dump(spacePos);
	self.m_touchCellIndex = cell:getIdx() + 1;
	if self.m_showDescScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_showDescScheduler);
		self.m_showDescScheduler = nil;
		if self.m_ccbDescripProp then

			self.m_ccbDescripProp:removeSelf();
			self.m_ccbDescripProp = nil;
		end
	else
		self.m_showDescScheduler = self:getScheduler():scheduleScriptFunc(function(dt) self:timeUpdate(dt); end, 0, false);
	end
end

function CCBRewardProp:awardTableCellUnHighLight(table, cell)
	-- print("     un high light    响应")
	if self.m_showDescScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_showDescScheduler);
		self.m_showDescScheduler = nil;
	end
	if self.m_ccbDescripProp then
		self.m_ccbDescripProp:removeSelf();
		self.m_ccbDescripProp = nil;
	end
end

function CCBRewardProp:scrollViewDidScroll(table)
	-- print("------响应   Scroll  ")
	local moveTableOffset = table:getContentOffset();
	if self.m_tableOffset then
		if math.abs(self.m_tableOffset.x - moveTableOffset.x) > 10 then
			-- 关闭定时器。
			print("  滑动 table 关闭定时器 ");
			if self.m_showDescScheduler then
				self:getScheduler():unscheduleScriptEntry(self.m_showDescScheduler);
				self.m_showDescScheduler = nil;
			end
			if self.m_ccbDescripProp then
				self.m_ccbDescripProp:removeSelf();
				self.m_ccbDescripProp = nil;
			end
		end
	end
end

function CCBRewardProp:timeUpdate(dt)
	self.m_showDescTime = self.m_showDescTime + dt;
	if self.m_showDescTime >= 0.6 and self.m_ccbDescripProp == nil then
		self.m_ccbDescripProp = DescripProp:create(2);
		self:addChild(self.m_ccbDescripProp);
		self.m_ccbDescripProp:setData(self.m_rankAwardData[tostring(self.m_touchCellIndex)]);
		local propSize = self.m_ccbDescripProp:getScale9PicSize();
		local tableSize = self.m_ccbNodeAwardTable:getContentSize();
		self.m_ccbDescripProp:setPosition(cc.p(self.m_spacePos.x + tableSize.width + propSize.width * 0.5, self.m_spacePos.y + self.m_cellSizeHeight * 0.5 + propSize.height * 0.5));
	end
end

function CCBRewardProp:awardCellSizeForTable(table, idx)
	return self.m_cellSizeWidth, self.m_cellSizeHeight;
end

function CCBRewardProp:awardTableCellAtIndex(table, idx)
	-- body
	-- print( " table cell at index 的  index ", idx);
	local listItem = nil;
	local cell = table:dequeueCell()
	if cell == nil then 
		cell = cc.TableViewCell:new();
		listItem = cc.Node:create();
		self:awardNodeSetData(listItem, idx + 1);

		cell:addChild(listItem)
		-- local posX = self.m_ccbNodeAwardTable:getContentSize().width * 0.5;
		-- listItem:setPosition(cc.p(posX, posX + 10));
		listItem:setTag(110)
 -- 因为table的索引从1开始  tableView 是 0

	else
		listItem = cell:getChildByTag(110)
		listItem:removeAllChildren();
		self:awardNodeSetData(listItem, idx + 1);
	end
	return cell;
end

function CCBRewardProp:awardNumberOfCellsInTableView(table)
	return self.m_awardTableSize;
end


function CCBRewardProp:createTableViewRank()
	local rankListSize = self.m_ccbNodeRankTable:getContentSize()

	self.m_rankTableView = cc.TableView:create(rankListSize)
	self.m_rankTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	self.m_rankTableView:setDelegate()
	self.m_rankTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self.m_ccbNodeRankTable:addChild(self.m_rankTableView)

	-- self.m_rankTableView:registerScriptHandler(function(table, cell) return self:rankTableCellTouched(table, cell); end, cc.TABLECELL_TOUCHED)
	self.m_rankTableView:registerScriptHandler(function(table, idx) return self:rankCellSizeForTable(table, idx); end, cc.TABLECELL_SIZE_FOR_INDEX)
	self.m_rankTableView:registerScriptHandler(function(table, idx) return self:rankTableCellAtIndex(table, idx); end, cc.TABLECELL_SIZE_AT_INDEX)
	self.m_rankTableView:registerScriptHandler(function(table) return self:rankNumberOfCellsInTableView(table); end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

	self.m_rankTableView:reloadData()
end

--触摸Cell
-- function CCBRewardProp:rankTableCellTouched(table, cell)

-- end

function CCBRewardProp:rankCellSizeForTable(table, idx)
	return self.m_ccbNodeRankTable:getContentSize().width, rankLineHeight;
end

function CCBRewardProp:rankTableCellAtIndex(table, idx)
	-- body
	local listItem = nil;
	local cell = table:dequeueCell()
	if cell == nil then 
		cell = cc.TableViewCell:new();
		listItem = cc.Node:create();
		self:rankPlayerData(listItem, idx + 1);

		cell:addChild(listItem)
		listItem:setPosition(cc.p(self.m_ccbNodeRankTable:getContentSize().width * 0.5, rankLineHeight * 0.5 + 5));
		listItem:setTag(110)

		 -- 因为table的索引从1开始

	else
		listItem = cell:getChildByTag(110)
		listItem:removeAllChildren();
		self:rankPlayerData(listItem, idx + 1);
	end
	return cell;
end

function CCBRewardProp:rankNumberOfCellsInTableView(table)
	if #self.m_playerRankData > 10 then
		return #self.m_playerRankData;
	else
		return 20;
	end
end

function CCBRewardProp:awardNodeSetData(node, index)
	local cellLine = cc.Sprite:create(ResourceMgr:getDomainNameLine());
	node:addChild(cellLine);
	local lineSize = cellLine:getContentSize();
	cellLine:setPosition(cc.p(self.m_cellSizeWidth * 0.5, lineSize.height * 0.5));
	local cellBgSprite = cc.Sprite:create(ResourceMgr:getDomainAwardRedBg());
	cellBgSprite:setAnchorPoint(cc.p(0, 0));
	node:addChild(cellBgSprite);
	cellBgSprite:setPosition(cc.p(0, lineSize.height));

	local rankTitleSprite = cc.Sprite:create(ResourceMgr:getDomainRankTitle());
	rankTitleSprite:setPosition(cc.p(60, 80));
	node:addChild(rankTitleSprite);

	local rankSprite = cc.Sprite:create(ResourceMgr:getDomainAwardRankByIndex(self.m_rankAwardData[tostring(index)].id));
	rankSprite:setPosition(cc.p(60, 40));
	node:addChild(rankSprite);

	local itemID = self.m_rankAwardData[tostring(index)].item_id;
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	local itemBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(itemLevel + 1));
	node:addChild(itemBg);
	itemBg:setScale(0.8);
	local itemIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(itemID));
	node:addChild(itemIcon);
	itemIcon:setScale(0.8);
	local itemFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(itemLevel + 1));
	node:addChild(itemFrame);
	itemFrame:setScale(0.8);
	itemBg:setPosition(cc.p(self.m_cellSizeWidth * 0.5 + 50, self.m_cellSizeHeight * 0.5 + 5));
	itemIcon:setPosition(cc.p(self.m_cellSizeWidth * 0.5 + 50, self.m_cellSizeHeight * 0.5 + 5));
	itemFrame:setPosition(cc.p(self.m_cellSizeWidth * 0.5 + 50, self.m_cellSizeHeight * 0.5 + 5));

	-- local showCurRank = nil;
	-- if self.m_playerRank > 0 then
	-- 	if index == 1 and self.m_playerRank == 1 then
	-- 		showCurRank = cc.Sprite:create(ResourceMgr:getDomainShowCurRank());
	-- 		node:addChild(showCurRank);
	-- 		showCurRank:setScale(0.9);
	-- 	elseif index > 1 then
	-- 		if self.m_playerRank > self.m_rankAwardData[tostring(index - 1)].rank and self.m_playerRank <= awardRank then
	-- 			showCurRank = cc.Sprite:create(ResourceMgr:getDomainShowCurRank());
	-- 			node:addChild(showCurRank);
	-- 			showCurRank:setScale(0.9);	
	-- 		end
	-- 	end
	-- end			
end

function CCBRewardProp:rankPlayerData(node, index)
	-- print(" rank table index  :  ", index);
	local data = self.m_playerRankData[index];
	local nameLabel = cc.LabelTTF:create();
	nameLabel:setFontSize(18);
	nameLabel:setPositionX(self.m_nameLabelPosX);
	node:addChild(nameLabel);

	local damageLabel = nil;
	local perLabel = nil;

	if index <= #self.m_playerRankData then
		nameLabel:setString(self.m_playerRankData[index].nickname);

		damageLabel = cc.LabelTTF:create();
		damageLabel:setFontSize(18);
		damageLabel:setPositionX(self.m_damageLabelPosX);
		node:addChild(damageLabel);
		damageLabel:setString(self.m_playerRankData[index].damage);

		perLabel = cc.LabelTTF:create();
		perLabel:setFontSize(18);
		perLabel:setPositionX(self.m_perLabelPosX);
		node:addChild(perLabel);
		perLabel:setString(self.m_playerRankData[index].damage_rate * 100 .. "%");
	else
		nameLabel:setString(Str[13001]);
	end

	if index == 1 then
		local rank1 = cc.Sprite:create(ResourceMgr:getDomainRank1())
		rank1:setPositionX(self.m_rankLabelPosX);
		node:addChild(rank1);
		nameLabel:setColor(goldColor);
		if index <= #self.m_playerRankData then
			damageLabel:setColor(goldColor);
			perLabel:setColor(goldColor);
		end
	elseif index == 2 then
		local rank2 = cc.Sprite:create(ResourceMgr:getDomainRank2());
		rank2:setPositionX(self.m_rankLabelPosX);
		node:addChild(rank2);
		nameLabel:setColor(pinkColor);
		if index <= #self.m_playerRankData then
			damageLabel:setColor(pinkColor);
			perLabel:setColor(pinkColor);
		end
	elseif index == 3 then
		local rank3 = cc.Sprite:create(ResourceMgr:getDomainRank3());
		rank3:setPositionX(self.m_rankLabelPosX);
		node:addChild(rank3);
		nameLabel:setColor(blueColor);
		if index <= #self.m_playerRankData then
			damageLabel:setColor(blueColor);
			perLabel:setColor(blueColor);
		end
	else
		local rankLabel = cc.LabelTTF:create();
		rankLabel:setString(index);
		rankLabel:setColor(grayColor);
		rankLabel:setPositionX(self.m_rankLabelPosX);
		rankLabel:setFontSize(18);
		node:addChild(rankLabel);
		nameLabel:setColor(grayColor);
		if index <= #self.m_playerRankData then
			damageLabel:setColor(grayColor);
			perLabel:setColor(grayColor);
		end
	end

	local lineSprite = cc.Sprite:create(ResourceMgr:getDomainNameLine());
	lineSprite:setScaleX(2.5);
	lineSprite:setScaleY(0.5);
	node:addChild(lineSprite);
	lineSprite:setPositionY(lineSpritePosY);
end

function CCBRewardProp:setPlayerSelfData(data)
	self.m_ccbLabelPlayerRank:setString(data.rank or Str[13001]);
	self.m_ccbLabelPlayerName:setString(data.nickname);
	self.m_ccbLabelPlayerDamage:setString(data.damage);
	self.m_ccbLabelPlayerDamagePer:setString(data.damage_rate * 100 .. "%");
end

function CCBRewardProp:onBtnClose()
	self:removeSelf();
	if self.m_showDescScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_showDescScheduler);
		self.m_showDescScheduler = nil;
	end
end

return CCBRewardProp;