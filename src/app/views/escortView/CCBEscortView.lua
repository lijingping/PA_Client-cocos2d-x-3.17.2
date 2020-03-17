local Tips = require("app.views.common.Tips")
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");
local ResourceMgr = require("app.utils.ResourceMgr");
local CCBEscortResult = require("app.views.escortView.CCBEscortResult");
local CCBEscortLootLog = require("app.views.escortView.CCBEscortLootLog");
local CCBEscortLootBattle = require("app.views.escortView.CCBEscortLootBattle");
local CCBCommonGetPath = require("app.views.commonCCB.CCBCommonGetPath");

local CCBEscortView = class("CCBEscortView",function()
	return CCBLoader("ccbi/escortView/CCBEscortView")
end)

---   问题
--   打劫搜索页有待定。功能有待定。
--   一次护送结束后，新的信息传入。界面的显示设置。（放弃护送和护送完成）
--   打劫搜索，搜索到，结束


----  打劫搜索框完成。✅
--   处理临界值。护送日志。✅

local barBallPos = cc.p(-380, -18);
local scrollViewSize = cc.size(250, 240);

local normalWhite = cc.c3b(255, 255, 255);
local successGreen = cc.c3b(0, 255, 0);
local failRed = cc.c3b(255, 0, 0);


function CCBEscortView:ctor()
	if display.resolution  >= 2 then
		self:resolution();
	end
	self:enableNodeEvents();

	self.m_time = 0.1;
	self.m_curChoiceindex = 0; 	-- 当前锁定的护送等级1-D,2-C,3-B,4-A,5-S
	self.m_curRefurbishNum = 0;	-- 当前的刷新次数
	self.m_remainFreeRefurbishNum = 0; -- 当前的免费刷新次数
	self.m_curLootNum = 0;		-- 当前剩余的抢劫次数
	self.m_curEscortNum = 0;	-- 当前剩余的护送次数
	self.m_merchantShipData = nil;	-- 当前的护送船奖励数据

	self.m_lootConstData = table.clone(require("app.constants.loot_const"));
	self.m_escortEventLogData = table.clone(require("app.constants.loot_event_description"));
-- 	local str1 = "你好，嗯嗯。";
-- 	local str2 = "你好,嗯嗯。";
-- 	local str3 = "你好，嗯嗯。1";
-- 	local str4 = "你好，嗯嗯。a";
-- 	local str5 = "你好，嗯嗯。1a";
-- 	local str6 = "你好，嗯嗯。哈";
-- 	local str7 = "你好，嗯嗯。哈";
-- 	local str8 = "你";

-- 	print("1:", string.len(str1)); -- 1:	18
-- 	print("2:", string.len(str2)); -- 2:	16
-- 	print("3:", string.len(str3)); -- 3:	19
-- 	print("4:", string.len(str4)); -- 4:	19
-- 	print("5:", string.len(str5)); -- 5:	20
-- 	print("6:", string.len(str6)); -- 6:	21
-- 	print("7:", #str7); -- 7:	21
-- 	print("单个字长度：", string.len(str8)); -- 单个字长度：	3
-- -- 中文符号：3； 英文符号：1； 
	self.m_lootLogTable = {};

	self:init();			 -- 初始化页面
	self.m_isEscorting = false;  -- 护送状态
	self.m_isEscortRefresh = false;  -- 刷新状态
	self.m_escortLogTable = {};  -- 护送日志
	self.m_isShowEscortLog = false;
	self.m_nextActiveSecond = 0;

	-- self:refurbishArmature(); 
	
	if not Audio:isMusicPlaying() then
		local level = UserDataMgr:getPlayerLevel();
		local index = math.ceil(level / 20);
		Audio:playMusic(index, true);
	end

	local coinGotPosX = self.m_ccbSpriteEscortCoin:getPositionX();
	local coinGotPosY = self.m_ccbSpriteEscortCoin:getPositionY();
	local nodePos = self.m_ccbNodeShipUi:convertToWorldSpace(cc.p(coinGotPosX, coinGotPosY));
	self.m_escortCoinGotAnimPos = self.m_ccbNodeShipView:convertToNodeSpace(nodePos);
	
end

function CCBEscortView:onEnter()
	print("进入护送界面");
end

function CCBEscortView:onExit()
	if self.m_activeTimeSchduler then
		self:getScheduler():unscheduleScriptEntry(self.m_activeTimeSchduler);
		self.m_activeTimeSchduler = nil;
	end
	if self.m_escortScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_escortScheduler);
		self.m_escortScheduler = nil;
	end
	if self.m_onUpdateScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_onUpdateScheduler);
		self.m_onUpdateScheduler = nil;
	end
	if self.m_nextActiveScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_nextActiveScheduler);
		self.m_nextActiveScheduler = nil;
	end

end

--分辨率
function CCBEscortView:resolution()
	self:setScale(display.reduce)
end

--页面初始化
function CCBEscortView:init()
	self:setBtnEnable(false);
	-- self:createRequestingLabel();
	self:showUI();
	self:setScrollViewContainer();
	self:requestEscortData();
	self:requestLootLog();
end

function CCBEscortView:showUI()
	self:setEscortRewardData();
	
	self.m_barSpriteSize = self.m_ccbSpriteProgressBar:getContentSize();
	-- dump(self.m_barSpriteSize);
	self.m_ccbSpriteProgressBar:setTextureRect(cc.rect(0, 0, 0, 0));
	--没有escort_ship_title资源
	--local shipTitle = cc.Sprite:create(ResourceMgr:getEscortShipLabelByLevel(1));
	--self.m_ccbNodeShipLevel:addChild(shipTitle);

	self.m_lockShipSItem = self.m_lootConstData[tostring(15)].value;
	local icon1ID = ItemDataMgr:getItemIconIDByItemID(self.m_lockShipSItem);
	local lockSprite = cc.Sprite:create(ResourceMgr:getItemIconByID(icon1ID));
	lockSprite:setScale(0.3);
	self.m_ccbNodeLockShipSItem:addChild(lockSprite);

	self.m_refreshShipItem = self.m_lootConstData[tostring(16)].value;
	local icon2ID = ItemDataMgr:getItemIconIDByItemID(self.m_refreshShipItem);
	local refreshSprite = cc.Sprite:create(ResourceMgr:getItemIconByID(icon2ID));
	refreshSprite:setScale(0.3);
	self.m_ccbNodeRefreshItem:addChild(refreshSprite);

	local escortSprite = cc.Sprite:create(ResourceMgr:getEscortBtnEscortTitle());
	self.m_ccbNodeEscortBtn:addChild(escortSprite);
end

-- 进入界面网络请求
function CCBEscortView:createRequestingLabel()
	self.m_requestingLabel = cc.LabelTTF:create();
	self.m_requestingLabel:setFontSize(30);
	self.m_requestingLabel:setString(Str[10009]);
	self:addChild(self.m_requestingLabel);
	self.m_requestingLabel:setPosition(display.center);
end

-- 移除进入界面的网络请求
function CCBEscortView:removeRequestingLabel()
	-- Tips:create("------------------------网络返回消息");
	if self.m_requestingLabel then
		self.m_requestingLabel:removeSelf();
		self.m_requestingLabel = nil;
	end
end

function CCBEscortView:createLoadingUILabel()
	self.m_loadingUILabel = cc.LabelTTF:create();
	self.m_loadingUILabel:setFontSize(30);
	self.m_loadingUILabel:setString(Str[10010]);
	self:addChild(self.m_loadingUILabel);
	self.m_loadingUILabel:setPosition(display.center);
end

function CCBEscortView:removeLoadingUILabel(  )
	if self.m_loadingUILabel then
		self.m_loadingUILabel:removeSelf();
		self.m_loadingUILabel = nil;
	end
	self:setBtnEnable(true);
end

function CCBEscortView:setBtnEnable(isEnable)
	self.m_ccbBtnShowLootLog:setEnabled(isEnable);
	self.m_ccbBtnLoot:setEnabled(isEnable);
	self.m_ccbBtnEscortBtn_S:setEnabled(isEnable);
	self.m_ccbBtnRefresh:setEnabled(isEnable);
	self.m_ccbBtnEscortBtn:setEnabled(isEnable);
end

function CCBEscortView:setEscortRewardData()
	for i = 1, 5 do 
		local shipData = EscortDataMgr:getMerchantShipData(i);
		if shipData.items[1].item_id == 10001 then
			local iconSprite = cc.Sprite:create(ResourceMgr:getSmallGoldIcon());
			self.m_ccbCenterNode:getChildByTag(i):getChildByTag(1):addChild(iconSprite);
		else
			local iconID = ItemDataMgr:getItemIconIDByItemID(shipData.items[1].item_id);
			local iconSprite = cc.Sprite:create(ResourceMgr:getItemIconByID(iconID));
			iconSprite:setScale(0.3);
			self.m_ccbCenterNode:getChildByTag(i):getChildByTag(1):addChild(iconSprite);
		end
		self.m_ccbCenterNode:getChildByTag(i):getChildByTag(2):setString(shipData.items[1].count);
		local itemIconID = ItemDataMgr:getItemIconIDByItemID(shipData.items[2].item_id);
		local itemSprite = cc.Sprite:create(ResourceMgr:getItemIconByID(itemIconID));
		itemSprite:setScale(0.3);
		self.m_ccbCenterNode:getChildByTag(i):getChildByTag(3):addChild(itemSprite);
		self.m_ccbCenterNode:getChildByTag(i):getChildByTag(4):setString(ItemDataMgr:getItemNameByID(shipData.items[2].item_id) .. " X " .. shipData.items[2].count);
	end
end

function CCBEscortView:setScrollViewContainer()
	self.m_nodeLabelShow = cc.Node:create();
	self.m_ccbScrollView:setContainer(self.m_nodeLabelShow);
	-- self.m_scrollViewSize = self.m_ccbScrollView:getContentSize();
-- 	dump(self.m_scrollViewSize);
-- 	"<var>" = {
--     "height" = 0
--     "width"  = 0
-- }
	self.m_nodeAddLabel = cc.Node:create();
	self.m_nodeLabelShow:addChild(self.m_nodeAddLabel);
	self.m_nodeLabelShow:setContentSize(cc.size(scrollViewSize.width, 0));	
end

function CCBEscortView:setViewData(data)
	-- dump(data);
-- "<var>" = {
--     "activity_remain_second" = 12174
--     "award_list" = {
--     }
--     "code"                   = 1
--     "escort_log" = {
--     }
--     "escort_remain_second"   = 0
--     "escort_remain_times"    = 1
--     "event_award_count"      = 0
--     "loot_count"             = 0
--     "loot_remain_times"      = 5
--     "merchant_ship_level"    = 4
-- }
	self.m_activeTime = data.activity_remain_second;
	self.m_lootRemainTimes = data.loot_remain_times;
	self.m_lootGotCoinCount = data.loot_count;
	self.m_escortShipLevel = data.merchant_ship_level;
	self.m_escortRemainTimes = data.escort_remain_times; -- 次数
	self.m_escortRemainSec = data.escort_remain_second;
	self.m_escortLogTable = data.escort_log;
	self.m_escortOtherGainCoin = data.event_award_count;

	self:shopViewState();
	if data.activity_remain_second > 0 then
		local timeStr = self:computeTime(self.m_activeTime);
		self.m_ccbLabelActiveRemain:setString(Str[12009] .. timeStr);
		self.m_activeTimeSchduler = self:getScheduler():scheduleScriptFunc(function() self:countActiveTime(); end, 1, false);
	else
		self.m_ccbLabelActiveRemain:setString("         " .. Str[12008]);
	end
	self:selectItemFrame();

	-- 还有打劫收益
	self.m_ccbLabelLootCoinCount:setString(self.m_lootGotCoinCount);
	self.m_ccbLabelLootNum:setString(self.m_lootRemainTimes .. "/" .. self.m_lootConstData[tostring(2)].value);

	self:setEscortData();


	self:setEscortBtnSprite();
	self.m_ccbLabelEscortNum:setString(Str[12010] .. self.m_escortRemainTimes .. "/" .. self.m_lootConstData[tostring(3)].value);

	-- 判断是否有未领取的奖励
	if data.award_list == nil then
		print("   奖励为空   333333");
	end
	local awardTable = {};

	if data.event_award_count > 0 and self.m_escortRemainSec <= 0 then  -- 有奖励
		awardTable["award_list"] = data.award_list;
		awardTable["event_award_count"] = data.event_award_count;
		if #data.award_list <= 0 then
			local escortResult = CCBEscortResult:create(1, 2);
			escortResult:setViewData(awardTable);
		else
			local escortResult = CCBEscortResult:create(1, 1);
			escortResult:setViewData(awardTable);
		end
	end
	self:removeLoadingUILabel();
end

function CCBEscortView:setEscortData()
	local shipData = EscortDataMgr:getMerchantShipData(self.m_escortShipLevel);
	self.m_ccbNodeShipLevel:removeAllChildren();
	--没有escort_ship_title资源
	--local shipTitle = cc.Sprite:create(ResourceMgr:getEscortShipLabelByLevel(self.m_escortShipLevel));
	--self.m_ccbNodeShipLevel:addChild(shipTitle);
	self.m_ccbLabelEscortTime:setString(math.floor(shipData.time / 60) .. Str[10008]);
	self.m_ccbNodeRewardCoinIcon:removeAllChildren();
	self.m_ccbNodeRewardItemIcon:removeAllChildren();
	if shipData.items[1].item_id == 10001 then
		local iconSprite = cc.Sprite:create(ResourceMgr:getSmallGoldIcon());
		self.m_ccbNodeRewardCoinIcon:addChild(iconSprite);
	else
		local iconID = ItemDataMgr:getItemIconIDByItemID(shipData.items[1].item_id);
		local iconSprite = cc.Sprite:create(ResourceMgr:getItemIconByID(iconID));
		iconSprite:setScale(0.3);
		self.m_ccbNodeRewardCoinIcon:addChild(iconSprite);
	end
	self.m_ccbLabelRewardCoinCount:setString(shipData.items[1].count);
	local itemIconID = ItemDataMgr:getItemIconIDByItemID(shipData.items[2].item_id);
	local itemSprite = cc.Sprite:create(ResourceMgr:getItemIconByID(itemIconID));
	itemSprite:setScale(0.3);
	self.m_ccbNodeRewardItemIcon:addChild(itemSprite);
	self.m_ccbLabelRewardItemCount:setString(shipData.items[2].count);
end

function CCBEscortView:setEscortBtnSprite()
	self.m_ccbNodeEscortBtn:removeAllChildren();
	if self.m_isEscorting then
		local escortingSprite = cc.Sprite:create(ResourceMgr:getEscortBtnAbandonEscortTitle());
		self.m_ccbNodeEscortBtn:addChild(escortingSprite);
	else
		local escortSprite = cc.Sprite:create(ResourceMgr:getEscortBtnEscortTitle());
		self.m_ccbNodeEscortBtn:addChild(escortSprite);
	end
end

function CCBEscortView:selectItemFrame()
	for i = 1, 5 do 
		self.m_ccbCenterNode:getChildByTag(i):getChildByTag(5):removeAllChildren();
		if i == self.m_escortShipLevel then
			local levelFrame = cc.Sprite:create(ResourceMgr:getEscortItemSelectFrame());
			self.m_ccbCenterNode:getChildByTag(i):getChildByTag(5):addChild(levelFrame);
		end
	end
end

function CCBEscortView:shopViewState()
	if self.m_escortRemainSec > 0 then
		-- 护送中
		self.m_ccbCenterNode:setVisible(false);
		self.m_ccbNodeShipView:setVisible(true);
		self.m_isEscorting = true;

		self.m_ccbNodeEscortReward:setVisible(true);
		self.m_ccbLabelEscortTimeTitle:setVisible(false);
		self.m_ccbLabelEscortTime:setVisible(false);
		self.m_ccbNodeEscortBtns:setVisible(false);

		self:setShipEscortView();

		self.m_ccbLabelEscortNum:setVisible(false);
	else
		self.m_ccbCenterNode:setVisible(true);
		self.m_ccbNodeShipView:setVisible(false);
		self.m_isEscorting = false;

		self.m_ccbNodeEscortReward:setVisible(false);
		self.m_ccbLabelEscortTimeTitle:setVisible(true);
		self.m_ccbLabelEscortTime:setVisible(true);
		self.m_ccbNodeEscortBtns:setVisible(true);

		self.m_ccbLabelEscortNum:setVisible(true);
	end
end

function CCBEscortView:countActiveTime()
	self.m_activeTime = self.m_activeTime - 1;
	local timeStr = self:computeTime(self.m_activeTime);
	self.m_ccbLabelActiveRemain:setString(Str[12009] .. timeStr);
end

function CCBEscortView:computeTime(time)
	local hour = math.floor(time / 3600);
	local min = math.floor((time % 3600) / 60);
	local sec = time % 60;
	return string.format("%02d:%02d:%02d", hour, min, sec);
end

function CCBEscortView:requestEscortData()
	Network:request("loot_battle.lootHandler.query_interface_info", nil, function (rc, data)
		print("------------请求护送页面数据-----------------")
		-- dump(data)
     -- {
     --        code:number,
     --        next_start_need_second:number,  //距离下次活动开启所需秒数(当活动未开启code=974373344)
     --        activity_remain_second:number,  //活动剩余秒数
     --        merchant_ship_level:number, //护送贩售舰等级 1~5=DCBAS
     --        escort_remain_times:number, //剩余护送次数
     --        loot_remain_times: number,  //剩余打劫次数
     --        escort_remain_second: number,   //护送剩余秒数
     --        escort_log: 
     --        {
     --            time: string;   //xx:xx
     --            type: number;   //事件类型 1随机事件|2护送方遭遇打劫|3打劫日志
     --            second_type: number;    //描述的数组第几个,从1开始(如果type=2|3,则secondtype 1也代表胜利|2输)
     --            money: number;  //获取|失去星际币数量
     --            enemy_name: string | undefined;
     --            level: number | undefined;
     --            enemy_ship: number | undefined;
     --            enemy_fort1: number | undefined;
     --            enemy_fort2: number | undefined;
     --            enemy_fort3: number | undefined;
     --        }[];    //护送日志
     --        award_list: {item_id,count}[], //护送奖励(包括事件奖励)
     --        event_award_count:number, //事件奖励星际币数量
     --        loot_count: number  //打劫收益的数量
     --    }
--    
-- 说明:  
--     1. 当护送剩余秒数>0即有在护送
--     2. 当client收到award_list不为空时,进行展示奖励
--     3. 护送日志格式:  x时:y分|内容, 请按|分割字符串

		self:removeRequestingLabel();
		self:createLoadingUILabel();
		if data["code"] ~= 1 then
-- 			"<var>" = {
--     "code"                   = 974373344
--     "next_start_need_second" = 5956
-- }
	--  data.activity_remain_second;
	--  data.loot_remain_times;
	--  data.loot_count;
	--  data.merchant_ship_level;
	--  data.escort_remain_times; -- 次数
	--  data.escort_remain_second;
	--  data.escort_log;
	--  data.event_award_count;
			if data.code == 974373344 then
				local viewData = {};
				viewData.activity_remain_second = 0;
				viewData.loot_remain_times = self.m_lootConstData[tostring(2)].value;
				viewData.loot_count = 0;
				viewData.merchant_ship_level = math.random(1, 5);
				viewData.escort_remain_times = self.m_lootConstData[tostring(3)].value;
				viewData.escort_remain_second = 0;
				viewData.escort_log = {};
				viewData.event_award_count = 0;
				self:setViewData(viewData);
				self.m_nextActiveSecond = data.next_start_need_second;
				self:openNextActiveScheduler();
			else
				Tips:create(ServerCode[data.code]);
			end
			return;
		end
		self:setViewData(data);
	end)
end

function CCBEscortView:openNextActiveScheduler()
	self.m_nextActiveScheduler = self:getScheduler():scheduleScriptFunc(function() 
		self.m_nextActiveSecond = self.m_nextActiveSecond - 1;
		if self.m_nextActiveSecond < 0 then
			self:requestEscortData();
			self:getScheduler():unscheduleScriptEntry(self.m_nextActiveScheduler);
			self.m_nextActiveScheduler = nil;
		end
	end, 1, false);
end

function CCBEscortView:requestLootLog()
	Network:request("loot_battle.lootHandler.query_loot_log", nil, function(rc, data)
		if data.code ~= 1 then
			Tips:create(ServerCode[data.code]);
			return;
		end
		-- dump(data);
		self.m_lootLogTable = data.log;
	end)
end

function CCBEscortView:onBtnShowLootLog()
	print("显示打劫日志");
	if self.m_activeTime <= 0 then
		local nextActiveTimeStr = self:computeTime(self.m_nextActiveSecond);
		local ccbMessageBox = CCBMessageBox:create(Str[3057], Str[4057] .. nextActiveTimeStr, MB_OK);
		ccbMessageBox.onBtnOK = function ()
			ccbMessageBox:removeSelf();
		end
		return;
	end
	local ccbLootLogView = CCBEscortLootLog:create(self.m_lootLogTable);

	-- 打劫战斗测试
	-- local data = {
	-- count = 0,
	-- enemy_info = {nickname = "打劫我最棒", ship = 70003, ["fort1"] = 90003, ["fort2"] = 90006, ["fort3"] = 90009}
	-- }; -- 测试
	-- CCBEscortLootBattle:create(data);
end

-- 发起抢劫
function CCBEscortView:onBtnLoot()
	print("抢劫按钮")
	if self.m_activeTime <= 0 then
		local nextActiveTimeStr = self:computeTime(self.m_nextActiveSecond);
		local ccbMessageBox = CCBMessageBox:create(Str[3057], Str[4057] .. nextActiveTimeStr, MB_OK);
		ccbMessageBox.onBtnOK = function ()
			ccbMessageBox:removeSelf();
		end
		return;
	end
	self.m_ccbBtnLoot:setEnabled(false);
	if self.m_lootRemainTimes > 0 then
		
		Network:request("loot_battle.lootHandler.find_merchant_ship", nil, function(rc, data)
			dump(data);
			self.m_ccbBtnLoot:setEnabled(true);
			if data.code ~= 1 then
				Tips:create(ServerCode[data.code]);
				return;
			end
			-- 抢劫搜索动画
			print("  打劫请求发送成功  开始搜索 ");
			self:createLootSearchView();
		end)
	else
		Network:request("game.itemsHandler.query_buy_loot_need", nil, function(rc, data)
			self.m_ccbBtnLoot:setEnabled(true);
			if data.code ~= 1 then
				Tips:create(ServerCode[data.code]);
				return;
			end
			-- dump(data);
			local ccbMessageBox = CCBMessageBox:create(Str[3045], string.format(Str[4054], data.count, 1), MB_YESNO);
			ccbMessageBox.onBtnOK = function()
				Network:request("game.itemsHandler.buy_loot_times", nil, function(rc, data)
					ccbMessageBox:removeSelf();
					if data.code ~= 1 then 
						Tips:create(ServerCode[data.code]);
						return;
					end
					Tips:create(Str[10017]);
					self.m_lootRemainTimes = self.m_lootRemainTimes + 1;
					self.m_ccbLabelLootNum:setString(self.m_lootRemainTimes .. "/" .. self.m_lootConstData[tostring(2)].value);
				end)
			end
			ccbMessageBox.onBtnCancel = function()
				ccbMessageBox:removeSelf();
			end
		end)
	end
		
end

--护送开始
function CCBEscortView:onBtnStartEscort()
	print("护送按钮")
	if self.m_activeTime <= 0 then
		local nextActiveTimeStr = self:computeTime(self.m_nextActiveSecond);
		local ccbMessageBox = CCBMessageBox:create(Str[3057], Str[4057] .. nextActiveTimeStr, MB_OK);
		ccbMessageBox.onBtnOK = function ()
			ccbMessageBox:removeSelf();
		end
		return;
	end
	if self.m_isEscorting then
		local ccbMessageBox = CCBMessageBox:create(Str[3041], Str[4040], MB_YESNO);
		ccbMessageBox.onBtnOK = function()
			Network:request("loot_battle.lootHandler.abandon_merchant_ship", nil, function(rc, data)
				dump(data)
-- 		"<var>" = {
--     "code"              = 1
--     "event_award_count" = 240
--     "level"             = 1
-- }

				if data["code"] ~= 1 then
					Tips:create(ServerCode[data.code]);
					return;
				end	
				print("放弃护送任务");
				self.m_escortRemainSec = 0;
				self.m_escortShipLevel = data.level;
				self:escortFinish();
				self:selectItemFrame();
				self:setEscortData();
				local escortResult = CCBEscortResult:create(1, 2);
				escortResult:setViewData(data);
			end)
			ccbMessageBox:removeSelf();
		end
		ccbMessageBox.onBtnCancel = function()
			ccbMessageBox:removeSelf();
		end
	else
		if self.m_escortRemainTimes <= 0 then
			Tips:create(Str[12006]);
		elseif EscortDataMgr:getMerchantShipData(self.m_escortShipLevel).time > self.m_activeTime then
			local ccbMessageBox = CCBMessageBox:create(Str[3058], Str[4058], MB_YESNO);
			ccbMessageBox.onBtnOK = function()
				Network:request("loot_battle.lootHandler.escort_merchant_ship", nil, function(rc, data)
				if data.code ~= 1 then
					Tips:create(ServerCode[data.code]);
					return;
				end
				-- dump(data);
				self.m_escortOtherGainCoin = 0;
				self.m_escortRemainSec = data.remain_second;
				self:shopViewState();
				self:setEscortBtnSprite();
				self.m_escortRemainTimes = self.m_escortRemainTimes - 1;
				self.m_ccbLabelEscortNum:setString(Str[12010] .. self.m_escortRemainTimes .. "/" .. self.m_lootConstData[tostring(3)].value);
				end)
				ccbMessageBox:removeSelf();
			end
			ccbMessageBox.onBtnCancel = function()
				ccbMessageBox:removeSelf();
			end
		else
			Network:request("loot_battle.lootHandler.escort_merchant_ship", nil, function(rc, data)
				if data.code ~= 1 then
					Tips:create(ServerCode[data.code]);
					return;
				end
				-- dump(data);
				self.m_escortOtherGainCoin = 0;
				self.m_escortRemainSec = data.remain_second;
				self:shopViewState();
				self:setEscortBtnSprite();
				self.m_escortRemainTimes = self.m_escortRemainTimes - 1;
				self.m_ccbLabelEscortNum:setString(Str[12010] .. self.m_escortRemainTimes .. "/" .. self.m_lootConstData[tostring(3)].value);
			end)
		end
	end
end

function CCBEscortView:onBtnChooseSMerchantShip()
	print("锁定S级贩售舰")
	if self.m_activeTime <= 0 then
		local nextActiveTimeStr = self:computeTime(self.m_nextActiveSecond);
		local ccbMessageBox = CCBMessageBox:create(Str[3057], Str[4057] .. nextActiveTimeStr, MB_OK);
		ccbMessageBox.onBtnOK = function ()
			ccbMessageBox:removeSelf();
		end
		return;
	end
	if self.m_escortShipLevel >= 5 then
		Tips:create(Str[12007]);
		return;
	end
	if ItemDataMgr:getItemCount(self.m_lockShipSItem) > 0 then
		local ccbMessageBox = CCBMessageBox:create(Str[3055], Str[4055], MB_YESNO);
		ccbMessageBox.onBtnOK = function ()
			Network:request("game.itemsHandler.appoint_s_level", nil, function (rc, data)
				-- dump(data);
	-- 			"<var>" = {
	--     "code"  = 1
	--     "level" = 5
	-- }
				if data.code ~= 1 then
					Tips:create(ServerCode[data.code]);
					return;
				end
				self.m_escortShipLevel = data.level;
				self:selectItemFrame();

				local selectLight = ResourceMgr:getEscortSelectLight();
				self.m_ccbCenterNode:getChildByTag(self.m_escortShipLevel):getChildByTag(5):addChild(selectLight);
				selectLight:getAnimation():play("anim01");
				selectLight:getAnimation():setMovementEventCallFunc(function ( armatureBack, movementType, movementID )
					if movementType == ccs.MovementEventType.complete then
						selectLight:removeSelf();
						selectLight = nil;
					end
				end)
				
				self:setEscortData();
			end);
			ccbMessageBox:removeSelf();
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
		
	else
		local ccbMessageBox = CCBMessageBox:create(Str[3044], Str[4056], MB_YESNO);
		ccbMessageBox.onBtnOK = function()
			CCBCommonGetPath:create(4010);

			ccbMessageBox:removeSelf();
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
	end
end

-- 刷新护卫贩售船
function CCBEscortView:onBtnRefresh()
	print("刷新护卫贩售船")
	if self.m_activeTime <= 0 then
		local nextActiveTimeStr = self:computeTime(self.m_nextActiveSecond);
		local ccbMessageBox = CCBMessageBox:create(Str[3057], Str[4057] .. nextActiveTimeStr, MB_OK);
		ccbMessageBox.onBtnOK = function ()
			ccbMessageBox:removeSelf();
		end
		return;
	end
	local freshItemCount = ItemDataMgr:getItemCount(self.m_refreshShipItem);
	if freshItemCount > 0 then
		local ccbMessageBox = CCBMessageBox:create(Str[3043], Str[4043], MB_YESNO);
		ccbMessageBox.onBtnOK = function ()
			self:refreshShipRequest();
			ccbMessageBox:removeSelf();
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
	else
		local ccbMessageBox = CCBMessageBox:create(Str[3044], Str[4053], MB_YESNO);
		ccbMessageBox.onBtnOK = function ()
			App:enterScene("ShopScene");
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
	end

end

function CCBEscortView:refreshShipRequest()
	self.m_ccbBtnRefresh:setEnabled(false);
	self.m_isEscortRefresh = true;
	Network:request("game.itemsHandler.refresh_merchant_ship_level", nil, function (rc, data)
		-- dump(data)
		-- "<var>" = {
	    -- "code"  = 1
	    -- "level" = 4
		-- }
		if data["code"] ~= 1 then
			Tips:create(ServerCode[data.code]);
			self.m_ccbBtnRefresh:setEnabled(true);
			self.m_isEscortRefresh = false;
			return
		end
		self.m_escortShipLevel = data.level;
		self:refurbishArmature();
	end)
end

function CCBEscortView:refurbishArmature()
	print("CCBEscortView:refurbishArmature")
	self:startScheduler();
	--停止计时
	local function stopScheduler()
		self.m_ccbBtnRefresh:setEnabled(true);
		self.m_isEscortRefresh = false;
		self:getScheduler():unscheduleScriptEntry(self.m_onUpdateScheduler);
	end
	local function setData()
		self:selectItemFrame();
		self:setEscortData();

		local selectLight = ResourceMgr:getEscortSelectLight();
		self.m_ccbCenterNode:getChildByTag(self.m_escortShipLevel):getChildByTag(5):addChild(selectLight);
		selectLight:getAnimation():play("anim01");
		selectLight:getAnimation():setMovementEventCallFunc(function ( armatureBack, movementType, movementID )
			if movementType == ccs.MovementEventType.complete then
				selectLight:removeSelf();
				selectLight = nil;
			end
		end)
	end
	local delayTime = cc.Sequence:create(
		cc.DelayTime:create(1.5),
		cc.CallFunc:create(stopScheduler),
		cc.CallFunc:create(setData));
	self:runAction(delayTime)
end

--开始计时
function CCBEscortView:startScheduler()
	print("CCBEscortView:startScheduler")
	self.m_onUpdateScheduler = self:getScheduler():scheduleScriptFunc(function(dt) self:refurbishUpdate(dt) end, self.m_time, false);
end

function CCBEscortView:refurbishUpdate()
	-- self.m_time = self.m_time + 0.1;
	local index = math.random(1,5);
	index = math.random(1,5);
	-- print("CCBEscortView:refurbishUpdate",index)
	for i = 1,5 do
		self.m_ccbCenterNode:getChildByTag(i):getChildByTag(5):removeAllChildren();
 		if i == index then
			local levelFrame = cc.Sprite:create(ResourceMgr:getEscortItemSelectFrame());
			self.m_ccbCenterNode:getChildByTag(i):getChildByTag(5):addChild(levelFrame);
		end
	end
end

function CCBEscortView:setShipEscortView()
	-- 护送动画
	local sceneAnim = ResourceMgr:getEscortSceneArmature();
	self.m_ccbNodeForShipAnim:addChild(sceneAnim);
	sceneAnim:getAnimation():play("anim01");
	-- 护送舰动画
	local shipAnim = ResourceMgr:getEscortShipArmatureByLevel(self.m_escortShipLevel);
	self.m_ccbNodeForShipAnim:addChild(shipAnim);
	shipAnim:getAnimation():play("anim01");
	shipAnim:setPosition(cc.p(-250, -20));
	-- 额外星际币收益
	self.m_ccbLabelViewCoinCount:setString(self.m_escortOtherGainCoin);
	local escortTimeStr = self:computeTime(self.m_escortRemainSec);
	self.m_ccbLabelEscortRemainTime:setString(escortTimeStr);
	self:createProgressBall();
	self:openEscortSecondScheduler();
	-- self:createEscortLogTableView();
	self:createScrollViewNode();
	self.m_isShowEscortLog = true;
end

-- 创建进度条的球球和设置进度跳的宽度。
function CCBEscortView:createProgressBall()
	if self.m_ccbNodeShipUi:getChildByTag(1) then
		self.m_ballArmature = self.m_ccbNodeShipUi:getChildByTag(1);
	else
		self.m_ballArmature = ResourceMgr:getEscortProgressBallArmature();
		self.m_ballArmature:getAnimation():play("anim01");
		self.m_ccbNodeShipUi:addChild(self.m_ballArmature, 1, 1);
	end
	local shipData = EscortDataMgr:getMerchantShipData(self.m_escortShipLevel);
	local goneTime = shipData.time - self.m_escortRemainSec;
	local barPercent = goneTime / shipData.time;
	self.m_ballArmature:setPosition(cc.p(barBallPos.x + self.m_barSpriteSize.width * barPercent, barBallPos.y));
	local moveDisX = self.m_barSpriteSize.width * (1 - barPercent);
	local moveAction = cc.MoveBy:create(self.m_escortRemainSec, cc.p(moveDisX, 0));
	self.m_ballArmature:runAction(moveAction);
	local barPreWidth = self.m_barSpriteSize.width * barPercent;
	self.m_ccbSpriteProgressBar:setTextureRect(cc.rect(0, 0, barPreWidth, self.m_barSpriteSize.height));
end

-- 打开护送倒计时的定时器。
function CCBEscortView:openEscortSecondScheduler()
	self.m_escortScheduler = self:getScheduler():scheduleScriptFunc(function() self:updateEscortTime(); end, 1, false);
end

-- 护送倒计时响应函数。
function CCBEscortView:updateEscortTime()
	self.m_escortRemainSec = self.m_escortRemainSec - 1;
	local escortTimeStr = self:computeTime(self.m_escortRemainSec);
	self.m_ccbLabelEscortRemainTime:setString(escortTimeStr);
	local shipData = EscortDataMgr:getMerchantShipData(self.m_escortShipLevel);
	local goneTime = shipData.time - self.m_escortRemainSec;
	local barPercent = goneTime / shipData.time;
	local barPreWidth = self.m_barSpriteSize.width * barPercent;
	self.m_ccbSpriteProgressBar:setTextureRect(cc.rect(0, 0, barPreWidth, self.m_barSpriteSize.height));
	if self.m_escortRemainSec <= 0 then
		print("  关闭 护送定时器  。。  ");
		print("  护送剩余时间，关闭定时器后 ： ", self.m_escortRemainSec);
		self:getScheduler():unscheduleScriptEntry(self.m_escortScheduler);
		self.m_escortScheduler = nil;
	end
end

function CCBEscortView:createScrollViewNode()

	self.m_escortLogCountY = 0;

	for i = 1, #self.m_escortLogTable do
		local lineSprite = cc.Sprite:create(ResourceMgr:getEscortLogLine());
		self.m_nodeAddLabel:addChild(lineSprite);
		local lineSize = lineSprite:getContentSize();
		lineSprite:setPosition(scrollViewSize.width * 0.5, self.m_escortLogCountY + lineSize.height * 0.5);
		self.m_escortLogCountY = self.m_escortLogCountY + lineSize.height;
		-- scrollViewSize.width
		local escortLogStr = self:getEscortLogStr(self.m_escortLogTable[i]);
		local labelSize = self:getLabelSize(escortLogStr);
		local richTextWidth = scrollViewSize.width;
		local richTextHeight = math.ceil(labelSize.width / scrollViewSize.width) * labelSize.height;
		local richSize = cc.size(richTextWidth, richTextHeight);
		local richText = self:createRichTextEscortLog(self.m_escortLogTable[i], richSize);
		self.m_nodeAddLabel:addChild(richText);
		richText:setPosition(cc.p(scrollViewSize.width * 0.5, self.m_escortLogCountY));

		self.m_escortLogCountY = self.m_escortLogCountY + richSize.height + 5;

	end
	print("  self.m_escortLogCountY: : ", self.m_escortLogCountY);
	self.m_nodeLabelShow:setContentSize(cc.size(scrollViewSize.width, self.m_escortLogCountY));

	-- self.m_nodeAddLabel:setPosition(cc.p(0, 0));
	local offsetNum = scrollViewSize.height - self.m_escortLogCountY;
	self.m_ccbScrollView:setContentOffset(cc.p(0, offsetNum));
end

function CCBEscortView:receiveNotifyEscortLog(data)
	-- dump(data);
-- 	"<var>" = {
--     "count" = 289
--     "log"   = "飞来横财,捡到从前方飘来的保险箱,获得星际币289"
-- }
	if not self.m_isShowEscortLog then
		Tips:create(Str[12001]);
		return;
	end
	local coinAnim = ResourceMgr:getEscortCoinGotAnim();
	self.m_ccbNodeShipView:addChild(coinAnim);
	coinAnim:getAnimation():play("anim01");
	coinAnim:setPosition(self.m_escortCoinGotAnimPos);
	coinAnim:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			self.m_escortOtherGainCoin = self.m_escortOtherGainCoin + data.money;
			self.m_ccbLabelViewCoinCount:setString(self.m_escortOtherGainCoin);
			coinAnim:removeSelf();
			coinAnim = nil;
		end
	end);

	local lineSprite = cc.Sprite:create(ResourceMgr:getEscortLogLine());
	self.m_nodeAddLabel:addChild(lineSprite);
	local lineSize = lineSprite:getContentSize();
	lineSprite:setPosition(scrollViewSize.width * 0.5, self.m_escortLogCountY + lineSize.height * 0.5);
	self.m_escortLogCountY = self.m_escortLogCountY + lineSize.height;

	local escortLogStr = self:getEscortLogStr(data);
	local labelSize = self:getLabelSize(escortLogStr);
	local richTextWidth = scrollViewSize.width;
	local richTextHeight = math.ceil(labelSize.width / scrollViewSize.width) * labelSize.height;
	local richSize = cc.size(richTextWidth, richTextHeight);
	local richText = self:createRichTextEscortLog(data, richSize);
	self.m_nodeAddLabel:addChild(richText);
	richText:setPosition(cc.p(scrollViewSize.width * 0.5, self.m_escortLogCountY));

	self.m_escortLogCountY = self.m_escortLogCountY + richSize.height + 5;

	self.m_nodeLabelShow:setContentSize(cc.size(scrollViewSize.width, self.m_escortLogCountY));
	-- self.m_nodeAddLabel:setPosition(cc.p(0, -self.m_escortLogCountY));
	-- local offsetNum = scrollViewSize.height - self.m_escortLogCountY;
	-- if offsetNum > 0 then
	-- 	self.m_ccbScrollView:setContentOffset(cc.p(0, offsetNum));
	-- else
	local offset = self.m_ccbScrollView:getContentOffset();
	offset.y = offset.y - richSize.height - lineSize.height - 5;
	self.m_ccbScrollView:setContentOffset(offset);
	-- end
end

function CCBEscortView:getEscortLogStr(data)
	-- {
    --     time: string;   //xx:xx
    --     type: number;   //事件类型 1随机事件|2护送方遭遇打劫|3打劫日志
    --     second_type: number;    //描述的数组第几个,从1开始(如果type=2|3,则secondtype 1也代表胜利|2输)
    --     money: number;  //获取|失去星际币数量
    --     enemy_name: string | undefined;
    --     level: number | undefined;
    --     enemy_ship: number | undefined;
    --     enemy_fort1: number | undefined;
    --     enemy_fort2: number | undefined;
    --     enemy_fort3: number | undefined;
    -- }

    -- type 1:money.    2:time, enemy_name, lootResult(用second_type判), money  3:打劫日志（这里不需要）time, enemy_name, level, money || lootResult
		-- 测试
-- 	dump(self.m_escortEventLogData["2"].desc_list);
-- 	"<var>" = {
--     1 = "遭到|的打劫,|获得星际币"
--     2 = "遭到|的打劫,|失去星际币"
-- }
     -- "打劫了|护送的|贩售舰,战斗胜利获得星际币",
     --  "打劫了|护送的|贩售舰,|空手而回."

	local descLog = self.m_escortEventLogData[tostring(data.type)].desc_list[data.second_type];
	local descLogTable = string.split(descLog, "|");
	local str = "";
	if data.type == 1 then
		str = descLog .. " +" .. data.money;
	elseif data.type == 2 then
		str = data.time .. "  " .. descLogTable[1] .. " " .. data.enemy_name .. descLogTable[2];
		if data.second_type == 1 then
			str = str .. " " .. Str[12019] .. " +";
		elseif data.second_type == 2 then
			str = str .. " " .. Str[12020] .. " -";
		end
		str = str .. data.money;
	elseif data.type == 3 then
		print("   这里是护送日志，没有打劫日志。 ")
	end
	return str;
end

function CCBEscortView:getLabelSize(str)
	local logLabel = cc.LabelTTF:create();
	logLabel:setFontSize(16);
	logLabel:setDimensions(cc.size(0, 0));
	logLabel:setString(str);
	-- logLabel:setAnchorPoint(cc.p(0.5, 0));
	-- logLabel:setPosition(cc.p(scrollViewSize.width * 0.5, self.m_escortLogCountY));
	-- self.m_nodeAddLabel:addChild(logLabel);
	local labelSize = logLabel:getContentSize();
	return labelSize;
end

function CCBEscortView:createRichTextEscortLog(data, size)
	local richText = ccui.RichText:create();
	richText:ignoreContentAdaptWithSize(false);
	richText:setSize(size);
	richText:setAnchorPoint(cc.p(0.5, 0));

	local descLog = self.m_escortEventLogData[tostring(data.type)].desc_list[data.second_type];
	local descLogTable = string.split(descLog, "|");
	if data.type == 1 then
		local descText = ccui.RichElementText:create(1, normalWhite, 255, descLog, "", 16);
		richText:pushBackElement(descText);
		local moneyStr = " +" .. data.money;
		local moneyText = ccui.RichElementText:create(2, successGreen, 255, moneyStr, "", 16);
		richText:pushBackElement(moneyText);

	elseif data.type == 2 then
		local str = data.time .. "  " .. descLogTable[1] .. " " .. data.enemy_name .. descLogTable[2];
		local eventText = ccui.RichElementText:create(1, normalWhite, 255, str, "", 16);
		richText:pushBackElement(eventText);
		if data.second_type == 1 then
			local battleResultText = ccui.RichElementText:create(2, successGreen, 255, Str[12019], "", 16);
			richText:pushBackElement(battleResultText);
			local gainTipText = ccui.RichElementText:create(3, normalWhite, 255, descLogTable[3], "", 16);
			richText:pushBackElement(gainTipText);
			local moneyStr = " +" .. data.money;
			local moneyText = ccui.RichElementText:create(4, successGreen, 255, moneyStr, "", 16);
			richText:pushBackElement(moneyText);
		elseif data.second_type == 2 then
			local battleResultText = ccui.RichElementText:create(2, failRed, 255, Str[12020], "", 16);
			richText:pushBackElement(battleResultText);
			local loseTipText = ccui.RichElementText:create(3, normalWhite, 255, descLogTable[3], "", 16);
			richText:pushBackElement(loseTipText);
			local moneyStr = " -" .. data.money;
			local moneyText = ccui.RichElementText:create(4, failRed, 255, moneyStr, "", 16);
			richText:pushBackElement(moneyText);
		end
	elseif data.type == 3 then
		print("   这里是护送日志，没有打劫日志。 ")
	end

	return richText;
end

-- function CCBEscortView:createEscortLogTableView()
-- 	self.m_logNodeSize = self.m_ccbNodeEscortLog:getContentSize();
-- 	self.m_escortLogTableView = cc.TableView:create(self.m_logNodeSize);
-- 	self.m_escortLogTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
-- 	self.m_escortLogTableView:setDelegate();
-- 	self.m_escortLogTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
-- 	self.m_ccbNodeEscortLog:addChild(self.m_escortLogTableView);
-- 	print(" 创建 tableview    ")
-- 	dump(self.m_escortLogTableView);
-- 	self.m_escortLogTableView:registerScriptHandler(function(table, cell) self:tableCellTouched(table, cell); end, cc.TABLECELL_TOUCHED);
-- 	self.m_escortLogTableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx); end, cc.TABLECELL_SIZE_FOR_INDEX);
-- 	self.m_escortLogTableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx); end, cc.TABLECELL_SIZE_AT_INDEX);
-- 	self.m_escortLogTableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table); end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);
-- 	self.m_escortLogTableView:reloadData();

-- end

-- function CCBEscortView:tableCellTouched(table, cell)

-- end

-- function CCBEscortView:cellSizeForTable(table, idx)
-- 	print(idx , "       !!@@~~ cell  idx  。")
-- 	-- dump(table);
-- 	local cellHeight = 60;
-- 	local cell = table:dequeueCell();
-- 	dump(cell);
-- 	if cell ~= nil then
-- 		local logNode = cell:getChildByTag(1);
-- 		cellHeight = 100;
-- 	end
-- 	-- local logNode = cell:getChildByTag(1);
-- 	-- local logNodeSize = logNode:getContentSize();
-- 	-- dump(logNodeSize);
-- 	return self.m_logNodeSize.width, cellHeight;
-- end

-- function CCBEscortView:tableCellAtIndex(table, idx)
-- 	local cell = table:dequeueCell();
-- 	if cell == nil then
-- 		cell = cc.TableViewCell:new();
-- 		local escortLogNode = self:createEscortLogNode(self.m_escortLogTable[idx + 1]);
-- 		cell:addChild(escortLogNode);
-- 		escortLogNode:setTag(1);
-- 		escortLogNode:setPosition(cc.p(0, 0));
-- 	else
-- 		cell:removeAllChildren();
-- 		local escortLogNode = self:createEscortLogNode(self.m_escortLogTable[idx + 1]);
-- 		cell:addChild(escortLogNode);
-- 		escortLogNode:setTag(1);
-- 		escortLogNode:setPosition(cc.p(0,0));
-- 	end
-- 	return cell;
-- end

-- function CCBEscortView:numberOfCellsInTableView(table)
-- 	return #self.m_escortLogTable;
-- end

-- function CCBEscortView:createEscortLogNode(logStr)
-- 	local node = cc.Node:create();
-- 	local lineSprite = cc.Sprite:create(ResourceMgr:getEscortLogLine());
-- 	node:addChild(lineSprite);
-- 	local lineSize = lineSprite:getContentSize();
-- 	lineSprite:setPosition(self.m_logNodeSize.width * 0.5, lineSize.height * 0.5);
-- 	local logLabel = cc.LabelTTF:create();
-- 	logLabel:setFontSize(16);
-- 	logLabel:setDimensions(cc.size(self.m_logNodeSize.width, 0));
-- 	logLabel:setString(logStr);
-- 	logLabel:setAnchorPoint(cc.p(0, 0));
-- 	logLabel:setPosition(cc.p(0, lineSize.height));
-- 	node:addChild(logLabel);
-- 	local labelSize = logLabel:getContentSize();
-- 	node:setContentSize(cc.size(self.m_logNodeSize.width, lineSize.height + labelSize.height));
-- 	return node;
-- end

function CCBEscortView:escortFinish()
	self:shopViewState();
	self:setEscortBtnSprite();
	self.m_ccbNodeForShipAnim:removeAllChildren();
	if self.m_ccbNodeShipUi:getChildByTag(1) then
		self.m_ccbNodeShipUi:removeChildByTag(1);
	end
	self.m_nodeAddLabel:removeAllChildren();
	self.m_escortLogCountY = 0;
	self.m_escortOtherGainCoin = 0;
	self.m_escortLogTable = {};
end

function CCBEscortView:receiveNotifyLootLog(data)
	print("    打劫  单条 日志。   ");
	-- return:`{log:string,count:number,enemy_info}`  
-- 说明:  
	-- {
    --     time: string;   //xx:xx
    --     type: number;   //事件类型 1随机事件|2护送方遭遇打劫|3打劫日志
    --     second_type: number;    //描述的数组第几个,从1开始(如果type=2|3,则secondtype 1也代表胜利|2输)
    --     money: number;  //获取|失去星际币数量
    --     enemy_name: string | undefined;
    --     level: number | undefined;
    --     enemy_ship: number | undefined;
    --     enemy_fort1: number | undefined;
    --     enemy_fort2: number | undefined;
    --     enemy_fort3: number | undefined;
    -- }
	self:lootFindShip();
	CCBEscortLootBattle:create(data);
	self.m_lootGotCoinCount = self.m_lootGotCoinCount + data.money;
	self.m_lootRemainTimes = self.m_lootRemainTimes - 1;
	self.m_ccbLabelLootCoinCount:setString(self.m_lootGotCoinCount);
	self.m_ccbLabelLootNum:setString(self.m_lootRemainTimes .. "/" .. self.m_lootConstData[tostring(2)].value);
	table.insert(self.m_lootLogTable, data);
end

--  打劫搜索框
function CCBEscortView:createLootSearchView()
	
	self.m_searchViewNode = cc.Node:create();

	App:getRunningScene():addChild(self.m_searchViewNode);

	local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 180), display.width, display.height);
	self.m_searchViewNode:addChild(colorLayer);
	colorLayer:setAnchorPoint(cc.p(0.5, 0.5));
	colorLayer:setPosition(display.center);
	colorLayer:ignoreAnchorPointForPosition(false);

	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return true; end, cc.Handler.EVENT_TOUCH_BEGAN);
	local dispatcher = self.m_searchViewNode:getEventDispatcher();
	dispatcher:addEventListenerWithSceneGraphPriority(listener, colorLayer);

	local searchArmature = ResourceMgr:getEscortLootSearchArmature();
	self.m_searchViewNode:addChild(searchArmature);
	searchArmature:setPosition(display.center);
	searchArmature:getAnimation():play("anim01");

	local exitBtn = ccui.Button:create(ResourceMgr:getEscortLootSearchExitBtn(1), 
									ResourceMgr:getEscortLootSearchExitBtn(2),
									ResourceMgr:getEscortLootSearchExitBtn(2));
	exitBtn:setPosition(cc.p(display.cx, display.cy - 250));
	self.m_searchViewNode:addChild(exitBtn);
	exitBtn:addClickEventListener(function()
		self.m_searchViewNode:removeSelf();
		self.m_searchViewNode = nil;
		Network:request("loot_battle.lootHandler.cancel_find_merchant_ship", nil, function(rc, data)
			-- dump(data);
			if data.code ~= 1 then
				Tips:create(ServerCode[data.code]);
				return;
			end
		end)
	end)
end

function CCBEscortView:lootFindShip()
	if self.m_searchViewNode then
		self.m_searchViewNode:removeSelf();
		self.m_searchViewNode = nil;
	end
end

-- 护送结束的notify接收
function CCBEscortView:notifyEscortOverResponse(data)
	-- dump(data);
-- 	"<var>" = {
--     "is_success" = true
--     "level"      = 3
-- }
	print("  护送剩余时间———notify 护送结束响应 ———", self.m_escortRemainSec);
	-- local preShipData = EscortDataMgr:getMerchantShipData(self.m_escortShipLevel);
	self.m_escortShipLevel = data.level;
	-- 关闭定时器，护送时间置0.（护送结束的响应）.(客户端有卡顿延迟等，时间一般比服务器跑得慢，
	--所以，这边的护送时间没跑完，服务器就会附送结束通知。以服务器为准，发过来就算是护送时间为零了，防止2次打开定时器)
	if self.m_escortScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_escortScheduler);
		self.m_escortScheduler = nil;
	end
	self.m_escortRemainSec = 0;

	self:escortFinish();
	self:selectItemFrame();
	self:setEscortData();
	Network:request("loot_battle.lootHandler.receive_escort_award", nil, function(rc, receiveData)
		-- dump(receiveData);
-- 		"<var>" = {
--     "award_list" = {
--         1 = {
--             "count"   = 60404
--             "item_id" = 10001
--         }
--         2 = {
--             "count"   = 15
--             "item_id" = 4001
--         }
--     }
--     "code"              = 1
--     "event_award_count" = 714
-- }
		if receiveData.code ~= 1 then
			Tips:create(ServerCode[receiveData.code]);
			return;
		end
		if data.is_success then
			local escortResult = CCBEscortResult:create(1, 1);
			escortResult:setViewData(receiveData);
		else
			local escortResult = CCBEscortResult:create(1, 2);
			escortResult:setViewData(receiveData);
		end
	end)
	
end

return CCBEscortView
