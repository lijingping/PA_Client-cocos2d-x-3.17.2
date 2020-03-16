local CCBLeagueApplyCell = require("app.views.leagueView.CCBLeagueApplyCell");
local CCBLeagueCreate = require("app.views.leagueView.CCBLeagueCreate");
local LeagueConsts = require("app.views.leagueView.LeagueConsts");
-------------------
-- CCB主界面
-------------------
local CCBLeagueApply = class("CCBLeagueApply", function ()
	return CCBLoader("ccbi/leagueView/CCBLeagueApply.ccbi")
end)

function CCBLeagueApply:ctor()
	if display.resolution >= 2 then
    	self.m_ccbLayerCenter:setScale(display.reduce);
    end

	self:enableNodeEvents();

	self.m_listData = {};

	self:createTableView();

	self.m_ccbLabelPresident:setString("");
	self.m_ccbLabelDesc:setString("");

	-- 创建EditBox
	local boxSize = self.m_ccbNodeInput:getContentSize();
	self.m_editBox = cc.EditBox:create(boxSize, "res/resources/friendView/friend_input.png");
	self.m_editBox:setAnchorPoint(cc.p(0, 0));
	self.m_editBox:setFontSize(20);
	self.m_editBox:setFontColor(cc.c3b(255, 255, 255));
	self.m_editBox:setPlaceholderFontSize(20);
	self.m_editBox:setPlaceholderFontColor(cc.c3b(102, 102, 102));
	self.m_editBox:setPlaceHolder(Str[24001]);
	self.m_editBox:setMaxLength(120);
	self.m_editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE);
	self.m_editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
	self.m_ccbNodeInput:addChild(self.m_editBox);

	local function editBoxTextEventHandle(stringEventName, pSender)
		if stringEventName == "changed" then
			local editBoxLen, chNum, enNum = Utils:getStringLenth(pSender:getText());
			if editBoxLen >= 120 then
				pSender:setMaxLength(chNum + enNum);
			else
				pSender:setMaxLength(120);
			end
		end
	end	
	self.m_editBox:registerScriptEditBoxHandler(editBoxTextEventHandle);
end

function CCBLeagueApply:onEnter()
	self:flushList();
end

function CCBLeagueApply:onExit()
end

function CCBLeagueApply:flushList()
	--test data
	if #UserDataMgr.m_leagueData <= 0 then
		local name = {"打发", "12121", "tttt", "%%^^^@@", "kekk", "哦哦突突", "电放费", "21归属感", "#*&……大", "麻痹4X3cn.com"}
		for i=1,10 do
			local data = {}
			data.id = i
			data.aid = i
			data.name = name[i]
			data.state = math.random(1, 2);
			data.chairman_name = "会长".. i;
			data.notice = [[联盟联盟公告联盟公告联盟公告联盟公告联盟公告联盟公告联盟公告联盟公告]] .. data.name.. data.chairman_name .. i
			data.level=i
			data.power=100+i
			data.member_count=10
			data.member_limit =50
			data.score= 1000+i
			data.iconID=i%(LeagueConsts.MAX_BADGE)+1
			self.m_listData[i] = data;
		end
		UserDataMgr.m_leagueData = clone(self.m_listData);
	else
		self.m_listData = clone(UserDataMgr.m_leagueData);
	end
	self.m_listView:reloadData();
end

function CCBLeagueApply:onExit()
end

function CCBLeagueApply:createTableView()
	self.m_listViewSize = self.m_ccbNodeTableView:getContentSize();
	self.m_listView = cc.TableView:create(self.m_listViewSize);
	self.m_listView:setDelegate();
	self.m_listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	self.m_listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
	self.m_ccbNodeTableView:addChild(self.m_listView);

	self.m_listView:registerScriptHandler(handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED);
    self.m_listView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);
    self.m_listView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);
    self.m_listView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW);

    self.m_listView:reloadData();
end

function CCBLeagueApply:cellSizeForTable(view, idx)
  	return self.m_listViewSize.width, self.m_listViewSize.height/7;
end

function CCBLeagueApply:numberOfCellsInTableView(view)
	return #self.m_listData;
end

function CCBLeagueApply:tableCellAtIndex(view, idx)
	local cell = view:dequeueCell();
	if cell == nil then
		cell = cc.TableViewCell:new();
	end
	local index = idx+1;
	local item = cell:getChildByTag(1);
	if item == nil then
		item = CCBLeagueApplyCell:create();
		cell:addChild(item, 1, 1);
	end

	local data = self.m_listData[index];
	item:flushData(data);
	item:setApplyVisible(UserDataMgr:isApplyLeagueAid(data.aid));
	cell.index = index;

	if self.m_lastCell == nil and index == 1 then
		self.m_lastCell = cell;
		self:tableCellTouched(nil, cell);
	elseif self.m_lastCell then
		cell:getChildByTag(1):setSelectedVisible(self.m_selectIndex==index);
	end

	return cell;
end

function CCBLeagueApply:tableCellTouched(table, cell)
	local data = self.m_listData[cell.index];
	if self.m_lastCell then
		self.m_lastCell:getChildByTag(1):setSelectedVisible(false);
	end
	self.m_lastCell = cell;
	self.m_selectIndex = cell.index;
	cell:getChildByTag(1):setSelectedVisible(true);

	self.m_ccbLabelPresident:setString(data.chairman_name);
	self.m_ccbLabelDesc:setString(data.notice);
end

function CCBLeagueApply:onBtnJoin()
	if self.m_lastCell == nil then
		Tips:create(Str[24004]);
	else
		local data = self.m_listData[self.m_selectIndex];
		if data.state == 1 then--自由加入
			UserDataMgr:setPlayerUnionLevel(1);
			UserDataMgr.m_leagueAid = data.aid;
			
			App:getRunningScene():getViewBase():createView();
		elseif UserDataMgr:isApplyLeagueAid(data.aid) then
			Tips:create(Str[24007]);
		elseif data.member_count >= data.member_limit then
			Tips:create(Str[24009]);
		--elseif 该联盟申请人数已满 then
			--Tips:create(Str[24006]);
		else
			Tips:create(Str[24005]);
			UserDataMgr:setApplyLeagueAid(data.aid);
			self.m_listView:reloadData();
		end
	end
end

function CCBLeagueApply:onBtnCreate()
	App:getRunningScene():addChild(CCBLeagueCreate:create());
end

function CCBLeagueApply:onBtnSearch()
	if #self.m_editBox:getText() <= 0 then
		Tips:create(Str[5005]);
	else
		if self.m_lastCell then
			self.m_lastCell:getChildByTag(1):setSelectedVisible(false);
			self.m_lastCell = nil;
		end

		self.m_listData = nil;
		self.m_listData = {};

		for i,v in pairs(UserDataMgr.m_leagueData) do
			if string.find(v.name, self.m_editBox:getText()) then
				table.insert(self.m_listData, v);
			end
		end

    	self.m_listView:reloadData();

    	if table.nums(self.m_listData) <= 0 then
			Tips:create(Str[24010]);
			self.m_ccbLabelPresident:setString("");
			self.m_ccbLabelDesc:setString("");
		end
	end
end

return CCBLeagueApply