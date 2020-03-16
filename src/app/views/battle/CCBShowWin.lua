local Tips = require("app.views.common.Tips");

local BattleResourceMgr = require("app.utils.BattleResourceMgr")

local CCBShowWin = class("CCBShowWin", function ()
	return CCBLoader("ccbi/battle/CCBShowWin.ccbi")
end)

local partMoveY = 80;

function CCBShowWin:onEnter()
	
end

function CCBShowWin:onExit()
	if self.m_scheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_scheduler);
		self.m_scheduler = nil;
	end
end

function CCBShowWin:ctor()
	if display.resolution >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
	self:enableNodeEvents();
	self:createTouchEvent();

	self.m_ccbNodeShowResult:setVisible(false);
	self.m_ccbNodeShowResult:setOpacity(0);
	self.m_ccbNodeShowResult:setCascadeOpacityEnabled(true);

	self.m_scheduler = nil;	

	-- if BattleDataMgr:getBattleType() == 2 then
		self.m_ccbBtnBack:setVisible(false);
		self.m_ccbBtnAgain:setVisible(false);
		self.m_ccbBtnEnsure:setVisible(true);
	-- else
	-- 	self.m_ccbBtnBack:setVisible(true);
	-- 	self.m_ccbBtnAgain:setVisible(true);
	-- 	self.m_ccbBtnEnsure:setVisible(false);
	-- end
	self.m_famousAdd = 0;
end

function CCBShowWin:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return true; end, cc.Handler.EVENT_TOUCH_BEGAN );
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function CCBShowWin:setData(result)
	--胜利动画
	local resultArmature = nil;
	if result == 1 then
		resultArmature = BattleResourceMgr:getWinArmature();
	elseif result == 2 then
		resultArmature = BattleResourceMgr:getLoseArmature();
	elseif result == 3 then
		resultArmature = BattleResourceMgr:getDrawArmature();
	end
	self.m_ccbNodeAnim1:addChild(resultArmature);
	resultArmature:getAnimation():play("anim01");
	self.m_battleResult = result;
end

function CCBShowWin:showItemInfo(data)
	self.m_ccbNodeItemNormal:removeAllChildren();
	-- dump(data.result.recoup);
	if data.battle_type == 0 then
		if data.result.win == 1 then
			local titleSprite = cc.Sprite:create(BattleResourceMgr:getBattleResultRobTitle());
			self.m_ccbNodeRobTitle:addChild(titleSprite);
			local itemTable = table.clone(data.result.trophy);
			local movePosX = (#itemTable - 1) * 135 * 0.5;
			for i = 1, #itemTable do
				-- if data.result.trophy[i].item_id <= 10000 then
				-- 	local icon = BattleResourceMgr:getItemWithFrameAndCount(data.result.trophy[i].item_id, data.result.trophy[i].count);
				-- 	icon:setPositionX((i - 1) * 135 - movePosX);
				-- 	icon:setScale(0.8);
				-- 	self.m_ccbNodeRobAward:addChild(icon);
				-- else

				local icon = BattleResourceMgr:getItemWithFrameAndCount(itemTable[i].item_id, itemTable[i].count);
				icon:setPositionX((i - 1) * 135 - movePosX);
				icon:setScale(0.8);
				self.m_ccbNodeRobAward:addChild(icon);

				-- end
			end
		elseif data.result.win == 0 then
			local titleSprite = cc.Sprite:create(BattleResourceMgr:getBattleResultBeRobTitle());
			self.m_ccbNodeRobTitle:addChild(titleSprite);
			local itemTable = table.clone(data.result.lost);
			local movePosX = (#itemTable - 1) * 135 * 0.5;
			for i = 1, #itemTable do 
				-- if data.result.lost[i].item_id <= 10000 then
				-- 	local icon = BattleResourceMgr:getItemWithFrameAndCount(data.result.lost[i].item_id, data.result.lost[i].count);
				-- 	icon:setPositionX((i - 1) * 135 - movePosX);
				-- 	icon:setScale(0.8);
				-- 	self.m_ccbNodeRobAward:addChild(icon);
				-- else

				local icon = BattleResourceMgr:getItemWithFrameAndCount(itemTable[i].item_id, itemTable[i].count);
				icon:setPositionX((i - 1) * 135 - movePosX);
				icon:setScale(0.8);
				self.m_ccbNodeRobAward:addChild(icon);

				-- end
			end
		end
	elseif data.battle_type == 1 and data.result.win == 1 then

			local titleSprite = cc.Sprite:create(BattleResourceMgr:getBattleResoultExploreTetle());
			self.m_ccbNodeRobTitle:addChild(titleSprite);
			local itemTable = table.clone(data.result.trophy);
			local movePosX = (#itemTable - 1) * 135 * 0.5;
			for i = 1, #itemTable do
				-- if data.result.trophy[i].item_id <= 10000 then
				local icon = BattleResourceMgr:getItemWithFrameAndCount(itemTable[i].item_id, itemTable[i].count);
				icon:setPositionX((i - 1) * 135 - movePosX);
				icon:setScale(0.8);
				self.m_ccbNodeRobAward:addChild(icon);
				-- else
				-- 	local icon = BattleResourceMgr:getCoinFrameAndCount(data.result.trophy[i].item_id, data.result.trophy[i].count);
				-- 	icon:setPositionX((i - 1) * 135 - movePosX);
				-- 	icon:setScale(0.8);
				-- 	self.m_ccbNodeRobAward:addChild(icon);
				-- end
			end		
	else
		self.m_ccbScale9RobAwardBg:setVisible(false);
		self.m_ccbNodeRobTitle:setVisible(false);
		self.m_ccbNodeRobAward:setVisible(false);
		local bgPosY = self.m_ccbScale9SysAwardBg:getPositionY();
		self.m_ccbScale9SysAwardBg:setPositionY(bgPosY + partMoveY);
		local titlePosY = self.m_ccbSpriteSysTitle:getPositionY();
		self.m_ccbSpriteSysTitle:setPositionY(titlePosY + partMoveY);
		local nodePosY = self.m_ccbNodeItemNormal:getPositionY();
		self.m_ccbNodeItemNormal:setPositionY(nodePosY + partMoveY);
	end

	--系统奖励
	local itemTable = table.clone(data.result.recoup);
	for k, v in pairs(itemTable) do 
		if v.item_id == 10006 then
			self.m_famousAdd = v.count;
			table.remove(itemTable, k);
			break;
		end
	end
	local movePosX = (#itemTable - 1) * 135 * 0.5;
	for i = 1, #itemTable do
		local icon = BattleResourceMgr:getItemWithFrameAndCount(itemTable[i].item_id, itemTable[i].count);
		icon:setPositionX((i-1) * 135 - movePosX);
		icon:setScale(0.8)
		self.m_ccbNodeItemNormal:addChild(icon);
	end
	self.m_ccbNodeShowResult:setVisible(true);
	local resultFadeIn = cc.FadeIn:create(0.3);
	self.m_ccbNodeShowResult:runAction(resultFadeIn);

end



function CCBShowWin:onBtnBack()
	Audio:stopMusic();
	self:getParent():getParent():setEffectStop();
	App:enterScene("MainScene");

end

function CCBShowWin:onBtnAgain()
	Audio:stopMusic();
	App:getRunningScene():getViewBase().m_ccbBattle:setEffectStop();
	App:enterScene("MainScene");
	App:getRunningScene():requestWaitForBattle();
end

function CCBShowWin:onBtnEnsure()
	if BattleDataMgr:getBattleType() == 2 then
		self:getParent():getParent():showEscortResult();
		self:removeSelf();
	else
		-- App:enterScene("MainScene");
		self:getParent():getParent():rankAddView(self.m_famousAdd);
		self:removeSelf();
	end
end

return CCBShowWin