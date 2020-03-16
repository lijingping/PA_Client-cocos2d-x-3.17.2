local Tips = require("app.views.common.Tips");
local ResourceMgr = require("app.utils.ResourceMgr");
local CCBRateView = require("app.views.lotteryView.CCBRateView");

local CCBLotteryView = class("CCBLotteryView", function ()
	return CCBLoader("ccbi/lotteryView/CCBLotteryView.ccbi")
end)

function CCBLotteryView:ctor()
	if display.resolution >= 2 then
		self:setScale(display.reduce);
	end
	
	self:enableNodeEvents();
	self:requestCoolTime();
	self:createBoxBottomAnim();
	self.m_isLock = false;
	self.m_showCDTime = 0;
	self.m_isRequest = false;
end

function CCBLotteryView:onExit()
	self:unscheduleScriptEntry()
end

function CCBLotteryView:createBoxBottomAnim()
	local normalBoxBottomAnim = ResourceMgr:getLotteryBoxLightAnim();
	self.m_ccbNodeNormalBox:addChild(normalBoxBottomAnim);
	normalBoxBottomAnim:getAnimation():play("box1");

	local superBoxBottomAnim = ResourceMgr:getLotteryBoxLightAnim();
	self.m_ccbNodeSuperBox:addChild(superBoxBottomAnim);
	superBoxBottomAnim:getAnimation():play("box2");
end

function CCBLotteryView:requestCoolTime()
	local function requestCallBack(re, callBackInfo)
		-- dump(callBackInfo);
		if callBackInfo.code ~= 1 then
			Tips:create(ServerCode[callBackInfo.code]);
			return;
		end
		self:setCoolTime(callBackInfo.cd, callBackInfo.num);
	end
	Network:request("game.shopHandler.queryFreeLuckyDraw", nil, requestCallBack);
end

function CCBLotteryView:setCoolTime(cd, num)
	print("冷却时间", cd , "    免费次数剩余", num);
	if cd > 0 then
		local lastTime = cd;
		self.m_ccbNodeCost1:setVisible(true);		
		self.m_ccbSpriteFreeTips:setVisible(false);
		self.m_ccbLabelCoolTime:setVisible(true);
		self.m_ccbLabelFreeTips:setVisible(true);
		self.m_showCDTime = self.m_showCDTime + 1;
		if self.m_showCDTime == 1 then
			local labelTipPosY = self.m_ccbSpriteLabelTip:getPositionY();
			self.m_ccbSpriteLabelTip:setPositionY(labelTipPosY - 10);
		end
		if self.m_updateScheduler == nil then
			self.m_updateScheduler = self:getScheduler():scheduleScriptFunc(
				function()
					-- 1秒更新1次 
					--print("计时器开启")
					self.m_ccbLabelCoolTime:setString(self:setStrTimeFormat(lastTime));				
					lastTime = lastTime - 1;

					if lastTime < 0 then
						self.m_ccbNodeCost1:setVisible(false);
						self.m_ccbSpriteFreeTips:setVisible(true);
						self.m_ccbLabelCoolTime:setVisible(false);
						self.m_ccbLabelFreeTips:setVisible(false);
						self.m_showCDTime = 0;
						local posY = self.m_ccbSpriteLabelTip:getPositionY();
						self.m_ccbSpriteLabelTip:setPositionY(posY + 10);
						self:unscheduleScriptEntry();
					end
		 		end, 
		 	1, false);
		end
	else
		self.m_ccbLabelCoolTime:setVisible(false);
		self.m_ccbLabelFreeTips:setVisible(false);		
		if num == 0 then
			self.m_ccbNodeCost1:setVisible(true);				
			self.m_ccbSpriteFreeTips:setVisible(false);		
		else
			self.m_ccbNodeCost1:setVisible(false);
			self.m_ccbSpriteFreeTips:setVisible(true);
		end
	end
end

function CCBLotteryView:unscheduleScriptEntry()
	if self.m_updateScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_updateScheduler);
		self.m_updateScheduler = nil;
	end	
end

function CCBLotteryView:setStrTimeFormat(time)
	--print("CD时间", time);
	local hour = math.floor(time / 3600);
	local minute = math.floor((time % 3600) / 60);
	local second = time % 60;
	return string.format("%02d:%02d:%02d", hour, minute, second);
end

function CCBLotteryView:lockForAMoment(delayTime)
	self.m_isLock = true;
	self:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(function () self.m_isLock = false; end)));
end

function CCBLotteryView:onBtnNormalOnce()
	-- print("普通抽一次1");
	if self.m_isLock == false then
		self:lockForAMoment(1);
	else
		return;
	end
	self.m_isRequest = true;
	App:getRunningScene():getViewBase().m_isNormal = true;
	local function requestCallBack(re, callBackInfo)
		if callBackInfo.code ~= 1 then
			Tips:create(ServerCode[callBackInfo.code]);
			return;
		end
		self:requestCoolTime();
		self.m_isRequest = false;
	end

	Network:request("game.shopHandler.luckyDraw", {is_normal = true, is_ten = false}, requestCallBack);
end

function CCBLotteryView:onBtnNormalTen()
	--print("普通抽十次");
	if self.m_isLock == false then
		self:lockForAMoment(1);
	else
		return;
	end
	self.m_isRequest = true;
	App:getRunningScene():getViewBase().m_isNormal = true;
	local function requestCallBack(re, callBackInfo)
		if callBackInfo.code ~= 1 then
			Tips:create(ServerCode[callBackInfo.code]);
			return;
		end
		self.m_isRequest = false;
	end

	Network:request("game.shopHandler.luckyDraw", {is_normal = true, is_ten = true}, requestCallBack);
end
 
function CCBLotteryView:onBtnSuperiorOnce()
	--print("高级抽一次");
	if self.m_isLock == false then
		self:lockForAMoment(1);
	else
		return;
	end
	self.m_isRequest = true;
	App:getRunningScene():getViewBase().m_isNormal = false;
	local function requestCallBack(re, callBackInfo)
		if callBackInfo.code ~= 1 then
			Tips:create(ServerCode[callBackInfo.code]);
			return;
		end
		self.m_isRequest = false;
	end

	Network:request("game.shopHandler.luckyDraw", {is_normal = false, is_ten = false}, requestCallBack);
end

function CCBLotteryView:onBtnSuperiorTen()
	--print("高级抽十次");
	if self.m_isLock == false then
		self:lockForAMoment(1);
	else
		return;
	end
	self.m_isRequest = true;
	App:getRunningScene():getViewBase().m_isNormal = false;
	local function requestCallBack(re, callBackInfo)	
		if callBackInfo.code ~= 1 then
			Tips:create(ServerCode[callBackInfo.code]);
			return;
		end
		self.m_isRequest = false;
	end

	Network:request("game.shopHandler.luckyDraw", {is_normal = false, is_ten = true}, requestCallBack);
end

function CCBLotteryView:onBtnShowNormalList()
	self:showList(2)
end

function CCBLotteryView:onBtnShowSuperiorList()
	self:showList(1);
end

function CCBLotteryView:showList(listType)
	App:getRunningScene():addChild(CCBRateView:create(listType));
end 

function CCBLotteryView:getIsRequest()
	return self.m_isRequest;
end

function CCBLotteryView:setRequestOver()
	self.m_isRequest = false;
end

return CCBLotteryView;