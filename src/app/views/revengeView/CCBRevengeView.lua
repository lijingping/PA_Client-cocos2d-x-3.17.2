local Tips = require("app.views.common.Tips");
local CCBRevengeViewCell = require("app.views.revengeView.CCBRevengeViewCell")


-----------------------
-- CCB复仇名单列表界面
-----------------------
local CCBRevengeView = class("CCBRevengeView", function ()
	return CCBLoader("ccbi/revengeView/CCBRevengeView.ccbi")
end)

function CCBRevengeView:ctor()	
    if display.resolution >= 2 then
        self.m_ccbNodeMain:setScale(display.reduce);
    end

    self:requestRevengeList();

	self.m_tableView = nil;
	self:createTableView();
    self.m_ccbLabelTips:setVisible(false);
end

function CCBRevengeView:createTableView()
	--创建tableview并设置参数
	self.m_tableView = cc.TableView:create(self.m_ccbLayerViewSize:getContentSize());
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    --self.m_tableView:setDelegate()
    self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.m_ccbLayerViewSize:addChild(self.m_tableView)
    
    --注册响应函数
    self.m_tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx); end, cc.TABLECELL_SIZE_FOR_INDEX);
    self.m_tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx); end, cc.TABLECELL_SIZE_AT_INDEX);
    self.m_tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table); end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);
 	--刷新cells数据
    self.m_tableView:reloadData()
end

--一个cell的size
function CCBRevengeView:cellSizeForTable(table, idx)
	return 1180, 110;
end
--生成列表每一项的内容
function CCBRevengeView:tableCellAtIndex(table, idx)
	--print("##CCBRevengeView:tableCellAtIndex:" .. idx);
	local listItem1, listItem2 = nil, nil;
    local cell = table:dequeueCell()

    if nil == cell then
    	cell = cc.TableViewCell:new();

    	listItem1 = CCBRevengeViewCell:create();
    	listItem1:setPosition(cc.p(0,0))
     --    --listItem1:setAnchorPoint(cc.p(0,0))
    	listItem1:setTag(111);
    	cell:addChild(listItem1);
    	listItem1:setData(RevengeDataMgr:getData()[idx*2+1]);

    	listItem2 = CCBRevengeViewCell:create();
    	listItem2:setPosition(cc.p(listItem1.m_ccbScale9SpriteBG:getContentSize().width + 5, 0))
     --    --listItem2:setAnchorPoint(cc.p(0,0))
    	listItem2:setTag(112);
    	cell:addChild(listItem2);
    	if math.ceil(#RevengeDataMgr:getData() / 2) == idx + 1 and #RevengeDataMgr:getData() % 2 == 1 then
            listItem2:setVisible(false);
        else
        	listItem2:setData(RevengeDataMgr:getData()[idx*2+2]);
        	listItem2:setVisible(true);
        end        
    else
    	listItem1 = cell:getChildByTag(111);
        if listItem1 then
        	listItem1:setData(RevengeDataMgr:getData()[idx*2+1]);
        end
    	listItem2 = cell:getChildByTag(112);
        if listItem2 then 
			if math.ceil(#RevengeDataMgr:getData() / 2) == idx + 1 and #RevengeDataMgr:getData() % 2 == 1 then
      			listItem2:setVisible(false);
   			 else
   			 	listItem2:setData(RevengeDataMgr:getData()[idx*2+2]);
    			listItem2:setVisible(true);
    		end
        end
    end

    return cell
end

--返回列表的子项的个数
function CCBRevengeView:numberOfCellsInTableView(table)
	return math.ceil(#RevengeDataMgr:getData() / 2); -- math.ceil 向上取整函数。
end

--请求复仇列表
function CCBRevengeView:requestRevengeList()
    print("请求复仇的复仇对象列表")
    local function requestCallBack(rc, reveiveData)
        if reveiveData.code ~= 1 then
            Tips:create(ServerCode[reveiveData.code]);
            return;
        end

        if #reveiveData.data ~= 0 then
            if 0 == #RevengeDataMgr:getData() then
                RevengeDataMgr:insert(reveiveData.data);
            else
                for k, v in pairs(reveiveData.data) do
                    RevengeDataMgr:setData(v, k);
                end
            end
            table.sort(RevengeDataMgr:getData(), function(a, b)
                return a.sort < b.sort;
            end)
            if self.m_tableView then
               self.m_tableView:reloadData();
            end
        else
            RevengeDataMgr:clearData();
        end

        self.m_ccbLabelTips:setVisible(#reveiveData.data == 0);
    end
    Network:request("social.friendHandler.revenge_list", nil, requestCallBack)
end

function CCBRevengeView:setListInRequest(uid)
    --print("CCBRevengeView:setListInRequest", uid);
    for k, v in pairs(RevengeDataMgr:getData()) do
        --dump(v);
        if v.uid == uid then
            v.stateIsInRequest = false;
            v.m_curSystemTime = os.time();
            v.revenge_remain_second = 60;
            self.m_tableView:reloadData();
            Tips:create("玩家" .. v.nickname .. "拒绝了你的复仇，1分钟后可再次复仇");
            self.m_ccbLabelTips:setVisible(#RevengeDataMgr:getData() == 0);
            return;
        end
    end
    
end


return CCBRevengeView