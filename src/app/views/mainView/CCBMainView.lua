local FrameLayer = require("app.views.common.FrameLayer")

local FloatingObjLayer = require("app.views.mainView.FloatingObjLayer")
local debugView = require("app.views.debugView.debugView")
local Tips = require("app.views.common.Tips")
local DescripProp = require("app.views.common.DescripProp");

local Planet = require("app.views.mainView.Planet");
local CCBChangeName = require("app.views.mainView.CCBChangeName")
local ResourceMgr = require("app.utils.ResourceMgr");
local CCBSearchView = require("app.views.searchView.CCBSearchView");
local CCBChannel = require("app.views.mainView.CCBChannel");
local CCBShowBuff = import(".CCBShowBuff");
local CCBPlanetExplore = require("app.views.exploreView.CCBPlanetExplore");
local CCBRankAward = require("app.views.rankView.CCBRankAward");
local CCBExchangeCoin = require("app.views.commonCCB.CCBExchangeCoin");
local CCBExchangeDiamond = require("app.views.commonCCB.CCBExchangeDiamond");
local CCBSetView = require("app.views.setView.CCBSetView");
local CCBChatView = require("app.views.chatView.CCBChatView");

local LEAGUE_LEVEL_LIMIT = 15
-------------------
-- CCB主界面
-------------------
local CCBMainView = class("CCBMainView", function ()
	return CCBLoader("ccbi/mainView/CCBMainView.ccbi")
end)

local itemWidth = 120;
local itemHeight = 120;

function CCBMainView:ctor()
	if display.resolution >= 2 then
        self.m_ccbNodeRightList:setScale(display.reduce);
    end
	self:coverLayer();

	self:init();
	self:isNewPlayer();
	self.m_isHideBottom = false;

	--Audio:setMusicVolume(1);
	--Audio:setEffectsVolume(1);
end

function CCBMainView:init()
	self:enableNodeEvents();
	-------------------------
	-- backgrounds
	-------------------------
	self.frameLayer = FrameLayer:create():addTo(self.root_layer)
	self.m_ccbNodeTop:setPositionY(self.frameLayer.top);
	self.m_ccbNodeBottom:setPositionY(self.frameLayer.bottom);

	-- exp New Bar
	self.m_newExpBar = cc.ProgressTimer:create(cc.Sprite:create(ResourceMgr:getFamousBarPng()));
	self.m_newExpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR);
	self.m_newExpBar:setPercentage(0);
	self.m_ccbNodeHalfExpBar:addChild(self.m_newExpBar);
	--从下到上
    self.m_newExpBar:setMidpoint(ccp(0.5, 0));
    self.m_newExpBar:setBarChangeRate(ccp(0, 1));
	
	self:setVisibleOfStateBtn();

	self.m_ccbSliderExp = ccui.Slider:create();
    self.m_ccbSliderExp:loadBarTexture("res/resources/mainView/main_loading2_2.png");
    self.m_ccbSliderExp:loadProgressBarTexture("res/resources/mainView/main_loading2_3.png");
	self.m_ccbSliderExp:setPercent(0);
	self.m_ccbSliderExp:setTouchEnabled(false);
	self.m_ccbSliderExp:setPosition(cc.p(0, 0));
	self.m_ccbNodeExp:addChild(self.m_ccbSliderExp);

	local labelPower = cc.LabelBMFont:create(0, "res/font/fight_num.fnt")
	labelPower:setAnchorPoint(self.m_ccbLabelPower:getAnchorPoint())
	    :setPosition(cc.p(self.m_ccbLabelPower:getPositionX(), self.m_ccbLabelPower:getPositionY()))
	    :addTo(self.m_ccbLabelPower:getParent())
    self.m_ccbLabelPower:removeSelf()
    self.m_ccbLabelPower = labelPower

    self.m_fadeBtn = {};
    for i = 1, 3 do
		self.m_fadeBtn[#self.m_fadeBtn+1] = self.m_ccbNodeRightList:getChildByTag(i);
	end
	for i = 1, 6 do
		self.m_fadeBtn[#self.m_fadeBtn+1] = self.m_ccbNodeBottomHide:getChildByTag(i);
	end
	self.m_fadeBtn[#self.m_fadeBtn+1] = self.m_ccbBtnSearchExplore;
	self.m_fadeBtn[#self.m_fadeBtn+1] = self.m_ccbBtnOpenShipView;
	self.m_fadeBtn[#self.m_fadeBtn+1] = self.m_ccbBtnOpenProduceView;
	self.m_fadeBtn[#self.m_fadeBtn+1] = self.m_ccbBtnRankAward;
	-- dump(self.m_fadeBtn);

	local playerLevel = UserDataMgr:getPlayerLevel();
	self.m_playerDomain = self:getPlayerDomainNum(playerLevel);
	self:bgAnimationByDomainNum(self.m_playerDomain);

	local size = self.m_ccbNodeDescripProp:getContentSize();
	local scale9Sprite = cc.Scale9Sprite:create(ResourceMgr:getAlpha0Sprite())
	local btn = cc.ControlButton:create(cc.Label:createWithSystemFont("", "", 0), scale9Sprite);
	btn:setPreferredSize(size);
	btn:setPosition(cc.p(size.width/2, size.height/2));
	btn:addTo(self.m_ccbNodeDescripProp);
	btn:registerControlEventHandler(function()
		self:openDescProp();
	end, cc.CONTROL_EVENTTYPE_TOUCH_DOWN);
	btn:registerControlEventHandler(function()
		self:deleteDescProp();
	end, cc.CONTROL_EVENTTYPE_DRAG_EXIT);--拖动刚离开内部时（保持触摸状态下）
	btn:registerControlEventHandler(function()
		self:deleteDescProp();
	end, cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE);--在内部抬起手指（保持触摸状态下）
	btn:registerControlEventHandler(function()
		self:deleteDescProp();
	end, cc.CONTROL_EVENTTYPE_TOUCH_CANCEL);--取消触点时
end

function CCBMainView:onEnter()
	self:requestRankAwardStatus();
end

function CCBMainView:onExit()

end

function CCBMainView:setVisibleOfStateBtn()
	if UserDataMgr:getPlayerStateCount() == 0 then
		self.m_ccbBtnShowBuff:setVisible(false);
		self.m_ccbBtnShowBuff:setEnabled(false);
	else
		self.m_ccbBtnShowBuff:setVisible(true);
		self.m_ccbBtnShowBuff:setEnabled(true);		
	end
end

function CCBMainView:lockingInterface()
	print("Locking");
	self.m_listener:setSwallowTouches(true);--layer为最上层，事件不向下传递，锁定该界面操作
end

function CCBMainView:unlockInterface()
	print("Unlock");
	self.m_listener:setSwallowTouches(false);--向下传递
end

-- 陨石
function CCBMainView:createAerolite(domainNum)
	--print("##createAerolite")
	-- if domainNum > 2 then
	-- 	domainNum = 2;
	-- end

	local armatureName = "scene" .. domainNum .. "_part2";

	local armature = ResourceMgr:getAnimArmatureByNameOnMain(armatureName);		
	math.randomseed(os.clock());
	local index = math.random(1, 3);

	armature:getAnimation():play("anim0" .. index);
	self.m_ccbNodeAerolite:addChild(armature);
	armature:setPosition(cc.p(display.cx, display.cy));

	armature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID) 
		if movementType == ccs.MovementEventType.complete then
			local index = math.random(1, 3);
			armature:getAnimation():play("anim0" .. index);	
		end	
	end)
end

--新玩家
function CCBMainView:isNewPlayer()
	print("#####CCBMainView:isNewPlayer")
	
	local playerName = UserDataMgr:getPlayerName()
	-- dump(userData)
	if playerName == nil or playerName == "" then
		--隐藏下层按钮
		self:hideBottom() 
		--按钮不可见
		self.m_ccbNodeTopHide:setVisible(false);
		self.m_ccbNodeTop:setVisible(false);
		self.m_ccbBtnOpenShipView:setVisible(false);
		self.m_ccbBtnOpenProduceView:setVisible(false);
		self:lockingInterface();
		self:playerHeadAnime(); --播放开场动画

		-- 播放新玩家创号音乐

	end
end

--开头动画（需要判断是否播放）
function CCBMainView:playerHeadAnime()
	self:jumpAnime();
	-- self.m_armatureStory = ResourceMgr:getAnimArmatureByNameOnOthers("begin_anim1");
	-- self.m_armatureStory:getAnimation():play("scene1");
	-- self:add(self.m_armatureStory, 1, 100);
	-- self.m_armatureStory:setPosition(display.center);

	-- self.m_armatureStory:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
	-- 	if movementType == ccs.MovementEventType.complete then			
	-- 		local sceneCount = 5;
	-- 		for i = 1, sceneCount-1 do
	-- 			if movementID == "scene" .. i then
	-- 				self.m_armatureStory:getAnimation():play("scene" .. i+1);
	-- 			end
	-- 		end
	-- 		if movementID == "scene" .. sceneCount then
	-- 			print("end");
	-- 			self.m_ccbLayerCover:removeAllChildren();
	-- 			self.m_armatureStory:removeSelf();
	-- 			self:unlockInterface();
	-- 			self:setNamePopup();
	-- 		end
	-- 		Audio:preloadMusic(1, "res/music/mainScene_1.mp3");
	-- 		Audio:playMusic(1, true);
	-- 	end
	-- end)

	if device.platform == "android" or device.platform == "ios" then
		local videoPlayer = ccexp.VideoPlayer:create()
		local function onVideoEventCallback(sener, eventType)
		    if eventType == ccexp.VideoPlayerEvent.COMPLETED then
		        print("视频播放结束");
		        videoPlayer:removeSelf();
		        -- self.m_ccbLayerCover:removeAllChildren();
		        self:getChildByTag(300):removeSelf();
		        self:unlockInterface();
				self:setNamePopup();

		        Audio:preloadMusic(1, "res/music/mainScene_1.mp3");
				Audio:playMusic(1, true);
		    end
		end

		videoPlayer:setPosition(cc.p(display.cx, display.cy));
		videoPlayer:setContentSize(cc.size(display.size.width, display.size.height));
		videoPlayer:setFileName(ResourceMgr:getGameBeginMovie());
		videoPlayer:addEventListener(onVideoEventCallback);
		self:addChild(videoPlayer, 1, 100);
		videoPlayer:play();
	else
		-- self.m_ccbLayerCover:removeAllChildren();
		self:unlockInterface();
		self:setNamePopup();
	end	
end

--创建取名弹窗（开头动画播放完毕后出现）
function CCBMainView:setNamePopup()
	local CCBChangeName = CCBChangeName:create();
	self:addChild(CCBChangeName, 2, 100);
end

--动画跳过按钮
function CCBMainView:jumpAnime()
	Tips:create("创建  动画跳过按钮");
	local btnJump = cc.Scale9Sprite:create(ResourceMgr:getAlpha0Sprite())  
	local titleBtnLabel = cc.Label:createWithSystemFont("", "", 30);
	local btnJumpStoryAnime = cc.ControlButton:create(titleBtnLabel, btnJump); 
	btnJumpStoryAnime:setPreferredSize(cc.size(300,300));
	btnJumpStoryAnime:setPosition(cc.p(1100, 620));
	btnJumpStoryAnime:registerControlEventHandler(
		function() 
			print("  跳过动画按钮 。。。 ");
			Tips:create("  跳过动画按钮 。。。 ");
			btnJumpStoryAnime:setEnabled(false);
			Audio:playEffect(11, false);
			-- btnJumpStoryAnime:removeSelf();
			-- self.m_ccbLayerCover:removeAllChildren();
			self:unlockInterface();
			self:setNamePopup();
		end,
		cc.CONTROL_EVENTTYPE_TOUCH_DOWN)

    self:addChild(btnJumpStoryAnime, 3, 300);
end

--遮蔽层
function CCBMainView:coverLayer()
	self.m_listener = cc.EventListenerTouchOneByOne:create();
	self.m_listener:setSwallowTouches(false);--刚创建默认为可向下传递，需要时再调用locking和unlock

	self.m_listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN);--只有当began事件为true才能吞噬点击事件

    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_listener, self.m_ccbLayerCover);
end

function CCBMainView:onTouchBegan(touch, event)
	local convertIconPos = self.m_ccbNodeTop:convertToNodeSpace(touch:getLocation());
	if not cc.rectContainsPoint(self.m_ccbNodeDescripProp:getBoundingBox(), convertIconPos) then
		self:deleteDescProp();
	end
	return true;
end

function CCBMainView:deleteDescProp()
	if self.m_descProp then
		self.m_descProp:removeSelf();
		self.m_descProp = nil;
	end
end

function CCBMainView:openDescProp()
	if self.m_descProp == nil then
		self.m_descProp = DescripProp:create();
		self.m_descProp:setHeadData();

		local size = self.m_descProp:getScale9PicSize();
		self.m_descProp:setPositionY(self.m_descProp:getPositionY()-size.height);
		self.m_descProp:setPositionX(- display.width*0.5 + self.m_ccbNodeDescripProp:getContentSize().width*0.8);
		self.m_ccbNodeTop:addChild(self.m_descProp);
	end
end

-- create 漂流物
function CCBMainView:appearFloatingObj()
	-- self.floatingObjLayer:appear()

	if self.m_playerDomain then
		if self.m_floatingObjLayer == nil then    -- 防止在主界面熄屏的时候有的手机没断开连接
			self.m_floatingObjLayer = FloatingObjLayer:create(self.m_playerDomain):addTo(self.m_ccbNodeFloating);
		end
	end
end

function CCBMainView:setFreeFloating()
	self.m_floatingObjLayer = nil;
end

function CCBMainView:cleanData()
	self.m_ccbLabelName:setString("");
	self.m_ccbLabelPower:setString("");
	self.m_ccbLabelLevel:setString("");
	self.m_ccbLabelCoin:setString("");
	self.m_ccbLabelDiamond:setString("");
	self.m_ccbNodeRankIcon:removeAllChildren();
	self.m_ccbNodeAerolite:removeAllChildren();
	self.m_ccbNodeShips:removeAllChildren();
end

function CCBMainView:updateView()
	self:cleanData();
	-- dump(data);
	local playerName = UserDataMgr:getPlayerName();
	local playerPower = UserDataMgr:getPlayerPower();
	local playerLevel = UserDataMgr:getPlayerLevel();
	local PlayerUnionCoin = UserDataMgr:getPlayerUnionCoin();
	local playerLevelUpExp = UserDataMgr:getPlayerLvExp();
	local playerCurrentExp = UserDataMgr:getPlayerExp();
	
	self.m_ccbLabelName:setString(playerName);
	self.m_ccbLabelPower:setString(playerPower);
	self.m_ccbLabelLevel:setString(playerLevel);

	self:updateMoney();

	if playerLevelUpExp and playerCurrentExp and playerLevelUpExp ~= 0 then
		self.m_ccbSliderExp:setPercent((playerCurrentExp / playerLevelUpExp) *100);
	end

	local playerFamous = UserDataMgr:getPlayerFamous();
	local toNextExp = UserDataMgr:getNextRankNeedExp();
	local rankInfo = UserDataMgr:getPlayerRankInfo();
	self.m_newExpBar:setPercentage((rankInfo.curExp / rankInfo.levelUpExp) * 100);
	self.m_ccbNodeRankIcon:addChild(self:getRankIcon(playerFamous));

	self.m_playerDomain = self:getPlayerDomainNum(playerLevel);
	self:playBgMusic(self.m_playerDomain);
	-- self.shipLayer = BGShipLayer:create(self.m_playerDomain):addTo(self.m_ccbNodeShips)
end

function CCBMainView:playBgMusic(starDomain)
	if self.m_recordPreStarDomain and starDomain ~= self.m_recordPreStarDomain then
		Audio:preloadMusic(starDomain, "res/music/mainScene_" .. starDomain .. ".mp3");
		Audio:playMusic(starDomain, true);
	end
	if not Audio:isMusicPlaying() then
		Audio:preloadMusic(starDomain, "res/music/mainScene_" .. starDomain .. ".mp3");
		Audio:playMusic(starDomain, true);
	end
	self.m_recordPreStarDomain = starDomain;
end

function CCBMainView:moneyFormat(node, value)
	if value >= 100000 then
		node:setString(string.format("%d%s", math.floor(value / 10000), Str[10011]));
	else
		node:setString(value);
	end
end

function CCBMainView:updateMoney()
	self:moneyFormat(self.m_ccbLabelCoin, UserDataMgr:getPlayerGoldCoin());
	self:moneyFormat(self.m_ccbLabelDiamond, UserDataMgr:getPlayerDiamond());
end

function CCBMainView:getPlayerDomainNum(playerLevel)
	if playerLevel > 80 then		 
		return 5;
	elseif playerLevel > 60 then  
		return 4;
	elseif playerLevel > 40 then
		return 3;
	elseif playerLevel > 20 then
		return 2;
	else 
		return 1;
	end
end

function CCBMainView:bgAnimationByDomainNum(domainNum)
	--加载背景动画，根据星域来显示
	-- if domainNum > 2 then
	-- 	domainNum = 2; --现资源只有1和2星域
	-- end
	self.m_ccbNodeAnimBG:removeAllChildren();
	local animBgName = "main_scene" .. domainNum;
	local armature = ResourceMgr:getAnimArmatureByNameOnMain(animBgName);
	armature:getAnimation():play("anim01");
	-- armature:setScale(display.scale)
	self.m_ccbNodeAnimBG:add(armature);
	armature:setPosition(display.center);

	self.m_ccbSpriteLight1:setTexture(ResourceMgr:getUpMaskByDomainNum(domainNum));
	self.m_ccbSpriteLight2:setTexture(ResourceMgr:getUpMaskByDomainNum(domainNum));
end

--获得军衔图标
function CCBMainView:getRankIcon(famousNum)
	local rankTable = table.clone(require("app.constants.rank_exp"));
	local rankExp = {};
	for k, v in pairs(rankTable) do 
		rankExp[v.id] = v;
	end

	for i = 1, #rankExp - 1 do
		if famousNum >= rankExp[i].exp and famousNum < rankExp[i + 1].exp then
			local resRankIconPaht = ResourceMgr:getRankBigIconByLevel(rankExp[i].level);
			return cc.Sprite:create(resRankIconPaht):setScale(0.35);
		end
	end
end
---------------------------------------------
-- 按钮响应时间
---------------------------------------------
function CCBMainView:onBtnOpenChatView()
	print("chat")
	-- pitch(高音) 0.5 - 2.0; pan(立体效果) -1.0 - 1.0 小于0增强左声道，大于0增强右声道，0.0是正常值; gain(音量) 0以上 1.0是正常值
	Audio:playEffect(11, false, 1, 0, 1);

	local chatView = CCBChatView:create();
	chatView:setName("CCBChatView");
	App:getRunningScene():addChild(chatView);
end

function CCBMainView:onBtnOpenShipView()
	-- print("  ^^^^^^^^^^^^^^^ship")
	Audio:playEffect(11, false, 1, 0, 1);
	App:enterScene("ShipScene");	
end

function CCBMainView:onBtnOpenShopView()
	-- print("shop")
	Audio:playEffect(11, false, 1, 0, 1);
	App:enterScene("ShopScene")	
end

function CCBMainView:onBtnOpenResourceView()
	Audio:playEffect(11, false, 1, 0, 1);
	App:enterScene("PackageScene");	
end

function CCBMainView:onBtnOpenFriendView()
	-- print("social")
	Audio:playEffect(11, false, 1.5, 0, 1);
	App:enterScene("FriendScene");
end

function CCBMainView:onBtnOpenUnionView()
	--Audio:playEffect(11, false, 2, 0, 1);

	if UserDataMgr:getPlayerLevel() < LEAGUE_LEVEL_LIMIT then
		Tips:create(string.format(Str[24008], LEAGUE_LEVEL_LIMIT));
	else
		App:enterScene("LeagueScene");
	end
end

function CCBMainView:onBtnOpenProduceView()
	-- print("produce")
	Audio:playEffect(11, false, 1, 0, 1);
	ProduceDataMgr:setOffsetProduceView1(nil);
	App:enterScene("ProduceScene1");
end

function CCBMainView:onBtnAddCoin()
	print("gold")
	Audio:playEffect(11, false, 1, -0.5, 1);
	CCBExchangeCoin:create();
end

function CCBMainView:onBtnAddDiamond()
	print("diamond")
	Audio:playEffect(11, false, 1, -0.5, 4);
	CCBExchangeDiamond:create();
end

function CCBMainView:onBtnOpenRevengeView()
	Audio:playEffect(11, false, 1, 0.5, 1);
	App:enterScene("RevengeScene")	
end

function CCBMainView:onBtnOpenMailView()
	Audio:playEffect(11, false, 1, 0, 1);
	App:enterScene("MailScene")	
end

function CCBMainView:onBtnEscort()
	--print("护送贩售舰")
	Audio:playEffect(11, false, 1, 0, 1);
	App:enterScene("EscortScene");
end

function CCBMainView:enterDomainView()
	--print("进入公寓混战");
	Audio:playEffect(11, false);
	App:enterScene("DomainScene");
end

function CCBMainView:onBtnPvP()	--SearchView自带遮罩
	--print("开始请求PVP战斗");
	Audio:playEffect(11, false, 1, 0, 1);

	App:getRunningScene():requestWaitForBattle();
	App:getRunningScene():getViewBase():popSearchView();
end

function CCBMainView:onBtnHide()
	if self.m_isHideBottom == false then
		self:hideBottom();
	else
		self:showBottom();
	end
end

function CCBMainView:addCloseAction(btn, time)
	time = time or 0.3
	btn:runAction(cc.Sequence:create(cc.FadeOut:create(time),cc.CallFunc:create(function()
		btn:setEnabled(false);
	end)))
end

function CCBMainView:addOpenAction(btn, time)
	time = time or 0.3
	btn:runAction(cc.Sequence:create(cc.CallFunc:create(function()
		btn:setEnabled(true);
	end), cc.FadeIn:create(time)))
end

function CCBMainView:showBottom()
	self.m_isHideBottom = false;
	self.m_ccbSpriteArrowHide:runAction(cc.RotateTo:create(0.1, 0));

	for i = 1, #self.m_fadeBtn do
		self:addOpenAction(self.m_fadeBtn[i]);
	end

	for i = 7, 12 do
		self.m_ccbNodeBottomHide:getChildByTag(i):runAction(cc.FadeIn:create(0.3));
	end

	self.m_ccbSpriteRightListBg:setVisible(true);
end

function CCBMainView:hideBottom()
	self.m_isHideBottom = true;
	self.m_ccbSpriteArrowHide:runAction(cc.RotateTo:create(0.1, 180))

	for i = 1, #self.m_fadeBtn do
		self:addCloseAction(self.m_fadeBtn[i]);
	end

	for i = 7, 12 do
		self.m_ccbNodeBottomHide:getChildByTag(i):runAction(cc.FadeOut:create(0.3));
	end

	self.m_ccbSpriteRightListBg:setVisible(false);
end

--进入任务界面
function CCBMainView:onBtnShowMission()
	Audio:playEffect(11, false, 1, 0, 1);
	App:enterScene("TaskScene");
end

--进入寻宝界面
function CCBMainView:onBtnOpenLottery()
	Audio:playEffect(11, false, 1, 0, 1);
	App:enterScene("LotteryScene");	
end

--进入哪种战斗的菜单选项
function CCBMainView:onBtnSearchExplore()
	-- print("打开菜单");
	local channel = CCBChannel:create(self);
	self.m_ccbNodeChannel:addChild(channel);
end

function CCBMainView:onBtnShowBuff()
	print("显示加成状态");
	local showBuffPop = CCBShowBuff:create();
	-- self.m_ccbNodeChannel 是最上层的节点
	self.m_ccbNodeChannel:addChild(showBuffPop);
end

function CCBMainView:planetExplore()
	local planetExplore = CCBPlanetExplore:create(self);
	self:addChild(planetExplore);
end

function CCBMainView:requestRankAwardStatus()
	if UserDataMgr:isRankAwardGet() == nil then
		Network:request("game.taskHandler.query_rank_award_status", nil, function (rc, receiveData)
			if receiveData.code ~= 1 then
				Tips:create(ServerCode[reveiveData.code]);
				return;
			end

			UserDataMgr:setRankAwardGet(receiveData.is_rank_award_get == 1);
		end)
	end
end

function CCBMainView:onBtnRankAward()
	App:getRunningScene():addChild(CCBRankAward:create());
end

function CCBMainView:onBtnSet()
	App:getRunningScene():addChild(CCBSetView:create());
end

return CCBMainView