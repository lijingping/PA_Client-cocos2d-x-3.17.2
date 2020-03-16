local ProductDataMgr = class("ProductDataMgr")

function ProductDataMgr:Init()
	self.m_isQueueData = false;

	self.m_productData = table.clone(require("app.constants.item_produce"))
	self.m_listNum = 0;
	for k,v in pairs(self.m_productData) do
		self.m_listNum = self.m_listNum + 1;
	end
end

function ProductDataMgr:getProductInfoByIndex(index)
	-- print("###ProductDataMgr:getProductInfoByIndex")
	return self.m_productData[tostring(index)];
end

function ProductDataMgr:getProduceItemData()
	return self.m_productData;
end

function ProductDataMgr:getListNum()
	-- dump(self.m_productData)
	-- print("生产列表：",#self.m_productData)
	return self.m_listNum;

end
--生产道具的ID
function ProductDataMgr:setProductID(id)
	self.m_poductInfoID = id;
end

function ProductDataMgr:getProduceID()
	return self.m_poductInfoID;
end
--设置生产道具的数量
function ProductDataMgr:setProduceItemNum(num)
	self.m_productNum = Num;
end

function ProductDataMgr:getProduceItemNum()
	return self.m_productNum;
end

--生产列表数据
function ProductDataMgr:setQueueData(data)
	self.m_queueData = data;
	self.m_isQueueData = true;
end

function ProductDataMgr:getQueueData()
	return self.m_queueData;
end

function ProductDataMgr:isQueueData()
	return self.m_isQueueData
end

--生产解锁状态
function ProductDataMgr:setIsUnlockBtnClick(bool)
	self.m_unlockBtnClick = bool;
end

function ProductDataMgr:getIsUnlockBtnClick()
	return self.m_unlockBtnClick;
end

function ProductDataMgr:saveProduceData(data)
	self.m_produceData = data;
end

function ProductDataMgr:getProduceData()
	return self.m_produceData;
end

return ProductDataMgr