local ResourceMgr = require("app.utils.ResourceMgr");
local Tips = require("app.views.common.Tips");

-------------------
-- 炮台技能升级窗口
-------------------
local CCBFortSkill = class("CCBFortSkill", function ()
	return CCBLoader("ccbi/shipView/CCBFortSkill.ccbi")
end)

function CCBFortSkill:ctor()
	self.m_skillID = -1;
	self.m_fortQuality = "";
	self.m_skillLevel = nil;
	self.m_receiveMoney = -1;
	self:init()
end

function CCBFortSkill:init()
end

function CCBFortSkill:setData(data)
	-- print("CCBFortSkill:setData")
	-- dump(data)
	-- "<var>" = {
	--     "advance_item" = 3001
	--     "fort_desc"    = "NO.1炮台"
	--     "fort_name"    = "零式刀锋"
	--     "fort_type"    = 1
	--     "id"           = 90001
	--     "skill_id"     = 50001
	--     "star_const"   = 1
	-- }
	self.m_data = data
	self.m_fortID = data["id"];

	local skillId = data.skill_id
	local skillLevel = FortDataMgr:getUnlockFortSkillLevel(self.m_fortID)
	-- print("炮台的质量品级:",quality)
	if skillId ~= self.m_skillID or self.m_skillLevel ~= skillLevel or self.m_fortQuality ~= FortDataMgr:getUnlockFortQuality(self.m_fortID) then
		--print("设置技能更新信息")
		self:cleanNode();
		self.m_skillID = skillId;
		self.m_skillLevel = skillLevel;
		-- print("当前的技能等级:", self.m_skillLevel)
		self.m_fortQuality = FortDataMgr:getUnlockFortQuality(self.m_fortID);

		local skillData = FortDataMgr:getSkillInfoBySkillID(skillId)
		-- dump(skillData)
		-- "<var>" = {
		--     "atk_base" = {
		--         "buff_duration" = "0"
		--         "buff_effect"   = "0"
		--         "buff_hitrate"  = "0"
		--         "skill_damage"  = "125"
		--     }
		--     "atk_factor"        = 1
		--     "attack_mode"       = 1
		--     "buff_target"       = 0
		--     "condition"         = 0
		--     "desc"              = "对单体目标造成%d%%伤害"
		--     "effect_compensate" = 1
		--     "effectgrow_factor" = 1
		--     "effecttype_factor" = 1
		--     "hit_compensate"    = 1
		--     "hitgrow_factor"    = 1
		--     "hittype_factor"    = 1
		--     "id"                = 50001
		--     "name"              = "死亡切割"
		--     "targt"             = 0
		--     "time_compensate"   = 1
		--     "timegrow_factor"   = 1
		--     "timetype_factor"   = 1
		--     "type_atkfactor"    = 0.05
		-- }
		-- print("    self.mfortQuality .... ", self.m_fortQuality);
		self.m_isLevelEnough = false;
		self.m_limitInfo = "";
		local limitInfo = nil;
		if self.m_fortQuality == 1 then limitInfo = self.m_skillLevel >= 2 and string.format(Str[7121], 21) or "" end
		if self.m_fortQuality == 2 then limitInfo = self.m_skillLevel >= 4 and string.format(Str[7121], 41) or "" end
		if self.m_fortQuality == 3 then limitInfo = self.m_skillLevel >= 6 and string.format(Str[7121], 61) or "" end
		if self.m_fortQuality == 4 then limitInfo = self.m_skillLevel >= 8 and string.format(Str[7121], 81) or "" end
		if self.m_fortQuality == 5 then 
			-- limitInfo = self.m_skillLevel >= 10 and Str[7122] or "" 
			limitInfo = "";
			self.m_isLevelEnough = true;
			self.label_limitInfo:setString(limitInfo);   
			if self.m_skillLevel >= 10 then
				self.m_ccbBtnUpSkill:setEnabled(false);
				self.m_ccbBtnUpSkill:setVisible(false);
				self.m_ccbSpriteBtnUpgrade:setVisible(false);
				self.m_ccbSpriteBtnGold:setVisible(false);
				self.m_ccbLabelCoinCount:setVisible(false);
				local posX = self.m_ccbBtnUpSkill:getPositionX();
				local posY = self.m_ccbBtnUpSkill:getPositionY();

				local maxLevelSprite = cc.Sprite:create(ResourceMgr:getMaxSkillLevelSprite());
				self:addChild(maxLevelSprite);
				maxLevelSprite:setPosition(cc.p(posX, posY));
			else
				self.m_ccbBtnUpSkill:setEnabled(true);
			end
		else
			self.m_isLevelEnough = limitInfo == "";
			self.m_limitInfo = limitInfo;
			-- self.label_limitInfo:setString(limitInfo);
			-- self.m_ccbBtnUpSkill:setEnabled(buttonEnabled);
		end

		self.m_ccbLabelSkillName:setString(skillData.name .. "（Lv." .. self.m_skillLevel .. "）");

		local haveDataCount = 2;
		local skillDescNum = {};
		-- local tableCount = {};

		local skillDamage = FortDataMgr:getSkillDamageDesc(skillId, self.m_skillLevel);
		-- print("skillDamage",skillDamage);
		local buffHitRate = FortDataMgr:getSkillBuffHitRate(skillId, self.m_skillLevel);
		print("   buffHitRate   命中率。。: ",buffHitRate);
		skillDescNum[1] = buffHitRate;
		local buffEffect = FortDataMgr:getSkillBuffEffect(skillId, self.m_skillLevel);
		-- print("buffEffect",buffEffect);
		skillDescNum[2] = buffEffect;
		local effectTime = FortDataMgr:getSkillEffectTime(skillId, self.m_skillLevel);
		-- print("effectTime", effectTime);
		skillDescNum[3] = effectTime;


		if buffHitRate ~= nil and buffHitRate ~= 100 then
			haveDataCount = haveDataCount + 1;
			self:getChildByTag(haveDataCount):getChildByTag(1):setString(Str[7114] .. buffHitRate.."%");
			if self.m_skillLevel < 10 then
				local buffNextHitRate = FortDataMgr:getSkillBuffHitRate(skillId, self.m_skillLevel + 1); -- 升级后技能命中率
				self:getChildByTag(haveDataCount):getChildByTag(2):setString(buffNextHitRate.."%");
				local upSprite = cc.Sprite:create(ResourceMgr:getUpQualityArrow());
				self:getChildByTag(haveDataCount):getChildByTag(3):addChild(upSprite);
			else
				self:getChildByTag(haveDataCount):getChildByTag(2):setString(buffHitRate .. "%");
				local maxSprite = cc.Sprite:create(ResourceMgr:getFortMaxSprite());
				self:getChildByTag(haveDataCount):getChildByTag(3):addChild(maxSprite);
			end
		end

		if buffEffect ~= nil then
			haveDataCount = haveDataCount + 1;
			self:getChildByTag(haveDataCount):getChildByTag(1):setString(Str[7115] .. buffEffect.."%");
			if self.m_skillLevel < 10 then
				local buffNextEffect = FortDataMgr:getSkillBuffEffect(skillId, self.m_skillLevel + 1); -- 升级后技能效果
				-- print(buffNextEffect)
				self:getChildByTag(haveDataCount):getChildByTag(2):setString(buffNextEffect.."%");
				local upSprite = cc.Sprite:create(ResourceMgr:getUpQualityArrow());
				self:getChildByTag(haveDataCount):getChildByTag(3):addChild(upSprite);
			else
				self:getChildByTag(haveDataCount):getChildByTag(2):setString(buffEffect.."%");
				local maxSprite = cc.Sprite:create(ResourceMgr:getFortMaxSprite());
				self:getChildByTag(haveDataCount):getChildByTag(3):addChild(maxSprite);
			end
		end

		if effectTime ~= nil then
			haveDataCount = haveDataCount + 1;
			self:getChildByTag(haveDataCount):getChildByTag(1):setString(Str[7116] .. effectTime.."s");
			if self.m_skillLevel < 10 then
				local NextEffectTime = FortDataMgr:getSkillEffectTime(skillId, self.m_skillLevel + 1); -- 升级后技能buff持续时间
				self:getChildByTag(haveDataCount):getChildByTag(2):setString(NextEffectTime.."s");
				local upSprite = cc.Sprite:create(ResourceMgr:getUpQualityArrow());
				self:getChildByTag(haveDataCount):getChildByTag(3):addChild(upSprite);
			else
				self:getChildByTag(haveDataCount):getChildByTag(2):setString(effectTime.."s");
				local maxSprite = cc.Sprite:create(ResourceMgr:getFortMaxSprite());
				self:getChildByTag(haveDataCount):getChildByTag(3):addChild(maxSprite);
			end
		end

		self.label_left_1:setString(self.m_skillLevel)
		if self.m_skillLevel < 10 then
			self.label_right_1:setString(self.m_skillLevel+1)
			local upSprite = cc.Sprite:create(ResourceMgr:getUpQualityArrow());
			self.m_ccbNodeDataUpgrade1:addChild(upSprite);
		else
			self.label_right_1:setString(self.m_skillLevel);
			local maxSprite = cc.Sprite:create(ResourceMgr:getFortMaxSprite());
			self.m_ccbNodeDataUpgrade1:addChild(maxSprite);
		end

		self.m_ccbLabelDamageLeft:setString(skillDamage.."%");
		if self.m_skillLevel < 10 then
			local skillNextDamage = FortDataMgr:getSkillDamageDesc(skillId,self.m_skillLevel+1);
			self.m_ccbLabelDamageRight:setString(skillNextDamage.."%");
			local upSprite = cc.Sprite:create(ResourceMgr:getUpQualityArrow());
			self.m_ccbNodeDataUpgrade2:addChild(upSprite);
		else
			self.m_ccbLabelDamageRight:setString(skillDamage.."%");
			local maxSprite = cc.Sprite:create(ResourceMgr:getFortMaxSprite());
			self.m_ccbNodeDataUpgrade2:addChild(maxSprite);
		end

		if 4 - haveDataCount > 0 then
			for i = 1, 4 - haveDataCount do
				self:getChildByTag(5 - i):setVisible(false);
			end
		end

		if self.m_skillLevel < 10 then
			self.m_needLvUpData = table.clone(require("app.constants.skill_upgrade"))[tostring(self.m_skillLevel + 1)].need_items;   --     GameData:get("skill_upgrade", self.m_skillLevel + 1)["need_items"];
			for k,v in pairs(self.m_needLvUpData) do
				self.m_receiveMoney = tonumber(v.count);
				self.m_ccbLabelCoinCount:setString(self.m_receiveMoney);
			end
		else
			self.m_ccbLabelCoinCount:setString("");
		end
	end
end

function CCBFortSkill:cleanNode()
	self.m_ccbNodeDataUpgrade1:removeAllChildren();
	self.m_ccbNodeDataUpgrade2:removeAllChildren();
	self.m_ccbNodeDataUpgrade3:removeAllChildren();
	self.m_ccbNodeDataUpgrade4:removeAllChildren();
	self.m_ccbNodeDataUpgrade5:removeAllChildren();
end

function CCBFortSkill:requestUpgradeFortSkill()
	print("    CCBFortSkill:requestUpgradeFortSkill()    ", self.m_isLevelEnough);
	print("       self.m_limitInfo  ", self.m_limitInfo);
	if self.m_isLevelEnough then
		if UserDataMgr:getPlayerGoldCoin() > self.m_receiveMoney then
			Network:request("game.fortHandler.upgradeFortSkill", {fort_id = self.m_fortID}, function (rc, receivedData)
				print("请求升级炮台技能")
				dump(receivedData);
				if receivedData["code"] ~= 1 then
					Tips:create(GameData:get("code_map", receivedData["code"])["desc"])
					return
				end
				Tips:create("技能等级提升")
				if App:getRunningScene():getChildByTag(150) then
					App:getRunningScene():getChildByTag(150):setDetailSkillDesc(receivedData.fort.skill_id, receivedData.fort.skill_level);
					App:getRunningScene():getChildByTag(150):updataFortViewSkillDesc();
				end
				self:setData(self.m_data);
				self:playUpSkillAnim();
			end)
		else
			Tips:create(Str[4031]);
		end
	else
		Tips:create(self.m_limitInfo);
	end
end

function CCBFortSkill:playUpSkillAnim()
	-- print("    CCBFortQuality:playUpQualityAnim() 播放品质提升动画   ");
	local upSkillAnim = ResourceMgr:getCommonArmature("common_up");
	App:getRunningScene():addChild(upSkillAnim, 200, 200);
	upSkillAnim:setPosition(display.center);
	upSkillAnim:getAnimation():play("anim01");
	upSkillAnim:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			upSkillAnim:removeSelf();
			upSkillAnim = nil;
		end
	end);
end

return CCBFortSkill