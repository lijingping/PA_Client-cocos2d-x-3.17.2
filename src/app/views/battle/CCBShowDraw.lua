-- local file = "app.utils.BattleResourceMgr"
-- package.loaded[file]  = nil
-- local BattleResourceMgr = require(file);

local BattleResourceMgr = require("app.utils.BattleResourceMgr")

local CCBShowDraw = class("CCBShowDraw", function ()
	return CCBLoader("ccbi/battle/CCBShowDraw.ccbi")
end)

function CCBShowDraw:ctor()
	self:createTouchEvent();
end

function CCBShowDraw:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return true  end, cc.Handler.EVENT_TOUCH_BEGAN );
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function CCBShowDraw:setData(data)
	local drawArmature = BattleResourceMgr:getDrawArmature()
	self.m_ccbNodeAnim:addChild(drawArmature);
	drawArmature:getAnimation():play("anim01");
end

function CCBShowDraw:showItemInfo(resultInfo)		
	--系统奖励
	local movePosX = (#resultInfo.recoup - 1) * 135 / 2;
	for i = 1, #resultInfo.recoup do
		if resultInfo.recoup[i].item_id <= 10000 then
			local icon = BattleResourceMgr:getItemWithFrameAndCount(resultInfo.recoup[i].item_id, resultInfo.recoup[i].count);
			icon:setPositionX((i-1) * 135 - movePosX);
			icon:setScale(0.8);
			self.m_ccbNodeItemNormal:addChild(icon);
		else
			local icon = BattleResourceMgr:getCoinFrameAndCount(resultInfo.recoup[i].item_id, resultInfo.recoup[i].count);
			icon:setPositionX((i-1) * 135 - movePosX);
			icon:setScale(0.8);
			self.m_ccbNodeItemNormal:addChild(icon);
		end
	end
end

function CCBShowDraw:onBtnBack()
	Audio:stopMusic();
	self:getParent():getParent():setEffectStop();
	-- Audio:stopAllEffects();
	App:enterScene("MainScene");
end

function CCBShowDraw:onBtnAgain()
	Audio:stopMusic();
	self:getParent():getParent():setEffectStop();
	-- Audio:stopAllEffects();
	App:enterScene("MainScene");
	App:getRunningScene():requestWaitForBattle();
end

return CCBShowDraw