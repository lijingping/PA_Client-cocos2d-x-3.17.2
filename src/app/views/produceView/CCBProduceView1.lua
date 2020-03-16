local CCBProduceView1Cell = require("app.views.produceView.CCBProduceView1Cell");
local CCBProduceSpeedUp = require("app.views.produceView.CCBProduceSpeedUp")
local Tips = require("app.views.common.Tips");

local CCBProduceView1 = class("CCBProduceView1", function()
	return CCBLoader("ccbi/produceView/CCBProduceView1.ccbi")
end)

function CCBProduceView1:onEnter()
	
end

function CCBProduceView1:onExit()
	if self.m_tableView then
		ProduceDataMgr:setOffsetProduceView1(self.m_tableView:getContentOffset());
	end
end

function CCBProduceView1:ctor()
	self:enableNodeEvents();
	self:requestProduceQueue();
	self:createTableView();
	self.m_ccbProduceSpeedUp = nil;
	
end

function CCBProduceView1:createViewSpeedUp(cell)
	if self.m_ccbProduceSpeedUp == nil then
		self.m_ccbProduceSpeedUp = CCBProduceSpeedUp:create(cell);
		App:getRunningScene():addChild(self.m_ccbProduceSpeedUp, display.Z_UILAYER);
	end
end

function CCBProduceView1:closeViewSpeedUp()
	if self.m_ccbProduceSpeedUp then
		self.m_ccbProduceSpeedUp:removeSelf();
		self.m_ccbProduceSpeedUp = nil;
	end
end

function CCBProduceView1:requestProduceQueue()
	Network:request("game.syncHandler.produceQueue", "", function(rc, data) -- 请求生产队列数据
		--print("生产队列,包含解锁状态与生产状态");
		if data.code ~= 1 then
			Tips:create(GameData:get("code_map", data.code)["desc"])
			return
		end
		-- dump(data)
		ProduceDataMgr:setProduceQueue(data.items);
		self:updateQueue();
	end)
end

function CCBProduceView1:updateQueue()
	if self.m_tableView then
		local offset = self.m_tableView:getContentOffset();
		self.m_tableView:reloadData();
		self.m_tableView:setContentOffset(offset)
	end
end

function CCBProduceView1:createTableView()
	-- local tableSize = self.m_ccbLayerViewSize:getContentSize();
	self.m_tableView = cc.TableView:create(cc.size(display.width, 960));
    self.m_tableView:setDelegate();
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL); --从左到右
    self.m_ccbLayerViewSize:addChild(self.m_tableView);
    
    --注册响应函数
    self.m_tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx) end, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end, cc.TABLECELL_SIZE_AT_INDEX)
    self.m_tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.m_tableView:reloadData();
    self.m_tableView:setContentOffset(ProduceDataMgr:getOffsetProduceView1());

end

function CCBProduceView1:cellSizeForTable(table, idx)
	return 300, display.height;
end

function CCBProduceView1:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell();
	if cell == nil then
		cell = cc.TableViewCell:create();
		local ccbNode = CCBProduceView1Cell:create();
		cell:addChild(ccbNode);
		ccbNode:setTag(123);
		ccbNode:setInfoByCellIndex(idx);
	else
		local ccbNode = cell:getChildByTag(123);
		if ccbNode then
			ccbNode:setInfoByCellIndex(idx);
		end
	end

	return cell;
end

function CCBProduceView1:numberOfCellsInTableView(table)
	return #ProduceDataMgr:getProduceQueue();
end

function CCBProduceView1:setTableViewTouchEnabled(isEnabled)
	self.m_tableView:setTouchEnabled(isEnabled);
end

return CCBProduceView1;