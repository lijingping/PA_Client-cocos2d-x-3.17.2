-- local file = "app.utils.BattleResourceMgr"
-- package.loaded[file]  = nil
-- local BattleResourceMgr = require(file);

local BattleResourceMgr = require("app.utils.BattleResourceMgr")

local CCBShowLose = class("CCBShowLose", function ()
	return CCBLoader("ccbi/battle/CCBShowLose.ccbi")
end)

function CCBShowLose:ctor()
	self:createTouchEvent();

	self.m_ccbSpriteLeftNum:setOpacity(0);
	self.m_ccbSpriteRightNum:setOpacity(0);
	self.m_ccbNodeWaitting:setOpacity(0);
	self.m_ccbNodeWaitting:setCascadeOpacityEnabled(true);
	self.m_ccbNodeShowResult:setVisible(false);
	self.m_ccbNodeShowResult:setOpacity(0);
	self.m_ccbNodeShowResult:setCascadeOpacityEnabled(true);

	self.m_process = nil;
end

function CCBShowLose:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return true  end, cc.Handler.EVENT_TOUCH_BEGAN );
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function CCBShowLose:setData(data)
	--失败动画
	local loseArmature = BattleResourceMgr:getLoseArmature()
	self.m_ccbNodeAnim1:addChild(loseArmature);
	loseArmature:getAnimation():play("anim01");	
	-- if data then
	-- 	--分数计算
	-- 	-- local playID = cc.UserDefault:getInstance():getStringForKey("uid");
	-- 	-- -- playID = "cfcde26858946fcd8220e0261b525294";	
	-- 	-- for k, v in pairs(data.scores) do
	-- 	-- 	if k == playID then
	-- 	-- 		self.m_playerScore = v;
	-- 	-- 	else
	-- 	-- 		self.m_enemyScore = v;
	-- 	-- 	end
	-- 	-- end
	-- 	--分数动画
	-- 	local numArmature = BattleResourceMgr:getScoreArmature();
	-- 	self.m_ccbNodeAnim2:addChild(numArmature);
	-- 	numArmature:getAnimation():play("anim01");
	-- 	numArmature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
	-- 			if movementType == ccs.MovementEventType.complete then
	-- 				-- self:showScores();
	-- 				self:showProcess();
	-- 			end
	-- 		end)
	-- else
	-- 	--若无分数则跳过分数显示，直接显示获得物品
	-- 	self.m_ccbSpriteLeftNum:setVisible(false);
	-- 	self.m_ccbSpriteRightNum:setVisible(false);
	-- end
end

function CCBShowLose:showScores()
	self.m_ccbSpriteLeftNum:setVisible(true);
	self.m_ccbSpriteRightNum:setVisible(true);
	self.m_ccbSpriteLeftNum:setTexture(BattleResourceMgr:getScoreTextureBlue(self.m_playerScore));
	self.m_ccbSpriteRightNum:setTexture(BattleResourceMgr:getScoreTextureYellow(self.m_enemyScore));
	self.m_ccbSpriteLeftNum:runAction(cc.FadeIn:create(0.3));
	self.m_ccbSpriteRightNum:runAction(cc.FadeIn:create(0.3));
end

function CCBShowLose:showProcess()
	self.m_ccbNodeWaitting:setOpacity(0);
	self.m_ccbNodeWaitting:runAction(cc.FadeIn:create(0.3));

	if self.m_process == nil then
		local pathProcess = "res/resources/battle/ui_account_bar.png"
		self.m_process = cc.ProgressTimer:create(cc.Sprite:create(pathProcess));
	    self.m_process:setType(cc.PROGRESS_TIMER_TYPE_BAR);
		self.m_process:setPercentage(100);
		self.m_process:setMidpoint(cc.p(0, 0));
	    self.m_process:setBarChangeRate(cc.p(1, 0));    
	    self.m_ccbNodeProcess:addChild(self.m_process);

	    local action = cc.ProgressTo:create(5, 0);
	    self.m_process:runAction(action);
	end
end

--显示被掠夺物品和系统奖励
function CCBShowLose:showItemInfo(resultInfo)	
	--比分不显示
	self.m_ccbSpriteLeftNum:setVisible(false);
	self.m_ccbSpriteRightNum:setVisible(false);
	self.m_ccbNodeAnim2:removeAllChildren();

	local function nodeItemInfoFadeIn()
		self.m_ccbNodeShowResult:setVisible(true);
		self.m_ccbNodeShowResult:runAction(cc.FadeIn:create(0.3));
	end
	local actionSequence = cc.Sequence:create(cc.FadeOut:create(0.3), cc.CallFunc:create(nodeItemInfoFadeIn))
	self.m_ccbNodeWaitting:runAction(actionSequence);
	-- dump(resultInfo)
	--被掠夺的物品
	if resultInfo.lost ~= nil and #resultInfo.lost >= 1 then
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
			local icon = BattleResourceMgr:getItemWithFrameAndCount(resultInfo.recoup[i].item_id, resultInfo.recoup[i].count);
			icon:setPositionX((i-1) * 135 - movePosX);
			icon:setScale(0.8)
			self.m_ccbNodeItemNormal:addChild(icon);
		end
	end
end


function CCBShowLose:onBtnBack()
	Audio:stopMusic();
	self:getParent():getParent():setEffectStop();
	-- Audio:stopAllEffects();
	App:enterScene("MainScene");

end

function CCBShowLose:onBtnAgain()
	Audio:stopMusic();
	self:getParent():getParent():setEffectStop();
	-- Audio:stopAllEffects();
	App:enterScene("MainScene");
	App:getRunningScene():requestWaitForBattle();
end

return CCBShowLose