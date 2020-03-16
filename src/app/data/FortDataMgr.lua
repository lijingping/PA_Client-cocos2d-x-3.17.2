local FortDataMgr = class("FortDataMgr")

function FortDataMgr:Init()
	self.m_dataBase = table.clone(require("app.constants.fort_list"))
	self.m_fortConst = table.clone(require("app.constants.fort_factor"))
	self.m_skillInfo = table.clone(require("app.constants.fort_skill"))
	self.m_advanceInfo = table.clone(require("app.constants.fort_advance"))

	self.m_fortState={};
	self.m_shipForts={};-- 战舰炮台
	self.m_equipForts = {};--装备炮台

	self:getMatchedData()

	-- dump(self.m_dataBase);
	-- dump(self.m_fortConst);
	-- dump(self.m_advanceInfo);
end

--进阶表
function FortDataMgr:getAdvanceInfo()
	return self.m_advanceInfo;
end 

--获得炮台基础信息
function FortDataMgr:getFortBaseInfo(fortID)
	return self.m_dataBase[tostring(fortID)];
end

--获得炮台类型
function FortDataMgr:getFortBaseType(fortID)
	return self.m_dataBase[tostring(fortID)].fort_type;
end

--获得炮台specialID
function FortDataMgr:getFortBaseSpecialID(fortID)
	return self.m_dataBase[tostring(fortID)].id;
end

--获得炮台名字
function FortDataMgr:getFortBaseName(fortID)
	return self.m_dataBase[tostring(fortID)].frot_name;
end

--通过技能ID获得技能信息
function FortDataMgr:getSkillInfoBySkillID(skillID)
	return self.m_skillInfo[tostring(skillID)];
end

--通过炮台ID获得技能信息
function FortDataMgr:getSkillInfoByFortID(fortID)
	-- print("炮台ID = ",  fortID);
	local skillID = self.m_dataBase[tostring(fortID)].skill_id;
	return self.m_skillInfo[tostring(skillID)];
end

--获得当前技能等级的对应伤害值
function FortDataMgr:getSkillDamageDesc(skillID,skillLevel)
	local skillDamage = tonumber(self.m_skillInfo[tostring(skillID)].atk_base.skill_damage);
	-- print("FortDataMgr:getSkillDamageDesc() skillDamage = ", skillDamage)
	if skillLevel == 1 then	
		return tonumber(string.format("%d", skillDamage));
	else
		skillDamage = skillDamage + skillLevel*self.m_skillInfo[tostring(skillID)].atk_factor*self.m_skillInfo[tostring(skillID)].type_atkfactor*100;
		-- print("skillLevel ~= 1, skillDamage = ", skillDamage)
		return tonumber(string.format("%d", skillDamage));
	end
end

--获得当前技能等级的对应buff命中概率
function FortDataMgr:getSkillBuffHitRate(skillID, skillLevel)
	local skillHitRate = tonumber(self.m_skillInfo[tostring(skillID)].atk_base.buff_hitrate);
	if skillHitRate == 0 or skillHitRate == nil then
		print("技能命中概率不存在");
		return;
	end
	if skillLevel == 1 then
		return tonumber(string.format("%0.2f", skillHitRate));
	else
		local hittype_factor = self.m_skillInfo[tostring(skillID)].hittype_factor;
		local hitgrow_factor = self.m_skillInfo[tostring(skillID)].hitgrow_factor;
		local hit_compensate = self.m_skillInfo[tostring(skillID)].hit_compensate;
		skillHitRate = skillHitRate + skillLevel*hittype_factor*hitgrow_factor*hit_compensate*100;
		return tonumber(string.format("%0.2f", skillHitRate));
	end
end

--获得技能等级对应的Buff影响效果
function FortDataMgr:getSkillBuffEffect(skillID, skillLevel)
	local skillEffect = tonumber(self.m_skillInfo[tostring(skillID)].atk_base.buff_effect);
	if skillEffect == 0 then
		print("技能效果不存在")
		return
	end
	if skillLevel == 1 then
		return tonumber(string.format("%0.2f", skillEffect));
	else
		local effectgrow_factor = self.m_skillInfo[tostring(skillID)].effectgrow_factor;
		local effecttype_factor = self.m_skillInfo[tostring(skillID)].effecttype_factor;
		local effect_compensate = self.m_skillInfo[tostring(skillID)].effect_compensate;
		skillEffect = skillEffect + skillLevel*effectgrow_factor*effecttype_factor*effect_compensate*100;
		return tonumber(string.format("%0.2f", skillEffect));
	end
end

--获得技能等级对应Buff效果时间
function FortDataMgr:getSkillEffectTime(skillID, skillLevel)
	local skillDuration = tonumber(self.m_skillInfo[tostring(skillID)].atk_base.buff_duration);
	if skillDuration == 0 then
		print("持续时间不存在")
		return
	end
	if skillLevel == 1 then
		return tonumber(string.format("%0.2f", skillDuration));
	else
		local timegrow_factor = self.m_skillInfo[tostring(skillID)].timegrow_factor;
		local timetype_factor = self.m_skillInfo[tostring(skillID)].timetype_factor;
		local time_compensate = self.m_skillInfo[tostring(skillID)].time_compensate;
		skillDuration = skillDuration + skillLevel*timegrow_factor*timetype_factor*time_compensate;
		return tonumber(string.format("%0.2f", skillDuration));
	end
end

--炮台分类
function FortDataMgr:getMatchedData()
	print("炮台分类")
	self.m_atkFort = {}
	self.m_defFort = {}
	self.m_skillFort = {}
	for k,v in pairs(self.m_dataBase) do
		if v.fort_type == 1 then
			-- self.m_atkFort[v.id] = {}
			-- self.m_atkFort[v.id] = v
			table.insert(self.m_atkFort, v)
		elseif v.fort_type == 2 then
			-- self.m_defFort[v.id] = {}
			-- self.m_defFort[v.id] = v
			table.insert(self.m_defFort,v)
		elseif v.fort_type == 3 then
			-- self.m_skillFort[v.id] = {}
			-- self.m_skillFort[v.id] = v
			table.insert(self.m_skillFort,v)
		end
	end
	-- dump(self.m_atkFort)
	-- dump(self.m_defFort)
	-- dump(self.m_skillFort)
end

function FortDataMgr:getAtkFortData()
	return self.m_atkFort;
end

function FortDataMgr:getDefFortData()
	return self.m_defFort;
end

function FortDataMgr:getSkillFortData()
	return self.m_skillFort;
end

-------------------解锁炮台------------------------
--战舰解锁炮台(logingScene)
function FortDataMgr:setUnlockFortsData(fortData)
	for k,v in pairs(fortData.forts) do
		self:addUnlockFortData(v)
	end
end

--添加战舰解锁炮台战舰
function FortDataMgr:addUnlockFortData(info)
	if self.m_shipForts[info.fort_id] == nil then
		self.m_shipForts[info.fort_id] = {};
		self.m_shipForts[info.fort_id].exp = info.exp;
		self.m_shipForts[info.fort_id].id = info.fort_id;
		self.m_shipForts[info.fort_id].level = info.level;
		self.m_shipForts[info.fort_id].quality = info.quality;
		self.m_shipForts[info.fort_id].skill_id = info.skill_id;
		self.m_shipForts[info.fort_id].skill_level = info.skill_level;
	else
		
		self:upDateUnlockFortData(info)
	end
	-- dump(self.m_shipForts)
end

--更新解锁炮台
function FortDataMgr:upDateUnlockFortData(info)
	self.m_shipForts[info.fort_id].exp = info.exp;
	self.m_shipForts[info.fort_id].id = info.fort_id;
	self.m_shipForts[info.fort_id].level = info.level;
	self.m_shipForts[info.fort_id].quality = info.quality;
	self.m_shipForts[info.fort_id].skill_id = info.skill_id;
	self.m_shipForts[info.fort_id].skill_level = info.skill_level;
end

--解锁炮台数据
function FortDataMgr:getUnlockFortData()
	return self.m_shipForts;
end

function FortDataMgr:getUnlockFortDataByID(fortID)
	return self.m_shipForts[fortID]
end

--解锁炮台等级
function FortDataMgr:getUnlockFortLevel(fortID)
	-- print("FortDataMgr:getUnlockFortLevel(fortID)",fortID);
	-- dump(self.m_shipForts);
	return self.m_shipForts[fortID].level
end

--解锁炮台技能ID
function FortDataMgr:getUnlockFortSkillID(fortID)
	return self.m_shipForts[fortID].skill_id;
end

--解锁炮台的EXP
function FortDataMgr:getUnlockFortExp(fortID)
	return self.m_shipForts[fortID].exp;
end

--解锁炮台的技能等级
function FortDataMgr:getUnlockFortSkillLevel(fortID)
	return self.m_shipForts[fortID].skill_level;
end

--炮台是否解锁 解锁true,锁false
function FortDataMgr:isUnlockFort(fortID)
	if self.m_shipForts[fortID] ~= nil then
		return true;
	else
		return false;
	end
end

function FortDataMgr:setSelectedFort(fortID)
	self.m_selectedFort = fortID;
end

function FortDataMgr:getSelectedFort()
	return self.m_selectedFort;
end

-----------------战舰装备炮台----------------------------
--我方战舰装备炮台信息 （位置 012，类型：攻击0，防御1，技能2）
function FortDataMgr:setEquipFortsTableNone()
	self.m_equipForts = {};
end

function FortDataMgr:setShipFortsInfo(info)
	if info.forts == nil then
		info.pos = info.pos - 1;			--装备炮台位置要减一
		self:addNewEquipFort(info) 
	else
		for k,v in pairs(info.forts) do
			v.pos = k - 1;			--装备炮台位置要减一
			self:addNewEquipFort(v) 
		end
	end
	-- print("装备炮台信息");
	-- dump(self.m_equipForts);
end

function FortDataMgr:addNewEquipFort(info)
	-- dump(info)
	if self.m_equipForts[info.fort_id] == nil then
		self.m_equipForts[info.fort_id] = {};
		self.m_equipForts[info.fort_id].isMe = true; 
		self.m_equipForts[info.fort_id].pos = info.pos;
		self.m_equipForts[info.fort_id].fort_id = info.fort_id;
		self.m_equipForts[info.fort_id].skill_id = info.skill_id;
		self.m_equipForts[info.fort_id].level = info.level;
	else
		self:UpDateEquipFort(info)
	end
	-- dump(self.m_equipForts)
end

function FortDataMgr:UpDateEquipFort(info)
	self.m_equipForts[info.fort_id].isMe = true; 
	if info.pos ~= nil then
		self.m_equipForts[info.fort_id].pos = info.pos;
	end
	self.m_equipForts[info.fort_id].fort_id = info.fort_id;
	self.m_equipForts[info.fort_id].skill_id = info.skill_id;
	self.m_equipForts[info.fort_id].level = info.level;
end

function FortDataMgr:getEquipFortData()
	return self.m_equipForts;
end

--根据位置获得战舰炮台信息
function FortDataMgr:getShipFortsInfo(fortID)
	return self.m_equipForts[fortID];
end

--根据ID获得装备炮台等级
function FortDataMgr:getEquipFortLv(fortID)
	return self.m_equipForts[fortID].level;
end

--根据位置获得装备炮台技能
function FortDataMgr:getEquipFortSkill(fortID)
	return self.m_equipForts[fortID].skill_id;
end

--根据ID获得装备炮台的位置
function FortDataMgr:getEquipFortPos(fortID)
	return self.m_equipForts[fortID].pos;
end

--是否可移动炮台
function FortDataMgr:setIsMoveFort(boolean)
	self.m_isMoveFort = boolean
end

function FortDataMgr:getIsMoveFort()
	return self.m_isMoveFort;
end

-----------------------------------------------
-- 获得FortConst
function FortDataMgr:getFortConst(fortID, fortLevel)
	-- print("FortDataMgr:getFortConst", fortID,fortLevel)
	local fortType = self.m_dataBase[tostring(fortID)].fort_type;
	-- print("fortType = ", fortType)
	for k,v in pairs(self.m_fortConst) do
		if v.type == fortType then
			if fortLevel <= 20 then
				if v.quality == 1 then
					return v;
				end
			elseif fortLevel <= 40 then
				if v.quality == 2 then
					return v;
				end
			elseif fortLevel <= 60 then
				if v.quality == 3 then
					return v;
				end
			elseif fortLevel <= 80 then
				if v.quality == 4 then
					return v;
				end
			elseif fortLevel < 100 then 
				if v.quality == 5 then
					return v;
				end
			end
		end
	end
end

--已解锁炮塔品质
function FortDataMgr:getUnlockFortQuality(fortID)
	-- local level = self:getUnlockFortLevel(fortID);
	-- return self:getFortConst(fortID, level).quality;
	return self.m_shipForts[fortID].quality;
end

--星域系数
function FortDataMgr:getStarConst(fortID)
	-- print("FortDataMgr:starConst", fortID);
	return self.m_dataBase[tostring(fortID)].star_const;
end

--攻击成长系数
function FortDataMgr:getAtkFactor(fortID,fortLevel)
	-- print("FortDataMgr:getAtkFactor", fortID,fortLevel);
	local fortConst = self:getFortConst(fortID,fortLevel);
	local atkFactor = fortConst.atk_factor;
	-- print("攻击成长系数", atkFactor);
	return atkFactor; 
end

--生命成长系数
function FortDataMgr:getHpFactor(fortID,fortLevel)
	-- print("FortDataMgr:getHpFactor", fortID)
	local fortConst = self:getFortConst(fortID,fortLevel);
	local hpFactor = fortConst.hp_factor;
	return hpFactor;
end

--能量系数
function FortDataMgr:getEnergyFactor(fortID,fortLevel)
	-- print("FortDataMgr:getEnergyFactor", fortID,fortLevel)
	local fortConst = self:getFortConst(fortID,fortLevel);
	local energyFactor = fortConst.energy_factor;
	return energyFactor;
end

--品质系数
function FortDataMgr:getQualityFactor(fortID,fortLevel)
	-- print("FortDataMgr:getQualityFactor", fortID,fortLevel)
	local fortConst = self:getFortConst(fortID,fortLevel);
	local qualityFactor = fortConst.quality_factor;
	return qualityFactor;
end

--攻速
function FortDataMgr:getAtkSpeedFactor(fortID,fortLevel)
	-- print("FortDataMgr:getAtkSpeedFactor",fortID,fortLevel)
	local fortConst = self:getFortConst(fortID,fortLevel);
	local atkSpeedFactor = fortConst.atk_speed_factor;
	return atkSpeedFactor;
end

--攻击
function FortDataMgr:attack(fortID, fortLevel)
	-- print("FortDataMgr:attack(fortID,fortLevel)", fortID, fortLeve)
	local qualityFactor = self:getQualityFactor(fortID,fortLevel);
	local starConst = self:getStarConst(fortID);
	local atkFactor = self:getAtkFactor(fortID,fortLevel); -- 暂定的攻击成长系数(需要读表)
	local initialAtk = 100 * self:getQualityFactor(fortID, 1) * starConst * atkFactor; -- 初始攻击力
	local fortAttack = initialAtk;

	if fortLevel > 1 then 
		fortAttack = initialAtk+(10*fortLevel)*qualityFactor*starConst*atkFactor
	end
	return fortAttack;
end

-- 生命值
function FortDataMgr:healthPoint(fortID,fortLevel)
	-- print("********** FortDataMgr:healthPoint(fortID,fortLevel)", fortID, fortLevel)
	local battleTime = 120; -- 暂定战斗时间
	local starConst = self:getStarConst(fortID);
	local qualityFactor = self:getQualityFactor(fortID,fortLevel);
	local hpFactor = self:getHpFactor(fortID,fortLevel); --暂定生命成长系数
	local fortAttack = self:attack(fortID,fortLevel);
	-- print("fortAttack(攻击):", fortAttack, "battleTime:", battleTime, "fortLevel(等级):", fortLevel, "hpFactor(生命系数):", hpFactor, "qualityFactor(品质系数):", qualityFactor, "星域系数:", starConst);
	--生命值 = 攻击X(战斗时间+炮台等级)X生命成长系数X质量系数X星域系数
	local healthPoint = fortAttack*(battleTime-fortLevel*0.1)*hpFactor*qualityFactor*starConst;
	return healthPoint;
end

--防御
function FortDataMgr:defence(fortID,fortLevel)
	local healthPoint = self:healthPoint(fortID,fortLevel);
	local fortDefence = 0.05*healthPoint;
	return fortDefence;
end

--造成伤害
function FortDataMgr:FortDamage(fortID,fortLevel)
	local fortAttack = self:attack(fortID,fortLevel);
	local damage = fortAttack*2 - fortAttack*100/(fortLevel*10+100);
	return damage;
end

-- 免伤率
function FortDataMgr:reduceDamage(fortID,fortLevel)
	local fortDefence = self:defence(fortID,fortLevel);
	local avoidDamage = (fortDefence/300+1)*0.01;
end

return FortDataMgr