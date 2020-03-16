local CEnergyBody = require("app.views.battle.CEnergyBody")
local Tips = require("app.views.common.Tips");

local newEnergyBodyMgr = class("newEnergyBodyMgr")

--能量体事件类型
local ENERGY_LOOP = 0; --能量体生成
local ENERGY_CHANGE = 1; --能量体改变
local ENERGY_JUMP = 2; --能量体跳跃
local ENERGY_BURST = 3; --能量体爆破

function newEnergyBodyMgr:Init(nodeEnergy)
	self.m_nodeParent = nodeEnergy;
	self.m_energyType = nil;
	self.m_energyBody = nil;
	self.m_energyMaxHp = 0;
	self.m_energyHp = 0;
	self.m_energyPosX = 0;
	self.m_energyPosY = 0;

	self.m_energyBody = CEnergyBody:create();
	self.m_nodeParent:addChild(self.m_energyBody);

	-- self.tab = cc.LabelTTF:create("","res/font/simhei.fft", 20);
	-- self.m_nodeParent:addChild(self.tab,50,50);
end

function newEnergyBodyMgr:refresh()
	local energy = newBattle.energyBodyData()
	-- dump(energy)
	-- "<var>" = {
	--     "buffGetter" = 3
	--     "energyType" = 0
	--     "hp"         = 78636.96
	--     "maxHp"      = 78636.96
	--     "x"          = 640
	--     "y"          = 540
	-- }
	if energy == nil then
		return
	else
		self.m_energyBody:setEnergyPosition(energy.x, energy.y);	--设置出现的位置
		self.m_energyBody:energyAscription(energy.buffGetter);		--归属权
		if energy.y ~= self.m_energyPosY then
			self.m_energyPosY = energy.y;
			BattleDataMgr:setEnergyBodyPos(energy.y);
		end
	end
end

function newEnergyBodyMgr:refreshEvent()
	local energyEvent = newBattle.energyBodyEvent();
	if energyEvent == nil then
		return;
	end

	if #energyEvent ~= 0 then
		-- dump(energyEvent)
		-- "<var>" = {
		--     1 = {
		--         "buffGetter" = 3
		--         "energyType" = 0
		--         "eventType"  = 0
		--         "x"          = 640
		--         "y"          = 540
		--     }
		-- }
	end

	for k,v in pairs(energyEvent) do
		if v.eventType == ENERGY_LOOP then 	---0
			-- print("能量loop动画")
			self.m_energyType = v.energyType;
			self.m_energyBody:energyArmature();
			
			self.m_energyBody:setEnergyType(self.m_energyType);

		elseif v.eventType == ENERGY_CHANGE then 	---1
			self.m_energyType = v.energyType;
			self.m_energyBody:setEnergyType(self.m_energyType);

		elseif v.eventType == ENERGY_JUMP then 	---2
			self.m_energyBody:energyPlayJump();
		
		elseif v.eventType == ENERGY_BURST then 	---3
			dump(energyEvent);
			if v.buffGetter == 3 then
				self.m_energyBody:setEnergyGetterNone();
			end
			self.m_energyBody:energyPlayDestroy();
			
			self.m_energyPosY = 0;
			BattleDataMgr:setEnergyBodyPos(0);
		end
	end
end


--点击到能量体
function newEnergyBodyMgr:onTouchBegan(touch, event)
	-- print("点击能量体")
	local function useItemCallBack(rc,data)
		-- dump(data)
		if data.code ~= 1 then
			print("使用道具出错")
		else
			print("成功使用道具")
			-- CCBattle = self.m_nodeParent:getParent();
			-- CCBattle.m_ccbFileBottom:updateItemCount();
		end
	end
	if BattleDataMgr:getCurSelectItemId() ~= 0 then
		if self.m_energyBody and self.m_energyBody:isTargetShow() then
			local sendInfo = {type = 1, name = "use_item", item_id = BattleDataMgr:getCurSelectItemId(), arg = 9};
			-- newBattle.useProp(1, BattleDataMgr:getCurSelectItemId(), 0, 0); 		--测试用

			local battleType = BattleDataMgr:getBattleType();
			if battleType == 0 then   -- 普通战斗
				Network:request("battle.battleHandler.emitEvent", sendInfo, useItemCallBack);
			elseif battleType == 1 then   -- 探险
				Network:request("explore_battle.exploreHandler.emitEvent", sendInfo, useItemCallBack);
			elseif battleType == 2 then	  -- 抢劫贩售舰
				Network:request("loot_battle.lootHandler.emitEvent", sendInfo, useItemCallBack);
			elseif battleType == 3 then	  -- 公域混战
				-- Network:request("domain_battle.domainHandler.emitEvent", sendInfo, useItemCallBack);
			elseif battleType == 4 then   -- 殖民星争夺战
				-- Network:request("battle.battleHandler.emitEvent", sendInfo, useItemCallBack);
			end
		end
	end
end

--显示能量体目标动画
function newEnergyBodyMgr:showTargetEnergy(ccbBattle)
	if BattleDataMgr:getEnergyBodyPos() ~= 0 and self.m_energyBody then
		self.m_energyBody:showTargetEnergy();
	else
		Tips:create(Str[11003]);
		local sequence = cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function() 
			ccbBattle:cancelBottonAllSelectForNoUse(); 
			end));
		ccbBattle:runAction(sequence);
	end
end

--隐藏能量体目标动画
function newEnergyBodyMgr:hideTargetEnergy()
	self.m_energyBody:hideTargetEnergy();
end


function newEnergyBodyMgr:updateEnergyHp(percent)
	if self.m_energyBody then
		self.m_energyBody:setEnergyHp(percent);
		if percent <= 0 then
			if self.m_energyBody.m_isEnergyAlive == false then
				self.m_energyBody:removeSelf();
				self.m_energyBody = nil;
			end
		end
	end
end

return newEnergyBodyMgr