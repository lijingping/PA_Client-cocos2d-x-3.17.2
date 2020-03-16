
local CCBFriendView = require("app.views.friendView.CCBFriendView");
local Tips = require("app.views.common.Tips");
local CCBTitlePanel = require("app.views.commonCCB.CCBTitlePanel");

------------------
-- 好友界面
------------------
local FriendView = class("FriendView", require("app.views.GameViewBase"))

function FriendView:init()
	self.m_ccbTitlePanel = CCBTitlePanel:create("friendView");
	self.m_ccbTitlePanel:setPosition(display.center);
	self:addChild(self.m_ccbTitlePanel, 2, 2);
	self.m_ccbTitlePanel:showNodeFriendship();

	self.m_ccbTitlePanel.onBtnBack = function ()
		App:enterScene("MainScene");
	end

	self.m_ccbFriendView = CCBFriendView:create();
	self:addContent(self.m_ccbFriendView);
end

function FriendView:updateHeadInfo()
	self.m_ccbTitlePanel:updateInfo();
end

-- 接收好友发来的信息
function FriendView:getFriendMassage(data)
-- 	dump(data);
-- 	"<var>" = {
--     "any" = {
--         "msg"    = "#"
--         "sender" = "cfcde2685943a05da69f0b7fe5d02c0c"
--         "time"   = "2017-07-19 16:32:23"
--     }
-- }
	-- dump(self:getChildByTag(50));
	if self:getChildByTag(50) then
		if self:getChildByTag(50):getFriendUID() == data.any.sender then	-- 如果弹框又在，又是跟发送消息人的弹窗私聊，就在私聊弹窗显示聊天内容
			self:getChildByTag(50):notifyChatNews(data);
		else	--有私聊弹窗但是不是跟消息发送人的私聊，小红点提示
			self.m_ccbFriendView:acceptNewMessageFriendUid(data.any.sender);
		end
	else
		self.m_ccbFriendView:acceptNewMessageFriendUid(data.any.sender);
	end
end

-- -- 私聊弹窗弹出，请求好友的新消息并标记消息已读后隐藏小红点及新消息列表上的好友Uid
-- function FriendView:updataNewMessageFriendList(friendUid)
-- 	self.m_ccbFriendView:updataNewMessageFriendList(friendUid);
-- end



return FriendView