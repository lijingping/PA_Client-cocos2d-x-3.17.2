local BattleResourceMgr = require("app.utils.BattleResourceMgr")
local CFort = import(".CFort");
local Tips = require("app.views.common.Tips");

CShip = class("CShip", cc.Node)


local FortPosY  = {180, 40, -100};
-- shipPps 1代表自己，2代表敌人
function CShip:ctor(shipID, shipPos, ccbBattle)
	-- print(" CShip:ctor(shipID, shipPos)",shipID, shipPos)
	self.m_ccbBattle = ccbBattle;
	self.m_shipPos = shipPos;

	if  shipPos == 1 then
		self.m_shipIndex = 0;
	else
		self.m_shipIndex = 1;
	end
	--飞船动画 -> 这边先添加不播放
	self.m_armatureShip = BattleResourceMgr:getShipArmatureByShipID(shipID);
	self:addChild(self.m_armatureShip, 1, 1);
	if BattleDataMgr:getBattleType() ~= 3 then
		self.m_armatureShip:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				self:movementEventComplete(movementID);
			end
		end)
	end

	self.m_myFort = {};
	self.m_enemyFort = {};

	if shipPos == 1 then
		for i = 1, 3 do --fort位置：上1， 中2， 下3 (索引1，2，3)
			self.m_myFort[i] = CFort:create(BattleDataMgr:getFortIDByfortPos(i , shipPos), 1, i);
			self:addChild(self.m_myFort[i], 10 + i, 10 + i);
			self.m_myFort[i]:setPosition(0, FortPosY[i]);
			self.m_myFort[i]:setVisible(false);
		end
	else
		for i = 1, 3 do
			self.m_enemyFort[i] = CFort:create(BattleDataMgr:getFortIDByfortPos(i, shipPos), 2, i);
			self:addChild(self.m_enemyFort[i], 10 + i, 10 + i);
			self.m_enemyFort[i]:setPosition(0, FortPosY[i]);
			self.m_enemyFort[i]:setVisible(false);
		end
	end
	--飞船甲板展开动画
	self.m_armatureDeck = BattleResourceMgr:getDeckArmatureByShipID(shipID);
	self:addChild(self.m_armatureDeck, 100, 100);
	self.m_armatureDeck:setVisible(false);
	
	if shipPos ~= 1 then --如果不在左边，则将飞船动画和甲板做水平翻转
		self.m_armatureShip:setScaleX(-1);
		self.m_armatureDeck:setScaleX(-1);
	end

	--可点击的区域特效
	if shipPos == 1 then
		self.m_armatureTarget = BattleResourceMgr:getTargetShipPlayer();
	else
		self.m_armatureTarget = BattleResourceMgr:getTargetShipEnemy();
	end
	self:addChild(self.m_armatureTarget, 200, 200);
	self.m_armatureTarget:setVisible(false);

	--战舰摧毁动画
	self.m_armatureShipDestroy = BattleResourceMgr:getShipDestroyArmature();
	if self.m_armatureShipDestroy then
		self:addChild(self.m_armatureShipDestroy, 300, 300);
		self.m_armatureShipDestroy:setVisible(false);
		self.m_armatureShipDestroy:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
			if evt == "destroyShip" then
				self.m_armatureShip:setVisible(false);
				if shipPos == 1 then 
					for i = 1, 3 do
						if self.m_myFort[i] then
							self.m_myFort[i]:setVisible(false);
						end
					end
				else
					for i = 1, 3 do
						if self.m_enemyFort[i] then
							self.m_enemyFort[i]:setVisible(false);
						end
					end
				end
			end
		end)
	end 
end

function CShip:setEffectSkillAndCloud(ccbNodeEffectSkill, ccbNodeCloud)
	if self.m_shipPos == 1 then
		for i=1,3 do
			self.m_myFort[i]:setEffectSkill(ccbNodeEffectSkill);
			self.m_myFort[i]:setCloudNode(ccbNodeCloud);
		end
	else
		for i=1,3 do
			self.m_enemyFort[i]:setEffectSkill(ccbNodeEffectSkill);
			self.m_enemyFort[i]:setCloudNode(ccbNodeCloud);
		end
	end
	
end

function CShip:playBegin()
	if self.m_shipPos == 1 then
		self.m_armatureShip:getAnimation():play("begin_enter");
	else
		self.m_armatureShip:getAnimation():play("begin_back");
	end
end

function CShip:playShipIdle()
	self.m_armatureShip:getAnimation():play("idle");
end

function CShip:playIdle()
	-- print("CShip:playIdle");
	self:playShipIdle();
	self.m_armatureDeck:setVisible(false);

	if self.m_shipPos == 1 then 
		for i = 1, 3 do
			if self.m_myFort[i] then
				self.m_myFort[i]:setVisible(true);
				self.m_myFort[i]:playStart();
			end
		end
	else
		for i = 1, 3 do
			if self.m_enemyFort[i] then
				self.m_enemyFort[i]:setVisible(true);
				self.m_enemyFort[i]:playStart();
			end
		end
	end
end

function CShip:playDestroy()
	Audio:playEffect(109, false);
	self.m_armatureShipDestroy:setVisible(true);
	self.m_armatureShipDestroy:getAnimation():play("anim01");
end

--飞船的动画结束事件
function CShip:movementEventComplete(movementID)
	if movementID == "begin_enter"  or movementID == "begin_back" then
		print("飞船的动画结束事件 ---------------  3");
		self.m_armatureShip:getAnimation():play("idle");
		if self.m_shipPos == 1 then
			self:getParent():getParent():showVS();
		end
		local function openDeck()
			self:openDeck();
		end
		local delayTask = cc.Sequence:create(cc.DelayTime:create(2), cc.CallFunc:create(openDeck));
		self:runAction(delayTask);
	end
end

--飞船甲板展开动画
function CShip:openDeck()

	if self.m_shipPos == 1 then 
		for i = 1, 3 do
			if self.m_myFort[i] then --123和456不会同时都存在于一个ship里，有123则没有456，这里可能123不存在或者456不存在
				--显示炮台，炮台在甲板层的下方
				self.m_myFort[i]:setVisible(true);
			end
		end
	else
		for i = 1, 3 do
			if self.m_enemyFort[i] then
				self.m_enemyFort[i]:setVisible(true);
			end
		end
	end
	--显示甲板并展开
	self.m_armatureDeck:setVisible(true);	
	self.m_armatureDeck:getAnimation():play("anim01");
	self.m_armatureDeck:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			if self.m_shipPos == 1 then
				for i = 1, 3 do
					if self.m_myFort[i] then
						self.m_myFort[i]:playStart(); --展开甲板后炮台再展开
					end
				end
			else
				for i = 1, 3 do
					if self.m_enemyFort[i] then
						self.m_enemyFort[i]:playStart();
					end
				end
			end
		end
	end);
end

--显示炮台的状态，战斗飞船入场时隐藏，显示UI时再显示出来
function CShip:showFortState()
	if self.m_shipPos == 1 then
		for i = 1, 3 do
			if self.m_myFort[i] and self.m_myFort[i]:isVisible() then
				self.m_myFort[i]:showState();
			end
		end
	else
		for i = 1, 3 do 
			if self.m_enemyFort[i] and self.m_enemyFort[i]:isVisible() then
				self.m_enemyFort[i]:showState();
			end
		end
	end
end


function CShip:isFortAliveByfortPos(fortPos)
	if self.m_shipPos == 1 then
		if self.m_myFort[fortPos] then
			return self.m_myFort[fortPos]:isAlive();
		else
			print("判断炮台是否存活时出错了。我方战舰此位置不存在炮台:", fortPos);
			return false;
		end
	else
		if self.m_enemyFort[fortPos] then
			return self.m_enemyFort[fortPos]:isAlive();
		else
			print("判断炮台是否存活时出错了。敌方战舰此位置不存在炮台:", fortPos);
			return false;
		end
	end
end

function CShip:isFullSpByfortPos(fortPos)
	if self.m_shipPos == 1  then 
		if self.m_myFort[fortPos] then
			return self.m_myFort[fortPos]:isFullSp();
		else
			print("判断炮台能量是否满时出错了。我方战舰此位置不存在炮台:", fortPos);
			return false;
		end
	else
		if self.m_enemyFort[fortPos] then
			return self.m_enemyFort[fortPos]:isFullSp();
		else
			print("判断炮台能量是否满时出错了。敌方战舰此位置不存在炮台:", fortPos);
			return false;
		end
	end
end

--获取炮台的fortIndex，使用物品时调用，发给服务器, fortIndex(123456)
function CShip:getFortIndexByPos(fortPos)
	if self.m_shipPos == 1 then
		if fortPos == 1 then
			return 1;
		elseif fortPos == 2 then
			return 2;
		elseif fortPos == 3 then
			return 3;
		end
	else
		if fortPos == 1 then
			return 4;
		elseif fortPos == 2 then
			return 5;
		elseif fortPos == 3 then
			return 6;
		end
	end
end

-- function CShip:getFortPosByIndex(fortIndex)
-- 	if self.m_shipPos == 1 then
-- 		if fortIndex == 1 then
-- 			return 1;
-- 		elseif fortIndex == 2 then
-- 			return 2;
-- 		elseif fortIndex == 3 then
-- 			return 3;
-- 		end
-- 	else
-- 		if fortIndex == 4 then
-- 			return 4;
-- 		elseif fortIndex == 5 then
-- 			return 5;
-- 		elseif fortIndex == 6 then
-- 			return 6;
-- 		end
-- 	end
-- end

--刷新炮台状态
function CShip:updatePlayerFort()
	for i = 1, 3 do
		if self.m_myFort[i] and self.m_myFort[i]:isVisible() then
			self.m_myFort[i]:updatePlayerFortInfo(i);
		end
	end	
end

function CShip:updateEnemyFort()
	for i= 1, 3 do
		if self.m_enemyFort[i] and self.m_enemyFort[i]:isVisible() then
			self.m_enemyFort[i]:updataEnemyFortInfo(i);
		end
	end
end


function CShip:hideAllTarget()
	self:hideShipTarget();
	self:hideFortTarget();
end

function CShip:showShipTarget()
	self.m_armatureTarget:setVisible(true);
	self.m_armatureTarget:getAnimation():play("anim01");
end

function CShip:hideShipTarget()
	self.m_armatureTarget:setVisible(false);
end

--显示存活的炮台目标
function CShip:showAliveFortTarget()

	if self.m_shipPos == 1 then
		for i = 1, 3 do
			if self.m_myFort[i] and self.m_myFort[i]:isVisible() and self.m_myFort[i]:isAlive() then
				self.m_myFort[i]:showTarget();
			end
		end
	else
		for i = 1, 3 do
			if self.m_enemyFort[i] and self.m_enemyFort[i]:isVisible() and self.m_enemyFort[i]:isAlive() then
				self.m_enemyFort[i]:showTarget();
			end
		end
	end
end

function CShip:showDestroyFortTarget()
	if self.m_shipPos == 1 then 
		local countDestroyFort = 0;
		for i = 1, 3 do
			if self.m_myFort[i] and self.m_myFort[i]:isVisible() and self.m_myFort[i]:isAlive() == false then
				self.m_myFort[i]:showTarget();
				countDestroyFort = countDestroyFort + 1;
			end
		end
		if countDestroyFort == 0 then
			Tips:create(Str[11003]);
			local sequence = cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
					self.m_ccbBattle:cancelBottonAllSelectForNoUse();
				end));
			self:runAction(sequence);
		end
	else
		for i = 1, 3 do
			if self.m_enemyFort[i] and self.m_enemyFort[i]:isVisible() and self.m_enemyFort[i]:isAlive() == false then
				self.m_enemyFort[i]:showTarget();
			end
		end
	end
end

function CShip:hideFortTarget()
	if self.m_shipPos == 1 then
		for i = 1, 3 do
			if self.m_myFort[i] and self.m_myFort[i]:isVisible() then
				self.m_myFort[i]:hideTarget();
			end
		end	
	else
		for i = 1, 3 do
			if self.m_enemyFort[i] and self.m_enemyFort[i]:isVisible() then
				self.m_enemyFort[i]:hideTarget();
			end
		end	
	end
end

function CShip:isFortTargetShow(fortPos)
	if self.m_shipPos == 1 then
		if self.m_myFort[fortPos] and self.m_myFort[fortPos]:isVisible() then
			return self.m_myFort[fortPos]:isTargetShow();
		else
			print("Error: ship", self.m_shipPos, "have not fortPos", fortPos);
		end
	else
		if self.m_enemyFort[fortPos] and self.m_enemyFort[fortPos]:isVisible() then
			return self.m_enemyFort[fortPos]:isTargetShow();
		else
			print("Error: ship", self.m_shipPos, "have not fortPos", fortPos);
		end
	end
end

function CShip:isShiptargetShow()
	if self.m_armatureTarget then
		return self.m_armatureTarget:isVisible();
	end
end

return CShip