-----------------------
-- 添加好友列表的子控件
-----------------------
local RankIcon = require("app.views.common.RankIcon");
local Tips = require("app.views.common.Tips");
-- local ResourceMgr = require("app.utils.ResourceMgr");

local CCBRecommendListCell = class("CCBRecommendListCell", function ()
	return CCBLoader("ccbi/friendView/CCBRecommendListCell.ccbi")
end)

function CCBRecommendListCell:ctor()

end

function CCBRecommendListCell:setInfo(info)
	 -- dump(info);
--  "<var>" = {
--      "famous_num" = 0
--      "is_online"  = true
--      "nickname"   = "詹宁斯梦娜"
--      "power"      = 0
-- }
	if info.nickname == nil or info.nickname == "" then
		info.nickname = "玩家未取名（旧号）"
	end

	self.m_showInfo = info;

	self.m_ccbNodeIcon:removeAllChildren();
	local rankSprite = RankIcon:getZoomRankIcon(info.famous_num, 0.2);
	self.m_ccbNodeIcon:addChild(rankSprite);
	local rankSpriteLabel = RankIcon:getZoomRankIconLabel(info.famous_num, 0.3);
	self.m_ccbNodeIcon:addChild(rankSpriteLabel);
	rankSpriteLabel:setPosition(cc.p(0, -15));

	self.m_ccbLabelName:setString("Lv." .. info.level .. " " .. info.nickname);
	self.m_ccbLabelPower:setString("战斗力: ".. info.power);
end

function CCBRecommendListCell:onBtnAddFriend()
	Network:request("social.friendHandler.befriend", {friend = self.m_showInfo.uid}, function (rc, receiveData)
		--print("申请加为好友")
		if receiveData.code ~= 1 then 
			Tips:create(ServerCode[receiveData.code]);
			return;
		end
		-- dump(receiveData);
		if self.m_showInfo.nickname then
			Tips:create(string.format("已成功向[%s]发送好友申请。", self.m_showInfo.nickname));
			return;
		end
	end)
end

return CCBRecommendListCell