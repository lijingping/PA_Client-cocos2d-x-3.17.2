local CFort = require("app.views.battle.CFort");
local BattleResourceMgr = require("app.utils.BattleResourceMgr");
local ResourceMgr = require("app.utils.ResourceMgr");
local CCBEscortResult = require("app.views.escortView.CCBEscortResult");

local CCBEscortLootBattle = class("CCBEscortLootBattle", function( )
	return CCBLoader("ccbi/escortView/CCBEscortLootBattle");
end)

-- 大体： 正常的战斗大小，拿过来缩小。
--     坐标都用战斗同款

-- 简单战斗
--   准备
-- 	双方战舰，炮台。
--   界面弹出
--   	两艘ship，双方六个炮台
--   	ship play("idle");
--   	同时还有战斗开始的动画。动画播放完，开始炮台射击。

--   	数据准备：
--   	  子弹：子弹生成坐标、 子弹爆炸坐标、 子弹移动速度；
--   	  炮台：生成子弹时间（也就是子弹射击间隔）（随机）、炮台释放技能时间（随机）、炮台坐标、 炮台的size。
--   	  战舰：坐标。

--   是否需要特效音乐   ？？
local LeftX = -1280 * 0.5 + 150;
local RightX = 1280 * 0.5 - 150;
local fortPosY = {180, 40, -100};
local fortSize = cc.size(100, 100);

local bulletMoveTime = 0.5;

function CCBEscortLootBattle:ctor(data)
	if display.resolution >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
	App:getRunningScene():addChild(self);
	-- dump(data);
	self.m_data = data;
	self.m_coinGet = data.money;
	if self.m_coinGet <= 0 then
		self.m_isSuccess = false;
	elseif self.m_coinGet > 0 then
		self.m_isSuccess = true;
	end

	self.m_playerShipID = ShipDataMgr:getUseShipID();
	self:createEventListener();

	local playerEquipForts = FortDataMgr:getEquipFortData();
	self.m_playerEquipFortsID = {};
	for k, v in pairs(playerEquipForts) do
		self.m_playerEquipFortsID[v.pos + 1] = v.fort_id;
	end

	self.m_enemyShipID = data.enemy_ship;
	self.m_enemyEquipFortsID = {data.enemy_fort1, data.enemy_fort2, data.enemy_fort3};
-- 	"<var>" = {
--     1 = 90017
--     2 = 90016
--     3 = 90018
-- }
	self.m_shipNode = cc.Node:create();
	self.m_ccbNodeLootBattle:addChild(self.m_shipNode, 1, 1);
	self.m_animNode = cc.Node:create();
	self.m_ccbNodeLootBattle:addChild(self.m_animNode, 2, 2);

	self.m_battleEndTime = math.random(8, 12);

	self:init();
end

function CCBEscortLootBattle:init()
	self.m_battleTiming = 0;
	-- 战斗开始动画。
	local battleStartArmature = ResourceMgr:getEscortLootBattleStartArmature();
	self:addChild(battleStartArmature);
	battleStartArmature:setPosition(display.center);
	battleStartArmature:getAnimation():play("anim01");
	battleStartArmature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			print("  开始打架   ");
			battleStartArmature:removeSelf();
			self:openBattleScheduler();
		end
	end)

	self.m_playerShip = BattleResourceMgr:getShipArmatureByShipID(self.m_playerShipID);
	self.m_shipNode:addChild(self.m_playerShip);
	self.m_playerShip:setPosition(cc.p(LeftX, 0));
	self.m_playerShip:getAnimation():play("idle");

	self.m_enemyShip = BattleResourceMgr:getShipArmatureByShipID(self.m_enemyShipID);
	self.m_shipNode:addChild(self.m_enemyShip);
	self.m_enemyShip:setPosition(cc.p(RightX, 0));
	self.m_enemyShip:getAnimation():play("idle");

	self.m_playerForts = {};
	self.m_enemyForts = {};
	self.m_playerFortAckSpeed = {};
	self.m_enemyFortAckSpeed = {};
	self.m_playerFortSkillTime = {};
	self.m_enemyFortSkillTime = {};
	for i = 1, 3 do 
		self.m_playerForts[i] = CFort:create(self.m_playerEquipFortsID[i], 1, i);
		self.m_shipNode:addChild(self.m_playerForts[i]);
		self.m_playerForts[i]:setEffectSkill(self.m_animNode);
		self.m_playerForts[i]:setPosition(cc.p(LeftX, fortPosY[i]));
		self.m_playerForts[i]:playStart();
		self.m_playerForts[i]:setLootBattle();
		-- self.m_playerFortAckSpeed[i] = FortDataMgr:getAtkSpeedFactor(self.m_playerEquipFortsID[i], 1) * 0.5; -- 炮台攻速不随升级而改变，这边填10
		local playerRandomSpeed = math.random(30, 60) * 0.01;
		self.m_playerFortAckSpeed[i] = playerRandomSpeed;
		self.m_playerFortSkillTime[i] = FortDataMgr:getFortBaseInfo(self.m_playerEquipFortsID[i]).skill_time + 0.3;

		self.m_enemyForts[i] = CFort:create(self.m_enemyEquipFortsID[i], 2, i);
		self.m_shipNode:addChild(self.m_enemyForts[i]);
		self.m_enemyForts[i]:setEffectSkill(self.m_animNode);
		self.m_enemyForts[i]:setPosition(cc.p(RightX, fortPosY[i]));
		self.m_enemyForts[i]:playStart();
		self.m_enemyForts[i]:setLootBattle();
		-- self.m_enemyFortAckSpeed[i] = FortDataMgr:getAtkSpeedFactor(self.m_enemyEquipFortsID[i], 1) * 0.5;
		local enemyRandomSpeed = math.random(30, 60) * 0.01;
		self.m_enemyFortAckSpeed[i] = enemyRandomSpeed;
		self.m_enemyFortSkillTime[i] = FortDataMgr:getFortBaseInfo(self.m_enemyEquipFortsID[i]).skill_time + 0.3; -- 增加点技能后摇时间。hh
	end
	-- 计算炮台子弹发射的时间
	self.m_playerFortBulletTiming = {0, 0, 0};
	self.m_enemyFortBulletTiming = {0, 0, 0};
	-- 计算技能中的时间
	self.m_playerFortSkillTiming = {0, 0, 0};
	self.m_enemyFortSkillTiming = {0, 0, 0};
	-- 是否在技能中状态
	self.m_playerIsFortSkilling = {0, 0, 0};
	self.m_enemyIsFortSkilling = {0, 0, 0};
	-- 记录释放几次技能统计
	self.m_playerSkillFortCount = 0;
	self.m_enemySkillFortCount = 0;
	-- 释放技能随机出来的时间
	self.m_playerSkillRandomTime = {};
	self.m_enemySkillRandomTime = {};
	-- 随机到的技能是否已经释放了
	self.m_playerIsSkillFire = {};
	self.m_enemyIsSkillFire = {};
	-- 计算技能发射的时间
	self.m_playerSkillScheduleTime = {};
	self.m_enemySkillScheduleTime = {};
	-- 记录已释放过技能的炮台
	self.m_playerHaveSkillFort = {};
	self.m_enemyHaveSkillFort = {};

	self:randomFortSkillTime();
end

function CCBEscortLootBattle:createEventListener()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(event, touch) return self:onTouchBegan(event, touch); end, cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(function(event, touch) self:onTouchEnded(event, touch); end, cc.Handler.EVENT_TOUCH_ENDED);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerColor);
end

function CCBEscortLootBattle:onTouchBegan(event, touch)
	return true;
end

function CCBEscortLootBattle:onTouchEnded(event, touch)

end

function CCBEscortLootBattle:openBattleScheduler()
	if self.m_battleScheduler == nil then
		self.m_battleScheduler = self:getScheduler():scheduleScriptFunc(function(delta) self:schedulerFunc(delta); end, 0, false);
	end
end

function CCBEscortLootBattle:schedulerFunc(delta)
	for i = 1, 3 do 
		if self.m_playerIsFortSkilling[i] == 0 then
			self.m_playerFortBulletTiming[i] = self.m_playerFortBulletTiming[i] + delta;
			if self.m_playerFortBulletTiming[i] >= self.m_playerFortAckSpeed[i] then
				self.m_playerFortBulletTiming[i] = self.m_playerFortBulletTiming[i] - self.m_playerFortAckSpeed[i];
				self.m_playerForts[i]:playFire();
				local beginPos = cc.p(LeftX + fortSize.width * 0.5, fortPosY[i]);
				local targetPos = cc.p(RightX - fortSize.width * 0.5, fortPosY[i]);
				self:createBullet(self.m_playerEquipFortsID[i], true, beginPos, targetPos);
			end
		else
			self.m_playerFortSkillTiming[i] = self.m_playerFortSkillTiming[i] + delta;
			if self.m_playerFortSkillTiming[i] >= self.m_playerFortSkillTime[i] then
				-- 技能结束
				self.m_playerFortSkillTiming[i] = 0;
				self.m_playerIsFortSkilling[i] = 0;

			end
		end

		if self.m_enemyIsFortSkilling[i] == 0 then
			self.m_enemyFortBulletTiming[i] = self.m_enemyFortBulletTiming[i] + delta;
			if self.m_enemyFortBulletTiming[i] >= self.m_enemyFortAckSpeed[i] then
				self.m_enemyFortBulletTiming[i] = self.m_enemyFortBulletTiming[i] - self.m_enemyFortAckSpeed[i];
				self.m_enemyForts[i]:playFire();
				local beginPos = cc.p(RightX - fortSize.width * 0.5, fortPosY[i]);
				local targetPos = cc.p(LeftX + fortSize.width * 0.5, fortPosY[i]);
				self:createBullet(self.m_enemyEquipFortsID[i], false, beginPos, targetPos);
			end
		else
			self.m_enemyFortSkillTiming[i] = self.m_enemyFortSkillTiming[i] + delta;
			if self.m_enemyFortSkillTiming[i] >= self.m_enemyFortSkillTime[i] then
				-- 技能结束
				self.m_enemyFortSkillTiming[i] = 0;
				self.m_enemyIsFortSkilling[i] = 0;

			end
		end
	end

	for i = 1, self.m_playerSkillFortCount do 
		if self.m_playerIsSkillFire[i] == 0 then
			self.m_playerSkillScheduleTime[i] = self.m_playerSkillScheduleTime[i] + delta;
			if self.m_playerSkillScheduleTime[i] >= self.m_playerSkillRandomTime[i] then
				self.m_playerIsSkillFire[i] = 1;
				local fortIndex = self:chooseTargetFortIndex(true);
				-- print("   fortIndex :  " , fortIndex);
				table.insert(self.m_playerHaveSkillFort, fortIndex);
				self:playerPlayFortSkill(fortIndex);
			end
		end
	end

	for i = 1, self.m_enemySkillFortCount do
		if self.m_enemyIsSkillFire[i] == 0 then
			self.m_enemySkillScheduleTime[i] = self.m_enemySkillScheduleTime[i] + delta;
			if self.m_enemySkillScheduleTime[i] >= self.m_enemySkillRandomTime[i] then
				self.m_enemyIsSkillFire[i] = 1;
				local fortIndex = self:chooseTargetFortIndex(false);
				-- print("   fortIndex :  ", fortIndex);
				table.insert(self.m_enemyHaveSkillFort, fortIndex);
				self:enemyPlayFortSkill(fortIndex);
			end
		end
	end

	self.m_battleTiming = self.m_battleTiming + delta;
	if self.m_battleTiming >= self.m_battleEndTime then
		self:closeScheduler();
		self:createShipDestroyAnim();
	end
end

function CCBEscortLootBattle:createBullet(bulletID, isPlayer, beginPos, targetPos)
	local bulletSprite = cc.Sprite:create(BattleResourceMgr:getBulletSprite(bulletID, isPlayer));
	self.m_animNode:addChild(bulletSprite);
	bulletSprite:setPosition(beginPos);
	if not isPlayer then
		bulletSprite:setScaleX(-1);
	end
	local moveAction = cc.MoveTo:create(bulletMoveTime, targetPos);
	local callFunc = cc.CallFunc:create(function()
		bulletSprite:removeSelf();
		bulletSprite = nil;
		self:createBulletHitEffect(targetPos, isPlayer);
	end)
	local sequence = cc.Sequence:create(moveAction, callFunc);
	bulletSprite:runAction(sequence);
end

function CCBEscortLootBattle:createBulletHitEffect(pos, isPlayer)
	local hitEffect = BattleResourceMgr:getNormalHitEffect();
	self.m_animNode:addChild(hitEffect);
	hitEffect:setPosition(pos);
	hitEffect:getAnimation():play("anim01");
	-- isPlayer  是否反转
	hitEffect:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			-- print("  移除子弹爆炸特效   ");
			hitEffect:removeSelf();
			hitEffect = nil;
		end
	end)
end

function CCBEscortLootBattle:randomFortSkillTime()
	self.m_playerSkillFortCount = math.random(1, 3);
	-- print(  "  player  炮台释放几次技能。：：  ", self.m_playerSkillFortCount);
	for i = 1, self.m_playerSkillFortCount do
		self.m_playerSkillRandomTime[i] = math.random(25, (self.m_battleEndTime - 1) * 10) * 0.1;
		self.m_playerIsSkillFire[i] = 0;
		self.m_playerSkillScheduleTime[i] = 0;
	end

	self.m_enemySkillFortCount = math.random(1, 3);
	-- print("  enemy  释放几次技能 ： ", self.m_enemySkillFortCount);
	for i = 1, self.m_enemySkillFortCount do
		self.m_enemySkillRandomTime[i] = math.random(25, (self.m_battleEndTime - 1) * 10) * 0.1;
		self.m_enemyIsSkillFire[i] = 0;
		self.m_enemySkillScheduleTime[i] = 0;
	end

end

function CCBEscortLootBattle:chooseTargetFortIndex(isPlayer)
	local fortIndex = math.random(1, 3);
	if isPlayer then
		local isFireSkill = false;
		for k, v in pairs(self.m_playerHaveSkillFort) do 
			if fortIndex == v then
				isFireSkill = true;
				break;
			end
		end
		if isFireSkill then
			return self:chooseTargetFortIndex(isPlayer);
		else
			return fortIndex;
		end
	else
		local isFireSkill = false;
		for k, v in pairs(self.m_enemyHaveSkillFort) do
			if fortIndex == v then
				isFireSkill = true;
				break;
			end
		end
		if isFireSkill then
			return self:chooseTargetFortIndex(isPlayer);
		else
			return fortIndex;
		end
	end
end

function CCBEscortLootBattle:playerPlayFortSkill(nIndex)
	local skillTarget = nIndex - 1;
	self.m_playerForts[nIndex]:playSkill(skillTarget);
	self.m_playerIsFortSkilling[nIndex] = 1;
	self.m_playerFortBulletTiming[nIndex] = 0;
end

function CCBEscortLootBattle:enemyPlayFortSkill(nIndex)
	local skillTarget = nIndex - 1;
	self.m_enemyForts[nIndex]:playSkill(skillTarget);
	self.m_enemyIsFortSkilling[nIndex] = 1;
	self.m_enemyFortBulletTiming[nIndex] = 0;
end

function CCBEscortLootBattle:closeScheduler()
	if self.m_battleScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_battleScheduler);
		self.m_battleScheduler = nil;
	end
end

function CCBEscortLootBattle:createShipDestroyAnim()
	local destroyArmature = BattleResourceMgr:getShipDestroyArmature();
	self.m_animNode:addChild(destroyArmature);
	if self.m_isSuccess then
		destroyArmature:setPosition(cc.p(RightX, 0));
	else
		destroyArmature:setPosition(cc.p(LeftX, 0));
	end
	destroyArmature:getAnimation():play("anim01");
	destroyArmature:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
		if evt == "destroyShip" then
			print("  摧毁战舰  。。 动画。。 ")
			if self.m_isSuccess then 
				self.m_enemyShip:removeSelf();
				self.m_enemyShip = nil;
				for i = 1, 3 do
					if self.m_enemyForts[i] then
						self.m_enemyForts[i]:removeSelf();
					end
				end
				self.m_enemyForts = {};
			else
				self.m_playerShip:removeSelf();
				self.m_playerShip = nil;
				for i = 1, 3 do
					if self.m_playerForts[i] then
						self.m_playerForts[i]:removeSelf();
					end
				end
				self.m_playerForts = {};
			end
		end
	end)

	destroyArmature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			print("  摧毁战舰动画播放完毕   ");
			destroyArmature:removeSelf();
			destroyArmature = nil;
			
			local lootResult = 1;
			if not self.m_isSuccess then
				lootResult = 2;
			end
			local escortResult = CCBEscortResult:create(2, lootResult);
			escortResult:setViewData(self.m_data);
			self:removeSelf();
		end
	end)
end

-- function CCBEscortLootBattle:onBtnClose()
-- 	self:removeSelf();
-- end

return CCBEscortLootBattle;