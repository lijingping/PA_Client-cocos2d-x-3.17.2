local EscortDataMgr = class("EscortDataMgr")

function EscortDataMgr:Init()
	self.m_merchantShipData = table.clone(require("app.constants.loot_award")) -- 贩售舰的奖励信息
	self.m_curChooseMerchantShip = 0; -- 当前选择的贩售舰
	self.m_escortExist = false;
	self.m_totalSuccessGold = 0;
	self.m_totalSuccessDiamond = 0;
end

--存入当前锁定的商船(登录时服务器发送初始数据) 
function EscortDataMgr:setCurChooseMerchantShip(MerchantShipIndex)
	self.m_curMerchantShipLv = MerchantShipIndex;
end

--获得当前锁定的商船等级
function EscortDataMgr:getCurChooseMerChantShip()
	return self.m_curMerchantShipLv;
end

--存入护送任务开始时的时间
function EscortDataMgr:setEscortTaskTime(remianTime)
	if remianTime ~= nil then
		self.m_remianTime = remianTime;
		if remianTime > 0 then
			self.m_escortExist = true;
		else
			self.m_escortExist = false;
		end
	end
end

--获得护送任务开始时的时间
function EscortDataMgr:getEscortTaskTime()
	return self.m_remianTime;
end

--护送次数
function EscortDataMgr:setEscortNum(escortNum)
	self.m_escortNum = escortNum;
end

function EscortDataMgr:getEscortNum()
	return self.m_escortNum;
end

--剩余打劫次数
function EscortDataMgr:setRemainLootNum(remianLootNum)
	self.m_remianLootNum = remianLootNum;
end

function EscortDataMgr:getRemainLootNum()
	return self.m_remianLootNum;
end

--今日刷新次数
function EscortDataMgr:setRefurbishNum(refurbishNum)
	self.m_refurbishNum = refurbishNum;
end

function EscortDataMgr:getRefurbishNum()
	return self.m_refurbishNum;
end

--当前剩余免费刷新次数
function EscortDataMgr:getRemainFreeRefurbishNum()
	if self.m_refurbishNum < 3 then
		return 3-self.m_refurbishNum
	else
		return 0
	end
end

-- 设置奖励数据
function EscortDataMgr:setMerchantShipData()
	self.m_totalSuccessGold = self.m_merchantShipData[tostring(self.m_curMerchantShipLv)].success_glod;
	self.m_totalSuccessDiamond = self.m_merchantShipData[tostring(self.m_curMerchantShipLv)].success_diamond;
end

--读表获得商船数据
function EscortDataMgr:getMerchantShipData(Index)
	return self.m_merchantShipData[tostring(Index)];
end

-- 统计星际币 (记录用，护送战斗结束 重回页面需要)
function EscortDataMgr:totalGoldCount(gold)
	self.m_totalSuccessGold = self.m_totalSuccessGold + gold; 
end

function EscortDataMgr:getTotalGoldCount()
	return self.m_totalSuccessGold;
end

-- 统计钻石
function EscortDataMgr:totalDiamondCount(diamond)
	self.m_totalSuccessDiamond = self.m_totalSuccessDiamond + diamond;
end

function EscortDataMgr:getTotalDiamondCount()
	return self.m_totalSuccessDiamond;
end

return EscortDataMgr
