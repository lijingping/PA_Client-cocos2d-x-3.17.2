local Tips = require("app.views.common.Tips");
local ResourceMgr = require("app.utils.ResourceMgr");
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");

local math_ceil = math.ceil;

local MAX_LINE_WIDTH = 735;
local MSG_FONT_SIZE = 18;
local MSG_FONT_HEIGHT = 20;
local RANK_ICON_BG_HEIGHT = 82;

local CCBChatView = class("CCBChatView", function ()
	return CCBLoader("ccbi/chatView/CCBChatView.ccbi")
end)

function CCBChatView:ctor(listType)
	self:enableNodeEvents();
	self:createCoverLayer();

	self.m_label = cc.LabelTTF:create();
	self.m_label:setFontSize(MSG_FONT_SIZE);
	self.m_label:setVisible(false);
	self.m_label:addTo(self);

	-- 创建EditBox
	local boxSize = self.m_ccbNodeEditBox:getContentSize();
	self.m_editBox = cc.EditBox:create(boxSize, "res/resources/friendView/friend_input.png");
	self.m_editBox:setAnchorPoint(cc.p(0, 0));
	self.m_editBox:setFontSize(20);
	self.m_editBox:setFontColor(cc.c3b(255, 255, 255));
	self.m_editBox:setPlaceholderFontSize(20);
	self.m_editBox:setPlaceholderFontColor(cc.c3b(102, 102, 102));
	self.m_editBox:setPlaceHolder(Str[22002]);
	self.m_editBox:setMaxLength(120);
	self.m_editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE);
	self.m_editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
	self.m_ccbNodeEditBox:addChild(self.m_editBox);
	local function editBoxTextEventHandle(stringEventName, pSender)
		if stringEventName == "changed" then
			local editBoxLen, chNum, enNum = self:getStringLenth(pSender:getText());
				if editBoxLen >= 120 then
					pSender:setMaxLength(chNum + enNum);
				else
					pSender:setMaxLength(120);
				end

			if self.m_scheduler then
				if #pSender:getText() <= 0 then
					self.m_editBox:setPlaceHolder("");
					self.m_ccbNodeCountDown:setVisible(true);
				else
					self.m_editBox:setPlaceHolder(Str[22002]);
					self.m_ccbNodeCountDown:setVisible(false);
				end
			end
		elseif stringEventName == "ended" then
		elseif stringEventName == "return" then
			if self.m_scheduler and #pSender:getText() <= 0 then
				self.m_editBox:setPlaceHolder("");
				self.m_ccbNodeCountDown:setVisible(true);
			end
		end
	end	
	self.m_editBox:registerScriptEditBoxHandler(editBoxTextEventHandle)
	self.m_editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE);

	self:createTableView();

	self:onBtnWorld();
end

function CCBChatView:onEnter()
end

function CCBChatView:onExit()
	self:unscheduleScriptEntry();
end

function CCBChatView:createCoverLayer()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
    listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);

    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerColor);
end

function CCBChatView:createTableView()
	self.m_nViewCount = 0;

	self.m_tableView = cc.TableView:create(self.m_ccbScaleSpriteView:getContentSize());
    self.m_tableView:setDelegate();
    --self.m_tableView:setTouchEnabled(false);
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
    self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
    self.m_ccbScaleSpriteView:addChild(self.m_tableView);

    --注册响应函数
    self.m_tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx); end, cc.TABLECELL_SIZE_FOR_INDEX);
    self.m_tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx); end, cc.TABLECELL_SIZE_AT_INDEX);
    self.m_tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table); end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);
    self.m_tableView:reloadData();
end

function CCBChatView:getStrSize(idx)
	self.m_label:setString(ChatDataMgr:getMsgList(self.m_nViewIndex)[idx].msg);
	local size = self.m_label:getContentSize();
	local row = math_ceil(size.width/MAX_LINE_WIDTH);
	row = (row <= 0) and 1 or row;
	local labelHeight = row * size.height;

	size.height = labelHeight + MSG_FONT_HEIGHT;--20大小（一个名字高度)
	if RANK_ICON_BG_HEIGHT > size.height then
		size.height = RANK_ICON_BG_HEIGHT;
	end
	local isMulLine = (size.width > MAX_LINE_WIDTH)
	return (isMulLine and MAX_LINE_WIDTH or size.width)
	, size.height + (isMulLine and MSG_FONT_HEIGHT*1.5 or MSG_FONT_HEIGHT)
	, labelHeight + MSG_FONT_HEIGHT;
end

function CCBChatView:cellSizeForTable(table, idx)
	local _,height = self:getStrSize(idx+1);
	return self.m_ccbScaleSpriteView:getContentSize().width, height;
end

function CCBChatView:ownerTableCellAtIndex(cell, idx, data)
	local rankIconBg;
	local rankIcon;
	local rankName;
	local name;
	local msgBg;
	local msg;
	local rankIconBgSize;
	if cell == nil then
		cell = cc.TableViewCell:create();
		rankIconBg = cc.Sprite:create("res/resources/chatView/chat_head_frame.png");
		rankIconBg:setAnchorPoint(cc.p(0, 1));
		rankIconBg:addTo(cell, 1, 1);

		rankIconBgSize = rankIconBg:getContentSize();
		rankIcon = cc.Sprite:create(ResourceMgr:getRankBigIconByLevel(data.player_info.rankLevel));
		rankIcon:setScale(0.18);
		rankIcon:setPosition(cc.p(rankIconBgSize.width/2, rankIconBgSize.height/2));
		rankIcon:addTo(rankIconBg, 1, 1);

		rankName = cc.Sprite:create(ResourceMgr:getRankTextByLevel(data.player_info.rankLevel));
		rankName:setScale(0.44);
		rankName:setPosition(cc.p(rankIconBgSize.width/2, rankIconBgSize.height*0.2));
		rankName:addTo(rankIconBg, 2, 2);

		name = cc.LabelTTF:create();
		name:setFontSize(16)
		name:setAnchorPoint(cc.p(0, 1));
		name:addTo(cell, 2, 2);

		msgBg = ccui.Scale9Sprite:create("res/resources/chatView/chat_dialog_frame2_24_10_16_10.png");

		msg = cc.LabelTTF:create();
		msg:setFontSize(MSG_FONT_SIZE);
		msg:setAnchorPoint(cc.p(0, 0.5));
		msg:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT);
		msg:setDimensions(cc.size(MAX_LINE_WIDTH, 0));
	else
		rankIconBg = cell:getChildByTag(1);
		rankIconBgSize = rankIconBg:getContentSize();
		rankIcon = rankIconBg:getChildByTag(1):setTexture(ResourceMgr:getRankBigIconByLevel(data.player_info.rankLevel));
		rankName = rankIconBg:getChildByTag(2):setTexture(ResourceMgr:getRankTextByLevel(data.player_info.rankLevel))

		name = cell:getChildByTag(2);
		msgBg = cell:getChildByTag(3);
		msg = msgBg:getChildByTag(1);

        msg:retain()
        msg:removeFromParent()
        msgBg:removeSelf()

		--msgBg:initWithFile(cc.rect(24, 10, 16, 10), "res/resources/chatView/chat_dialog_frame2_24_10_16_10.png");
		msgBg = ccui.Scale9Sprite:create("res/resources/chatView/chat_dialog_frame2_24_10_16_10.png");
	end

	local cellWidth = self.m_ccbScaleSpriteView:getContentSize().width;
	rankIconBg:setPositionX(cellWidth - rankIconBgSize.width);

	msg:setColor(cc.c3b(255, 255, 255)):setString(data.msg);
	name:setColor(cc.c3b(255, 255, 255)):setString("["..data.player_info.nickname.."]");
	name:setPositionX(cellWidth - rankIconBgSize.width - (name:getContentSize().width+20));

	local bgWidth, bgHeight, labelHeight = self:getStrSize(idx+1);
	rankIconBg:setPositionY(bgHeight);
	name:setPositionY(bgHeight-5);
	
	msgBg:setAnchorPoint(cc.p(0, 1));
	msgBg:setCapInsets(cc.rect(24, 10, 16, 10));
	msgBg:setPositionY(name:getPositionY()-MSG_FONT_HEIGHT-3);

	local size = cc.size(bgWidth+MSG_FONT_HEIGHT*2, labelHeight);
	msgBg:setPreferredSize(size);
	msgBg:setPositionX(cellWidth -rankIconBgSize.width - size.width)
	
	msgBg:addTo(cell, 3, 3);

	msg:setPositionX(MSG_FONT_HEIGHT*0.8);
	msg:setPositionY(labelHeight/2);
	msg:addTo(msgBg, 1, 1);
	return cell;
end

function CCBChatView:otherTableCellAtIndex(cell, idx, data)
	local rankIconBg;
	local rankIcon;
	local rankName;
	local name;
	local msgBg;
	local msg;
	local rankIconBgSize;
	if cell == nil then
		cell = cc.TableViewCell:create();
		rankIconBg = cc.Sprite:create("res/resources/chatView/chat_head_frame.png");
		rankIconBg:setAnchorPoint(cc.p(0, 1));
		rankIconBg:addTo(cell, 1, 1);

		rankIconBgSize = rankIconBg:getContentSize();
		rankIcon = cc.Sprite:create(ResourceMgr:getRankBigIconByLevel(data.player_info.rankLevel));
		rankIcon:setScale(0.18);
		rankIcon:setPosition(cc.p(rankIconBgSize.width/2, rankIconBgSize.height/2));
		rankIcon:addTo(rankIconBg, 1, 1);

		rankName = cc.Sprite:create(ResourceMgr:getRankTextByLevel(data.player_info.rankLevel));
		rankName:setScale(0.44);
		rankName:setPosition(cc.p(rankIconBgSize.width/2, rankIconBgSize.height*0.2));
		rankName:addTo(rankIconBg, 2, 2);

		name = cc.LabelTTF:create();
		name:setFontSize(16)
		name:setAnchorPoint(cc.p(0, 1));
		name:addTo(cell, 2, 2);

		msgBg = ccui.Scale9Sprite:create("res/resources/chatView/chat_dialog_frame1_24_10_16_10.png");

		msg = cc.LabelTTF:create();
		msg:setFontSize(MSG_FONT_SIZE);
		msg:setAnchorPoint(cc.p(0, 0.5));
		msg:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT);
		msg:setDimensions(cc.size(MAX_LINE_WIDTH, 0));
	else
		rankIconBg = cell:getChildByTag(1);
		rankIconBgSize = rankIconBg:getContentSize();
		rankIcon = rankIconBg:getChildByTag(1):setTexture(ResourceMgr:getRankBigIconByLevel(data.player_info.rankLevel));
		rankName = rankIconBg:getChildByTag(2):setTexture(ResourceMgr:getRankTextByLevel(data.player_info.rankLevel))

		name = cell:getChildByTag(2);
		msgBg = cell:getChildByTag(3);
		msg = msgBg:getChildByTag(1);

		--msgBg:initWithFile(cc.rect(24, 10, 16, 10), "res/resources/chatView/chat_dialog_frame1_24_10_16_10.png");
		msg:retain()
        msg:removeFromParent()
        msgBg:removeSelf()

        msgBg = ccui.Scale9Sprite:create("res/resources/chatView/chat_dialog_frame1_24_10_16_10.png");
	end
	rankIconBg:setPositionX(0);
	name:setPositionX(rankIconBgSize.width+20);

	name:setColor(cc.c3b(114, 243, 255)):setString("["..data.player_info.nickname.."]");
	msg:setColor(cc.c3b(114, 243, 255)):setString(data.msg);

	local bgWidth, bgHeight, labelHeight = self:getStrSize(idx+1);
	rankIconBg:setPositionY(bgHeight);
	name:setPositionY(bgHeight-5);

	msgBg:setAnchorPoint(cc.p(0, 1));
	msgBg:setCapInsets(cc.rect(24, 10, 16, 10));
	msgBg:setPositionX(rankIconBgSize.width)
	msgBg:setPositionY(name:getPositionY()-MSG_FONT_HEIGHT-3);

	local size = cc.size(bgWidth+MSG_FONT_HEIGHT*2, labelHeight);
	msgBg:setPreferredSize(size);

	msgBg:addTo(cell, 3, 3);

	msg:setPositionX(MSG_FONT_HEIGHT*1.3);
	msg:setPositionY(labelHeight/2);
	msg:addTo(msgBg, 1, 1);
	return cell;
end
function CCBChatView:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell();
	local data = ChatDataMgr:getMsgList(self.m_nViewIndex)[idx+1];
	if UserDataMgr:getPalyerUID() == data.player_info.uid then
		return self:ownerTableCellAtIndex(cell, idx, data);
	else
		return self:otherTableCellAtIndex(cell, idx, data);
	end
end

function CCBChatView:numberOfCellsInTableView(table)
	return self.m_nViewCount;
end

function CCBChatView:onBtnClose()
	self:removeSelf();
end

--长度计算
function CCBChatView:getStringLenth(string)
	local len = string.len(string)
	local i = 1;
	local chCount = 0;
	local enCount = 0;
	while i <= len do
		if self:calcCharacterLength_UTF8(string.byte(string, i)) == 3 then
			chCount = chCount+1;
		elseif self:calcCharacterLength_UTF8(string.byte(string, i)) == 1 then
			enCount = enCount+1;
		end
		i = i+self:calcCharacterLength_UTF8(string.byte(string,i));
	end
	
	local stringLenth = chCount*3 + enCount;
	return stringLenth, chCount, enCount;
end

function CCBChatView:calcCharacterLength_UTF8(ch)
	if ch >= 240 and ch <= 247 then
		return 4;
	elseif ch >= 224 and ch <= 239 then --中文
		return 3;
	elseif ch >= 192 and ch <= 223 then
		return 2;
	else --英文字符
		return 1;
	end
end

function CCBChatView:onBtnSendMessage()
	if #self.m_editBox:getText() > 0 then
		if self.m_scheduler then
			 Tips:create(Str[22005])
			return;
		else
			local isContain, word = ChatDataMgr:isContainBadWords(self.m_editBox:getText()); 
			if isContain then
				Tips:create(Str[22006]..word);
				return;
			end
		end
	elseif self.m_editBox:getText() == "" or self.m_editBox:getText() == nil then
		Tips:create(Str[22001]);
		return;
	end

	if self.m_nViewIndex == CHANNEL_WORLD then
		Network:request("chat.chatHandler.send_msg_to_world", {msg=self.m_editBox:getText()}, function (rc, receiveData)
			if receiveData.code ~= 1 then
				Tips:create(ServerCode[receiveData.code]);
				return;
			end

			self.m_editBox:setText("");
			ChatDataMgr:setSendRemainSecond(self.m_nViewIndex, receiveData.remain_second and receiveData.remain_second or 10);
			self:nextSendMsgCountDown();
		end)
	elseif  self.m_nViewIndex == CHANNEL_ALLIANCE then
		Network:request("chat.chatHandler.send_msg_to_alliance", {msg=self.m_editBox:getText()}, function (rc, receiveData)
			if receiveData.code ~= 1 then
				Tips:create(ServerCode[receiveData.code]);
				return;
			end

			self.m_editBox:setText("");
			ChatDataMgr:setSendRemainSecond(self.m_nViewIndex, receiveData.remain_second and receiveData.remain_second or 10);
			self:nextSendMsgCountDown();
		end)
	elseif self.m_nViewIndex == CHANNEL_SYSTEM then
	end
end

function CCBChatView:onBtnSlot(index)
	for i=1, self.m_ccbNodeBtn:getChildrenCount() do
		self.m_ccbNodeBtn:getChildByTag(i):setEnabled(i ~= index);
	end

	self:flush(index);
	self.m_editBox:setText("");
end

function CCBChatView:flush(index)
	self.m_nViewIndex = index;
	self.m_nViewCount = #ChatDataMgr:getMsgList(self.m_nViewIndex);

	self.m_tableView:reloadData();
	if self.m_tableView:getViewSize().height < self.m_tableView:getContentSize().height then
		self.m_tableView:setContentOffset(self.m_tableView:maxContainerOffset());
	end
end

function CCBChatView:reloadViewData()
	self:flush(self.m_nViewIndex);
end

function CCBChatView:setTips()
	if self.m_nViewIndex == CHANNEL_WORLD then
		self.m_ccbNodeEditBox:setVisible(true);
		self.m_ccbBtnSend:setVisible(true):setEnabled(true);
		self.m_ccbSpriteSendTitle:setVisible(true);
		self.m_ccbLabelTips:setVisible(false);
	elseif  self.m_nViewIndex == CHANNEL_ALLIANCE then
		if 0 == UserDataMgr:getPlayerUnionLevel() then
			self.m_ccbNodeEditBox:setVisible(false);
			self.m_ccbBtnSend:setVisible(false):setEnabled(false);
			self.m_ccbSpriteSendTitle:setVisible(false);
			self.m_ccbLabelTips:setString(Str[22007]):setVisible(true);
		else
			self.m_ccbNodeEditBox:setVisible(true);
			self.m_ccbBtnSend:setVisible(true):setEnabled(true);
			self.m_ccbSpriteSendTitle:setVisible(true);
			self.m_ccbLabelTips:setVisible(false);
		end
	elseif self.m_nViewIndex == CHANNEL_SYSTEM then
		self.m_ccbNodeEditBox:setVisible(false);
		self.m_ccbBtnSend:setVisible(false):setEnabled(false);
		self.m_ccbSpriteSendTitle:setVisible(false);
		self.m_ccbLabelTips:setString(Str[22003]):setVisible(true);
		self.m_ccbNodeCountDown:setVisible(false);
	end
end

function CCBChatView:onBtnWorld()
	self:onBtnSlot(CHANNEL_WORLD);
	self:nextSendMsgCountDown();
	self:setTips();
end

function CCBChatView:onBtnAlliance()
	self:onBtnSlot(CHANNEL_ALLIANCE);
	self:nextSendMsgCountDown();
	self:setTips();
end

function CCBChatView:onBtnSystem()
	self:onBtnSlot(CHANNEL_SYSTEM);
	self:nextSendMsgCountDown();
	self:setTips();
end

function CCBChatView:unscheduleScriptEntry()
	if self.m_scheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_scheduler);
		self.m_scheduler = nil;

		self.m_ccbNodeCountDown:setVisible(false);
	end		
end

function CCBChatView:nextSendMsgCountDown()
	self:unscheduleScriptEntry();

	local leftTime = ChatDataMgr:getSendRemainSecond(self.m_nViewIndex);
	if leftTime > 0 then
		self.m_editBox:setPlaceHolder("");
		self.m_ccbNodeCountDown:setVisible(true);
		self.m_ccbLabelRemain:setString(leftTime..Str[22004]);

		if self.m_scheduler == nil then
			self.m_scheduler = self:getScheduler():scheduleScriptFunc(function ()
				leftTime = leftTime - 1;
				self.m_ccbLabelRemain:setString(leftTime..Str[22004]);

				ChatDataMgr:setSendRemainSecond(self.m_nViewIndex, leftTime);
				if leftTime <= 0 then
					self:unscheduleScriptEntry();
					self.m_editBox:setPlaceHolder(Str[22002]);
					self.m_ccbNodeCountDown:setVisible(false);
					ChatDataMgr:setSendRemainSecond(self.m_nViewIndex, 0);
				end
			end, 1, false);
		end
	else
		self.m_editBox:setPlaceHolder(Str[22002]);
		self.m_ccbNodeCountDown:setVisible(false);
	end	
end

return CCBChatView;
