-- local CCBChatPopup = require("app.views.friendView.CCBChatPopup");
--local CCBPopWindow = require("app.views.commonCCB.CCBPopWindow");
--local CCBPrivateChatPopup = require("app.views.friendView.CCBPrivateChatPopup");
--local ResourceMgr = require("app.utils.ResourceMgr");

local RankIcon = require("app.views.common.RankIcon")
local Tips = require("app.views.common.Tips");
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");

------------------------------
-- 好友列表的子控件
------------------------------

local CCBFriendListCell = class("CCBFriendListCell", function ()
	return CCBLoader("ccbi/friendView/CCBFriendListCell.ccbi")
end)


function CCBFriendListCell:ctor()

end

-- 根据数据更新
function CCBFriendListCell:setInfo(info)
	--dump(info)

--     "famous_num"   = 66
--     "icon"         = "default"
--     "level"        = 96
--     "nickname"     = "布朗伊芙"
--     "online"       = false
--     "power"        = 65730
--     "sort"         = 6573066
--     "uid"          = "cfcde2685ab4a9c2360e6bd6d2caf292"
--     "wish_cd"      = 0
--     "wish_item_id" = 2906

	self.m_showInfo = info;

	self.m_ccbNodeIcon:removeAllChildren();
	local rankSprite = RankIcon:getZoomRankIcon(info.famous_num, 0.2);
	self.m_ccbNodeIcon:addChild(rankSprite);
	local rankSpriteLabel = RankIcon:getZoomRankIconLabel(info.famous_num, 0.3);
	self.m_ccbNodeIcon:addChild(rankSpriteLabel);
	rankSpriteLabel:setPosition(cc.p(0, -15));

	self.m_ccbLabelName:setString("Lv." .. info.level .. " " .. info.nickname);
	self.m_ccbLabelPower:setString("战斗力: ".. info.power);
	self:showStateIsOnline(info.online);

	if self:isHaveNewMessage() then
		self.m_ccbSpriteHintMessage:setVisible(true);
	else
		self.m_ccbSpriteHintMessage:setVisible(false);
	end
end

function CCBFriendListCell:showStateIsOnline(isOnline)
	if isOnline then
		self.m_ccbSpriteOnline:setVisible(true);
		self.m_ccbSpriteOffline:setVisible(false);
		self.m_ccbScale9SpriteMask:setVisible(false);
	else
		self.m_ccbSpriteOnline:setVisible(false);
		self.m_ccbSpriteOffline:setVisible(true);
		self.m_ccbScale9SpriteMask:setVisible(true);
	end
end

function CCBFriendListCell:isHaveNewMessage()
	local messageHintList = App:getRunningScene():getViewBase().m_ccbFriendView:getMessageNewHintList();
	if #messageHintList ~= 0 then
		for k, v in pairs(messageHintList) do
			if self.m_showInfo.uid == v then
				return true;
			end
		end
		return false;
	else
		return false;
	end
end

function CCBFriendListCell:onBtnChat()
	self.m_ccbSpriteHintMessage:setVisible(false);
	App:getRunningScene():getViewBase().m_ccbFriendView:cleanHintMessage(self.m_showInfo.uid);
	App:getRunningScene():getViewBase().m_ccbFriendView:showChatDialogbox(self.m_showInfo);
end

function CCBFriendListCell:onBtnDelete()
	local ccbMessageBox = CCBMessageBox:create(Str[3008], "是否与[" .. self.m_showInfo.nickname .. "]解除好友关系。", MB_YESNO);
	ccbMessageBox.onBtnOK = function ()
		Network:request("social.friendHandler.breakup", {friend = self.m_showInfo.uid}, function (rc, receiveData)
			if receiveData.code ~= 1 then
				Tips:create(ServerCode[receiveData.code]);
				return;
			end
			Tips:create(string.format("已成功与玩家[%s]解除好友关系！", self.m_showInfo.nickname));
			App:getRunningScene():getViewBase().m_ccbFriendView:deleteFriend(self.m_showInfo);
			ccbMessageBox:removeSelf();
		end)				
	end

	ccbMessageBox.onBtnCancel = function ()
		ccbMessageBox:removeSelf();	
	end

end

return CCBFriendListCell