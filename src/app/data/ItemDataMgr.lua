---------------------
--物品管理类

local ItemDataMgr = class("ItemDataMgr")
function ItemDataMgr:Init()
	self.m_dataBase = table.clone(require("app.constants.item"));
	self.m_dataBaseEx = table.clone(require("app.constants.item_ex"));

	self.m_allItems = {};
	self.m_playerInfo = {};
	self.m_buy_times = {};
end

function ItemDataMgr:setAllItemInfo(infos)
	-- dump(infos)
	for i, v in pairs(infos.items) do
		if v.item_id > 10000 then
			self:changePlayerInfo(v);
		else
			self:changeItemInfos(v);
		end		
	end
end

function ItemDataMgr:changeItemInfos(itemInfo)
	if itemInfo.item_id > 10000 then 
		return;
	end
	-- if itemInfo.item_id > 4000 then
	-- print("  itemID ...", itemInfo.item_id);
	-- end
	if self.m_allItems[itemInfo.item_id] == nil then
		self.m_allItems[itemInfo.item_id] = {};
		self.m_allItems[itemInfo.item_id].count = itemInfo.item_count;
	else
		self:UpdateItemCount(itemInfo.item_id, itemInfo.item_count)
	end
end

function ItemDataMgr:changePlayerInfo(itemInfo)
	if self.m_playerInfo[itemInfo.item_id] == nil then
		self.m_playerInfo[itemInfo.item_id] = {};
		self.m_playerInfo[itemInfo.item_id].count = itemInfo.item_count;
	else
		self.m_playerInfo[itemInfo.item_id].count = itemInfo.item_count;
	end
end

function ItemDataMgr:setEquipList(data)
	self.m_equipList = {};
	self.m_equipList = data;
end

function ItemDataMgr:UpdateItemCount(itemID, itemCount)
--物品数量更新
	-- print("更新物品数量", itemID, itemCount)
	if itemCount == 0 then
		self:deleteItemByItemID(itemID);
	else
		self.m_allItems[itemID].count = itemCount;
	end	
end

--根据ItemID删除Item
function ItemDataMgr:deleteItemByItemID(itemID)
	if self.m_allItems[itemID] ~= nil then
	 	self.m_allItems[itemID] = nil;
	end
end

--获得资源库item，不包括金币、钻石等
function ItemDataMgr:getAllItems()
	return self.m_allItems;
end

--获得资源库item数量
function ItemDataMgr:getItemCount(itemID)
	-- dump(m_allItems)
	-- dump(m_playerInfo)
	if self.m_allItems[itemID] ~= nil then
		return self.m_allItems[itemID].count;
	elseif self.m_playerInfo[itemID] ~= nil then
		return self.m_playerInfo[itemID].count;
	else
		return 0;
	end
end

-- 根据物品ID获取物品等级
function ItemDataMgr:getItemLevelByID(itemID)
	if self.m_dataBase[tostring(itemID)] ~= nil then
		return self.m_dataBase[tostring(itemID)].level;
	elseif self.m_dataBaseEx[tostring(itemID)] ~= nil then
		return self.m_dataBaseEx[tostring(itemID)].level;
	else
		return 0;
	end
end

-- 根据物品ID获取物品显示的ICON (有等级的物品：导弹)
function ItemDataMgr:getItemIconIDByItemID(itemID)
	if self.m_dataBase[tostring(itemID)] ~= nil then
		return self.m_dataBase[tostring(itemID)].item_icon;
	elseif self.m_dataBaseEx[tostring(itemID)] ~= nil then
		return self.m_dataBaseEx[tostring(itemID)].item_icon;
	else
		return 99999;
	end
end

-- 根据物品ID获取物品显示的名字
function ItemDataMgr:getItemNameByID(itemID)
	if self.m_dataBase[tostring(itemID)] ~= nil then
		return self.m_dataBase[tostring(itemID)].name;
	elseif self.m_dataBaseEx[tostring(itemID)] ~= nil then
		return self.m_dataBaseEx[tostring(itemID)].name;
	else
 		return "";		
	end
end

-- 根据物品ID获取炮台升级经验道具经验值
function ItemDataMgr:getItemFortExpByID(itemID)
	if self.m_dataBase[itemID] ~= nil then
		if self.m_dataBase[itemID].fort_exp ~= nil then
			return self.m_dataBase[itemID].fort_exp;
		end
	else
		print("there is no Item");
		return 0;
	end
end

-- 根据物品ID获取资源库物品数据
function ItemDataMgr:getItemByID(itemID)
	if self.m_allItems[itemID] ~= nil then
		return self.m_allItems[itemID];
	end
end

-- 根据物品ID获取表物品数据
function ItemDataMgr:getItemBaseInfo(itemID)
	if self.m_dataBase[tostring(itemID)] ~= nil then
		return self.m_dataBase[tostring(itemID)];
	elseif self.m_dataBaseEx[tostring(itemID)] ~= nil then
		return self.m_dataBaseEx[tostring(itemID)];
	else
		print("  此物品不存在  物品ID ：", itemID);
		return 0;
	end
end

function ItemDataMgr:getItemBaseExInfo()
	return self.m_dataBaseEx[tostring(itemID)];
end

function ItemDataMgr:getItemUseLimitByID(itemID)
	if self.m_dataBase[tostring(itemID)] ~= nil then
		return self.m_dataBase[tostring(itemID)].use_limit;
	else
		print("读取物品数据出错.找不到该物品,itemID:", itemID);
		return 0;
	end	
end

-------------------通过服务器接收装备信息--------------------------
-- function ItemDataMgr:setAllEquipSlot(data)
-- 	-- dump(data)
-- 	-- self.m_allEquipSlot = {
-- 	-- 						[1] = {item_id = -1, count = 0},
-- 	-- 						[2] = {item_id = 1011, count = 3},
-- 	-- 						[3] = {item_id = 1005, count = 52},
-- 	-- 						[4] = {item_id = 1052, count = 2},
-- 	-- 						[5] = {item_id = -1, count = 0},
-- 	-- 					   }
-- 			{
--               1 = 1004
--               2 = 1104
--               3 = 1107
--               4 = 1204
--               5 = 1304
--           }

-- 	self.m_allEquipSlot = data;
-- end

function ItemDataMgr:getAllEquipSlot()
	return self.m_equipList;
end

function ItemDataMgr:UpdateEquipSlotByPos(pos, itemID, itemCount)
	self.m_equipList[pos].itemID = itemID;
	self.m_equipList[pos].count = itemCount;
end

function ItemDataMgr:getEquipSlotByPos(pos)
	-- print("ItemDataMgr:getEquipSlotByPos", pos);
	if self.m_equipList == nil then
		--self:setAllEquipSlot();
		-- print("没有物品装备信息")
	end
	if self.m_equipList[pos] == nil then
		return -1;
	end
	return self.m_equipList[pos];
end

function ItemDataMgr:isEquipedByItemID(itemID)
	-- print("选中物品的ID是", itemID)
	for k,v in pairs(self.m_equipList) do
		-- print("装备的物品ID",v.itemID)
		if v == itemID then		
			return k;
		end
	end
	return -1;
end

--得到装备信息
function ItemDataMgr:getEquipDataByPos(pos)
	-- print("获取装备的信息")
	if pos == -1 then
		return nil;
	end
	-- dump(self.m_equipList)
	return self.m_dataBase[tostring(self.m_equipList[pos])];
end

--好友许愿选择物品
function ItemDataMgr:setWishSelectCell(itemID)
	self.m_wishSelectItemID = itemID;
end

function ItemDataMgr:getWishSelectCell()
	return self.m_wishSelectItemID;
end

--资源库选中物品
function ItemDataMgr:setCurSelectData(data)
	-- dump(data)
	self.curSelectData = data;
end

function ItemDataMgr:getCurSelectData()
	return self.curSelectData;
end

--资源库点击物品
function ItemDataMgr:setItemData(data)
	-- dump(data)
	self.m_ItemData = data;
end

function ItemDataMgr:getItemData()
	return self.m_ItemData;
end

--根据资源库物品位置获得物品数据
function ItemDataMgr:posSetItemData(data)
	self.posItemData = data;
end

function ItemDataMgr:posGetItemData()
	return self.posItemData;
end

function ItemDataMgr:setDeleteItemID(itemID)
	self.m_deleteItemID = itemID;
end

function ItemDataMgr:getDeleteItemID()
	return self.m_deleteItemID;
end

function ItemDataMgr:setBuyTimes(data)
	for i, v in pairs(data) do
		self.m_buy_times[tonumber(i)] = v;
	end
end
function ItemDataMgr:getBuyTimes()
	return self.m_buy_times;
end

return ItemDataMgr