local CCBFightRecordListCell = require("app.views.leagueFight.CCBFightRecordListCell");
local LeagueConsts = require("app.views.leagueView.LeagueConsts");

local CCBFightRecordList = class("CCBFightRecordList", function()
	return CCBLoader("ccbi/leagueFight/CCBFightRecordList")
end)

function CCBFightRecordList:ctor()
	if display.resolution  >= 2 then
		self.m_ccbLayerCenter:setScale(display.reduce);
	end

	self:setData();
end

function CCBFightRecordList:setData()
	self.m_data = {};
	local result
	for i=1,10 do
		result = math.random(1, 3)
        self.m_data[i] = {
        	id=i,
            nickname="超能陆战队".. i,
            result=(result==1 and "胜利" or (result==2 and "平局" or "失败")),
            resultColor = (result==1 and cc.GREEN or (result==2 and cc.WHITE or cc.RED)),
            info="龙鳞城下赛因" ..i,
            time="2019-6-" .. i,
			score=1000+i,
			iconID=i%(LeagueConsts.MAX_BADGE)+1
		};
    end

	self:createTableView();
end

function CCBFightRecordList:createTableView()
	local listSize = self.m_ccbNodeTableView:getContentSize()

	self.m_tableView = cc.TableView:create(listSize)
	self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	self.m_tableView:setDelegate()
	self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self.m_ccbNodeTableView:addChild(self.m_tableView)

	self.m_tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx); end, cc.TABLECELL_SIZE_FOR_INDEX)
	self.m_tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx); end, cc.TABLECELL_SIZE_AT_INDEX)
	self.m_tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table); end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

	self.m_tableView:reloadData()
end

function CCBFightRecordList:cellSizeForTable(table, idx)
	return self.m_ccbNodeTableView:getContentSize().width, self.m_ccbNodeTableView:getContentSize().height/8;
end

function CCBFightRecordList:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if cell == nil then 
		cell = cc.TableViewCell:new();
	end

	local listItem = cell:getChildByTag(110);
	if listItem == nil then
		listItem = CCBFightRecordListCell:create();
		cell:addChild(listItem);
		listItem:setTag(110);
	end

	listItem:setData(self.m_data[idx+1])
	return cell;
end

function CCBFightRecordList:numberOfCellsInTableView(table)
	return #self.m_data;
end

function CCBFightRecordList:onBtnClose()
	self:removeSelf();
end

return CCBFightRecordList;