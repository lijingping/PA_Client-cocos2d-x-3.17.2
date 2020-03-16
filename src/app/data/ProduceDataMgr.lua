local ProduceDataMgr = class("ProduceDataMgr")

function ProduceDataMgr:Init()
	--生产队列的状态
	self.m_produceQueue = {{produceItemID = -1, produceItemCount = 0, produceleftTime = 0, produceTime = 0, queuePos = 1, isLock = false}};
	for k, v in pairs(table.clone(require("app.constants.unlock_queue"))) do
		v.produceItemID = -1;
		v.produceItemCount = 0;
		v.produceLeftTime = 0;
		v.produceTime = 0;--获得数据时的时间，用来计算已经过去的时间
		v.queuePos = v.id+1; -- 生产从0开始，表中只有2-10的解锁条件，所以索引值只有从1到9
		v.isLock = true;
		table.insert(self.m_produceQueue, v);
		table.sort(self.m_produceQueue, function (a, b) return a.queuePos < b.queuePos; end)
	end	

	--生产配方的列表
	self.m_produceFormulation = {};
	for k, v in pairs(table.clone(require("app.constants.item_produce"))) do
		table.insert(self.m_produceFormulation, v);
		table.sort(self.m_produceFormulation, function (a, b) return a.id < b.id; end)
	end
end

function ProduceDataMgr:getProduceFormulation()
	return self.m_produceFormulation;
end

function ProduceDataMgr:setProduceQueue(queueInfos)
	for k, v in pairs(queueInfos) do
		-- 服务器上传过来的index为0~9，对应客户端的pos是1~10
		self.m_produceQueue[v.index+1].produceItemID = v.item_id;
		self.m_produceQueue[v.index+1].produceItemCount = v.count;
		self.m_produceQueue[v.index+1].produceLeftTime = v.remain / 1000;
		self.m_produceQueue[v.index+1].produceTime = os.time();
		self.m_produceQueue[v.index+1].isLock = false; -- 未解锁是不会遍历到该index，一旦遍历了则该状态就是解锁状态
	end
end

function ProduceDataMgr:getProduceQueue()
	return self.m_produceQueue;
end

--记录生产位置，生产时发给服务器
function ProduceDataMgr:setCurProducePos(pos)
	self.m_producePos = pos;
end

function ProduceDataMgr:getCurProducePos()
	return self.m_producePos;
end

--设置tableview的offset，从生产界面2跳转回生产界面1时，tableview保持之前的位置
function ProduceDataMgr:setOffsetProduceView1(offset)
	self.m_offsetProduceVidw1 = offset;
end

function ProduceDataMgr:getOffsetProduceView1()
	if self.m_offsetProduceVidw1 then
		return self.m_offsetProduceVidw1;
	else
		return cc.p(0, 0);
	end	
end

function ProduceDataMgr:setProduceSpeedUpPos(pos)
	self.m_produceSpeedUpPos = pos;
end

function ProduceDataMgr:getProduceSpeedUpPos()
	return self.m_produceSpeedUpPos;
end

return ProduceDataMgr