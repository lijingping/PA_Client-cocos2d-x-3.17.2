local CCBLeagueApplyListCell = require("app.views.leagueActivity.CCBLeagueApplyListCell")
-----------------------
local CCBLeagueApplyList = class("CCBLeagueApplyList", function ()
	return CCBLoader("ccbi/leagueActivity/CCBLeagueApplyList.ccbi")
end)

function CCBLeagueApplyList:ctor()	
    if display.resolution >= 2 then
        self.m_ccbLayerCenter:setScale(display.reduce);
    end

    self.m_ccbNodeOpen:setVisible(not UserDataMgr.m_isJoinClose);
    self.m_ccbNodeClose:setVisible(UserDataMgr.m_isJoinClose);

    self.m_data = {};

	self.m_tableView = nil;
	self:createTableView();
    self.m_ccbLabelTips:setVisible(false);
    self:requestList();
end

function CCBLeagueApplyList:createTableView()
	--创建tableview并设置参数
	self.m_tableView = cc.TableView:create(self.m_ccbNodeTableView:getContentSize());
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    --self.m_tableView:setDelegate()
    self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.m_ccbNodeTableView:addChild(self.m_tableView)
    
    --注册响应函数
    self.m_tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx); end, cc.TABLECELL_SIZE_FOR_INDEX);
    self.m_tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx); end, cc.TABLECELL_SIZE_AT_INDEX);
    self.m_tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table); end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);
 	--刷新cells数据
    self.m_tableView:reloadData()
end

--一个cell的size
function CCBLeagueApplyList:cellSizeForTable(table, idx)
	return 1080, 100;
end
--生成列表每一项的内容
function CCBLeagueApplyList:tableCellAtIndex(table, idx)
	local listItem1, listItem2 = nil, nil;
    local cell = table:dequeueCell()
    if nil == cell then
    	cell = cc.TableViewCell:new();
    end

    listItem1 = cell:getChildByTag(111);
    if listItem1 == nil then
    	listItem1 = CCBLeagueApplyListCell:create();
    	listItem1:setTag(111);
    	cell:addChild(listItem1);
    end
	listItem1:setData(self.m_data[idx*2+1]);

    if listItem2 == nil then
    	listItem2 = CCBLeagueApplyListCell:create();
    	listItem2:setPosition(540, 0)
    	listItem2:setTag(112);
    	cell:addChild(listItem2);
    end

	if math.ceil(#self.m_data / 2) == idx+1 and #self.m_data%2 == 1 then
        listItem2:setVisible(false);
    else
    	listItem2:setData(self.m_data[idx*2+2]);
    	listItem2:setVisible(true);
    end        

    return cell
end

--返回列表的子项的个数
function CCBLeagueApplyList:numberOfCellsInTableView(table)
	return math.ceil(#self.m_data / 2); -- math.ceil 向上取整函数。
end

--请求复仇列表
function CCBLeagueApplyList:requestList()
    for i=1,10 do
        self.m_data[i] = {
            level = i,
            nickname = "联盟"..1,
            power = 100 + i,
            famous_num=i};
    end
    self.m_tableView:reloadData();
end

function CCBLeagueApplyList:onBtnAllAccept()
end
function CCBLeagueApplyList:onBtnAllReject()
end
function CCBLeagueApplyList:onBtnCondition()
    UserDataMgr.m_isJoinClose = not UserDataMgr.m_isJoinClose;

    self.m_ccbNodeOpen:setVisible(not UserDataMgr.m_isJoinClose);
    self.m_ccbNodeClose:setVisible(UserDataMgr.m_isJoinClose);

    UserDataMgr.m_leagueData[UserDataMgr.m_leagueAid].state = UserDataMgr.m_isJoinClose and 2 or 1;
end

return CCBLeagueApplyList