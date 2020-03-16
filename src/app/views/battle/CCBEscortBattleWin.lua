local BattleResourceMgr = require("app.utils.BattleResourceMgr")

local CCBEscortBattleWin = class("CCBEscortBattleWin", function ()
	return CCBLoader("ccbi/battle/CCBEscortBattleWin.ccbi")
end)

function CCBEscortBattleWin:ctor()
	self.m_enterTiming = 5;
	self:createCoverLayer();
end

function CCBEscortBattleWin:createCoverLayer()
	local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return true  end, cc.Handler.EVENT_TOUCH_BEGAN );
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function CCBEscortBattleWin:winArmature()
	local winArmature = BattleResourceMgr:getWinArmature()
	self.m_ccbNodeAnim1:addChild(winArmature);
	winArmature:getAnimation():play("anim01");
	self:startScheduler(); -- 开始倒计时
end

--自动进入护送界面
function CCBEscortBattleWin:startScheduler()
	if self.m_onUpdateScheduler == nil then
		self.m_onUpdateScheduler = self:getScheduler():scheduleScriptFunc(function() self:enterEscortTime() end, 1, false);
	end
end


function CCBEscortBattleWin:stopScheduler()
	if self.m_onUpdateScheduler then
		self.m_onUpdateScheduler:getScheduler():unscheduleScriptEntry(self.m_onUpdateScheduler);
		self.m_onUpdateScheduler = nil;
	end
end

--进入护送倒计时
function CCBEscortBattleWin:enterEscortTime()
	self.m_enterTiming = self.m_enterTiming - 1
	if self.m_enterTiming == 0 then
		self:stopScheduler();
		App:enterScene("EscortScene")
	end
end


function CCBEscortBattleWin:onBtnBack()
	App:enterScene("EscortScene");
end

return CCBEscortBattleWin