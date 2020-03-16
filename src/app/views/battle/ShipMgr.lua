local CShip = import(".CShip");
local CBoss = import(".CBoss");
local NumberTips = require("app.views.common.NumberTips")
local BattleResourceMgr = require("app.utils.BattleResourceMgr");
local BuffWordTips = require("app.views.common.BuffWordTips");

local ShipMgr = class("ShipMgr");

local Left_X = -1280*0.5 + 150; --左战舰位置
local Right_X = 1280*0.5 - 150;	--右战舰位置

-- 战舰位置
local SHIPS_POSITION = { LEFT = cc.p(Left_X , 0), RIGHT = cc.p(Right_X, 0) }

--炮台位置
local FORTS_POSITION = { [1] = cc.p(Left_X, 180), [2] = cc.p(Left_X, 40), [3] = cc.p(Left_X, -100),
						 [4] = cc.p(Right_X, 180), [5] = cc.p(Right_X, 40), [6] = cc.p(Right_X, -100) }

--炮台事件枚举
local FORT_FIRE = 1; --开火
local FORT_SKILL = 2; --技能
local FORT_SKILL_END = 3; --技能结束
local FORT_ENERGY_ADD_HP = 4; --能量加血
local FORT_PROP_ADD_HP = 5;	--道具加血
local FORT_CONTINUE_ADD_HP = 6;	--持续加血
local FORT_SKILL_ADD_HP = 7;	--技能回血
local FORT_SELF_ADD_ENERGY = 8; --炮台自身能量增加
local FORT_ENERGY_ADD_ENERGY = 9;	--炮台能量体充能
local FORT_PROP_ADD_ENERGY = 10;	--道具充能
local FORT_ATTACK_ADD_ENERGY = 11;	--攻击充能
local FORT_BE_DAMAGE_ADD_ENERGY = 12;	--受击充能
local FORT_BULLET_DAMAGE = 13; --子弹伤害 
local FORT_PROP_BULLET_DAMAGE = 14;	--道具炮弹伤害
local FORT_BUFF_BURN_DAMAGE = 15;	--燃烧BUFF伤害
local FORT_NPC_DAMAGE = 16;		--npc伤害
local FORT_SKILL_DAMAGE = 17;	--技能伤害
local FORT_DEEP_DAMAGE = 18; --多50%伤害
local FORT_BE_DEEP_DAMAGE = 19;  --多被打50%伤害
local FORT_DIE = 20;	--炮台死亡
local FORT_RELIVE_COOLDOWN = 21;	--复活倒计时
local FORT_RELIVE = 22;		--炮台复活
local FORT_EVENT_CLEAN_GOOD_BUFF = 23; --炮台清空增益BUFF
local FORT_EVENT_CLEAN_BAD_BUFF = 24;	--炮台清空减益BUFF

local FORT_SHIP_SKILL_ADD_HP = 25;    -- 战舰技能加血
local FORT_SHIP_SKILL_ADD_ENERGY = 26;-- 战舰技能加能量
local FORT_SHIP_SKILL_DAMAGE = 27;    -- 战舰技能伤害（扣血）


local BOSS_FIRE = 1;                   -- boss普攻
local BOSS_SKILL_BEGIN = 2;            -- boss技能开始
local BOSS_SKILL_FIRE = 3;             -- boss技能爆破
local BOSS_CALL_NPC_SKILL = 4;         -- boss召唤npc
local BOSS_CALL_NPC_BACK = 5;          -- boss呼唤npc回去

local BOSS_BE_DAMAGE_BY_BULLET = 6;    -- 子弹伤害
local BOSS_BE_DAMAGE_BY_FORT_SKILL = 7;-- 技能伤害
local BOSS_BE_DAMAGE_BY_NPC = 8;       -- NPC 伤害
local BOSS_BE_DAMAGE_BY_PROP = 9;      -- 道具伤害
local BOSS_BE_DAMAGE_BY_SHIP_SKILL = 10;--战舰技能伤害

local BOSS_CHANGE_STAGE_ONE = 11;      -- 切换状态1
local BOSS_CHANGE_STAGE_TWO = 12;      -- 切换状态2
local BOSS_CHANGE_STAGE_OVER = 13;     -- 切换状态完成

local BOSS_BE_DEEP_DAMAGE_BY_FORT_SKILL = 14;-- 技能的额外伤害

function ShipMgr:Init(ccbNodeShip, ccbNodeCloud, ccbBattle)
	-- print("ShipMgr:Init")
	self.m_ccbBattle = ccbBattle;

	self.m_ccbNodeShip = ccbNodeShip;--CCBBattle里的m_ccbNodeShip
	self.m_ccbNodeCloud = ccbNodeCloud;
	self.m_ship = {}; 	-- m_ship[1]为自己，m_ship[2]为敌人
	self.m_battleType = BattleDataMgr:getBattleType();

	-- SHIPS_POSITION = { LEFT = cc.p(-490 + display.offsetX, display.offsetY * 0.5 * display.scale), 
	-- 				RIGHT = cc.p(490 - display.offsetX * 0.5, display.offsetY * 0.5 * display.scale) }

	-- FORTS_POSITION = { FORT1 = cc.p(-490 + display.offsetX, 180 * display.scale),FORT2 = cc.p(-490 + display.offsetX, 40 * display.scale), 
	-- 				FORT3 = cc.p(-490 + display.offsetX, -100 * display.scale),FORT4 = cc.p(490 - display.offsetX, 180 * display.scale), 
	-- 				FORT5 = cc.p(490 - display.offsetX, 40 * display.scale), FORT6 = cc.p(490 - display.offsetX, -100 * display.scale)}

	local myFortInfo = BattleDataMgr:getCurPlayerInfo();
	-- dump(myFortInfo)
	self.m_ship[1] = CShip:create(myFortInfo.skin, 1, self.m_ccbBattle);
	ccbNodeShip:addChild(self.m_ship[1]);
	self.m_ship[1]:setPosition(SHIPS_POSITION.LEFT);
	--print(self.m_ship[1].m_shipIndex);
	local enemyFortInfo = BattleDataMgr:getCurEnemyInfo();
	-- dump(enemyFortInfo)
	if self.m_battleType ~= 3 then
		self.m_ship[2] = CShip:create(enemyFortInfo.skin, 2, self.m_ccbBattle);
		ccbNodeShip:addChild(self.m_ship[2]);
		self.m_ship[2]:setPosition(SHIPS_POSITION.RIGHT);
	elseif self.m_battleType == 3 then
		self.m_ship[2] = CBoss:create(enemyFortInfo.id, 2);
		ccbNodeShip:addChild(self.m_ship[2]);
		self.m_ship[2]:setPosition(SHIPS_POSITION.RIGHT);
	end

	--print(self.m_ship[2].m_shipIndex);

	self.m_testCount = 0;
end

function ShipMgr:setEffectSkill(ccbNodeEffectSkill)
	self.m_ship[1]:setEffectSkillAndCloud(ccbNodeEffectSkill, self.m_ccbNodeCloud);
	if self.m_battleType ~= 3 then
		self.m_ship[2]:setEffectSkillAndCloud(ccbNodeEffectSkill, self.m_ccbNodeCloud);
	else
		self.m_ship[2]:setEffectSkill(ccbNodeEffectSkill);
	end
end

-- 飞船入场动画（普通战斗）
function ShipMgr:playBegin()
	self.m_ship[1]:playBegin();
	self.m_ship[2]:playBegin();
end

function ShipMgr:playShip_1Idle()
	self.m_ship[1]:playShipIdle();
end

function ShipMgr:openShip1Deck()
	self.m_ship[1]:openDeck();
end

-- 重連进场直接playIdel
function ShipMgr:playIdle()
	self.m_ship[1]:playIdle();
	self.m_ship[2]:playIdle();
end

-- boss重连进场
function ShipMgr:playIdle1() 
	self.m_ship[1]:playIdle();
end

function ShipMgr:showFortState()
	-- print("ShipMgr:showFortState");
	self.m_ship[1]:showFortState();
	if self.m_battleType ~= 3 then
		self.m_ship[2]:showFortState();
	end
end

function ShipMgr:hideAllTarget()    -- 可点击的显示区域
	self.m_ship[1]:hideAllTarget();
	if self.m_battleType ~= 3 then
		self.m_ship[2]:hideAllTarget();
	elseif self.m_battleType == 3 then  -- boss
		self.m_ship[2]:hideTarget();
	end
end

--显示玩家存活炮台目标
function ShipMgr:showTargetPlayerFortAlive()
	self.m_ship[1]:showAliveFortTarget();
end

--显示玩家损毁炮台目标
function ShipMgr:showTargetPlayerFortDestroy()
	self.m_ship[1]:showDestroyFortTarget();
end

--显示敌方存活炮台目标
function ShipMgr:showTargetEnemyFortAlive()
	if self.m_battleType ~= 3 then
		self.m_ship[2]:showAliveFortTarget();
	elseif self.m_battleType == 3 then
		-- 显示boss的可点击区域目标特效
		self.m_ship[2]:showTarget();
	end
end

--显示玩家战舰目标（全体）
function ShipMgr:showTargetPlayerShip()
	self.m_ship[1]:showShipTarget();
end

--显示敌方战舰目标（全体）
function ShipMgr:showTargetEnemyShip()
	if self.m_battleType ~= 3 then
		self.m_ship[2]:showShipTarget();
	elseif self.m_battleType == 3 then
		-- 显示boss的可点击区域目标特效
		self.m_ship[2]:showTarget();
	end
end


--fortPos 123, isPlayer是否是ship[1]
function ShipMgr:touchFort(fortPos, isPlayer)
	--判断释放可以使用物品，如果有选中物品栏则使用物品
	local function useItemCallBack(rc, data)
		dump(data);		
		if data.code ~= 1 then
			print("Battle Use Item Error:");
			print(GameData:get("code_map")[data.code]["desc"]);
		else
			print("use item success:", itemID);
			-- local CCBattle = self.m_ccbNodeShip:getParent();
			-- CCBattle.m_ccbFileBottom:updateItemCount()
		end
	end	

	--如果选择的itemID~=0
	if BattleDataMgr:getCurSelectItemId() ~= 0 then
		--对玩家全体使用物品
		if isPlayer == true and self.m_ship[1]:isShiptargetShow() then
			self:touchShip(1); 
			return;
		end
		--对敌人全体使用物品
		if isPlayer == false and self.m_ship[2]:isShiptargetShow() then
			self:touchShip(2);
			return;
		end
		--对玩家炮台使用道具
		if isPlayer == true and self.m_ship[1]:isFortTargetShow(fortPos) then
			print("自己使用了物品", BattleDataMgr:getCurSelectItemId());
			local fortIndex = self.m_ship[1]:getFortIndexByPos(fortPos);
			local tarFortID = BattleDataMgr:getFortIDByfortPos(fortPos,1);
			local sendInfo = {type = 1, item_id = BattleDataMgr:getCurSelectItemId(), fort_id = tarFortID, target_is_enemy = 0, arg = fortIndex};
			-- newBattle.useProp(1, BattleDataMgr:getCurSelectItemId(), 1, tarFortID); --单机测试
			print(" 使用的道具ID：", BattleDataMgr:getCurSelectItemId(), "  道具目标炮台ID：", tarFortID, "   炮台序号？：", fortIndex);
			if self.m_battleType == 0 then   -- 普通战斗
				Network:request("battle.battleHandler.emitEvent", sendInfo, useItemCallBack);
			elseif self.m_battleType == 1 then   -- 探险
				Network:request("explore_battle.exploreHandler.emitEvent", sendInfo, useItemCallBack);
			elseif self.m_battleType == 2 then	  -- 抢劫贩售舰
				Network:request("loot_battle.lootHandler.emitEvent", sendInfo, useItemCallBack);
			elseif self.m_battleType == 3 then	  -- 公域混战
				Network:request("domain_battle.domainHandler.emitEvent", sendInfo, useItemCallBack);
			elseif self.m_battleType == 4 then   -- 殖民星争夺战
				-- Network:request("battle.battleHandler.emitEvent", sendInfo, useItemCallBack);
			end
			return;
		end
		--对敌人炮台使用道具
		if self.m_battleType ~= 3 then
			if isPlayer == false and self.m_ship[2]:isFortTargetShow(fortPos) then
				print("对敌人使用了物品", BattleDataMgr:getCurSelectItemId());
				local fortIndex = self.m_ship[2]:getFortIndexByPos(fortPos);
				local tarFortID = BattleDataMgr:getFortIDByfortPos(fortPos,2);
				local sendInfo = {type = 1, item_id = BattleDataMgr:getCurSelectItemId(), fort_id = tarFortID, target_is_enemy = 1, arg = fortIndex};
				-- newBattle.useProp(1, BattleDataMgr:getCurSelectItemId(), 2, tarFortID);	
				print(" 使用的道具ID： ", BattleDataMgr:getCurSelectItemId(), " 道具目标炮台ID： ", tarFortID, "   炮台序号？", fortIndex);
				if self.m_battleType == 0 then   -- 普通战斗
					Network:request("battle.battleHandler.emitEvent", sendInfo, useItemCallBack);
				elseif self.m_battleType == 1 then   -- 探险
					Network:request("explore_battle.exploreHandler.emitEvent", sendInfo, useItemCallBack);
				elseif self.m_battleType == 2 then	  -- 抢劫贩售舰
					Network:request("loot_battle.lootHandler.emitEvent", sendInfo, useItemCallBack);
				elseif self.m_battleType == 3 then	  -- 公域混战
					Network:request("domain_battle.domainHandler.emitEvent", sendInfo, useItemCallBack);
				elseif self.m_battleType == 4 then   -- 殖民星争夺战
					-- Network:request("battle.battleHandler.emitEvent", sendInfo, useItemCallBack);
				end
				return;
			end 
		end
		print("选中了物品，无法释放技能", BattleDataMgr:getCurSelectItemId(), fortPos, isPlayer);
		return;
	end

	--判断是否可以释放技能
	local function useSkillCallBack(rc, data)
		if data.code ~= 1 then
			print("Battle Use Skill Error:", pos);
			print(GameData:get("code_map")[data.code]["desc"]);
		else
			print("Battle Success Use Skill")
		end
	end	
	if isPlayer == true then
		if self.m_ship[1]:isFullSpByfortPos(fortPos) then
			--print("炮台"fortPos"号位置释放了技能");
			local fortIndex = self.m_ship[1]:getFortIndexByPos(fortPos);
			local FortID = BattleDataMgr:getFortIDByfortPos(fortPos,1);
			local sendInfo = {type = 2, fort_id = FortID, arg = fortIndex};
			print("我方",fortPos, "号位置炮台ID", FortID, " 释放了技能");

			if self.m_battleType == 0 then   -- 普通战斗
				Network:request("battle.battleHandler.emitEvent", sendInfo, useSkillCallBack);
			elseif self.m_battleType == 1 then   -- 探险
				Network:request("explore_battle.exploreHandler.emitEvent", sendInfo, useSkillCallBack);
			elseif self.m_battleType == 2 then	  -- 抢劫贩售舰
				Network:request("loot_battle.lootHandler.emitEvent", sendInfo, useSkillCallBack);
			elseif self.m_battleType == 3 then	  -- 公域混战
				Network:request("domain_battle.domainHandler.emitEvent", sendInfo, useSkillCallBack);
			elseif self.m_battleType == 4 then   -- 殖民星争夺战
				-- Network:request("battle.battleHandler.emitEvent", sendInfo, useSkillCallBack);
			end
			return;
		end
	end
	-- self.m_ship[1].m_myFort[2]:playSkill(1) -- 测试用
	-- print("点击炮台，没有使用物品，没有释放技能", fortPos);
end

-- 玩家shipPos = 1, 敌人shipPos = 2 
function ShipMgr:touchShip(shipPos)
	-- print("目标: 战舰", shipPos);
	if self.m_ship[shipPos].m_armatureTarget:isVisible() == false then
		print("使用目标不是战舰");
		return;
	end

	local function useItemCallBack(rc, data)

		if data.code ~= 1 then  -- 请求失败
			print("Battle Use Item Error");
			print(GameData:get("code_map")[data.code]["desc"]);
		else  -- 请求成功
			print("use item success");
			--取父类调用，不可直接调用CCBBottom

			-- local CCBattle = self.m_ccbNodeShip:getParent();   -- 。。。。 
			-- CCBattle.m_ccbFileBottom:updateItemCount()
		end
	end	
	local shipIndex = -1;	--自己 0; 敌人 1;
	if shipPos == 1 then
		shipIndex = 0;
	elseif shipPos == 2 then
		shipIndex = 1;
	end

	local sendInfo = {type = 1, item_id = BattleDataMgr:getCurSelectItemId(), target_is_enemy = shipIndex};
	-- print("对战舰", shipPos,"使用道具，", sendInfo.item_id, "shipIndex=", shipIndex);

	if self.m_battleType == 0 then   -- 普通战斗
		Network:request("battle.battleHandler.emitEvent", sendInfo, useItemCallBack);
	elseif self.m_battleType == 1 then   -- 探险
		Network:request("explore_battle.exploreHandler.emitEvent", sendInfo, useItemCallBack);
	elseif self.m_battleType == 2 then	  -- 抢劫贩售舰
		Network:request("loot_battle.lootHandler.emitEvent", sendInfo, useItemCallBack);
	elseif self.m_battleType == 3 then	  -- 公域混战
		Network:request("domain_battle.domainHandler.emitEvent", sendInfo, useItemCallBack);
	elseif self.m_battleType == 4 then   -- 殖民星争夺战
		-- Network:request("battle.battleHandler.emitEvent", sendInfo, useItemCallBack);
	end
end



-- 服务器传回1~8（1~6是炮台）, 位置转换
-- function ShipMgr:getFortPosByIndex(fortIndex)
-- 	print("ShipMgr:getFortPosByIndex", fortIndex);	
-- 	local fortPos = self.m_ship[1]:getFortPosByIndex(fortIndex);
-- 	if fortPos then
-- 		print("return ship 1 fort", fortPos);
-- 		return fortPos; -- 1,2,3
-- 	end 
-- 	fortPos = self.m_ship[2]:getFortPosByIndex(fortIndex);
-- 	if fortPos then
-- 		print("return ship 2 fort", fortPos);
-- 		return fortPos; --4,5,6
-- 	end
-- end

-- function ShipMgr:getShipPosByIndex(shipIndex)
-- 	print("ShipMgr:getShipPosByIndex", shipIndex);
-- 	if shipIndex == self.m_ship[1].m_shipIndex then
-- 		return 7;
-- 	elseif shipIndex == self.m_ship[2].m_shipIndex then
-- 		return 8;
-- 	else
-- 		print("ShipMgr Error: shipIndex is wrong", shipIndex);
-- 	end
-- end

--分别调用各自接口
function ShipMgr:refresh()
	self.m_ship[1]:updatePlayerFort();
	self.m_ship[2]:updateEnemyFort();

	self:handlePlayerFortEvent();
	self:handleEnemyFortEvent();

	self:updatePlayerFortBuff()
	self:updateEnemyFortBuff()
end
-- boss战斗
function ShipMgr:bossBattleRefresh()
	self.m_ship[1]:updatePlayerFort();
	self:handlePlayerFortEvent();
	self:handleBossEvent();
	self:updatePlayerFortBuff();
end

function ShipMgr:addNumberTips(str, kind, pos, side)
	local showNumberTips = NumberTips:create(str, kind, side);
	self.m_ccbNodeCloud:addChild(showNumberTips);
	local randomNumberX = math.random(-40, 40);
	local randomNumberY = math.random(-20, 20);
	showNumberTips:setPosition(cc.p(pos.x + randomNumberX, pos.y + randomNumberY));
end

--玩家炮台事件（技能血量...）
function ShipMgr:handlePlayerFortEvent()
	-- if self.m_testCount == 0 then
	-- 	self.m_testCount = self.m_testCount + 1;
	-- 	local testNumberTips = NumberTips:create("12346", 1); 
	-- 	testNumberTips:setPosition(FORTS_POSITION[1]);
	-- 	self.m_ccbNodeShip:addChild(testNumberTips);
	-- end
	local playerFortEvents = newBattle.playerFortEvent();
	-- dump(playerFortEvents)
	-- "<var>" = {
	--     1 = {
	--         1 = 0
	--     }
	--     2 = {
	--         1  = 0
	--         11 = 2.4891389315482
	--         12 = 2.5196264429568
	--         13 = 2392.528859136
	--     }
	--     3 = {
	--         1  = 0
	--         11 = 2.4891389315482
	--         12 = 2.5196264429568
	--         13 = 2392.528859136
	--     }
	--		cleanGoodBuff = 2,
	--		cleanBadBuff = 1
	-- }
	if playerFortEvents["cleanGoodBuff"] ~= nil then 	--播放特效(暂时无动画)

	end

	if playerFortEvents["cleanBadBuff"] ~= nil then
		self:createBuffTip(FORT_EVENT_CLEAN_BAD_BUFF, FORTS_POSITION[2], 1);
	end

	for i = 1, 3 do
		if playerFortEvents[i][FORT_FIRE] ~= nil then 		--炮台开火
			self.m_ship[1].m_myFort[i]:playFire()
			
		end
		if playerFortEvents[i][FORT_SKILL] ~= nil then 		--炮台技能
			print("playerFortEvents[i][FORT_SKILL]", playerFortEvents[i][FORT_SKILL]);
			self.m_ship[1].m_myFort[i]:playSkill(playerFortEvents[i][FORT_SKILL])
		end

		if playerFortEvents[i][FORT_RELIVE_COOLDOWN] ~= nil then
			print("炮台复活倒计时")
			self.m_ship[1].m_myFort[i].m_ccbState:showRecoverCountTime();
		end

		if playerFortEvents[i][FORT_RELIVE] ~= nil then
			print("炮台复活")
			self.m_ship[1].m_myFort[i]:setVisible(true);
			-- self.m_ship[1].m_myFort[i]:playStart();
			self:createBuffTip(FORT_RELIVE, FORTS_POSITION[i], 1);
		end


		if playerFortEvents[i][FORT_ENERGY_ADD_HP] ~= nil then

			local addHpNumber = Utils:round(playerFortEvents[i][FORT_ENERGY_ADD_HP]);
			self:addNumberTips("+" .. tostring(addHpNumber), 1, FORTS_POSITION[i], 1);
			self:createBuffTip(2, FORTS_POSITION[i], 1);
		end

		if playerFortEvents[i][FORT_PROP_ADD_HP] ~= nil then
			local addHpNumber = Utils:round(playerFortEvents[i][FORT_PROP_ADD_HP]);
			self:addNumberTips("+" .. tostring(addHpNumber), 1, FORTS_POSITION[i], 1);
			self:createBuffTip(2, FORTS_POSITION[i], 1);
		end

		if playerFortEvents[i][FORT_CONTINUE_ADD_HP] ~= nil then
			local addHpNumber = Utils:round(playerFortEvents[i][FORT_CONTINUE_ADD_HP]);
			self:addNumberTips("+" .. tostring(addHpNumber), 1, FORTS_POSITION[i], 1);
		end

		if playerFortEvents[i][FORT_SKILL_ADD_HP] ~= nil then
			local addHpNumber = Utils:round(playerFortEvents[i][FORT_SKILL_ADD_HP]);
			self:addNumberTips("+" .. tostring(addHpNumber), 1, FORTS_POSITION[i], 1);
			self:createBuffTip(2, FORTS_POSITION[i], 1);
		end

		if playerFortEvents[i][FORT_SELF_ADD_ENERGY] ~= nil then
			-- local addEnergyNumber = Utils:round(playerFortEvents[i][FORT_SELF_ADD_ENERGY]);
			-- self:addNumberTips(tostring(addEnergyNumber), 2, FORTS_POSITION[i]);
		end

		if playerFortEvents[i][FORT_ENERGY_ADD_ENERGY] ~= nil then
			local addEnergyNumber = Utils:round(playerFortEvents[i][FORT_ENERGY_ADD_ENERGY]);
			self:addNumberTips("+" .. tostring(addEnergyNumber), 2, FORTS_POSITION[i], 1);
			self:createBuffTip(13, FORTS_POSITION[i], 1);
		end

		if playerFortEvents[i][FORT_PROP_ADD_ENERGY] ~= nil then
			local addEnergyNumber = Utils:round(playerFortEvents[i][FORT_PROP_ADD_ENERGY]);
			self:addNumberTips("+" .. tostring(addEnergyNumber), 2, FORTS_POSITION[i], 1);
			self:createBuffTip(13, FORTS_POSITION[i], 1);
		end

		if playerFortEvents[i][FORT_ATTACK_ADD_ENERGY] ~= nil then
			-- local addEnergyNumber = Utils:round(playerFortEvents[i][FORT_ATTACK_ADD_ENERGY]);
			-- self:addNumberTips(tostring(addEnergyNumber), 2, FORTS_POSITION[i]);
		end

		if playerFortEvents[i][FORT_BE_DAMAGE_ADD_ENERGY] ~= nil then
			-- local addEnergyNumber = Utils:round(playerFortEvents[i][FORT_BE_DAMAGE_ADD_ENERGY]);
			-- self:addNumberTips(tostring(addEnergyNumber), 2, FORTS_POSITION[i])
		end

		if playerFortEvents[i][FORT_BULLET_DAMAGE] ~= nil then
			local addDamageNumber = Utils:round(playerFortEvents[i][FORT_BULLET_DAMAGE]);
			self:addNumberTips(tostring(addDamageNumber), 3, FORTS_POSITION[i], 1);
		end

		if playerFortEvents[i][FORT_PROP_BULLET_DAMAGE] ~= nil then
			local addDamageNumber = Utils:round(playerFortEvents[i][FORT_PROP_BULLET_DAMAGE]);
			self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[i], 1);
			-- Audio:playEffect(106, false);
		end

		if playerFortEvents[i][FORT_BUFF_BURN_DAMAGE] ~= nil then
			local addDamageNumber = Utils:round(playerFortEvents[i][FORT_BUFF_BURN_DAMAGE]);
			self:addNumberTips(tostring(addDamageNumber), 3, FORTS_POSITION[i], 1);
		end

		if playerFortEvents[i][FORT_NPC_DAMAGE] ~= nil then
			local addDamageNumber = Utils:round(playerFortEvents[i][FORT_NPC_DAMAGE]);
			self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[i], 1);

		end

		if playerFortEvents[i][FORT_SKILL_DAMAGE] ~= nil then
			local addDamageNumber = Utils:round(playerFortEvents[i][FORT_SKILL_DAMAGE]);
			self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[i], 1);
		end

		if playerFortEvents[i][FORT_BE_DEEP_DAMAGE] ~= nil then
			local addDamageNumber = Utils:round(playerFortEvents[i][FORT_BE_DEEP_DAMAGE]);
			self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[i], 1);
			self:createBuffTip(FORT_BE_DEEP_DAMAGE, FORTS_POSITION[i], 1);
		end

		if playerFortEvents[i][FORT_SHIP_SKILL_ADD_HP] ~= nil then
			local addHpNumber = Utils:round(playerFortEvents[i][FORT_SHIP_SKILL_ADD_HP]);
			self:addNumberTips("+" .. tostring(addHpNumber), 1, FORTS_POSITION[i], 1);
			self:createBuffTip(2, FORTS_POSITION[i], 1);
		end

		if playerFortEvents[i][FORT_SHIP_SKILL_ADD_ENERGY] ~= nil then 
			local addEnergyNumber = Utils:round(playerFortEvents[i][FORT_SHIP_SKILL_ADD_ENERGY]);
			self:addNumberTips("+" .. tostring(addEnergyNumber), 2, FORTS_POSITION[i], 1);
			self:createBuffTip(13, FORTS_POSITION[i], 1);
		end

		if playerFortEvents[i][FORT_SHIP_SKILL_DAMAGE] ~= nil then
			local addDamageNumber = Utils:round(playerFortEvents[i][FORT_SHIP_SKILL_DAMAGE]);
			self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[i], 1);
		end

		-- if playerFortEvents[i][FORT_DIE] ~= nil then
		-- 	self.m_ship[1].m_myFort[i]:changeToDestroyState();
		-- end

	end
end

--敌方炮台事件
function ShipMgr:handleEnemyFortEvent()
	local enemyFortEvents = newBattle.enemyFortEvent();
	-- dump(enemyFortEvents)
	if enemyFortEvents["cleanGoodBuff"] ~= nil then 	--播放特效

	end
	if enemyFortEvents["cleanBadBuff"] ~= nil then
		self:createBuffTip(FORT_EVENT_CLEAN_BAD_BUFF, FORTS_POSITION[4], 2);
	end
	for i = 1, 3 do
		if enemyFortEvents[i][FORT_FIRE] ~= nil then 	
			self.m_ship[2].m_enemyFort[i]:playFire()
		end
		if enemyFortEvents[i][FORT_SKILL] ~= nil then
			self.m_ship[2].m_enemyFort[i]:playSkill(enemyFortEvents[i][FORT_SKILL])
		end

		if enemyFortEvents[i][FORT_RELIVE_COOLDOWN] ~= nil then
			print("炮台复活倒计时")
			self.m_ship[2].m_enemyFort[i].m_ccbState:showRecoverCountTime();
		end

		if enemyFortEvents[i][FORT_RELIVE] ~= nil then
			print("炮台复活")
			self.m_ship[2].m_enemyFort[i]:setVisible(true);
			-- self.m_ship[1].m_myFort[i]:playStart();
			self:createBuffTip(FORT_RELIVE, FORTS_POSITION[3 + i], 2);
		end

		if enemyFortEvents[i][FORT_ENERGY_ADD_HP] ~= nil then
			local addHpNumber = Utils:round(enemyFortEvents[i][FORT_ENERGY_ADD_HP]);
			self:addNumberTips("+" .. tostring(addHpNumber), 1, FORTS_POSITION[3 + i], 2);
			self:createBuffTip(2, FORTS_POSITION[3 + i], 2);
		end

		if enemyFortEvents[i][FORT_PROP_ADD_HP] ~= nil then
			local addHpNumber = Utils:round(enemyFortEvents[i][FORT_PROP_ADD_HP]);
			self:addNumberTips("+" .. tostring(addHpNumber), 1, FORTS_POSITION[3 + i], 2);
			self:createBuffTip(2, FORTS_POSITION[3 + i], 2);
		end

		if enemyFortEvents[i][FORT_CONTINUE_ADD_HP] ~= nil then
			local addHpNumber = Utils:round(enemyFortEvents[i][FORT_CONTINUE_ADD_HP]);
			self:addNumberTips("+" .. tostring(addHpNumber), 1, FORTS_POSITION[3 + i], 2);
		end

		if enemyFortEvents[i][FORT_SKILL_ADD_HP] ~= nil then
			local addHpNumber = Utils:round(enemyFortEvents[i][FORT_SKILL_ADD_HP]);
			self:addNumberTips("+" .. tostring(addHpNumber), 1, FORTS_POSITION[3 + i], 2);
			self:createBuffTip(2, FORTS_POSITION[3 + i], 2);
		end

		if enemyFortEvents[i][FORT_SELF_ADD_ENERGY] ~= nil then
			-- local addEnergyNumber = Utils:round(enemyFortEvents[i][FORT_SELF_ADD_ENERGY]);
			-- self:addNumberTips(tostring(addEnergyNumber), 2, FORTS_POSITION[3 + i]);
		end

		if enemyFortEvents[i][FORT_ENERGY_ADD_ENERGY] ~= nil then
			local addEnergyNumber = Utils:round(enemyFortEvents[i][FORT_ENERGY_ADD_ENERGY]);
			self:addNumberTips("+" .. tostring(addEnergyNumber), 2, FORTS_POSITION[3 + i], 2);
			self:createBuffTip(13, FORTS_POSITION[3 + i], 2);
		end

		if enemyFortEvents[i][FORT_PROP_ADD_ENERGY] ~= nil then
			local addEnergyNumber = Utils:round(enemyFortEvents[i][FORT_PROP_ADD_ENERGY]);
			self:addNumberTips("+" .. tostring(addEnergyNumber), 2, FORTS_POSITION[3 + i], 2);
			self:createBuffTip(13, FORTS_POSITION[3 + i], 2);
		end

		if enemyFortEvents[i][FORT_ATTACK_ADD_ENERGY] ~= nil then
			-- local addEnergyNumber = Utils:round(enemyFortEvents[i][FORT_ATTACK_ADD_ENERGY]);
			-- self:addNumberTips(tostring(addEnergyNumber), 2, FORTS_POSITION[3 + i]);
		end

		if enemyFortEvents[i][FORT_BE_DAMAGE_ADD_ENERGY] ~= nil then
			-- local addEnergyNumber = Utils:round(enemyFortEvents[i][FORT_BE_DAMAGE_ADD_ENERGY]);
			-- self:addNumberTips(tostring(addEnergyNumber), 2, FORTS_POSITION[3 + i])
		end

		if enemyFortEvents[i][FORT_BULLET_DAMAGE] ~= nil then
			local addDamageNumber = Utils:round(enemyFortEvents[i][FORT_BULLET_DAMAGE]);
			self:addNumberTips(tostring(addDamageNumber), 3, FORTS_POSITION[3 + i], 2);
		end

		if enemyFortEvents[i][FORT_PROP_BULLET_DAMAGE] ~= nil then
			local addDamageNumber = Utils:round(enemyFortEvents[i][FORT_PROP_BULLET_DAMAGE]);
			self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[3 + i], 2);
			-- Audio:playEffect(106, false);
		end

		if enemyFortEvents[i][FORT_BUFF_BURN_DAMAGE] ~= nil then
			local addDamageNumber = Utils:round(enemyFortEvents[i][FORT_BUFF_BURN_DAMAGE]);
			self:addNumberTips(tostring(addDamageNumber), 3, FORTS_POSITION[3 + i], 2);
		end

		if enemyFortEvents[i][FORT_NPC_DAMAGE] ~= nil then
			local addDamageNumber = Utils:round(enemyFortEvents[i][FORT_NPC_DAMAGE]);
			self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[3 + i], 2);
		end

		if enemyFortEvents[i][FORT_SKILL_DAMAGE] ~= nil then
			local addDamageNumber = Utils:round(enemyFortEvents[i][FORT_SKILL_DAMAGE]);
			self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[3 + i], 2);
		end

		if enemyFortEvents[i][FORT_BE_DEEP_DAMAGE] ~= nil then
			local addDamageNumber = Utils:round(enemyFortEvents[i][FORT_BE_DEEP_DAMAGE]);
			self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[3 + i], 2);
			self:createBuffTip(FORT_BE_DEEP_DAMAGE, FORTS_POSITION[3 + i], 2);
		end

		if enemyFortEvents[i][FORT_SHIP_SKILL_ADD_HP] ~= nil then
			local addHpNumber = Utils:round(enemyFortEvents[i][FORT_SHIP_SKILL_ADD_HP]);
			self:addNumberTips("+" .. tostring(addHpNumber), 1, FORTS_POSITION[3 + i], 2);
			self:createBuffTip(2, FORTS_POSITION[3 + i], 2);
		end

		if enemyFortEvents[i][FORT_SHIP_SKILL_ADD_ENERGY] ~= nil then
			local addEnergyNumber = Utils:round(enemyFortEvents[i][FORT_SHIP_SKILL_ADD_ENERGY]);
			self:addNumberTips("+" .. tostring(addEnergyNumber), 2, FORTS_POSITION[3 + i], 2);
			self:createBuffTip(13, FORTS_POSITION[3 + i], 2);
		end

		if enemyFortEvents[i][FORT_SHIP_SKILL_DAMAGE] ~= nil then
			local addDamageNumber = Utils:round(enemyFortEvents[i][FORT_SHIP_SKILL_DAMAGE]);
			self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[3 + i], 2);
		end

		-- if enemyFortEvents[i][FORT_DIE] ~= nil then
		-- 	self.m_ship[2].m_enemyFort[i]:changeToDestroyState();
		-- end
	end
end

function ShipMgr:handleBossEvent()
	local bossEvent = newBattle.bossEvent();
	-- dump(bossEvent);
	if bossEvent[BOSS_CHANGE_STAGE_OVER] ~= nil then
		self.m_ship[2]:bossChangeOver();
		self.m_ccbBattle:setBottomBtnUse();
	end

	if bossEvent[BOSS_FIRE] ~= nil then   -- boss fire
		self.m_ship[2]:bossFire();
	end
	if bossEvent[BOSS_SKILL_BEGIN] ~= nil then   -- boss技能
		self.m_ship[2]:bossSkillFire();
	end
	if bossEvent[BOSS_SKILL_FIRE] ~= nil then  -- boss技能爆炸

	end
	if bossEvent[BOSS_CALL_NPC_SKILL] ~= nil then  -- boss召唤npc (需要选择npc型号)
		self.m_ship[2]:bossNpc(bossEvent[BOSS_CALL_NPC_SKILL] + 1);
	end
	if bossEvent[BOSS_CALL_NPC_BACK] ~= nil then  -- boss召唤npc返回
		self.m_ship[2]:bossNpcBack();
	end
	if bossEvent[BOSS_BE_DAMAGE_BY_BULLET] ~= nil then
		local addDamageNumber = Utils:round(bossEvent[BOSS_BE_DAMAGE_BY_BULLET]);
		self:addNumberTips(tostring(addDamageNumber), 3, FORTS_POSITION[5], 2);
	end
	if bossEvent[BOSS_BE_DAMAGE_BY_FORT_SKILL] ~= nil then
		local addDamageNumber = Utils:round(bossEvent[BOSS_BE_DAMAGE_BY_FORT_SKILL]);
		self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[5], 2);
	end
	if bossEvent[BOSS_BE_DAMAGE_BY_NPC] ~= nil then
		local addDamageNumber = Utils:round(bossEvent[BOSS_BE_DAMAGE_BY_NPC]);
		self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[5], 2);
	end
	if bossEvent[BOSS_BE_DAMAGE_BY_PROP] ~= nil then
		local addDamageNumber = Utils:round(bossEvent[BOSS_BE_DAMAGE_BY_PROP]);
		self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[5], 2);
	end
	if bossEvent[BOSS_BE_DAMAGE_BY_SHIP_SKILL] ~= nil then
		local addDamageNumber = Utils:round(bossEvent[BOSS_BE_DAMAGE_BY_SHIP_SKILL]);
		self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[5], 2);
	end
	if bossEvent[BOSS_CHANGE_STAGE_ONE] ~= nil then
		self.m_ship[2]:bossChangeStage();
		self.m_ccbBattle:setBottomBtnUnuse();
	end
	if bossEvent[BOSS_CHANGE_STAGE_TWO] ~= nil then
		self.m_ship[2]:bossChangeStage();
		self.m_ccbBattle:setBottomBtnUnuse();
	end
	if bossEvent[BOSS_BE_DEEP_DAMAGE_BY_FORT_SKILL] ~= nil then
		print(" ！！！！！！！！！！  额外  伤害   boss的")
		local addDamageNumber = Utils:round(bossEvent[BOSS_BE_DEEP_DAMAGE_BY_FORT_SKILL]);
		self:addNumberTips(tostring(addDamageNumber), 4, FORTS_POSITION[5], 2);
		self:createBuffTip(FORT_BE_DEEP_DAMAGE, FORTS_POSITION[5], 2);
	end
end

--更新玩家炮台buff
function ShipMgr:updatePlayerFortBuff()
	local playerBuff = newBattle.playerBuffEvent()
	-- "<var>" = {
	--     1 = {
	--         1 = 90005
	--     }
	--     2 = {
	--         1 = 90006
	--     }
	-- }
	for k,v in pairs(playerBuff) do
		-- dump(playerBuff)
		for k1,v1 in pairs(v) do
			-- print(k1,v1)
			if v1 == 0 then
				for i = 1, 3 do
					self.m_ship[1].m_myFort[i]:updateFortBuff(k1);
				end
				if k1 == 11 then
					-- 设置反导弹
					self.m_ccbBattle.m_ccbFileBottom:showUnmissileState();
				elseif k1 == 31 then
					-- 取消反导弹
					self.m_ccbBattle.m_ccbFileBottom:removeUnmissileState();
				end
			else
				local fortPos = BattleDataMgr:getFortPosByFortID(v1, 1)
				self.m_ship[1].m_myFort[fortPos]:updateFortBuff(k1)
			end
		end
	end
end

--更新敌方炮台buff
function ShipMgr:updateEnemyFortBuff()
	local enemyBuff = newBattle.enemyBuffEvent()
	for k,v in pairs(enemyBuff) do
		-- dump(enemyBuff)
		for k1,v1 in pairs(v) do
			if v1 == 0 then
				for i = 1, 3 do
					self.m_ship[2].m_enemyFort[i]:updateFortBuff(k1);
				end
			else
				local fortPos = BattleDataMgr:getFortPosByFortID(v1, 2)
				self.m_ship[2].m_enemyFort[fortPos]:updateFortBuff(k1)
			end
		end
	end
end

function ShipMgr:showWin()
	print("ShipMgr:showWin")
	self.m_ship[2]:playDestroy();
end

function ShipMgr:showLose()
	print("ShipMgr:showLose");
	self.m_ship[1]:playDestroy();
end

function ShipMgr:bossEnterBattle()
	self.m_ship[2]:shipEnterBattle();
end

function ShipMgr:createBuffTip(buffID, pos, ship)
	local buffTip = BuffWordTips:create(buffID);
	if ship == 1 then
		buffTip:setPosition(pos.x + 50, pos.y);
	else
		buffTip:setPosition(pos.x - 50, pos.y);
	end
	self.m_ccbNodeCloud:addChild(buffTip);
end

return ShipMgr