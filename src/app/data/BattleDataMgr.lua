local BattleDataMgr = class("BattleDataMgr");
local fortList = table.clone(require("app.constants.fort_list"))

local  path = "res/data/"

-- 0 普通pvp
-- 1 探险
-- 2 抢劫贩售舰
-- 3 公域混战
-- 4 殖民星争夺战

function BattleDataMgr:Init(battleInfo)
	-- print("BattleDataMgr:Init(battleInfo)")
	-- self.m_isNeedReverse = false; --数据是否换位过
	self.m_isBattleExist = false; --重新登入游戏时是否存在未结束的战斗
	self.m_curSelectItemSlot = 0;
	self.m_energyPosY = 0;
	self.m_playerInfo = {}
	self.m_enemyInfo = {}
	self.m_robotInfo = {}

	self.m_battleType = -1;
	self.m_playerAddAckPercent = 0;

	self.m_battleItemList = table.clone(require("app.constants.combat"));
	-- dump(self.m_battleItemList[tostring(1001)]);

	self.m_enemyData = {}	--敌人炮台数据
	self.m_playerData = {}
	self.m_enemyData.HP = 0;
	self.m_playerData.HP = 0;

	self.m_isSendReadyOver = false;  -- 发送战斗准备完毕信号

	-- dump(battleInfo)	
-- {
--       "animation"           = 13000
--       "battle_type"         = 0
--       "config" = {
--           "f1" = {
--               "bullet_id"        = 90019
--               "fort_id"          = 90019
--               "fort_level"       = 99
--               "fort_star_domain" = 103
--               "fort_type"        = 0
--               "skill_level"      = 10
--           }
--           "f2" = {
--               "bullet_id"        = 90020
--               "fort_id"          = 90020
--               "fort_level"       = 99
--               "fort_star_domain" = 103
--               "fort_type"        = 1
--               "skill_level"      = 10
--           }
--           "f3" = {
--               "bullet_id"        = 90021
--               "fort_id"          = 90021
--               "fort_level"       = 99
--               "fort_star_domain" = 103
--               "fort_type"        = 2
--               "skill_level"      = 10
--           }
--           "f4" = {
--               "bullet_id"        = 90019
--               "fort_id"          = 90019
--               "fort_level"       = 99
--               "fort_star_domain" = 103
--               "fort_type"        = 0
--               "skill_level"      = 10
--           }
--           "f5" = {
--               "bullet_id"        = 90020
--               "fort_id"          = 90020
--               "fort_level"       = 99
--               "fort_star_domain" = 103
--               "fort_type"        = 1
--               "skill_level"      = 10
--           }
--           "f6" = {
--               "bullet_id"        = 90021
--               "fort_id"          = 90021
--               "fort_level"       = 99
--               "fort_star_domain" = 103
--               "fort_type"        = 2
--               "skill_level"      = 10
--           }
--           "hp1"               = 486678
--           "hp2"               = 486678
--           "item1" = {
--           }
--           "item2" = {
--           }
--           "level1"            = 99
--           "level2"            = 99
--           "name_1"            = "毫无还击能力的训练机器人"
--           "name_2"            = "艾尔索普奥德丽"
--           "power_1"           = 0
--           "power_2"           = 520241
--           "ship1"             = 70001
--           "ship2"             = 70007
--           "ship_skill_level1" = 10
--           "ship_skill_level2" = 10
--           "sid_2"             = "connector-server-1"
--           "uid_1"             = "robot"
--           "uid_2"             = "cfcde2685ab4aa52209ca97148571c9b"
--       }
--       "energy_refresh_time" = "15,20,27,16,30,18,30,20,23,23"
--       "energy_string"       = "1,0,0,0,1,1,1,1,1,0,1,0#0,1,0,1,1,0,0,0,1,0,1,0#1,2,0,0,1,0,0,1,0,1,1,0#0,0,0,1,0,0,1,1,0,0,1,0#1,2,0,0,0,1,0,1,0,0,1,0#1,2,1,1,0,1,0,0,0,0,0,0#1,0,1,1,0,1,1,1,0,0,1,1#1,0,1,0,1,1,0,1,0,0,1,0#2,2,1,1,0,0,0,1,0,1,1,1#1,2,0,0,0,0,1,0,1,1,1,0#"
--       "is_uid1"             = false -- 是否是玩家1
--       "name_1"              = "毫无还击能力的训练机器人"
--       "name_2"              = "艾尔索普奥德丽"
--       "power_1"             = 0
--       "power_2"             = 520241
--       "uid_1"               = "robot"
--       "uid_2"               = "cfcde2685ab4aa52209ca97148571c9b"
--   }
	
	-- local tempData = {						--用于单机测试
	-- 			animation = 10000,
	-- 			battle_id = "bat_5927963413320aff4abce8f0",
	-- 			battle_type         = 0,
	-- 			config = {
	-- 				f1      ={
	-- 							fort_id = 90004,
	-- 							fort_type = 0,
	-- 							fort_level = 1,
	-- 							fort_star_domain = 100,
	-- 							bullet_id = 90004,
	-- 							skill_level = 1
	-- 						},
	-- 				f2      ={
	-- 							fort_id = 90005,
	-- 							fort_type = 1,
	-- 							fort_level = 1,
	-- 							fort_star_domain = 100,
	-- 							bullet_id = 90005,
	-- 							skill_level = 1
	-- 						},
	-- 				f3      ={
	-- 							fort_id = 90006,
	-- 							fort_type = 2,
	-- 							fort_level = 1,
	-- 							fort_star_domain = 100,
	-- 							bullet_id = 90006,
	-- 							skill_level = 1
	-- 						},
	-- 				f4      ={
	-- 							fort_id = 90004,
	-- 							fort_type = 0,
	-- 							fort_level = 1,
	-- 							fort_star_domain = 100,
	-- 							bullet_id = 90004,
	-- 							skill_level = 1
	-- 						},
	-- 				f5      ={
	-- 							fort_id = 90005,
	-- 							fort_type = 1,
	-- 							fort_level = 1,
	-- 							fort_star_domain = 100,
	-- 							bullet_id = 90005,
	-- 							skill_level = 1
	-- 						},
	-- 				f6      ={
	-- 							fort_id = 90006,
	-- 							fort_type = 2,
	-- 							fort_level = 1,
	-- 							fort_star_domain = 100,
	-- 							bullet_id = 90006,
	-- 							skill_level = 1
	-- 						},
	-- 			       ship_skill_level1 = 1,
	-- 				   ship_skill_level2 = 1,
	-- 			       hp1     = 4360,
	-- 			       hp2     = 4360,
	-- 			       item1   = {},
	-- 			       item2   = {},
	-- 			       name_1  = "lll113",
	-- 			       name_2  = "kk123",
	-- 			       power_1 = 45849,
	-- 			       power_2 = 78635,
	-- 			       sid_1   = "connector-server-1",
	-- 			       sid_2   = "connector-server-1",
	-- 			       ship1   = 70003,
	-- 			       ship2   = 70003,
	-- 			       uid1    = "cfcde26858946fb8fbf3ef8d696c2dee",
	-- 			       uid2    = "cfcde26858c7433404a6abf7c9a51e4a"
	-- 		    },
	-- 			   energy_refresh_time = "20,18,20,24,21,17,26,30,29,27",
	--     		   energy_string      = "2,0,0,1,1,0,0,1,1,1,1#0,0,0,0,1,0,0,0,0,1,1#0,1,1,1,1,1,0,1,0,0,1#0,1,0,0,1,0,0,1,1,1,1#2,2,0,0,0,0,1,0,0,0,0#1,0,1,1,1,0,0,0,0,1,0#",
	-- 			   is_uid1   = "false", 
	-- 			   name_1    = "lll113",
	-- 			   name_2    = "kk123",
	-- 			   power_1   = 45849,
	-- 			   power_2   = 78635,
	-- 			   uid_1     = "cfcde26858946fb8fbf3ef8d696c2dee",
	-- 			   uid_2     = "cfcde26858c7433404a6abf7c9a51e4a"
	-- 			}

	----------------------------------------------------------------
				-- boss 战
				--------------------------------------------
 -- local tempData = {
 --     animation       = 0,
 --     battle_id       = "bat_5b5ab70a830fe7f2b2e8e09e",
 --     battle_type     = 3,
 --     boss_npc_buff   = "2,0,0,1,0,1,2,0,2,0",
 --     config = {
 --         f1 = {
 --             bullet_id        = 90019,
 --             fort_id          = 90019,
 --             fort_level       = 99,
 --             fort_star_domain = 103,
 --             fort_type        = 0,
 --             skill_level      = 10,
 --         },
 --         f2 = {
 --             bullet_id        = 90020,
 --             fort_id          = 90020,
 --             fort_level       = 99,
 --             fort_star_domain = 103,
 --             fort_type        = 1,
 --             skill_level      = 10,
 --         },
 --         f3 = {
 --             bullet_id        = 90021,
 --             fort_id          = 90021,
 --             fort_level       = 99,
 --             fort_star_domain = 103,
 --             fort_type        = 2,
 --             skill_level      = 10,
 --         },
 --         hp               = 486678,
 --         item1 = {
 --         },
 --         item2 = {
 --         },
 --         level            = 99,
 --         name             = "艾尔索普奥德丽",
 --         power            = 520241,
 --         ship             = 70007,
 --         ship_skill_level = 10,
 --         sid              = "connector-server-1",
 --         uid_1            = "boss",
 --         uid_2            = "cfcde2685ab4aa52209ca97148571c9b"
 --     },
 --     damage_add_rate = 0,
 --     name            = "艾尔索普奥德丽",
 --     player_num      = 423,
 --     power           = 520241,
 --     uid             = "cfcde2685ab4aa52209ca97148571c9b"
 -- }
 	-- battleInfo = tempData;
	if battleInfo ~= nil then
		self.m_battleType = battleInfo.battle_type;

		self:getFortData(battleInfo);	--处理数据
		
		if device.platform == "android" then 	--如果设备是android
			path = "assets/res/data/"			
		end

		-- battleType 0 普通战斗 battleType 1 探險， battleType 2 打劫贩售舰 battleType 3 公寓混战
		if self.m_battleType ~= 3 then    -- 普通战斗 
			newBattle.enterBattle(0, path.."skill_data.json", path.."combat.json", path.."libcode.json", path.."ship_list.json");
			newBattle.setEnergyBodyRoad(battleInfo.energy_refresh_time,battleInfo.energy_string)
			self:submitData();
		elseif self.m_battleType == 3 then  -- boss  公域混战

			self.m_playerAddAckPercent = battleInfo.damage_add_rate;
			newBattle.enterBossBattle(3, path.."skill_data.json", path.."combat.json", path.."libcode.json", path.."ship_list.json", battleInfo.player_num, path .. "boss_data.json", self.m_enemyData.boss_id, battleInfo.boss_npc_buff);
			 -- 设置boss 被动Npc buff 执行路线
			 -- 设置玩家数量
			 -- 设置boss的json文件路径
			 self:setFortDataInBossBattle();
			 newBattle.playerAddDamage(battleInfo.damage_add_rate);
		end

		if battleInfo.data then --重新登入游戏时存在未结束的战斗
			newBattle.restartBattle(battleInfo.data)
			self.m_isBattleExist = true;
		end
	end		
end

--敌人的炮台数据
function BattleDataMgr:getFortData(data)
	if data.config.uid_1 ~= UserDataMgr:getPalyerUID() then
		if self.m_battleType == 3 then
				-- boss数据
				self.m_enemyData.boss_id = 1;
		else
			for i= 1, 3 do --炮台位置:上1 ，中2， 下3
			--=====敌人炮台=====--


			self.m_enemyData[i] = {}
			local enemyFortKey = string.format("f%s",i);
			self.m_enemyData[i].fort_id = data.config[enemyFortKey].fort_id;
			self.m_enemyData[i].level = data.config[enemyFortKey].fort_level;
			self.m_enemyData[i].fort_type = data.config[enemyFortKey].fort_type;
			self.m_enemyData[i].bullet_id = data.config[enemyFortKey].bullet_id;
			self.m_enemyData[i].star_const = data.config[enemyFortKey].fort_star_domain;

			local enemySkillID = FortDataMgr:getSkillInfoByFortID(data.config[enemyFortKey].fort_id);
			self.m_enemyData[i].skillID = enemySkillID.id;
			self.m_enemyData[i].fortSkillLevel = data.config[enemyFortKey].skill_level

			self.m_enemyData.HP = FortDataMgr:healthPoint(data.config[enemyFortKey].fort_id,self.m_enemyData[i].level)+self.m_enemyData.HP;
			self.m_enemyData.skin = data.config.ship1;
			self.m_enemyData.name = data.config.name_1;
			self.m_enemyData.items = data.config.item1;
			self.m_enemyData.fight =data.config.power_1;
			self.m_enemyData.level = data.config.level1;
			self.m_enemyData.rank = data.config.famous_level1;
			self.m_enemyData.shipSkillLv = data.config.ship_skill_level1;
			end
		end
			--=====自己装备炮台=====--
		for i = 1, 3 do
			self.m_playerData[i] = {}
			if self.m_battleType ~= 3 then
				local myFortKey = string.format("f%s",i+3);
				self.m_playerData[i].fort_id = data.config[myFortKey].fort_id;
				self.m_playerData[i].level = data.config[myFortKey].fort_level;
				self.m_playerData[i].fort_type = data.config[myFortKey].fort_type;
				self.m_playerData[i].bullet_id = data.config[myFortKey].bullet_id;
				self.m_playerData[i].star_const = data.config[myFortKey].fort_star_domain;

				local mySkillID = FortDataMgr:getSkillInfoByFortID(data.config[myFortKey].fort_id)
				self.m_playerData[i].skillID = mySkillID.id;
				self.m_playerData[i].fortSkillLevel = data.config[myFortKey].skill_level

				self.m_playerData.HP = FortDataMgr:healthPoint(data.config[myFortKey].fort_id,self.m_playerData[i].level)+self.m_playerData.HP;
				self.m_playerData.skin = data.config.ship2;
				self.m_playerData.name = data.config.name_2;
				self.m_playerData.items = data.config.item2;
				self.m_playerData.fight = data.config.power_2;
				self.m_playerData.level = data.config.level2;
				self.m_playerData.rank = data.config.famous_level2;
				self.m_playerData.shipSkillLv = data.config.ship_skill_level2;

			elseif self.m_battleType == 3 then
				local myFortKey = string.format("f%s",i);
				self.m_playerData[i].fort_id = data.config[myFortKey].fort_id;
				self.m_playerData[i].level = data.config[myFortKey].fort_level;
				self.m_playerData[i].fort_type = data.config[myFortKey].fort_type;
				self.m_playerData[i].bullet_id = data.config[myFortKey].bullet_id;
				self.m_playerData[i].star_const = data.config[myFortKey].fort_star_domain;

				local mySkillID = FortDataMgr:getSkillInfoByFortID(data.config[myFortKey].fort_id)
				self.m_playerData[i].skillID = mySkillID.id;
				self.m_playerData[i].fortSkillLevel = data.config[myFortKey].skill_level

				self.m_playerData.HP = FortDataMgr:healthPoint(data.config[myFortKey].fort_id,self.m_playerData[i].level)+self.m_playerData.HP;
				self.m_playerData.skin = data.config.ship;
				self.m_playerData.name = data.config.name;
				self.m_playerData.items = data.config.item1;
				self.m_playerData.fight = data.config.power;
				self.m_playerData.level = data.config.level;
				self.m_playerData.rank = data.config.famous_level;
				self.m_playerData.shipSkillLv = data.config.ship_skill_level;

			end

		end
	else  -- uid_1 是玩家的。
		for i = 1, 3 do --炮台位置:上1 ，中2， 下3
			--=====敌人炮台=====--
			self.m_enemyData[i]={}
			local enemyFortKey = string.format("f%s",i+3)

			self.m_enemyData[i].fort_id = data.config[enemyFortKey].fort_id;
			self.m_enemyData[i].level = data.config[enemyFortKey].fort_level;
			self.m_enemyData[i].fort_type = data.config[enemyFortKey].fort_type;
			self.m_enemyData[i].bullet_id = data.config[enemyFortKey].bullet_id;
			self.m_enemyData[i].star_const = data.config[enemyFortKey].fort_star_domain;

			local enemySkillID = FortDataMgr:getSkillInfoByFortID(data.config[enemyFortKey].fort_id)
			self.m_enemyData[i].skillID = enemySkillID.id;
			self.m_enemyData[i].fortSkillLevel = data.config[enemyFortKey].skill_level

			self.m_enemyData.HP = FortDataMgr:healthPoint(data.config[enemyFortKey].fort_id,self.m_enemyData[i].level)+self.m_enemyData.HP;
			self.m_enemyData.skin = data.config.ship2;
			self.m_enemyData.name = data.config.name_2;
			self.m_enemyData.items = data.config.item2;
			self.m_enemyData.fight =data.config.power_2;
			self.m_enemyData.level = data.config.level2;
			self.m_enemyData.rank = data.config.famous_level2;
			self.m_enemyData.shipSkillLv = data.config.ship_skill_level2;

			--====自己装备炮台====--
			self.m_playerData[i] = {}
			local myFortKey = string.format("f%s",i)
			self.m_playerData[i].fort_id = data.config[myFortKey].fort_id;
			self.m_playerData[i].level =  data.config[myFortKey].fort_level; 
			self.m_playerData[i].fort_type = data.config[myFortKey].fort_type;
			self.m_playerData[i].bullet_id = data.config[myFortKey].bullet_id;
			self.m_playerData[i].star_const = data.config[myFortKey].fort_star_domain;

			local mySkillID = FortDataMgr:getSkillInfoByFortID(data.config[myFortKey].fort_id)
			self.m_playerData[i].skillID = mySkillID.id;
			self.m_playerData[i].fortSkillLevel = data.config[myFortKey].skill_level

			self.m_playerData.HP = FortDataMgr:healthPoint(data.config[myFortKey].fort_id,self.m_playerData[i].level)+self.m_playerData.HP;
			self.m_playerData.skin = data.config.ship1;
			self.m_playerData.name = data.config.name_1;
			self.m_playerData.items = data.config.item1;
			self.m_playerData.fight = data.config.power_1;
			self.m_playerData.level = data.config.level1;
			self.m_playerData.rank = data.config.famous_level1;
			self.m_playerData.shipSkillLv = data.config.ship_skill_level1;
		end
	end

	self.m_playerData.isMe = true;
	self.m_enemyData.isMe = false;
	-- dump(self.m_enemyData)
	-- dump(self.m_playerData)
end 

--提交炮台数据
function BattleDataMgr:submitData()
	local playerShipSkillLv = self.m_playerData.shipSkillLv; 
	local enemyShipSkillLv = self.m_enemyData.shipSkillLv;
	newBattle.setShipData(self.m_playerData.skin, playerShipSkillLv, self.m_playerData[1].fort_id, self.m_playerData[2].fort_id, self.m_playerData[3].fort_id, self.m_enemyData.skin, enemyShipSkillLv, self.m_enemyData[1].fort_id, self.m_enemyData[2].fort_id, self.m_enemyData[3].fort_id)
	-- print("皮肤ID:", self.m_playerData.skin, " 战舰技能等级：", playerShipSkillLv, " 玩家1-fort_id1:", self.m_playerData[1].fort_id, " 玩家1-fort_id2:", self.m_playerData[2].fort_id,
	-- 	" 玩家1-fort_id3:", self.m_playerData[3].fort_id, " 敌方战舰ID:", self.m_enemyData.skin, " 敌方战舰技能等级：", enemyShipSkillLv, 
	-- 	" 玩家2-fort_id1：", self.m_enemyData[1].fort_id, " 玩家2-fort_id2：", self.m_enemyData[2].fort_id, " 玩家2-fort_id3：", self.m_enemyData[3].fort_id);
	-- 敌我炮台，位置，炮台ID，专用ID，炮台类型，等级，炮台星域系数
	for i = 1, 3 do
		local isEnemy = 1;
		local fortPos = i - 1;
		local fortID = self.m_enemyData[i].fort_id;
		local specialID = self.m_enemyData[i].bullet_id;
		local fortType = self.m_enemyData[i].fort_type;
		local fortLevel = self.m_enemyData[i].level;
		local fortDomain = self.m_enemyData[i].star_const;
		local fortSkillLevel = self.m_enemyData[i].fortSkillLevel
		newBattle.setFortData(isEnemy,fortPos,fortID,specialID,fortType,fortLevel,fortDomain,fortSkillLevel);
		-- print("isEnemy:", isEnemy, " fortPos:", fortPos," fortID:", fortID, " bulletID:", specialID, " fortType:", fortType, " fortLevel:", fortLevel,
		-- 	" fortDomain:", fortDomain, " fortSkillLevel:", fortSkillLevel);
	end
	for i = 1, 3 do
		local isMe = 0;
		local fortPos = i - 1;
		local fortID = self.m_playerData[i].fort_id;
		local specialID = self.m_playerData[i].bullet_id;
		local fortType = self.m_playerData[i].fort_type;
		local fortLevel = self.m_playerData[i].level;
		local fortDomain = self.m_playerData[i].star_const;
		local fortSkillLevel = self.m_playerData[i].fortSkillLevel;
		newBattle.setFortData(isMe,fortPos,fortID,specialID,fortType,fortLevel,fortDomain,fortSkillLevel);
		-- print("isMe:", isMe, " fortPos:", fortPos, " fortID:", fortID, " bulletID:", specialID, " fortType:", fortType, " fortLevel:", fortLevel,
		-- " fortDomain:", fortDomain, " fortSkillLevel:", fortSkillLevel);
	end

end

-- boss战设置炮台数据
function BattleDataMgr:setFortDataInBossBattle()
	local playerShipSkillLV = self.m_playerData.shipSkillLv;
	-- dump(self.m_playerData);
	newBattle.setShipDataInBossBattle(self.m_playerData.skin, playerShipSkillLV, self.m_playerData[1].fort_id, self.m_playerData[2].fort_id, self.m_playerData[3].fort_id);
	for i = 1, 3 do
		local isMe = 0;
		local fortPos = i - 1;
		local fortID = self.m_playerData[i].fort_id;
		local specialID = self.m_playerData[i].bullet_id;
		local fortType = self.m_playerData[i].fort_type;
		local fortLevel = self.m_playerData[i].level;
		local fortDomain = self.m_playerData[i].star_const;
		local fortSkillLevel = self.m_playerData[i].fortSkillLevel;
		newBattle.setFortData(isMe,fortPos,fortID,specialID,fortType,fortLevel,fortDomain,fortSkillLevel);
	end
end

-- shipPos：1是左边战舰（自己），2是右边战舰（敌人）
function BattleDataMgr:getFortIDByfortPos(fortPos, shipPos)
	-- print("BattleDataMgr:getFortIDByfortPos(fortPos, shipPos)", fortPos, shipPos)
	if shipPos == 1 then
		if fortPos == 1 then
			return self.m_playerData[1].fort_id;
		elseif fortPos == 2 then
			return self.m_playerData[2].fort_id;
		elseif fortPos == 3 then
			return self.m_playerData[3].fort_id;
		end
	else
		if fortPos == 1 then
			return self.m_enemyData[1].fort_id;
		elseif fortPos == 2 then
			return self.m_enemyData[2].fort_id;
		elseif fortPos == 3 then
			return self.m_enemyData[3].fort_id;
		end
	end
end

function BattleDataMgr:getFortPosByFortID(fortID, shipPos)
	if shipPos == 1 then
		if fortID == self.m_playerData[1].fort_id then
			return 1;
		elseif fortID == self.m_playerData[2].fort_id then
			return 2;
		elseif fortID == self.m_playerData[3].fort_id then
			return 3;
		end
	else
		if fortID == self.m_enemyData[1].fort_id then
			return 1;
		elseif fortID == self.m_enemyData[2].fort_id then
			return 2;
		elseif fortID == self.m_enemyData[3].fort_id then
			return 3;
		end
	end
end

function BattleDataMgr:getBattleItemByItemID(itemID)
	return self.m_battleItemList[tostring(itemID)];
end 

function BattleDataMgr:getCurPlayerInfo()
	return self.m_playerData;
end

function BattleDataMgr:getCurEnemyInfo()
	return self.m_enemyData;
end

-- function BattleDataMgr:setPlayerShipSkin(shipID)
-- 	self.m_playerShipSkin = shipID;
-- end

-- function BattleDataMgr:getPlayerShipSkin()
-- 	return self.m_playerShipSkin
-- end

-- function BattleDataMgr:setEnemyShipSkin(shipID)
-- 	self.m_enemyShipSkin = shipID
-- end

-- function BattleDataMgr:getEnemyShipSkin()
-- 	return self.m_enemyShipSkin
-- end

--我方炮台的数据
function BattleDataMgr:getPlayerFortInfo(pos)
	return self.m_playerData[pos];
end

--敌方炮台的数据
function BattleDataMgr:getEnemyFortInfo(pos)
	return self.m_enemyData[pos];
end

function BattleDataMgr:getPlayerShipID()
	return self.m_playerData.skin
end

--当前选择的是第几个道具(CCBBottom的选中道具)
function BattleDataMgr:setCurSelectItemSlot(slotIndex)
	self.m_curSelectItemSlot = slotIndex;
end

function BattleDataMgr:getCurSelectItemSlot()
	return self.m_curSelectItemSlot;
end

--选中的道具的ID(CCBBottom的选中道具)
function BattleDataMgr:setCurSelectItemId(itemID)
	self.m_curSelectItemID = itemID;
end

function BattleDataMgr:getCurSelectItemId()
	return self.m_curSelectItemID;
end

--是否使用战舰技能
function BattleDataMgr:setSelectShipSkill(isSelect)
	self.m_isSelectHelper = isSelect;
end

function BattleDataMgr:isSelectShipSkill()
	return self.m_isSelectHelper;
end

function BattleDataMgr:setEnergyBodyPos(posY)
	-- self.m_energyPosX = posX;
	self.m_energyPosY = posY;
end

function BattleDataMgr:getEnergyBodyPos()
	return self.m_energyPosY 
end

function BattleDataMgr:getBattleType()
	return self.m_battleType;
end

function BattleDataMgr:getAddAckPercent()
	return self.m_playerAddAckPercent;
end

return BattleDataMgr