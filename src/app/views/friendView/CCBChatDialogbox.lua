local Tips = require("app.views.common.Tips");

local CCBChatDialogbox = class("CCBChatDialogbox", function()
	return CCBLoader("ccbi/friendView/CCBChatDialogbox.ccbi")
end)

local colorBlue = cc.c3b(42, 247, 247);
local colorWhite = cc.c3b(255, 255, 255);
local colorGreen = cc.c3b(0, 204, 51);
local colorTimeBlue = cc.c3b(0, 204, 255);

local mineMassage = 1
local friendMassage = 2;

local editBgImg = "res/resources/friendView/friend_input.png";

local path = "res/data/";
local androidFilePath = "/sdcard/chatDataFile/"


function CCBChatDialogbox:ctor(data)
	-- if display.resolution >= 2 then   父节点已经缩放过了
	-- 	self.m_ccbNodeCenter:setScale(display.reduce);
	-- end
	--屏蔽Zorder在self之下的点击事件
    self.m_listener = cc.EventListenerTouchOneByOne:create();
    self.m_listener:setSwallowTouches(true);
    self.m_listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_listener, self);


	self.m_playerUid = cc.UserDefault:getInstance():getStringForKey("uid");
	self.m_data = data;
	-- dump(data);

	self:init();

	self:requestToGetHistoryMassage();

	-- 创建添加于滚动框的节点
	-- self.m_scrollViewSize = self.m_ccbScrollViewChat:getViewSize();

	-- 弹框标题
	self:setPopTitle(data);

	-- 创建EditBox
	local boxSize = self.m_ccbNodeEditBox:getContentSize();
	self.m_editBox = cc.EditBox:create(boxSize, editBgImg);
	self.m_editBox:setAnchorPoint(cc.p(0, 0));
	self.m_editBox:setFontSize(20);
	self.m_editBox:setFontColor(cc.c3b(255, 255, 255));
	self.m_editBox:setPlaceholderFontSize(20);
	self.m_editBox:setPlaceholderFontColor(cc.c3b(102, 102, 102));
	self.m_editBox:setPlaceHolder("在这里输入聊天内容");
	self.m_editBox:setMaxLength(50);
	self.m_editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE);
	self.m_editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
	self.m_ccbNodeEditBox:addChild(self.m_editBox);

	-- dump(self);

end

function CCBChatDialogbox:init()
	-- print("device.platform", device.platform); --ios
	-- print("----------",cc.FileUtils:getInstance():getWritablePath());
	-- 计算一星期的时间戳
	local todayZeroTime = os.time({day = 19, month = 7, year = 2017, hour = 0, minute = 0, second = 0});
	local pastWeekTime = os.time({day = 12, month = 7, year = 2017, hour = 0, minute = 0, second = 0});
	self.m_aWeekTime = todayZeroTime - pastWeekTime;

	self.m_nodeSizeHeight = 0;
	self:createScrollView();
	-- local filePath = nil;
	-- print("device.platform       ", device.platform);
	-- local fileCheck = nil;
	-- if device.platform == "mac" then
	-- 	path = cc.FileUtils:getInstance():getWritablePath() .. path;
	-- 	fileCheck = io.open(path);
	-- elseif device.platform == "ios" then
	-- 	path = cc.FileUtils:getInstance():getWritablePath();
	-- 	fileCheck = io.open(path);
	-- elseif device.platform == "windows" then
	-- 	fileCheck = io.open(path);
	-- elseif device.platform == "android" then
	-- 	fileCheck = io.open(androidFilePath);
	-- end

	-- if fileCheck then
	-- 	fileCheck:close();
	-- else
	-- 	-- print("文件不存在 -----------")
	-- 	if device.platform == "mac" then
	-- 		os.execute("mkdir -p \"" .. path .. "\"");
	-- 	elseif device.platform == "ios" then
	-- 		os.execute("mkdir -p \"" .. path .. "\"");
	-- 	elseif device.platform == "windows" then
	-- 		os.execute("mkdir\"" .. path .. "\"");
	-- 	elseif device.platform == "android" then
	-- 		os.execute("mkdir -p \"" .. androidFilePath .. "\"")
	-- 	end
	-- end

	-- if device.platform == "mac" or device.platform == "ios" then
	-- 	filePath = path .. self.m_playerUid .. self.m_data.uid;

	-- 	-- filePath = "res/data/" .. self.m_playerUid .. self.m_data.name;
	-- elseif device.platform == "android" then
	-- 	filePath = androidFilePath .. self.m_playerUid .. self.m_data.uid;

	-- 	-- filePath = "/sdcard/pa_assets/" .. self.m_playerUid .. self.m_data.name;
	-- elseif device.platform == "windows" then
	-- 	filePath = path .. self.m_playerUid .. self.m_data.uid;
	-- end

	-- local file = io.open(filePath, "a+");
	-- file:close();
	-- self:loadHistoryChatLog();

end

function CCBChatDialogbox:setPopTitle(data)
	-- local str = "正在与<font color = \'#2AF7F7\'>[" .. data.name .. "]</font>私聊.";
	-- local text = ccui.RichText:createWithXML(str);
	-- -- text:setSystemFontSize(30);
	-- text:setAnchorPoint(cc.p(0.5, 0.5));
	-- -- text:setContentSize(cc.size(200, 30));
	-- self.m_ccbNodeTitleLabel:addChild(text);
	local richText = ccui.RichText:create();
	local text1 = ccui.RichElementText:create(1, colorBlue, 255, Str[5003], "", 20);
	local nameStr = "[" .. data.nickname .. "]";
	local text2 = ccui.RichElementText:create(1, colorWhite, 255, nameStr, "", 24);
	local text3 = ccui.RichElementText:create(1, colorBlue, 255, Str[5004], "", 20);
	richText:pushBackElement(text1);
	richText:pushBackElement(text2);
	richText:pushBackElement(text3);
	self.m_ccbNodeTitleLabel:addChild(richText);
end

-- 创建消息标签
function CCBChatDialogbox:chatNewsLabel(str, typeNumber, timeStr)
	-- self.m_ccbScrollViewChat:removeAllChildren();

	local scrollViewSize = self.m_scrollView:getContentSize();

	local timeLabel = nil;
	local nowTime, outTimeStr = self:splitTimeStr(timeStr); 

	if self.m_preLogTime then
		local preTime, preTimeStr = self:splitTimeStr(self.m_preLogTime);
		for i = 1, #nowTime - 1 do
			if i == #nowTime - 2 and nowTime[i] - preTime[i] == 1 then
				local toClock = 60 - preTime[i + 1];
				if toClock + nowTime[i + 1] > 5 then
					-- 创建时间标签
					timeLabel = self:createTimeLabel(outTimeStr);
					self.m_nodeAddScrollView:addChild(timeLabel);
					break;
				end
			end
			if i == #nowTime - 1 then
				if nowTime[i] - preTime[i] > 5 then
					-- 创建时间标签
					timeLabel = self:createTimeLabel(outTimeStr);
					self.m_nodeAddScrollView:addChild(timeLabel);
				end
				break;
			end
			if nowTime[i] > preTime[i] then

				timeLabel = self:createTimeLabel(outTimeStr);
				self.m_nodeAddScrollView:addChild(timeLabel);
				break;
			end
		end
	else
		timeLabel = self:createTimeLabel(outTimeStr);
		self.m_nodeAddScrollView:addChild(timeLabel);
	end
	if timeLabel then
		local timeLabelSize = timeLabel:getContentSize()
		self.m_nodeSizeHeight = self.m_nodeSizeHeight + timeLabelSize.height + 10;
		timeLabel:setPosition(cc.p((scrollViewSize.width - 30) / 2, -self.m_nodeSizeHeight));
	end

	local labelUser = cc.LabelTTF:create();
	labelUser:setFontSize(20);
	if typeNumber == mineMassage then
		labelUser:setColor(colorGreen);
		str = "[" .. Str[10005] .. "]: " .. str;
	elseif typeNumber == friendMassage then
		labelUser:setColor(colorWhite);
		str = "[" .. self.m_data.nickname .. "]: " .. str;
	end
	
	labelUser:setDimensions(cc.size(scrollViewSize.width - 30, 0));
	labelUser:setAnchorPoint(cc.p(0, 0));
	self.m_nodeAddScrollView:addChild(labelUser);

	labelUser:setString(str);
	local labelSize = labelUser:getContentSize();

	self.m_nodeSizeHeight = self.m_nodeSizeHeight + labelSize.height + 10;
	labelUser:setPosition(cc.p(0, -self.m_nodeSizeHeight));

	local scrollInnerSize = self.m_scrollView:getInnerContainerSize();
	if scrollInnerSize.height < self.m_nodeSizeHeight then
		self.m_scrollView:setInnerContainerSize(cc.size(scrollInnerSize.width, self.m_nodeSizeHeight));
		self.m_nodeAddScrollView:setPosition(cc.p(0, self.m_nodeSizeHeight));
		self.m_scrollView:getInnerContainer():setPosition(cc.p(0, 0));
	end
	self.m_preLogTime = timeStr;
end

-- 创建时间标签
function CCBChatDialogbox:createTimeLabel(timeStr)
	local timeLabel = cc.LabelTTF:create();
	timeLabel:setFontSize(16);
	timeLabel:setColor(colorBlue);
	timeLabel:setAnchorPoint(cc.p(0.5, 0));
	timeLabel:setString(timeStr);
	timeLabel:setDimensions(cc.size(0, 0));
	return timeLabel;
end

-- 创建ScrollView并创建一个节点用于放置label，添加于scrollView上面
function CCBChatDialogbox:createScrollView()
	local size = self.m_ccbNodeScrollView:getContentSize();
	self.m_scrollView = ccui.ScrollView:create();
	self.m_scrollView:setTouchEnabled(true);
	self.m_scrollView:setBounceEnabled(true);-- 滚动
	self.m_scrollView:setScrollBarEnabled(false);
	self.m_scrollView:setDirection(ccui.ScrollViewDir.vertical); -- 滚动方向
	self.m_scrollView:setContentSize(size);
	self.m_scrollView:setInnerContainerSize(size);
	self.m_scrollView:setAnchorPoint(cc.p(0.5, 0.5));
	self.m_scrollView:setPosition(cc.p(size.width / 2, size.height/2));
	self.m_ccbNodeScrollView:addChild(self.m_scrollView);

	local node = cc.Node:create();
	node:setPosition(cc.p(0, size.height));
	self.m_scrollView:addChild(node);
	self.m_nodeAddScrollView = node;
end

-- 红叉按钮事件
function CCBChatDialogbox:onBtnClose()
	local isOutRequest = false;
	self:requestMarkNewsRead(isOutRequest);

	if App:getRunningScene():getViewBase().m_ccbFriendView then
		App:getRunningScene():getViewBase().m_ccbFriendView:closeChatDialogbox();
	else
		self:removeSelf();
	end
end

-- 发送按钮事件
function CCBChatDialogbox:onBtnSendMessage()
	print("消息发送");
	local sendStr = self.m_editBox:getText();
	if sendStr == "" then
		Tips:create(Str[5005]);
	else
		self.m_sendStr = self:checkCharacterDouble(sendStr);
		self:sendMassage(self.m_data.uid, self.m_sendStr);
	end
	self.m_editBox:setText("");
end

-- 快捷回复按钮事件
function CCBChatDialogbox:onBtnQuickAnswer()
	print("快捷回复");
	-- local filePath = "res/data/" .. self.m_data.name .. ".txt";
	-- local file = io.input(filePath);
	-- assert(file);
	-- local str = io.read("*a");
	-- print(str);
	-- file:close();
	-- local str2 = self:Split(str, "\n");
	-- dump(str2);
	-- local str3 = self:Split(str2[1], " = ");
	-- print(str3[1], str3[2]);
	-- print(string.len(str3[1]), string.len(str3[2]));
	-- print(json.encode("['dddd\\ ddd']")[0]);
	-- json.encode(" dddd\\ ddd ")

end

-- 发送信息
function CCBChatDialogbox:sendMassage(friendUid, massageStr)
	local function requestCallBack(data, receiveData)
		-- dump(data);
		-- dump(receiveData);
		-- "<var>" = {
		-- 	    "chat" = {
		--         "msg"      = "["
		--         "receiver" = "cfcde268595eef72bba2f474ce024302"
		--         "sender"   = "cfcde2685940a51b0606af3b463469f8"
		--         "time"     = "2017-07-17 16:23:10"
		--     }
		--     "code" = 1
		-- }
		-- dump(receiveData.chat);
		if receiveData.code ~= 1 then
			Tips:create(Str[5006]);
			return;
		end
		
		-- print("  我发送消息   时间   ", os.date("%Y-%m-%d  %H:%M:%S"));
		self:chatLogText(receiveData.chat);
		self:chatNewsLabel(self.m_sendStr, mineMassage, receiveData.chat.time);
	end
	Network:request("chat.chatHandler.push_msg_to_friend", {friend = friendUid, msg = massageStr}, requestCallBack);
end

-- 在当前页面 服务器发来的好友消息
function CCBChatDialogbox:notifyChatNews(data)
	-- "<var>" = {
	-- 	    "info" = {
	--         "msg"    = "~"
	--		   "receiver" = "cfcde2685940a51b0606af3b463469f8"
	--         "sender" = "cfcde268595eef72bba2f474ce024302"
	--         "time"   = "2017-07-17 15:21:08"
	--     }
	-- }
	-- print("  好友消息   时间    " , data.any.time);
	data.info.receiver = self.m_playerUid;
	dump(data.info);
	self:chatLogText(data);
	self:chatNewsLabel(data.info.msg, friendMassage, data.info.time);
end

-- 获取好友的历史信息
function CCBChatDialogbox:requestToGetHistoryMassage()
	local function historyMassageCallBack(data, receiveData)
		-- print("CCBChatDialogbox:requestToGetHistoryMassage() 获取好友的历史信息");
		-- dump(receiveData);
		for k, v in pairs(receiveData.all_chat) do
			if v.sender == self.m_playerUid then
				self:chatNewsLabel(v.msg, mineMassage, v.time);
			else
				self:chatNewsLabel(v.msg, friendMassage, v.time);
			end
		end
	end
	Network:request("social.friendHandler.all_chat_log", {friend = self.m_data.uid}, historyMassageCallBack);
end

-- 拆分字符串
function CCBChatDialogbox:Split(szFullString, szSeparator)  
	local nFindStartIndex = 1  
	local nSplitIndex = 1  
	local nSplitArray = {}  
	while true do  
	   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
	   if not nFindLastIndex then  
		    nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
		    break  
	   end  
	   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
	   nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
	   nSplitIndex = nSplitIndex + 1  
	end 
	return nSplitArray
end

-- 把聊天记录写文本里
function CCBChatDialogbox:chatLogText(data)
	-- local filePath = nil;
	-- -- print("device.platform       ", device.platform);
	-- if device.platform == "mac" or device.platform == "ios" then
	-- 	filePath = path .. self.m_playerUid .. self.m_data.uid;
	-- 	-- filePath = "res/data/" .. self.m_playerUid .. self.m_data.name;
	-- elseif device.platform == "android" then
	-- 	filePath = androidFilePath .. self.m_playerUid .. self.m_data.uid;
	-- 	-- filePath = "/sdcard/pa_assets/" .. self.m_playerUid .. self.m_data.name;
	-- elseif device.platform == "windows" then
	-- 	filePath = path .. self.m_playerUid .. self.m_data.uid;
	-- end

	-- local file = io.open(filePath, "a+");
	-- assert(file);
	-- if type(data.info) == "table" then
	-- 	for k, v in pairs(data.info) do
	-- 		file:write(k .. " = ");
	-- 		file:write(v .. "\n");
	-- 	end
	-- end
	-- file:close();

end

-- 拆分时间str
function CCBChatDialogbox:splitTimeStr(timeStr)
	if timeStr then
		local typeTime = self:Split(timeStr, " ");
		local ymdData = self:Split(typeTime[1], "-");
		local hmsData = self:Split(typeTime[2], ":");
		local timeTable = {};
		timeTable[1] = ymdData[1];
		timeTable[2] = ymdData[2];
		timeTable[3] = ymdData[3];
		timeTable[4] = hmsData[1];
		timeTable[5] = hmsData[2];
		timeTable[6] = hmsData[3];

		local outTimeStr = typeTime[1] .. " " .. hmsData[1] .. ":" .. hmsData[2];
		return timeTable, outTimeStr;
	end
	return nil, nil;
end

-- 聊天记录写入
--  math.ceil 向上取整    -- math.floor 向下取整   -- math.modf() 取整
function CCBChatDialogbox:loadHistoryChatLog()
	local filePath = "";
	-- print("device.platform       ", device.platform);
	if device.platform == "mac" or device.platform == "ios" then
		filePath = path .. self.m_playerUid .. self.m_data.uid;
	elseif device.platform == "android" then
		filePath = androidFilePath .. self.m_playerUid .. self.m_data.uid;
		-- filePath = "/sdcard/pa_assets/" .. self.m_playerUid .. self.m_data.name;
	elseif device.platform == "windows" then
		filePath = path .. self.m_playerUid .. self.m_data.uid;
	end
	local file = io.input(filePath);
	-- assert(file);
	local strChatLog = io.read("*a");

	file:close();

	local strSplitRow = self:Split(strChatLog, "\n");
	local chatLogTable = {};
	local oneMassageTable = {};
	for i = 1, #strSplitRow - 1 do 
		local tableIndex = math.ceil(i / 4);
		local strSplitPart = self:Split(strSplitRow[i], " = ");

		if strSplitPart[1] == "time" then
			-- print("消息类型：time .", strSplitPart[2]);
			oneMassageTable.time = strSplitPart[2];

		elseif strSplitPart[1] == "msg" then
			oneMassageTable.msg = strSplitPart[2];

		elseif strSplitPart[1] == "receiver" then
			oneMassageTable.receiver = strSplitPart[2];

		elseif strSplitPart[1] == "sender" then
			oneMassageTable.sender = strSplitPart[2];

		end
		local integer, decimal = math.modf(i / 4);
		if decimal == 0 then
			-- table.insert(chatLogTable, oneMassageTable)
			chatLogTable[tableIndex] = oneMassageTable;
			oneMassageTable = {};
		end
	end
	local nowTime = os.time();
	if #chatLogTable > 50 then
		for i = #chatLogTable - 50, #chatLogTable do
			if self:checkMessageToShow(nowTime, chatLogTable[i].time) then
				local newsType = nil;
				if chatLogTable[i].sender == self.m_data.uid then
					newsType = friendMassage;
				else
					newsType = mineMassage;
				end
				self:chatNewsLabel(chatLogTable[i].msg, newsType, chatLogTable[i].time)
			end
		end
	elseif #chatLogTable > 0 then
		for i = 1, #chatLogTable do
			if self:checkMessageToShow(nowTime, chatLogTable[i].time) then
				local newsType = nil;
				if chatLogTable[i].sender == self.m_data.uid then
					newsType = friendMassage;
				else
					newsType = mineMassage;
				end
				self:chatNewsLabel(chatLogTable[i].msg, newsType, chatLogTable[i].time)
			end
		end

	else 
		return ;
	end

end

-- 判断消息是否过期，超过七天。
function CCBChatDialogbox:checkMessageToShow(nowTime, messageTime)

	local splitMessageTime = self:Split(messageTime, " ");
	local splitMessageYMD = self:Split(splitMessageTime[1], "-");
	local msgYear = splitMessageYMD[1];
	local msgMonth = splitMessageYMD[2];
	local msgDay = splitMessageYMD[3];

	local splitMessageHMS = self:Split(splitMessageTime[2], ":");
	local hourCount = splitMessageHMS[1];
	local minuteCount = splitMessageHMS[2];
	local secondCount = splitMessageHMS[3];
	-- print(" 各个单位的时间，日，月，年，时，分，秒", msgDay, msgMonth, msgYear, hourCount, minuteCount, secondCount);
	local messageTimeCount = os.time({day = msgDay, month = msgMonth, year = msgYear, hour = hourCount, minute = minuteCount, second = secondCount});-- 只能精确到小时

	if nowTime - messageTimeCount > self.m_aWeekTime then
		return false;
	else
		return true;
	end

end

-- 返回好友的uid
function CCBChatDialogbox:getFriendUID()
	return self.m_data.uid;
end

-- 请求好友发来的新消息
function CCBChatDialogbox:requestNewFriendLog()
	local isInRequest = true;
	local function requestNewFriendLogCallBack(data, receiveData)
		if receiveData.code ~= 1 then
			Tips:create(Str[5007]);
			return;
		end
		-- dump(receiveData);
-- "<var>" = {
--     "code"        = 1
--     "unread_chat" = {
--         1 = {
--             "is_read"  = false
--             "msg"      = "＼＼＼＼"
--             "receiver" = "cfcde268595eef72bba2f474ce024302"
--             "sender"   = "cfcde2685940a51b0606af3b463469f8"
--             "time"     = "2017-07-21 09:39:37"
--         }
--		   2 = {}
--		   3 = {}
--		   。。。。。
-- 	}
-- }
		self:friendNewChatLog(receiveData.unread_chat);
		self:requestMarkNewsRead(isInRequest);
	end
	Network:request("social.friendHandler.unread_chat_log",{friend = self.m_data.uid}, requestNewFriendLogCallBack)
end

-- 标记好友消息为已读
function CCBChatDialogbox:requestMarkNewsRead(isInRequest)
	local function requestMarkNewsReadCallBack(data, receiveData)
		if receiveData.code ~= 1 then
			print("function CCBPrivateChatPopup:requestMarkNewsRead()");
			Tips:create(Str[5008]);
			return;
		end
		if isInRequest then
			self:getParent():updataNewMessageFriendList(self.m_data.uid);
		end
	end
	Network:request("social.friendHandler.update_chat_read", {friend = self.m_data.uid}, requestMarkNewsReadCallBack);
end

-- 处理冲突符号。 有 ' ' " "    ---- \ -> 全角 ＼
function CCBChatDialogbox:checkCharacterDouble(str)
	local splitStr = self:Split(str, [["]]);
	local resultStr = "";
	for i = 1, #splitStr do
		resultStr = resultStr .. splitStr[i];
		local integer, decimal = math.modf(i / 2);
		if i < #splitStr then
			if decimal == 0 then
				resultStr = resultStr .. "”";
			else
				resultStr = resultStr .. "“";
			end
		end
	end
	resultStr = self:checkCharacterSingle(resultStr);
	return resultStr;
end

function CCBChatDialogbox:checkCharacterSingle(str)
	local splitStr = self:Split(str, [[']]);
	local resultStr = "";
	for i = 1, #splitStr do
		resultStr = resultStr .. splitStr[i];
		local integer, decimal = math.modf(i / 2);
		if i < #splitStr then
			if decimal == 0 then
				resultStr = resultStr .. "’";
			else
				resultStr = resultStr .. "‘";
			end
		end
	end
	resultStr, replaceCount = string.gsub(resultStr, [[\]], [[＼]]);
	return resultStr;
end

-- 处理请求来的好友新消息
function CCBChatDialogbox:friendNewChatLog(newChatLogTable)
	
	-- local resultTable = {};
	if #newChatLogTable > 0 then
		for i = 1, #newChatLogTable do
			local chatStr = {};
			for k, v in pairs(newChatLogTable[i]) do
				if k == "time" then
					chatStr.time = v;
				elseif k == "receiver" then
					chatStr.receiver = v;
				elseif k == "sender" then
					chatStr.sender = v;
				elseif k == "msg" then
					chatStr.msg = v;
				end
			end
			-- resultTable[i] = chatStr;
			self:chatLogText(chatStr);
			self:chatNewsLabel(chatStr.msg, friendMassage, chatStr.time);
			chatStr = {};
		end
	end
	-- dump(resultTable);
-- 1 = {
--         "msg"      = "fdfdfdffd"
--         "receiver" = "cfcde2685940a51b0606af3b463469f8"
--         "sender"   = "cfcde268595eef72bba2f474ce024302"
--         "time"     = "2017-07-21 10:41:45"
--     } ...

end


return CCBChatDialogbox;