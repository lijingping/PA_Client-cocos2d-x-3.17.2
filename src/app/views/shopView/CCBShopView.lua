local CCBShopItemCell = require("app.views.shopView.CCBShopItemCell")
local Tips = require("app.views.common.Tips");

local LIST_TYPE_1 = 1;
local LIST_TYPE_2 = 2;
local LIST_TYPE_3 = 3;
local LIST_TYPE_4 = 4;
local LIST_TYPE_5 = 5;
local LIST_TYPE_6 = 6;
------------------
-- CCB商店界面
------------------
local CCBShopView = class("CCBShopView", function ()
	return CCBLoader("ccbi/shopView/CCBShopView.ccbi")
end)

local g_loadTable = {};

function CCBShopView:ctor()
	if display.resolution >= 2 then
		self:resolution();
	end

	self:init();
	self:createTouchEvent();
	-- self:setBtnTextont();
end

function CCBShopView:resolution()
	self:setScale(display.reduce);
	-- local resWindowPosY = self.node_resWindow:getPositionY();
	-- self.node_resWindow:setPositionY(resWindowPosY-display.offsetY)
end

function CCBShopView:init()
	self.m_propsTable = {};
	self.m_goldCoinTable = {}; --金币table(暂时不用)
	self.m_friendshipTable = {};
	self.m_decomposeTable = {};
	self.m_unionShopTable = {};

	-- print("开始的时间", os.time())
	local shopItemList = table.clone(require("app.constants.shop"))
	-- print("结束的时间", os.clock())
	for k, v in pairs(shopItemList) do
		if v.type == LIST_TYPE_1 then
			table.insert(self.m_propsTable, v);
		elseif v.type == LIST_TYPE_2 then
			table.insert(self.m_goldCoinTable, v);
		elseif v.type == LIST_TYPE_4 then
			table.insert(self.m_friendshipTable, v);
		elseif v.type == LIST_TYPE_6 then
			table.insert(self.m_decomposeTable, v);
		elseif v.type == LIST_TYPE_5 then
			table.insert(self.m_unionShopTable, v);
		end
	end
	table.sort(self.m_propsTable, function(a, b)
		return a.order < b.order;
	end);
	table.sort(self.m_friendshipTable, function(a, b)
		return a.order < b.order;
	end);
	table.sort(self.m_decomposeTable, function(a, b)
		return a.order < b.order;
	end);
	table.sort(self.m_unionShopTable, function(a, b)
		return a.order < b.order;
	end);
	-- dump(self.m_propsTable);
	-- dump(self.m_friendshipTable);
	-- dump(self.m_decomposeTable);

	g_loadTable = self.m_propsTable;	
	self:createTableView();

	self.m_ccbBtnProps:setEnabled(false);
	-- local tab = self:createTabBar()
	-- self.pos_tab:add(tab)
end

function CCBShopView:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.m_ccbNodeTouch);
end

function CCBShopView:onTouchBegan(touch, event)
	self.m_beganPos = touch:getLocation();
	return true;
end

function CCBShopView:onTouchMoved(touch, event)
end

function CCBShopView:onTouchEnded(touch, event)
end

-- 按钮字体设置
function CCBShopView:setBtnTextont()
	self.m_ccbBtnProps:setTitleBMFontForState("res/resources/font/ui_font.fnt", cc.CONTROL_STATE_NORMAL);
	self.m_ccbBtnProps:setTitleBMFontForState("res/resources/font/ui_font.fnt", cc.CONTROL_STATE_DISABLED);
end

function CCBShopView:onBattleClicked()
	print("battle");
end

function CCBShopView:createTableView()
	self.m_tableViewSize = self.m_ccbLayerTableView:getContentSize();
	self.m_tableView = cc.TableView:create(self.m_tableViewSize);
	self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	self.m_tableView:setDelegate();
	self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
	self.m_ccbLayerTableView:addChild(self.m_tableView);
	self.m_tableView:registerScriptHandler(function (table, cell) self:tableCellTouched(table, cell); end, cc.TABLECELL_TOUCHED);
	self.m_tableView:registerScriptHandler(function (table, idx) return self:cellSizeForTable(table, idx) end, cc.TABLECELL_SIZE_FOR_INDEX);
	self.m_tableView:registerScriptHandler(function (table, idx) return self:tableCellAtIndex(table, idx) end, cc.TABLECELL_SIZE_AT_INDEX);
	self.m_tableView:registerScriptHandler(function (table) return self:numberOfCellsInTableView(table) end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);

	self.m_tableView:reloadData();
end

function CCBShopView:tableCellTouched(table, cell)
	local cellPos = cell:convertToNodeSpace(self.m_beganPos);
	for i = 1, 4 do 
		local cellItem = cell:getChildByTag(100 + i);
		if cellItem:isVisible() and cc.rectContainsPoint(cellItem:getBoundingBox(), cellPos) then
			local itemData = cellItem:getItemData();

			local itemBuyTimes = ItemDataMgr:getBuyTimes()[itemData.id];
			itemBuyTimes = (itemBuyTimes and itemBuyTimes or 0);

			if itemData.require_alliance_level ~= 0 and itemData.require_alliance_level > UserDataMgr:getPlayerUnionLevel() then
				Tips:create(Str[16004]);
			elseif itemData.contribution ~= 0 and itemData.contribution > UserDataMgr:getPlayerContribution() then
				Tips:create(Str[16005]);
			elseif itemData.day_limit ~= 0 and itemBuyTimes >= itemData.day_limit then
				Tips:create(Str[16006]);
			else
				App:getRunningScene():getViewBase():showSetAmountPopup(itemData, cellItem);
			end
			break;
		end
	end
end

function CCBShopView:cellSizeForTable(table, idx)
	print(" cellSizeForTable    idx ..:  " , idx);
	return self.m_tableViewSize.width, 300;
end

function CCBShopView:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell();
	local cellItem = {};
	-- local listItem1, listItem2 = nil, nil;
	print("  setData..    idx:", idx);
	if cell == nil then
		cell = cc.TableViewCell:new();
		for i = 1, 4 do 
			cellItem[i] = CCBShopItemCell:create();
			cellItem[i]:setTag(100 + i);
			cell:addChild(cellItem[i]);
			cellItem[i]:setPosition((i - 1) * (10 + cellItem[i]:getContentSize().width), 5);
			if g_loadTable[idx * 4 + i] ~= nil then
				cellItem[i]:setData(g_loadTable[idx * 4 + i]);
			else
				cellItem[i]:setVisible(false);
			end
		end

		-- listItem1 = CCBShopItemCell:create();
		-- listItem1:setPosition(cc.p(5, 5 + listItem1.m_ccbSpriteCellBg:getContentSize().height + 10));
		-- listItem1:setTag(100);
		-- listItem1:setData(g_loadTable[idx * 2 + 1]);
		-- cell:addChild(listItem1);

		-- listItem2 = CCBShopItemCell:create();
		-- listItem2:setPosition(5, 5);
		-- listItem2:setTag(101);		
		-- cell:addChild(listItem2);
		-- if math.ceil(#g_loadTable / 2) == idx + 1 and #g_loadTable % 2 == 1 then
		-- 	listItem2:setVisible(false);
		-- else
		-- 	listItem2:setVisible(true);
		-- 	listItem2:setData(g_loadTable[idx * 2 + 2]);
		-- end
	else
		for i = 1, 4 do 
			cellItem[i] = cell:getChildByTag(100 + i);
			if g_loadTable[idx * 4 + i] ~= nil then
				cellItem[i]:setVisible(true);
				cellItem[i]:setData(g_loadTable[idx * 4 + i]);
			else
				cellItem[i]:setVisible(false);
			end
		end
		-- listItem1 = cell:getChildByTag(100);
		-- if listItem1 then
		-- 	listItem1:setData(g_loadTable[idx * 2 + 1]);
		-- end

		-- listItem2 = cell:getChildByTag(101);
		-- if listItem2 then
		-- 	if math.ceil(#g_loadTable / 2) == idx + 1 and #g_loadTable % 2 == 1 then
		-- 		listItem2:setVisible(false);
		-- 	else
		-- 		listItem2:setVisible(true);
		-- 		listItem2:setData(g_loadTable[idx * 2 + 2]);
		-- 	end
		-- end

	end
	return cell;
end

function CCBShopView:numberOfCellsInTableView(table)
	return math.ceil(#g_loadTable / 4);
end

function CCBShopView:onBtnProps()
	self.m_ccbBtnProps:setEnabled(false);
	self.m_ccbBtnFriendship:setEnabled(true);
	self.m_ccbBtnDecompose:setEnabled(true);
	self.m_ccbBtnUnion:setEnabled(true);

	g_loadTable = self.m_propsTable;
	self.m_tableView:reloadData();

	self:changeTitlePanel(LIST_TYPE_1);
end

function CCBShopView:onBtnFriendship()
	self.m_ccbBtnProps:setEnabled(true);
	self.m_ccbBtnFriendship:setEnabled(false);
	self.m_ccbBtnDecompose:setEnabled(true);
	self.m_ccbBtnUnion:setEnabled(true);

	g_loadTable = self.m_friendshipTable;
	self.m_tableView:reloadData();

	self:changeTitlePanel(LIST_TYPE_4);
end

function CCBShopView:onBtnDecompose()
	self.m_ccbBtnProps:setEnabled(true);
	self.m_ccbBtnFriendship:setEnabled(true);
	self.m_ccbBtnDecompose:setEnabled(false);
	self.m_ccbBtnUnion:setEnabled(true);

	g_loadTable = self.m_decomposeTable;
	self.m_tableView:reloadData();

	self:changeTitlePanel(LIST_TYPE_6);
end

function CCBShopView:onBtnLeague()
	self.m_ccbBtnProps:setEnabled(true);
	self.m_ccbBtnFriendship:setEnabled(true);
	self.m_ccbBtnDecompose:setEnabled(true);
	self.m_ccbBtnUnion:setEnabled(false);

	g_loadTable = self.m_unionShopTable;
	self.m_tableView:reloadData();

	self:changeTitlePanel(LIST_TYPE_5);
end

function CCBShopView:changeTitlePanel(listType)
	local viewBase = App:getRunningScene():getViewBase();
	if LIST_TYPE_4 == listType then
		viewBase:showNodeFriendship();
		viewBase:hideNodeResolvePoint();
		viewBase:hideNodeLeague();
	elseif LIST_TYPE_6 == listType then
		viewBase:hideNodeFriendship();
		viewBase:showNodeResolvePoint();
		viewBase:hideNodeLeague();
	elseif LIST_TYPE_5 == listType then
		viewBase:hideNodeFriendship();
		viewBase:hideNodeResolvePoint();
		viewBase:showNodeLeague();
	else
		viewBase:hideNodeFriendship();
		viewBase:hideNodeResolvePoint();
		viewBase:hideNodeLeague();
	end
end

return CCBShopView