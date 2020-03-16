local BattleResourceMgr = require("app.utils.BattleResourceMgr");
local CCBFortState = import(".CCBFortState");
local Tips = require("app.views.common.Tips");
local BuffWordTips = require("app.views.common.BuffWordTips");

local CFort = class("CFort", cc.Node)

local Left_X = -(1280*0.5-150);
local Right_X = 1280*0.5-150;

local FORTS_POSITION = {[1] = cc.p(Left_X,180),[2] = cc.p(Left_X,40), [3] = cc.p(Left_X,-100),
						[4] = cc.p(Right_X,180), [5] = cc.p(Right_X,40), [6] = cc.p(Right_X,-100)}

local ACK_UP_BUFF_ADD = 1 --火力增幅
local REPAIRING_BUFF_ADD = 2 --持续维护
local SHIELD_BUFF_ADD = 3	--附加护盾
local PASSIVE_SKILL_STRONGER_BUFF_ADD = 4 --被动强化
local PARALYSIS_BUFF_ADD = 5	--瘫痪
local BURNING_BUFF_ADD = 6		--燃烧状态
local ACK_DOWN_BUFF_ADD = 7 	--火力干扰
local REPAIR_DISTURB_BUFF_ADD = 8 --维修干扰
local ENERGY_DISTURB_BUFF_ADD = 9 --能量体干扰
local BREAK_ARMOR_BUFF_ADD = 10		--破甲状态
local UNMISSILE_BUFF_ADD = 11		--反导弹状态

local ACK_UP_BUFF_DELETE = 21 --火力增幅结束
local REPAIRING_BUFF_DELETE = 22 --持续维护结束
local SHIELD_BUFF_DELETE = 23	--附加护盾结束
local PASSIVE_SKILL_STRONGER_BUFF_DELETE = 24 --被动强化结束
local PARALYSIS_BUFF_DELETE = 25	--瘫痪结束
local BURNING_BUFF_DELETE = 26		--燃烧状态结束
local ACK_DOWN_BUFF_DELETE = 27 	--火力干扰结束
local REPAIR_DISTURB_BUFF_DELETE = 28 --维修干扰结束
local ENERGY_DISTURB_BUFF_DELETE = 29 --能量体干扰结束
local BREAK_ARMOR_BUFF_DELETE = 30		--破甲状态结束
local UNMISSILE_BUFF_DELETE = 31		--反导弹状态结束


function CFort:ctor(fortID, shipPos, fortPos)
	-- print("fortID, shipPos, fortPos", fortID, shipPos, fortPos)
	print("  加载炮台  的时间  ", os.time());
	
	self.m_buffCount = 0;

	self.m_fortID = fortID;		--炮台ID
	self.m_shipPos = shipPos;	--哪边战舰， 1为左边，2为右边
	self.m_fortPos = fortPos;	--fort的位置 1,2,3
	self.m_baseInfo = FortDataMgr:getFortBaseInfo(fortID);	--炮台基本数据
	self.m_skillData = FortDataMgr:getSkillInfoByFortID(fortID);	--炮台技能基本数据

	self.m_isEscortLootBattle = false;

	if shipPos == 2 then
		self:setScaleX(-1);
	end

	--炮台初始状态
	self.m_HPMAX = self.m_baseInfo.hp;
	self.m_SPMAX = self.m_baseInfo.energy;	
	self.m_curHP = self.m_HPMAX;
	self.m_curSP = 0;
	self.m_alive = true;
	self.m_isFullSP = false;


	--炮台血量条、能量条和复活提示UI
	self.m_ccbState = CCBFortState:create(self.m_fortID, self.m_shipPos);
	self:addChild(self.m_ccbState);
	self.m_ccbState:setPosition(cc.p(-75, 0));
	self.m_ccbState:updateHP(1);
	self.m_ccbState:updateSP(0);
	self.m_ccbState:setVisible(false);

	--炮台动画
	self.m_armatureFort = BattleResourceMgr:getFortArmatureByFortID(fortID);
	self:addChild(self.m_armatureFort);
	-- self.m_armatureFort:setScale(0.8);
	self:playIdle();
	self.m_armatureFort:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			self:movementEventComplete(movementID);
		end
	end)

	-- buff分为buff图标和显示在炮台上的特效
	self.m_buffs = {};	
	-- buff图标
	self.m_nodeBuff = cc.Node:create();
	self:addChild(self.m_nodeBuff);
	if self.m_shipPos == 1 then
		-- print("buff图标不翻转");
		self.m_nodeBuff:setPosition(cc.p(-130, -50));--左右两边炮台的buff图标显示位置不一样
	else
		-- print("buff图标翻转");
		self.m_nodeBuff:setPosition(cc.p(-130,-50));
		-- self.m_nodeBuff:setScaleX(-1);
	end

	--炮台上的buff特效
	self.m_armatureBuff = {};

	--损毁动画
	self.m_armatureDestroy = BattleResourceMgr:getFortDestroyArmature();
	self:addChild(self.m_armatureDestroy);
	self.m_armatureDestroy:setVisible(false);
	self.m_armatureDestroy:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			if movementID == "start" then
				local index = math.random(1, 3);
				self.m_armatureDestroy:getAnimation():play("destroy" .. index);		
			end
		end
	end)

	--点击的区域特效
	if self.m_shipPos == 1 then
		self.m_armatureTarget = BattleResourceMgr:getTargetFortPlayer();
	else
		self.m_armatureTarget = BattleResourceMgr:getTargetFortEnemy();
	end
	self:addChild(self.m_armatureTarget, 10, 10);
	self.m_armatureTarget:setVisible(false);

	BattleResourceMgr:getSkill(self.m_baseInfo.skill_id);
	BattleResourceMgr:getNormalHitEffect();

	self.m_openFort = 0;
end

function CFort:setEffectSkill(ccbNodeEffectSkill)
	-- print("CFort:setEffectSkill")
	self.m_ccbNodeEffectSkill = ccbNodeEffectSkill;
end

function CFort:setCloudNode(ccbNodeCloud)
	self.m_ccbNodeCloud = ccbNodeCloud;
end

function CFort:setLootBattle()
	self.m_isEscortLootBattle = true;
end

function CFort:hideState()
	self.m_ccbState:setVisible(false);
end

function CFort:showState()
	self.m_ccbState:setVisible(true);
end

--炮台损毁
function CFort:changeToDestroyState()
	if self.m_shipPos == 1 then
		Audio:playEffect(108, false);
	end
	self.m_armatureFort:setVisible(false);
	self.m_armatureDestroy:setVisible(true);
	self.m_armatureDestroy:getAnimation():play("start");
end

--炮台存活
function CFort:changeToAliveState()
	self.m_armatureFort:setVisible(true);
	self.m_armatureDestroy:setVisible(false);
end

--战斗开始时每帧调用(炮台刷新)
function CFort:updatePlayerFortInfo(fortPos)-- 玩家炮台数据每帧刷新
	-- print("玩家的炮台位置", fortPos)
	local playertFortInfo = newBattle.playerFortData()
	-- dump(playertFortInfo)
	-- "<var>" = {
	--     1 = {
	--         "buffs" = {
	--         }
	--         "bulletID"  = 90001
	--         "energy"    = 16.038849512425
	--         "fortID"    = 90001
	--         "fortIndex" = 0
	--         "hp"        = 1164.1128757527
	--         "is_live"   = true
	--         "maxEnergy" = 100
	--         "maxHp"     = 1552.608
	--         "x"         = 150
	--         "y"         = 540
	--     }
	--     2 = {
	--         "buffs" = {
	--         }
	--         "bulletID"  = 90002
	--         "energy"    = 6.4122885170036
	--         "fortID"    = 90002
	--         "fortIndex" = 1
	--         "hp"        = 2464.7948299636
	--         "is_live"   = true
	--         "maxEnergy" = 100
	--         "maxHp"     = 2587.68
	--         "x"         = 150
	--         "y"         = 400
	--     }
	--     3 = {
	--         "buffs" = {
	--         }
	--         "bulletID"  = 90003
	--         "energy"    = 14.815538449967
	--         "fortID"    = 90003
	--         "fortIndex" = 2
	--         "hp"        = 1569.7355003345
	--         "is_live"   = true
	--         "maxEnergy" = 100
	--         "maxHp"     = 1725.12
	--         "x"         = 150
	--         "y"         = 260
	--     }
	-- }
	--血条变化
	if self.m_curHP ~= playertFortInfo[fortPos].hp*1000 then 
		self.m_curHP = playertFortInfo[fortPos].hp*1000;
		self:setHP(playertFortInfo[fortPos].hp / playertFortInfo[fortPos].maxHp);
	end

	--能量条变化
	if self.m_curSP ~= playertFortInfo[fortPos].energy then
		self:setSP(playertFortInfo[fortPos].energy / playertFortInfo[fortPos].maxEnergy)
	end
end

function CFort:updataEnemyFortInfo(fortPos) --敌人炮台数据每帧刷新
	local enemyFortInfo = newBattle.enemyFortData()
	--血条变化
	if self.m_curHP ~= enemyFortInfo[fortPos].hp then 
		self.m_curHP = enemyFortInfo[fortPos].hp;
		self:setHP(enemyFortInfo[fortPos].hp / enemyFortInfo[fortPos].maxHp);
	end

	--能量条变化
	if self.m_curSP ~= enemyFortInfo[fortPos].energy then
		self:setSP(enemyFortInfo[fortPos].energy / enemyFortInfo[fortPos].maxEnergy)
	end
end

--更新玩家buff状态
function CFort:updateFortBuff(buffNum)
	if self.m_buffs[buffNum] == nil then
		if buffNum < 20 then
			self.m_buffs[buffNum] = buffNum;
			self:addBuffIcon(buffNum);
			self:addEffect(buffNum);
			self:addBuffWordTip(buffNum);
		else
			self:cleanBuff(buffNum-20);
		end	
	else
		self:addBuffWordTip(buffNum);
	end
end

function CFort:setHP(percent)
	if percent <= 0 then
		if self.m_alive == true then -- HP第一次为0时，播放损毁动画，状态显示为修复状态
			self:changeToDestroyState();
		end
		self.m_alive = false;
	else 
		if self.m_alive == false then -- HP第一次不为0时，则显示炮台复活
			self:changeToAliveState();
		end
		self.m_alive = true;
	end

	if self.m_ccbState then
		self.m_ccbState:updateHP(percent);
	end
end

function CFort:setSP(percent)
	-- print("能量的百分比", percent)
	if percent == 1 then
		-- if self.m_isFullSP == false then -- SP第一次为1时，播放能量满提示动画（现在写在CCBFortState里）

		-- end
		self.m_isFullSP = true;
	else
		self.m_isFullSP = false;
	end
	if self.m_ccbState then
		self.m_ccbState:updateSP(percent);
	end
end

function CFort:isAlive()
	return self.m_alive;
end

function CFort:isFullSp()
	return self.m_isFullSP;
end

--炮台动画完成一次播放的事件
function CFort:movementEventComplete(movementID)
	if movementID == "skill_start" then
		self.m_armatureFort:getAnimation():play("skill_fire");
	elseif movementID == "start" then
		if self.m_isEscortLootBattle then
			return;
		end
		-- 战斗开始，炮台展开结束（给服务器发送ready ok消息）
		-- print(" 炮台 展开动画 结束 ，请求准备完毕 ", BattleDataMgr.m_isBattleExist, " ", BattleDataMgr:getBattleType());
		if BattleDataMgr:getBattleType() ~= 3 then
			if not BattleDataMgr.m_isBattleExist then
				if not BattleDataMgr.m_isSendReadyOver then
					-- print("  ...  ", BattleDataMgr:getBattleType());
					BattleDataMgr.m_isSendReadyOver = true;
					if BattleDataMgr:getBattleType() == 0 then   -- 普通战斗
						Network:request("battle.battleHandler.ready_over", nil, function(rc, data)
							-- dump(data);
							if data.code ~= 1 then
								Tips:create(GameData:get("code_map")[data.code]["desc"]);
							end
						end);
					elseif BattleDataMgr:getBattleType() == 1 then  -- 探险
						Network:request("explore_battle.exploreHandler.ready_over", nil, function(rc, data)
							if data.code ~= 1 then
								Tips:create(GameData:get("code_map")[data.code]["desc"]);
							end
						end)
					elseif BattleDataMgr:getBattleType() == 2 then  -- 打劫
						Network:request("loot_battle.lootHandler.ready_over", nil, function(rc, data)
							if data.code ~= 1 then
								Tips:create(GameData:get("code_map")[data.code]["desc"]);
							end
						end)
					elseif BattleDataMgr:getBattleType() == 3 then   -- 公寓混战
						Network:request("domain_battle.domainHandler.ready_over", nil, function(rc, data)
							if data.code ~= 1 then
								Tips:create(GameData:get("code_map")[data.code]["desc"]);
							end
						end);
					elseif BattleDataMgr:getBattleType() == 4 then
						--  colony_battle.colonyHandler.ready_over

					end
				end
			end
		end
	end
end

-- 炮台展开动画（一开始）
function CFort:playStart()
	if self.m_armatureFort then
		self.m_armatureFort:getAnimation():play("start");
	end
end

function CFort:playFire()
	-- print("炮台开火动画")
	if self.m_armatureFort then
		-- print("开火动画存在")
		if self.m_alive then
			-- print("炮台存活")
			if self.m_shipPos == 1 then
				Audio:playEffect(self.m_fortID, false);
			end
			self.m_armatureFort:getAnimation():play("fire");
		else
			-- 正常情况不会出现，如有出现则需要检查客户的battleShare和服务器的battleShare逻辑是否一致
			print("Error: " .. self.m_fortID .. " 该炮台已损坏");
		end		
	end
end

--炮台播放技能
function CFort:playSkill(target)
	if self.m_armatureFort then
		local fortPos;
		local targetPos;
		local pos1;
		local pos2;
		local pos3;

		if self.m_shipPos == 1 then	
			fortPos = FORTS_POSITION[self.m_fortPos];
			if target == -1 then
				if BattleDataMgr:getBattleType() ~= 3 then
					targetPos = 0;
				elseif BattleDataMgr:getBattleType() == 3 then
					targetPos = cc.p(FORTS_POSITION[self.m_fortPos + 3].x - 25, FORTS_POSITION[self.m_fortPos + 3].y);

				end
			else
				targetPos = FORTS_POSITION[target+4];
			end
			pos1 = FORTS_POSITION[4];
			pos2 = FORTS_POSITION[5];
			pos3 = FORTS_POSITION[6];
		else
			fortPos = FORTS_POSITION[self.m_fortPos+3];
			if target == -1 then
				targetPos = 0;
			else
				targetPos = FORTS_POSITION[target+1];
			end
			pos1 = FORTS_POSITION[1];
			pos2 = FORTS_POSITION[2];
			pos3 = FORTS_POSITION[3];
		end
		self:playSkillIdle();
		self:playSkillIntro();
		Audio:playEffect(107, false);
		-- print("炮台的攻击模式是",self.m_skillData.attack_mode)
		if self.m_skillData.attack_mode == 1 then -- 子弹式(单体)
			local isCenter = false; 
			self:playSkillBurstEffect(1);
		 	self:playCenterOrIndirect(isCenter,self.m_shipPos, fortPos,pos1,pos2,pos3,targetPos);

		elseif self.m_skillData.attack_mode == 2 then --激光(单体)
			self:playSkillBurstEffect(1);
			self:playDirectly(self.m_shipPos,fortPos,targetPos);

		elseif self.m_skillData.attack_mode == 3 then --散射(aoe)
			self:playSkillBurstEffect(2);
			self:playDirectlyScattering(self.m_shipPos, fortPos, pos1, pos2, pos3);

		elseif self.m_skillData.attack_mode == 4 then --扫射(aoe)
			self:playSkillBurstEffect(2);
			self:playDirectlyShooting(self.m_shipPos, fortPos, pos1, pos2, pos3);

		elseif self.m_skillData.attack_mode == 5 then --中心爆破(aoe)
			local isCenter = true;
			self:playSkillBurstEffect(2);
			self:playCenterOrIndirect(isCenter,self.m_shipPos, fortPos,pos1,pos2,pos3);
		end
	end	
end

function CFort:playSkillIdle()
	print("playSkillIdle")
	if self.m_armatureFort then
		self.m_armatureFort:getAnimation():play("skill_idle");
	end
end

function CFort:playSkillStart()
	print("playSkillStart")
	if self.m_armatureFort then
		self.m_armatureFort:getAnimation():play("skill_start");
	end
end

function CFort:playSkillIntro()
	-- self.m_shipPos = 1 不翻转(我方)  self.m_shipPos = 2 转(敌方)
	self.m_armatureSkillIntro = BattleResourceMgr:getSkillIntro();
	if self.m_armatureSkillIntro then
		self:addChild(self.m_armatureSkillIntro);
		self.m_armatureSkillIntro:getAnimation():play("anim01");
	end
end

function CFort:playSkillBurstEffect(singleOrNot)
	local sequence = cc.Sequence:create(cc.DelayTime:create(self.m_baseInfo.skill_time), 
		cc.CallFunc:create(function() 
			if singleOrNot == 1 then
				Audio:playEffect(115, false);
			elseif singleOrNot == 2 then
				Audio:playEffect(116, false);
			end
		end)
	)
	self:runAction(sequence);
end

--扫射
function CFort:playDirectlyShooting(shipPos, fortPos, pos1, pos2, pos3)
	if self.m_armatureFort then
		local rollTime = 0;
		local returnAngle = 0;
		local rotationAngle1 = Utils:getRotationAngle(fortPos, pos1);
		local rotationAngle2 = Utils:getRotationAngle(fortPos, pos2);
		local rotationAngle3 = Utils:getRotationAngle(fortPos, pos3);
		print("角1，角2，角3", rotationAngle1,rotationAngle2,rotationAngle3)
		if shipPos == 1 then 
			if rotationAngle1 == 0 then
				self:playSkillStart();
				rollTime = 0.1;
				returnAngle = rotationAngle1 - rotationAngle3;
			else
				if rotationAngle2 == 0 then
					rollTime = 0.05;
					returnAngle = rotationAngle2 - rotationAngle3;
					local startAngle = cc.RotateBy:create(0.05,rotationAngle1- rotationAngle2);
					self.m_armatureFort:runAction(startAngle);
					self:playSkillStart();
				else
					local startAngle = cc.RotateBy:create(0.1, rotationAngle1- rotationAngle3);
					self.m_armatureFort:runAction(startAngle);
					self:playSkillStart();
				end
			end
		else
			if rotationAngle1 == 180 then
				self:playSkillStart();
				rollTime = 0.1;
				returnAngle = rotationAngle3-rotationAngle1;
			else
				if rotationAngle2 == 180 then
					rollTime = 0.05;
					returnAngle = rotationAngle3 - rotationAngle2;
					local startAngle = cc.RotateBy:create(0.05, rotationAngle2-rotationAngle1);
					self.m_armatureFort:runAction(startAngle);
					self:playSkillStart();
				else
					print("设置初始角度3")
					local startAngle = cc.RotateBy:create(0.1, rotationAngle3-rotationAngle1);
					self.m_armatureFort:runAction(startAngle);
					self:playSkillStart();
				end
			end
		end
		self.m_armatureFort:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				if movementID == "skill_start" then
					self.m_armatureFort:getAnimation():play("skill_fire");
					local function playEnd()
						self.m_armatureFort:getAnimation():play("skill_end");

					end
					if shipPos == 1 then
						local fortActionSequence = cc.Sequence:create(
							cc.RotateBy:create(self.m_baseInfo.skill_time,rotationAngle3 - rotationAngle1),
							cc.CallFunc:create(playEnd));
						self.m_armatureFort:runAction(fortActionSequence);
					else
						local fortActionSequence = cc.Sequence:create(
							cc.RotateBy:create(self.m_baseInfo.skill_time,rotationAngle1 - rotationAngle3),
							cc.CallFunc:create(playEnd));
						self.m_armatureFort:runAction(fortActionSequence);
					end
				end
			end
		end)
		self:directlyShootingSkill(shipPos,fortPos,rotationAngle1,rotationAngle2,rotationAngle3,pos1,pos2,pos3,returnAngle);
	end
end

--扫射技能特效
function CFort:directlyShootingSkill(shipPos, fortPos, rotationAngle1, rotationAngle2, rotationAngle3,pos1,pos2,pos3,returnAngle)
	local armatureSkill = BattleResourceMgr:getSkill(self.m_baseInfo.skill_id);
	if armatureSkill then

		self.m_ccbNodeEffectSkill:addChild(armatureSkill);
		armatureSkill:setPosition(fortPos);
		Audio:playEffect(self.m_baseInfo.skill_id, false);
		armatureSkill:getAnimation():play("start");
		armatureSkill:setRotation(rotationAngle1);-- kangkang 
		-- if self.m_shipPos == 2 then
		-- 	armatureSkill:setScaleX(-1)
		-- end
		local hitEffectList = {};	
		local function createHitEffect(pos)
			print("@@createHitEffect:", pos.x, pos.y);
			local skillHitEffect = BattleResourceMgr:getNormalHitEffect();
			if skillHitEffect then
				table.insert(hitEffectList, skillHitEffect);
				if shipPos == 2 then
					skillHitEffect:setScaleX(-1);
				end
				self.m_ccbNodeEffectSkill:addChild(skillHitEffect, 1, 10);
				skillHitEffect:setPosition(pos);
				skillHitEffect:getAnimation():play("anim01");
			end 
		end	

		armatureSkill:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID) 
			if movementType == ccs.MovementEventType.complete then
				if movementID == "start" then

					armatureSkill:getAnimation():play("loop");
					createHitEffect(pos1);
					local function actionPos1ToPos2()
						createHitEffect(pos2);
					end
					local function actionPos2ToPos3()
						createHitEffect(pos3);
						armatureSkill:getAnimation():play("end");
					end

					local actionSequence = cc.Sequence:create(cc.RotateBy:create(self.m_baseInfo.skill_time/2, rotationAngle2 - rotationAngle1),
						cc.CallFunc:create(actionPos1ToPos2),
						cc.RotateBy:create(self.m_baseInfo.skill_time/2, rotationAngle3 - rotationAngle2),
						cc.CallFunc:create(actionPos2ToPos3));

					armatureSkill:runAction(actionSequence);
				end
				if movementID == "end" then
					armatureSkill:removeSelf();
					armatureSkill = nil;
					for k, v in pairs(hitEffectList) do --清除所有动画
						v:removeSelf();
						v = nil;
					end
					hitEffectList = {};
					local rotateTo = cc.RotateTo:create(0.4, 0);
					self.m_armatureFort:runAction(rotateTo);
				end
			end
		end)
	end
end

--散射炮台特效
function CFort:playDirectlyScattering(shipPos, fortPos, pos1, pos2 ,pos3)
	-- print("播放散射")
	if self.m_armatureFort then
		local targetPos = {{pos1,pos2,pos3},{pos1,pos3,pos2},
					{pos2,pos1,pos3},{pos2,pos3,pos1},
					{pos3,pos1,pos2},{pos3,pos2,pos1}};
		local horizontalAngle = 0; --水平角
		local rollTime = 0;			--转角时间
		local rotationAngle1 = 0; --idle转角位置
		local startTurnAngle = 0; --idle状态转动角
		local fortCount = 1;	--炮台随机数
		local isFortScattering = true; 	--炮台散射状态
		-- self.m_isSkillScattering =  false; --技能散射状态

		--转动角1(列子当ship2的炮台3时：shipPos = 1 oneTimeAngle = -7.81, shipPos = 2 oneTimeAngle = 7.81)
		local oneTimeAngle = Utils:getRotationAngle(fortPos,pos1) - Utils:getRotationAngle(fortPos,pos2);
		--转动角2（列子当ship2的炮台3时：shipPos = 1 oneTimeAngle = -8.1, shipPos = 2 oneTimeAngle = 8.1）
		local twoTimeAngle = Utils:getRotationAngle(fortPos,pos2) - Utils:getRotationAngle(fortPos,pos3);
		--最大转动角(列子当ship2的炮台3时：shipPos = 1 twoTimeAngle = -15.94, shipPos = 2 twoTimeAngle = 15.94)
		local treeTimeAngle = Utils:getRotationAngle(fortPos,pos1) - Utils:getRotationAngle(fortPos,pos3);
		if shipPos == 2 then	--战舰2时平行角是180
			horizontalAngle = 180;
		end
		local index = math.random(1, 6);
		index = math.random(1, 6);
		local choosePos = targetPos[index][fortCount]
		local rotationAngle1 = Utils:getRotationAngle(fortPos,choosePos);
		if shipPos == 1 then
			if rotationAngle1 == oneTimeAngle or rotationAngle1 == - oneTimeAngle then
				rollTime = 0.05;
			elseif rotationAngle1 == twoTimeAngle or rotationAngle1 == -twoTimeAngle then
				rollTime = 0.05;
			elseif rotationAngle1 == treeTimeAngle or rotationAngle1 == -treeTimeAngle then
				rollTime = 0.1;
			else
				rollTime = 0;
			end
		else
			if rotationAngle1 - horizontalAngle == oneTimeAngle or
			 rotationAngle1 - horizontalAngle == -oneTimeAngle then
			 	rollTime = 0.05;
			elseif rotationAngle1 - horizontalAngle == twoTimeAngle or
			 	rotationAngle1 - horizontalAngle == -twoTimeAngle then
			 	rollTime = 0.05;
			elseif rotationAngle1 - horizontalAngle == treeTimeAngle or
				rotationAngle1 - horizontalAngle == -treeTimeAngle then
				rollTime = 0.1;
			else
				rollTime = 0;
			end
		end

		startTurnAngle = horizontalAngle - rotationAngle1;
		local function rotateStartAngle()
			if shipPos == 1 then
				self.fortIdleStartAngle = cc.RotateBy:create(rollTime, -startTurnAngle);
				self.m_armatureFort:runAction(self.fortIdleStartAngle);
			else
				self.fortIdleStartAngle = cc.RotateBy:create(rollTime, startTurnAngle);
				self.m_armatureFort:runAction(self.fortIdleStartAngle);
			end
		end

		-- print("index = ",index)
		local function changeFortAngle()
			-- print("进入散射"..fortCount.."次")

			if fortCount == 4 then --循环3次后换一组目标
				index = math.random(1, 6);
				index = math.random(1, 6);
				fortCount = 1;
			end 
			choosePos = targetPos[index][fortCount]
			local rotationAngle2 = Utils:getRotationAngle(fortPos,choosePos);
			-- print("打击目标",index, fortCount)		
			-- print("rotationAngle2 = ",rotationAngle2)
			-- print("转动角度1", oneTimeAngle)
			-- print("转动角度2", twoTimeAngle)
			-- print("转动角度3", treeTimeAngle)
			if rotationAngle2 - rotationAngle1 == oneTimeAngle or rotationAngle2 - rotationAngle1 == -oneTimeAngle then
				rollTime = 0.05;
				rotationAngle1 = rotationAngle1 + oneTimeAngle
			elseif rotationAngle2 - rotationAngle1 == twoTimeAngle or rotationAngle2 - rotationAngle1 == -twoTimeAngle then
				rollTime = 0.05;
				rotationAngle1 = rotationAngle1 + twoTimeAngle
			elseif rotationAngle2 - rotationAngle1 == treeTimeAngle or rotationAngle2 - rotationAngle1 == -treeTimeAngle then
				rollTime = 0.1;
				rotationAngle1 = rotationAngle1 + treeTimeAngle
			elseif rotationAngle2 - rotationAngle1 == 0 then
				rollTime = 0;
			end
			-- print("返回时间", rollTime)
			-- print("rotationAngle1 = ", rotationAngle1)
			-- print("返回角度", returnAngle)
			-- print("转动角度", turnAngle)
			if shipPos == 1 then
				self.RotateAngle = cc.RotateTo:create(rollTime, rotationAngle2);
				self.m_armatureFort:runAction(self.RotateAngle);	
			else
				self.RotateAngle = cc.RotateTo:create(rollTime, 180-rotationAngle2);
				self.m_armatureFort:runAction(self.RotateAngle);	
			end

			fortCount = fortCount+1;
		
			-- if movementID == "skill_fire" then
			-- 	print("!!!!!!!fire")
			-- end
			self:directlyScatteringSkill(shipPos, fortPos, choosePos, rotationAngle2, skillNum)	
			local function delayCreateTask()
				if isFortScattering == true then
					changeFortAngle();
				end
			end		
			local delayTask = cc.Sequence:create(cc.DelayTime:create(0.18), cc.CallFunc:create(delayCreateTask));
			self.m_armatureFort:runAction(delayTask);
		end

		local function playFortFire()
			self.m_armatureFort:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
					if movementID == "skill_start" then
						print("播放炮台开火")
						self.m_armatureFort:getAnimation():play("skill_fire");
						changeFortAngle();
					end
				end
			end)
		end

		local sequence = cc.Sequence:create(cc.CallFunc:create(rotateStartAngle),
			self:playSkillStart(), cc.CallFunc:create(playFortFire));
		self.m_armatureFort:runAction(sequence);

		local function playEnd()
			self.m_armatureFort:getAnimation():play("skill_end");
			isFortScattering = false;
			-- print("结束")
		end
		local delayTask = cc.Sequence:create(
			cc.DelayTime:create(1.5),    -- ? 1.5
		 	cc.CallFunc:create(playEnd));
		self.m_armatureFort:runAction(delayTask);
	end
end

--散射技能特效
function CFort:directlyScatteringSkill(shipPos, fortPos, choosePos, rotationAngle)
	
	-- print("散射技能特效",shipPos, fortPos, choosePos, rotationAngle)
	local armatureList = {}
	local armatureSkill = BattleResourceMgr:getSkill(self.m_baseInfo.skill_id);

	if armatureSkill then
		table.insert(armatureList, armatureSkill);
		armatureSkill:setRotation(rotationAngle);
		self.m_ccbNodeEffectSkill:addChild(armatureSkill);
		armatureSkill:setPosition(fortPos);
		
		Audio:playEffect(self.m_baseInfo.skill_id, false);

		armatureSkill:getAnimation():play("start");
		if shipPos == 2 then
			print("炮台散射，是敌方炮台发射技能,取消了setScaleX");
			-- armatureSkill:setScaleX(-1);
		end

		local skillHitEffect = BattleResourceMgr:getNormalHitEffect();
		if skillHitEffect then
			table.insert(armatureList, skillHitEffect);
			if shipPos == 2 then
				skillHitEffect:setScaleX(-1);
			end
			self.m_ccbNodeEffectSkill:addChild(skillHitEffect, 1, 10);
			skillHitEffect:setPosition(choosePos);
			skillHitEffect:getAnimation():play("anim01");
		end

		local function skillEndCallBack()
		for k, v in pairs(armatureList) do --清除所有动画
				v:removeSelf();
				v = nil;
			end
			armatureList = {};

			local rotateTo = cc.RotateTo:create(0.1, 0);
			self.m_armatureFort:runAction(rotateTo);
		end	
		local delayTask = cc.Sequence:create(cc.DelayTime:create(self.m_baseInfo.skill_time),
		 cc.CallFunc:create(skillEndCallBack));
		self:runAction(delayTask);
	end
end

-- 炮台激光
function CFort:playDirectly(shipPos,fortPos,firePos)
	print("CFort:playDirectly", shipPos,fortPos,firePos)
	if self.m_armatureFort then
		self:playSkillStart();
		local rotationAngle = Utils:getRotationAngle(fortPos, firePos);
		-- self.m_armatureFort:setRotation(rotationAngle);  -- 双方炮台都是翻转到正常方向，就按照射击方向发射技能就OK了
		
		self.m_armatureFort:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
			if movementType == ccs.MovementEventType.complete then
				if movementID == "skill_start" then
					self.m_armatureFort:getAnimation():play("fire");
					self:directlySkill(shipPos,fortPos,firePos,rotationAngle)
				end
			end
		end)

		local function playEnd()
			self.m_armatureFort:getAnimation():play("end");		
		end
		local delayTask = cc.Sequence:create(cc.DelayTime:create(self.m_baseInfo.skill_time),
			cc.CallFunc:create(playEnd));
		self.m_armatureFort:runAction(delayTask);
	end
end

--激光技能特效 动画名有start, loop， end
function CFort:directlySkill(shipPos, fortPos, targetPos,rotationAngle)
	print("激光技能特效")
	local armatureSkill = BattleResourceMgr:getSkill(self.m_baseInfo.skill_id);
	if armatureSkill then
		print("show skill effect")
		self.m_ccbNodeEffectSkill:addChild(armatureSkill);
		armatureSkill:setPosition(fortPos);
		-- armatureSkill:setRotation(rotationAngle);     -- kangkang

		Audio:playEffect(self.m_baseInfo.skill_id, false);

		armatureSkill:getAnimation():play("loop");
		if shipPos == 2 then
			armatureSkill:setScaleX(-1);
		end

		local skillHitEffect = BattleResourceMgr:getspecialHitEffect();
		if skillHitEffect then
			if shipPos == 2 then
				skillHitEffect:setScaleX(-1);
			end
			self.m_ccbNodeEffectSkill:addChild(skillHitEffect, 1, 10);
			skillHitEffect:setPosition(targetPos);
			skillHitEffect:getAnimation():play("anim01");
		end
		local function skillMovementEvent(movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				if movementID == "end" then
					armatureSkill:removeSelf();
					armatureSkill = nil;
					-- local rotateBy = cc.RotateBy:create(0.1, -rotationAngle)   -- kangkang 注掉的
					-- self.m_armatureFort:runAction(rotateBy);
				end
			end
		end
		armatureSkill:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID) 
			skillMovementEvent(movementType, movementID);
		end)
		--技能播放结束
		local function skillEndCallBack()
			print("directly skill End");
			armatureSkill:getAnimation():play("end");
			skillHitEffect:removeSelf();
			skillHitEffect = nil;
		end
		local delayTask = cc.Sequence:create(cc.DelayTime:create(self.m_baseInfo.skill_time), cc.CallFunc:create(skillEndCallBack));
		armatureSkill:runAction(delayTask);
	end
end

--炮台中心爆破和子弹
function CFort:playCenterOrIndirect(isCenter,shipPos,fortPos, pos1, pos2, pos3,targetPos)
	-- print("是中心爆破?",isCenter)
	if self.m_armatureFort then
		self:playSkillStart();
		self.m_armatureFort:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
			if movementType == ccs.MovementEventType.complete then
				if movementID == "skill_start" then
					self.m_armatureFort:getAnimation():play("skill_fire");
				end
			end
		end)

		if isCenter == true then
			self:directlyCenterSkill(shipPos,fortPos, pos1, pos2, pos3)
		else
			local rotationAngle = Utils:getRotationAngle(fortPos, targetPos);
			-- print("子弹式技能炮台", rotationAngle);
			-- 一开始炮台就有翻转了，这边是用炮台直接播放技能，不需要再次翻转了
			-- self.m_armatureFort:setRotation(rotationAngle);

			self:indirectSkillMove(shipPos,fortPos,targetPos)
	
		end


		local function playEnd()
			self.m_armatureFort:getAnimation():play("skill_end");
		end
		local delayTask = cc.Sequence:create(cc.DelayTime:create(self.m_baseInfo.skill_time),cc.CallFunc:create(playEnd));
		self.m_armatureFort:runAction(delayTask);
	end
end

--子弹式技能特效 动画名有：start， loop， end
function CFort:indirectSkillMove(shipPos, fortPos, targetPos)

	local armatureSkill = BattleResourceMgr:getSkill(self.m_baseInfo.skill_id);
	if armatureSkill then
		print("show skill effect", self.m_baseInfo.skill_id)
		if self.m_shipPos == 2 then
			-- print("对发放技能，需要反向")
			armatureSkill:setScaleX(-1);
		end
		-- local rotationAngle = Utils:getRotationAngle(fortPos, targetPos);
		-- armatureSkill:setRotation(rotationAngle);
		
		self.m_ccbNodeEffectSkill:addChild(armatureSkill);
		armatureSkill:setPosition(fortPos);

		Audio:playEffect(self.m_baseInfo.skill_id, false);

		armatureSkill:getAnimation():play("start");
		local function skillMovementEvent(movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				if movementID == "start" then
					armatureSkill:getAnimation():play("loop");
				elseif movementID == "end" then
					armatureSkill:removeSelf();
					armatureSkill = nil;
					local skillHitEffect = BattleResourceMgr:getNormalHitEffect();
					if skillHitEffect then
						if shipPos == 2 then
							skillHitEffect:setScaleX(-1);
						end
						self.m_ccbNodeEffectSkill:addChild(skillHitEffect, 1, 10);
						skillHitEffect:setPosition(targetPos);

						skillHitEffect:getAnimation():play("anim01");
						skillHitEffect:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
							if movementType == ccs.MovementEventType.complete then
								skillHitEffect:removeSelf();
								skillHitEffect = nil;
							end
						end)
					end
				end
			end
		end
		armatureSkill:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID) 
			skillMovementEvent(movementType, movementID);
		end)
		local function actionMoveCallBack()
			armatureSkill:getAnimation():play("end");
			local rotateTo = cc.RotateTo:create(0.1, 0);
			self.m_armatureFort:runAction(rotateTo);
		end
		local actionMove = cc.MoveTo:create(self.m_baseInfo.skill_time, targetPos);
		local actionSequence = cc.Sequence:create(actionMove, cc.CallFunc:create(actionMoveCallBack));
		armatureSkill:runAction(actionSequence);
	end
end

--中心爆破技能特效 动画名有start， loop， end
function CFort:directlyCenterSkill(shipPos, fortPos, pos1, pos2, pos3)
	local armatureSkill = BattleResourceMgr:getSkill(self.m_baseInfo.skill_id);
	if armatureSkill then
		if shipPos == 2 then
			armatureSkill:setScaleX(-1);
		end
		self.m_ccbNodeEffectSkill:addChild(armatureSkill);
		armatureSkill:setPosition(pos2);

		Audio:playEffect(self.m_baseInfo.skill_id, false);

		armatureSkill:getAnimation():play("start");
		armatureSkill:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID) 
			if movementType == ccs.MovementEventType.complete then
				if movementID == "start" then
					armatureSkill:getAnimation():play("loop");
				elseif movementID == "end" then
					armatureSkill:removeSelf();
					armatureSkill = nil;
				end
			end
		end);
		local skillHitEffect = {};
		armatureSkill:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
			if evt == "showHit" then
				local pos = {pos1, pos2, pos3}
				for i = 1, 3 do
					skillHitEffect[i] = BattleResourceMgr:getNormalHitEffect();
					if skillHitEffect[i] then
						if shipPos == 2 then
							skillHitEffect[i]:setScaleX(-1);
						end
						self.m_ccbNodeEffectSkill:addChild(skillHitEffect[i], 1, 10);
						skillHitEffect[i]:setPosition(pos[i]);
						
						skillHitEffect[i]:getAnimation():play("anim01");
						skillHitEffect[i]:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
							if movementType == ccs.MovementEventType.complete then
								skillHitEffect[i]:removeSelf();
								skillHitEffect[i] = nil;
							end
						end)
					end
				end				
			end
		end);
		--技能播放结束
		local function skillEndCallBack()
			print("directly center skill end");
			armatureSkill:getAnimation():play("end");
		end
		local delayTask = cc.Sequence:create(cc.DelayTime:create(self.m_baseInfo.skill_time), cc.CallFunc:create(skillEndCallBack));
		armatureSkill:runAction(delayTask);
	end
end

function CFort:playIdle()
	if self.m_armatureFort then
		self.m_armatureFort:getAnimation():play("idle");
	end
end

function CFort:showTarget()
	self.m_armatureTarget:setVisible(true);
	self.m_armatureTarget:getAnimation():play("anim01");
end

function CFort:hideTarget()
	self.m_armatureTarget:setVisible(false);
end

function CFort:isTargetShow()
	print("CFort:isTargetShow");
	if self.m_armatureTarget then
		return self.m_armatureTarget:isVisible();
	end
end

-----buff----------
function CFort:cleanBuff(cleanBuffNum)
	print("清除Buff的id", cleanBuffNum)
	self.m_nodeBuff:removeChildByTag(cleanBuffNum);
	self.m_buffs[cleanBuffNum] = nil;
	self.m_buffCount = #self.m_buffs;
	local strBuff = BattleResourceMgr:getBattleBuffName(cleanBuffNum)
	if strBuff ~= 0 then
		self.m_armatureBuff[strBuff]:setVisible(false);
	end
end

--buff图标
function CFort:addBuffIcon(BuffNum)
	-- print("CFort:addBuffIcon", BuffNum);
	-- local strBuff = BattleResourceMgr:getBattleBuffName(BuffNum);
	-- if strBuff == 0 then
	-- 	return;
	-- end

	local spriteIcon = BattleResourceMgr:getBuffIcon(BuffNum);
	if spriteIcon then
		-- print("addBuff ", strBuff)
		self.m_nodeBuff:add(spriteIcon,1,BuffNum);
		self.m_buffCount = self.m_buffCount + 1;
		-- if self.m_shipPos == 1 then
		-- 	if self.m_buffCount > 6 then -- 一排6个buff图标
		-- 		local x = (self.m_buffCount - 7) * 26;
		-- 		local y = -26;
		-- 		spriteIcon:setPosition(cc.p(x, y));
		-- 	else
		-- 		local x = (self.m_buffCount - 1)  * 26;
		-- 		local y = 0;
		-- 		spriteIcon:setPosition(cc.p(x, y));
		-- 	end
		-- else
			if self.m_buffCount > 6 then -- 一排6个buff图标
				local x = (self.m_buffCount - 7) * 26;
				local y = -26;
				spriteIcon:setPosition(cc.p(x, y));
			else
				local x = (self.m_buffCount - 1)  * 26;
				local y = 0;
				spriteIcon:setPosition(cc.p(x, y));
			end
		-- end
	else
		print("Error: No PNG ", path);
	end
end

function CFort:addEffect(BuffNum)
	local strBuff = BattleResourceMgr:getBattleBuffName(BuffNum)
	if strBuff == 0 then
		return;
	end

	if self.m_armatureBuff[strBuff] == nil then	--动画已存在则不再创建,只需要显示即可
		self.m_armatureBuff[strBuff] = BattleResourceMgr:getBuffEffect(strBuff);
		if self.m_armatureBuff[strBuff] then
			self:addChild(self.m_armatureBuff[strBuff]);
			self.m_armatureBuff[strBuff]:getAnimation():play("anim01");
		end
	end
	if self.m_armatureBuff[strBuff] then
		print("动画存在，设为可见")
		self.m_armatureBuff[strBuff]:setVisible(true);
	end
end

function CFort:addBuffWordTip(buffID)
	local buffWord = BuffWordTips:create(buffID);
	self.m_ccbNodeCloud:addChild(buffWord);
	if self.m_shipPos == 1 then 
		buffWord:setPosition(FORTS_POSITION[self.m_fortPos].x + 50, FORTS_POSITION[self.m_fortPos].y);
	else
		buffWord:setPosition(FORTS_POSITION[self.m_fortPos + 3].x - 50, FORTS_POSITION[self.m_fortPos + 3].y);
	end
end

return CFort