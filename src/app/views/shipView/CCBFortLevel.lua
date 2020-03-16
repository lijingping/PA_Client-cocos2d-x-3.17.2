local ResourceMgr = require("app.utils.ResourceMgr");
local Tips = require("app.views.common.Tips");

------------------
-- 炮台升级窗口
------------------
local CCBFortLevel = class("CCBFortLevel", function ()
	return CCBLoader("ccbi/shipView/CCBFortLevel.ccbi")
end)

function CCBFortLevel:ctor()
	self:init()
	self:createTouchListener();
	self.isDone = true;
	self.count = 0
	self.m_armature = nil;
	self.m_expArmature = nil;
	self.m_animInOne = true;
	self.m_isLevelUp = false;
	self.m_fortQuality = "";
	self.m_nextFortQuality = "";
	self.m_isAddingExp = false;
	self.m_isRequesting = false;
end

-- 初始化
function CCBFortLevel:init()
	local expLabels = {
		self.m_ccbLabelExpIcon1,
		self.m_ccbLabelExpIcon2,
		self.m_ccbLabelExpIcon3,
		self.m_ccbLabelExpIcon4,
	}
	self.m_expItemData = {};

	local expItemData = table.clone(require("app.constants.fort_upgrade_item"));
	-- dump(expItemData);
	for i=1,4 do
	
		local pos = "m_ccbLayerIcon"..i -- self[m_ccbLayerIcon1]等于self.m_ccbLayerIcon1是ui中的layer

		local id = 4000 + i -- 升级道具的ID

		local quality = ItemDataMgr:getItemLevelByID(id)+1; -- 经验道具的品级
		self.m_expItemData[i] = ItemDataMgr:getItemBaseInfo(id); -- 存入信息
		self[pos]:getChildByTag(5):addChild(cc.Sprite:create(ResourceMgr:getItemBGByQuality(quality)));--背景
		self[pos]:getChildByTag(5):addChild(cc.Sprite:create(ResourceMgr:getItemIconByID(id))); --icon图标
		self[pos]:getChildByTag(5):addChild(cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(quality))); --icon变框

		local count = ItemDataMgr:getItemCount(id); -- 拥有升级道具的个数

		self[pos]:getChildByTag(6):setString(count); -- 设置道具个数
		if count <= 0 then --字体颜色
			self[pos]:getChildByTag(6):setTextColor(cc.c3b(255, 0, 0)); 
		else
			self[pos]:getChildByTag(6):setTextColor(cc.c3b(255, 255, 255));
		end

		local exp = expItemData[tostring(self.m_expItemData[i].id)].fort_exp;
		-- print("道具的经验值是", exp)
		self.m_expItemData[i].item_use_exp = exp;
		expLabels[i]:setString("EXP+"..tostring(exp));
	end
	-- dump(self.m_expItemData);

	--经验条
	-- local barBgSize = self.m_ccbSpriteBarBg:getContentSize();
	self.m_progressTimer = cc.ProgressTimer:create(cc.Sprite:create(ResourceMgr:getFortLevelExpBar()))
    self.m_progressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    -- self.m_progressTimer:setPosition(barBgSize.width / 2 - 3, barBgSize.height / 2 - 5);
	self.m_progressTimer:setPercentage(0);
    self.m_progressTimer:setBarChangeRate(cc.p(1, 0));
    self.m_progressTimer:setMidpoint(cc.p(0, 0));
	self.m_ccbNodeExpBar:addChild(self.m_progressTimer, 1);
	self.m_ccbLabelExpCount:setLocalZOrder(2);
end


function CCBFortLevel:createTouchListener()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(false);
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN);
	-- listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED);
	listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end


function CCBFortLevel:onTouchBegan(touch, event)
	if not self:isVisible() then
		return false;
	end
	if self.m_isRequesting then
		return false;
	end
	local beganPos = touch:getLocation();
	self.m_beganPos = self:convertToNodeSpace(beganPos);
	self.m_boxNumber = -1;
	self.m_beganTime = os.time();
	for i = 1, 4 do
		if cc.rectContainsPoint(self:getChildByTag(i):getBoundingBox(), self.m_beganPos) then
			if not self.m_isAddingExp then
				self.m_boxNumber = i; -- 使用的经验道具key
				self.m_itemGiveExp = self.m_expItemData[i].item_use_exp;	-- 升级道具提供的经验值
				self.m_expItemCount = ItemDataMgr:getItemCount(self.m_expItemData[i].id); -- 使用的经验道具的个数
				self.m_expItemUseCount = 0; -- 使用了几个经验道具
				--设置长按
				self.m_schedule = self:getScheduler():scheduleScriptFunc(function()	self:scheduleCallBack(i) end, 0.5, false);
				break;
			end
		end
	end
	return true;
end

-- function CCBFortLevel:onTouchMoved(touch, event)
-- end

function CCBFortLevel:onTouchEnded(touch, event)
	self.isDone = true;
	self.m_endedTime = os.time();
	if self.m_boxNumber > 0 and self.m_endedTime - self.m_beganTime < 0.2 then -- 单独按
		self:computeItemExp(self.m_itemGiveExp, self:getChildByTag(self.m_boxNumber), self.m_expItemData[self.m_boxNumber]);
	end
	if self.m_schedule then
		self:getScheduler():unscheduleScriptEntry(self.m_schedule);
		self.m_schedule = nil;
	end
end

--TouchBegan回调(长按时)
function CCBFortLevel:scheduleCallBack(index)
	print("长按",self.m_itemGiveExp)
	self.isDone = false;
	self:computeItemExp(self.m_itemGiveExp, self:getChildByTag(index), self.m_expItemData[index]);
	if self.m_schedule then
		self:getScheduler():unscheduleScriptEntry(self.m_schedule);
		self.m_schedule = nil;
	end
end

-- 道具经验计算（addExp：道具的增加的经验值, iconCell：使用的道具Node节点）
function CCBFortLevel:computeItemExp(addExp, iconCell, expItemdata)
	-- print("CCBFortLevel:computeItemExp", addExp, iconCell)
	self.m_isAddingExp = true;
	local expItemData = expItemdata; -- 经验道具数据
	if self:checkFortInfo() == false then
		print("请求失败")
		self.m_isAddingExp = false;
		self:requestUpgradeFort(expItemData.id, self.m_expItemUseCount, self.m_fortData);
		return
	end

	--第一次使用Item
	if addExp == self.m_itemGiveExp then
		self.m_expItemUseCount = self.m_expItemUseCount + 1;
		expItemData.count = self.m_expItemCount - self.m_expItemUseCount;
		iconCell:getChildByTag(6):setString(expItemData.count);
		if expItemData.count <= 0 then
			iconCell:getChildByTag(6):setTextColor(cc.c3b(255, 0, 0));
			self.isDone = true;
		else
			iconCell:getChildByTag(6):setTextColor(cc.c3b(255, 255, 255));
		end
		self:expMaterialAnim(iconCell);
	end

	local remindExp = 0 --剩下的经验值
	local useExp = addExp;
	if addExp + self.m_curFortExp >= self.m_LvUpNeedExp then
		useExp = self.m_LvUpNeedExp - self.m_curFortExp;
		remindExp = addExp - useExp;
	end
	self.m_curFortExp = self.m_curFortExp + useExp;

	local barStr = string.format("%d / %d", self.m_curFortExp, self.m_LvUpNeedExp)
	self.m_ccbLabelExpCount:setString(barStr)

	local r = self.m_curFortExp / self.m_LvUpNeedExp * 100;
	local progressToAction = cc.ProgressTo:create((useExp / self.m_LvUpNeedExp) * 0.2, r);
	local callback = cc.CallFunc:create(function()
    	if remindExp > 0 then
    		
    		self:levelUp()
    		self:computeItemExp(remindExp, iconCell, expItemData)
    	elseif self.isDone == false then
    		
    		self:computeItemExp(self.m_itemGiveExp, iconCell, expItemData);

		elseif self.isDone then
			-- Request Network
			
			self:requestUpgradeFort(expItemData.id, self.m_expItemUseCount, self.m_fortData)
    	end
    end)
	local addingExpCallback = cc.CallFunc:create(function()
		self.m_isAddingExp = false;
		end)
    local seq = cc.Sequence:create(progressToAction, callback, addingExpCallback);
	self.m_progressTimer:runAction(seq);
end

--检查炮台数据
function CCBFortLevel:checkFortInfo()
	-- local belowShipLevel = self.m_nextFortLevel <= UserDataMgr:getPlayerLevel(); -- 炮台等级要小于战舰等级
	local materialEnough = self.m_expItemCount > 0	--经验道具数量大于0
	local belowQualityMax = self.m_nextFortQuality == self.m_fortQuality -- 下个等级品质不变
	local belowLevelMax = self.m_fortLevel < 99
	-- print("belowShipLevel =",belowShipLevel, ", materialEnough =", materialEnough, ", belowQualityMax =",belowQualityMax, ", belowLevelMax =",belowLevelMax)
	return materialEnough and belowQualityMax and belowLevelMax
end

function CCBFortLevel:levelUp()
	self.m_curFortExp = 0
	self.m_isLevelUp = true;
	self:fortLevelUpAnim();
	-- print("升级回调")
	self.m_fortLevel = self.m_fortLevel + 1;
	self:updateInfo(self.m_fortData)
end

--数据传入
function CCBFortLevel:setData(data, isDone)
	-- dump(data)
	-- "<var>" = {
	--     "advance_item" = 3001
	--     "fort_desc"    = "NO.1炮台"
	--     "fort_name"    = "零式刀锋"
	--     "fort_type"    = 1
	--     "id"           = 90001
	--     "skill_id"     = 50001
	--     "star_const"   = 1
	-- }
	self.m_fortData = data
	local quality = FortDataMgr:getUnlockFortQuality(data.id)
	-- print("CCBFortLevel.lua line 223 print", quality);
	self.m_isLevelUp = false;
	-- self.m_fortLevel = FortDataMgr:getUnlockFortLevel(data.id); -- 炮台等级
	if isDone or self.m_fortQuality ~= quality then
		self:updateInfo(data)
	end
end

--数据更新
function CCBFortLevel:updateInfo(data)
	self:cleanNode();
	local fortID = data.id;
	if self.m_isLevelUp == false then
		self.m_fortLevel = FortDataMgr:getUnlockFortLevel(data.id); -- 炮台等级
		self.m_curFortExp = FortDataMgr:getUnlockFortExp(fortID) or 0; --炮台现在的经验值
	end
	if self.m_fortLevel < 99 then
		self.m_nextFortLevel = self.m_fortLevel + 1;
	else
		self.m_nextFortLevel = self.m_fortLevel;
	end
	self.m_fortQuality = FortDataMgr:getUnlockFortQuality(fortID)
	-- print("self.m_fortQuality    ", self.m_fortQuality);
	self.m_nextFortQuality = FortDataMgr:getFortConst(data.id, self.m_nextFortLevel).quality; -- 下个等级炮台品质
	-- print("self.m_nextFortQuality     ", self.m_nextFortQuality);
	self.m_fortAtk =  math.ceil(FortDataMgr:attack(data.id, self.m_fortLevel)) -- 炮台攻击
	self.m_fortNextAtk = math.ceil(FortDataMgr:attack(data.id, self.m_nextFortLevel)) -- 下个等级炮台攻击

	self.m_fortHp = math.ceil(FortDataMgr:healthPoint(data.id, self.m_fortLevel)); -- 炮台Hp
	self.m_fortNextHp = math.ceil(FortDataMgr:healthPoint(data.id, self.m_nextFortLevel)); --下个等级的炮台Hp

	self.m_fortDefence = math.ceil(FortDataMgr:defence(data.id, self.m_fortLevel)); -- 炮台防御值
	self.m_fortNextDef = math.ceil(FortDataMgr:defence(data.id, self.m_nextFortLevel)); -- 下个等级的炮台防御值

	self.m_ccbLabelLevel:setString("Lv."..self.m_fortLevel)

	self.m_ccbLabelHpLeft:setString(self.m_fortHp)
	self.m_ccbLabelHpRight:setString(self.m_fortNextHp)

	self.m_ccbLabelAckLeft:setString(self.m_fortAtk)
	self.m_ccbLabelAckRight:setString(self.m_fortNextAtk)

	self.m_ccbLabelDefLeft:setString(self.m_fortDefence);
	self.m_ccbLabelDefRight:setString(self.m_fortNextDef);

	if self.m_nextFortLevel == self.m_fortLevel then
		for i = 1, 3 do 
			local maxSprite = cc.Sprite:create(ResourceMgr:getFortMaxSprite());
			self:getChildByTag(50 + i):addChild(maxSprite);
		end
		self.m_ccbLabelExpCount:setString("MAX");
		self.m_progressTimer:setPercentage(100);

		-- local labelPosX = self.m_ccbLabelExpCount:getPositionX();
		-- local labelPosY = self.m_ccbLabelExpCount:getPositionY();
		-- local barSprite = cc.Sprite:create(ResourceMgr:getGoldBarSprite());
		-- self.m_ccbNodeExpBar:addChild(barSprite);
		-- -- barSprite:setPosition(cc.p(labelPosX, labelPosY - 2));
		-- barSprite:setScaleX(14.3);
		-- barSprite:setScaleY(1.5);

		-- local levelMaxSprite = cc.Sprite:create(ResourceMgr:getFortMaxSprite());
		-- self.m_ccbNodeExpBar:addChild(levelMaxSprite);
		-- -- levelMaxSprite:setPosition(cc.p(labelPosX, labelPosY));
		-- levelMaxSprite:setScale(1.5);
	else
		for i = 1, 3 do 
			local upArrowSprite = cc.Sprite:create(ResourceMgr:getUpQualityArrow());
			self:getChildByTag(50 + i):addChild(upArrowSprite);
		end
		self.m_LvUpNeedExp = GameData:get("exp_grow", self.m_fortLevel).exp; --升级需要的经验值

		local barStr = string.format("%d / %d", self.m_curFortExp, self.m_LvUpNeedExp)
		self.m_ccbLabelExpCount:setString(barStr)

		self.m_progressTimer:setPercentage(self.m_curFortExp / self.m_LvUpNeedExp * 100)
	end
end

function CCBFortLevel:cleanNode()
	for i = 1, 3 do 
		self:getChildByTag(50 + i):removeAllChildren();
	end	
end

--请求炮台升级
function CCBFortLevel:requestUpgradeFort(expItemID, expItemCount, CurfortData)
	local fortId = -1;
	local originLevel = -1;
	if FortDataMgr:isUnlockFort(CurfortData.id) then 
		fortId = CurfortData.id;
		originLevel = FortDataMgr:getUnlockFortLevel(fortId);
	end
	if fortId == -1 then
		print("CCBFortLevel:requestUpgradeFort: can not get fort id") 
		return;
	end
	self.m_isRequesting = true;
	Network:request("game.fortHandler.upgradeFort", {item_id = expItemID, fort_id = fortId, count = expItemCount, ol = originLevel}, function (rc, receivedData)
		print("请求升级炮台")
		self.m_isRequesting = false;
		if receivedData["code"] ~= 1 then
			local strDesc = ServerCode[receivedData.code];
			Tips:create(strDesc);
			return
		end
		local fortID = receivedData.fort.fort_id;
		if App:getRunningScene():getChildByTag(150) then
			App:getRunningScene():getChildByTag(150):updataFortData();
			local equipFortData = FortDataMgr:getEquipFortData();
			if equipFortData[fortID] ~= nil then
				App:getRunningScene():getChildByTag(150):updataEquipFortLevel(equipFortData[fortID].pos, equipFortData[fortID].level);
			end
		end
		App:getRunningScene():getViewBase().m_ccbShipMainView:updateEquipFort(fortID);

		local updatedFortData = FortDataMgr:getFortBaseInfo(fortID);
		local name = updatedFortData.frot_name
		local level = receivedData.fort.level
		
		if originLevel < receivedData.fort.level then
			Tips:create(name.."从"..tostring(originLevel).."级升级到"..tostring(level).."级");
		end
	end)
end

-- 炮台升级经验条特效
function CCBFortLevel:fortLevelUpAnim()
	if self.m_armature == nil then
		self.m_armature = ResourceMgr:getAnimArmatureByNameOnOthers("ui_upgrade_bar01");
		self.m_armature:getAnimation():play("anim01");
		self.m_ccbNodeExpBar:addChild(self.m_armature, 3);
		self.m_armature:setScaleX(1.2);
		-- local barBgSize = self.m_ccbSpriteBarBg:getContentSize();
		-- self.m_armature:setPosition(barBgSize.width / 2, barBgSize.height / 2 - 5);
	
	else
		self.m_armature:getAnimation():play("anim01");
	end
end

-- 经验材料使用特效
function CCBFortLevel:expMaterialAnim(touchNode)
	if self.m_animInOne then
		self.m_animInOne = false;
		self.m_expArmature = ResourceMgr:getAnimArmatureByNameOnOthers("ui_upgrade_02");
		self.m_expArmature:getAnimation():play("anim01");
		touchNode:addChild(self.m_expArmature);
		self.m_expArmature:setPosition(50, 50);
		self.m_expArmature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
			if movementType == ccs.MovementEventType.start then

			elseif movementType == ccs.MovementEventType.complete then
				touchNode:removeChild(self.m_expArmature);
				self.m_animInOne = true;
			end
		end)
	end
end

return CCBFortLevel