local BattleResourceMgr = require("app.utils.BattleResourceMgr")
local EscortFloat = require("app.views.escortView.EscortFloat")
local ResourceMgr = require("app.utils.ResourceMgr")
--local CCBPopWindow = require("app.views.commonCCB.CCBPopWindow")
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");

local CCBEscortMerchantShipView = class("CCBEscortMerchantShipView",function()
		return CCBLoader("ccbi/escortView/CCBEscortMerchantShipView")
end)

function CCBEscortMerchantShipView:ctor()
	-- dump(data)
	-- "<var>" = {
	--     "code"          = 1
	--     "remain_second" = 300
	-- }
	-- if display.resolution  >= 2 then
	-- 	self:setScale(display.reduce)
	-- end

	self.m_floatLayer = nil;	--漂浮物层
	self.m_onUpdateScheduler = nil; --更新计时器
	self.m_progressBk = 0; -- 进度备份
	self.m_ProgressTime = 0; --（临时进度条时间)
	self.m_animeState = 1;
	self.m_recodeFloatPos = nil;
	self.m_goldCount = 0;
	self.m_diamondCount = 0;
	self.m_recodeGetGoldCount = 0;

	-- self.m_data = data

	self:coverLayer();				--遮罩
	self:loadScene();				--背景动画
	self:taskTime();				--任务时间
	self:merchantShipArmature()		--飞船动画

	self:startScheduler()			-- 进度条
	self:randomArmatureState()

	-- print("x : ", self.m_ccbSpriteStoreBg:getPositionX(), "Y : ", self.m_ccbSpriteStoreBg:getPositionY());
	self.m_gainAnimDestinationPos = self:convertToWorldSpace(cc.p(self.m_ccbSpriteStoreBg:getPositionX(), self.m_ccbSpriteStoreBg:getPositionY()));
	-- dump(self.m_gainAnimDestinationPos);

	self.m_gainGoldArmature = ResourceMgr:gainGoldArmature();
	self:addChild(self.m_gainGoldArmature);
	self.m_gainGoldArmature:setVisible(false);
	self.m_gainGoldArmature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			if movementID == "start" then
				self.m_gainGoldArmature:getAnimation():play("loop");
				local moveTo = cc.MoveTo:create(0.5, cc.p(self.m_gainAnimDestinationPos.x + display.width * 0.5, self.m_gainAnimDestinationPos.y + display.height * 0.5));
				local callBack = cc.CallFunc:create(function()
					self.m_gainGoldArmature:getAnimation():play("end");
					if self.m_recodeGetGoldCount ~= 0 then
						self.m_goldCount = self.m_goldCount + self.m_recodeGetGoldCount;
						self.m_ccbLabelGold:setString(self.m_goldCount);
					end
				end)
				local sequence = cc.Sequence:create(moveTo, callBack);
				self.m_gainGoldArmature:runAction(sequence);
			end
			if movementID == "end" then 
				self.m_gainGoldArmature:setVisible(false);
			end
		end
	end)
end

--遮蔽层
function CCBEscortMerchantShipView:coverLayer()
	self.m_listener = cc.EventListenerTouchOneByOne:create();
	self.m_listener:setSwallowTouches(true);
    self.m_listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_listener, self);
end

function CCBEscortMerchantShipView:loadScene()
	local backgroundArmature = BattleResourceMgr:getBackGroundArmatureByLevel(19);	--护送背景
	if backgroundArmature then
		self.m_ccbNodeBGAnime:addChild(backgroundArmature);
		backgroundArmature:getAnimation():play("anim01");
		backgroundArmature:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				math.randomseed(os.time());
				local index = math.random(2,3); -- 2和3两段动画随机循环播放
				backgroundArmature:getAnimation():play("anim0" .. index);
			end
		end);
	end

	local TopPosY = self.m_ccbNodeTop:getPositionY();
	local BotPosY = self.m_ccbNodeBot:getPositionY();
	print(display.offsetY)
	self.m_ccbNodeTop:setPositionY(TopPosY + display.offsetY);
	self.m_ccbNodeBot:setPositionY(BotPosY - display.offsetY);
end

--初始任务奖励数据
function CCBEscortMerchantShipView:setInitReward()
	local curEscortMerchantShipQuelity = EscortDataMgr:getCurChooseMerChantShip();
	local rewardData = EscortDataMgr:getMerchantShipData(curEscortMerchantShipQuelity)
	self.m_goldCount = rewardData.success_glod;
	self.m_diamondCount = rewardData.success_diamond;
	self.m_ccbLabelGold:setString(self.m_goldCount);
	self.m_ccbLabelDaimond:setString(self.m_diamondCount);
end

--出现漂浮物
function CCBEscortMerchantShipView:emergeFloat()
	if self.m_floatLayer == nil then
		-- print("self.m_floatLayer == nil")
		self.m_floatLayer = EscortFloat:create();
		self.m_ccbNodeFloatAnime:addChild(self.m_floatLayer);
	end
end

--清除漂浮物
function CCBEscortMerchantShipView:releaseFloath()
	if self.m_floatLayer ~= nil then
		print("releaseFloath")
		self.m_floatLayer:removeSelf();
		self.m_floatLayer = nil;
	end
end

--遇敌（播放动画动画结束进入战斗）
function CCBEscortMerchantShipView:meetEnemyArmature()
	local enterBattleArmature = ResourceMgr:enterBattleArmature();
	self.m_ccbNodeEncounterAnime:addChild(enterBattleArmature);
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(enterBattleArmaturePath);
	enterBattleArmature:getAnimation():play("start");
	enterBattleArmature:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
		if movementType == ccs.MovementEventType.complete then
			if movementID == "start" then
				-- print("播放end")
				enterBattleArmature:getAnimation():play("loop")
			end
			if movementID == "loop" then
				enterBattleArmature:getAnimation():play("end")
				enterBattleArmature:removeSelf();
				self:stopScheduler();
			end
		end
	end)
end

--飞船动画
function CCBEscortMerchantShipView:merchantShipArmature()
	local merchantShipLv = EscortDataMgr:getCurChooseMerChantShip(); 	--当前贩售舰等级
	self.m_merchantShipArmature = ResourceMgr:merchantShipArmatrue(merchantShipLv);
	self.m_ccbNodeMerchantShipAnime:addChild(self.m_merchantShipArmature);
	self.m_merchantShipArmature:getAnimation():play("anim01");
end

--改变贩持续售舰动画
function CCBEscortMerchantShipView:changeMerchantShipArmature()	
	local randomNum = math.random(1,2)
	randomNum = math.random(1,2)
	if randomNum == 2 then
		return;
	end
	print("改变飞船状态")
	if self.m_animeState == 1 then
		self.m_merchantShipArmature:getAnimation():play("anim1to2");
	else
		self.m_merchantShipArmature:getAnimation():play("anim2to1");
	end

	self.m_merchantShipArmature:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
		if movementType == ccs.MovementEventType.complete then
			if movementID == "anim1to2" then
				print("播放anim02")
				self.m_merchantShipArmature:getAnimation():play("anim02");
				self.m_animeState = 2;
			end
			
			if movementID == "anim2to1" then
				print("播放anim01")
				self.m_merchantShipArmature:getAnimation():play("anim01");
				self.m_animeState = 1;
			end
		end
	end)
	self:getScheduler():unscheduleScriptEntry(self.m_changeState);
	self:randomArmatureState();
end

--随机飞船动画状态
function CCBEscortMerchantShipView:randomArmatureState()
	print("随机飞船状态");
	self.m_baseTime = 30;	--基础时间30s
	local function changeState()
		self.m_changeState = self:getScheduler():scheduleScriptFunc(function(dt) self:changeMerchantShipArmature(dt) end, 1, false);
	end	
	
	local delayTime = cc.Sequence:create(cc.DelayTime:create(self.m_baseTime), cc.CallFunc:create(changeState));
	self:runAction(delayTime)
end


--计算任务时间
function CCBEscortMerchantShipView:taskTime()
	self.m_taskTiming = EscortDataMgr:getEscortTaskTime();--护送任务剩余时间
	self.m_ProgressTime = 300 - self.m_taskTiming; --护送任务进度时间
end

--开始计时
function CCBEscortMerchantShipView:startScheduler()
	if self.m_onUpdateScheduler == nil then
		self.m_onUpdateScheduler = self:getScheduler():scheduleScriptFunc(function(dt) self:onUpdate(dt) end, 0.1, false);
	end	
end

--停止计时
function CCBEscortMerchantShipView:stopScheduler()
	if self.m_onUpdateScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_onUpdateScheduler);
		self.m_onUpdateScheduler = nil;
	end
	if self.m_changeState then
		self:getScheduler():unscheduleScriptEntry(self.m_changeState);
		self.m_changeState = nil;
	end
end

--更新时间
function CCBEscortMerchantShipView:onUpdate()
	self.m_ProgressTime = self.m_ProgressTime + 0.1; 
	self:updateProgress(self.m_ProgressTime);
	if self.m_ProgressTime >= 300 then
		self:stopScheduler()
	end
end

--更新进度条
function CCBEscortMerchantShipView:updateProgress(time)
	local progress = time/300;
	self.m_ccbSpriteLoadingBar:setScaleX(progress);

	if progress * self.m_ccbSpriteLoadingBar:getContentSize().width < self.m_ccbSpriteLoad4:getContentSize().width then
		local scale = progress * self.m_ccbSpriteLoadingBar:getContentSize().width / self.m_ccbSpriteLoad4:getContentSize().width
		self.m_ccbSpriteLoad4:setScaleX(scale)
	else
		self.m_ccbSpriteLoad4:setScaleX(1)
	end
	self.m_ccbNodeLoadBar:setPositionX(progress * self.m_ccbSpriteLoadingBar:getContentSize().width - 424);
end

function CCBEscortMerchantShipView:onBtnGiveUp()
	local ccbMessageBox = CCBMessageBox:create(Str[3040], Str[4040], MB_YESNO);
	ccbMessageBox.onBtnOK = function ()
		self:giveUpEscort();
	end

	ccbMessageBox.onBtnCancel = function ()
		ccbMessageBox:removeSelf();
	end

	-- local popWindow = CCBPopWindow:create(1, 16, self);
	-- self:addChild(popWindow);
	-- popWindow:setTitleLabel(Str[3040]);
	-- popWindow:setContentLabel(Str[4040]);

	-- App:enterScene("EscortScene");
end

-- 放弃护送任务
function CCBEscortMerchantShipView:giveUpEscort()
	self:stopScheduler();
	App:getRunningScene():requestGiveUpEscortTask();
end

function CCBEscortMerchantShipView:setFloatPos(pos)
	-- dump(pos);
	self.m_recodeFloatPos = pos;
end

function CCBEscortMerchantShipView:playGainGoldAnimation()
	print("show show show ");
	self.m_gainGoldArmature:setVisible(true);
	self.m_gainGoldArmature:setPosition(self.m_recodeFloatPos);
	self.m_gainGoldArmature:getAnimation():play("start");
end

function CCBEscortMerchantShipView:setGetGoldCount(count)
	self.m_recodeGetGoldCount = count;
end

function CCBEscortMerchantShipView:setRewardLabelDataSecond()
	self.m_goldCount = EscortDataMgr:getTotalGoldCount();
	self.m_diamondCount = EscortDataMgr:getTotalDiamondCount();
	self.m_ccbLabelGold:setString(self.m_goldCount);
	self.m_ccbLabelDaimond:setString(self.m_diamondCount);
end

return CCBEscortMerchantShipView