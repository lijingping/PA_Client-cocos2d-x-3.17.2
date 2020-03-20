local ResourceMgr = require("app.utils.ResourceMgr");
local BattleResourceMgr = require("app.utils.BattleResourceMgr")
local UIDrag = require("app.utils.UIDrag");
local Tips = require("app.views.common.Tips");

local constants_battle = require("app.constants.battle")
local constants_arms = require("app.constants.arms")

local testScrow = class("testScrow", function()
	return CCBLoader("ccbi/loginView/testScrow.ccbi")
end)

local layer1MoveDis = 0;
local layer2MoveDis = 50;
local layer3MoveDis = 50;
local layer4MoveDis = 500;
local layer5MoveDis = 400;
local layer6MoveDis = 900;
local layer7MoveDis = 960;
local layer8MoveDis = 600;
local layer9MoveDis = 1100;
local layer10MoveDis = 1720;

local MAX_ARMS = 6;
local MAX_ARMS_ICON_RES = 6
local MAX_SCIENCE = 3;
local MAX_LEVEL = 3;
local PLANE_ANIM_HALF_SIZE = 39;
local MAP_POINT_ADJUST = 6;

local VIEW_WIDTH = layer10MoveDis+display.width;
local SELF_SHIP_POS_X = 250; --左战舰x坐标
local SHIP_POS_Y = 200;      --战舰y坐标
local HOST_SHIP_POS_X = VIEW_WIDTH - SELF_SHIP_POS_X;--右战舰x坐标

--Zorder：子弹和战机默认0，HP在所有战机之上，受击爆炸动画最上层
local HP_ZOrder = 1000;
local PRODUCE_ZOrder = 2000;
local BE_ATTACK_EXPLOSION_ZOrder = 3000;

local SELF_PLANE_START_TAG = 0;
local HOST_PLANE_START_TAG = 1000;

local SELF_HP_NODE_START_TAG = 2000;
local HOST_HP_NODE_START_TAG = 3000;

local SELF_PRODUCE_START_TAG = 4000;
local HOST_PRODUCE_START_TAG = 5000;

local SELF_BULLET_START_TAG = 6000;
local HOST_BULLET_START_TAG = 7000;

local SELF_BE_ATTACK_EXPLOSION_TAG = 8000;
local HOST_BE_ATTACK_EXPLOSION_TAG = 9000;

local SELF_HP_START_TAG = 10000;
local HOST_HP_START_TAG = 11000;

local SELF_MAP_POINT_START_TAG = 1000;
local HOST_MAP_POINT_START_TAG = 2000;

local math_abs = math.abs;
local math_deg = math.deg;
local math_random = math.random;
local table_remove = table.remove;

local FORT_BORN = 1;-- 完成生产
local FORT_TURN_BODY = 2;-- 旋转机体 （旋转度数）
local FORT_ATTACK_READY = 3;-- 攻击准备
local FORT_FIRE_EVENT = 4;-- 攻击发动
local FORT_SKILL_ON = 5;-- 技能开
local FORT_SKILL_OFF = 6;-- 技能完
local FORT_BE_DAMAGE = 7;-- 被攻击  （扣除的血量）
local FORT_ADD_ATK = 8;-- 攻击加强
local FORT_ADD_HP = 9;-- 血量增加 （增加的血量）
local FORT_ADD_ENERGY = 10;-- 能量增加 （增加的能量）
local FORT_DIE = 11;-- 死亡
--子弹
local BULLET_BORN = 1;-- 子弹创建
local BULLET_BOMB = 2;-- 子弹爆炸
local BULLET_REMOVE = 3;--移除子弹；目标战机死亡，子弹在飞
--玩家类型
local SELF = 1;
local ENEMY = 2;

function testScrow:ctor()
	print("testScrow:ctor()");
	self:enableNodeEvents();

	self.m_touchHolder = 0;
	self.m_autoMoveView = 0;
	self.m_planeStartPosY = self.m_ccbNodeLayer10:getPositionY();

	self:createTouchEvent();

	self.m_topUISize = self.m_ccbNodeSliderBack:getContentSize();
	self.m_mapPointSize = cc.size(self.m_topUISize.width-MAP_POINT_ADJUST*2, self.m_topUISize.height-MAP_POINT_ADJUST*2);

	self.m_sliderNodeSize = self.m_ccbScale9SpriteSlider:getContentSize();
	self.m_sliderNodeSize.width = self.m_topUISize.width * (display.width/VIEW_WIDTH);
	self.m_ccbScale9SpriteSlider:setContentSize(self.m_sliderNodeSize)
	self.m_ccbScale9SpriteSlider.copyPosX = self.m_ccbScale9SpriteSlider:getPositionX();

    self.m_playerShipBar = self:createHPBar(self.m_ccbNodeLayer10, cc.size(154, 12)
    	, cc.p(SELF_SHIP_POS_X, SHIP_POS_Y+120), true, true).bar;

	local playerShip = ResourceMgr:getDemoArmature("ship1_1")
		:setAnchorPoint(cc.p(0.5, 0.5))
		:setPosition(cc.p(SELF_SHIP_POS_X, SHIP_POS_Y))
		:addTo(self.m_ccbNodeLayer10);
	playerShip:getAnimation():play("idle");

    self.m_enemyShipBar = self:createHPBar(self.m_ccbNodeLayer10, cc.size(154, 12)
    	, cc.p(HOST_SHIP_POS_X, SHIP_POS_Y+120), true, true).bar;

	local enemyShip = ResourceMgr:getDemoArmature("ship1_1")
		:setAnchorPoint(cc.p(0.5, 0.5))
		:setPosition(cc.p(HOST_SHIP_POS_X, SHIP_POS_Y))
		:setRotation(180)
		:addTo(self.m_ccbNodeLayer10);
	enemyShip:getAnimation():play("idle");

	local action1 = cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(-5, 0)), cc.MoveBy:create(0.5, cc.p(5, 0))));
    self.m_ccbBtnLeft:runAction(action1);
    local action2 = cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(5, 0)), cc.MoveBy:create(0.5, cc.p(-5, 0))));
    self.m_ccbBtnRight:runAction(action2);

	self:setArrowVisible(0);

    self.m_energyBar = ccui.Slider:create()
    	:setScale9Enabled(true)
    	:setTouchEnabled(false)
    	:setContentSize(cc.size(94, 30))
    	:loadProgressBarTexture(ResourceMgr:getDemoEnergySliderBar())
    	:loadSlidBallTextures(ResourceMgr:getDemoEnergySliderBall()
    	, ResourceMgr:getDemoEnergySliderBall(), ResourceMgr:getDemoEnergySliderBall())
    	:setCapInsets(cc.rect(18, 0, 18, 0))
    self.m_ccbNodeEnergyBar:addChild(self.m_energyBar);

    local itemId = {1104, 1007, 1013};
    for i=1,MAX_SCIENCE do
    	self["m_ccbNodeScience"..i]:getChildByTag(3):setString(152);
    	cc.Sprite:create(ResourceMgr:getItemIconByID(itemId[i]))
    		:setTag(4)
    		:addTo(self["m_ccbNodeScience"..i])
    end

    self.m_armsData = {
    	[1]={id="101",level=1},
    	[2]={id="102",level=2},
    	[3]={id="103",level=3},
    	[4]={id="104",level=1},
    	[5]={id="105",level=2},
    	[6]={id="106",level=3}
    };

    self:initDrag();
    self:loadDrag();

    self.m_planeData = {};
    self.m_mapPointData = {};
end

function testScrow:onEnter()
	Battle.enterBattle(1);
	Battle.setJsonDataPath("src/app/constants/arms.lua", "src/app/constants/warship.lua");
	Battle.setPlayerData(1001, 1, 1001, 1);

	Battle.startBattle();
	self.m_isPause = false;

	self:openScheduler();

    self.m_ccbLabelPlayerTopName:setString("超超能陆战队" or UserDataMgr:getPlayerName());
	self.m_ccbNodePlayerRankIcon:addChild(self:getRankIcon(100 or UserDataMgr:getPlayerFamous()));

	--待接服务器
    self.m_ccbLabelEnemyTopName:setString("小小超能");
	self.m_ccbNodeEnemyRankIcon:addChild(self:getRankIcon(200));

	self:updateUI();

	Battle.fortEventHandler(function(nSide,nEventID,nFortID,nFortIndex,dEventNumber,dReserveNumber)
		if nEventID == FORT_DIE then
		    self:removePlaneChild(nFortIndex+(nSide==SELF and SELF_PLANE_START_TAG or HOST_PLANE_START_TAG));
			self:removePlaneChild(nFortIndex+(nSide==SELF and SELF_HP_NODE_START_TAG or HOST_HP_NODE_START_TAG));

		    self:removeMapPointChild(nFortIndex+(nSide==SELF and SELF_MAP_POINT_START_TAG or HOST_MAP_POINT_START_TAG));
	    elseif nEventID == FORT_FIRE_EVENT then
	    	self.m_planeData[nFortIndex+(nSide==SELF and SELF_PLANE_START_TAG or HOST_PLANE_START_TAG)]:getAnimation():play("shoot");
	    elseif nEventID == FORT_BE_DAMAGE then--只有战机受到伤害
	    	self.m_planeData[nFortIndex+(nSide==SELF and SELF_PLANE_START_TAG or HOST_PLANE_START_TAG)]:getAnimation():play("hit");
		end
	end)

	Battle.bulletEventHandler(function(nSide,nEventID,nBulletID,nBulletIndex,dEventNumber)
		if nEventID == BULLET_BORN then
	    elseif nEventID == BULLET_BOMB or nEventID == BULLET_REMOVE then
	    	local index = nBulletIndex+(nSide==SELF and SELF_BULLET_START_TAG or HOST_BULLET_START_TAG)
	    	local bullet = self.m_planeData[index];
	    	if bullet ~= nil then
	    		if nEventID == BULLET_BOMB then----只有子弹碰到战舰和战机才有爆炸
		    		self:createBeAttackExplosion(cc.p(bullet:getPositionX(),bullet:getPositionY()), nBulletIndex);
		    	end
		    	self:removePlaneChild(index);
	    	end
		end
	end)

	if self.m_playerCount then
		for i=1,self.m_playerCount do
			local randArmsId = 10 .. math_random(1, MAX_ARMS_ICON_RES);
			Battle.createPlayerFort(randArmsId,math_random(1,MAX_LEVEL),math_random(0,SHIP_POS_Y*2),constants_arms[randArmsId].cost);
		end
	end
	if self.m_enemyCount then
		for i=1,self.m_enemyCount do
			self:onBtnCreateEnemyPlane();
		end
	end
end

function testScrow:onExit()
	self:unscheduleUpdate();
end

function testScrow:setArmsCount(playerCount, enemyCount)
	self.m_playerCount = playerCount;
	self.m_enemyCount = enemyCount;
end

function testScrow:removePlaneChild(index)
	self.m_ccbNodeLayer10:removeChild(self.m_planeData[index]);
	self.m_planeData[index] = nil;
end

function testScrow:removeMapPointChild(index)
	self.m_ccbNodeSliderBack:removeChild(self.m_mapPointData[index]);
	self.m_mapPointData[index] = nil;
end

function testScrow:createBeAttackExplosion(pos, nIndex)
	local explosionTag = nIndex+(nSide==SELF and SELF_BE_ATTACK_EXPLOSION_TAG or HOST_BE_ATTACK_EXPLOSION_TAG);
	local explosion = self.m_ccbNodeLayer10:getChildByTag(explosionTag);
	if explosion == nil then
    	explosion = ResourceMgr:getDemoArmature("explosion")
    		:setTag(explosionTag)
    		:addTo(self.m_ccbNodeLayer10, BE_ATTACK_EXPLOSION_ZOrder);
    end
    explosion:setPosition(pos)
    	:setVisible(true);
    explosion:getAnimation():play("anim1");
	explosion:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			if movementID == "anim1" then
				--explosion:setVisible(false);
				explosion:removeSelf();
			end
		end
	end)
end

function testScrow:unscheduleUpdate()
	if self.m_schedulerUpdate then
		self:getScheduler():unscheduleScriptEntry(self.m_schedulerUpdate);
		self.m_schedulerUpdate = nil;
	end
end

function testScrow:openScheduler()
	self:unscheduleUpdate();

	self.m_schedulerUpdate = self:getScheduler():scheduleScriptFunc(function(delta)
		Battle.update(delta);

    	self:updateUI();
    	self:updateFort();
    	self.m_ccbLabelTime:setString(self:showTimeFormat(constants_battle.max_time - Battle.getBattleTime().time));

		if self.m_autoMoveView ~= 0 then
			self:moveView(self.m_autoMoveView);
		end
	end, 0, false);
end

function testScrow:setFortData(data,planeStartTag,hpStartTag,hpNodeStartTag,produceStartTag,mapPointStartTag,isEnemy)
	local plane = self.m_planeData[data.fortIndex+planeStartTag];
	if plane == nil then
    	plane = ResourceMgr:getDemoArmature("pvp_plane".. data.id%MAX_ARMS_ICON_RES+1)
    		:addTo(self.m_ccbNodeLayer10);
    	plane:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				if movementID == "shoot" or movementID == "hit" then
					plane:getAnimation():play("idle");
				end
			end

		end)
		self.m_planeData[data.fortIndex+planeStartTag] = plane;
	end
	plane:setPosition(cc.p(data.x, data.y))
		:setRotation(math_deg(data.radian));

	if data.bornTime > 0 then
		local produce = self.m_planeData[data.fortIndex+produceStartTag];
		if produce == nil then
			produce = self:createProduceBar(self.m_ccbNodeLayer10, cc.p(data.x+PLANE_ANIM_HALF_SIZE, data.y+PLANE_ANIM_HALF_SIZE))
			self.m_planeData[data.fortIndex+produceStartTag] = produce;
		end
		produce:setPosition(cc.p(data.x+PLANE_ANIM_HALF_SIZE, data.y+PLANE_ANIM_HALF_SIZE))
		produce.bar:setPercentage((data.bornTime/constants_arms["".. data.id].production_time)*100);
	else	
		local hp = self.m_planeData[data.fortIndex+hpNodeStartTag];
		if hp == nil then
			self:removePlaneChild(data.fortIndex+produceStartTag);
	
		    hp = self:createHPBar(self.m_ccbNodeLayer10
		    	, cc.size(52, 12), cc.p(data.x, data.y+PLANE_ANIM_HALF_SIZE))

		    hp.level = cc.Sprite:create(ResourceMgr:getDemoIconLevel(1))
		    	:setAnchorPoint(cc.p(1, 0.5))
		    	:setPositionX(-12)
		    	:setScale(0.5)
		    hp.level:addTo(hp);
		    self.m_planeData[data.fortIndex+hpNodeStartTag] = hp;
		    self.m_planeData[data.fortIndex+hpNodeStartTag].bar = hp.bar;
		    --self.m_planeData[data.fortIndex+hpStartTag] = hp.bar;
		end
		
		hp:setPosition(cc.p(data.x, data.y + PLANE_ANIM_HALF_SIZE));
		if hp.bar and hp.bar.setPercent then
			hp.bar:setPercent((data.hp/data.maxHp)*100);
		end
		--hp.level:setTexture(ResourceMgr:getDemoIconLevel(1))
	end

	self:updateShortMapPoint(data.fortIndex+mapPointStartTag,cc.p(data.x, data.y+self.m_planeStartPosY), isEnemy);
end

function testScrow:setBulletData(data,bulletStartTag,isEnemy)
	local bullet = self.m_planeData[data.index+bulletStartTag];
	if bullet == nil then
		bullet = cc.Sprite:create(BattleResourceMgr:getBulletSprite(data.id%100+90001, not isEnemy))
			:addTo(self.m_ccbNodeLayer10);
		self.m_planeData[data.index+bulletStartTag] = bullet;
	end
	bullet:setPosition(cc.p(data.x, data.y))
		:setRotation(math_deg(data.radian));
end

function testScrow:updateFort()
	local selfFortData = Battle.getSelfFortData();
    for i=1,#selfFortData do
    	self:setFortData(selfFortData[i],SELF_PLANE_START_TAG
    		,SELF_HP_START_TAG,SELF_HP_NODE_START_TAG
    		,SELF_PRODUCE_START_TAG,SELF_MAP_POINT_START_TAG);
    end

	local hostFortData = Battle.getHostFortData();
    for i=1,#hostFortData do
    	self:setFortData(hostFortData[i],HOST_PLANE_START_TAG
    		,HOST_HP_START_TAG,HOST_HP_NODE_START_TAG
    		,HOST_PRODUCE_START_TAG,HOST_MAP_POINT_START_TAG,true);
    end

	local selfBulletData = Battle.getSelfBulletData();
    for i=1,#selfBulletData do
    	self:setBulletData(selfBulletData[i],SELF_BULLET_START_TAG);
    end

	local hostBulletData = Battle.getHostBulletData();
    for i=1,#hostBulletData do
    	self:setBulletData(hostBulletData[i],HOST_BULLET_START_TAG,true);
    end
end

function testScrow:updateUI()
	local playerSelfData = Battle.getPlayerSelfData()
    self.m_ccbLabelEnergy:setString(playerSelfData.playerEnergy .."/".. constants_battle.max_energy);
    self.m_energyBar:setPercent((playerSelfData.playerEnergy/constants_battle.max_energy)*100);
    self.m_ccbLabelPlayerForces:setString(playerSelfData.playerArmy .."/".. constants_battle.max_army);

    self.m_ccbLabelEnemyForces:setString(Battle.getPlayerHostData().playerArmy .."/".. constants_battle.max_army);

	local selfShipData = Battle.getSelfShipData();
	self.m_playerShipBar:setPercent((selfShipData.hp/selfShipData.maxHp)*100);
	local hostShipData = Battle.getHostShipData();
    self.m_enemyShipBar:setPercent((hostShipData.hp/hostShipData.maxHp)*100);
end

function testScrow:showTimeFormat(time)
	local minute = math.floor((time % 3600) / 60);
	local second = time % 60;
	return string.format("%02d:%02d", minute, second);	
end

function testScrow:createHPBar(parent, size, pos, isScale9Bg,isScale9HP)
	size = size or cc.size(154, 12);

	local node = cc.Node:create()
		:setPosition(pos)
		:addTo(parent, HP_ZOrder);

	if isScale9Bg then
		ccui.Scale9Sprite:create(ResourceMgr:getDemoHPBarBack())
			:setCapInsets(cc.rect(5, 5, 42, 2))
			:setContentSize(size)
			:addTo(node);
	else
		cc.Sprite:create(ResourceMgr:getDemoHPBarBack())
			:addTo(node);
	end

    node.bar = ccui.Slider:create()
    	:setScale9Enabled(isScale9HP)
    	:setTouchEnabled(false)
    	:setContentSize(size)
  		:loadBarTexture(ResourceMgr:getDemoHPBar())
    	:loadProgressBarTexture(ResourceMgr:getDemoHPProgressBar())
    	--:loadSlidBallTextures(ResourceMgr:getDemoEnergySliderBall()
    	--	, ResourceMgr:getDemoEnergySliderBall(), ResourceMgr:getDemoEnergySliderBall())
    	--:setPercent(100)
    	:setCapInsets(cc.rect(18, 0, 18, 0))
    	:addTo(node);
    return node;
end

function testScrow:createProduceBar(parent, pos)
	local node = cc.Node:create()
		:setPosition(pos)
		:addTo(parent, PRODUCE_ZOrder);

	cc.Sprite:create(ResourceMgr:getDemoProduceBarBack())
		:addTo(node);

    local bar = cc.ProgressTimer:create(cc.Sprite:create(ResourceMgr:getDemoProduceBar()))
    	:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    	--:setPercentage(0)
    	--:setReverseProgress(true)
    	--:setReverseDirection(true)
    	:addTo(node);
    node.bar = bar;

    return node;
end

function testScrow:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:registerScriptHandler(function(touch, event)
		return self:touchBegin(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(function(touch, event)
		return self:touchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED);
	listener:registerScriptHandler(function( touch, event )
		return self:touchEnded(touch, event);
	end, cc.Handler.EVENT_TOUCH_ENDED);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbNodeTouch);
end
--获得军衔图标
function testScrow:getRankIcon(famousNum)
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

function testScrow:touchBegin(touch, event)
	print("touch begin");
	self.m_touchBeginPos = touch:getLocation();
	local nodePos = self.m_ccbNodeTopUI:convertToNodeSpace(self.m_touchBeginPos);
	if cc.rectContainsPoint(self.m_ccbScale9SpriteSlider:getBoundingBox(), nodePos) then
		self.m_touchHolder = 1;
	elseif cc.rectContainsPoint(self.m_ccbNodeTouchView:getBoundingBox(), self.m_touchBeginPos) then
		self.m_touchHolder = 2;
	end
	return true;
end

function testScrow:touchMoved(touch, event)
	self.m_touchMovePos = touch:getLocation();
	if self.m_touchHolder == 1 then
		local nodePos = self.m_ccbNodeTopUI:convertToNodeSpace(self.m_touchMovePos);
		if self.m_previousPos then
			self:moveSlider(self.m_touchMovePos.x - self.m_previousPos.x);
		end
	elseif self.m_touchHolder == 2 then
		if self.m_previousPos then
			self:moveView(self.m_touchMovePos.x - self.m_previousPos.x);
		end
	end

	self.m_previousPos = self.m_touchMovePos;
end

function testScrow:touchEnded(touch, event)
	self.m_touchHolder = 0;
	self.m_previousPos = nil;
end

function testScrow:randomArms()
	local rand = math_random(1, MAX_ARMS_ICON_RES);
	table.insert(self.m_armsData, {id="10"..rand,level=rand%MAX_LEVEL+1});
end

function testScrow:armsUpgrade()
	local armsUpgradeLimit = 3;
	if (#self.m_armsData-1) < armsUpgradeLimit then return end

	local tmpArms = {id=self.m_armsData[1].id, level=self.m_armsData[1].level};
	local count = 1;
	local index = -1;
	for i=2,#self.m_armsData-1 do
		local data = self.m_armsData[i];
		if data.id == tmpArms.id
		and data.level <= MAX_LEVEL
		and data.level == tmpArms.level then
			count = count + 1;
			if count >= armsUpgradeLimit then
				index = i - 2;
				break;
			end
		else
			tmpArms = {id=data.id, level=data.level};
			count = 1;
		end
	end

	if index > 0 then
		self.m_armsData[index].level = self.m_armsData[index].level + 1;
		Tips:create("demo版，模拟服务器三张同样的排在一起等级，ID:%s升到%d级", self.m_armsData[index].id, self.m_armsData[index].level);
		
		table_remove(self.m_armsData, index+1);
		table_remove(self.m_armsData, index+2);
		for i=1,armsUpgradeLimit-1 do
    		self:randomArms();
		end
	end
end

function testScrow:initDrag()
	self.m_drag = UIDrag.new()
	self.m_drag:setCurrentDragObjParent(self.m_ccbNodeLayer10)
	self:addChild(self.m_drag, 999)

	self.m_drag:setOnDragMoveBeforeEvent(function(currentItem,point)
		local parent = currentItem.dragBox:getParent();
		local icon = parent:getChildByTag(6);
		if icon then
			icon:setVisible(false);
		end
		local animation = parent:getChildByTag(5);
		if animation then
			animation:setVisible(true);
		end
	end)

	-- 拖拽移动处理
	local movePosX = 25;
	local moveValue = display.width*0.02;
	self.m_drag:setOnDragMoveEvent(function(currentItem,targetItem,point)
		if cc.rectContainsPoint(self.m_ccbNodeTouchView:getBoundingBox(), point) then
			self.m_ccbSpriteGuideBack:setPositionY(point.y)
			self.m_ccbSpriteGuideArrow:setPosition(point.x+PLANE_ANIM_HALF_SIZE, point.y)
			self.m_ccbNodeGuide:setVisible(true)
		else			
			self.m_ccbNodeGuide:setVisible(false)
		end

		if movePosX >= point.x then
			self.m_autoMoveView = moveValue;
		elseif point.x >= (display.width-movePosX) then
			self.m_autoMoveView = -moveValue;
		else
			self.m_autoMoveView = 0;
		end
	end)

	-- 拖拽界限处理
	self.m_drag:setOnDragDownNoneEvent(function(currentItem, targetItem, point)
		if cc.rectContainsPoint(self.m_ccbNodeTouchView:getBoundingBox(), point) then
			return true;
		end

		return false;
	end)

	-- 拖拽放下后
	self.m_drag:setOnDragDownAfterEvent(function(currentItem,targetItem,point)
		if targetItem and targetItem.success then

			local armsId = "".. self.m_armsData[targetItem.index].id;
			Battle.createPlayerFort(armsId,1,point.y-self.m_planeStartPosY,constants_arms[armsId].cost);
			
			table_remove(self.m_armsData, targetItem.index);
			currentItem.dragObj:removeSelf();

			--测试数据
    		self:randomArms();
   			--self:armsUpgrade();

			self:loadDrag();
			--self:updateShortMapPoint(point);
		else
			self.m_drag:resetDragObj();
			if targetItem.index then
				self["m_ccbNodeArms"..targetItem.index]:getChildByTag(5):setVisible(false);
				self["m_ccbNodeArms"..targetItem.index]:getChildByTag(6):setVisible(true);
			end
		end
		self.m_ccbNodeGuide:setVisible(false);
		self.m_autoMoveView = 0;
	end)
end

function testScrow:loadDrag()
	self.m_drag:removeDragAll()

	for i=1,MAX_ARMS do
		local data = self.m_armsData[i];
		local parent = self["m_ccbNodeArms"..i];
		local animation = parent:getChildByTag(5);

		local icon = parent:getChildByTag(6); 
		if data then
	    	if icon == nil then
		    	cc.Sprite:create(ResourceMgr:getDemoPlaneIconById(data.id%MAX_ARMS_ICON_RES+1))
		    		:setTag(6)
		    		:addTo(parent);
	    	else
		    	icon:setTexture(ResourceMgr:getDemoPlaneIconById(data.id%MAX_ARMS_ICON_RES+1))
		    		:setVisible(true);
	    	end

	    	parent:getChildByTag(1):setTexture(ResourceMgr:getDemoIconFrame(data.level));
	    	parent:getChildByTag(2):setTexture(ResourceMgr:getDemoIconLevel(data.level));
	    	parent:getChildByTag(3):setString(data.id);--(constants_arms[data.id].consume);

	    	if animation == nil then
	    		animation = ResourceMgr:getDemoArmature("pvp_plane".. data.id%MAX_ARMS_ICON_RES+1);
    			animation:addTo(parent);
	    		animation.id = data.id;
	    	else
				if animation.id ~= data.id then
					animation:removeSelf();
		    		animation = ResourceMgr:getDemoArmature("pvp_plane".. data.id%MAX_ARMS_ICON_RES+1);
	    			animation:addTo(parent);
		    		animation.id = data.id;
				end
			end
	    	animation:setRotation(90)
	    		:setTag(5)
	    		:setVisible(false);
	    	animation:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
				if movementType == ccs.MovementEventType.complete then
					if movementID == "shoot" or movementID == "hit" then
						animation:getAnimation():play("idle");
					end
				end
			end)

			animation:getAnimation():play("idle");

	    	if i < MAX_ARMS then
	    		parent:getChildByTag(4):setVisible(true);
    			self.m_drag:addDragItem(parent:getChildByTag(1), animation, 1)
    		end
		else
	    	parent:getChildByTag(1):setTexture(ResourceMgr:getDemoIconFrame(1));
	    	parent:getChildByTag(2):setTexture(ResourceMgr:getDemoIconLevel(1));
	    	parent:getChildByTag(3):setString("");
    		icon:setVisible(false);
    		if animation then
				animation:setVisible(false);
			end

	    	if i < MAX_ARMS then
    			parent:getChildByTag(4):setVisible(false);
    		end
		end
    end
--[[
    for i=1,MAX_SCIENCE do
		local icon = self["m_ccbNodeScience"..i]:getChildByTag(5);
		if icon ~= nil then
			self.m_drag:addDragItem(self["m_ccbNodeScience"..i]:getChildByTag(1)
	    		,icon
	    		,2)
		end
    end
]]
end

function testScrow:setArrowVisible(percent)
	if percent <= 0 then
		self.m_ccbBtnLeft:setVisible(false);
		self.m_ccbBtnRight:setVisible(true);
	elseif percent >= 1 then
		self.m_ccbBtnLeft:setVisible(true);
		self.m_ccbBtnRight:setVisible(false);
	else
		self.m_ccbBtnLeft:setVisible(true);
		self.m_ccbBtnRight:setVisible(true);
	end
end

function testScrow:moveSlider(moveDistanceX)
	local changePosX = self.m_ccbScale9SpriteSlider:getPositionX() + moveDistanceX;
	local sliderRightMax = self.m_topUISize.width - self.m_sliderNodeSize.width;
	if changePosX < self.m_ccbScale9SpriteSlider.copyPosX then
		changePosX = self.m_ccbScale9SpriteSlider.copyPosX;
	elseif changePosX > (sliderRightMax+self.m_ccbScale9SpriteSlider.copyPosX) then
		changePosX = (sliderRightMax+self.m_ccbScale9SpriteSlider.copyPosX);
	end
	local percent = (changePosX - self.m_ccbScale9SpriteSlider.copyPosX) / sliderRightMax;
	self:moveSliderByPercent(percent);
	self:moveViewByPercent(percent);
	self:setArrowVisible(percent);
end

function testScrow:moveSliderByPercent(percent)
	local sliderMoveMax = self.m_topUISize.width - self.m_sliderNodeSize.width;
	self.m_ccbScale9SpriteSlider:setPositionX(self.m_ccbScale9SpriteSlider.copyPosX+sliderMoveMax * percent);
end

function testScrow:moveView(moveDistanceX)
	local changePosX = self.m_ccbNodeLayer10:getPositionX() + moveDistanceX;
	if changePosX < -layer10MoveDis then
		changePosX = -layer10MoveDis;
	elseif changePosX > 0 then
		changePosX = 0;
	end

	local percent = math_abs(changePosX / layer10MoveDis);
	self:moveSliderByPercent(percent);
	self:moveViewByPercent(percent);
	self:setArrowVisible(percent);
end

function testScrow:moveViewByPercent(percent)
	self.m_ccbNodeLayer2:setPositionX(-layer2MoveDis * percent);
	self.m_ccbNodeLayer3:setPositionX(-layer3MoveDis * percent);
	self.m_ccbNodeLayer4:setPositionX(-layer4MoveDis * percent);
	self.m_ccbNodeLayer5:setPositionX(-layer5MoveDis * percent);
	self.m_ccbNodeLayer6:setPositionX(-layer6MoveDis * percent);
	self.m_ccbNodeLayer7:setPositionX(-layer7MoveDis * percent);
	self.m_ccbNodeLayer8:setPositionX(-layer8MoveDis * percent);
	self.m_ccbNodeLayer9:setPositionX(-layer9MoveDis * percent);
	self.m_ccbNodeLayer10:setPositionX(-layer10MoveDis * percent);
end

function testScrow:updateShortMapPoint(tag, point, isEnemy)
	local percentX = math_abs(point.x/VIEW_WIDTH)
	local percentY = (point.y-self.m_ccbNodeTouchView:getPositionY())/self.m_ccbNodeTouchView:getContentSize().height

    local sprite = self.m_mapPointData[tag];
    if sprite == nil then
		sprite = cc.Sprite:create(isEnemy and "res/resources/demo/pvp_preview_part4.png" or "res/resources/demo/pvp_preview_part3.png")
			:setScale(0.5)
			:addTo(self.m_ccbNodeSliderBack)
		self.m_mapPointData[tag] = sprite;
	end
	sprite:setPosition(cc.p(percentX*self.m_mapPointSize.width+MAP_POINT_ADJUST, percentY*self.m_mapPointSize.height+MAP_POINT_ADJUST))
end

function testScrow:createFortAnim()
	local animPath = "res/anims/demo/pvp_plane2/pvp_plane2.ExportJson";
	
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath);
	local armature = ccs.Armature:create("pvp_plane2");
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath);
	self.m_ccbNodeLayer10:addChild(armature);
	armature:setPosition(400, 200);
	armature:getAnimation():play("idle");
	armature:setRotation(90);
	armature:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.complete then
				if movementID == "shoot" then
					print("shoot完");
					armature:getAnimation():play("idle");
				end
			end

		end)
	self.m_fortArmature = armature;
	self:createButton();
end

function testScrow:createButton()
	self.m_touchCount = 0;
	local cancelBtn = ccui.Button:create(ResourceMgr:getRevengeBtnRejectNormal(), ResourceMgr:getRevengeBtnRejectHigh(), ResourceMgr:getRevengeBtnRejectHigh());
	self.m_ccbNodeLayer10:addChild(cancelBtn);
	cancelBtn:setPosition(600,200);
	-- cancelBtn:setTitleText(Str[1002]);
	-- cancelBtn:setTitleFontSize(20);
	cancelBtn:addClickEventListener(function()
		self.m_touchCount = self.m_touchCount + 1;

		if self.m_touchCount % 3 == 0 then
			print("self.m_touchCount:", self.m_touchCount, "     hit");
			self.m_fortArmature:getAnimation():play("hit");
		elseif self.m_touchCount % 3 == 1 then
			print("self.m_touchCount:", self.m_touchCount, "     shoot");
			self.m_fortArmature:getAnimation():play("shoot");
		elseif self.m_touchCount % 3 == 2 then
			print("self.m_touchCount:", self.m_touchCount, "     idle");
			self.m_fortArmature:getAnimation():play("idle");
		end
	end) 
end
--测试数据
function testScrow:onBtnCreateEnemyPlane()
	local randArmsId = 10 .. math_random(1, MAX_ARMS_ICON_RES);
	Battle.createEnemyFort(randArmsId,math_random(1,MAX_LEVEL),math_random(0,SHIP_POS_Y*2),constants_arms[randArmsId].cost);
end

function testScrow:onBtnPause()
	self.m_isPause = not self.m_isPause;
	if self.m_isPause then
		Battle.pauseBattle();
		self.m_ccbBtnPause:getTitleLabel():setString("游戏恢复");
	else
		Battle.startBattle();
		self.m_ccbBtnPause:getTitleLabel():setString("游戏暂停");
	end
end

function testScrow:onBtnExit()
	Battle.deleteBattle();
	self:onExit();

	App:enterScene("DemoBattlePreScene");
end

return testScrow;