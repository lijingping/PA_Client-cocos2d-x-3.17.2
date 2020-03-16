local BattleResourceMgr = require("app.utils.BattleResourceMgr")

local CCBFortState = class("CCBFortState", function ()
    return CCBLoader("ccbi/battle/CCBFortState.ccbi")
end)
------------------------------------------------------------------
------------------------------------------------------------------
	-- 炮台基本数据
    -- ["$fort_id"] = 90001,
    -- advanced_id = 90020,
    -- special_id = 90001,
    -- type = "alpha",
    -- name = "零式刀锋",
    -- desc = "NO.1炮台",
    -- icon_id = 90001,
    -- unlock = "unlock",
    -- quality = "D",
    -- level = 1,
    -- hp = 2203,
    -- attack_low = 24.4,
    -- attack_high = 27,
    -- duration = 0,
    -- frequency = 0.7,
    -- speed = 600,
    -- energy = 100,
    -- energy_conversion = 0.27,
    -- rock_conversion = 1,
    -- skill_id = 50001,
    -- skill_time = 1.5

---------------------华--丽--丽--的--分割--线-------------------------------------

    --技能表结构
    -- ["$skill_id"] = 50001,
    -- name = "死亡切割",
    -- desc = "对单体目标造成XXX%的技能伤害，并对目标附加持续一段时间的动力干扰状态。",
    -- skillicon_id = 50001,
    -- level = 1,
    -- required_items = {
    --   {
    --     item_id = 0,
    --     count = 1
    --   }
    -- },
    -- attack_mode = "indirect",
    -- damage = {
    --   text = "880%",
    --   relative = 880.0,
    --   absolute = nil
    -- },
    -- target = 0,
    -- buff_target = 0,
    -- chance = 100,
    -- buff = {
    --   buff_name = "de_speed",
    --   buff_arg_percent = 0.12,
    --   buff_arg_delta = 0,
    --   args = {
    --     {
    --       percent = 0.12,
    --       delta = 0
    --     }
    --   }
    -- },
    -- condition = 6
------------------------------------------------------------------
------------------------------------------------------------------

function CCBFortState:ctor(fortID, shipPos)
	self.m_armatureSPFull = nil;

    if shipPos == 1 then
        self.m_isEnemy = false;
    else
        self.m_isEnemy = true;
    end

	--血条和能量条 	
 	self.m_spriteHP = cc.ProgressTimer:create(cc.Sprite:create("res/resources/battle/pvp_hp1_part3.png"));
    self.m_spriteHP:setType(cc.PROGRESS_TIMER_TYPE_RADIAL);
    self.m_spriteHP:setReverseDirection(true);
    -- self.m_spriteHP:setMidpoint(cc.p(0.01, 0.5));
    self.m_spriteHP:setPercentage(100);
    -- self.m_spriteHP:setAnchorPoint(cc.p(0, 0.5));
	self.m_ccbNodeBar:addChild(self.m_spriteHP);

	self.m_spriteSP = cc.ProgressTimer:create(cc.Sprite:create("res/resources/battle/pvp_hp1_part2.png"));
    self.m_spriteSP:setType(cc.PROGRESS_TIMER_TYPE_RADIAL);
    -- self.m_spriteSP:setMidpoint(cc.p(0.99, 0.5));
    self.m_spriteSP:setPercentage(0);
    -- self.m_spriteSP:setAnchorPoint(cc.p(1, 0.5));
	self.m_ccbNodeBar:addChild(self.m_spriteSP);

    self.m_spriteRepair = cc.ProgressTimer:create(cc.Sprite:create("res/resources/battle/ui_pvp_hp07.png"));
    self.m_spriteRepair:setType(cc.PROGRESS_TIMER_TYPE_RADIAL);
    self.m_spriteRepair:setPercentage(0);
    self.m_spriteRepair:setReverseProgress(true);
    -- self.m_spriteHP:setReverseDirection(true);
    self.m_ccbNodeBar:addChild(self.m_spriteRepair);

    -- self.m_ccbSpriteRepair:setVisible(false);

    local fortType = FortDataMgr:getFortBaseType(fortID);
    local typeIcon = cc.Sprite:create(BattleResourceMgr:getBattleFortTypeIcon(fortType));
    self.m_ccbNodeBar:addChild(typeIcon);

    self.m_lastHpPer = 0;
    self.m_lastSpPer = 0;

    self.m_isSpFull = false;
end

function CCBFortState:updateHP(percent)
    if self.m_lastHpPer ~= percent then
        if percent <= 0 then
            -- print("炮台死亡")
            percent = 0;
            self.m_spriteHP:setVisible(false);
            self.m_spriteSP:setVisible(false);
            if self.m_armatureSPFull and self.m_armatureSPFull:isVisible() == true then
                self.m_armatureSPFull:setVisible(false);
                self.m_energyArmature:setVisible(false);
            end
        elseif percent > 1 then
            percent = 1;
        end  
        if percent == 1 then
            -- self.m_ccbSpriteRepair:setVisible(false);
            self.m_spriteHP:setVisible(true);
            self.m_spriteSP:setVisible(true);
        end
        self.m_lastHpPer = percent;
        self.m_spriteHP:setPercentage(50 + percent * 50);
    end
end

function CCBFortState:updateSP(percent)
    if self.m_lastSpPer ~= percent then
        if percent < 0 then
            percent = 0;
        elseif percent > 1 then
            percent = 1;
        end
        self.m_lastSpPer = percent;
        self.m_spriteSP:setPercentage(50 + percent * 50);

        if percent == 1 then
            if not self.m_isEnemy then  
                if self.m_armatureSPFull == nil then
                    self.m_armatureSPFull = BattleResourceMgr:createBattleArmature("fort_skill_full");--state_sp1
                    self.m_armatureSPFull:getAnimation():play("anim01");
                    self:add(self.m_armatureSPFull);
                    self.m_armatureSPFull:setPosition(cc.p(75, 0));
                    self.m_energyArmature = BattleResourceMgr:createBattleArmature("fort_energy_full");
                    self.m_energyArmature:getAnimation():play("anim01");
                    self.m_ccbNodeBar:addChild(self.m_energyArmature);
                    self.m_energyArmature:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
                        if movementType == ccs.MovementEventType.complete then
                            self.m_energyArmature:removeSelf();
                            self.m_energyArmature = nil;
                        end
                    end)

                else
                    self.m_armatureSPFull:setVisible(true);
                    self.m_energyArmature:setVisible(true);
                end
                self.m_isSpFull = true;
            end
        else
            if self.m_armatureSPFull and self.m_armatureSPFull:isVisible() == true then
                self.m_armatureSPFull:setVisible(false);
                self.m_energyArmature:setVisible(false);
            end
            self.m_isSpFull = false;
        end        
    end
end

function CCBFortState:isSpFull()
    return self.m_isSpFull;
end

function CCBFortState:setSpFull(isFull)
    self.m_isSpFull = isFull;
end

function CCBFortState:showRecoverCountTime()
    self.m_isRepairing = true;
    self.m_spriteHP:setVisible(false);
    self.m_spriteSP:setVisible(false);
    if self.m_armatureSPFull and self.m_armatureSPFull:isVisible() == true then
        self.m_armatureSPFull:setVisible(false);
        self.m_energyArmature:setVisible(false);
    end
    -- self.m_ccbSpriteRepair:setVisible(true);
    self.m_spriteRepair:setPercentage(100);
    local function callback()
       self.m_spriteRepair:runAction(cc.ProgressTo:create(10, 0));
    end
       
    local function showHpAndSp()
        -- self.m_ccbSpriteRepair:setVisible(false);
        self.m_spriteHP:setVisible(true);
        self.m_spriteSP:setVisible(true);
        self.m_isRepairing = false
    end
    local seq = cc.Sequence:create(cc.CallFunc:create(callback), cc.DelayTime:create(10), cc.CallFunc:create(showHpAndSp));
    self:runAction(seq)
end

return CCBFortState