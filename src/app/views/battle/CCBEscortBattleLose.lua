local BattleResourceMgr = require("app.utils.BattleResourceMgr")

local CCBEscortBattleLose = class("CCBEscortBattleLose", function ()
	return CCBLoader("ccbi/battle/CCBEscortBattleLose.ccbi")
end)

function CCBEscortBattleLose:ctor()
	self:createCoverLayer();
end

function CCBEscortBattleLose:createCoverLayer()
	local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return true  end, cc.Handler.EVENT_TOUCH_BEGAN );
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function CCBEscortBattleLose:loseArmature()
	local loseArmature = BattleResourceMgr:getLoseArmature()
	self.m_ccbNodeAnim1:addChild(loseArmature);
	loseArmature:getAnimation():play("anim01");	
end

function CCBEscortBattleLose:showItemInfo()
	--被掠夺的物品
	if resultInfo.lost ~= nil then
		local icon = BattleResourceMgr:getCoinFrameAndCount(resultInfo.lost[1].item_id, resultInfo.lost[1].count);
		self.m_ccbNodeItemBeSpoliatory:addChild(icon);
	end

	--系统奖励
	local movePosX = (#resultInfo.recoup - 1) * 135 / 2;
	for i = 1, #resultInfo.recoup do
		if resultInfo.recoup[i].item_id <= 10000 then
			local icon = BattleResourceMgr:getItemWithFrameAndCount(resultInfo.recoup[i].item_id, resultInfo.recoup[i].count);
			icon:setPositionX((i-1) * 135 - movePosX);
			icon:setScale(0.8)
			self.m_ccbNodeItemNormal:addChild(icon);
		else
			local icon = BattleResourceMgr:getCoinFrameAndCount(resultInfo.recoup[i].item_id, resultInfo.recoup[i].count);
			icon:setPositionX((i-1) * 135 - movePosX);
			icon:setScale(0.8)
			self.m_ccbNodeItemNormal:addChild(icon);
		end
	end
end

function CCBEscortBattleLose:onBtnBack()
	App:enterScene("EscortScene");
end

return CCBEscortBattleLose