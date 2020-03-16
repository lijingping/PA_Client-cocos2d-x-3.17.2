local FriendDataMgr = class("FriendDataMgr")

function FriendDataMgr:Init()
	
end

function FriendDataMgr:setFriendList(list)
	self.m_friendList = list;
	for k, v in pairs(self.m_friendList) do
		v.giftOutTime = 0;
	end
end

function FriendDataMgr:getFriendList()
	return self.m_friendList;
end

function FriendDataMgr:setFriendGiftTime(friendUid, time)
	if self.m_friendList then
		for k, v in pairs(self.m_friendList) do 
			if v.uid == friendUid then
				v.wish_cd = time;
			end
		end
	end
end

function FriendDataMgr:getFriendGiftTime(friendUid)
	for k, v in pairs(self.m_friendList) do
		if v.uid == friendUid then
			if v.wish_cd then
				return v.wish_cd;
			else
				return 0;
			end
		end
	end
	return 0;
end

function FriendDataMgr:setGiftOutTime(friendUid, time)
	if self.m_friendList then
		for k, v in pairs(self.m_friendList) do
			if v.uid == friendUid then
				v.giftOutTime = time;
			end
		end
	end
end

function FriendDataMgr:getGiftOutTime(friendUid)
	for k, v in pairs(self.m_friendList) do
		if v.uid == friendUid then
			return v.giftOutTime;
		end
	end
	return 0;
end

return FriendDataMgr;