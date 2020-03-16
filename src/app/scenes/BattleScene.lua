--------------------------
-- 战斗场景
--------------------------
-- global("ShipMgr");
-- ShipMgr = require("app.views.battle.ShipMgr");
local Tips = require("app.views.common.Tips");
local CCBBattle = require("app.views.battle.CCBBattle")

local BattleScene = class("BattleScene", require("app.scenes.GameSceneBase"))

function BattleScene:ctor()
	-- print("BattleScene:ctor")
	self.m_conbatData = table.clone(require("app.constants.combat"));
	self.m_battleSkillData = table.clone(require("app.constants.skill_data"));
	
	self.m_ccbBattle = CCBBattle:create();
	self:addChild(self.m_ccbBattle);
	self.m_ccbBattle:setPosition(cc.p(display.cx - self.m_ccbBattle:getContentSize().width * 0.5, 
							display.cy - self.m_ccbBattle:getContentSize().height * 0.5))

	self:setBattleData();

	-- local callBack = cc.CallFunc:create(function ()
	-- 	self:notifyBattleReady();
	-- 	self:notifyBattleStart();
	-- end)
	-- local sequence = cc.Sequence:create(cc.DelayTime:create(5), callBack);
	-- self:runAction(sequence);
end

function BattleScene:setBattleData()
	-- print("BattleScene:setBattleData");
	if BattleDataMgr.m_isBattleExist == false then
		if BattleDataMgr:getBattleType() ~= 3 then
			self.m_ccbBattle:battleShipBegin();
		elseif BattleDataMgr:getBattleType() == 3 then
			self.m_ccbBattle:playBossBattleMusic();
			self.m_ccbBattle:playShip1Idle();
			self.m_ccbBattle:showBossWarning();   
		end
	else
		if BattleDataMgr:getBattleType() ~= 3 then
			print("普通战斗重连");
			self.m_ccbBattle:battleShipAgain();
			self.m_ccbBattle:ready();
			self.m_ccbBattle:showUI();
			self.m_ccbBattle:startBattle();
		else     
		-- 重连的boss战
			self.m_ccbBattle:playIdle1();
			self.m_ccbBattle:showUI();

			self.m_ccbBattle:ready();
			self.m_ccbBattle:startBattle();
		end
	end
end

function BattleScene:notifyBattleReady(data)
	-- print(" BattleScene:notifyBattleReady  1111111111111111111111111111111111111111111111111111111111111111111")
	self.m_ccbBattle:ready();
end

function BattleScene:notifyBattleStart(data)
	self.m_ccbBattle:startBattle();
end

--使用道具
	--单体 "arg":3,"name":"use_item","item_id":1012,"ship_index":1,"frame":5682,"seqnum":2
	--群体 "arg":8,"name":"use_item","item_id":4004,"ship_index":1,"frame":63,"seqnum":1

--使用技能 "name":"fort_skill","fort_index":2,"ship_index":0,"frame":2263,"seqnum":3
function BattleScene:notifyBattleEvent(data)
	-- dump(data)
	--炮台技能
	-- "<var>" = {
	--     "arg"        = 3
	--     "code"       = 0
	--     "fort_id"    = 90003
	--     "is_uid1"    = false
	--     "ship_index" = 1
	--     "type"       = 2
	--	   "buff_rate"= 1
	-- }

	--使用道具
	-- "<var>" = {
	--     "arg"             = 3
	--     "code"            = 0
	--     "fort_id"         = 90003
	--   
	--     "ship_id"         = 70001
	--     "ship_index"      = 1
	--     "target_is_enemy" = 0
	--     "type"            = 3
	-- }

	-- ship_index 为0 时 提交者为uid1， 为2 时 提交者是 uid2
	-- is_uid1  为false 说明自己是uid2 ，true 自己是uid1.

	-- dump(data); --使用道具成功与否服务器发来的。tip提示可以在这边做
	if data.code == 4 then
		-- Tips:create(Str[11002]);
		self.m_ccbBattle:UpdateCurSelectItem();
		-- self.m_ccbBattle:cancelBottonAllSelectForNoUse();
		self.m_ccbBattle.m_ccbFileBottom:updateItemCount();
		self.m_ccbBattle:addBuffOfBossUnBuff();
	elseif data.code ~= 1 then
		print("错误消息,无法使用道具或者技能")
		print("    data. code  .. " , data.code);
		local str = ServerCode[data.code];
		Tips:create(str);
		self.m_ccbBattle:UpdateCurSelectItem();
		self.m_ccbBattle:cancelBottonAllSelectForNoUse();
		return;
	end

	local ItemUser = 0; 	--道具使用者 1.player\2.enemy
	local isMyFort = nil;	--是否是我方炮台
	local use_skill_ship = 0;	--是否是我方战舰

	if data.ship_index == 0 then 	 --事件提交者是uid1 即为使用者是uid1
		if data.is_uid1 == true then --玩家是否是uid_1 事件接受者 true 为uid1 false 为uid2。也就是自己（判断自己是uid1 还是uid2）
			print("自己发的")
			ItemUser = 1;
			isMyFort = 1;
			use_skill_ship = 1;
		else
			print("对方发的")
			ItemUser = 2;
			isMyFort = 2;
			use_skill_ship = 2;
		end
	else
		if data.is_uid1 == true then
			print("对方发的")
			ItemUser = 2;
			isMyFort = 2;
			use_skill_ship = 2;
		else
			print("自己发的")
			ItemUser = 1;
			isMyFort = 1;
			use_skill_ship = 1;
		end
	end

	if data.type == 1 then
		print("使用道具")
		local targetShip = 1; -- 目标战舰Index
		local targetFortID = 0;
		if ItemUser == 1 then
			if data.target_is_enemy == 0 then
				targetShip = 1;
			elseif data.target_is_enemy == 1 then
				targetShip = 2;
			else
				targetShip = 0;
			end
		else
			if data.target_is_enemy == 0 then
				targetShip = 2;
			elseif data.target_is_enemy == 1 then
				targetShip = 1;
			else
				targetShip = 0;
			end
		end
		if data.fort_id ~= nil then
			targetFortID = data.fort_id
		else
			targetFortID = 0
		end
		-- print("  itemUser : ", ItemUser,  "  target : ", targetShip, "  targetFortID: ", targetFortID);
		-- print("    itme_id  : ", data.item_id);
		newBattle.useProp(ItemUser, data.item_id, targetShip, targetFortID);
		if BattleDataMgr:getBattleType() == 3 then
			if tonumber(data.item_id) <= 1012 then
				print("使用有debuff的导弹道具  item_id ", data.item_id);
				local propTime = self.m_conbatData[tostring(data.item_id)].time;
				local callBack = cc.CallFunc:create(function()
					-- Tips:create(Str[11002]);
					self.m_ccbBattle:addBuffOfBossUnBuff();
				end)
				local sequence = cc.Sequence:create(cc.DelayTime:create(propTime), callBack);
				self:runAction(sequence);
			end
		end
		if ItemUser == 1 then
			self.m_ccbBattle:UpdateCurSelectItem();
			self.m_ccbBattle.m_ccbFileBottom:updateItemCount();
		end
	elseif data.type == 2 then
		print("播放炮台技能,炮台id",data.fort_id)
		newBattle.fortFireSkill(isMyFort, data.fort_id, data.buff_rate) -- 炮台放技能给外部库
		if BattleDataMgr:getBattleType() == 3 then
			-- buff类型  3 - 8  是debuff 
			local isDebuff = 0;
			print("  释放技能啦    ！！！！！！！1 ");
			local skillID = FortDataMgr:getFortBaseInfo(data.fort_id).skill_id;
			local skillData = FortDataMgr:getSkillInfoBySkillID(skillID);
			for k, v in pairs(skillData.skill_type) do 
				if tonumber(v) >= 3 and tonumber(v) <= 8 then
					isDebuff = 1;
					break;
				end
			end
			if isDebuff == 1 then
				local fortSkillLevel = FortDataMgr:getUnlockFortSkillLevel(data.fort_id);
				print("   ~~~~~ 选中炮台的技能等级：   ", fortSkillLevel);
				local hitRate = FortDataMgr:getSkillBuffHitRate(skillID, fortSkillLevel);
				print("  ~~~~~~ 技能buff命中率：  ", hitRate);
				local skillTime = self.m_battleSkillData[tostring(skillID)].skill_time;
				print(" ~~~~~~ 技能释放时间：  ", skillTime);
				local randNum = math.random(1, 100);
				print(" ~~~~~~ 随机到的数字：   ", randNum);
				if randNum <= hitRate then
					local callBack = cc.CallFunc:create(function()
						-- Tips:create(Str[11002]);
						self.m_ccbBattle:addBuffOfBossUnBuff();
					end)
					local sequence = cc.Sequence:create(cc.DelayTime:create(skillTime), callBack);
					self:runAction(sequence);
				end
			end
		end

	elseif data.type == 3 then 	--使用战舰技能
		newBattle.useShipSkill(use_skill_ship) 	 -- 参数：使用方：1，player；2，enemy
		if use_skill_ship == 1 then 
			Audio:playEffect(BattleDataMgr:getCurPlayerInfo().skin, false);
		else
			Audio:playEffect(BattleDataMgr:getCurEnemyInfo().skin, false);
		end
		print("-----------使用战舰技能：");
		-- dump(data);
		if BattleDataMgr:getBattleType() == 3 then
			if BattleDataMgr:getCurPlayerInfo().skin == 70007 then
				-- Tips:create(Str[11002]);
				self.m_ccbBattle:addBuffOfBossUnBuff();
			end
		end
		if use_skill_ship == 1 then
			self.m_ccbBattle:showShipSkill(BattleDataMgr:getCurPlayerInfo().skin, use_skill_ship, data.target_is_enemy);
		elseif use_skill_ship == 2 then
			self.m_ccbBattle:showShipSkill(BattleDataMgr:getCurEnemyInfo().skin, use_skill_ship, data.target_is_enemy);
		end
		-- if data.target_is_enemy == 0 then  -- 道具目标是对自己
		-- 	if use_skill_ship == 1 then		-- 使用方是自己
				
		-- 	else
		-- 		self.m_ccbBattle:showShipSkill(BattleDataMgr:getCurEnemyInfo().skin, 10);
		-- 	end
		-- else
		-- 	if use_skill_ship == 1 then
		-- 		self.m_ccbBattle:showShipSkill(BattleDataMgr:getCurPlayerInfo().skin, 0);
		-- 	else
		-- 		self.m_ccbBattle:showShipSkill(BattleDataMgr:getCurEnemyInfo().skin, 10);
		-- 	end
		-- 	-- if use_skill_ship == 1 then
		-- 	-- 	self.m_ccbBattle:showItemEffect(4004, 10)
		-- 	-- else
		-- 	-- 	self.m_ccbBattle:showItemEffect(4004, 0)
		-- 	-- end
		-- end
	end
end

--战斗结束，显示胜负
function BattleScene:notifyBattleOver(data)
	print("BattleScene:notifyBattleOver")
	-- dump(data)
	-- "<var>" = {
	--     "code"    = 1
	--     "is_surrender" = 0
	--     "is_uid1" = false
	--     "timeout" = 5
	-- }

	-- boss
-- "<var>" = {
--      "battle_id"   = "bat_5b6bdca2e1696b1db4dd7a58"
--      "battle_type" = 3
--      "code"        = 1
--  }
	local function delayShowResult()
		self.m_ccbBattle:showResult(data)
		newBattle.stop();
	end
	local delayTime = 1;
	if data.is_surrender == 1 then
		delayTime = 0;
	end
	local delayTask = cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(delayShowResult))
	self:runAction(delayTask)
end

--显示奖励结果
--胜利
--{"code":1,
--	"result":
--		{"recoup":[ {"item_id":10001,"count":200},
--				{"item_id":10006,"count":20},
--				{"item_id":10005,"count":305}],
--		"trophy":[ {"item_id":10001,"count":5000}],
--		"lost":[],
--		"win":1}
--}
--失败
--{"code":1,
--	"result":
--		{"recoup":[ {"item_id":10001,"count":200},
--				{"item_id":10006,"count":-20},
--		"trophy":[],
--		"lost":[{"item_id":10001,"count":5000}],
--		"win":0}
--}
--平局
--{"code":1,
--	"result":
-- 		{"recoup":[							--系统补偿
-- 			{"item_id":10001,"count":200},
-- 			{"item_id":10005,"count":152}],
-- 		"trophy":[],						--掠夺的物品
-- 		"lost":[],							--被掠夺的物品
-- 		"win":-1
--		}
-- }


function BattleScene:notifyBattleResult(data)
	dump(data);

	-- boss 
	-- dump(data.result.recoup);
-- "<var>" = {
--      "battle_type" = 3
--      "code"        = 1
--      "result" = {
--          "damage_info" = {
--              "all_damage" = 4822674
--              "damage"     = 2422057
--              "old_rank"   = 1
--              "rank"       = 1
--          }
--          "recoup" = {
--              1 = *MAX NESTING*
--              2 = *MAX NESTING*
--              3 = *MAX NESTING*
--              4 = *MAX NESTING*
--              5 = *MAX NESTING*
--              6 = *MAX NESTING*
--              7 = *MAX NESTING*
--          }
--      }
--  }
	print("BattleScene:notifyBattleResult")
	local function delayStart()
		-- if data.battle_type == 2 then 	--护送中的战斗
			-- if data.result.win == 1 then 	--胜利
			-- 	self.m_ccbBattle:showEscortBattleWin();
			-- else
			-- 	self.m_ccbBattle:showEscortBattleLose();
			-- 	self.m_ccbBattle.m_showEscortLose:showItemInfo(data.result);
			-- end
		if data.battle_type ~= 3 then
			if data.result then
				if self.m_ccbBattle.m_showResult then
					self.m_ccbBattle.m_showResult:showItemInfo(data);
				end
				-- if data.result.win == 1 then 	--普通战斗胜利
				-- 	if self.m_ccbBattle.m_showWin == nil then
				-- 		self.m_ccbBattle:showWin();			
				-- 	end
				-- 	self.m_ccbBattle.m_showWin:showItemInfo(data.result);
				-- elseif data.result.win == 0 then 	--普通战斗失败
				-- 	if self.m_ccbBattle.m_showLose == nil then
				-- 		self.m_ccbBattle:showLose();
				-- 	end
				-- 	self.m_ccbBattle.m_showLose:showItemInfo(data.result);
				-- elseif data.result.win == 2 then 	--普通战斗平局
				-- 	if self.m_ccbBattle.m_showDraw == nil then
				-- 		self.m_ccbBattle:showDraw();
				-- 	end
				-- 	self.m_ccbBattle.m_showDraw:showItemInfo(data.result);
				-- end		
			end
		elseif data.battle_type == 3 then
			self.m_ccbBattle:bossShowResult(data.result);
		end
	end
	local delayTime = 1;
	if data.is_surrender == 1 then -- or data.battle_type == 3 
		delayTime = 0;
	end
	local delayTask = cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(delayStart))
	self:runAction(delayTask)
end

function BattleScene:notifyBattleUpdate(data)
	self.m_ccbBattle:battleUpdateForSynchronization(data)
end

return BattleScene