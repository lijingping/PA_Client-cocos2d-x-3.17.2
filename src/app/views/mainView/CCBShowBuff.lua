local CCBBuffCell = import(".CCBBuffCell");

local CCBShowBuff = class("CCBShowBuff", function()
	return CCBLoader("ccbi/mainView/CCBShowBuff.ccbi");
end)

local cellHeight = 115;

function CCBShowBuff:ctor()
	if display.resolution >= 2 then
        self.m_ccbNodeCenter:setScale(display.reduce);
    end
	self:setPosition(display.center);

	self:enableNodeEvents();
	self.m_showList = {};
	self:createTouchListener();
	self:createShowList();
	self:createTableView();
end

function CCBShowBuff:onEnter()
	if self.m_updateScheduler == nil then
		self.m_updateScheduler = self:getScheduler():scheduleScriptFunc(function() 
			self:createShowList();
			local offset = self.m_tableView:getContentOffset();
			self.m_tableView:reloadData();
			self.m_tableView:setContentOffset(offset)
		end, 1, false);
	end
end

function CCBShowBuff:onExit()
	if self.m_updateScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_updateScheduler);
		self.m_updateScheduler = nil;
	end
end

function CCBShowBuff:createShowList()
	self.m_showList = {};
	-- local list1 = {};
	-- list1.time = UserDataMgr:getLeftTimePlayerInvisible();
	-- if list1.time > 0 then
	-- 	list1.iconID = 4001;
	-- 	list1.str = Str[15001];
	-- 	table.insert(self.m_showList, list1)
	-- end
	local list2 = {};
	list2.time = UserDataMgr:getLeftTimeDoubleFloater();
	if list2.time > 0 then
		list2.iconID = 4008;
		list2.str = Str[15002];
		table.insert(self.m_showList, list2);
	end
	local list3 = {};
	list3.time = UserDataMgr:getLeftTimeDoubleFriendship();
	if list3.time > 0 then
		list3.iconID = 4007;
		list3.str= Str[15003];
		table.insert(self.m_showList, list3)
	end
	if #self.m_showList == 0 then
		self:removeSelf();
	end
end

function CCBShowBuff:createTouchListener()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return true; end, cc.Handler.EVENT_TOUCH_BEGAN);
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self);	
end

function CCBShowBuff:createTableView()
	self.m_tableViewSize = self.m_ccbNodeBuff:getContentSize()

	self.m_tableView = cc.TableView:create(self.m_tableViewSize)
	self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	self.m_tableView:setDelegate()
	self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self.m_ccbNodeBuff:addChild(self.m_tableView)

	self.m_tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx); end, cc.TABLECELL_SIZE_FOR_INDEX)
	self.m_tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx); end, cc.TABLECELL_SIZE_AT_INDEX)
	self.m_tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table); end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

	self.m_tableView:reloadData()
end

function CCBShowBuff:cellSizeForTable(table, idx)
	return self.m_tableViewSize.width, cellHeight;
end

function CCBShowBuff:tableCellAtIndex(table, idx)
	
	local cell = table:dequeueCell();
	local listItem = nil;
	if cell == nil then 
		cell = cc.TableViewCell:new();
		listItem = CCBBuffCell:create();
		listItem:setData(self.m_showList[idx+1]);
		listItem:setTag(110)		
		cell:addChild(listItem)
	else
		listItem = cell:getChildByTag(110)
		listItem:setData(self.m_showList[idx+1]);
	end
	return cell;
end

function CCBShowBuff:numberOfCellsInTableView(table)
	return #self.m_showList;
end

function CCBShowBuff:onBtnClose()
	self:removeSelf();
end

return CCBShowBuff;