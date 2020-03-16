local RevengeDataMgr = class("RevengeDataMgr");

function RevengeDataMgr:Init()
	--生产队列的状态
	self.m_data = {};
end

function RevengeDataMgr:getData()
	return self.m_data;
end

function RevengeDataMgr:clearData()
	self.m_data = nil;
	self.m_data = {};
end

function RevengeDataMgr:format(data, index)
	data.m_curSystemTime = os.time();
	data.stateIsInRequest = false;
	data.sort = index;
	if data.online == false then
	    data.sort = index + 1000;
	end
	if data.revenge_remain_second > 0 then
	    data.sort = index + 100;
	end
	return data;
end

function RevengeDataMgr:setData(data, index)
	for k, v in pairs(self.m_data) do
		if v.uid == data.uid then
			RevengeDataMgr:format(data, index);
			data.stateIsInRequest = v.stateIsInRequest;
			if v.revenge_remain_second > 0 and data.revenge_remain_second <= 0 then
				data.revenge_remain_second = v.revenge_remain_second;
			end
			self.m_data[k] = clone(data);
			return;
		end
	end

	RevengeDataMgr:format(data, index);
    table.insert(self.m_data, data);
end

function RevengeDataMgr:insert(data)
	for k, v in pairs(data) do
		RevengeDataMgr:format(v, k);
        table.insert(self.m_data, v);
    end
end

function RevengeDataMgr:changeTime(data)
	for k, v in pairs(self.m_data) do
		if v.uid == data.uid then
			v.m_curSystemTime = data.m_curSystemTime;
			v.revenge_remain_second = data.revenge_remain_second;
			return;
		end
	end
end

function RevengeDataMgr:setStateIsInRequest(uid, isInRequest)
	for k, v in pairs(self.m_data) do
		if v.uid == uid then
			v.stateIsInRequest = isInRequest;
			return;
		end
	end
end

return RevengeDataMgr