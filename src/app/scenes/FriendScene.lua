local Tips = require("app.views.common.Tips");
-------------------------
-- 好友列表场景
-------------------------
local FriendScene = class("FriendScene", require("app.scenes.GameSceneBase"))

function FriendScene:init()
 	self:initView("friendView.FriendView")
end

function FriendScene:notifyChatNews(data)
	self:getViewBase().m_ccbFriendView:newMassageFromFriend(data);
end

function FriendScene:notifyFriendApplication(data)
	self:getViewBase().m_ccbFriendView:newApplicationHint(data);
end

function FriendScene:notifyNewFriendHint(data)
	self:getViewBase().m_ccbFriendView:newFriendHint(data);
end

function FriendScene:notifyBeAddedFromFriend(data)
	self:getViewBase().m_ccbFriendView:beAddedFromFriend(data);
end

function FriendScene:notifyBeDeletedFromFriend(data)
	self:getViewBase().m_ccbFriendView:beDeletedFromFriend(data);
end

return FriendScene