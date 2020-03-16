local RankIcon = require("app.views.common.RankIcon")
local Tips = require("app.views.common.Tips");
------------------
-- 复仇名单列表子控件
------------------
local CCBRevengeViewCell = class("CCBRevengeViewCell", function ()
	return CCBLoader("ccbi/revengeView/CCBRevengeViewCell.ccbi")
end)

local color_online = cc.c3b(0, 255, 0)
local color_offline = cc.c3b(153, 153, 153)
local color_fighting = cc.c3b(0, 255, 255)

function CCBRevengeViewCell:ctor()
	--print("##############CCBRevengeViewCell:ctor");
	self:enableNodeEvents();

	self.m_infoEnemy = nil;
	self.m_ccbNodeRankIcon:removeAllChildren();
	self.m_ccbLabelName:setString("");
	self.m_ccbLabelPower:setString("");
end

function CCBRevengeViewCell:onEnter()
	
end

function CCBRevengeViewCell:onExit()
	self:unscheduleScriptEntry();
end

function CCBRevengeViewCell:unscheduleScriptEntry()
	if self.m_scheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_scheduler);
		self.m_scheduler = nil;
	end		
end

function CCBRevengeViewCell:setData(info)
	--print("##############CCBRevengeViewCell:setData");
	--dump(info);
	self.m_infoEnemy = info;
	--info.revenge_remain_second = 10;

	self.m_ccbLabelName:setString("Lv." .. info.level .. " " .. info.nickname);
	self:showStateIsOnline(info.online);
	self.m_ccbLabelPower:setString("战斗力: " .. info.power);
	self.m_ccbNodeRankIcon:addChild(RankIcon:getZoomRankIcon(info.famous_num, 0.2));
	local rankSpriteLabel = RankIcon:getZoomRankIconLabel(info.famous_num, 0.3);
	self.m_ccbNodeRankIcon:addChild(rankSpriteLabel);
	rankSpriteLabel:setPosition(cc.p(0, -15));

	self:resetState();
end

function CCBRevengeViewCell:resetState()
	if self.m_infoEnemy.stateIsInRequest == true then --请求中
		self.m_ccbNodeNextCD:setVisible(false);
		self.m_ccbNodeBtnRevenge:setVisible(false);
		self.m_ccbSpriteInRequest:setVisible(true);

		-- 此处做15秒自动切换状态的预防措施
		local function changeStateInRequest()
			self.m_infoEnemy.stateIsInRequest = true;
			self.m_ccbSpriteInRequest:setVisible(false);
			self.m_infoEnemy.m_curSystemTime = os.time();
			self.m_infoEnemy.revenge_remain_second = 3600;
			self:nextRevengeCountDown();
		end
		local delayTask = cc.Sequence:create(cc.DelayTime:create(15), cc.CallFunc:create(changeStateInRequest));
		self:runAction(delayTask);
	else
		self.m_ccbSpriteInRequest:setVisible(false);
		self:nextRevengeCountDown();
	end 
end

function CCBRevengeViewCell:nextRevengeCountDown()
	local passTime = os.time() - self.m_infoEnemy.m_curSystemTime;
	local leftTime = self.m_infoEnemy.revenge_remain_second - passTime;
	if leftTime > 0 then
		self.m_ccbNodeNextCD:setVisible(true);
		self.m_ccbNodeBtnRevenge:setVisible(false);
		self.m_ccbLabelNextCD:setString(self:setStrTimeFormat(leftTime));
		self.m_infoEnemy.stateIsInRequest = false;
		if self.m_scheduler == nil then
			self.m_scheduler = self:getScheduler():scheduleScriptFunc(function ()
				leftTime = leftTime - 1;
				self.m_infoEnemy.revenge_remain_second = leftTime;

				self.m_ccbLabelNextCD:setString(self:setStrTimeFormat(leftTime));
				if leftTime <= 0 then
					self:unscheduleScriptEntry();
					self.m_ccbNodeNextCD:setVisible(false);
					self.m_ccbNodeBtnRevenge:setVisible(true);
					self.m_infoEnemy.revenge_remain_second = 0;
				end
			end, 1, false);
		end
	else
		self.m_ccbNodeNextCD:setVisible(false);
		self.m_ccbNodeBtnRevenge:setVisible(true);
	end	
end

function CCBRevengeViewCell:showStateIsOnline(isOnline)
	if isOnline then
		self.m_ccbSpriteOnline:setVisible(true);
		self.m_ccbSpriteOffline:setVisible(false);
		--self.m_ccbBtnRevenge:setVisible(true);
		self.m_ccbBtnRevenge:setEnabled(true);
		self.m_ccbScale9SpriteMask:setVisible(false);
	else
		self.m_ccbSpriteOnline:setVisible(false);
		self.m_ccbSpriteOffline:setVisible(true);
		--self.m_ccbBtnRevenge:setVisible(false);
		self.m_ccbBtnRevenge:setEnabled(false);
		self.m_ccbScale9SpriteMask:setVisible(true);
	end
end

function CCBRevengeViewCell:setStrTimeFormat(time)
	local hour = math.floor(time / 3600);
	local minute = math.floor((time % 3600) / 60);
	local second = time % 60;
	return string.format("%02d:%02d:%02d", hour, minute, second);
end

function CCBRevengeViewCell:onBtnRevenge()
	self.m_infoEnemy.stateIsInRequest = true;
	self:resetState();
	Network:request("battle.matchHandler.revenge_req", { enemy = self.m_infoEnemy.uid }, function(rc, receiveData)
		--dump(receiveData);
		-- self.m_infoEnemy.stateIsInRequest = true;
		-- self:resetState();
		if receiveData.code ~= 1 then
			print("revenge server code:", receiveData.code);
			Tips:create(ServerCode[receiveData.code]);

			if receiveData.code == 1542298762 or receiveData.code == 717496722 then--敌方不在线 or 对方正在其他活动中
				self.m_infoEnemy.stateIsInRequest = false;
				RevengeDataMgr:changeTime({uid=self.m_infoEnemy.uid,m_curSystemTime=os.time(), revenge_remain_second=15});
				self:resetState();
			end
			return;
		end
	end)
end

return CCBRevengeViewCell