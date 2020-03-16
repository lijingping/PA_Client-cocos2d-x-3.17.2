local CCBMailCell = require("app.views.mailView.CCBMailCell")
--local CCBPopWindow = require("app.views.commonCCB.CCBPopWindow");
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");
local CCBReceiveItemCell = require("app.views.commonCCB.CCBReceiveItemCell")
local CCBReceiveWindowPopup = require("app.views.commonCCB.CCBReceiveWindowPopup")
local Tips = require("app.views.common.Tips");
local ResourceMgr = require("app.utils.ResourceMgr");

---------------
-- CCB邮件界面
---------------
local CCBMailView = class("CCBMailView", function ()
	return CCBLoader("ccbi/mailView/CCBMailView.ccbi")
end)

local g_BtnNumber = 1

local g_MailLoadList = {}


local g_tableCurMailData = {}   -- 当前邮件数据Table

-- 邮件类型Table
local g_tableMailType = {"system", "ship", "earth", "domain", "alliance"};
local g_tableMailTable = {g_tableSystemMail = {}, g_tableShipMail = {}, g_tableEarthMail = {}, g_tableDomainMail = {}, g_tableAllianceMail = {}};

-- 字体置灰 #cccccc
local grayColor = cc.c3b(204, 204, 204);

-- mail_state
-- 0 未读， 1 已读， 2已删除， 3 有附件未领取 4 有附件已领取

local contentTopShadePos = cc.p(22, 176);
local contentBottonShadePos = cc.p(22, 52);
local scrollSmallSize = cc.size(720, 220);
local scrollBigSize = cc.size(720, 345);
local deleteBtnPos = cc.p(314, -247);
local receiveAllBtnPos = cc.p(462, -247);

function CCBMailView:ctor()
	if display.resolution >= 2 then
		self:resolution();
	end

	self.m_labelContent = nil;
	self:init()

	g_BtnNumber = 1
	self.m_ccbNodeMailMain:setVisible(false);
	self.m_ccbLabelNoneMail:setVisible(true);

	self.m_ccbBtnReceiveAll:setEnabled(false);
	self.m_ccbNodeReceiveAll:setVisible(false);
	self.m_ccbNodeDeleteAll:setPosition(receiveAllBtnPos);

	-- print("os .time ", os.time());
	
end

function CCBMailView:resolution()
	self:setScale(display.reduce);
end

function CCBMailView:init()
	self:requestToLoadMailList();
	self:onUpdateView();
	self:createTextContentLabel();

--   暂时没有邮件  的文本框   显示与否
	-- self.m_ccbLabelNoneMail:setVisible(true)
--   设置系统邮件节点的     显示与否 
	-- self.m_ccbNodeMailMain:setVisible(false)

--   全部接受按钮  是否可用
	-- self.m_ccbBtnReceiveAll:setEnabled(true)	

 -- 	for i = 1, 5 do 
 -- 		local button = self.m_ccbCenterNode:getChildByTag(i);
 -- 		if button then
 -- 			button:setTitleBMFontForState("res/resources/font/ui_font.fnt", cc.CONTROL_STATE_NORMAL);
	-- 		button:setTitleBMFontForState("res/resources/font/ui_font.fnt", cc.CONTROL_STATE_DISABLED);
	-- 	end
	-- end
	-- self.m_ccbBtnReceiveAll:setTitleBMFontForState("res/resources/font/ui_font.fnt", cc.CONTROL_STATE_NORMAL);
	-- self.m_ccbBtnReceiveAll:setTitleBMFontForState("res/resources/font/ui_font.fnt", cc.CONTROL_STATE_DISABLED);

	-- self.m_ccbBtnReceive:setTitleBMFontForState("res/resources/font/ui_font.fnt", cc.CONTROL_STATE_NORMAL);
	-- self.m_ccbBtnReceive:setTitleBMFontForState("res/resources/font/ui_font.fnt", cc.CONTROL_STATE_DISABLED);
end

-- 设置按钮的可用与否及按钮对应的界面
-- function CCBMailView:setBtnEnable(buttonNum)
-- 	for i = 1, 5 do
-- 		if buttonNum ~= i  then
-- 			self.m_ccbCenterNode:getChildByTag(i):setEnabled(true);
-- 		else
-- 			self.m_ccbCenterNode:getChildByTag(i):setEnabled(false);
-- 		end
-- 	end

-- 	if #g_MailLoadList == 0 then 
-- 		self.m_ccbNodeMailMain:setVisible(false)
-- 		self.m_ccbLabelNoneMail:setVisible(true)	
-- 	else
-- 		self.m_ccbNodeMailMain:setVisible(true)
-- 		self.m_ccbLabelNoneMail:setVisible(false)
-- 	end
-- 	self.m_ccbLabelMailCount:setString(string.format(Str[6001], #g_MailLoadList))

-- end

function CCBMailView:createTableView()
	local mailListSize = self.m_ccbLayerMailList:getContentSize();
	self.mailListTableView = cc.TableView:create(mailListSize);
	self.mailListTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL); -- 向上下滚动
	self.mailListTableView:setDelegate();
	self.mailListTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN); -- 从上到下填充
	self.m_ccbLayerMailList:addChild(self.mailListTableView)

	
	self.mailListTableView:registerScriptHandler(function (table, cell) self:tableCellTouched(table, cell); end , cc.TABLECELL_TOUCHED)
	self.mailListTableView:registerScriptHandler(function (table, idx) return self:cellSizeForTable(table, idx) end, cc.TABLECELL_SIZE_FOR_INDEX)
	self.mailListTableView:registerScriptHandler(function (table, idx) return self:tableCellAtIndex(table, idx) end, cc.TABLECELL_SIZE_AT_INDEX)
	self.mailListTableView:registerScriptHandler(function (table) return self:numberOfCellsInTableView(table) end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

	self.mailListTableView:reloadData()

end

function CCBMailView:tableCellTouched(table, cell)

	local nodeItem = cell:getChildByTag(100)
	if nodeItem then 
		local itemData = nodeItem:getCellData()
		self.m_currentMailID = itemData.id;

		if itemData.mail_state == 0 then
			self:requestToMarkMail(itemData);
			self.m_mailUnreadCount = self.m_mailUnreadCount - 1;
			self.m_ccbLabelMailCount:setString(string.format(Str[6001], self.m_mailCount, self.m_mailUnreadCount));
		end
		nodeItem:setMail_state();  -- 会改变g_MailLoadList 里的数据。
	
		local offset = table:getContentOffset()
		nodeItem:onTouchMailCell()

		g_tableCurMailData = itemData;

		self.m_presentTableView:reloadData();
		self:operationForSelectMail(itemData);
		
		table:reloadData()
		table:setContentOffset(offset)

		self:setTextData(itemData);
		self.m_presentTableView:reloadData();
	end
end

function CCBMailView:cellSizeForTable(table, idx)
	return 310,95
end

function CCBMailView:tableCellAtIndex(table, idx)

	local listItem = nil;
	local cell = table:dequeueCell()
	if nil == cell then 
		cell = cc.TableViewCell:new();
		listItem = CCBMailCell:create();
		cell:addChild(listItem);
		listItem:setPosition(cc.p(0,0))
		listItem:setTag(100)

		listItem:setData(g_MailLoadList[idx+1])
	else
		listItem = cell:getChildByTag(100)
		listItem:setData(g_MailLoadList[idx+1])
	end

	return cell;
end

function CCBMailView:numberOfCellsInTableView(table)
	if g_MailLoadList ~= nil then
		return #g_MailLoadList;
	else
		return 0;
	end
end

-- 设置数据,对界面初始化
function CCBMailView:setData(data)
 -- dump(data)
 -- "<var>" = {
 --   1 = {
 --         "attachment" = {
 --          1 = *MAX NESTING*
 --        }
 --        "content"    = "查询邮件的测试"
 --        "created_at" = "2017-3-29"
 --        "ms_time"    = 213543534;
 --        "id"         = 5
 --        "mail_state" = 3
 --        "title"      = "尊敬的召唤师"
 --        "type"       = "ship"
 --     }
 --	 }
 -- 	dump(g_MailLoadList[1].attachment)
-- 	"<var>" = {
--     1 = {
--         "count"   = 100
--         "item_id" = 10009
--     }
--     2 = {
--         "count"   = 50
--         "item_id" = 10010
--     }
-- }

	g_MailLoadList = data;

	self.m_ccbNodeMailMain:setVisible(true);
	self.m_ccbLabelNoneMail:setVisible(false);
	if #g_MailLoadList ~= 0 then

		if g_MailLoadList[1].mail_state == 0 then
			self:requestToMarkMail(g_MailLoadList[1]);
		end
		g_MailLoadList[1] = self:setFirstMailRead(g_MailLoadList[1]);

	else
		-- self.m_ccbNodeMailMain:setVisible(false);
		-- self.m_ccbLabelNoneMail:setVisible(true);
	end
	self.m_mailCount = #g_MailLoadList;
	self.m_mailUnreadCount = 0;
	self.m_presentMailCount = 0;
	-- dump(g_MailLoadList);
	for k, v in pairs(g_MailLoadList) do
		if v.mail_state == 0 then
			self.m_mailUnreadCount = self.m_mailUnreadCount + 1;
			if #v.attachment ~= 0 then
				self.m_presentMailCount = self.m_presentMailCount + 1;
			end
		elseif v.mail_state == 3 then
			self.m_presentMailCount = self.m_presentMailCount + 1;
		end
	end

	self.m_ccbLabelMailCount:setString(string.format(Str[6001], self.m_mailCount, self.m_mailUnreadCount));

	if self.m_presentMailCount > 0 then
		-- self.m_ccbBtnDeleteAll:setVisible(true);
		self.m_ccbNodeReceiveAll:setVisible(true);
		self.m_ccbNodeDeleteAll:setPosition(deleteBtnPos);
		-- self.m_ccbBtnReceiveAll:setPosition(receiveAllBtnPos);
		self.m_ccbBtnReceiveAll:setEnabled(true);
	else
		-- self.m_ccbBtnDeleteAll:setVisible(true);
		-- self.m_ccbBtnReceiveAll:setEnabled(false);
		-- self.m_ccbNodeReceiveAll:setVisible(false);
		-- self.m_ccbNodeDeleteAll:setPosition(receiveAllBtnPos);
	end

	-- 一开始点进界面显示的数据。
	-- 邮件附件的内容
	g_tableCurMailData = g_MailLoadList[1];
	self:operationForSelectMail(g_MailLoadList[1]);

	MailDataMgr:setCurTouchMailData(g_MailLoadList[1]);
	self:setTextData(g_MailLoadList[1]);

	-- self:onUpdateView();
	self.mailListTableView:reloadData();
	self.m_presentTableView:reloadData();
end

-- 标记邮件第一封为已读
function CCBMailView:setFirstMailRead(firstMail)
	if firstMail.mail_state ~= 4 then
		if #firstMail.attachment == 0 then
			firstMail.mail_state = 1;
		else
			firstMail.mail_state = 3;
		end
	end
	return firstMail;
end

-- 获得全部礼物的数据
function CCBMailView:setAllPresentData(data)
	
	if self.m_ccbNodeAttachment:isVisible() then
		if g_tableCurMailData.mail_state == 3 then
			self.m_ccbBtnReceive:setEnabled(false)	
			-- self.m_ccbBtnReceive:getTitleLabel():setString(Str[6002]);
			self.m_ccbNodeReceiveBtn:removeAllChildren();
			local sprite = cc.Sprite:create(ResourceMgr:getMailBtnReceiveAlready());
			self.m_ccbNodeReceiveBtn:addChild(sprite);
		end
	end
	self.m_presentMailCount = 0;
	self:setOneDeleteBtnHere();
	self:setMailStateAfterReceiveAll();
end

function CCBMailView:onUpdateView()

 	self:createTableView();
 	self:createPresentTableView();

end


-- 系统邮件界面按钮
-- function CCBMailView:onBtnSystemMail()

-- 	-- 对小红点的操作
-- 	if self.m_ccbSysMailHint:isVisible() then
-- 		self.m_ccbSysMailHint:setVisible(false)
-- 	end

-- 	g_BtnNumber = 1;
-- 	g_MailLoadList = nil;

-- 	g_MailLoadList = g_tableMailTable[1];

		
-- 	self:setBtnEnable(g_BtnNumber);

-- 	if #g_MailLoadList ~= 0 then 
-- 		if g_MailLoadList[1].mail_state == 0 then
-- 			self:requestToMarkMail(g_MailLoadList[1]);
-- 		end
-- 		g_MailLoadList[1] = self:setFirstMailRead(g_MailLoadList[1]);
-- 		self.m_currentMailID = g_MailLoadList[1].id;

-- 		MailDataMgr:setCurTouchMailData(g_MailLoadList[1]);
-- 		self:setTextData(g_MailLoadList[1]);
-- 		-- 对礼物兰进行操作
-- 		g_tableCurMailData = g_MailLoadList[1];
-- 		if self.m_presentTableView then
-- 			self.m_presentTableView:reloadData();
-- 		end
-- 		self:operationForReceiveBtnByData(g_MailLoadList[1]);
-- 		self.mailListTableView:reloadData();
-- 	end

-- end


-- 点击邮件传入数据，设置接收按钮
function CCBMailView:operationForSelectMail(data)
	-- 标记邮件ID
	self.m_currentMailID = data.id;

-- 为已读无附件邮件
	if data.mail_state == 1 then
		self.m_ccbNodeAttachment:setVisible(false)
		self.m_ccbScale9SpriteContentShade:setPosition(contentBottonShadePos);
		self.m_ccbScrollViewMailContent:setViewSize(scrollBigSize);

	else
		self.m_ccbNodeAttachment:setVisible(true)
		self.m_ccbScale9SpriteContentShade:setPosition(contentTopShadePos);
		self.m_ccbScrollViewMailContent:setViewSize(scrollSmallSize);

		-- 对接受按钮的操作
		self.m_ccbNodeReceiveBtn:removeAllChildren();
		if data.mail_state == 4 then

			self.m_ccbBtnReceive:setEnabled(false)
			-- self.m_ccbBtnReceive:getTitleLabel():setString(Str[6002]);
			local sprite = cc.Sprite:create(ResourceMgr:getMailBtnReceiveAlready());
			self.m_ccbNodeReceiveBtn:addChild(sprite);
		else
			self.m_ccbBtnReceive:setEnabled(true)
			-- self.m_ccbBtnReceive:getTitleLabel():setString(Str[6003]);
			local sprite = cc.Sprite:create(ResourceMgr:getMailBtnReceive());
			self.m_ccbNodeReceiveBtn:addChild(sprite);
		end
	end
end

-- 接收附件
function CCBMailView:onBtnReceive()
	self:requestReceiveOneMail(self.m_currentMailID);
end

-- 成功接收单封邮件的附件操作
function CCBMailView:reloadMailListData()
	for k, v in pairs(g_MailLoadList) do
		if self.m_currentMailID == v.id then
			v.mail_state = 4;
		end
	end
	self:reloadListWithOffset();
	self.m_presentTableView:reloadData();
	-- 删除和接受按钮的操作
	self.m_presentMailCount = self.m_presentMailCount - 1;
	if self.m_presentMailCount > 0 then

	else
		self.m_ccbBtnReceiveAll:setEnabled(false);
		self.m_ccbNodeReceiveAll:setVisible(false);
		self.m_ccbNodeDeleteAll:setPosition(receiveAllBtnPos);
	end
end

function CCBMailView:reloadListWithOffset()
	local offset = self.mailListTableView:getContentOffset();
	self.mailListTableView:reloadData();
	self.mailListTableView:setContentOffset(offset);
	self.m_ccbBtnReceive:setEnabled(false);
	-- self.m_ccbBtnReceive:getTitleLabel():setString(Str[6002]);
	self.m_ccbNodeReceiveBtn:removeAllChildren();
	local sprite = cc.Sprite:create(ResourceMgr:getMailBtnReceiveAlready());
	self.m_ccbNodeReceiveBtn:addChild(sprite);
end

-- 接收全部附件
function CCBMailView:onBtnReceiveAll()
	if self.m_presentMailCount < 0 then
		Tips:create(Str[6007]);
		return;
	end
	local ccbMessageBox = CCBMessageBox:create(Str[3032], Str[4032], MB_YESNO)--是否接收全部邮件附件？
	ccbMessageBox.onBtnOK = function ()
		self:requestReceiveAll();
		ccbMessageBox:removeSelf();
	end
	ccbMessageBox.onBtnCancel = function ()
		ccbMessageBox:removeSelf();
	end
end

function CCBMailView:onBtnQuickDelete()
	local haveReadMail = 0;
	for k, v in pairs(g_MailLoadList) do 
		if v.mail_state == 1 or v.mail_state == 4 then
			haveReadMail = 1;
			break;
		end
	end
	if haveReadMail == 1 then
		local ccbMessageBox = CCBMessageBox:create(Str[3038], Str[4038], MB_YESNO)--是否删除所有已读已领取邮件
		ccbMessageBox.onBtnOK = function()
			self:requestDeleteMail();
			ccbMessageBox:removeSelf();
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
	else
		Tips:create(Str[6008]);
	end
end

-- 接收全部邮件后设置邮件状态
function CCBMailView:setMailStateAfterReceiveAll()

	for k, v in pairs(g_MailLoadList) do
		if #v.attachment ~= 0 then
			if v.mail_state == 0 then
				self.m_mailUnreadCount = self.m_mailUnreadCount - 1;
			end
			v.mail_state = 4;

		end
	end
	self.m_ccbLabelMailCount:setString(string.format(Str[6001], self.m_mailCount, self.m_mailUnreadCount));
	self.mailListTableView:reloadData();
	self.m_presentTableView:reloadData();
end

-- 设置邮件各种label的显示文本。
function CCBMailView:setTextData(data)
	self:cleanTextData();
	-- print("CCBMailView:setTextData")
	self.m_ccbLabelTextTitle:setString(data.title)

	local nowTime = os.time();
	local pastHourTime = math.floor((nowTime - data.ms_time * 0.001) / 3600);
	local leftHourTime = 30 * 24 - pastHourTime;
	local leftDayTime = 0;
	if leftHourTime > 24 then
		leftDayTime = math.floor(leftHourTime / 24);
		self.m_ccbLabelTextData:setString(string.format(Str[6005], leftDayTime));
	else
		self.m_ccbLabelTextData:setString(string.format(Str[6006], leftHourTime));
	end

	if self.m_ccbScrollViewMailContent then		
		
		self.m_labelContent:setDimensions(cc.size(720,0));
		self.m_labelContent:setString("    " .. data.content)
 
		self.m_labelContent:setDimensions(cc.size(720, self.m_labelContent:getContentSize().height + 30))
		if data.mail_state == 1 then
			self.m_ccbScrollViewMailContent:setContentOffset(cc.p(0, 345 - self.m_labelContent:getContentSize().height));
		else
			self.m_ccbScrollViewMailContent:setContentOffset(cc.p(0, 220 - self.m_labelContent:getContentSize().height));
		end
	end
end

function CCBMailView:cleanTextData()
	self.m_ccbLabelTextTitle:setString("")
	self.m_ccbLabelTextData:setString("")
	if self.m_labelContent then 
		self.m_labelContent:setString("")
	end
end

function CCBMailView:createTextContentLabel()
	print("CCBMailView:createTextContentLabel")

	self.m_labelContent = cc.LabelTTF:create()
	self.m_labelContent:setFontSize(20)
	self.m_ccbScrollViewMailContent:setContainer(self.m_labelContent)
end

function CCBMailView:createPresentTableView()

	local sizeTable = self.m_ccbLayerAttachment:getContentSize();
	self.m_presentTableView = cc.TableView:create(sizeTable);
	-- 水平方向滚动
	self.m_presentTableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL);
	self.m_presentTableView:setDelegate();
	self.m_ccbLayerAttachment:addChild(self.m_presentTableView);

	self.m_presentTableView:registerScriptHandler(self.presentCellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX);
	self.m_presentTableView:registerScriptHandler(self.presentTableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX);
	self.m_presentTableView:registerScriptHandler(self.presentNumberOfCellInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);

	self.m_presentTableView:reloadData();

end

function CCBMailView.presentCellSizeForTable(table,idx)
	return 100, 100;
end

function CCBMailView.presentTableCellAtIndex(table,idx)

	local presentItem = nil;
	local cell = table:dequeueCell()
	if cell == nil then
		cell = cc.TableViewCell:new();
		-- presentItem = CCBReceiveItemCell:create();
		-- cell:addChild(presentItem);
		-- presentItem:setPosition(cc.p(0,2))
		-- presentItem:setTag(100)
		-- presentItem:setData(g_tableCurMailData.attachment[idx + 1])
		-- persentItem:setReceiveImgByState(g_tableCurMailData.mail_state);
		presentItem = ResourceMgr:createSmallItemIcon(g_tableCurMailData.attachment[idx + 1].item_id, g_tableCurMailData.attachment[idx + 1].count);
		if g_tableCurMailData.mail_state == 4 then
			local receiveShade = cc.Sprite:create(ResourceMgr:getMailReceiveShade());
			presentItem:addChild(receiveShade, 10, 10);
			local receiveLabel = cc.Sprite:create(ResourceMgr:getMailPresentReceiveLabelImg());
			presentItem:addChild(receiveLabel, 11, 11);
		end
		presentItem:setPosition(cc.p(50, 52));
		cell:addChild(presentItem);
	else
		-- presentItem = cell:getChildByTag(100)
		-- presentItem:setData(g_tableCurMailData.attachment[idx + 1]);
		-- persentItem:setReceiveImgByState(g_tableCurMailData.mail_state);
		cell:removeAllChildren();

		presentItem = ResourceMgr:createSmallItemIcon(g_tableCurMailData.attachment[idx + 1].item_id, g_tableCurMailData.attachment[idx + 1].count);
		
		if g_tableCurMailData.mail_state == 4 then
			local receiveShade = cc.Sprite:create(ResourceMgr:getMailReceiveShade());
			presentItem:addChild(receiveShade, 10, 10);
			local receiveLabel = cc.Sprite:create(ResourceMgr:getMailPresentReceiveLabelImg());
			presentItem:addChild(receiveLabel, 11, 11);
		end
		presentItem:setPosition(cc.p(50, 52));
		cell:addChild(presentItem);
	end

	return cell;
end

function CCBMailView.presentNumberOfCellInTableView(table)
	if g_tableCurMailData.attachment ~= nil then 
		return #g_tableCurMailData.attachment;
	else
		return 0;
	end
end

-- 邮件各类型邮件的小红点提示
-- 新邮件
function CCBMailView:setHintByNewMailData(data)
	-- dump(data);
	-- for i = 1, 5 do
	-- 	if data.type == g_tableMailType[i] then
	-- 		table.insert(g_tableMailTable[i], 1, data);
			-- dump(g_tableMailTable[i]);
			-- if g_BtnNumber == i then
			-- 	g_MailLoadList = g_tableMailTable[i];
			-- 	self.mailListTableView:reloadData();
			-- 	return ;
			-- end
	-- 		if not self.m_ccbCenterNode:getChildByTag(10 + i):isVisible() then
	-- 			self.m_ccbCenterNode:getChildByTag(10 + i):setVisible(true);
	-- 		end
	-- 	end
	-- end
	-- self:setHint(data);

	if #g_MailLoadList <= 0 then   -- 界面无邮件。
		self.m_ccbNodeMailMain:setVisible(true);
		self.m_ccbLabelNoneMail:setVisible(false);

		table.insert(g_MailLoadList, 1, data);
		self:requestToMarkMail(g_MailLoadList[1]);
		g_MailLoadList[1] = self:setFirstMailRead(g_MailLoadList[1]);

		self.m_mailCount = #g_MailLoadList;
		self.m_mailUnreadCount = 0;
		self.m_presentMailCount = 0;

		g_tableCurMailData = g_MailLoadList[1];
		self:operationForSelectMail(g_MailLoadList[1]);

		MailDataMgr:setCurTouchMailData(g_MailLoadList[1]);
		self:setTextData(g_MailLoadList[1]);

		self.m_presentTableView:reloadData();
		-- self:setData(data);
	else
		table.insert(g_MailLoadList, 1, data);
		self.m_mailCount = self.m_mailCount + 1;
		self.m_mailUnreadCount = self.m_mailUnreadCount + 1;

	end

	if #data.attachment > 0 then
		self.m_presentMailCount = self.m_presentMailCount + 1;
		if not self.m_ccbNodeReceiveAll:isVisible() then
			self.m_ccbNodeDeleteAll:setPosition(deleteBtnPos);
			self.m_ccbBtnReceiveAll:setEnabled(true);
			self.m_ccbNodeReceiveAll:setVisible(true);
		end
	end

	self.m_ccbLabelMailCount:setString(string.format(Str[6001], self.m_mailCount, self.m_mailUnreadCount));
	self.mailListTableView:reloadData();
end

-- 删除邮件
function CCBMailView:deleteMail()
	for i = #g_MailLoadList, 1, -1 do 
		if g_MailLoadList[i].mail_state == 1 or g_MailLoadList[i].mail_state == 4 then
			table.remove(g_MailLoadList, i);
		end
	end
	-- 删除完邮件之后，剩下的有可能是，未读的纯文本，未读的有附件， 已读的有附件
	if #g_MailLoadList <= 0 then
		self.m_ccbNodeMailMain:setVisible(false);
		self.m_ccbLabelNoneMail:setVisible(true);
		self.m_mailCount = 0;
		self.m_mailUnreadCount = 0;
		self.m_ccbLabelMailCount:setString(string.format(Str[6001], self.m_mailCount, self.m_mailUnreadCount));

	else

		if g_MailLoadList[1].mail_state == 0 then
			self:requestToMarkMail(g_MailLoadList[1]);
		
			if #g_MailLoadList[1].attachment > 0 then
				g_MailLoadList[1].mail_state = 3;
			else
				g_MailLoadList[1].mail_state = 1;
			end
		end
		self.m_mailCount = #g_MailLoadList;
		self.m_mailUnreadCount = 0;
		self.m_presentMailCount = 0;
		for k, v in pairs(g_MailLoadList) do
			if v.mail_state == 0 then
				self.m_mailUnreadCount = self.m_mailUnreadCount + 1; -- 计算未读邮件
				if #v.attachment ~= 0 then
					self.m_presentMailCount = self.m_presentMailCount + 1; -- 计算有附件邮件（未读）
				end
			elseif v.mail_state == 3 then
				self.m_presentMailCount = self.m_presentMailCount + 1; -- 计算有附件邮件（已读）
			end
		end

		self.m_ccbLabelMailCount:setString(string.format(Str[6001], self.m_mailCount, self.m_mailUnreadCount));

		if self.m_presentMailCount > 0 then
			-- self.m_ccbBtnDeleteAll:setVisible(true);
			self.m_ccbBtnReceiveAll:setEnabled(true);
			self.m_ccbNodeReceiveAll:setVisible(true);
			self.m_ccbNodeDeleteAll:setPosition(deleteBtnPos);
		else
			-- self.m_ccbBtnDeleteAll:setVisible(true);
			self.m_ccbBtnReceiveAll:setEnabled(false);
			self.m_ccbNodeReceiveAll:setVisible(false);
			self.m_ccbNodeDeleteAll:setPosition(receiveAllBtnPos);
		end

		g_tableCurMailData = g_MailLoadList[1];
		self:operationForSelectMail(g_MailLoadList[1]);

		MailDataMgr:setCurTouchMailData(g_MailLoadList[1]);
		self:setTextData(g_MailLoadList[1]);
		self.m_presentTableView:reloadData();
		self.mailListTableView:reloadData();
	end
	
end

function CCBMailView:setOneDeleteBtnHere()
	self.m_ccbNodeReceiveAll:setVisible(false);
	self.m_ccbBtnReceiveAll:setEnabled(false);
	self.m_ccbNodeDeleteAll:setPosition(receiveAllBtnPos);
end

-- 请求邮件列表
function CCBMailView:requestToLoadMailList()
	Network:request("mail.mailHandler.load_mail", nil, function(rc, receiveData)
		if receiveData["code"] ~= 1 then
			Tips:create(GameData:get("code_map", receiveData.code)["desc"])
			return;
		end
		if #receiveData.mail_list ~= 0 then
			self:setData(receiveData.mail_list);
		else
			self.m_ccbLabelMailCount:setString(string.format(Str[6001], 0, 0));
		end
	end)
end

function CCBMailView:requestToMarkMail(data)
	Network:request("mail.mailHandler.mark_read", {mail_id = data.id} , function(rc, receiveData)
		print("-------       发送邮件ID标记状态            --- ")
		if receiveData["code"] ~= 1 then 
			Tips:create(GameData:get("code_map", receiveData.code)["desc"])
			return;
		end
	end)
end

function CCBMailView:requestReceiveOneMail(mailID)
	Network:request("mail.mailHandler.recv_mail", {mail_id = mailID}, function(rc, receiveData)
		print("-------------------   接收邮件  ————————————————")
		if receiveData["code"] ~= 1 then 
			Tips:create(GameData:get("code_map", receiveData.code)["desc"])
			return;
		end
		Tips:create(Str[6004]);
		self:reloadMailListData();
	end)
end

function CCBMailView:requestReceiveAll()
	Network:request("mail.mailHandler.recv_mail", {is_all = true}, function(rc, receiveData)
		print("-------------------   接收全部邮件  ————————————————")
		if receiveData["code"] ~= 1 then 
			Tips:create(GameData:get("code_map", receiveData.code)["desc"]);
			return;
		end 
		dump(receiveData);
		if #receiveData.attachment_list ~= 0 then
			self:setAllPresentData();
		end
	end)
end

function CCBMailView:requestDeleteMail()
	Network:request("mail.mailHandler.delete_mail", {is_all = true}, function(rc, receiveData)
		print("----------------删除邮件-----------------");
		if receiveData["code"] ~= 1 then
			Tips:create(ServerCode[receiveData.code]);
			return;
		end
		self:deleteMail();
	end)
end

return CCBMailView