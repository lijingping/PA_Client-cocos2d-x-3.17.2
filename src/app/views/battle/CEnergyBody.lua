local BattleResourceMgr = require("app.utils.BattleResourceMgr")

local CEnergyBody = class("CEnergyBody", cc.Node)

--能量体类型
local GREEN_CURE_ENERGY = 0; --绿色治疗
local BLUE_CHANGR_ENERGY = 1; --蓝色充能
local RED_CALLHELP_ENERGY = 2; --红色召唤

local PLAYERGETTER = 1;
local ENERGYGETTER = 2;
local NOTGETTER = 3;

local BATTLE_WIDTH = 1280;
local BATTLE_HEIGHT = 720;

function CEnergyBody:ctor()
	self.m_energyAscription = 0; --能量归属
	self.m_isEnergyAlive = false;
	self.m_energyType = -1;
	self.m_armatureEnergy = {};
	self.m_energyNum = 1;

	self:energyDirArmature(); 	--能量体方向动画
	self:energyGainAramture(); 	--能量体获得动画
	self:energyTargetArmature();--能量体target
	self:energyArmature();
end

--能量体Target
function CEnergyBody:energyTargetArmature()
	self.m_armatureEnergyTarget = BattleResourceMgr:getTargetFortEnemy();
	self:addChild(self.m_armatureEnergyTarget,25,25)
	self.m_armatureEnergyTarget:setVisible(false);
end

function CEnergyBody:energyArmature()
	-- print("生成新的能量体")
	-- self.m_energyNum = self.m_energyNum + 1;
	self.m_armatureEnergy[self.m_energyNum] = BattleResourceMgr:getEnergyArmature();
	self.m_armatureEnergy[self.m_energyNum]:setVisible(false);
	self:addChild(self.m_armatureEnergy[self.m_energyNum],20,20);
end

--energyType
function CEnergyBody:setEnergyType(energyType)
	-- print("设置能量体loop", energyType,"能量体num",self.m_energyNum)
	self.m_armatureEnergy[self.m_energyNum]:setVisible(true);
	self.m_energyType = energyType;
	if energyType == GREEN_CURE_ENERGY then
		self.m_armatureEnergy[self.m_energyNum]:getAnimation():play("green_loop");
	elseif energyType == BLUE_CHANGR_ENERGY then
		self.m_armatureEnergy[self.m_energyNum]:getAnimation():play("blue_loop");
	elseif energyType == RED_CALLHELP_ENERGY then
		self.m_armatureEnergy[self.m_energyNum]:getAnimation():play("red_loop");
	end
	self.m_isEnergyAlive = true;
end

--能量体方向箭头动画
function CEnergyBody:energyDirArmature()
	self.m_armatureEnergyArrows = BattleResourceMgr:getEnergyArrowsArmature();
	self:addChild(self.m_armatureEnergyArrows, 10, 10);
	self.m_armatureEnergyArrows:setVisible(false);
end

--能量体爆破粒子动画
function CEnergyBody:energyGainAramture()
	self.m_armateurEnergyGain = BattleResourceMgr:getEnergyGainArmature();
	self:addChild(self.m_armateurEnergyGain, 30, 30);
	self.m_armateurEnergyGain:setVisible(false);
end

-- 设置能量体位置
function CEnergyBody:setEnergyPosition(posX, posY)
	if self.m_armatureEnergy[self.m_energyNum] == nil then
		self.m_armatureEnergy[self.m_energyNum] = BattleResourceMgr:getEnergyArmature();
		self.m_armatureEnergy[self.m_energyNum]:setVisible(true);
		self:addChild(self.m_armatureEnergy[self.m_energyNum],20,20);
	end
	self.m_armatureEnergy[self.m_energyNum]:setPosition(posX - BATTLE_WIDTH * 0.5, posY - BATTLE_HEIGHT * 0.5)
	self.m_armatureEnergyArrows:setPosition(posX - BATTLE_WIDTH * 0.5, posY - BATTLE_HEIGHT * 0.5);
	self.m_armateurEnergyGain:setPosition(posX - BATTLE_WIDTH * 0.5, posY - BATTLE_HEIGHT * 0.5);
	self.m_armatureEnergyTarget:setPosition(posX - BATTLE_WIDTH * 0.5, posY - BATTLE_HEIGHT * 0.5)
	
end

--能量体归属
function CEnergyBody:energyAscription(buffGetter)
	-- print("能量体归属", buffGetter)
	if self.m_energyAscription ~= buffGetter then
		self.m_energyAscription = buffGetter;

		if self.m_energyAscription == PLAYERGETTER then	
			self.m_armatureEnergyArrows:setVisible(true);
			self.m_armatureEnergyArrows:getAnimation():play("blue");

		elseif self.m_energyAscription == ENERGYGETTER then
			self.m_armatureEnergyArrows:setVisible(true);
			self.m_armatureEnergyArrows:getAnimation():play("red");

		elseif self.m_energyAscription == NOTGETTER then
			self.m_armatureEnergyArrows:setVisible(false);
		end
	end
end
	

--能量体跳跃
function CEnergyBody:energyPlayJump()
	-- print("能量体跳跃")
	self.m_energyNum = self.m_energyNum + 1;
	if self.m_energyType == GREEN_CURE_ENERGY then
		self.m_armatureEnergy[self.m_energyNum-1]:getAnimation():play("green_end");

	elseif self.m_energyType == BLUE_CHANGR_ENERGY then
		self.m_armatureEnergy[self.m_energyNum-1]:getAnimation():play("blue_end");

	elseif self.m_energyType == RED_CALLHELP_ENERGY then
		self.m_armatureEnergy[self.m_energyNum-1]:getAnimation():play("red_end");
	end
	self.m_armatureEnergy[self.m_energyNum-1]:getAnimation():setMovementEventCallFunc(
		function (armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				self.m_armatureEnergy[self.m_energyNum-1]:removeSelf();
				self.m_armatureEnergy[self.m_energyNum-1] = nil;
			end
		end)

	
	self.m_armatureEnergy[self.m_energyNum] = BattleResourceMgr:getEnergyArmature();
	self:setEnergyType(self.m_energyType)
	self:addChild(self.m_armatureEnergy[self.m_energyNum],20,20);
end

--播放能量粒子动画
function CEnergyBody:energyPlayGain()
	self.m_armateurEnergyGain:setVisible(true);
	self.m_armateurEnergyGain:setScale(1);

	if self.m_energyAscription == PLAYERGETTER then
		self.m_armateurEnergyGain:setScale(-1);

	elseif self.m_energyAscription == NOTGETTER then
		self.m_isEnergyAlive = false;
		self.m_armateurEnergyGain:setVisible(false);
		return
	end
	Audio:playEffect(111, false);
	if self.m_energyType == GREEN_CURE_ENERGY then
		self.m_armateurEnergyGain:getAnimation():play("green");
	elseif self.m_energyType == BLUE_CHANGR_ENERGY then
		self.m_armateurEnergyGain:getAnimation():play("blue");
	elseif self.m_energyType == RED_CALLHELP_ENERGY then
		self.m_armateurEnergyGain:getAnimation():play("red");
	end
	self.m_armateurEnergyGain:getAnimation():setMovementEventCallFunc(
		function (armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				self.m_isEnergyAlive = false;
				self.m_armateurEnergyGain:setVisible(false);
				
			end
		end)
end

--能量体爆裂
function CEnergyBody:energyPlayDestroy()
	-- print("爆破") 
	self.m_armatureEnergyArrows:setVisible(false);

	Audio:playEffect(110, false);

	if self.m_energyType == GREEN_CURE_ENERGY then
		self.m_armatureEnergy[self.m_energyNum]:getAnimation():play("green_destroy");
	elseif self.m_energyType == BLUE_CHANGR_ENERGY then
		self.m_armatureEnergy[self.m_energyNum]:getAnimation():play("blue_destroy");
	elseif self.m_energyType == RED_CALLHELP_ENERGY then
		self.m_armatureEnergy[self.m_energyNum]:getAnimation():play("red_destroy");
	end
	self.m_armatureEnergy[self.m_energyNum]:getAnimation():setMovementEventCallFunc(
	function (armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			self:energyPlayGain();
			self.m_armatureEnergy[self.m_energyNum]:setVisible(false);
			self.m_armatureEnergy[self.m_energyNum]:removeSelf();
			self.m_armatureEnergy[self.m_energyNum] = nil;
			self.m_energyAscription = 0;
		end
	end)
end

function CEnergyBody:setEnergyGetterNone()
	self.m_energyAscription = NOTGETTER;
end

--显示energytarget
function CEnergyBody:showTargetEnergy()
	self.m_armatureEnergyTarget:setVisible(true);
	self.m_armatureEnergyTarget:getAnimation():play("anim01")
end

--隐藏energytarget
function CEnergyBody:hideTargetEnergy()
	self.m_armatureEnergyTarget:setVisible(false);
end

--energytarget的状态
function CEnergyBody:isTargetShow()
	return self.m_armatureEnergyTarget:isVisible();
end

return CEnergyBody
