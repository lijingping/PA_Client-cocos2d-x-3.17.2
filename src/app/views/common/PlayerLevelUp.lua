local ResourceMgr = require("app.utils.ResourceMgr");

local PlayerLevelUp = class("PlayerLevelUp", cc.Node);

function PlayerLevelUp:ctor(lastLevel, nowLevel)
	print("-----------------playerLevel   ctor");
	print(" runningSceneName ", App:getRunningSceneName());
	if display.resolution >= 2 then
		self:setScale(display.reduce);
	end

	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return true; end, cc.Handler.EVENT_TOUCH_BEGAN);
	local dispatcher = self:getEventDispatcher();
	dispatcher:addEventListenerWithSceneGraphPriority(listener, self);

	local levelUpAnim = ResourceMgr:getCommonArmature("grade_up");
	self:addChild(levelUpAnim);
	levelUpAnim:getAnimation():play("anim01");
	levelUpAnim:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
		if evt == "showLevel" then
			local lastLevelLabel = cc.LabelBMFont:create("Lv." .. lastLevel, ResourceMgr:getPlayerLevelUpFont());
			lastLevelLabel:setPositionY(-7);
			levelUpAnim:getBone("grade_last"):addDisplay(lastLevelLabel, 0);
			levelUpAnim:getBone("grade_last"):changeDisplayWithIndex(0, true);
			local levelLabel = cc.LabelBMFont:create("Lv." .. nowLevel, ResourceMgr:getPlayerLevelUpFont());
			levelLabel:setPositionY(-7);
			levelUpAnim:getBone("grade_back"):addDisplay(levelLabel, 0);
			levelUpAnim:getBone("grade_back"):changeDisplayWithIndex(0, true);
		end
	end)

	levelUpAnim:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			UserDataMgr:setPlayerLastLevel(nowLevel);

			local ensureBtn = ccui.Button:create(ResourceMgr:getGreenBtnNormal(), ResourceMgr:getGreenBtnHigh(),
				ResourceMgr:getGreenBtnHigh());
			self:addChild(ensureBtn);
			ensureBtn:setPositionY(-250);
			ensureBtn:addClickEventListener(function()
				-- self:removeSelf();
				if nowLevel % 20 == 1 then
					if device.platform == "android" or device.platform == "ios" then
						local videoPlayer = ccexp.VideoPlayer:create()
						local function onVideoEventCallback(sener, eventType)
						    if eventType == ccexp.VideoPlayerEvent.COMPLETED then
						        print("视频播放结束");
						        videoPlayer:removeSelf();
						        App:getRunningScene():getViewBase().m_ccbMainView:bgAnimationByDomainNum(App:getRunningScene():getViewBase().m_ccbMainView.m_playerDomain);
						        self:removeSelf();
						    end
						end
						local domain = math.ceil(nowLevel * 0.05);
						--videoPlayer:setPosition(cc.p(display.cx, display.cy));
						videoPlayer:setContentSize(cc.size(display.size.width, display.size.height));
						videoPlayer:setFileName("res/movie/cutscenes" .. domain .. "_1.mp4");
						videoPlayer:addEventListener(onVideoEventCallback);
						self:addChild(videoPlayer);
						videoPlayer:play();
					else
						self:removeSelf();
					end
				else
					self:removeSelf();
				end				
			end);

			local ensureBtnTitle = cc.Sprite:create(ResourceMgr:getBtnEnsureTitleSprite());
			self:addChild(ensureBtnTitle);
			ensureBtnTitle:setPositionY(-250);
		end
	end);
	App:getRunningScene():addChild(self, display.Z_MESSAGE_HINT);
	self:setPosition(display.center);

end

return PlayerLevelUp;