local BattleResourceMgr = require("app.utils.BattleResourceMgr");
local ShipMgr = import(".ShipMgr");
local BulletMgr = import(".BulletMgr");
local newEnergyBodyMgr = import(".newEnergyBodyMgr");
local CCBShowResult = import(".CCBShowWin");
local CCBShowLose = import(".CCBShowLose");
local CCBShowDraw = import(".CCBShowDraw");
local CCBEscortResult = require("app.views.escortView.CCBEscortResult");
local RankUpView = require("app.views.common.RankUpView");
local BuffWordTips = require("app.views.common.BuffWordTips");
local ResourceMgr = require("app.utils.ResourceMgr");
local PlayerLevelUp = require("app.views.common.PlayerLevelUp");

local CCBBattle = class("CCBBattle", function ()
	return CCBLoader("ccbi/battle/CCBBattle.ccbi")
end)

local Left_X = -1280*0.5 + 150;
local Right_X = 1280*0.5 - 150;

local SHIPS_POSITION = {LEFT = cc.p(Left_X,0),RIGHT = cc.p(Right_X,0)}

local FORTS_POSITION = {[1] = cc.p(Left_X,180),[2] = cc.p(Left_X,40), [3] = cc.p(Left_X,-100),
						[4] = cc.p(Right_X,180), [5] = cc.p(Right_X,40), [6] = cc.p(Right_X,-100)}


function CCBBattle:ctor()
	print("CCBBattle:ctor   ", os.time());

	if display.resolution >= 2 then
		self.m_ccbNodeBackground:setScale(display.reduce);
		self.m_ccbNodeShip:setScale(display.reduce);
		self.m_ccbNodeBullet:setScale(display.reduce);
		self.m_ccbNodeEnergy:setScale(display.reduce);
		self.m_ccbNodeEffectSkill:setScale(display.reduce);
		self.m_ccbNodeNpc:setScale(display.reduce);
		self.m_ccbNodeEffectItem:setScale(display.reduce);
		self.m_ccbNodeCloud:setScale(display.reduce);
		self.m_ccbLayerTouch:setScale(display.reduce);
		self.m_ccbNodeBtn:setScale(display.reduce);
	end
	self.m_battleType = BattleDataMgr:getBattleType();
	self.m_isTouch = false;
	self.m_isBattleBegin = false;

	-- self:setScale(display.scale);
	
	self.m_ccbNodeBtn:setVisible(false);
	self.m_armatureTargetFortPlayer = {};
	self.m_armatureTargetFortEnemy = {};
	self.m_armatureTargetNpc = nil;
	self.m_armatureTargetEnergyBody = nil;
	self.m_targetUseItem = -1;
	self.m_showWin = nil;
	self.m_showLose = nil;
	self.m_showDraw = nil;
	
	self:enabledTouchEvent();
	self:enableNodeEvents();
	self.m_onUpdateScheduler = nil;
	
	-- self.m_ccbNodeBackground;	背景层
	-- self.m_ccbNodeShip;			战舰和炮台层
	-- self.m_ccbNodeBullet;		子弹层
	-- self.m_ccbNodeEnergy; 		能量体层
	-- self.m_ccbNodeEffectSkill;	技能层
	-- self.m_ccbNodeNpc;			NPC层
	-- self.m_ccbNodeEffectItem;	物品特效层
	-- self.m_ccbNodeCloud;			云雾层
	-- self.m_ccbNodeResult;		结果显示层

	self:loadScene();	--加载场景的动画
	self:loadMusicFile(); --加载音乐文件
	self.m_escortResultData = nil; -- 护送战斗的结算数据

	-- 加载子弹
	BulletMgr:Init(self.m_ccbNodeBullet);   -- 这里先不把boss的子弹做预加载操作
	if self.m_battleType ~= 3 then
		newEnergyBodyMgr:Init(self.m_ccbNodeEnergy);
	end
	
	ShipMgr:Init(self.m_ccbNodeShip, self.m_ccbNodeCloud, self);
	ShipMgr:setEffectSkill(self.m_ccbNodeEffectSkill)
	print(" battle.ctor  的结束时间", os.time());
	-- dump(self);
end

function CCBBattle:onEnter()

end

function CCBBattle:onExit()
	if self.m_onUpdateScheduler then
		self:stopScheduler();
	end

	if UserDataMgr:getPlayerLastLevel() < UserDataMgr:getPlayerLevel() then
		PlayerLevelUp:create(UserDataMgr:getPlayerLastLevel(), UserDataMgr:getPlayerLevel());
	end
end

-- 加载场景
function CCBBattle:loadScene()
	-- print("CCBBattle:loadScene")
	-- 背景动画
	local backgroundArmature = nil;
		--云雾
	local cloudArmature;
	if self.m_battleType ~= 3 then   -- 普通战斗
		backgroundArmature = BattleResourceMgr:getBackGroundArmatureByLevel(UserDataMgr:getPlayerLevel());
		cloudArmature = BattleResourceMgr:getCloudArmatureByLevel(UserDataMgr:getPlayerLevel());
	elseif self.m_battleType == 3 then  -- boss战
		backgroundArmature = BattleResourceMgr:getBossBackGroundArmature();
		cloudArmature = BattleResourceMgr:getBossCloudArmature();
	end

	if backgroundArmature then
		self.m_ccbNodeBackground:addChild(backgroundArmature);
		backgroundArmature:getAnimation():play("anim01");
		backgroundArmature:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				math.randomseed(os.time());
				local index = math.random(2,3); -- 2和3两段动画随机循环播放
				backgroundArmature:getAnimation():play("anim0" .. index);
			end
		end);
	end

	
	if cloudArmature then
		self.m_ccbNodeCloud:addChild(cloudArmature);
		cloudArmature:getAnimation():play("anim01");
	end
end

-- boss战开始，需play 战舰1的idle
function CCBBattle:playShip1Idle()
	ShipMgr:playShip_1Idle();
	-- local callBack = cc.CallFunc:create(function() 
	-- 	ShipMgr:openShip1Deck();
	-- 	self:showUI();
	-- end)
	-- local sequence = cc.Sequence:create(cc.DelayTime:create(2), callBack);
	-- self:runAction(sequence);
end

function CCBBattle:playIdle1()
	ShipMgr:playIdle1();
end

--战斗不存在时战舰接口
function CCBBattle:battleShipBegin() -- 于battleScene:init()里执行
	-- print("CCBBattle:battleShipBegin")
	print("播放战斗背景音乐");
	self.m_shipFlyEffect = Audio:playEffect(102, false); -- 战斗入场飞船喷射音效
	-- Audio:playMusic(101, true); -- 战斗场景背景音乐

	-- 普通战斗
	local randomNum = math.random(1, 4);
	Audio:preloadMusic(30 + randomNum, "res/music/battleSceneBg_" .. randomNum .. ".mp3");
	Audio:playMusic(30 + randomNum, true);

	ShipMgr:playBegin();
end

function CCBBattle:playBossBattleMusic()
	Audio:preloadMusic(33, "res/music/battleSceneBg_3.mp3");
	Audio:playMusic(33, true);
end

--战斗存在时战舰接口
function CCBBattle:battleShipAgain()
	-- print("CCBBattle:battleShipAgain")
	ShipMgr:playIdle();
	-- 普通战斗
	local randomNum = math.random(1, 4);
	Audio:preloadMusic(30 + randomNum, "res/music/battleSceneBg_" .. randomNum .. ".mp3");
	Audio:playMusic(30 + randomNum, true);
end

function CCBBattle:showBossWarning()
	local bossWarnArmature = BattleResourceMgr:createBattleArmature("boss_start");-- boss战的警告动画
	bossWarnArmature:getAnimation():play("anim01");
	self.m_ccbNodeShip:addChild(bossWarnArmature);
	bossWarnArmature:setPosition(cc.p(0, 0));
	bossWarnArmature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			bossWarnArmature:removeSelf();
			bossWarnArmature = nil;
			ShipMgr:openShip1Deck();
			ShipMgr:bossEnterBattle();
			self:showUI();
		end
	end)
end

--显示战斗开始时的VS动画
function CCBBattle:showVS()
	-- print("显示VS动画")
		-- 入场飞船飞行动画执行完毕到显示玩家信息
		-- 设置喷射音效音量为百分90（这边我把喷射音效写成music）
		-- Audio:setMusicVolume(0.9);
	--VS半透明背景
	if display.resolution >= 2 then
		self.m_layerColorBG = cc.LayerColor:create(cc.c4b(0, 0, 0, 255 * 0.60), display.width / display.reduce, display.height / display.reduce)
	else
		self.m_layerColorBG = cc.LayerColor:create(cc.c4b(0, 0, 0, 255 * 0.60), display.width, display.height);
	end
	self.m_layerColorBG:setAnchorPoint(cc.p(0.5, 0.5));
	self.m_layerColorBG:ignoreAnchorPointForPosition(false);
	self.m_ccbNodeShip:add(self.m_layerColorBG);
	--左边飞船遮罩
	self.m_armatureVS1 = BattleResourceMgr:createBattleArmature("begin_vs2");
	self.m_armatureVS1:getAnimation():play("start");
	self.m_armatureVS1:setPosition(cc.p(display.c_left+150, 0));
	self.m_ccbNodeShip:add(self.m_armatureVS1);
	self.m_armatureVS1:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
	end)
	self.m_armatureVS1:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID) 
		if movementType == ccs.MovementEventType.complete then
			if movementID == "start" then
				self.m_armatureVS1:getAnimation():play("end");
				self.m_armatureVS2:getAnimation():play("end");
			elseif movementID == "end" then
				self.m_armatureVS1:setVisible(false);
				self.m_armatureVS2:setVisible(false);
			end
		end
	end)	
	--右边飞船遮罩
	self.m_armatureVS2 = BattleResourceMgr:createBattleArmature("begin_vs3");
	self.m_armatureVS2:getAnimation():play("start");
	self.m_armatureVS2:setPosition(cc.p(display.c_right-150, 0));
	self.m_ccbNodeShip:add(self.m_armatureVS2);
	self.m_armatureVS2:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
		if evt == "showName" then
			-- print("显示玩家名字战力")
			local playerInfo = BattleDataMgr:getCurPlayerInfo();
			-- dump(playerInfo.name)
			local labelName1 = cc.LabelTTF:create(playerInfo.name, "res/font/simhei.fft", 20);
			local labelFight1 = cc.LabelTTF:create(playerInfo.fight, "res/font/simhei.fft", 20);
			labelName1:setAnchorPoint(cc.p(0, 0.5));
			labelFight1:setAnchorPoint(cc.p(0, 0.5));
			self.m_armatureVS1:getBone("name1"):addDisplay(labelName1, 0);
			self.m_armatureVS1:getBone("fight1"):addDisplay(labelFight1, 0);
			self.m_armatureVS1:getBone("name1"):changeDisplayWithIndex(0, true);
			self.m_armatureVS1:getBone("fight1"):changeDisplayWithIndex(0, true);

			local enemyInfo = BattleDataMgr:getCurEnemyInfo();
			-- dump(enemyInfo.name)
			local labelName2 = cc.LabelTTF:create(enemyInfo.name, "res/font/simhei.fft", 20);
			local labelFight2 = cc.LabelTTF:create(enemyInfo.fight, "res/font/simhei.fft", 20);
			labelName2:setAnchorPoint(cc.p(0, 0.5));
			labelFight2:setAnchorPoint(cc.p(0, 0.5));
			self.m_armatureVS2:getBone("name2"):addDisplay(labelName2, 0);
			self.m_armatureVS2:getBone("fight2"):addDisplay(labelFight2, 0);
			self.m_armatureVS2:getBone("name2"):changeDisplayWithIndex(0, true);
			self.m_armatureVS2:getBone("fight2"):changeDisplayWithIndex(0, true);
		end	
	end)
	--显示玩家名字战力
	self.m_armatureVS3 = BattleResourceMgr:createBattleArmature("begin_vs1");
	self.m_armatureVS3:getAnimation():play("anim01");
	self.m_ccbNodeShip:add(self.m_armatureVS3);

	self.m_armatureVS3:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
		if evt == "enterBattle" then
			self.m_layerColorBG:removeSelf();
			self:showUI();
		end
		
	end)
end

--战斗场景的TopUI
function CCBBattle:showTop()
	self.m_ccbFileTop:InitData();
	local topPositionY = self.m_ccbFileTop:getPositionY();

	local topMoveHeight = -topPositionY + display.height;--display.designResolutionHeight + display.offsetY

	self.m_ccbFileTop:runAction(cc.MoveBy:create(0.5, cc.p(0, topMoveHeight)));
end

--战斗场景的BotUI
function CCBBattle:showBottom()
	self.m_ccbFileBottom:InitData(self);
	local bottomPosition = self.m_ccbFileBottom:getPositionY();

	local bottomMoveHeight = - bottomPosition;  --  -display.offsetY 

	self.m_ccbFileBottom:runAction(cc.MoveBy:create(0.5, cc.p(0, bottomMoveHeight)));
end

--------------触摸层-------------------
function CCBBattle:enabledTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerTouch)
end

function CCBBattle:onTouchBegan(touch, event)
	
	if not self.m_isTouch then
		return false;
	end
	print("CCBBattle:onTouchBegan");
	local touchPos = touch:getLocation();
	if self.m_battleType ~= 3 then
		if BattleDataMgr:getEnergyBodyPos() ~= 0 and math.abs(touchPos.y-BattleDataMgr:getEnergyBodyPos()) <= 40
		and math.abs(touchPos.x-640) <= 40 then
			newEnergyBodyMgr:onTouchBegan(touch, event);
		else
			self.m_ccbFileBottom:cancelAllSelect();
		end

		newEnergyBodyMgr:hideTargetEnergy();
	else
		self.m_ccbFileBottom:cancelAllSelect();
	end

	ShipMgr:hideAllTarget();
	return true;
end

function CCBBattle:onTouchMoved(touch, event)
	-- print("touch move");
end

function CCBBattle:onTouchEnded(touch, event)
	print("touch end");
end
-----------------------------------------

-- 返回错误代码，无法使用道具，要是有选中道具，就把选中道具恢复
function CCBBattle:cancelBottonAllSelectForNoUse()
	self.m_ccbFileBottom:cancelAllSelect();
end

---------------使用物品技能----------------
function CCBBattle:onBtnPlayerShip()
	print("CCBBattle:onBtnPlayerShip")
	ShipMgr:touchShip(1);
end

function CCBBattle:onBtnEnemyShip()
	print("CCBBattle:onBtnEnemyShip")
	ShipMgr:touchShip(2);
end

function CCBBattle:onBtnPlayerFort1()
	local isPlayer = true;
	ShipMgr:touchFort(1, isPlayer);
end

function CCBBattle:onBtnPlayerFort2()
	local isPlayer = true;
	ShipMgr:touchFort(2, isPlayer);
end

function CCBBattle:onBtnPlayerFort3()
	local isPlayer = true;
	ShipMgr:touchFort(3, isPlayer);
end

function CCBBattle:onBtnEnemyFort1()
	local isPlayer = false;
	ShipMgr:touchFort(1, isPlayer);
end

function CCBBattle:onBtnEnemyFort2()
	local isPlayer = false;
	ShipMgr:touchFort(2, isPlayer);
end

function CCBBattle:onBtnEnemyFort3()
	local isPlayer = false;
	ShipMgr:touchFort(3, isPlayer);
end


-- 物品的使用目标
-- 0-我方炮台（单体）
-- 1-我方舰体
-- 2-我方全体（舰体、所有炮台
-- 3-我方战损的炮台
-- 4-敌方炮台（单体
-- 5-敌方舰体
-- 6-敌方全体（舰体、所有炮台）
-- 7-能量体
-- 8-我方或敌方
function CCBBattle:showTarget(itemTargetType)
	-- print("itemTargetType 是多少~~~   ", itemTargetType);
	if self.m_battleType ~= 3 then
		newEnergyBodyMgr:hideTargetEnergy();
	end
	ShipMgr:hideAllTarget();
	if itemTargetType == 0 then
		ShipMgr:showTargetPlayerFortAlive();
	elseif itemTargetType == 1 then
		ShipMgr:showTargetPlayerShip();
	elseif itemTargetType == 2 then
		ShipMgr:showTargetPlayerShip();
	elseif itemTargetType == 3 then
		ShipMgr:showTargetPlayerFortDestroy();
	elseif itemTargetType == 4 then
		ShipMgr:showTargetEnemyFortAlive();
	elseif itemTargetType == 5 then 	--助战
		ShipMgr:showTargetEnemyShip();
	elseif itemTargetType == 6 then
		ShipMgr:showTargetEnemyShip();
	elseif itemTargetType == 7 then 	--目标是能量体	
		newEnergyBodyMgr:showTargetEnergy(self);
	elseif itemTargetType == 8 then 	--我方和敌方都可选
		ShipMgr:showTargetPlayerShip();
		ShipMgr:showTargetEnemyShip();
	end
end

function CCBBattle:UpdateCurSelectItem()
	ShipMgr:hideAllTarget();
	if self.m_battleType ~= 3 then
		newEnergyBodyMgr:hideTargetEnergy();
	end
end

function CCBBattle:updateItemEffect()
	local useItemData =  newBattle.propEvent()
	-- dump(useItemData)
	-- "<var>" = {
	--     1 = {
	--         1408 = 10
	--     }
	-- }

	for k,v in pairs(useItemData) do
		for k1,v1 in pairs(v) do
			if k1 ~= nil then
				print("  使用的道具ID   ： ", k1);
			print("使用道具更新特效")
				if k1 ~= 1408 and k1 ~= 75 then
					-- dump(v)
					self:showItemEffect(k1, v1)
				elseif k1 == 1408 then
					-- dump(useItemData)
					self:showFireSupportItemEffect(k1,v1)
				elseif k1 == 75 then
					-- dump(useItemData)
					self:NpcfireSupportEnd(v1)
				end
			end
		end
	end
end

-- 使用物品特效
-- arg 1~3为我方炮台,11~13敌方炮台, 0我方全体, 10敌方全体
function CCBBattle:showItemEffect(itemID, arg)
	print("使用的道具ID:"..itemID.."     目标是："..arg)
	-- 导弹道具音效有待整理
	local itemData = BattleDataMgr:getBattleItemByItemID(itemID);
	if itemData.missile == 1 then   -- 导弹道具
		Audio:playEffect(105, false);
		local sequence = cc.Sequence:create(cc.DelayTime:create(itemData.time), 
			cc.CallFunc:create(function()
				if itemData.target == 1 then   -- 单体导弹
					Audio:playEffect(115, false);
				elseif itemData.target == 2 then
					Audio:playEffect(116, false);
				end
			end)
		);
		self:runAction(sequence);
	else
		if itemID ~= 4004 then  
			Audio:playEffect(114, false);
		end
	end
	local iconID = ItemDataMgr:getItemBaseInfo(itemID).item_icon;
	local effectName = "item_" .. iconID;
	local armatureUseItem = BattleResourceMgr:createBattleArmature(effectName);
	if armatureUseItem == nil then
		-- local usePropPath = "道具动画资源不存在"
		-- local usePropLabel =  cc.Label:createWithTTF(usePropPath, "font/simhei.ttf", 24)
		-- self.m_ccbNodeEffectItem:removeChildByTag(19);
		-- self.m_ccbNodeEffectItem:addChild(usePropLabel, 19, 19);
		return;
	end 
	armatureUseItem:getAnimation():play("anim01")
	self.m_ccbNodeEffectItem:addChild(armatureUseItem)
	
	if 0 < arg and arg <= 3 then 	-- 我方炮台
		if itemID < 1100 then
			armatureUseItem:setScaleX(-1);
		else

		end
		
		armatureUseItem:setPosition(FORTS_POSITION[arg]);
	elseif 10 < arg and arg <= 13 then 	--敌方炮台(arg 11~13)
		print("对敌方炮台的道具  arg 等于", arg);
		if itemID < 1100 then

		else
			armatureUseItem:setScaleX(-1);
		end
		armatureUseItem:setPosition(FORTS_POSITION[arg-7]);
	elseif arg == 0 then 	--我方全体
		print("特效显示在左边战舰，需要翻转，显示的位置在中间炮台上");
		if itemID < 1100 then
			armatureUseItem:setScaleX(-1);
		else

		end
		armatureUseItem:setPosition(FORTS_POSITION[2]);
	elseif arg == 10 then 	--敌方全体
		print("对敌方炮台的道具  arg 等于", arg);
		if itemID < 1100 then

		else
			armatureUseItem:setScaleX(-1);
		end
		armatureUseItem:setPosition(FORTS_POSITION[5]);
	elseif arg == 4 then 	--能量体
		armatureUseItem:setPosition(cc.p(0,BattleDataMgr:getEnergyBodyPos()-360))
	end

	--动画播放事件，处理动画播放结束事件
	armatureUseItem:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			armatureUseItem:removeSelf();
		end
	end)
end

-- 显示播放战舰技能
function CCBBattle:showShipSkill(shipSkill, useShip, target)
	local shipIndex = shipSkill - 70000;
	local skillArmatureName = "ship" .. shipIndex .. "_skill";
	print("CCBattle:showShipSkill:  === ", skillArmatureName);
	local armature = BattleResourceMgr:createBattleArmature(skillArmatureName);
	if armature == nil then
		print("找不到战舰技能动画，无法播放");
		return ;
	end
	armature:getAnimation():play("anim01");
	self.m_ccbNodeEffectItem:addChild(armature);
	if useShip == 1 then   -- 使用方是自己
		if target == 0 then   -- 道具目标是对自己
			armature:setPosition(FORTS_POSITION[2]);
		else                  -- 道具目标是对敌人
			armature:setPosition(FORTS_POSITION[5]);
		end
	else
		armature:setScaleX(-1);
		if target == 0 then
			armature:setPosition(FORTS_POSITION[5]);
		else
			armature:setPosition(FORTS_POSITION[2]);
		end
	end
	armature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			armature:removeSelf();
		end
	end)
end

--召唤NPC道具特效
function CCBBattle:showFireSupportItemEffect(itemID, arg)
	print("火力支援的ItemID:  "..itemID.."    火力支援道具的打击目标是 arg : "..arg)
	self:fireSupportArmature(arg); -- 飞船动画
	local effectName = "item_"..itemID;
	if arg == 0 then 	--我方全体
		print("特效显示在左边战舰，需要翻转，显示的位置在中间炮台上");
		self.m_supportItemEffectToPlayer = BattleResourceMgr:createBattleArmature(effectName);
		self.m_supportItemEffectToPlayer:getAnimation():play("anim01")
		self.m_ccbNodeEffectItem:addChild(self.m_supportItemEffectToPlayer);
		self.m_supportItemEffectToPlayer:setScaleX(1);
		self.m_supportItemEffectToPlayer:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then		
				self.m_supportItemEffectToPlayer:removeSelf();
			end
		end)
	elseif arg == 10 then 	--敌方全体
		self.m_supportItemEffectToEnemy = BattleResourceMgr:createBattleArmature(effectName);
		self.m_supportItemEffectToEnemy:getAnimation():play("anim01")
		self.m_ccbNodeEffectItem:addChild(self.m_supportItemEffectToEnemy);
		self.m_supportItemEffectToEnemy:setScaleX(1);
		self.m_supportItemEffectToEnemy:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then		
				self.m_supportItemEffectToEnemy:removeSelf();
			end
		end)
	end
	
end

--召唤飞机火力支援动画特效(0我方全体, 10敌方全体)
function CCBBattle:fireSupportArmature(arg)
	Audio:playEffect(112, false);
	if arg == 0 then
		self.m_NpcFireArmatureToPlayer = BattleResourceMgr:getFireSupportArmature();
		self.m_NpcFireArmatureToPlayer:getAnimation():play("start");
 		self.m_ccbNodeNpc:addChild(self.m_NpcFireArmatureToPlayer);
		self.m_NpcFireArmatureToPlayer:setPositionX(Left_X);
		-- self.m_NpcFireArmatureToPlayer:setPositionX(0);
		self.m_NpcFireArmatureToPlayer:setScaleX(-1);
		self.m_NpcFireArmatureToPlayer:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
		if movementType == ccs.MovementEventType.complete then
			if movementID == "start" then
				local sequence = cc.Sequence:create(cc.CallFunc:create(function() Audio:playEffect(113, false); end), 
					cc.CallFunc:create(function() Audio:playEffect(116, false); end));
				self:runAction(sequence);

				self.m_NpcFireArmatureToPlayer:getAnimation():play("fire");
			end
			if movementID == "end" then
				self.m_NpcFireArmatureToPlayer:removeSelf();
			end
		end
	end)
	elseif arg == 10 then
		self.m_NpcFireArmatureToEnemy = BattleResourceMgr:getFireSupportArmature();
		self.m_NpcFireArmatureToEnemy:getAnimation():play("start");
 		self.m_ccbNodeNpc:addChild(self.m_NpcFireArmatureToEnemy);
		self.m_NpcFireArmatureToEnemy:setPositionX(Right_X);
		-- self.m_NpcFireArmatureToEnemy:setScaleX(-1);
		self.m_NpcFireArmatureToEnemy:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
		if movementType == ccs.MovementEventType.complete then
			if movementID == "start" then
				local sequence = cc.Sequence:create(cc.CallFunc:create(function() Audio:playEffect(113, false); end), 
					cc.CallFunc:create(function() Audio:playEffect(116, false); end));
				self:runAction(sequence);

				self.m_NpcFireArmatureToEnemy:getAnimation():play("fire");
			end
			if movementID == "end" then
				self.m_NpcFireArmatureToEnemy:removeSelf();
			end
		end
	end)
	end
	

end

function CCBBattle:NpcfireSupportEnd(arg)
	Audio:playEffect(112, false);
	if arg == 0 then
		if self.m_NpcFireArmatureToPlayer then
			self.m_NpcFireArmatureToPlayer:getAnimation():play("end");
		end
	else
		if self.m_NpcFireArmatureToEnemy then
			self.m_NpcFireArmatureToEnemy:getAnimation():play("end");
		end
	end
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

function CCBBattle:startScheduler()
	-- print("CCBBattle:startScheduler");
	if self.m_onUpdateScheduler == nil then
		if self.m_battleType ~= 3 then
			self.m_onUpdateScheduler = self:getScheduler():scheduleScriptFunc(function(dt) 
				self:onUpdate(dt); 
			end, 0, false);
		elseif self.m_battleType == 3 then
			self.m_onUpdateScheduler = self:getScheduler():scheduleScriptFunc(function(dt)
				self:onUpdateBossBattle(dt);
			end, 0, false);
		end
	end	
end

function CCBBattle:stopScheduler()
	if self.m_onUpdateScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_onUpdateScheduler);
		self.m_onUpdateScheduler = nil;
	end
end

function CCBBattle:onUpdate(dt)
	-- print("CCBBattle:onUpdate", dt);
	newBattle.update(dt);
	
	--战舰血量与时间显示
	self.m_ccbFileTop:refresh();

	--物品栏CD刷新
	self.m_ccbFileBottom:refresh(dt);
	self.m_ccbFileBottom:updateShipEnergy();

	--飞船上数据刷新，包含炮台的状态
	ShipMgr:refresh();

	--道具信息
	self:updateItemEffect();

	--子弹
	BulletMgr:refreshPlayerBullets();
	BulletMgr:refreshEnemyBullets();
	BulletMgr:refreshBulletEvent();

	--能量体
	newEnergyBodyMgr:refreshEvent();
	newEnergyBodyMgr:refresh();
end

function CCBBattle:onUpdateBossBattle(dt)
	newBattle.update(dt);

	self.m_ccbFileTop:refresh();

	self.m_ccbFileBottom:refresh(dt);
	self.m_ccbFileBottom:updateShipEnergy();

	ShipMgr:bossBattleRefresh();

	self:updateItemEffect();

	BulletMgr:refreshPlayerBullets();
	BulletMgr:refreshBulletEvent();
end

-- VS界面播放完显示战舰的血条，物品栏和炮台的状态栏
function CCBBattle:showUI()

	self:showTop();
	self:showBottom();
	ShipMgr:showFortState();
	self.m_ccbNodeBtn:setVisible(true);
	
	--测试时手动调用ready和startBattle
	-- self:ready(); 
	-- local function delayStart()
	-- 	self:startBattle();
	-- end
	-- local delayTask = cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(delayStart));
	-- self:runAction(delayTask);
end

-- 在CCBBattle:ready()里预载 or 在showUI里预载（这时候VS动画播放完了）
function CCBBattle:loadMusicFile()
	print("   加载战斗音乐 的 time ", os.time());
	for i = 1, 3 do
		local playerFortInfo = BattleDataMgr:getPlayerFortInfo(i);
		Audio:preloadEffect(playerFortInfo.fort_id, "res/music/bullet_" .. playerFortInfo.fort_id .. ".mp3");
		Audio:preloadEffect(playerFortInfo.skillID, "res/music/skill_" .. playerFortInfo.skillID .. ".mp3");
	end
	if self.m_battleType ~= 3 then
		for i = 1, 3 do
			local enemyFortInfo = BattleDataMgr:getEnemyFortInfo(i);
			Audio:preloadEffect(enemyFortInfo.fort_id, "res/music/bullet_" .. enemyFortInfo.fort_id .. ".mp3");
			Audio:preloadEffect(enemyFortInfo.skillID, "res/music/skill_" .. enemyFortInfo.skillID .. ".mp3");
		end
		local enemyInfo = BattleDataMgr:getCurEnemyInfo();
		Audio:preloadEffect(enemyInfo.skin, "res/music/ship_" .. enemyInfo.skin .. ".mp3");
	end
	local playerInfo = BattleDataMgr:getCurPlayerInfo();
	Audio:preloadEffect(playerInfo.skin, "res/music/ship_" .. playerInfo.skin .. ".mp3");
	print("   加载战斗音乐完毕 的 time ", os.time());
end

--战斗准备阶段，可以预先加载子弹、能量体、NPC等资源
function CCBBattle:ready()
	print( " @@@@@@@@ ccbBattle  :ready ")

end

--战斗开始，双方开始发射子弹
function CCBBattle:startBattle()
	print("CCBBattle:startBattle")

	self.m_isTouch = true;

	newBattle.start(); -- 外部库战斗开始
	self:startScheduler();
	self.m_isBattleBegin = true;
end

--显示战斗结果
function CCBBattle:showResult(data)
	-- dump(data)
	-- Draw
	-- "<var>" = {
	--     "code"    = 1
	--     "is_uid1" = false
	--     "timeout" = 5
	-- }
	-- Win
	-- "<var>" = {
	--     "code"    = 1
	--     "is_uid1" = false
	--     "timeout" = 5
	--     "winner"  = "cfcde2685ab8c07460f95c279ea39788"
	-- }
	if self.m_battleType ~= 3 then
		self:stopScheduler();
		self.m_ccbNodeBtn:setVisible(false);
		self.m_resultData = data;
		self.m_showResult = CCBShowResult:create();
		self.m_showResult:setPosition(cc.p(-display.width * 0.5, -display.height * 0.5));
		self.m_ccbNodeResult:addChild(self.m_showResult);

		local playerUID = cc.UserDefault:getInstance():getStringForKey("uid")
		if data.winner == nil then
			-- self:showDraw(data);
			Audio:playEffect(104, false);
			self.m_showResult:setData(3);
		else
			if data.winner == playerUID then
				-- self:showResult(data);
				Audio:playEffect(103, false);
				ShipMgr:showWin();
				self.m_showResult:setData(1);
			else
				-- self:showLose(data);
				Audio:playEffect(104, false);
				ShipMgr:showLose();
				self.m_showResult:setData(2);
			end	
		end
	elseif self.m_battleType == 3 then
		-- self:bossShowResult(data);
	end
end

--我方胜利，对面炮台要摧毁，然后显示战舰损毁动画并消失
function CCBBattle:showWin(data)
	-- dump(data)
	-- "<var>" = {
	--     "battle_id" = "bat_5a97a4d0e17aec532f5cbbc5"
	--     "code"      = 1
	--     "is_uid1"   = false
	--     "timeout"   = 5
	--     "winner"    = "cfcde2685a97a4c9eec7bec48e5324af"
	-- }
	print("@win")
	self:stopScheduler();
	self.m_ccbNodeBtn:setVisible(false);
	self.m_resultData = data;
	ShipMgr:showWin();
	--self.m_armatureShip:getAnimation():play("destroy02");
	-- for i = 4, 6 do
		-- self.m_armatureForts[i]:setVisible(false);
		-- self.m_fortStates[i]:setVisible(false);
		-- if self.m_armatureFortDestroys[i] then
		-- 	self.m_armatureFortDestroys[i]:setVisible(false);
		-- end
	-- end
	Audio:playEffect(103, false);
	if data ~= nil then
		self.m_showWin = CCBShowWin:create();
		self.m_showWin:setPosition(cc.p(-display.width * 0.5, -display.height * 0.5));
		self.m_ccbNodeResult:addChild(self.m_showWin);
		self.m_showWin:setData();
	end
end

--我方失败，我方炮台损毁消失，我方战舰播放损毁并消失
function CCBBattle:showLose(data)
	print("@lose");
	self:stopScheduler();
	self.m_ccbNodeBtn:setVisible(false);
	self.m_resultData = data;
	ShipMgr:showLose();
	-- self.m_armatureShip:getAnimation():play("destroy01");
	-- for i = 1, 3 do
		-- self.m_armatureForts[i]:setVisible(false);
		-- self.m_fortStates[i]:setVisible(false);
		-- if self.m_armatureFortDestroys[i] then 
		-- 	self.m_armatureFortDestroys[i]:setVisible(false);
		-- end
	-- end
	Audio:playEffect(104, false);
	if data ~= nil then
		self.m_showLose = CCBShowLose:create();
		self.m_showLose:setPosition(cc.p(-display.width * 0.5, -display.height * 0.5));
		self.m_ccbNodeResult:addChild(self.m_showLose);
		self.m_showLose:setData(data);
	end
end

--平局，则直接显示平局结算画面
function CCBBattle:showDraw(data)
	print("@draw");
	Audio:playEffect(104, false);
	self:stopScheduler();
	self.m_ccbNodeBtn:setVisible(false);
	self.m_showDraw = CCBShowDraw:create();
	self.m_showDraw:setPosition(cc.p(-display.width * 0.5, -display.height * 0.5));
	self.m_ccbNodeResult:addChild(self.m_showDraw);
	self.m_showDraw:setData(data);
end

-- boss战, 显示战斗结果
function CCBBattle:bossShowResult(data)
	print("boss战, 显示战斗结果");
	-- dump(data.recoup);

	self:stopScheduler();
	self.m_ccbNodeBtn:setVisible(false);
	-- local touchNode = cc.Node:create();
	local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 255 * 0.60), display.width, display.height)
	layerColor:setAnchorPoint(cc.p(0.5, 0.5));
	layerColor:setPosition(cc.p(-display.width * 0.5, -display.height * 0.5));
	self.m_ccbNodeResult:addChild(layerColor);
	local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return true  end, cc.Handler.EVENT_TOUCH_BEGAN );
    local eventDispatcher = layerColor:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layerColor);

	self.m_bossClearArmature = BattleResourceMgr:createBattleArmature("boss_clear1");
	self.m_ccbNodeResult:addChild(self.m_bossClearArmature);
	self.m_bossClearArmature:setPosition(cc.p(0, 50));
	self.m_bossClearArmature:getAnimation():play("count_equip");

	local animState = 0;

	local itemNode = cc.Node:create();
	self.m_ccbNodeResult:addChild(itemNode);

	local btnNode = cc.Node:create();
	btnNode:setPosition(0, -display.height * 0.5 + 75);
	self.m_ccbNodeResult:addChild(btnNode);
	btnNode:setCascadeOpacityEnabled(true);
	btnNode:setOpacity(0);

	local ensureBtn = ccui.Button:create(ResourceMgr:getGreenBtnNormal(), ResourceMgr:getGreenBtnHigh(), ResourceMgr:getGreenBtnNormal());
	ensureBtn:setAnchorPoint(cc.p(0.5, 0.5));
	ensureBtn:addClickEventListener(function()
		if animState == 1 then
			Audio:stopMusic();
			App:enterScene("DomainScene");
		else
			animState = 1;
			ensureBtn:setEnabled(false);
			local fadeOutAction = cc.FadeOut:create(0.3);
			local callBack = cc.CallFunc:create(function()
				itemNode:removeAllChildren();
				self.m_bossClearArmature:getAnimation():play("count_hurt");
			end);
			local sequenceAction = cc.Sequence:create(fadeOutAction, callBack);
			btnNode:runAction(sequenceAction);
		end
	end)
	ensureBtn:setTitleText("");
	btnNode:addChild(ensureBtn);
	ensureBtn:setEnabled(false);

	local btnEnsureTitle = cc.Sprite:create(ResourceMgr:getBtnEnsureTitleSprite());
	btnNode:addChild(btnEnsureTitle);


	self.m_bossClearArmature:getAnimation():setFrameEventCallFunc(function (bone, evt, originFrameIndex, currentFrameIndex)
		if evt == "show1" then
			local number1 = cc.LabelTTF:create(data.damage_info.damage, "", 30);--res/font/simhei.fft
			number1:setAnchorPoint(cc.p(0, 0.5));
			self.m_bossClearArmature:getBone("word1"):addDisplay(number1, 0);
			self.m_bossClearArmature:getBone("word1"):changeDisplayWithIndex(0, true);
		elseif evt == "show2" then
			local number2 = cc.LabelTTF:create(data.damage_info.all_damage, "", 30);
			number2:setAnchorPoint(cc.p(0, 0.5));
			self.m_bossClearArmature:getBone("word2"):addDisplay(number2, 0);
			self.m_bossClearArmature:getBone("word2"):changeDisplayWithIndex(0, true);
		elseif evt == "show3" then
			local number3 = cc.LabelTTF:create(data.damage_info.rank, "", 30);
			number3:setAnchorPoint(cc.p(0, 0.5));
			self.m_bossClearArmature:getBone("word3"):addDisplay(number3, 0);
			self.m_bossClearArmature:getBone("word3"):changeDisplayWithIndex(0, true);
		elseif evt == "rank_number" then
			local rank = data.damage_info.old_rank - data.damage_info.rank;
			if rank ~= 0 and data.damage_info.old_rank ~= 0 then
				local number4 = nil;
				if rank < 0 then
					number4 = cc.LabelBMFont:create(rank, "res/font/number_red.fnt");
				else
					number4 = cc.LabelBMFont:create("+" .. rank, "res/font/number_green.fnt");
				end
				number4:setAnchorPoint(cc.p(0, 0.5));

				self.m_bossClearArmature:getBone("rank_number"):addDisplay(number4, 0);
				self.m_bossClearArmature:getBone("rank_number"):changeDisplayWithIndex(0, true);
			end
		end
	end)
	self.m_bossClearArmature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			if movementID == "count_equip" then
				-- 显示获得物品。
				local movePosX = (#data.recoup - 1) * 135 * 0.5;
				for i = 1, #data.recoup do
					if data.recoup[i].item_id <= 10000 then
						local icon = BattleResourceMgr:getItemWithFrameAndCount(data.recoup[i].item_id, data.recoup[i].count);
						icon:setPositionX((i - 1) * 135 - movePosX);
						itemNode:addChild(icon);
					else
						local icon = BattleResourceMgr:getItemWithFrameAndCount(data.recoup[i].item_id, data.recoup[i].count);
						icon:setPositionX((i - 1) * 135 - movePosX);
						itemNode:addChild(icon);
					end
				end
				-- 显示按钮
				local fadeInAction = cc.FadeIn:create(0.3);
				local callBack = cc.CallFunc:create(function()
					ensureBtn:setEnabled(true);
				end)
				local sequenceAction = cc.Sequence:create(fadeInAction, callBack);
				btnNode:runAction(sequenceAction);
			elseif movementID == "count_hurt" then
				local fadeInAction = cc.FadeIn:create(0.3);
				local callBack = cc.CallFunc:create(function()
					ensureBtn:setEnabled(true);
				end)
				local sequenceAction = cc.Sequence:create(fadeInAction, callBack);
				btnNode:runAction(sequenceAction);
			end
		end
	end)
	if display.resolution >= 2 then
		self.m_bossClearArmature:setScale(display.reduce);
		itemNode:setScale(display.reduce);
		btnNode:setScale(display.reduce);
	end
end

----------------护送------------------------
--护送战斗胜利
function CCBBattle:showEscortBattleWin()
	self:stopScheduler();
	self.m_ccbNodeBtn:setVisible(false);
	self.m_showEscortResult = CCBEscortResult:create();
	self.m_showEscortWin:setPosition(cc.p(-display.width * 0.5, -display.height * 0.5));
	self.m_ccbNodeResult:addChild(self.m_showEscortWin);
	self.m_showEscortWin:winArmature();
end

--护送战斗失败
function CCBBattle:showEscortBattleLose()
	self:stopScheduler();
	self.m_ccbNodeBtn:setVisible(false);
	self.m_showEscortLose = CCBEscortBattleLose:create();
	self.m_showEscortLose:setPosition(cc.p(-display.width * 0.5, -display.height * 0.5));
	self.m_ccbNodeResult:addChild(self.m_showEscortLose);
	self.m_showEscortLose:loseArmature();
	EscortDataMgr.m_escortExist = false;
end

function CCBBattle:showEscortResult()
	-- dump(self.m_escortResultData);
	local escortResult = nil;
	if self.m_escortResultData then
		if self.m_escortResultData.is_loot then
			if self.m_escortResultData.result == 0 then  -- 打劫失败
				escortResult = CCBEscortResult:create(4);
			elseif self.m_escortResultData.result == 1 then -- 打劫成功
				escortResult = CCBEscortResult:create(3);
			end
		else
			if self.m_escortResultData.result == 1 then  -- 战败
				escortResult = CCBEscortResult:create(2);
				EscortDataMgr.m_escortExist = false;
			elseif self.m_escortResultData.result == 2 then -- 护送成功
				App:enterScene("EscortScene");
				-- escortResult = CCBEscortResult:create(5);
			end
		end
	else
		escortResult = CCBEscortResult:create(5);
	end
	self.m_ccbNodeResult:addChild(escortResult);
	escortResult:setPosition(cc.p(-display.width * 0.5, -display.height * 0.5));
	escortResult:setResultData(self.m_escortResultData);
end

function CCBBattle:setEscortResultData(data)
	dump(data);
	-- "<var>" = {
 --     "award" = {
 --         1 = {
 --             "count"   = 298450
 --             "item_id" = 10001
 --         }
 --         2 = {
 --             "count"   = 50
 --             "item_id" = 10002
 --         }
 --     }
 --     "float_items" = {
 --         "count"   = 0
 --         "item_id" = 10001
 --     }
 --     "is_loot"     = false
 --     "result"      = 2
 -- }
	self.m_escortResultData = data;
end

function CCBBattle:getEscortResultData()
	-- dump(self.m_escortResultData);
	return self.m_escortResultData;
end

---------------------------------------------

function CCBBattle:battleUpdateForSynchronization(data) 
	-- print(" 战斗数据同步 " );
	newBattle.synchordataBattle(data.data);
end

function CCBBattle:setEffectStop()
	-- Audio:stopEffect(self.m_shipFlyEffect);
end

function CCBBattle:setBottomBtnUse()
	self.m_ccbFileBottom:setButtonUse();
end

function CCBBattle:setBottomBtnUnuse()
	self.m_ccbFileBottom:setButtonUnuse();
end

function CCBBattle:shakeAction()
	local moveByRight1 = cc.MoveBy:create(0.05, cc.p(5, 0));
	local moveByLeft1 = cc.MoveBy:create(0.05, cc.p(-5, 0));
	local moveByUp1 = cc.MoveBy:create(0.05, cc.p(0, 5));
	local moveByDown1 = cc.MoveBy:create(0.05, cc.p(0, -5));
	local sequence1 = cc.Sequence:create(moveByRight1, moveByLeft1, moveByUp1, moveByDown1, moveByLeft1, moveByRight1, moveByDown1, moveByUp1);
	local repAction1 = cc.RepeatForever:create(sequence1);
	-- repAction1:retain();
	self.m_ccbNodeBackground:runAction(repAction1);

	local moveByRight1 = cc.MoveBy:create(0.05, cc.p(5, 0));
	local moveByLeft1 = cc.MoveBy:create(0.05, cc.p(-5, 0));
	local moveByUp1 = cc.MoveBy:create(0.05, cc.p(0, 5));
	local moveByDown1 = cc.MoveBy:create(0.05, cc.p(0, -5));
	local sequence1 = cc.Sequence:create(moveByRight1, moveByLeft1, moveByUp1, moveByDown1, moveByLeft1, moveByRight1, moveByDown1, moveByUp1);
	local repAction1 = cc.RepeatForever:create(sequence1);
	self.m_ccbNodeShip:runAction(repAction1);

	local moveByRight1 = cc.MoveBy:create(0.05, cc.p(5, 0));
	local moveByLeft1 = cc.MoveBy:create(0.05, cc.p(-5, 0));
	local moveByUp1 = cc.MoveBy:create(0.05, cc.p(0, 5));
	local moveByDown1 = cc.MoveBy:create(0.05, cc.p(0, -5));
	local sequence1 = cc.Sequence:create(moveByRight1, moveByLeft1, moveByUp1, moveByDown1, moveByLeft1, moveByRight1, moveByDown1, moveByUp1);
	local repAction1 = cc.RepeatForever:create(sequence1);
	self.m_ccbNodeCloud:runAction(repAction1);
end

function CCBBattle:stopShakeAction()
	self.m_ccbNodeBackground:stopAllActions();
	self.m_ccbNodeBackground:setPosition(display.center);

	self.m_ccbNodeShip:stopAllActions();
	self.m_ccbNodeShip:setPosition(display.center);

	self.m_ccbNodeCloud:stopAllActions();
	self.m_ccbNodeCloud:setPosition(display.center);
end

function CCBBattle:rankAddView(famous)
	local rankAddView = RankUpView:create(famous);
	self.m_ccbNodeResult:addChild(rankAddView);
end

function CCBBattle:addBuffOfBossUnBuff()
	local buffWord = BuffWordTips:create(17);
	buffWord:setPosition(FORTS_POSITION[5].x - 50, FORTS_POSITION[5].y);
	self.m_ccbNodeCloud:addChild(buffWord);
end

return CCBBattle