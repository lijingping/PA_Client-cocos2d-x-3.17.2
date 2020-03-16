---------------
-- 好友CCB
---------------

local CCBReceiveWindowPopup = require("app.views.commonCCB.CCBReceiveWindowPopup");


local CCBFriendListCell = require("app.views.friendView.CCBFriendListCell");
local CCBRecommendListCell = require("app.views.friendView.CCBRecommendListCell");
local CCBPresentListCell = require("app.views.friendView.CCBPresentListCell");
local CCBApplicationListCell = require("app.views.friendView.CCBApplicationListCell");


local WishCell = require("app.views.friendView.WishCell");
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");
local Tips = require("app.views.common.Tips");
local CCBChatDialogbox = require("app.views.friendView.CCBChatDialogbox");

local CCBFriendView = class("CCBFriendView", function ()
	return CCBLoader("ccbi/friendView/CCBFriendView.ccbi")
end)

function CCBFriendView:onEnter()
	
end

function CCBFriendView:onExit()

end

function CCBFriendView:ctor()
	if display.resolution >= 2 then
		self:setScale(display.reduce);
	end
	self:enableNodeEvents();

	--好友列表
	self.m_friendList = {};
	--推荐其他玩家列表
	self.m_recommendedList = {};
	--好友的申请列表
	self.m_applicationList = {};
	--有新消息的玩家UID
	self.m_newMessageFriendUIDList = {};

	--创建好友列表的tableView
	self:createFriendListTableView();
	
	--界面默认为好友列表
	self:changeTab(1);
	--self:requestFriendList();

	--创建推荐界面
	self:createEditBox();
	self:createTableViewRecommendList();

	--创建相互赠送道具界面
	self:createTableViewWishList();
	self:createTableViewPresentList();

	--创建其他好友申请列表的tableView
	self:createTableViewApplicationList();
end

function CCBFriendView:requestFriendList()
	Network:request("social.friendHandler.list", nil, function (rc, receiveData)
		if receiveData.code ~= 1 then
			Tips:create(ServerCode[receiveData.code]);
			return;
		end

		--好友数量显示
		self.m_ccbLabelFriendNum:setString(#receiveData.friends);

		self.m_friendList = {};
		for k, v in ipairs(receiveData.friends) do
			if v.online == true then
				v.sort = v.power * 1000000 + v.famous_num;
			else
				--不在线的玩家排序就不用太严格，避免不在线的玩家战斗力高，排在在线玩家前面
				v.sort = v.power * 100 + v.famous_num;
			end
			v.m_curSystemTime = os.time();
			
			table.insert(self.m_friendList, v);
		end

		table.sort(self.m_friendList, function (a, b)
			return a.sort > b.sort;
		end)
		--dump(self.m_friendList);
		if self.m_tableViewFriendList then
			self.m_tableViewFriendList:reloadData();
		end
		if self.m_tableViewPresentList then
			self.m_tableViewPresentList:reloadData();
		end
	end)
end

function CCBFriendView:requestRecommendedList()
	Network:request("social.friendHandler.advice_friends", nil, function (rc, receiveData)
		if receiveData.code ~= 1 then
			Tips:create(ServerCode[receiveData.code]);
			return;
		end
		--dump(receiveData.player_list)
		
		self.m_recommendedList = receiveData.player_list;
		if self.m_tableViewRecommendList then
			self.m_tableViewRecommendList:reloadData();
		end
	end)
end

function CCBFriendView:requestApplicationList()
	Network:request("social.friendHandler.friend_requests", nil, function (rc, receiveData)
		if receiveData.code ~= 1 then
			Tips:create(ServerCode[receiveData.code])
			return;
		end
		--dump(receiveData.requests);
		self.m_applicationList = receiveData.requests;

		if self.m_tableViewApplicationList then
			self.m_tableViewApplicationList:reloadData();
		end
	end)
end

------------------------------------------------------------------------------------------------------
----------------------------------------------好-友-列-表----------------------------------------------
------------------------------------------------------------------------------------------------------

-- 创建好友列表的TableView
function CCBFriendView:createFriendListTableView()
	self.m_tableViewFriendList = cc.TableView:create(self.m_ccbLayerFriendList:getContentSize());
	self.m_tableViewFriendList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	self.m_tableViewFriendList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
	self.m_ccbLayerFriendList:addChild(self.m_tableViewFriendList);

   	self.m_tableViewFriendList:registerScriptHandler(function(table, idx) return self:cellSizeForTableFriendList(table, idx) end, cc.TABLECELL_SIZE_FOR_INDEX);
    self.m_tableViewFriendList:registerScriptHandler(function(table, idx) return self:tableCellAtIndexFriendList(table, idx) end, cc.TABLECELL_SIZE_AT_INDEX);
    self.m_tableViewFriendList:registerScriptHandler(function(table) return self:numberOfCellsInTableViewFriendList(table) end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);

	self.m_tableViewFriendList:reloadData()
end

function CCBFriendView:cellSizeForTableFriendList(table, idx)
	return 1050, 110;
end

function CCBFriendView:tableCellAtIndexFriendList(table, idx)
	local listItem = nil;
	local cell = table:dequeueCell()
	if cell == nil then 
		cell = cc.TableViewCell:new();
		listItem = CCBFriendListCell:create();
		cell:addChild(listItem)
		listItem:setPosition(cc.p(0,0))
		listItem:setTag(110)

		listItem:setInfo(self.m_friendList[idx+1]);
	else
		listItem = cell:getChildByTag(110)
		listItem:setInfo(self.m_friendList[idx+1]);
	end
	return cell;
end

function CCBFriendView:numberOfCellsInTableViewFriendList(table)
	if #self.m_friendList > 0 then
		self.m_ccbNodeNoneFriend:setVisible(false);
	else
		self.m_ccbNodeNoneFriend:setVisible(true);
	end
	return #self.m_friendList;
end

-----------------------------------------------------------------------------------------------------
------------------------------------------好-友-推-荐-列-表-------------------------------------------
-----------------------------------------------------------------------------------------------------
-- 创建添加好友的输入框
function CCBFriendView:createEditBox()
	self.m_editbox = cc.EditBox:create(self.m_ccbLayerEditBox:getContentSize(), "resources/friendView/friend_input.png");
	self.m_editbox:setAnchorPoint(cc.p(0, 0));
	self.m_editbox:setFontSize(20);
	self.m_editbox:setFontColor(cc.c3b(255, 255, 255));
	self.m_editbox:setPlaceholderFontSize(20);
	self.m_editbox:setPlaceholderFontColor(cc.c3b(128, 128, 128));
    self.m_editbox:setPlaceHolder("请输入好友的昵称");
	self.m_editbox:setMaxLength(32);
    self.m_editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE );
    self.m_editbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
    self.m_ccbLayerEditBox:addChild(self.m_editbox);
end

function CCBFriendView:createTableViewRecommendList()
	self.m_tableViewRecommendList = cc.TableView:create(self.m_ccbLayerRecommendList:getContentSize());
	self.m_tableViewRecommendList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	self.m_tableViewRecommendList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
	self.m_ccbLayerRecommendList:addChild(self.m_tableViewRecommendList);
	--self.m_tableViewRecommendList:setTouchEnabled(false);

   	self.m_tableViewRecommendList:registerScriptHandler(function(table, idx) return self:cellSizeForTableRecommendList(table, idx) end, cc.TABLECELL_SIZE_FOR_INDEX);
    self.m_tableViewRecommendList:registerScriptHandler(function(table, idx) return self:tableCellAtIndexRecommendList(table, idx) end, cc.TABLECELL_SIZE_AT_INDEX);
    self.m_tableViewRecommendList:registerScriptHandler(function(table) return self:numberOfCellsInTableViewRecommendList(table) end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);

	self.m_tableViewRecommendList:reloadData()
end

function CCBFriendView:cellSizeForTableRecommendList(table, idx)
	return 1080, 110;
end

function CCBFriendView:tableCellAtIndexRecommendList(table, idx)
	local cellNode, listItem1, listItem2
	local cell = table:dequeueCell()

	if cell == nil then 
		cell = cc.TableViewCell:new();

		cellNode = cc.Node:create();
		cellNode:setTag(200);
		cell:addChild(cellNode);

		listItem1 = CCBRecommendListCell:create();
		listItem1:setTag(210);
		cellNode:addChild(listItem1);
		listItem1:setInfo(self.m_recommendedList[idx * 2 + 1]);
		listItem1:setPosition(cc.p(0, 0));

		listItem2 = CCBRecommendListCell:create();
		listItem2:setTag(220);
		cellNode:addChild(listItem2);
		listItem2:setPosition(cc.p(listItem1.m_ccbSpriteBack:getContentSize().width + 10, 0));
		if math.ceil(#self.m_recommendedList/2) == idx + 1 and #self.m_recommendedList % 2 == 1 then
			listItem2:setVisible(false)
		else
			listItem2:setInfo(self.m_recommendedList[idx * 2 + 2]);
			listItem2:setVisible(true);
		end
	else

		cellNode = cell:getChildByTag(200);
		if cellNode then
			listItem1 = cellNode:getChildByTag(210);
			if listItem1 then
				listItem1:setInfo(self.m_recommendedList[idx * 2 + 1]);
			end
			listItem2 = cellNode:getChildByTag(220);
			if math.ceil(#self.m_recommendedList/2) == idx + 1 and #self.m_recommendedList % 2 == 1 then
				listItem2:setVisible(false);
			else
				listItem2:setInfo(self.m_recommendedList[idx * 2 + 2]);
				listItem2:setVisible(true);
			end
		end
	end
	return cell;
end

function CCBFriendView:numberOfCellsInTableViewRecommendList(table)
	--return 3; --不做滑动，只留3行
	return math.ceil(#self.m_recommendedList / 2);
end

function CCBFriendView:onBtnSearchFriend()
	if self.m_editbox:getText() == "" then
		Tips:create(Str[5012]);
		return;
	end
	
	Network:request("social.friendHandler.search", {name = self.m_editbox:getText()}, function (rc, receiveData)
		--print("搜索好友")
		if receiveData.code ~= 1 then
			Tips:create(ServerCode[receiveData.code])
			return;
		end
		--搜索到好友就发送加好友申请
		Network:request("social.friendHandler.befriend", {friend = receiveData.data.uid}, function (rc, receiveData2)
			--print("申请加为好友")
			if receiveData2.code ~= 1 then
				Tips:create(ServerCode[receiveData2.code]);
				return;
			end
	
			if data.nickname then
				Tips:create(string.format("已成功向[%s]发送好友申请。", receiveData2.data.nickname));
			end
		end)
	end)
end

function CCBFriendView:onBtnRefreshRecommendList()
	--print("刷新")
	self:requestRecommendedList();
end

--------------------------------------------------------------------------------------------------------------
-------------------------------------------------许-愿-列-表---------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- 创建许愿列表的TableView
function CCBFriendView:createTableViewWishList()
	-- local wishListSize = self.m_ccbLayerWishList:getContentSize()
	self.m_wishList = {};
	for k, v in pairs(table.clone(require("app.constants.friend_gift"))) do
		table.insert(self.m_wishList, v);
	end
	--dump(self.m_wishList);

	self.m_tableViewWishList = cc.TableView:create(self.m_ccbLayerWishList:getContentSize());
	self.m_tableViewWishList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	self.m_tableViewWishList:setDelegate();
	self.m_tableViewWishList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
	self.m_ccbLayerWishList:addChild(self.m_tableViewWishList);

	self.m_tableViewWishList:registerScriptHandler(function(table, cell) self:tableCellTouchedWishList(table, cell) end, cc.TABLECELL_TOUCHED);
   	self.m_tableViewWishList:registerScriptHandler(function(table, idx) return self:cellSizeForTableWishList(table, idx) end, cc.TABLECELL_SIZE_FOR_INDEX);
    self.m_tableViewWishList:registerScriptHandler(function(table, idx) return self:tableCellAtIndexWishList(table, idx) end, cc.TABLECELL_SIZE_AT_INDEX);
    self.m_tableViewWishList:registerScriptHandler(function(table) return self:numberOfCellsInTableViewWishList(table) end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);

	self.m_tableViewWishList:reloadData();
end

--触摸Cell
function CCBFriendView:tableCellTouchedWishList(table, cell)
	local cellItem = cell:getChildByTag(110);
	local iconInfo = cellItem:getIconInfo();

	local showText = string.format("是否将请求物品变更为[%s]", iconInfo.name)
	local ccbMessageBox = CCBMessageBox:create("提示", showText, MB_YESNO)--是否接受所有好友申请
	ccbMessageBox.onBtnOK = function ()
		self.m_curWishItem = iconInfo;
		Network:request("social.giftHandler.wish", {item_id = iconInfo.id}, function (rc, receiveData)
			if receiveData.code ~= 1 then
				Tips:create(ServerCode[receiveData.code]);
				return;
			end
			--dump(receiveData);
			Tips:create(string.format("你的请求已经变更为[%s]", iconInfo.name));
			UserDataMgr:setPlayerWishItemID(iconInfo.id);
			self.m_tableViewWishList:reloadData();
			ccbMessageBox:removeSelf();
		end)
	end
	ccbMessageBox.onBtnCancel = function ()
		ccbMessageBox:removeSelf();
	end
end

function CCBFriendView:cellSizeForTableWishList(table, idx)
	return 120, 135
end

function CCBFriendView:tableCellAtIndexWishList(table, idx)
	local wishItemInfo = ItemDataMgr:getItemBaseInfo(tonumber(self.m_wishList[idx+1]["$item_id"]))
	--dump(wishItemInfo);
	local listItem = nil;
	local cell = table:dequeueCell();
	if cell == nil then
		cell = cc.TableViewCell:new();
		listItem = WishCell:create();

		cell:addChild(listItem);
		listItem:setPosition(cc.p(0, 0));
		listItem:setTag(110);

		listItem:setIconInfo(wishItemInfo) -- 因为table的索引从1开始
	else
		listItem = cell:getChildByTag(110)
		listItem:setIconInfo(wishItemInfo)
	end
	return cell;
end

function CCBFriendView:numberOfCellsInTableViewWishList(table)
	return #self.m_wishList;
end

function CCBFriendView:onWishItemTouch(data)
	App:getRunningScene():requestWishItem(data);
end

------------------------------------------------------------------------------------------------------------
-------------------------------------------------赠-送-列-表-------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- 创建好友馈赠的TableView
function CCBFriendView:createTableViewPresentList()
	self.m_tableViewPresentList = cc.TableView:create(self.m_ccbLayerPresentList:getContentSize());
	self.m_tableViewPresentList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	self.m_tableViewPresentList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
	self.m_ccbLayerPresentList:addChild(self.m_tableViewPresentList);

   	self.m_tableViewPresentList:registerScriptHandler(function(table, idx) return self:cellSizeForTablePresentList(table, idx) end, cc.TABLECELL_SIZE_FOR_INDEX);
    self.m_tableViewPresentList:registerScriptHandler(function(table, idx) return self:tableCellAtIndexPresentList(table, idx) end, cc.TABLECELL_SIZE_AT_INDEX);
    self.m_tableViewPresentList:registerScriptHandler(function(table) return self:numberOfCellsInTableViewPresentList(table) end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);

	self.m_tableViewPresentList:reloadData()
end

function CCBFriendView:cellSizeForTablePresentList(table, idx)
	return 890, 110
end

function CCBFriendView:tableCellAtIndexPresentList(table, idx)
	local cellNode = nil;
	local cell = table:dequeueCell()

	if cell == nil then
		cell = cc.TableViewCell:new();

		cellNode = CCBPresentListCell:create()
		cellNode:setTag(100)
		cell:addChild(cellNode);

		cellNode:setShowInfo(self.m_friendList[idx+1]);
	else
		cellNode = cell:getChildByTag(100)
		if cellNode then
			cellNode:setShowInfo(self.m_friendList[idx+1]);
		end
	end
	return cell
end

function CCBFriendView:numberOfCellsInTableViewPresentList(table)
	return #self.m_friendList;
end

-----------------------------------------------------------------------------------------------------------
----------------------------------------------好-友-申-请---------------------------------------------------
-----------------------------------------------------------------------------------------------------------

-- 创建好友申请的TableView
function CCBFriendView:createTableViewApplicationList()
	self.m_tableViewApplicationList = cc.TableView:create(self.m_ccbLayerApplicationList:getContentSize())
	self.m_tableViewApplicationList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	self.m_tableViewApplicationList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self.m_ccbLayerApplicationList:addChild(self.m_tableViewApplicationList)

   	self.m_tableViewApplicationList:registerScriptHandler(function(table, idx) return self:cellSizeForTableApplicationList(table, idx) end, cc.TABLECELL_SIZE_FOR_INDEX);
    self.m_tableViewApplicationList:registerScriptHandler(function(table, idx) return self:tableCellAtIndexApplicationList(table, idx) end, cc.TABLECELL_SIZE_AT_INDEX);
    self.m_tableViewApplicationList:registerScriptHandler(function(table) return self:numberOfCellsInTableViewApplicationList(table) end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);

	self.m_tableViewApplicationList:reloadData()
end

function CCBFriendView:cellSizeForTableApplicationList(table, idx)
	return 1080, 110;
end

function CCBFriendView:tableCellAtIndexApplicationList(table, idx)
	local cellNode, listItem1, listItem2
	local cell = table:dequeueCell()

	if cell == nil then  
		cell = cc.TableViewCell:new();		
		
		cellNode = cc.Node:create();
		cellNode:setTag(110)
		cellNode:setAnchorPoint(cc.p(0,0))
		cell:addChild(cellNode)

		listItem1 = CCBApplicationListCell:create()
		listItem1:setTag(111)
		cellNode:addChild(listItem1)
		listItem1:setShowInfo(self.m_applicationList[idx * 2 + 1])

		listItem2 = CCBApplicationListCell:create()
		listItem2:setTag(112)
		cellNode:addChild(listItem2)
		listItem2:setPosition(cc.p(listItem1.m_ccbSpriteBack:getContentSize().width + 10, 0))
		if math.ceil(#self.m_applicationList/2) == idx + 1 and #self.m_applicationList % 2 == 1 then
			listItem2:setVisible(false)
		else
			listItem2:setShowInfo(self.m_applicationList[idx * 2 + 2])
			listItem2:setVisible(true)
		end
	else

		cellNode = cell:getChildByTag(110)
		if cellNode then
			listItem1 = cellNode:getChildByTag(111)
			if listItem1 then
				listItem1:setShowInfo(self.m_applicationList[idx * 2 + 1])
			end
			listItem2 = cellNode:getChildByTag(112)	
			if math.ceil(#self.m_applicationList/2) == idx + 1 and #self.m_applicationList % 2 == 1 then
				listItem2:setVisible(false)
			else
				listItem2:setShowInfo(self.m_applicationList[idx * 2 + 2])
				listItem2:setVisible(true)
			end
		end

	end
	return cell
end

function CCBFriendView:numberOfCellsInTableViewApplicationList(table)
	--print(#self.m_applicationList)
	if #self.m_applicationList ~= 0 then
		self.m_ccbLabelNoApply:setVisible(false);
		self.m_ccbNodeBtnDoAll:setVisible(true);
	else
		self.m_ccbLabelNoApply:setVisible(true);
		self.m_ccbNodeBtnDoAll:setVisible(false);
	end

	return math.ceil(#self.m_applicationList/2);
end

function CCBFriendView:onBtnReceiveAll()
	Network:request("social.friendHandler.accept_friend", nil, function (rc, receiveData)
		--print ( "接受好友申请 ")
		if receiveData.code ~= 1 then
			Tips:create(ServerCode[receiveData.code]);
			return;
		end
		self:requestApplicationList();
	end)	
end

function CCBFriendView:onBtnRefuseAll()
	Network:request("social.friendHandler.reject_friend", nil, function (rc, receiveData)
		--print("拒绝好友请求")
		if receiveData.code ~= 1 then
			Tips:create(ServerCode[receiveData.code]);
			return;
		end
		self:requestApplicationList();
	end)
end

-- 好友列表界面按钮
function CCBFriendView:onBtnFriendList()
	self:changeTab(1);
end

-- 添加好友界面按钮
function CCBFriendView:onBtnAddFriend()
	self:changeTab(2);
end

-- 好友馈赠界面按钮
function CCBFriendView:onBtnWish()
	self:changeTab(3);
end

-- 好友申请界面按钮
function CCBFriendView:onBtnApplication()
	self:changeTab(4)
end

function CCBFriendView:changeTab(num)
	self:setShowData(num);
	for i = 1, 4 do
		if i == num then
			--当前标签高亮
			self.m_ccbNodeTab:getChildByTag(i):setEnabled(false);
			--显示内容
			self.m_ccbLayerRoot:getChildByTag(i):setVisible(true);
		else
			self.m_ccbNodeTab:getChildByTag(i):setEnabled(true);
			self.m_ccbLayerRoot:getChildByTag(i):setVisible(false);
		end
	end
end

function CCBFriendView:setShowData(num)
	self.m_tablePage = num;
	if num == 1 then
		self:showFriendList();
	elseif num == 2 then
		self:showAddFriend();
	elseif num == 3 then
		self:showWish();
	elseif num == 4 then
		self:showApplication();
	end
end

function CCBFriendView:showFriendList()
	self:requestFriendList();
	self:requestFriendNewMessage();
end

function CCBFriendView:showAddFriend()
	if #self.m_recommendedList == 0 then
		self:requestRecommendedList();
	end
end

function CCBFriendView:showWish()
	self:requestFriendList();
end

function CCBFriendView:showApplication()
	self:cleanHintApplication();
	self:requestApplicationList();
end

--------------------------------------------------------------------分------割------线--------------------------------------------------------------------------

--删除一个好友后刷新好友列表
function CCBFriendView:deleteFriend(friendInfo)
	for k, v in ipairs(self.m_friendList) do
		if v.uid == friendInfo.uid then
			--print("删除好友", friendInfo.nickname);
			table.remove(self.m_friendList, k);
		end
	end
	self.m_tableViewFriendList:reloadData();
	--local offset = self.m_tableViewFriendList:getContentOffset();
	--self.m_tableViewFriendList:setContentOffset(offset);
end

--被其他玩家添加成好友时调用
function CCBFriendView:beAddedFromFriend(data)
	--dump(data);
	Tips:create("你与[".. data.nickname .. "]成为了好友");
	self:requestFriendList();
end

--被好友删除时调用
function CCBFriendView:beDeletedFromFriend(data)
	--dump(data);
	for k, v in ipairs(self.m_friendList) do
		if v.uid == data.target then
			Tips:create("你与[".. v.nickname .. "]失去了好友关系");
			table.remove(self.m_friendList, k);
		end
	end
	self.m_tableViewFriendList:reloadData();	
end

--创建私聊对话框，friendInfo由cell里的info传过来
function CCBFriendView:showChatDialogbox(friendInfo)
	if self.m_dialogboxChat == nil then
		self.m_dialogboxChat = CCBChatDialogbox:create(friendInfo);
		self.m_ccbNodeDialogbox:addChild(self.m_dialogboxChat);
		self.m_ccbNodeDialogbox:setPosition(cc.p(0, 0));
	end
end

function CCBFriendView:closeChatDialogbox()
	if self.m_dialogboxChat then
		self.m_dialogboxChat:removeSelf();
		self.m_dialogboxChat = nil;
	end
end

--好友发来的新消息，带有消息内容
function CCBFriendView:newMassageFromFriend(data)
	dump(data);
	if self.m_dialogboxChat then
		if self.m_dialogboxChat:getFriendUID() == data.info.sender then
			self.m_dialogboxChat:notifyChatNews(data);
		else
			self:requestFriendNewMessage();
		end
	else
		self:requestFriendNewMessage();
		if self.m_tablePage ~= 1 then
			self.m_ccbSpriteHintMessage:setVisible(true);
		end
	end
end

--请求是否有好友发来新消息，返回只有好友UID列表，不带消息内容
function CCBFriendView:requestFriendNewMessage()
	Network:request("social.friendHandler.have_new_msg", nil, function (rc, receiveData)
		if receiveData.code ~= 1 then
			Tips:create(ServerCode[receiveData.code]);
			return;
		end
		-- dump(receiveData);
		self.m_newMessageFriendUIDList = receiveData.data;
		
		if #self.m_newMessageFriendUIDList ~= 0 then
			self.m_ccbSpriteHintMessage:setVisible(true);
		else
			self.m_ccbSpriteHintMessage:setVisible(false);
		end

		if self.m_tableViewFriendList then
			self.m_tableViewFriendList:reloadData();
		end
	end)
end

function CCBFriendView:getMessageNewHintList()
	return self.m_newMessageFriendUIDList;
end

-- function CCBFriendView:requestFriendMessageToReaded()
-- 	Network:request("social.friendHandler.update_chat_read", {friend = receiveData.data.uid}, function (rc, receiveData)
-- 		if receiveData.code ~= 1 then
-- 			Tips:create(ServerCode[receiveData.code]);
-- 			return;
-- 		end
-- 		dump(receiveData);
-- 	end)
-- end

-- function CCBFriendView:addMessageFriendUID(friendUID)
-- 	for k, v in pairs(self.m_newMessageFriendUIDList) do
-- 		if v == friendUID then
-- 			return;
-- 		end
-- 	end
-- 	table.insert(self.m_newMessageFriendUIDList, friendUID);
-- end

-- function CCBFriendView:deleteFriendUID(friendUID)
-- 	for k, v in pairs(self.m_newMessageFriendUIDList) do
-- 		if v == friendUID then
-- 			table.remove(self.m_newMessageFriendUIDList, k);
-- 			return;
-- 		end
-- 	end	
-- end

function CCBFriendView:newFriendHint(data)
	-- self.m_ccbSpriteHintMessage:setVisible(true);
	-- dump(data);
	if self.m_tableViewFriendList then
		self:requestFriendList();
	end
end

function CCBFriendView:newApplicationHint(data)
	--dump(data)
	if self.m_tablePage ~= 4 then
		self.m_ccbSpriteHintApplication:setVisible(true);
	end
	
	if self.m_tableViewApplicationList then
		self:requestApplicationList();
	end
end

function CCBFriendView:cleanHintApplication()
	self.m_ccbSpriteHintApplication:setVisible(false);
end

function CCBFriendView:cleanHintMessage(friendUID)
	for k, v in pairs(self.m_newMessageFriendUIDList) do
		if v == friendUID then
			table.remove(self.m_newMessageFriendUIDList, k);
			break;
		end
	end	
	if #self.m_newMessageFriendUIDList == 0 then
		self.m_ccbSpriteHintMessage:setVisible(false);
	end
end

return CCBFriendView