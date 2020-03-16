----------------
-- 赠送列表子控件
-----------------
local RankIcon = require("app.views.common.RankIcon");
local Tips = require("app.views.common.Tips");
local PresentIcon = require("app.views.friendView.PresentIcon");

local ResourceMgr = require("app.utils.ResourceMgr");
local CCBPresentListCell = class("CCBPresentListCell", function ()
	return CCBLoader("ccbi/friendView/CCBPresentListCell.ccbi")
end)

function CCBPresentListCell:onEnter()
	
end

function CCBPresentListCell:onExit()
	self:unscheduleScriptEntry();
end

function CCBPresentListCell:ctor()
	self:enableNodeEvents();
end

function CCBPresentListCell:setShowInfo(info)
	self.m_showInfo = info;
	--dump(self.m_showInfo);

	self.m_ccbNodeIcon:removeAllChildren();
	local rankSprite = RankIcon:getZoomRankIcon(info.famous_num, 0.2);
	self.m_ccbNodeIcon:addChild(rankSprite);
	local rankSpriteLabel = RankIcon:getZoomRankIconLabel(info.famous_num, 0.3);
	self.m_ccbNodeIcon:addChild(rankSpriteLabel);
	rankSpriteLabel:setPosition(cc.p(0, -15));

	self.m_ccbLabelName:setString("Lv." .. info.level .. " " .. info.nickname);
	self.m_ccbLabelPower:setString("战斗力: ".. info.power);
	--self:showStateIsOnline(info.online);

	self.m_ccbNodeFriendWish:removeAllChildren();
	local presentIcon = PresentIcon:create(info.wish_item_id);
	self.m_ccbNodeFriendWish:addChild(presentIcon);

	self:nextPresentCountDown();
end

function CCBPresentListCell:nextPresentCountDown()
	if self.m_showInfo.wish_cd == nil then
		self.m_ccbNodePresentCD:setVisible(false);
		self.m_ccbNodeBtnPresent:setVisible(true);	
		return;	
	end
	
	local passTime = os.time() - self.m_showInfo.m_curSystemTime;
	local leftTime = self.m_showInfo.wish_cd - passTime;

	if leftTime > 0 then
		self.m_ccbNodePresentCD:setVisible(true);
		self.m_ccbNodeBtnPresent:setVisible(false);
		self.m_ccbLabelNextCD:setString(self:setStrTimeFormat(leftTime));
		if self.m_scheduler == nil then
			self.m_scheduler = self:getScheduler():scheduleScriptFunc(function ()
				leftTime = leftTime - 1;
				self.m_ccbLabelNextCD:setString(self:setStrTimeFormat(leftTime));
				if leftTime <= 0 then
					self:unscheduleScriptEntry();
					self.m_ccbNodePresentCD:setVisible(false);
					self.m_ccbNodeBtnPresent:setVisible(true);
				end
			end, 1, false);
		end
	else
		self.m_ccbNodePresentCD:setVisible(false);
		self.m_ccbNodeBtnPresent:setVisible(true);
	end	
end

function CCBPresentListCell:setStrTimeFormat(time)
	local hour = math.floor(time / 3600);
	local minute = math.floor((time % 3600) / 60);
	local second = time % 60;
	return string.format("%02d:%02d:%02d", hour, minute, second);
end

function CCBPresentListCell:unscheduleScriptEntry()
	if self.m_scheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_scheduler);
		self.m_scheduler = nil;
	end	
end

function CCBPresentListCell:onBtnPresent()
	Network:request("social.giftHandler.give", {friend = self.m_showInfo.uid}, function (rc, receiveData)
		dump(receiveData);
		if receiveData.code ~= 1 then
			Tips:create(ServerCode[receiveData.code]);
			return;
		end

		local itemData = ItemDataMgr:getItemBaseInfo(self.m_showInfo.wish_item_id);
		Tips:create(string.format("已成功向[%s]赠送了[%s]。", self.m_showInfo.nickname, itemData.name));

		App:getRunningScene():getViewBase().m_ccbFriendView:requestFriendList();
	end)	
end

return CCBPresentListCell