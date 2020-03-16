
local CCBLeagueDynamicList = class("CCBLeagueDynamicList", cc.Node)

function CCBLeagueDynamicList:ctor()
    self.m_data = {};
end

function CCBLeagueDynamicList:setData(data)
    self.m_data = data;
end

function CCBLeagueDynamicList:setCell(cell)
    self.m_cell = cell;
end

function CCBLeagueDynamicList:createTableView(tableViewSize, cellSize)
	--创建tableview并设置参数
    self.m_tableViewSize = tableViewSize;
    self.m_cellSize = cellSize;

	self.m_tableView = cc.TableView:create(self.m_tableViewSize);
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
    --self.m_tableView:setDelegate()
    self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
    self:addChild(self.m_tableView);
    
    --注册响应函数
    self.m_tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx); end, cc.TABLECELL_SIZE_FOR_INDEX);
    self.m_tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx); end, cc.TABLECELL_SIZE_AT_INDEX);
    self.m_tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table); end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);
 	--刷新cells数据
    self.m_tableView:reloadData();
end

--一个cell的size
function CCBLeagueDynamicList:cellSizeForTable(table, idx)
	return self.m_cellSize.width, self.m_cellSize.height;
end
--生成列表每一项的内容
function CCBLeagueDynamicList:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
    	cell = cc.TableViewCell:new();
    end

    local listItem = cell:getChildByTag(111);
    if listItem == nil then
        listItem = self.m_cell:create();
    	listItem:setTag(111);
    	cell:addChild(listItem);
    end

    listItem:setData(self.m_data[idx+1]);

    return cell
end

--返回列表的子项的个数
function CCBLeagueDynamicList:numberOfCellsInTableView(table)
	return #self.m_data;
end

return CCBLeagueDynamicList