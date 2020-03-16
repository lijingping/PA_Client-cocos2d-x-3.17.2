local ResourceMgr = require("app.utils.ResourceMgr");
local Tips = require("app.views.common.Tips");
-- local CCBShipProperty = require("app.views.shipView.CCBShipProperty");

local CCBPopupProperty = class("CCBPopupProperty", function()
	return CCBLoader("ccbi/shipView/CCBPopupProperty.ccbi")
end)

local blueColor = cc.c3b(0, 204, 255);
local greenColor = cc.c3b(0, 255, 0);
local redColor = cc.c3b(255, 0, 0);
local grayColor = cc.c3b(153, 153, 153);
local skillDescSize = cc.size(510, 90);
local equipIconPos = cc.p(12, -12);

local upgradeItemID_1 = 3901;
local upgradeItemID_2 = 3902;

local unlockScale9BgSize = cc.size(725, 570);
local unlockScale9FrameSize = cc.size(675, 500);
local lockScale9BgSize = cc.size(725, 470);
local lockScale9FrameSize = cc.size(675, 400);


function CCBPopupProperty:ctor(data)
	App:getRunningScene():addChild(self, display.Z_MESSAGE_HINT);
	self:setPosition(display.width / 2, display.height / 2);
	
	if display.resolution >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end

	local listener=cc.EventListenerTouchOneByOne:create();
	self.m_listener = listener;
	local eventDispatcher = self:getEventDispatcher();
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end,cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(self.onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
	listener:setSwallowTouches(true);

	self.m_shipData = data;
	 --  ["70001"] = {
  --   id = 70001,
  --   ship_name = "探险者",
  --   quality = 1,
  --   unlock_level = 1,
  --   unlock_item_id = 0,
  --   unlock_item_count = 0,
  --   skill_name = "孤注一掷",
	  -- skill_type = {
	  --     type_1 = "11"
	  --   },
  --   skill_desc = "全体炮台开启火力增幅状态【伤害+%s】，持续%s",
  --   skill_base_value_per = 15,
  --   last_time = 5,
  --   upgrade_base_value_per = 1,
  --   upgrade_last_time = 0.5,
  --   target = 1,
  --   fort_id1 = 90001,
  --   fort_id2 = 90002,
  --   fort_id3 = 90003,
  --   suite_attri_per = 15,
  --   time = 0
  -- }
  -- allFort
  	self.m_upgradeSituation = 0;
	self:init();
	self:setShipName(self.m_shipData.id - 70000);
	self:setShipSkillIcon(self.m_shipData.id);
	self:setShipSkillType();
	self:setShipSkillNameAndDesc();
	if self.m_isShipUnlock then
		self:setMaterialNeedIcon();
		self:setMaterialNeedLabel();
	end
	self:setShipSuit();
end

function CCBPopupProperty:onTouchBegan(touch, event)
	return true;
end

function CCBPopupProperty.onTouchEnded(touch, event)

end

function CCBPopupProperty:init()
	-- self.m_shipProperty = CCBShipProperty:create(self.m_shipData, self.m_fortData);
	-- local size = self.m_shipProperty:getContentSize();
	-- local viewSize = self.m_ccbScrollView:getViewSize();
	-- self.m_ccbScrollView:setContainer(self.m_shipProperty);	
	-- self.m_ccbScrollView:setContentOffset(cc.p(0, viewSize.height - size.height));
	self.m_isShipUnlock = ShipDataMgr:isUnlockShipSkin(self.m_shipData.id);
	self:setViewIsUnlock(self.m_isShipUnlock);
end

function CCBPopupProperty:setViewIsUnlock(isUnlock)
	if isUnlock then

	else
		self.m_ccbNodeShipUpgrade:setVisible(false);
		self.m_ccbScale9SpriteBg:setPreferredSize(lockScale9BgSize);
		self.m_ccbScale9SpriteFrame:setPreferredSize(lockScale9FrameSize);
		local nodeMoveDown = -50;
		local nodeMoveUp = 50;
		local uiTopPosY = self.m_ccbNodeUITop:getPositionY();
		self.m_ccbNodeUITop:setPositionY(uiTopPosY + nodeMoveDown);
		local uiBottomPosY = self.m_ccbNodeUIBottom:getPositionY();
		self.m_ccbNodeUIBottom:setPositionY(uiBottomPosY + nodeMoveUp);
		local propertyNodePosY = self.m_ccbNodeShipProperty:getPositionY();
		self.m_ccbNodeShipProperty:setPositionY(propertyNodePosY + nodeMoveDown - 20);
		local suitNodePosY = self.m_ccbNodeShipSuit:getPositionY();
		self.m_ccbNodeShipSuit:setPositionY(suitNodePosY + nodeMoveUp + 20);
	end
end

function CCBPopupProperty:setShipName(index)
	local nameSprite = cc.Sprite:create(ResourceMgr:getShipNameByIndex(index));
	self.m_ccbNodeShipName:addChild(nameSprite);
end

function CCBPopupProperty:setShipSkillIcon(shipID)
	local skillIcon = cc.Sprite:create(ResourceMgr:getShipSkinSkillIcon(shipID));
	skillIcon:setScale(0.8);
	self.m_ccbNodeSkinSkillIcon:addChild(skillIcon);
end

function CCBPopupProperty:setShipSkillType()
	local xLength = 0;
	for k, v in pairs(self.m_shipData.skill_type) do 
		local typeSprite = cc.Sprite:create(ResourceMgr:getFortTalentTag(v));
		self.m_ccbNodeShipSkillType:addChild(typeSprite);
		local spriteSize = typeSprite:getContentSize();
		typeSprite:setPositionX(xLength + spriteSize.width * 0.5);
		xLength = xLength + spriteSize.width + 10;
	end
end

function CCBPopupProperty:setShipSkillNameAndDesc()
	self.m_ccbNodeSkillDesc:removeAllChildren();
	local skillLevel = 1;
	if self.m_isShipUnlock then
		skillLevel = ShipDataMgr:getUnlockShipSkinSkillLv(self.m_shipData.id);
	end
	local str = string.format(Str[7200], self.m_shipData.skill_name, skillLevel);
	self.m_ccbLabelSkinSkillName:setString(str);

	local skillDesc = self.m_shipData.skill_desc;
	-- dump(self.m_shipData);
	-- print("   skillDesc .. ", skillDesc);
	local skillValue = self.m_shipData.skill_base_value_per+(skillLevel - 1) * self.m_shipData.upgrade_base_value_per;
	local skillTime = self.m_shipData.last_time + (skillLevel - 1) * self.m_shipData.upgrade_last_time;
	-- dump(shipInfo);
	-- 标记技能参数类型
	local markSkillArgType = 0; 
	local skillStr = "";
	if self.m_shipData.skill_base_value_per ~= 0 and self.m_shipData.last_time == 0 then
		markSkillArgType = 1;
		skillStr = string.format(skillDesc, skillValue .. "%|");
	elseif self.m_shipData.skill_base_value_per ~= 0 and self.m_shipData.last_time ~= 0 then
		markSkillArgType = 2;
		skillStr = string.format(skillDesc, skillValue .. "%|", skillTime .. Str[10006] .. "|");
	elseif self.m_shipData.skill_base_value_per == 0 and self.m_shipData.last_time ~= 0 then
		markSkillArgType = 3;
		skillStr = string.format(skillDesc, skillTime .. Str[10006] .. "|");
	end
	-- print("    markSkillArgType ... : ", markSkillArgType);
	-- print("    skillDDDDDD:    ", skillStr);
	local richText = ccui.RichText:create();
	richText:ignoreContentAdaptWithSize(false);
	richText:setSize(skillDescSize);
	richText:setAnchorPoint(cc.p(0, 1));

	local textCount = 0;
	local descSplitTable = string.split(skillStr, "|");
	for i = 1, #descSplitTable do
		textCount = textCount + 1;
		local text = ccui.RichElementText:create(textCount, blueColor, 255, descSplitTable[i], "", 14);
		richText:pushBackElement(text);
		if self.m_isShipUnlock then
			-- 富文本一定要顺序？
			if i < #descSplitTable then
				textCount = textCount + 1;
				if skillLevel < 10 then
					if markSkillArgType == 1 then
						local valueStr = string.format(Str[7201], self.m_shipData.upgrade_base_value_per .. "%");
						local upValueText = ccui.RichElementText:create(textCount, greenColor, 255, valueStr, "", 14);
						richText:pushBackElement(upValueText);
					elseif markSkillArgType == 3 then
						local timeStr = string.format(Str[7201], self.m_shipData.upgrade_last_time .. Str[10006]);
						local upTimeText = ccui.RichElementText:create(textCount, greenColor, 255, timeStr, "", 14);
						richText:pushBackElement(upTimeText);
					elseif markSkillArgType == 2 then
						local greenText;
						if i == 1 then
							local valueStr = string.format(Str[7201], self.m_shipData.upgrade_base_value_per .. "%");
							greenText = ccui.RichElementText:create(textCount, greenColor, 255, valueStr, "", 14);
							richText:pushBackElement(greenText);	
						elseif i == 2 then
							local timeStr = string.format(Str[7201], self.m_shipData.upgrade_last_time .. Str[10006]);
							greenText = ccui.RichElementText:create(textCount, greenColor, 255, timeStr, "", 14);
							richText:pushBackElement(greenText);
						end
					end
				else
					local greenMaxText = ccui.RichElementText:create(textCount, greenColor, 255, "（MAX）", "", 14);
					richText:pushBackElement(greenMaxText);
				end
			end
		end
	end
	self.m_ccbNodeSkillDesc:addChild(richText);
end

function CCBPopupProperty:setMaterialNeedIcon()
	local item1Quality = ItemDataMgr:getItemLevelByID(upgradeItemID_1) + 1;
	local item1IconBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(item1Quality));
	local item1Icon = cc.Sprite:create(ResourceMgr:getItemIconByID(upgradeItemID_1))
	local item1IconFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(item1Quality));
	self.m_ccbNodeNeedItem_1:addChild(item1IconBg);
	self.m_ccbNodeNeedItem_1:addChild(item1Icon);
	self.m_ccbNodeNeedItem_1:addChild(item1IconFrame);
	local item1Name = ItemDataMgr:getItemNameByID(upgradeItemID_1);
	self.m_ccbLabelItemName1:setString(item1Name);

	local item2Quality = ItemDataMgr:getItemLevelByID(upgradeItemID_2) + 1;
	local item2IconBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(item2Quality));
	local item2Icon = cc.Sprite:create(ResourceMgr:getItemIconByID(upgradeItemID_2));
	local item2IconFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(item2Quality));
	self.m_ccbNodeNeedItem_2:addChild(item2IconBg);
	self.m_ccbNodeNeedItem_2:addChild(item2Icon);
	self.m_ccbNodeNeedItem_2:addChild(item2IconFrame);
	local item2Name = ItemDataMgr:getItemNameByID(upgradeItemID_2);
	self.m_ccbLabelItemName2:setString(item2Name);
end

function CCBPopupProperty:setMaterialNeedLabel()
	if self.m_isShipUnlock then
		local skillLevel = ShipDataMgr:getUnlockShipSkinSkillLv(self.m_shipData.id);
		if skillLevel < 10 then
			local nextShipGrowData = ShipDataMgr:getSkillGrowData(skillLevel + 1);
			local item1Count = ItemDataMgr:getItemCount(upgradeItemID_1);
			local item2Count = ItemDataMgr:getItemCount(upgradeItemID_2);
			self.m_ccbLabelNeedItem1:setString(item1Count);
			self.m_ccbLabelNeedItem2:setString(item2Count);
			self.m_ccbLabelLimitItemCount_1:setString("/" .. nextShipGrowData.upgrade_item1);
			self.m_ccbLabelLimitItemCount_2:setString("/" .. nextShipGrowData.upgrade_item2);
			
			self.m_ccbLabelConsumeGlod:setString(nextShipGrowData.cost_coin);
			if UserDataMgr:getPlayerGoldCoin() < nextShipGrowData.cost_coin then
				self.m_upgradeSituation = 2;
			end
			if item1Count < nextShipGrowData.upgrade_item1 then
				self.m_upgradeSituation = 1;
				self.m_ccbLabelNeedItem1:setTextColor(redColor);
			end
			if item2Count < nextShipGrowData.upgrade_item2 then
				self.m_upgradeSituation = 1;
				self.m_ccbLabelNeedItem2:setTextColor(redColor);
			end
		else 
			self.m_ccbNodeUpgradeMaterial:setVisible(false);
			local maxViewSprite = cc.Sprite:create(ResourceMgr:getViewLabelMax());
			self.m_ccbNodeShipUpgrade:addChild(maxViewSprite);
		end
	end
end

function CCBPopupProperty:setShipSuit()
	local countSuitFort = 0;
	local equipFortData = FortDataMgr:getEquipFortData();
	for i = 1, 3 do 
		local fortIndex = "fort_id" .. i;
		local fortID = self.m_shipData[fortIndex];
		local fortQuality = 1;
		local isFortUnlock = FortDataMgr:isUnlockFort(fortID);
		if isFortUnlock then
			fortQuality = FortDataMgr:getUnlockFortQuality(fortID);
		end
		local fortIconBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(fortQuality));
		local fortIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(fortID));
		local fortIconFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(fortQuality));
		self.m_ccbNodeShipSuit:getChildByTag(i):getChildByTag(1):addChild(fortIconBg);
		self.m_ccbNodeShipSuit:getChildByTag(i):getChildByTag(1):addChild(fortIcon);
		self.m_ccbNodeShipSuit:getChildByTag(i):getChildByTag(1):addChild(fortIconFrame);
		if isFortUnlock then
			if equipFortData[fortID] ~= nil then
				countSuitFort = countSuitFort + 1;
				local equipSprite = cc.Sprite:create(ResourceMgr:getMarkEquipSprite());
				equipSprite:setPosition(equipIconPos);
				self.m_ccbNodeShipSuit:getChildByTag(i):getChildByTag(2):addChild(equipSprite);
			else
				local getSprite = cc.Sprite:create(ResourceMgr:getShipSuitFortUnlockTitle());
				self.m_ccbNodeShipSuit:getChildByTag(i):getChildByTag(2):addChild(getSprite);
			end
		else
			local lockSprite = cc.Sprite:create(ResourceMgr:getShipSuitFortLockTitle());
			self.m_ccbNodeShipSuit:getChildByTag(i):getChildByTag(2):addChild(lockSprite);
		end
		local fortName = FortDataMgr:getFortBaseName(fortID);
		self.m_ccbNodeShipSuit:getChildByTag(10 + i):setString(fortName);
	end
	local suitDesc = string.format(Str[7202], self.m_shipData.suite_attri_per .. "%  ");
	if self.m_isShipUnlock then
		self.m_ccbLabelCountEquip:setString(string.format(Str[7203], countSuitFort));
		if countSuitFort == 3 then
			suitDesc = suitDesc .. Str[7204];
			self.m_ccbLabelShipSuit:setColor(greenColor);
		else
			suitDesc = suitDesc .. Str[7205];
			self.m_ccbLabelShipSuit:setColor(grayColor);
		end
	else
		self.m_ccbLabelCountEquip:setString("");
		self.m_ccbLabelShipSuit:setColor(grayColor);
	end
	self.m_ccbLabelShipSuit:setString(suitDesc);

end

function CCBPopupProperty:updateShipProperty()
	-- self.m_shipProperty:updateShipProperty(self.m_shipData, self.m_fortData);
	self:setShipSkillNameAndDesc();
	self:setMaterialNeedLabel();
end

function CCBPopupProperty:onBtnUpgrade()
	if self.m_upgradeSituation == 1 then
		Tips:create(Str[7206]);
	elseif self.m_upgradeSituation == 2 then
		Tips:create(Str[4031]);
	else
		Network:request("game.shipHandler.upgradeShipSkill", {ship_id = self.m_shipData.id}, function (rc, receivedData)
			print("请求升级战舰皮肤技能")
			dump(receivedData);
			if receivedData["code"] ~= 1 then
				Tips:create(ServerCode[receivedData.code]);
				return
			end

			ShipDataMgr:setShipSkinData(receivedData["ship"]);
			self:updateShipProperty();
			self:playUpShipSkillAnim();
		end)
	end
end

function CCBPopupProperty:playUpShipSkillAnim()
	-- print("    CCBFortQuality:playUpQualityAnim() 播放品质提升动画   ");
	local upShipSkillAnim = ResourceMgr:getCommonArmature("common_up");
	-- App:getRunningScene():addChild(upShipSkillAnim, 200, 200);
	upShipSkillAnim:setPosition(display.center);
	self:addChild(upShipSkillAnim);
	upShipSkillAnim:getAnimation():play("anim01");
	upShipSkillAnim:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			upShipSkillAnim:removeSelf();
			upShipSkillAnim = nil;
		end
	end);
end

function CCBPopupProperty:onBtnClose()
	-- self:getParent().m_popupView = nil;
	self:removeSelf();
end

return CCBPopupProperty