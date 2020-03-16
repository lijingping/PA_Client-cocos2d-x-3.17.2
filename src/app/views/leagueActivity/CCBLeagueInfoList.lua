
local ResourceMgr = require("app.utils.ResourceMgr");
local CCBLeagueInfoListCell = require("app.views.leagueActivity.CCBLeagueInfoListCell");
local CCBMsgBox = require("app.views.leagueActivity.CCBMsgBox");
local CCBLeagueDynamic = require("app.views.leagueActivity.CCBLeagueDynamic");
-----------------------
local CCBLeagueInfoList = class("CCBLeagueInfoList", function ()
	return CCBLoader("ccbi/leagueActivity/CCBLeagueInfoList.ccbi")
end)

function CCBLeagueInfoList:ctor()
    self:enableNodeEvents();

    if display.resolution >= 2 then
        self.m_ccbLayerCenter:setScale(display.reduce);
    end

    self.m_data = UserDataMgr.m_leagueData[UserDataMgr.m_leagueAid];
    self.m_ccbLabelName:setString(self.m_data.name)
    self.m_ccbLabelChairname:setString(self.m_data.chairman_name)
    self.m_ccbNodeHead:addChild(cc.Sprite:create(ResourceMgr:getLeagueBadgeByIconID(self.m_data.iconID)));
    self.m_ccbLabelDesc:setString(self.m_data.notice)

    self.m_list = {};
	self:createTableView();
end

function CCBLeagueInfoList:onEnter()
    self:requestList();
end

function CCBLeagueInfoList:onExit()
end

function CCBLeagueInfoList:createTableView()
	--创建tableview并设置参数
    self.m_tableViewSize = self.m_ccbNodeTableView:getContentSize();
	self.m_tableView = cc.TableView:create(self.m_tableViewSize);
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
function CCBLeagueInfoList:cellSizeForTable(table, idx)
	return self.m_tableViewSize.width, 108;
end
--生成列表每一项的内容
function CCBLeagueInfoList:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
    	cell = cc.TableViewCell:new();
    end

    local listItem = cell:getChildByTag(111);
    if listItem == nil then
    	listItem = CCBLeagueInfoListCell:create();
    	listItem:setTag(111);
    	cell:addChild(listItem);
    end

    listItem:setData(self.m_list[idx+1]);

    return cell
end

--返回列表的子项的个数
function CCBLeagueInfoList:numberOfCellsInTableView(table)
	return #self.m_list;
end

function CCBLeagueInfoList:requestList()
    for i=1,10 do
        local online = math.random(1, 3)
        self.m_list[i] = {
            level = i,
            nickname = "联盟"..1,
            online = (1 == online),
            loginTime = ((3 == online) and string.format("最后登入时间：%d分钟之前", i) or nil),
            power = 100 + i,
            famous_num=100-10*i,
            isChairman = (i==1),
            isSubChairman = (i==2 or i==3)};
    end

    self.m_data.member_count = #self.m_list
    self.m_tableView:reloadData();
end

function CCBLeagueInfoList:onBtnChangeIcon()
end

function CCBLeagueInfoList:onBtnDynamic()
    App:getRunningScene():addChild(CCBLeagueDynamic:create());
end

function CCBLeagueInfoList:onBtnExit()
    App:getRunningScene():addChild(CCBMsgBox:create({callFun=function()
        UserDataMgr:setPlayerUnionLevel(0);
        UserDataMgr.m_leagueAid = 0
        
        App:enterScene("LeagueScene");
    end}));
end

function CCBLeagueInfoList:onBtnModifyNotify()
end

return CCBLeagueInfoList