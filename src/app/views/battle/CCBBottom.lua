local BattleResourceMgr = require("app.utils.BattleResourceMgr");
--local CCBPopWindow = require("app.views.commonCCB.CCBPopWindow");
local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");
local Tips = require("app.views.common.Tips");
local DescripProp = require("app.views.common.DescripProp");

local CCBBottom = class("CCBBottom", function ()
	return CCBLoader("ccbi/battle/CCBBottom.ccbi");
end)

local itemCountCirPos = cc.p(-45, -38);

--更新道具冷却时间
function CCBBottom:refresh(dt)
	-- print("CCBBottom:onUpdate")
	-- 普通物品1,2,3,4,5 计算CD
	for i = 1, 5 do
		if self.m_isStateCD and self.m_isStateCD[i] and self.m_isStateCD[i] == true then
			self.m_leftTimeCD[i] = self.m_leftTimeCD[i] - dt
			if self.m_leftTimeCD[i] <= 0 then
				self.m_isStateCD[i] = false;
				self.m_leftTimeCD[i] = 0;
				if self.m_slotItemCount[i] ~= 0 then
					if not self.m_isBossChange then
						self:setGrayState(i, false);
					end
				end
			end
			local baseTimeCD = ItemDataMgr:getItemBaseInfo(self.m_slotItemID[i]).cd 	--基础CD
			self.m_scale9SpriteCD[i]:setScaleY(self.m_leftTimeCD[i] / baseTimeCD);
		end
	end
end

function CCBBottom:InitData(ccbBattle)
	self:enableNodeEvents();
	self.m_ccbBattle = ccbBattle;

	self.m_nodeSlot = {};				--物品栏节点对象
	self.m_scale9SpriteCD = {};			--CD遮罩层对象

	self.m_isStateCD = {};				--是否处于CD中
	self.m_leftTimeCD = {0,0,0,0,0};	--CD剩余时间
	
	self.m_helperLeftTimeCD = 0;		--好友助力CD剩余时间

	self.m_slotItemID = {};				--物品ID
	self.m_slotItemCount = {};			--物品数量
	self.m_helperItemCount = 0;			--好友助力物品个数
	self.m_labelCount = {};				--显示物品数量Label
	self.m_slotItemDesc = {};           --物品描述
	self.m_slotItemName = {};			--物品名字

	self.m_nodeItemIcon = {}; 			--物品ICON
	self.m_btnTouch = {};				--点击物品的按钮
	self.m_spriteAddIcon = {};

	self.m_isBossChange = false;

	self:createEventListener();

	--道具栏初始状态
	-- BattleDataMgr:setCurSelectItemSlot(0);
	BattleDataMgr:setCurSelectItemId(0);
	BattleDataMgr:setSelectShipSkill(false);
	self.m_armatureSelectItem = nil; -- 选中物品栏的动画

	--普通物品1,2,3,4,5
	for i = 1, 5 do
		self:setSlotDataByPos(i);
	end

	-- 战舰技能图标
	self.m_shipID = BattleDataMgr:getPlayerShipID();
	print(self.m_shipID)
	local shipSkillIcon = cc.Sprite:create("res/itemIcon/ship_skill_"..self.m_shipID..".png");
	self.m_ccbNodeShipSkill:addChild(shipSkillIcon, 1, 1)

	-- 战舰技能能量条
	self.m_spriteShipEnergy = cc.ProgressTimer:create(cc.Sprite:create("res/resources/battle/pvp_shipskill_part3.png"));
    self.m_spriteShipEnergy:setType(cc.PROGRESS_TIMER_TYPE_BAR);
    self.m_spriteShipEnergy:setPercentage(0);
  
    self.m_spriteShipEnergy:setMidpoint(cc.p(0, 0));
    self.m_spriteShipEnergy:setBarChangeRate(cc.p(0, 1));
	self.m_ccbNodeEnergyBar:addChild(self.m_spriteShipEnergy);

	self.m_combatData = table.clone(require("app.constants.combat"));
end

-- BattleDataMgr:getCurPlayerInfo().items
--    "1001" = {
--         "count"   = 1
--         "item_id" = 1001
--         "past"    = 27.117
--     }
--     "1002" = {
--         "count"   = 1
--         "item_id" = 1002
--         "past"    = 24.285
--     }
--     "1012" = {
--         "count"   = 2
--         "item_id" = 1012
--         "past"    = 15.554
--     }
--     "4004" = {
--         "count"   = 1
--         "item_id" = 4004
--         "past"    = 20.399
--     }

function CCBBottom:createEventListener()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(false);
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event); end, cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event); end, cc.Handler.EVENT_TOUCH_MOVED);
	listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event); end, cc.Handler.EVENT_TOUCH_ENDED);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbNodeTouch);

end

function CCBBottom:onTouchBegan(touch, event)
	self.m_touchBeganPos = touch:getLocation();
	self.m_nodePos = self.m_ccbNodeItems:convertToNodeSpace(self.m_touchBeganPos);
	self.m_touchIndex = 0;
	for i = 1, 5 do
		if cc.rectContainsPoint(self.m_ccbNodeItems:getChildByTag(i):getBoundingBox(), self.m_nodePos) then
			self.m_touchIndex = i;
		end
	end
	if self.m_descProp then
		self.m_descProp:removeSelf();
		self.m_descProp = nil;
	end
	if self.m_schdulerTouch then
		self:getScheduler():unscheduleScriptEntry(self.m_schdulerTouch);
		self.m_schdulerTouch = nil;
	end
	self.m_touchTime = 0;
	self.m_isCreateProp = false;
	if self.m_touchIndex ~= 0 then
		self.m_schdulerTouch = self:getScheduler():scheduleScriptFunc(function (dt)
				self:onTimeDate(dt);
			end, 0, false);
	end
	return true;
end

function CCBBottom:onTouchMoved(touch, event)

end

function CCBBottom:onTouchEnded(touch, event)

	if self.m_descProp then
		self.m_descProp:removeSelf();
		self.m_descProp = nil;
	end
	if self.m_schdulerTouch then
		self:getScheduler():unscheduleScriptEntry(self.m_schdulerTouch);
		self.m_schdulerTouch = nil;
	end
end

function CCBBottom:onTimeDate(dt)
	self.m_touchTime = self.m_touchTime + dt;
	if self.m_touchTime > 0.7 then
		self.m_isCreateProp = true;
		self.m_descProp = DescripProp:create();
		self.m_ccbNodeItems:addChild(self.m_descProp);
		
		self.m_descProp:setBattleDesc(self.m_slotItemName[self.m_touchIndex], self.m_slotItemDesc[self.m_touchIndex]);
		local size = self.m_descProp:getScale9PicSize();
		self.m_descProp:setPosition(cc.p(self.m_nodePos.x, self.m_nodePos.y + 80 + size.height));

		self:getScheduler():unscheduleScriptEntry(self.m_schdulerTouch);
		self.m_schdulerTouch = nil;
	end
end

--普通物品显示1,2,3,4,5
function CCBBottom:setSlotDataByPos(pos)
	self.m_slotItemID[pos] = ItemDataMgr:getEquipSlotByPos(pos);
	local itemBaseInfo = ItemDataMgr:getItemBaseInfo(self.m_slotItemID[pos]);
	self.m_slotItemDesc[pos] = itemBaseInfo.desc;
	self.m_slotItemName[pos] = itemBaseInfo.name;

	--获取CCB上的控件对象
	self.m_nodeSlot[pos] = self.m_ccbNodeItems:getChildByTag(pos);
	self.m_nodeItemIcon[pos] = self.m_nodeSlot[pos]:getChildByTag(2);
	self.m_scale9SpriteCD[pos] = self.m_nodeSlot[pos]:getChildByTag(3);
	self.m_labelCount[pos] = self.m_nodeSlot[pos]:getChildByTag(4);
	self.m_btnTouch[pos] = self.m_nodeSlot[pos]:getChildByTag(6);
	self.m_spriteAddIcon[pos] = self.m_nodeSlot[pos]:getChildByTag(5);

	-- print("初始化 buttom   底部 。。。");
	--有装备物品则显示，bing将点击的按钮设为不可点
	if self.m_slotItemID[pos] ~= -1 then
		BattleResourceMgr:getBattleItemIcon(self.m_slotItemID[pos]):addTo(self.m_nodeItemIcon[pos], 1, 1);

		-- print("装备栏的",pos,"位置有装备")
		self.m_spriteAddIcon[pos]:setVisible(false);
	else
		self.m_btnTouch[pos]:setEnabled(false);
	end	

	--CD遮罩层
	self.m_scale9SpriteCD[pos]:setScaleY(0);

	--物品数量
	self.m_slotItemCount[pos] = ItemDataMgr:getItemCount(ItemDataMgr:getEquipSlotByPos(pos));
	-- print("pos : ", pos);
	-- dump(self.m_slotItemCount);
	if itemBaseInfo ~= nil and self.m_slotItemCount[pos] > itemBaseInfo.use_limit then
		self.m_slotItemCount[pos] = itemBaseInfo.use_limit;
	end

	if self.m_slotItemCount[pos] <= 0 then
		self:setGrayState(pos, true);
		local useUpSprite = cc.Sprite:create(BattleResourceMgr:getBattleItemUseUp());
		self.m_ccbNodeItems:getChildByTag(pos):getChildByTag(7):addChild(useUpSprite);
	end

	--显示消耗过的物品的数量和CD过去时间
	for k, v in pairs(BattleDataMgr:getCurPlayerInfo().items) do
		if v.item_id == self.m_slotItemID[pos] then
			if self.m_slotItemCount[pos] > itemBaseInfo.use_limit - v.count then
				self.m_slotItemCount[pos] = itemBaseInfo.use_limit - v.count;
			end
			self.m_leftTimeCD[pos] = itemBaseInfo.cd - v.past;
			if self.m_leftTimeCD[pos] > 0 then
				self:showCD(pos, self.m_leftTimeCD[pos])
			end
		end
	end

	self:createItemCountHint(self.m_nodeItemIcon[pos], self.m_slotItemCount[pos], itemBaseInfo.use_limit);
	-- self.m_labelCount[pos]:setString(self.m_slotItemCount[pos]);
end

function CCBBottom:createItemCountHint(node, curNum, limitNum)
	local nodeHint = cc.Node:create();
	nodeHint:setPosition(itemCountCirPos);
	node:addChild(nodeHint, 2, 2);
	for i = 1, limitNum do 
		if i <= curNum then
			local spriteCirHint = cc.Sprite:create(BattleResourceMgr:getBattleItemCountHigh());
			local spriteSize = spriteCirHint:getContentSize();
			nodeHint:addChild(spriteCirHint, 1, i);
			spriteCirHint:setPositionY(spriteSize.height * (i - 1));
		else
			local spriteCirHint = cc.Sprite:create(BattleResourceMgr:getBattleItemCountLow());
			local spriteSize = spriteCirHint:getContentSize();
			nodeHint:addChild(spriteCirHint, 1, i);
			spriteCirHint:setPositionY(spriteSize.height * (i - 1));
		end
	end
end

-- 开始战斗，打开按钮
function CCBBottom:openBtnToUse()
	-- print(" 开始战斗，在底部开启buttom按钮");
	self.m_isBattleReady = true;
	for i = 1, 5 do
		if self.m_slotItemID[pos] ~= -1 then
			self.m_btnTouch[pos]:setEnabled(true);
		else
			self.m_btnTouch[pos]:setEnabled(false);
		end
	end
end

--道具CD
function CCBBottom:showCD(pos)
	-- print("CCBBottom:showCD", pos);	
	if self.m_slotItemCount[pos] > 0 then
		if self.m_leftTimeCD[pos] == 0 then
			local itemBaseInfo = ItemDataMgr:getItemBaseInfo(self.m_slotItemID[pos]);
			self.m_leftTimeCD[pos] = itemBaseInfo.cd;
		end 
		
		self.m_isStateCD[pos] = true;
	else
		-- Tips:create(Str[11004]);
		-- show 用尽 picture
		-- Tips:create("show 用尽's picture");
		local useUpSprite = cc.Sprite:create(BattleResourceMgr:getBattleItemUseUp());
		self.m_ccbNodeItems:getChildByTag(pos):getChildByTag(7):addChild(useUpSprite);
	end
	self:setGrayState(pos, true);
end

function CCBBottom:setButtonUnuse()
	print("设置道具区按钮不可用")
	self.m_isBossChange = true;
	for i = 1, 5 do 
		self:setGrayState(i, true);
	end
	-- self:setHelperGray(true);
end

function CCBBottom:setButtonUse()
	print("设置道具去按钮可以用。。。");
	self.m_isBossChange = false;
	for i = 1, 5 do
		if self.m_slotItemCount[i] > 0 and not self.m_isStateCD[i] then
			self:setGrayState(i, false);
		end
	end
	-- if self.m_isMaxEnergy then
	-- 	self:setHelperGray(false);
	-- end
end

--置灰某一个位置上的物品，并设为不可点
function CCBBottom:setGrayState(pos, isGray)
	if isGray then
		self.m_btnTouch[pos]:setEnabled(false);
		display.setGray(self.m_nodeItemIcon[pos]:getChildByTag(1):getChildByTag(1));
		display.setGray(self.m_nodeItemIcon[pos]:getChildByTag(1):getChildByTag(2));
	else
		self.m_btnTouch[pos]:setEnabled(true);
		display.removeShader(self.m_nodeItemIcon[pos]:getChildByTag(1):getChildByTag(1));
		display.removeShader(self.m_nodeItemIcon[pos]:getChildByTag(1):getChildByTag(2));
	end
end

--好友助力置灰，并设为不可点
function CCBBottom:setHelperGray(isGray)
	if isGray then
		self.m_ccbBtnHelper:setEnabled(false);
		-- display.setGray(self.m_ccbNodeHelper:getChildByTag(1));
		-- display.setGray(self.m_ccbSpriteHelperBg);
		if self.m_ccbScale9SpriteHelperCD:isVisible() == false then
			self.m_ccbScale9SpriteHelperCD:setVisible(true);
		end
	else
		self.m_ccbBtnHelper:setEnabled(true);
		-- display.removeShader(self.m_ccbNodeHelper:getChildByTag(1));
		-- display.removeShader(self.m_ccbSpriteHelperBg);
		if self.m_ccbScale9SpriteHelperCD:isVisible() == true then
			self.m_ccbScale9SpriteHelperCD:setVisible(false);
		end
	end
end

--处理当前物品栏的选中状态
function CCBBottom:setCurSelectItemSlot(index)
	local lastSelectSlot = BattleDataMgr:getCurSelectItemSlot();
	if index == 0 and lastSelectSlot ~= 0 then --点击某个物品
		print("cencal", lastSelectSlot);
		BattleDataMgr:setCurSelectItemSlot(0);
		BattleDataMgr:setCurSelectItemId(0);
		if self.m_armatureSelectItem then
			self.m_armatureSelectItem:removeSelf();
			self.m_armatureSelectItem = nil;
		end
		local lastnodeSlot = self.m_ccbNodeItems:getChildByTag(lastSelectSlot);
		if lastnodeSlot then
			lastnodeSlot:runAction(cc.MoveBy:create(0.1, cc.p(0, -8)))
		end	
	elseif index ~= 0 and lastSelectSlot == 0 then
		print("first select or select again", index);
		BattleDataMgr:setCurSelectItemSlot(index);
		BattleDataMgr:setCurSelectItemId(self.m_slotItemID[index]);
		if self.m_armatureSelectItem then
			self.m_armatureSelectItem:removeSelf();
		end
		self.m_armatureSelectItem = BattleResourceMgr:getSelectItemArmature()
		self.m_ccbNodeItems:getChildByTag(index):getChildByTag(7):addChild(self.m_armatureSelectItem);
		self.m_armatureSelectItem:getAnimation():play("anim01");
		self.m_armatureSelectItem:setPositionY(-5);
		
		local nodeCurSlot = self.m_ccbNodeItems:getChildByTag(index);
		if nodeCurSlot then
			nodeCurSlot:runAction(cc.MoveBy:create(0.1, cc.p(0, 8)))
		end	
	elseif index ~= 0 and lastSelectSlot ~= 0 then
		if lastSelectSlot == index then
			print("cencal self", index);
			BattleDataMgr:setCurSelectItemSlot(0);
			BattleDataMgr:setCurSelectItemId(0);
			if self.m_armatureSelectItem then
				self.m_armatureSelectItem:removeSelf();
				self.m_armatureSelectItem = nil;
			end
			local lastnodeSlot = self.m_ccbNodeItems:getChildByTag(lastSelectSlot);
			if lastnodeSlot then
				lastnodeSlot:runAction(cc.MoveBy:create(0.1, cc.p(0, -8)))
			end	
		else
			print("change", lastSelectSlot, index);
			BattleDataMgr:setCurSelectItemSlot(index);
			BattleDataMgr:setCurSelectItemId(self.m_slotItemID[index]);
			if self.m_armatureSelectItem then
				self.m_armatureSelectItem:removeSelf();
			end
			self.m_armatureSelectItem = BattleResourceMgr:getSelectItemArmature()
			self.m_ccbNodeItems:getChildByTag(index):getChildByTag(7):addChild(self.m_armatureSelectItem);
			self.m_armatureSelectItem:getAnimation():play("anim01");
			self.m_armatureSelectItem:setPositionY(-5);

			local lastnodeSlot = self.m_ccbNodeItems:getChildByTag(lastSelectSlot);
			if lastnodeSlot then
				lastnodeSlot:runAction(cc.MoveBy:create(0.1, cc.p(0, -8)))
			end

			local nodeCurSlot = self.m_ccbNodeItems:getChildByTag(index);
			if nodeCurSlot then
				nodeCurSlot:runAction(cc.MoveBy:create(0.1, cc.p(0, 8)))
			end
		end
	end	
end

--道具数量更新（notify调用）
function CCBBottom:updateItemCount()
	print("CCBBottom:updateItemCount")
	print("更新道具冷却时间");
	local pos = BattleDataMgr:getCurSelectItemSlot(); -- 使用好友支援 pos = 0
	if pos ~= 0 then
		self:updateItemCountHint(pos);
		self.m_slotItemCount[pos] = self.m_slotItemCount[pos] - 1;
		-- self.m_labelCount[pos]:setString(self.m_slotItemCount[pos]);
		
		self:showCD(pos);
		self:setCurSelectItemSlot(0);
		BattleDataMgr:setCurSelectItemId(0);
	end
end

function CCBBottom:updateItemCountHint(pos)
	local nodeHint = self.m_nodeItemIcon[pos]:getChildByTag(2);
	local hintSpritePosY = nodeHint:getChildByTag(self.m_slotItemCount[pos]):getPositionY();
	nodeHint:removeChildByTag(self.m_slotItemCount[pos]);
	local hintSprite = cc.Sprite:create(BattleResourceMgr:getBattleItemCountLow());
	nodeHint:addChild(hintSprite, 1, self.m_slotItemCount[pos]);
	hintSprite:setPositionY(hintSpritePosY);
end

-- item_target类型定义
-- 0-我方炮台（单体）
-- 1-我方舰体
-- 2-我方全体（舰体、所有炮台）
-- 3-我方战损的炮台
-- 4-敌方炮台（单体）
-- 5-敌方舰体
-- 6-敌方全体（舰体、所有炮台）
-- 7-能量体
-- 8-我方或敌方
function CCBBottom:showTarget()	
	-- self.m_ccbBattle:cleanAllTarget();
	if BattleDataMgr:getCurSelectItemSlot() ~= 0 then
		local selectItemPos = BattleDataMgr:getCurSelectItemSlot()
		local itemID = self.m_slotItemID[selectItemPos];
		local itemInfo = ItemDataMgr:getItemBaseInfo(itemID);
		-- dump(itemInfo);
		self.m_ccbBattle:showTarget(itemInfo.item_target);
	elseif BattleDataMgr:isSelectShipSkill() then
		self.m_ccbBattle:showTarget(5);--敌方舰体
	else
		self.m_ccbBattle:showTarget();--清除，不显示
	end
end

--使用物品1
function CCBBottom:onBtnItem1()
	print("onBtnItem1")	
	if self.m_slotItemID[1] and self.m_slotItemID[1] ~= -1 and self.m_ccbBattle.m_isBattleBegin and not self.m_isCreateProp then
		BattleDataMgr:setSelectShipSkill(false);
		self:setCurSelectItemSlot(1);
		self:showTarget();
	end
	self.m_isCreateProp = false;
end

--使用物品2
function CCBBottom:onBtnItem2()
	print("onBtnItem2")
	if self.m_slotItemID[2] and self.m_slotItemID[2] ~= -1 and self.m_ccbBattle.m_isBattleBegin and not self.m_isCreateProp then
		BattleDataMgr:setSelectShipSkill(false);
		self:setCurSelectItemSlot(2);
		self:showTarget();
	end
	self.m_isCreateProp = false;
end

--使用物品3
function CCBBottom:onBtnItem3()
	print("onBtnItem3")
	if self.m_slotItemID[3] and self.m_slotItemID[3] ~= -1 and self.m_ccbBattle.m_isBattleBegin and not self.m_isCreateProp then
		BattleDataMgr:setSelectShipSkill(false);
		self:setCurSelectItemSlot(3);
		self:showTarget();
	end
	self.m_isCreateProp = false;
end

--使用物品4
function CCBBottom:onBtnItem4()
	print("onBtnItem4")
	if self.m_slotItemID[4] and self.m_slotItemID[4] ~= -1 and self.m_ccbBattle.m_isBattleBegin and not self.m_isCreateProp then
		BattleDataMgr:setSelectShipSkill(false);
		self:setCurSelectItemSlot(4);
		self:showTarget();
	end
	self.m_isCreateProp = false;
end

--使用物品5
function CCBBottom:onBtnItem5()
	print("onBtnItem5")
	if self.m_slotItemID[5] and self.m_slotItemID[5] ~= -1 and self.m_ccbBattle.m_isBattleBegin and not self.m_isCreateProp then
		BattleDataMgr:setSelectShipSkill(false);
		self:setCurSelectItemSlot(5);
		self:showTarget();
	end
	self.m_isCreateProp = false;
end

--点到非点击区则取消选择状态
function CCBBottom:cancelAllSelect()
	self:setCurSelectItemSlot(0);
	self:setShipSkillState(false);
end

--战舰技能(原好友助力)
function CCBBottom:onBtnHelper()
	print("好友助力释放战舰技能")
	self:setCurSelectItemSlot(0);	
	if self.m_isMaxEnergy then

		local function useItemCallBack(rc, data)		
			if data.code ~= 1 then
				print("Battle Use shipSkill Error");
				print(GameData:get("code_map")[data.code]["desc"]);
			else
				print("use shipSkill success");
			end
		end	

		local shipID = BattleDataMgr:getPlayerShipID();
		local target = ShipDataMgr:getShipSkillTarget(self.m_shipID)
		if target == 1 then
			target = 0;
		else
			target = 1;
		end
		local sendInfo = {type = 3, ship_id = self.m_shipID, target_is_enemy = target};
		local battleType = BattleDataMgr:getBattleType();
		if battleType == 0 then   -- 普通战斗
			Network:request("battle.battleHandler.emitEvent", sendInfo, useItemCallBack);
		elseif battleType == 1 then   -- 探险
			Network:request("explore_battle.exploreHandler.emitEvent", sendInfo, useItemCallBack);
		elseif battleType == 2 then	  -- 抢劫贩售舰
			Network:request("loot_battle.lootHandler.emitEvent", sendInfo, useItemCallBack);
		elseif battleType == 3 then	  -- 公域混战
			Network:request("domain_battle.domainHandler.emitEvent", sendInfo, useItemCallBack);
		elseif battleType == 4 then   -- 殖民星争夺战
			-- Network:request("battle.battleHandler.emitEvent", sendInfo, useItemCallBack);
		end
	else
		return
	end	
end

function CCBBottom:updateShipEnergy()
	local FighterData = newBattle.getFighterData()
	self.m_energyPercentage = FighterData.playerShipEnergy/100
	if self.m_spriteShipEnergy then
		-- print("战舰能量的百分比是:", self.m_energyPercentage)
		self.m_spriteShipEnergy:setPercentage(self.m_energyPercentage*100)
	end
	if self.m_energyPercentage ~= 1 or self.m_isBossChange then
		self:setShipSkillState(false)
		self:removeShipSkillLight();
	else
		self:setShipSkillState(true)
		self:showShipSkillLight();
	end
end

function CCBBottom:showShipSkillLight()
	if not self.m_shipSkillAnim then
		self.m_shipSkillAnim = BattleResourceMgr:createBattleArmature("fx_shipskill");
		self.m_ccbNodeHelperParent:addChild(self.m_shipSkillAnim);
		self.m_shipSkillAnim:getAnimation():play("anim01");
		self.m_shipSkillAnim:setPosition(cc.p(-5, 0));
	end
end

function CCBBottom:removeShipSkillLight()
	if self.m_shipSkillAnim then
		self.m_shipSkillAnim:removeSelf();
		self.m_shipSkillAnim = nil;
	end
end

--设置助力状态
function CCBBottom:setShipSkillState(isSelect)
	if isSelect then
		-- print("能量已满可以释放战舰技能")
		self.m_isMaxEnergy = true;
		self:setHelperGray(false);
	else
		-- print("能量未满不能释放战舰技能")
		self.m_isMaxEnergy = false;
		self:setHelperGray(true);
	end
end

--点击投降按钮
function CCBBottom:onBtnSurrender()
	if self.m_ccbBattle.m_isBattleBegin then
		local ccbMessageBox = CCBMessageBox:create(Str[3008], Str[4008], MB_YESNO);
		ccbMessageBox.onBtnOK = function ()
			self:sendSurrenderMsg();
			ccbMessageBox:removeSelf();
		end

		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();	
		end

		-- local hint = CCBPopWindow:create(1, 10, self);
		-- self.m_ccbBattle:addChild(hint, 1, 100);
		-- hint:setTitleLabel(Str[3008]);
		-- hint:setContentLabel(Str[4008]);
	end
end

function CCBBottom:showUnmissileState()
	for i = 1, 5 do 
		if self.m_combatData[tostring(self.m_slotItemID[i])] and 
			self.m_combatData[tostring(self.m_slotItemID[i])].missile == 1 and
			self.m_slotItemCount[i] > 0 then
			self:setGrayState(i, true);
			if BattleDataMgr:getCurSelectItemSlot() == i then
				self:setCurSelectItemSlot(0);
			end
			if not self.m_ccbNodeItems:getChildByTag(i):getChildByTag(7):getChildByTag(1) then
				local unmissileSprite = cc.Sprite:create(BattleResourceMgr:getBattleItemUnmissileState());
				self.m_ccbNodeItems:getChildByTag(i):getChildByTag(7):addChild(unmissileSprite, 1, 1);
			end
		end
	end
end

function CCBBottom:removeUnmissileState()
	for i = 1, 5 do
		if self.m_combatData[tostring(self.m_slotItemID[i])] and
		self.m_combatData[tostring(self.m_slotItemID[i])].missile == 1 and
		self.m_slotItemCount[i] > 0 then
			self:setGrayState(i, false);
			if self.m_ccbNodeItems:getChildByTag(i):getChildByTag(7):getChildByTag(1) then
				self.m_ccbNodeItems:getChildByTag(i):getChildByTag(7):removeChildByTag(1);
			end
		end
	end
end

--向服务器发送投降消息
function CCBBottom:sendSurrenderMsg()
	local battleType = BattleDataMgr:getBattleType();
	print(" 投降 ！！！！！！！！！！！！！！", battleType);
	if battleType == 0 then   -- 普通战斗
		Network:request("battle.battleHandler.emitEvent", {type = 4}, function(rc, data)
			if data.code ~= 1 then
				print(GameData:get("code_map")[data.code]["desc"]);
			end
		end);
	elseif battleType == 1 then   -- 探险
		Network:request("explore_battle.exploreHandler.emitEvent", {type = 4}, function(rc, data)
			if data.code ~= 1 then
				print(GameData:get("code_map")[data.code]["desc"]);
			end
		end);
	elseif battleType == 2 then	  -- 抢劫贩售舰
		Network:request("loot_battle.lootHandler.emitEvent", {type = 4}, function(rc, data)
			if data.code ~= 1 then
				print(GameData:get("code_map")[data.code]["desc"]);
			end
		end);
	elseif battleType == 3 then	  -- 公域混战
		Network:request("domain_battle.domainHandler.emitEvent", {type = 4}, function(rc, data)
			if data.code ~= 1 then
				print(GameData:get("code_map")[GameData.code]["desc"]);
			end
		end);
	elseif battleType == 4 then   -- 殖民星争夺战
		-- Network:request("battle.battleHandler.emitEvent", sendInfo, useItemCallBack);
	end

end

return CCBBottom