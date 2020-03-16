local Tips = require("app.views.common.Tips");
local ResourceMgr = require("app.utils.ResourceMgr");
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");

local CCBPlanetExplore = class("CCBPlanetExplore", function ()
	return CCBLoader("ccbi/exploreView/CCBPlanetExplore.ccbi")
end)

function CCBPlanetExplore:ctor()
	if display.resolution  >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
	UserDataMgr:setStateExploring(true);

	self.m_data = {};
	local data = table.clone(require("app.constants.planet_explore")) or {};

	for i,v in pairs(data) do
		local index = tonumber(i);
		if index >= #self.m_data then
			table.insert(self.m_data, v);
		else
			table.insert(self.m_data, index, v);
		end
	end

	self:coverLayer();
	self:init();	
end

function CCBPlanetExplore:createDifficultyLevel()
	local function createBtn()
		local posy = 520;
		for i,v in pairs(self.m_data) do
			local btn = ccui.Button:create("res/resources/common/btn2_green_n.png", 
				"res/resources/common/btn2_green_h.png",
				"res/resources/common/btn2_green_n.png");
			btn:setTitleText("等级"..i);
			btn:setTitleFontSize(30);
			btn:setTag(i);
			btn:setPosition(cc.p(display.cx+340, posy));
			btn:addTouchEventListener(function(sender, event)
				if event == ccui.TouchEventType.ended then
					self:randomDifficulty(v.difficulty_level);
					self:specialFight();
					for j,k in pairs(self.m_data) do
						self.m_ccbNodeTouch:removeChildByTag(j);
					end
				end
			end);

			self.m_ccbNodeTouch:addChild(btn);
			posy = posy - 70;
		end
	end

	if table.nums(self.m_data)>0 then
		createBtn();
	else
		local ccbToShopMsgBox = CCBMessageBox:create(Str[3004], "请在星球探险表里配置难度等级数据", MB_OK);
		ccbToShopMsgBox.onBtnOK = function()
			ccbToShopMsgBox:removeSelf();
		end
	end
end

function CCBPlanetExplore:close()
	UserDataMgr:setStateExploring(false);
	self:removeSelf();
end

function CCBPlanetExplore:setItemTips()
	local itemTips = App:getRunningScene():getChildByTag(TAG_ITEM_TIPS);
	if itemTips then
		itemTips:setVisible(true);
		itemTips:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
			itemTips:setShowNext(true);
		end)));
	end
end

function CCBPlanetExplore:init()
	local exploreData = nil;
	Network:request("explore_battle.exploreHandler.star_explore", nil, function (rc, receiveData)
		if receiveData.code ~= 1 then
			self:close();
			Tips:create(ServerCode[receiveData.code]);
			return;
		end

		exploreData = receiveData or {};
		local armature = ResourceMgr:getAnimArmatureByNameOnMain("planetar_adventure");
		self.m_animPlanetarAdventure = armature;
		self.m_ccbNodeExploreAnim:addChild(armature);
		-- armature:setPosition(cc.p(display.cx, display.cy));
		armature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				if movementID == "anim01" then					
					self:normalFight();
				elseif movementID == "anim02" then
					--self:createDifficultyLevel()--打开等级按钮，测试专用

					math.randomseed(os.time());
					local data = self.m_data[math.random(1, #self.m_data)];
					self:randomDifficulty(data.difficulty_level);
					self:specialFight();
				elseif movementID == "victory" or movementID == "failure" then
					self.m_isResult = true;

					self:setItemTips();
				end
			end
		end)

		if exploreData.is_normal then
			self.m_animPlanetarAdventure:getAnimation():play("anim01");
		else
			self.m_animPlanetarAdventure:getAnimation():play("anim02");
		end
	end)
end

--遮蔽层
function CCBPlanetExplore:coverLayer()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
    listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);
    listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED);
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbNodeTouch);
end

function CCBPlanetExplore:onTouchEnded(touch, event)
	if self.m_nodeTarget then
		local width = self.m_nodeTarget:getContentSize().width*0.5;
		local minPosx = self.m_nodeTarget:getPositionX() - width - self.m_fbarMoveOffset;
		local maxPosx = self.m_nodeTarget:getPositionX() + width + self.m_fbarMoveOffset;
		local curPosx = self.m_ccbSpriteBar:getPositionX();
		if minPosx <= curPosx and curPosx <= maxPosx then
			self:result("loading_success", "victory", true);
		else
			self:result("loading_lose", "failure", false);
		end
		transition.removeAction(self.m_actionCountdown);
		self.m_nodeTarget = nil;
	elseif self.m_isResult then
		self:close();

		self:setItemTips();
	end
end

function CCBPlanetExplore:result(animName, frameName, is_winner)
	local armature = ResourceMgr:getAnimArmatureByNameOnMain(animName);
	self.m_ccbNodeExploreReady:addChild(armature);
	armature:setPosition(cc.p(self.m_ccbNodeTipAnim:getPositionX(), self.m_ccbNodeTipAnim:getPositionY()));
	armature:getAnimation():play("anim01");
	armature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			armature:removeSelf();
			armature = nil;
			
			self.m_ccbNodeExploreReady:removeAllChildren();

			Network:request("explore_battle.exploreHandler.receive_special_award", {is_winner=is_winner}, function (rc, receiveData)
				if receiveData.code ~= 1 then
					Tips:create(ServerCode[receiveData.code]);
				end

				self.m_animPlanetarAdventure:getAnimation():play(frameName);
			end)
		end
	end)
end

function CCBPlanetExplore:normalFight()
	self:close();

	self:setItemTips();
end

function CCBPlanetExplore:randomDifficulty(level)
   	local data = self.m_data[level];
   	local scale = data.target_size_percent;
   	self.m_ccbSpriteTarget:setScaleX(scale);

	local size = self.m_ccbNodeTarget:getContentSize();
	size.width = size.width*scale;
	--size.height = size.height*scale;
	self.m_ccbNodeTarget:setContentSize(size);

   	self.m_nSliderMoveTime = data.bar_duration;

	self.m_fbarMoveOffset = self.m_ccbSpriteBar:getContentSize().width*0.21*scale;
   	local startPosx = self.m_ccbSpriteBar:getPositionX();
   		--+ (self.m_ccbSpriteBar:getContentSize().width*0.5 - self.m_fbarMoveOffset);
	local width = self.m_ccbSpriteBarBg:getContentSize().width;-- - startPosx*0.5;
	
	local endPosx;
	local tmp_start = data.target_random_posx_start_percent;
	if tmp_start > data.target_random_posx_end_percent then
		endPosx = startPosx + width*tmp_start;
		startPosx = startPosx + width*data.target_random_posx_end_percent;
	else
		endPosx = startPosx + width*data.target_random_posx_end_percent;
		startPosx = startPosx + width*tmp_start;
	end
   	
   	local posx = math.random(startPosx, endPosx);
   	self.m_ccbSpriteTarget:setPositionX(posx);
   	self.m_ccbNodeTarget:setPositionX(posx);
   	self.m_ccbSpriteTargetTip:setPositionX(posx);
   	self.m_ccbSpriteTargetArrow:setPositionX(posx);
end

function CCBPlanetExplore:specialFight()
	local adventure_attack = ResourceMgr:getAnimArmatureByNameOnMain("adventure_attack");
	self.m_ccbNodeExploreReady:addChild(adventure_attack);
	adventure_attack:getAnimation():play("anim01");
	adventure_attack:setPosition(cc.p(self.m_ccbNodeAdventureAttack:getPositionX(), self.m_ccbNodeAdventureAttack:getPositionY()));

	local armature = ResourceMgr:getAnimArmatureByNameOnMain("adventure_countdown");
	self.m_ccbNodeExploreReady:addChild(armature);
	-- armature:setPosition(cc.p(display.cx, display. cy));
	armature:getAnimation():play("anim01");
	armature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			armature:removeSelf();
			armature = nil;

			self.m_nodeTarget = self.m_ccbNodeTarget;

			self.m_ccbSpriteBar:setVisible(true);
			local startPos = cc.p(self.m_ccbSpriteBar:getPositionX(), self.m_ccbSpriteBar:getPositionY());
			local endPos = clone(startPos);
			endPos.x =  endPos.x + self.m_ccbSpriteBarBg:getContentSize().width;
			local seq = cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(self.m_nSliderMoveTime, endPos), cc.CallFunc:create(function()
				self.m_ccbSpriteBar:setPositionX(startPos.x);
			end)))	
			self.m_actionCountdown = transition.execute(self.m_ccbSpriteBar, seq);
		end
	end)
	
	self.m_ccbNodeExploreReady:setVisible(true);
end

return CCBPlanetExplore;