local Tips = require("app.views.common.Tips");

local CCBTaskViewCell = class("CCBTaskViewCell", function ()
	return CCBLoader("ccbi/taskView/CCBTaskViewCell.ccbi")
end)

function CCBTaskViewCell:ctor(parentNode)
	self.m_nodeParent = parentNode;
	self:init();
end

function CCBTaskViewCell:init()
	self.m_index = 1;
	self.m_labelPape = 1;
end

function CCBTaskViewCell:setIndex(idx)
	self.m_index = idx;
end

function CCBTaskViewCell:setCurLabelPage(labelPage)
	self.m_labelPape = labelPage;
end

function CCBTaskViewCell:setData(data)
	self.m_showInfo = data;
	--dump(data);
	if data.taskState == 2 then
		self.m_ccbScale9SpriteDark:setVisible(true);
		-- self.m_ccbScale9SpriteBgDark:setVisible(true);
		-- self.m_ccbScale9SpriteBgLight:setVisible(false);
	else
		self.m_ccbScale9SpriteDark:setVisible(false);
		-- self.m_ccbScale9SpriteBgDark:setVisible(false);
		-- self.m_ccbScale9SpriteBgLight:setVisible(true);
	end

	self.m_ccbNodeIcon:removeAllChildren();
	self.m_ccbNodeIcon:addChild(self:combineIcon(data));

	self.m_ccbLabelTaskName:setString(data.task_name);
	self.m_ccbLabelTaskDesc:setString(data.task_desc);

	--现在策划案上没有设定任务时间相关的
	self.m_ccbNodeTaskTime:setVisible(false);
	self.m_ccbLabelTaskTime:setString("");

	if data.taskState == 2 then
		self.m_ccbNodeTaskProcess:setVisible(false);
		self.m_ccbLabelTaskProcess:setString("");
	else
		self.m_ccbNodeTaskProcess:setVisible(true);
		local curProcess = data.curProcess;
		local targetCount = data.target_num;
		if curProcess > 10000 then
			curProcess = math.floor(curProcess / 10000) .. "万";
		end

		if targetCount > 10000 then
			targetCount = math.floor(targetCount / 10000) .. "万";
		end
		
		self.m_ccbLabelTaskProcess:setString( curProcess .. "/" .. targetCount);
	end

	-- self.m_ccbBtnReceive:setVisible(false);
	-- self.m_ccbSpriteBtnReceive:setVisible(false);
	-- self.m_ccbSpriteInProcess:setVisible(false);
	-- self.m_ccbSpriteCompleted:setVisible(false);
	if data.taskState == 0 then --进行中
		self.m_ccbBtnReceive:setVisible(false);
		self.m_ccbSpriteBtnReceive:setVisible(false);
		self.m_ccbSpriteInProcess:setVisible(true);
		self.m_ccbSpriteBtnCompleted:setVisible(false);
		self.m_ccbSpriteCompleted:setVisible(false);
	elseif data.taskState == 1 then --完成未领取
		self.m_ccbBtnReceive:setVisible(true);
		self.m_ccbSpriteBtnReceive:setVisible(true);
		self.m_ccbSpriteInProcess:setVisible(false);
		self.m_ccbSpriteBtnCompleted:setVisible(false);
		self.m_ccbSpriteCompleted:setVisible(false);
	-- 	dump(data);		
	elseif data.taskState == 2 then --完成并领取
		self.m_ccbBtnReceive:setVisible(false);
		self.m_ccbSpriteBtnReceive:setVisible(false);
		self.m_ccbSpriteInProcess:setVisible(false);
		self.m_ccbSpriteBtnCompleted:setVisible(true);
		self.m_ccbSpriteCompleted:setVisible(true);
	end	
end

function CCBTaskViewCell:combineIcon(data)
	local node = cc.Node:create();
	local bg = cc.Sprite:create("res/resources/common/item_bg_4.png");	
	local icon = cc.Sprite:create("res/itemIcon/" .. data.icon .. ".png");
	local frame = cc.Sprite:create("res/resources/common/item_frame_4.png");

	if icon == nil then
		icon = cc.Sprite:create("res/itemIcon/99999.png");
		print("找不到资源", data.icon);
	end
	
	node:addChild(bg);
	node:addChild(icon);
	node:addChild(frame);
	node:setScale(0.8);
	return node;
end

function CCBTaskViewCell:onBtnReceive()
	print("11111");
	if self.m_labelPape == 1 then
		local function requestCallBack(re, callBackInfo)
			if callBackInfo.code ~= 1 then
				Tips:create(GameData:get("code_map", callBackInfo.code)["desc"]);
				return;
			end
			--dump(callBackInfo);
			self.m_nodeParent:updateData(self.m_index);
		end

		Network:request("game.taskHandler.receive_day_task_award", {task_id = self.m_showInfo.id}, requestCallBack);
		
	elseif self.m_labelPape == 2 then
		local function requestCallBack(rc, callBackInfo)
			if callBackInfo.code ~= 1 then
				Tips:create(GameData:get("code_map", callBackInfo.code)["desc"]);
				return;
			end
			--dump(callBackInfo);
			self.m_nodeParent:updateData(self.m_index);
		end

		Network:request("game.taskHandler.receive_achievement_task_award", {task_id = self.m_showInfo.id}, requestCallBack);
	end

	
end




return CCBTaskViewCell;