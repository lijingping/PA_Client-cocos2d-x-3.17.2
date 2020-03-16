local Tips = require("app.views.common.Tips");
local LoadingLayer = require("app.views.common.LoadingLayer");
local MessageHint = require("app.views.common.MessageHint");

---------------------
-- Scene(场景)基类
---------------------
local GameSceneBase = class("GameSceneBase", cc.load("mvc").SceneBase)

function GameSceneBase:onCreate()
	if self.init and type(self.init) == "function" then
		self:init()
	end
	self.m_revengeList = {};
	self.m_revengeIndex = 0;
end

function GameSceneBase:baseUpdate(delta)
end


-- 游戏内log信息，仅用于调试
function GameSceneBase:info(str)
	if self._rootView and self._rootView.console then
		self._rootView.console:info(str)
	end
end

-- 消息弹框
function GameSceneBase:tips(str)
	if self._rootView and self._rootView.tipsLayer then
		self._rootView.tipsLayer:tips(str)
	end
end

-- 显示Loading动画
function GameSceneBase:showLoading()

	if self.m_loading == nil then
		self.m_loading = LoadingLayer:create();
	end
end

-- 隐藏Loading动画
function GameSceneBase:hideLoading()
	-- if self._rootView and self._rootView.loadingLayer then
	-- 	self._rootView.loadingLayer:setVisible(false)
	-- end
	if self.m_loading then
		self.m_loading:removeSelf();
		self.m_loading = nil;
	end
end

-- 请求进入战斗，进入搜索敌方战舰的状态
function GameSceneBase:requestWaitForBattle()
	Network:request("battle.matchHandler.wait_for_battle", nil, function (rc, searchData)
		-- dump(searchData)

		if searchData.code ~= 1 then
			Tips:create(ServerCode[searchData.code]);
			return
		end

	end)
end

-- 请取消搜索敌方战舰
-- function GameSceneBase:requestCancelSearch()
-- 	Network:request("battle.matchHandler.cancel_wait", nil, function (rc, cancelData)
-- 		-- dump(cancelData)

-- 		if cancelData.code ~= 1 or cancelData.cancel ~= true then
-- 			-- self:tips(GameData:get("code_map", cancelData.code)["desc"])
-- 			return
-- 		end
-- 		self:getViewBase():removeSearchView();
-- 	end)
-- end


--===========================================--
-------notify为服务器主动发送的给客户端的消息-------
--===========================================--

-- 通知移除搜索界面
function GameSceneBase:notifyBattleEndWait()
	print(" close the ---- Explore ---- search window ");
	Tips:create("is search time out!");
	if self:getViewBase().m_ccbSearchView then
		self:getViewBase().m_ccbSearchView:removeSelf();
		self:getViewBase().m_ccbSearchView = nil;
	end
end

-- 更新资源库数据
function GameSceneBase:notifyUpdateItems(data)
	print("------------GameSceneBase:notifyUpdateItems：更新玩家物品数据---------")
	-- dump(data)
-- "<var>" = {
--      "items" = {
--          1 = {
--              "count"   = 99
--              "delta"   = -1
--              "item_id" = 1004
--          }
--      }
--  }
	for i = 1, #data.items do
		local itemdata = {
			item_id = data.items[i].item_id,
			item_count = data.items[i].count,
		}
		ItemDataMgr:changeItemInfos(itemdata);
		-- 更新背包升级道具界面道具数量信息
		if App:getRunningSceneName() == "PackageScene" then
			if self:getChildByTag(200) ~= nil then
				if self:getChildByTag(200):getItemID() == data.items[i].item_id then
					self:getChildByTag(200):updateItemLabelCount(data.items[i].count);
				end
			end
		end
	end

	if App:getRunningSceneName() == "PackageScene" then
		self:getViewBase().m_ccbPackageView:updateViewOfDataUpdate(data.items);
	elseif App:getRunningSceneName() == "LotteryScene" then
		self:getViewBase():updateHeadInfo();
	end

	--获得物品提示界面
	if App:getRunningSceneName() ~= "BattleScene"
	and App:getRunningSceneName() ~= "EscortScene" then
		local itemTips = require("app.views.common.ItemTips");
		itemTips:create(data.items, showTipDelayTime);
	end
end

-- 同步货币数据
function GameSceneBase:notifyMoneyUpdate(data)
	print("------------GameSceneBase:notifyMoneyUpdate：更新玩家货币数据---------")
	-- dump(data)

	if data.code ~= 1 then
		Tips:create(ServerCode[data.code]);
		return;
	end

	UserDataMgr:setPlayerGoldCoin(data.universal_coin);
	UserDataMgr:setPlayerDiamond(data.diamond);
	UserDataMgr:setPlayerUnionCoin(data.alliance_coin);
	UserDataMgr:setFriendshipPoint(data.friendship_coin);
	UserDataMgr:setPlayerDecomposeCoin(data.decompose_coin);

	if App:getRunningSceneName() == "MainScene" then
		self:getViewBase().m_ccbMainView:updateMoney();
	else
		print(" 更新货币  信息  ", App:getRunningSceneName());
		if App:getRunningSceneName() ~= "BattleScene" then
			self:getViewBase():updateHeadInfo();
		else
			print("  ............  ")
			-- self:getViewBase():updateHeadInfo();
		end
		-- if App:getRunningSceneName() == "FriendScene" then
		-- 	self:getViewBase():updateHeadInfo();
		-- end
		-- if App:getRunningSceneName() == "PackageScene" then
		-- 	self:getViewBase():updateHeadInfo();
		-- end
	end
end

--玩家战斗力变化
function GameSceneBase:notifyPlayerPowerChange(data)
	UserDataMgr:setPlayerPower(data.power)
end

--护送等级S的贩售舰全服通知
function GameSceneBase:notifyLvSEscort(data)
	print("护送S级贩售舰")
end

-- 更新玩家信息
function GameSceneBase:notifyInfoChange(data)
	print("----------玩家信息更新--------------")
	-- dump(data);
	UserDataMgr:setPlayerExp(data.exp);
	UserDataMgr:setPlayerFamousId(data.famous_id);
	UserDataMgr:setPlayerFamous(data.famous_num);
	UserDataMgr:setPlayerLevel(data.level);
	UserDataMgr:setPlayerLvExp(data.max_exp);
	UserDataMgr:setPlayerPower(data.power);

	UserDataMgr:setPlayerRankInfo(data.famous_num);

	if App:getRunningSceneName() == "MainScene" then
		self:getViewBase().m_ccbMainView:updateView();
	end
end

--有玩家进行复仇
function GameSceneBase:notifyRevengeRequest(data)
	-- print("##########GameSceneBase:notifyRevengeRequest");
	--dump(data);
	--  "<var>" = {
 --     "code"       = 1
 --     "famous_num" = 203
 --     "nickname" = "**************"
 --     "from"       = "cfcde2685a7fdccce9158593389b3fb6"
 --     "icon"       = "default"
 --     "level"      = 89
 --     "power"      = 498212
 --     "timeout"    = 5
 -- }
	if data.code ~= 1 then
		Tips:create(GameData:get("code_map", data.code)["desc"]);
		return;
	end
	-- print("*****"..data.from);
	-- print("*****"..cc.UserDefault:getInstance():getStringForKey("uid"));
	if data.from == cc.UserDefault:getInstance():getStringForKey("uid") then
		return;
	end
	for k, v in pairs(self.m_revengeList) do
		local moveBy = cc.MoveBy:create(0.5, cc.p(0, -100));
		v:runAction(moveBy);
	end

	self.m_revengeIndex = self.m_revengeIndex + 1;
	local message = MessageHint:create(cc.p(1000, 570), "Lv."..data.level.." "..data.nickname, self.m_revengeIndex);
	table.insert(self.m_revengeList, message);

	local acceptFunc = function ()
		Network:request("battle.matchHandler.revenge_resp", {enemy = data.from, accept = true}, function (rc, reveiveData)
			if reveiveData.code ~= 1 or reveiveData.cancel ~= true then
				Tips:create(ServerCode[reveiveData.code]);
				return
			end	
		end)
	end
	local rejectFunc = function()
		Network:request("battle.matchHandler.revenge_resp", {enemy = data.from, accept = false}, function (rc, reveiveData)
			if reveiveData.code ~= 1 or reveiveData.cancel ~= true then
				Tips:create(ServerCode[reveiveData.code]);
				return
			end
		end)
	end
	-- 删除表中移除了的元素
	local removeMember = function(index)
		for k, v in pairs(self.m_revengeList) do
			if v.m_index == index then
				table.remove(self.m_revengeList, k);
				-- v:removeSelf();
				break;
			end
		end
	end
	-- 移动下面的请求向上
	local moveUpMember = function(index)
		for k, v in pairs(self.m_revengeList) do 
			if v.m_index < index then
				local moveBy = cc.MoveBy:create(0.5, cc.p(0, 100));
				v:runAction(moveBy);
			end
		end
	end
	message:onBtnEnsure(acceptFunc);
	message:onBtnCancel(rejectFunc);
	message:removeSelfFromListByIndex(removeMember);
	message:moveUpPreMember(moveUpMember);
	-- self:getViewBase():showRevengeRequestPopup(data);
end

-- 移除复仇提示列表的元素
function GameSceneBase:removeRevengeListMember(index)
	for k, v in pairs(self.m_revengeList) do
		if v.m_index == index then
			table.remove(self.m_revengeList, k);
		end
	end
end

--玩家请求复仇得到的反馈
function GameSceneBase:notifyIsAcceptRevenge(data)
	print("##########GameSceneBase:notifyIsAcceptRevenge");
	--self:getViewBase():closeWaitingRevengeView();
	dump(data);
	if data.code ~= 1 then
		Tips:create(GameData:get("code_map", data.code)["desc"]);
		return;
	end
	if data.accept == false then
		Tips:create("对方拒绝了你的复仇，1小时后可以再次发起复仇");
	else
		print("============进入复仇战=============");
	end
end

--战斗入口修改
function GameSceneBase:notifyBattleInfo(data)
	print("进入战斗")
	BattleDataMgr:Init(data);
	self.m_battleScene = App:enterScene("BattleScene");

	RevengeDataMgr:setStateIsInRequest(data.config.uid_1, false);
end

-- 好友申请小红点提示 ---------------
-- function GameSceneBase:notifyFriendReq(data)
-- 	-- 根据Scene的名字，判断当前页面
-- 	if App:getRunningSceneName() == "FriendScene" then
--     	App:getRunningScene():requestRequestList(data);
-- 	end
-- end

-- 好友馈赠小红点提示 ---------------
-- function GameSceneBase:notifyGift_recv(data)
-- 	if App:getRunningSceneName() == "FriendScene" then 
-- 		App:getRunningScene():requestGiftList(data);
-- 	end
-- end

-- 好友界面，好友消息提示响应的函数（私聊按钮小红点提示）
-- function GameSceneBase:notifyChatNews(data)
-- 	if App:getRunningSceneName() == "FriendScene" then
-- 		self:getViewBase():getFriendMassage(data);
-- 	end
-- end

-- 邮件页面的各个类型的小红点
function GameSceneBase:notifyNewMailHint(data)
	if App:getRunningSceneName() == "MailScene" then 
		self:getViewBase().m_ccbMailView:setHintByNewMailData(data);
	end
end

function GameSceneBase:notifyWorldNews(data)
	ChatDataMgr:insertMsgList(CHANNEL_WORLD, data);
	local CCBChatView = App:getRunningScene():getChildByName("CCBChatView");
	if CCBChatView then
		CCBChatView:reloadViewData();
	end
end

function GameSceneBase:notifyAllianceNews(data)
	ChatDataMgr:insertMsgList(CHANNEL_ALLIANCE, data);
	local CCBChatView = App:getRunningScene():getChildByName("CCBChatView");
	if CCBChatView then
		CCBChatView:reloadViewData();
	end
end

return GameSceneBase