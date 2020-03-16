local ChatDataMgr = class("ChatDataMgr")

CHANNEL_WORLD = 1;
CHANNEL_ALLIANCE = 2;
CHANNEL_SYSTEM = 3;

local filterLexicon = table.clone(require("app.constants.forbidden_words"));

function ChatDataMgr:Init()
	self.m_msgList = nil;
	self.m_msgList = {[CHANNEL_WORLD]={}, [CHANNEL_ALLIANCE]={}, [CHANNEL_SYSTEM]={}};

	self.send_remain_time = nil;
	self.send_remain_time = {};
	for i=1,CHANNEL_SYSTEM do
		self.send_remain_time[i] = {second=0, curSystemTime=os.time()};
	end

end

--判断是否包含过滤词
function ChatDataMgr:isContainBadWords(str)
	--特殊字符过滤
	--str = string.gsub(str, "[%w '|/?·`,;.~!@#$%^&*()-_。，、+]", "");
	--是否直接为敏感字符
	local res = filterLexicon[str];
	local word = "";
	--是否包含
	for k,v in pairs(filterLexicon)	do
		local b,e = string.find(str, k);
		if nil ~= b or nil ~= e then
			res = true;
			word = clone(k);
			break;
		end
	end
	return res ~= nil, word;
end

function ChatDataMgr:insertMsgList(channel, list)
	for k,v in pairs(list) do
		local rankInfo = UserDataMgr:getRankInfoByFamous(v.player_info.famous);
		if rankInfo then
			v.player_info.rankLevel = rankInfo.level;
		end
		if #self.m_msgList[channel] >= 100 then
			table.remove(self.m_msgList[channel], 1)
		end
		table.insert(self.m_msgList[channel] , v);
	end
end

function ChatDataMgr:getMsgList(channel)
	if channel == nil then
		return self.m_msgList;
	end
	return self.m_msgList[channel];
end

function ChatDataMgr:setSendRemainSecond(channel, time)
	self.send_remain_time[channel] = {second=time, curSystemTime=os.time()};
end

function ChatDataMgr:getSendRemainSecond(channel)
	if channel == nil then 
		return 0;
	end
	
	local passTime = os.time() - self.send_remain_time[channel].curSystemTime;
	return self.send_remain_time[channel].second - passTime;
end

return ChatDataMgr;