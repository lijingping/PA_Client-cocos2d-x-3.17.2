local Crypto = require("app.utils.Crypto")
local NetworkConst = require("app.constants.NetworkConst")
local Code = require("app.constants.code")
local Tips = require("app.views.common.Tips");

require "packages.network.NetCommandDef"
--------------------
-- 登录场景
--------------------
local LoginScene = class("LoginScene", require("app.scenes.GameSceneBase"))

local GATE_HOST = Network.GATE_HOST
local GATE_PORT = Network.GATE_PORT

local DELETE_LOCAL_DATA = "delete"
local LOGIN_WITH_SESSION = "session"
local USE_TEST_GATE = "testgate"
local USE_DEV_GATE = "devgate"
local CHECK_BATTLE = true

function LoginScene:init()

	self.userDefault = cc.UserDefault:getInstance()

	self:initView("loginView.LoginView")
	self:connect()

end

-- 删除本地保存的帐号密码和session／uid
function LoginScene:deleteLocalData()
	print("deleteLocalData")
	self.userDefault:deleteValueForKey("uaccount")
	self.userDefault:deleteValueForKey("upassword")
	self.userDefault:deleteValueForKey("usession")
	self.userDefault:deleteValueForKey("uid")
end

-- 获取本地保存的帐号密码
function LoginScene:getLocalAccountPassword()
 	local uaccount = self.userDefault:getStringForKey("uaccount")
	local upassword = self.userDefault:getStringForKey("upassword")

	if uaccount ~= nil and upassword ~= nil and uaccount ~= "" and upassword ~= "" then
		return Crypto:decrypt(uaccount), Crypto:decrypt(upassword)			   
	end

	return nil, nil
end

-- 获取本地保存的session／uid
function LoginScene:getLocalSession()
 	local usession = self.userDefault:getStringForKey("usession")
	local uid = self.userDefault:getStringForKey("uid")

	return usession, uid
end

-- 保存帐号密码到本地
function LoginScene:saveAccountPassword(account, password)
 	local uaccount = Crypto:encrypt(account)
	local upassword = Crypto:encrypt(password)
	self.userDefault:setStringForKey("uaccount", uaccount)
	self.userDefault:setStringForKey("upassword", upassword)
end

-- 连接服务器
function LoginScene:connect()
	--self:showLoading() -- 显示Loading动画
	-- Network:init()
	local function connectNext()
		local function getGateNext(rc, gateInfo)
			--ServerData:saveServerInfo(gateInfo);
			local function disconnectNext()
				local function connectGateNext()
					local function askSeed(rc, seed)
						if rc ~= 0 then
							self:info("获取服务器随机种子失败, code:" .. rc)
						else
							self.seed = seed;
							Network.seed = seed;
							self:onConnectSuccessed(seed)							
						end
					end
					Network:request("connector.entryHandler.askSeed", nil, askSeed)
				end
				Network:connect(gateInfo.host, gateInfo.port, connectGateNext);
			end
			Network:disconnect(disconnectNext);
		end
		Network:request(NetCommandDef.s_gate_knock, "", getGateNext);
	end
	Network:connect(GATE_HOST, GATE_PORT, connectNext);
end

function LoginScene:onConnectSuccessed(seed)
	print("LoginScene:onConnectSuccessed");
	if seed then 
		self.seed = seed
	end

	self:getViewBase().m_ccbLoginView:onConnectSuccessed();
	
	local account, password = self:getLocalAccountPassword() -- 取出已保存在本地的帐号密码(如有)
	self:getViewBase().m_ccbLoginView:setDefaultInfo(account, password);

	self:hideLoading() -- 隐藏Loading动画
end

-- 登录按钮点击事件
function LoginScene:requestLogin(data)
	if data.account == DELETE_LOCAL_DATA then
		self:deleteLocalData()
		Tips:create("本地存储帐号密码数据已删除")

	elseif data.account == LOGIN_WITH_SESSION then
		self:showLoading()
		self:loginWithSession()

	elseif data.account == USE_TEST_GATE then
		Network:disconnect(function() 
			GATE_HOST = NetworkConst.TEST_GATE_HOST
			GATE_PORT = NetworkConst.TEST_GATE_PORT
			self:connect() 
		end)

	elseif data.account == USE_DEV_GATE then
		Network:disconnect(function()		
			GATE_HOST = NetworkConst.DEV_GATE_HOST
			GATE_PORT = NetworkConst.DEV_GATE_PORT
			self:connect() 
		end)

	else
		self:showLoading()
		self:loginWithPassword(data)
	end
end

-- 使用帐号密码登录
function LoginScene:loginWithPassword(data)
	local account = data.account
	local password = data.password

	if account == nil or account == "" then
		Tips:create("账号不能为空");
		self:hideLoading()
		return
	end

	local hash = Crypto:md5(password .. "|" .. account .. "|" .. self.seed) -- 加密
	local data = {
		account = account,
		hash = hash,
		channel = "0",
		uid = ""
	}
	self:saveAccountPassword(account, password) -- 保存帐号密码到本地

	local function loginCallBack(rc, data)
		-- print("① ： ");
		-- dump(data);
		if data.code == 1 then
			self.userDefault:setStringForKey("usession", data.session)
			self.userDefault:setStringForKey("uid", data.uid)
			self:onLoginSuccessed()
		else
			Tips:create(Code[data.code]..", "..data.code)
			self:hideLoading()
		end		
	end
	Network:request("login.userHandler.loginVerify", data, loginCallBack)	
end

-- 使用session／uid登录
function LoginScene:loginWithSession()
	local session, uid = self:getLocalSession() -- 取出本地保存的session／uid

	if session == nil or uid == nil or session == "" or uid == "" then
		Tips:create("登录失败");
		print("session与uid不能为空。");
		self:hideLoading()
		return
	end

	local token = Crypto:decrypt(session)
	local hash = Crypto:md5(token .. "|" .. uid .. "|" .. self.seed)
	local data = {
		uid = uid,
		hash = hash,
	}

  	Network:request("login.userHandler.loginVerify", data, function(rc, data)
		dump(data);
  		if data.code == 1 then
  			self:onLoginSuccessed()
  		else
  			Tips:create(Code[data.code]..", "..data.code)
  			self:hideLoading()
  		end
	end)
end

-- 登录成功后请求数据
function LoginScene:onLoginSuccessed()
	self:requestUserData()
	self:requestResItemList()
	self:requestEquipSlotItemList();
	self:requestShipInfo()
	self:requestFortList()
	self:requestShipSkinList()
	self:requestBuyTimes();
	-- self:requestMerchantShipLevel()
end

-- 请求玩家数据
		
-- - "<var>" = {
-- -     "alliance_coin"  = 10000
-- -     "code"           = 1
-- -     "diamond"        = 20
-- -     "exp"            = 0
-- -     "famous_id"      = 1
-- -     "famous_num"     = 0
-- -     "global_id"      = "cfcde2685861c1bf4c1a4ee2d10bb8d5"
-- -     "level"          = 1
-- -     "max_exp"        = 10
-- -     "nickname"       = "pt_56"
-- -     "universal_coin" = 10
-- - }
function LoginScene:requestUserData()
 
 	---单机测试 ------
     -- local battleScene = App:enterScene("BattleScene");
     -- BattleDataMgr:Init();
     -- battleScene:setBattleData();
     ----------------

	Network:request("game.syncHandler.userInfo", nil, function (rc, data)
		print("------------请求玩家数据----------------")
		-- dump(data)

		if data["code"] ~= 1 then
			Tips:create(ServerCode[data.code]);
			self:hideLoading()
			return
		end

		-- local viewData = {
		-- 	playerName = data.nickname,
		-- 	playerPower = data.power,
		-- 	playerLevel = data.level,
		-- 	playerCurrentExp = data.exp,
		-- 	playerLevelUpExp = data.max_exp,
		-- 	playerUniversalCoin = data.universal_coin,
		-- 	playerDiamond = data.diamond,
		-- 	playerAllianceCoin = data.alliance_coin,
		-- 	-- playerFamousId = data.famous_id,
		-- 	playerFamous = data.famous_num,
		
		-- 	hiding_second //隐身剩余秒数
		-- radar_second: //探索雷达剩余秒数
		-- friendship_buff_remain_second: //友情点数双倍buff剩余秒数
		-- }

		UserDataMgr:setAllUseInfo(data)
		self.mainViewDataReady = true
		self:tryEnterGame()
	end)
end

-- 请求资源库物品列表
function LoginScene:requestResItemList()
	Network:request("game.syncHandler.loadItems", nil, function (rc, data)
		print("----------------请求资源库物品------------------")
		-- dump(data)

		if data["code"] ~= 1 then
			Tips:create(ServerCode[data.code]);
			self:hideLoading()
			return
		end

		ItemDataMgr:setAllItemInfo(data)
		self.resItemListReady = true
		self:tryEnterGame()
	end)
end

function LoginScene:requestEquipSlotItemList()
	Network:request("game.syncHandler.queryEquipList", nil, function (rc, data)
		print("----------------请求已装备道具------------------");
		if data.code ~= 1 then
			Tips:create(ServerCode[data.code]);
			return ;
		end
		-- dump(data);
		ItemDataMgr:setEquipList(data.equip_list[1]);
	end);
end

-- 请求战舰信息(战舰装备的炮台信息和战舰皮肤)
function LoginScene:requestShipInfo()
	Network:request("game.syncHandler.shipInfo", nil, function (rc, data)
		print("---------------请求战舰信息-----------------")
		-- dump(data)
		-- "<var>" = {
		--     "code"      = 1
		--     "forts" = {
		--         1 = {
		--             "exp"         = 0
		--             "fort_id"     = 90001
		--             "level"       = 1
		--             "skill_id"    = 50001
		--             "skill_level" = 1
		--         }
		--         2 = {
		--             "exp"         = 0
		--             "fort_id"     = 90002
		--             "level"       = 1
		--             "skill_id"    = 50002
		--             "skill_level" = 1
		--         }
		--         3 = {
		--             "exp"         = 0
		--             "fort_id"     = 90003
		--             "level"       = 1
		--             "skill_id"    = 50003
		--             "skill_level" = 1
		--         }
		--     }
		--     "global_id" = "cfcde2685a97cb30a5b41d9a2393049d"
		--     "ship"      = 70001
		-- }
		if data["code"] ~= 1 then
			Tips:create(ServerCode[data.code]);
			self:hideLoading()
			return
		end

		FortDataMgr:setShipFortsInfo(data);--获得装备炮台信息
		ShipDataMgr:setShipData(data);

		self.shipInfoReady = true
		self:tryEnterGame()
	end)
end

-- 请求炮台列表(所有炮台信息)
function LoginScene:requestFortList()
	Network:request("game.syncHandler.fortList", nil, function (rc, data)
		print("---------------请求炮台列表------------------")
		-- dump(data)

		if data["code"] ~= 1 then
			Tips:create(ServerCode[data.code]);
			self:hideLoading()
			return
		end

		FortDataMgr:setUnlockFortsData(data)

		self.fortListReady = true
		self:tryEnterGame()
	end)
end

-- 请求已解锁皮肤列表(接口改动)
function LoginScene:requestShipSkinList()
	Network:request("game.syncHandler.shipList", nil, function (rc, data)
		print("---------------请求已解锁皮肤列表------------------")
		-- dump(data) 
		-- "<var>" = {
		--     "code"  = 1
		--     "ships" = {
		--         1 = {
		--             "ship_id"     = 70001
		--             "skill_level" = 1
		--         }
		--     }
		-- }
		if data["code"] ~= 1 then
			Tips:create(ServerCode[data.code]);
			self:hideLoading()
			return
		end

		for k,v in pairs(data.ships) do
			local skinInfo = {
				ship_id = v.ship_id,
				skill_level = v.skill_level
			}
			-- dump(skinInfo)
			ShipDataMgr:setShipSkinData(skinInfo)
		end 
		
		self.skinListReady = true
		self:tryEnterGame()
	end)	
end

-- 尝试进入游戏
function LoginScene:tryEnterGame()
	if self.resItemListReady and
	   self.mainViewDataReady and
	   --self.equipListReady and
	   self.shipInfoReady and
	   self.fortListReady and
	   self.skinListReady

	then
		self:tryEnterBattleScene()
	end
end

-- 如有中断的战斗，则进入战斗场景继续，否则进入主界面
-- - "<var>" = {
-- -     "f1"    = 90001
-- -     "f2"    = 90101
-- -     "f3"    = 90201
-- -     "f4"    = 90001
-- -     "f5"    = 90002
-- -     "f6"    = 90003
-- -     "hp1"   = 2400
-- -     "hp2"   = 2899
-- -     "sid_1" = "connector-server-1"
-- -     "sid_2" = "connector-server-1"
-- -     "skin1" = 70001
-- -     "skin2" = 70001
-- -     "uid1"  = "cfcde268583f853ea2d364b08638bef8"
-- -     "uid2"  = "cfcde26857bd54a29ece089ef09a3562"
-- - }
function LoginScene:tryEnterBattleScene()
	print("  试图进入战斗场景 ")
	if not CHECK_BATTLE then App:enterScene("MainScene") return end

	Network:request("battle.matchHandler.check_exists_battle", nil, function (rc, data) -- 请求检查是否存在中断的战斗
		-- dump(rc);
		-- dump(data);
		-- dump(data.config)

		if not data.found then 
			App:enterScene("MainScene");
			-- self:tryEnterEscortScene() -- 如果没有战斗就判断是否在护送
			return;
		end

		Audio:stopMusic();
		BattleDataMgr:Init(data);
		local battleScene = App:enterScene("BattleScene")
		-- battleScene:initBattle(data)
	end)
end

-- function LoginScene:tryEnterEscortScene()
-- 	Network:request("loot_battle.lootHandler.query_escort_info", nil, function(rc, data)
-- 		print("LoginScene:tryEnterEscortScene")
-- 		if data.code == nil or data.remain_second <= 0 then
-- 			print("进入主界面")
-- 			Audio:stopMusic();
-- 			App:enterScene("MainScene");	-- 没有护送正常游戏
-- 			return;
-- 		end		
	
-- 		print("进入护送Scene")
-- 		EscortDataMgr:setCurChooseMerchantShip(data.merchant_ship_level)
-- 		EscortDataMgr:setEscortTaskTime(data.remain_second)
-- 		if data.award[1].item_id == 10001 then
-- 			EscortDataMgr:totalGoldCount(data.award[1].count);
-- 			EscortDataMgr:totalDiamondCount(data.award[2].count);
-- 		else
-- 			EscortDataMgr:totalDiamondCount(data.award[1].count);
-- 			EscortDataMgr:totalGoldCount(data.award[2].count);
-- 		end
-- 		App:enterScene("EscortScene");
-- 	end)
-- end

-- 查询商品购物次数信息
function LoginScene:requestBuyTimes()
	Network:request("game.shopHandler.query_buy_info", nil, function (rc, data)
		print("----------------查询商品购物次数信息------------------");
		--dump(data);

		if data["code"] ~= 1 then
			Tips:create(ServerCode[data.code]);
			self:hideLoading();
			return;
		end

		ItemDataMgr:setBuyTimes(data.info);
	end)
end

function LoginScene:reconnect()
	GATE_HOST = Network.GATE_HOST;
	GATE_PORT = Network.GATE_PORT;
	Network:reconnect();
end

return LoginScene