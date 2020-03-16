ShipDataMgr = class("ShipDataMgr")

function ShipDataMgr:Init()
	self.m_shipList = table.clone(require("app.constants.ship_list"))

	self.m_shipSkillGrow = table.clone(require("app.constants.shipskill_grow"))

	self.m_shipSkinData = {}
	self.m_shipData = {}
	self.m_usingShipID = 0;
end

--战舰皮肤个数
function ShipDataMgr:ShipListLength()
	return #self.m_shipList;
end

--战舰技能目标
function ShipDataMgr:getShipSkillTarget(shipID)
	return self.m_shipList[tostring(shipID)].target;
end

function ShipDataMgr:getShipList()
	return self.m_shipList;
end

--战舰数据
function ShipDataMgr:getShipData(shipID)
	return self.m_shipList[shipID];
end

--战舰技能升级数据
function ShipDataMgr:getSkillGrowData(shipSkinSkillLv)
	-- dump(self.m_shipSkillGrow)
	return self.m_shipSkillGrow[tostring(shipSkinSkillLv)];
end

function ShipDataMgr:getShipName(shipID)
	-- dump(self.m_shipList);
	-- print("shipDataMgr:getShipName(shipID)", shipID);

	local strShipID = string.format("%s", shipID);
	return self.m_shipList[strShipID].ship_name;
end


--存入解锁战舰皮肤数据
function ShipDataMgr:setShipSkinData(shipInfo)
	-- dump(shipInfo)
	if self.m_shipSkinData[shipInfo.ship_id] == nil then
		self.m_shipSkinData[shipInfo.ship_id] = {};
		self.m_shipSkinData[shipInfo.ship_id].skill_level = shipInfo.skill_level;
		self.m_shipSkinData[shipInfo.ship_id].ship_id = shipInfo.ship_id;
	else
		self:upDateShipSkinData(shipInfo)
	end
end

--更新战舰数据
function ShipDataMgr:upDateShipSkinData(shipInfo)
	self.m_shipSkinData[shipInfo.ship_id].skill_level = shipInfo.skill_level;
	self.m_shipSkinData[shipInfo.ship_id].ship_id = shipInfo.ship_id;
end

function ShipDataMgr:getShipSkinData(shipSkinID)
	return self.m_shipSkinData[shipSkinID];
end

function ShipDataMgr:getUnlockShipSkinSkillLv(shipSkinID)
	if self.m_shipSkinData[shipSkinID] then
		return self.m_shipSkinData[shipSkinID].skill_level;
	else
		return 1;
	end
end

--战舰是否解锁
function ShipDataMgr:isUnlockShipSkin(shipSkinID)
	if self.m_shipSkinData[shipSkinID] then
		return true;
	else
		return false;
	end
end

--解锁战舰皮肤列表
function ShipDataMgr:getUnlockShipSkinData()
	return self.m_shipSkinData;
end

--------------出战战舰数据--------------
function ShipDataMgr:setShipData(shipInfo)
	if shipInfo then
		self.m_shipData = shipInfo;
		self.m_usingShipID = self.m_shipData.ship;
	end 
end

--战舰信息
function ShipDataMgr:getShipData()
	return self.m_shipData;
end

function ShipDataMgr:setUsingShipSkinID(skinID)
	self.m_usingShipID = skinID;
end

function ShipDataMgr:getUseShipID()
	return self.m_usingShipID;
end

function ShipDataMgr:setSkinItem(item)
	self.m_skinItem = item;
end

function ShipDataMgr:getSkinItem()
	return self.m_skinItem;
end

function ShipDataMgr:setSpriteMovePos(pos)
	self.m_movePos = pos;
end

function ShipDataMgr:getSpriteMovePos()
	return self.m_movePos;
end

return ShipDataMgr