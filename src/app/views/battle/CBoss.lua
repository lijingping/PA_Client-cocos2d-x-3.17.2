local CBoss = class("CBoss", cc.Node)
local BattleResourceMgr = require("app.utils.BattleResourceMgr");

function CBoss:ctor(BossID)
	self.m_bossID = BossID;
	self.m_bossStage = 1;

	-- if self.m_bossID == 10000001 then
		self.m_bossArmature = BattleResourceMgr:createBattleArmature("ship_boss");
		-- self:setScale(1.2);
		self:addChild(self.m_bossArmature, 2);
		self.m_bossArmature:setScaleX(-1.2); -- 先反转，再放大1.2倍
		self.m_bossArmature:setScaleY(1.2);

	if BattleDataMgr.m_isBattleExist then
		self.m_bossArmature:setPosition(cc.p(0, 0));
	else
		self.m_bossArmature:setPosition(cc.p(0, display.height * 1.5));
	end

		self.m_bossArmature:getAnimation():play("idle1");
		self.m_bossArmature:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				if movementID == "skill1" then
					self.m_bossArmature:getAnimation():play("idle1");
				elseif movementID == "skill2" then
					self.m_bossArmature:getAnimation():play("idle2");
				elseif movementID == "1change2" then
					self.m_bossArmature:getAnimation():play("idle2");
				elseif movementID == "2change3" then
					self.m_bossArmature:getAnimation():play("idle3");
				elseif movementID == "fire2" then
					self.m_bossArmature:getAnimation():play("idle2");
				elseif movementID == "skill3" then
					print("  技能三   施放完成。 ");
					self.m_bossArmature:getAnimation():play("idle3");
					self:getParent():getParent():stopShakeAction();
				end
			end

		end)

		self.m_bossArmature:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
			if evt == "shake" then
				print(" boss boss ");
				self:getParent():getParent():shakeAction();
			end
		end);

	if BattleDataMgr.m_isBattleExist then
		self.m_bossStage = newBattle.getBossStage().bossStage + 1;
		print("输出boss的状态________", self.m_bossStage);
		if self.m_bossStage == 2 then
			self.m_bossArmature:getAnimation():play("idle2");
		elseif self.m_bossStage == 3 then
			self.m_bossArmature:getAnimation():play("idle3");
		end
	end
-- idle1
-- 1change2
-- idle2
-- 2change3
-- idle3
-- fire1 (普通子弹动画在boss_bullet1)
-- skill1
-- fire2
-- skill2
-- skill3
	

	-- end
-- 可点区域特效
	self.m_armatureTarget = BattleResourceMgr:getTargetShipEnemy();
	self.m_armatureTarget:setScale(1.2);
	self:addChild(self.m_armatureTarget, 3);
	self.m_armatureTarget:setVisible(false);

	-- npc动画

end

function CBoss:shipEnterBattle()
	-- dump(self:getParent());
	-- dump(self:getParent():getParent()); -- battle
	local moveBy = cc.MoveBy:create(5, cc.p(0, -display.height * 1.5));
	local callBack = cc.CallFunc:create(function() 
		Network:request("domain_battle.domainHandler.ready_over", nil, function(rc, data)
			if data.code ~= 1 then
				Tips:create(GameData:get("code_map")[data.code]["desc"]);
			end
		end);
	end)
	local sequence = cc.Sequence:create(moveBy, callBack);
	self.m_bossArmature:runAction(sequence);
end

function CBoss:setEffectSkill(node)
	self.m_nodeEffectSkill = node;
end

function CBoss:showTarget()
	self.m_armatureTarget:setVisible(true);
end

function CBoss:hideTarget()
	self.m_armatureTarget:setVisible(false);
end

function CBoss:isShiptargetShow()
	return self.m_armatureTarget:isVisible();
end

function CBoss:bossFire()
	if self.m_bossArmature then
		if self.m_bossStage == 1 then
			self.m_bossArmature:getAnimation():play("fire1");
			self:bossBulletAnimation();
		elseif self.m_bossStage == 2 then
			self.m_bossArmature:getAnimation():play("fire2");
		end
	end
end

function CBoss:bossBulletAnimation()
	local bulletArmature = BattleResourceMgr:createBattleArmature("boss_bullet1");
	self:addChild(bulletArmature, 1);  -- self.m_nodeEffectSkill
	bulletArmature:setScale(-1);
	bulletArmature:setPosition(-1000, 0);
	bulletArmature:getAnimation():play("anim01");
	bulletArmature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			bulletArmature:removeSelf();
			bulletArmature = nil;
		end
	end)
end

function CBoss:bossSkillFire()
	print("boss play skill  ---------", self.m_bossStage);
	if self.m_bossArmature then
		if self.m_bossStage == 1 then
			self.m_bossArmature:getAnimation():play("skill1");
		elseif self.m_bossStage == 2 then

			self.m_bossArmature:getAnimation():play("skill2");
		elseif self.m_bossStage == 3 then
			self.m_bossArmature:getAnimation():play("skill3");
		end
	end
end

function CBoss:bossChangeStage()
	if self.m_bossArmature then
		if self.m_bossStage == 1 then
			self.m_bossArmature:getAnimation():play("1change2");
		elseif self.m_bossStage == 2 then
			self.m_bossArmature:getAnimation():play("2change3");
		end
	end
	self.m_bossStage = self.m_bossStage + 1;
end

function CBoss:bossChangeOver()
	print("CBoss:bossChangeOver .. self.m_bossStage", self.m_bossStage);
	
	-- if self.m_bossStage == 2 then
	-- 	self.m_bossArmature:getAnimation():play("idle2");
	-- elseif self.m_bossStage == 3 then
	-- 	self.m_bossArmature:getAnimation():play("idle3");
	-- end
end

function CBoss:bossNpc(bossNum) -- 0, 1, 2
	print(" boss npc number .... ", bossNum);

	self.m_npcArmature = BattleResourceMgr:createBattleArmature("boss_npc" .. bossNum);
	self.m_nodeEffectSkill:addChild(self.m_npcArmature);
	self.m_npcArmature:setPosition(cc.p(-480, 0));
	self.m_npcArmature:setScaleX(-1);
	self.m_npcArmature:getAnimation():play("anim01");
	self.m_npcArmature:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			self.m_npcArmature:removeSelf();
			self.m_npcArmature = nil;
		end
	end)

end

function CBoss:bossNpcBack()

end

return CBoss;