local ResourceMgr = require("app.utils.ResourceMgr");
local Tips = require("app.views.common.Tips")
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");
local CCBCommonGetPath = require("app.views.commonCCB.CCBCommonGetPath");

--加载ccbi文件
local CCBProduceSpeedUp = class("CCBProduceSpeedUp", function()
	return CCBLoader("ccbi/produceView/CCBProduceSpeedUp.ccbi")
end)

local speedUpCount = 1;
local speedUpTime = speedUpCount * 600;
local diamondNumber = 0;
local speedUpItemID = 4005;

function CCBProduceSpeedUp:onExit()
	if self.m_updateScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_updateScheduler);
		self.m_updateScheduler = nil;
	end
end

function CCBProduceSpeedUp:onEnter()

end

function CCBProduceSpeedUp:ctor(cell)
	if display.resolution >= 2 then
		self.m_ccbLayerCenter:setScale(display.reduce);
	end
	self.m_cell = cell;

	self:enableNodeEvents();

	self.m_speedUpTime = 0; --加速过的时间，用来计算使用道具后的剩余时间的显示
	self.m_showProduceLeftTime = 0;
	self.m_speedCostItemCount = ItemDataMgr:getItemCount(speedUpItemID);

	--屏蔽其他层操作
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);

	--加速道具的显示
	self.m_ccbNodeIcon:addChild(ResourceMgr:getSlotsIconWithScale(speedUpItemID));
	self.m_ccbLabelHaveCount:setString(self.m_speedCostItemCount);
	if self.m_speedCostItemCount == 0 then
		self.m_ccbLabelHaveCount:setColor(cc.RED);
	else
		self.m_ccbLabelHaveCount:setColor(cc.WHITE);
	end

	self.m_showInfo = ProduceDataMgr:getProduceQueue()[ProduceDataMgr:getProduceSpeedUpPos()];
	--生产剩余时间
	local pastTime = os.time() - self.m_showInfo.produceTime
	self.m_showProduceLeftTime = self.m_showInfo.produceLeftTime - pastTime;
	if self.m_showProduceLeftTime > 0 then
		self.m_ccbLabelLeftTime:setString(self:showTimeFormat(self.m_showProduceLeftTime));
		if self.m_updateScheduler == nil then
			self.m_updateScheduler = self:getScheduler():scheduleScriptFunc(function() 
				self.m_showProduceLeftTime = self.m_showProduceLeftTime - 1;
				if self.m_showProduceLeftTime > 0 and self.m_itemCountSlider then
					local rate = math.ceil(self.m_showProduceLeftTime / 900);
					self.m_itemCountSlider:setMaxPercent(rate);
					if self.m_itemCountSlider:getPercent() > rate then
						self.m_itemCountSlider:setPercent(rate);
						self.m_ccbLabelItemCost:setString(Str[10013].."："..rate);
					end
				end
				
				--时间计算到0，关闭窗口
				if self.m_showProduceLeftTime < 0 then
					self:onBtnClose();
					return;
				end

				self.m_ccbLabelLeftTime:setString(self:showTimeFormat(self.m_showProduceLeftTime));
				self:useDiamondCount(self.m_showProduceLeftTime);
			end, 1, false);
		end
	end	

	--设置滑动条
    self.m_itemCountSlider = ccui.Slider:create()    
    self.m_itemCountSlider:setScale9Enabled(true)
    self.m_itemCountSlider:setTouchEnabled(true)
    self.m_itemCountSlider:setContentSize(self.m_ccbNodeSlider:getContentSize());
    self.m_itemCountSlider:setAnchorPoint(0, 0);
    self.m_itemCountSlider:loadBarTexture(ResourceMgr:getSliderBarBg());
    self.m_itemCountSlider:loadProgressBarTexture(ResourceMgr:getSliderBar());
    self.m_itemCountSlider:loadSlidBallTextures(ResourceMgr:getSliderBall(), ResourceMgr:getSliderBall(), ResourceMgr:getSliderBall());
	self.m_itemCountSlider:setPercent(1)
        :setCapInsets(cc.rect(18, 0, 18, 0));

	local reduceSecond = 900; --一个道具减少15分钟
	print("produceTime", self.m_showProduceLeftTime);
	self.needCountMax = math.ceil(self.m_showProduceLeftTime / 900);
	if self.needCountMax < 1 then
		self.needCountMax = 1;
	end
	self.m_itemCountSlider:setMaxPercent(self.needCountMax);
	self.m_ccbLabelItemCost:setString(Str[10013].."：1");
	self.m_ccbLabelSpeedUpTime:setString(self:showTimeFormat(900));
	self:useDiamondCount(self.m_showProduceLeftTime);

	local function changeEvent(pSender, eventType)
		if eventType == ccui.SliderEventType.percentChanged then
			local percent = pSender:getPercent();
			if percent < 1 then
				percent = 1;
				pSender:setPercent(1);
			end
			self.m_ccbLabelItemCost:setString(Str[10013].."："..percent);
			self.m_ccbLabelSpeedUpTime:setString(self:showTimeFormat(percent*900));
		end
	end
    self.m_itemCountSlider:addEventListener(changeEvent);
    self.m_ccbNodeSlider:addChild(self.m_itemCountSlider);
end

function CCBProduceSpeedUp:onBtnSliderDown()
	local curCostCount = self.m_itemCountSlider:getPercent();
	curCostCount = curCostCount - 1;
	if curCostCount < 1 then
		curCostCount = 1;
	end
	self.m_itemCountSlider:setPercent(curCostCount);
	self.m_ccbLabelItemCost:setString(Str[10013].."："..curCostCount);
	self.m_ccbLabelSpeedUpTime:setString(self:showTimeFormat(curCostCount*900));
end

function CCBProduceSpeedUp:onBtnSliderUp()
	local curCostCount = self.m_itemCountSlider:getPercent();
	curCostCount = curCostCount + 1;
	if curCostCount > self.needCountMax then
		curCostCount = self.needCountMax;
	end
	self.m_itemCountSlider:setPercent(curCostCount);
	self.m_ccbLabelItemCost:setString(Str[10013].."："..curCostCount);
	self.m_ccbLabelSpeedUpTime:setString(self:showTimeFormat(curCostCount*900));
end

function CCBProduceSpeedUp:onBtnUseItem()
	local costCount = self.m_itemCountSlider:getPercent();
	if costCount > ItemDataMgr:getItemCount(speedUpItemID) then
		local ccbMessageBox = CCBMessageBox:create(Str[3036], Str[10015], MB_YESNO); -- 道具不足
		ccbMessageBox.onBtnOK = function ()
			ccbMessageBox:removeSelf();
			
			CCBCommonGetPath:create(speedUpItemID);
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
		return;
	end

	local showProduceLeftTime = self.m_showProduceLeftTime - 900 * costCount;
	if showProduceLeftTime > 0 then
		self:addCellEffectAnim(false);
	else
		self:addCellEffectAnim(true);
	end

	Network:request("game.itemsHandler.speedupProduceQueue",  {item_id = speedUpItemID, count = costCount, queue_id = self.m_showInfo.queuePos-1}, function (rc, receiveData)
		if receiveData.code ~= 1 then
			Tips:create(ServerCode[receiveData.code]);
		end
		--[[
		self.m_speedCostItemCount = self.m_speedCostItemCount -  costCount;
		if self.m_speedCostItemCount < 0 then
			self.m_speedCostItemCount = 0;
		end
		self.m_ccbLabelHaveCount:setString(self.m_speedCostItemCount);
		if self.m_speedCostItemCount == 0 then
			self.m_ccbLabelHaveCount:setColor(cc.RED);
		else
			self.m_ccbLabelHaveCount:setColor(cc.WHITE);
		end

		self.m_showProduceLeftTime = self.m_showProduceLeftTime - 900 * costCount;
		if self.m_showProduceLeftTime > 0 then
			local rate = math.ceil(self.m_showProduceLeftTime / 900);
			self.m_itemCountSlider:setMaxPercent(rate);
			self.m_ccbLabelDiamondCost:setString(rate);
			if self.m_itemCountSlider:getPercent() > rate then
				self.m_itemCountSlider:setPercent(rate);
				self.m_ccbLabelItemCost:setString(Str[10013].."："..rate);
			end
		else
		end
		]]
	end);
	self:onBtnClose();
end

function CCBProduceSpeedUp:onTouchBegan(touch, event)
	return true;
end

function CCBProduceSpeedUp:onBtnUseDiamond()
	if UserDataMgr:getPlayerDiamond() < self.m_needCostDiamond then
		local ccbMessageBox = CCBMessageBox:create(Str[3036], Str[4004], MB_YESNO); --钻石不足
		ccbMessageBox.onBtnOK = function ()
			ccbMessageBox:removeSelf();
			App:enterScene("ShopScene");
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
		return;
	end

	local ccbMessageBox = CCBMessageBox:create(Str[3036], string.format(Str[4012], self.m_needCostDiamond), MB_YESNO);
	ccbMessageBox.onBtnOK = function ()
		ccbMessageBox:removeSelf();

		self:addCellEffectAnim(true);

		Network:request("game.itemsHandler.speedupProduceQueue",  {item_id = 10002, queue_id = self.m_showInfo.queuePos-1}, function (rc, receiveData)
			if receiveData.code ~= 1 then
				Tips:create(ServerCode[receiveData.code]);
			end
		end);
		self:onBtnClose();
	end
	ccbMessageBox.onBtnCancel = function ()
		ccbMessageBox:removeSelf();
	end
end

function CCBProduceSpeedUp:onBtnClose()
	App:getRunningScene():getViewBase().m_ccbProduceView1:closeViewSpeedUp();

	local msgBox = App:getRunningScene():getChildByTag(display.Z_MESSAGE_HINT-1);
	if msgBox then
		msgBox:removeSelf();
	end
end

function CCBProduceSpeedUp:showTimeFormat(time)
	local hour = math.floor(time / 3600);
	local minute = math.floor((time % 3600) / 60);
	local second = time % 60;
	return string.format("%02d:%02d:%02d", hour, minute, second);	
end

function CCBProduceSpeedUp:addCellEffectAnim(isAnimImmediateFinish)
	local parent = self.m_cell.m_ccbNodeOnLightAnim;
	if isAnimImmediateFinish then
		local armature = ResourceMgr:getProduceViewArmature("fx_ui_prod_finish");
		parent:addChild(armature);
		armature:getAnimation():play("anim01");
		armature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				parent:removeAllChildren();			
			end
		end)
	else
		local armature = ResourceMgr:getProduceViewArmature("fx_ui_prod_speed");
		parent:addChild(armature);
		armature:getAnimation():play("anim01");
		armature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				parent:removeAllChildren();
			end
		end)
	end
end

function CCBProduceSpeedUp:useDiamondCount(time)
	self.m_needCostDiamond = math.ceil(self.m_showProduceLeftTime / 15);
	self.m_ccbLabelDiamondCost:setString(self.m_needCostDiamond);
	self.m_ccbLabelDiamondCost:setColor(UserDataMgr:getPlayerDiamond() < self.m_needCostDiamond and cc.RED or cc.WHITE);
end

return CCBProduceSpeedUp