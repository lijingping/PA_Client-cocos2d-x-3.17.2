local CCBTaskViewCell = import(".CCBTaskViewCell");
local Tips = require("app.views.common.Tips");

local CCBTaskView = class("CCBTaskView", function ()
	return CCBLoader("ccbi/taskView/CCBTaskView.ccbi")
end)

function CCBTaskView:ctor()
	print("CCBTaskView:ctor");
	if display.resolution >= 2 then
		self:setScale(display.reduce);
	end
	self.m_showList = {};
	self.m_showList[1] = {};
	self.m_showList[2] = {};
	self.m_showList[3] = {};

	self.m_labelPape = 1;
	self.m_ccbBtnDailyTask:setEnabled(false);

	self:requestDailyTaskList();
	self:requestAchievementList();

	self:createTableView();
end

-- 请求任务列表
function CCBTaskView:requestDailyTaskList()
	--print("请求任务列表")
	local function requestCallBack(rc, callBackInfo)
		if callBackInfo.code ~= 1 then
			Tips:create(GameData:get("code_map", callBackInfo.code)["desc"]);
			return;
		end
		--dump(callBackInfo.task_info);
		self.m_showList[1] = {};
		local dailyList = table.clone(require("app.constants.day_task"));
		for i = 1, #callBackInfo.task_info do
			local info = dailyList[tostring(i)];
			info.curProcess = callBackInfo.task_info[i];
			if callBackInfo.task_info[i] >= dailyList[tostring(i)].target_num then
				info.sort = i;
				info.taskState = 1;	 --taskState 为1时是领取状态
			else
				if callBackInfo.task_info[i] == -1 then
					info.sort = 10000 + i;
					info.taskState = 2;	-- taskState为2时，是已领取状态
				else
					info.sort = 1000 + i;
					info.taskState = 0;	-- taskState为0时，是进行中状态
				end
			end	
			table.insert(self.m_showList[1], info);
			table.sort(self.m_showList[1], function (info1, info2) return info1.sort < info2.sort; end);
		end
		self.m_tableView:reloadData();
		--dump(self.m_showList[1]);
	end
	Network:request("game.taskHandler.query_day_task_info", nil, requestCallBack)
end

-- 请求成就列表
function CCBTaskView:requestAchievementList()
	--print("请求成就列表")
	local function requestCallBack(rc, callBackInfo)
		if callBackInfo.code ~= 1 then
			Tips:create(GameData:get("code_map", callBackInfo.code)["desc"]);
			return;
		end
		--dump(callBackInfo);
		--dump(callBackInfo.task_info);

		self.m_showList[2] = {};
		local allAchievementInfo = table.clone(require("app.constants.achievement_task"));
		for i = 1, #callBackInfo.task_info do
			for j = 1, #callBackInfo.task_info[i] do
				local taskID = callBackInfo.task_info[i][j].id
				local info = allAchievementInfo[tostring(taskID)];
				if info then
					info.is_receive = callBackInfo.task_info[i][j].is_receive;
					--dump(info);
					if info.is_receive == 0 then
						info.curProcess = callBackInfo.times_info[i];
						if info.curProcess == info.target_num or info.curProcess > info.target_num then
							info.taskState = 1;--可领取
							info.sort = taskID;
						else
							info.taskState = 0;--进行中
							info.sort = 1000 + taskID;
						end
					elseif info.is_receive == 1 then
						info.taskState = 2;--已领取
						info.sort = 10000 + taskID;
						info.curProcess = 0;						
					end
					table.insert(self.m_showList[2], info);
					table.sort(self.m_showList[2], function (info1, info2) return info1.sort < info2.sort; end);
				end
			end
		end	
		self.m_tableView:reloadData();
	end
	Network:request("game.taskHandler.query_achievement_task_info", nil, requestCallBack)
end

function CCBTaskView:createTableView()
	self.m_tableView = cc.TableView:create(self.m_ccbLayerViewSize:getContentSize());
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)--从上自下
    self.m_ccbLayerViewSize:addChild(self.m_tableView);
    self.m_tableView:setTouchEnabled(true);
    self.m_tableView:setLocalZOrder(100);
   	
   	self.m_tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx) end, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end, cc.TABLECELL_SIZE_AT_INDEX)
    self.m_tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

    self.m_tableView:reloadData()
end

function CCBTaskView:cellSizeForTable(table, idx)
	return 1130, 132;
end

function CCBTaskView:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell();
	if cell == nil then
		cell = cc.TableViewCell:new();
		local node = CCBTaskViewCell:create(self);
		node:setIndex(idx);
		node:setCurLabelPage(self.m_labelPape);
		node:setData(self.m_showList[self.m_labelPape][idx+1]);
		node:setTag(110);
		cell:addChild(node);
	else
		local node = cell:getChildByTag(110);
		node:setIndex(idx);
		node:setCurLabelPage(self.m_labelPape);
		node:setData(self.m_showList[self.m_labelPape][idx+1]);
	end
	return cell;
end

function CCBTaskView:numberOfCellsInTableView(table)
	if #self.m_showList[self.m_labelPape] == 0 then
		self.m_ccbNodeTipNothing:setVisible(true);
	else
		self.m_ccbNodeTipNothing:setVisible(false);
	end
	return #self.m_showList[self.m_labelPape];
end

function CCBTaskView:updateData(index)
	Tips:create(Str[14001]);
	if self.m_labelPape == 1 then
		-- local curInfo = self.m_showList[self.m_labelPape][index+1]
		-- curInfo.sort = 1000 + curInfo.id;
		-- curInfo.taskState = 2;
		-- table.sort(self.m_showList[self.m_labelPape], function (info1, info2) return info1.sort < info2.sort; end)
		-- self.m_tableView:reloadData();
		self:requestDailyTaskList();
	else
		self:requestAchievementList();
		--self.m_tableView:reloadData();
	end
end

function CCBTaskView:onBtnDailyTask()
	--print("切换至任务")
	self.m_labelPape = 1;
	self.m_ccbBtnDailyTask:setEnabled(false);
	self.m_ccbBtnAchievement:setEnabled(true);
	self.m_ccbBtnActivity:setEnabled(true);
	self.m_tableView:reloadData();
end

function CCBTaskView:onBtnAchievement()
	--print("切换至成就");
	self.m_labelPape = 2;
	self.m_ccbBtnDailyTask:setEnabled(true);
	self.m_ccbBtnAchievement:setEnabled(false);
	self.m_ccbBtnActivity:setEnabled(true);
	self.m_tableView:reloadData();
end

function CCBTaskView:onBtnActivity()
	--print("切换至活动");
	self.m_labelPape = 3;
	self.m_ccbBtnDailyTask:setEnabled(true);
	self.m_ccbBtnAchievement:setEnabled(true);
	self.m_ccbBtnActivity:setEnabled(false);
	self.m_tableView:reloadData();
end


return CCBTaskView;