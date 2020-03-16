local league_award = require("app.constants.league_award");
local rankAwardTable = require("app.constants.rank_award");
local ResourceMgr = require("app.utils.ResourceMgr");
local DescripProp = require("app.views.common.DescripProp");

local CCBRewardPropCell = require("app.views.leagueFight.CCBRewardPropCell");

local CCBRewardProp = class("CCBRewardProp", function()
	return CCBLoader("ccbi/leagueFight/CCBRewardProp");
end)

function CCBRewardProp:ctor(playerRank)
	if display.resolution  >= 2 then
		self.m_ccbLayerCenter:setScale(display.reduce);
	end

	self:createListener();

	self.m_playerRank = playerRank;

	self.m_rankAwardData = table.clone(league_award);
	self.m_awardTableSize = 0;
	table.sort(self.m_rankAwardData, function(a, b)
		return a.id < b.id;
	end)

	for k, v in pairs(self.m_rankAwardData) do 
		self.m_awardTableSize = self.m_awardTableSize + 1;
	end

	self.m_ccbDescripProp = nil;

	self:createTableViewAward();

	self:rankPlayerData();
end

function CCBRewardProp:rankPlayerData()
	self.m_playerRankData = clone(UserDataMgr.m_leagueData);

	self:createTableViewRank();

	self:setPlayerSelfData();
end

function CCBRewardProp:createListener()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event); end, cc.Handler.EVENT_TOUCH_BEGAN);
	
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function CCBRewardProp:onTouchBegan(touch, event)
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

	self.m_awardTableView:registerScriptHandler(function(table, cell) return self:awardTableCellTouched(table, cell); end, cc.TABLECELL_TOUCHED)
	self.m_awardTableView:registerScriptHandler(function(table, idx) return self:awardCellSizeForTable(table, idx); end, cc.TABLECELL_SIZE_FOR_INDEX)
	self.m_awardTableView:registerScriptHandler(function(table, idx) return self:awardTableCellAtIndex(table, idx); end, cc.TABLECELL_SIZE_AT_INDEX)
	self.m_awardTableView:registerScriptHandler(function(table) return self:awardNumberOfCellsInTableView(table); end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self.m_awardTableView:registerScriptHandler(function(table, cell) return self:awardTableCellHighLight(table, cell); end, cc.TABLECELL_HIGH_LIGHT);
	self.m_awardTableView:registerScriptHandler(function(table) return self:scrollViewDidScroll(table); end, cc.SCROLLVIEW_SCRIPT_SCROLL);
	self.m_awardTableView:registerScriptHandler(function(table, cell) return self:awardTableCellUnHighLight(table, cell); end, cc.TABLECELL_UNHIGH_LIGHT);

	self.m_awardTableView:reloadData()
end

--触摸Cell
function CCBRewardProp:awardTableCellTouched(table, cell)
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
	self.m_showDescTime = 0;
	self.m_tableOffset = table:getContentOffset();
	self.m_spacePos = cell:convertToWorldSpace(cc.p(cell:getChildByTag(110):getPositionX(), cell:getChildByTag(110):getPositionY()));

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
	local moveTableOffset = table:getContentOffset();
	if self.m_tableOffset then
		if math.abs(self.m_tableOffset.x - moveTableOffset.x) > 10 then
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
		self.m_ccbDescripProp = DescripProp:create(DescripProp.TYPE_AWARD);
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
	local listItem = nil;
	local cell = table:dequeueCell()
	if cell == nil then 
		cell = cc.TableViewCell:new();
		listItem = cc.Node:create();
		self:awardNodeSetData(listItem, idx + 1);

		cell:addChild(listItem)
		listItem:setTag(110)
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

	self.m_rankTableView:registerScriptHandler(function(table, idx) return self:rankCellSizeForTable(table, idx); end, cc.TABLECELL_SIZE_FOR_INDEX)
	self.m_rankTableView:registerScriptHandler(function(table, idx) return self:rankTableCellAtIndex(table, idx); end, cc.TABLECELL_SIZE_AT_INDEX)
	self.m_rankTableView:registerScriptHandler(function(table) return self:rankNumberOfCellsInTableView(table); end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

	self.m_rankTableView:reloadData()
end

function CCBRewardProp:rankCellSizeForTable(table, idx)
	return self.m_ccbNodeRankTable:getContentSize().width, self.m_ccbNodeRankTable:getContentSize().height/7;
end

function CCBRewardProp:rankTableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if cell == nil then 
		cell = cc.TableViewCell:new();
	end

	local listItem = cell:getChildByTag(110);
	if listItem == nil then
		listItem = CCBRewardPropCell:create();
		cell:addChild(listItem);
		listItem:setTag(110);
	end

	listItem:setData(self.m_playerRankData[idx+1])
	return cell;
end

function CCBRewardProp:rankNumberOfCellsInTableView(table)
	return #self.m_playerRankData;
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

	local rankSprite = cc.Sprite:create(ResourceMgr:getLeagueAwardRankByIndex(self.m_rankAwardData[tostring(index)].id));
	rankSprite:setPosition(cc.p(60, 40));
	node:addChild(rankSprite);

	local itemID = self.m_rankAwardData[tostring(index)].item_id;
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	local itemBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(itemLevel + 1));
	node:addChild(itemBg);
	itemBg:setScale(0.8);
	local itemIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(ItemDataMgr:getItemIconIDByItemID(itemID)));
	node:addChild(itemIcon);
	itemIcon:setScale(0.8);
	local itemFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(itemLevel + 1));
	node:addChild(itemFrame);
	itemFrame:setScale(0.8);
	itemBg:setPosition(cc.p(self.m_cellSizeWidth * 0.5 + 50, self.m_cellSizeHeight * 0.5 + 5));
	itemIcon:setPosition(cc.p(self.m_cellSizeWidth * 0.5 + 50, self.m_cellSizeHeight * 0.5 + 5));
	itemFrame:setPosition(cc.p(self.m_cellSizeWidth * 0.5 + 50, self.m_cellSizeHeight * 0.5 + 5));	
end

function CCBRewardProp:setPlayerSelfData()
	local data = UserDataMgr.m_leagueData[UserDataMgr.m_leagueAid];

	self.m_ccbLabelID:setString(data.id);
	self.m_ccbLabelName:setString(data.name);
	self.m_ccbLabelScore:setString(data.score);
	self.m_ccbLabelPower:setString(data.power);

	self.m_ccbSpriteRank:setTexture(ResourceMgr:getLeagueBadgeByIconID(data.iconID));
end

function CCBRewardProp:onBtnClose()
	self:removeSelf();
	if self.m_showDescScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_showDescScheduler);
		self.m_showDescScheduler = nil;
	end
end

return CCBRewardProp;