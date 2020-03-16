local RankIcon = require("app.views.common.RankIcon")
local Tips = require("app.views.common.Tips");
------------------
-- 复仇名单列表子控件
------------------
local CCBRevengeCell = class("CCBRevengeCell", function ()
	return CCBLoader("ccbi/revengeView/CCBRevengeCell.ccbi")
end)

local color_online = cc.c3b(0, 255, 0)
local color_offline = cc.c3b(153, 153, 153)
local color_fighting = cc.c3b(0, 255, 255)

function CCBRevengeCell:ctor()
	--print("##############CCBRevengeCell:ctor");
	
	self.m_infoEnemy = nil;
	self.m_ccbNodeIcon:removeAllChildren();
	self.m_ccbLabelName:setString("");
	self.m_ccbLabelGrade:setString("");
	self.m_ccbLabelPower:setString("");
	self.m_ccbLabelState:setString("");
end

function CCBRevengeCell:setData(info)
	--print("##############CCBRevengeCell:setData");
	self.m_infoEnemy = info; 

	self.m_ccbLabelName:setString(info.nickname);
	self.m_ccbLabelGrade:setString("军衔：" .. UserDataMgr:getRankNameByFamous(info.famous_num));
	self.m_ccbLabelState:setString(self:showStateIsOnline(info.online));
	self.m_ccbLabelState:setColor(self:getColorOnline(info.online));
	self.m_ccbLabelPower:setString("战斗力：" .. info.power);
	self.m_ccbNodeIcon:addChild(RankIcon:getZoomRankIcon(info.famous_num, 0.2));
	local rankSpriteLabel = RankIcon:getZoomRankIconLabel(info.famous_num, 0.3);
	self.m_ccbNodeIcon:addChild(rankSpriteLabel);
	rankSpriteLabel:setPosition(cc.p(0, -15));
end

function CCBRevengeCell:showStateIsOnline(isOnline)
	if isOnline then
		return "在线"
	else
		return "离线"
	end
end

function CCBRevengeCell:getColorOnline(isOnline)
	if isOnline then
		return cc.c3b(0,220,0);
	else
		return cc.c3b(150,150,150);
	end
end

function CCBRevengeCell:onBtnRevenge()
	Network:request("battle.matchHandler.revenge_req", { enemy = self.m_infoEnemy.uid }, function(rc, receiveData)
		dump(receiveData);
		if receiveData.code ~= 1 then
			Tips:create(GameData:get("code_map", receiveData.code)["desc"])
			return
		end
		Tips:create(Str[4044]);
		-- App:getRunningScene():getViewBase():PopWaittingRevengeRequest();
	end)
end



return CCBRevengeCell