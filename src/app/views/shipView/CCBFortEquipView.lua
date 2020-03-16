local ResourceMgr = require("app.utils.ResourceMgr");
local Tips = require("app.views.common.Tips");
local CCBFortMainCell = require("app.views.shipView.CCBFortMainCell");
local CCBFortView = require("app.views.shipView.CCBFortView");
local CCBCommonGetPath = require("app.views.commonCCB.CCBCommonGetPath");

local CCBFortEquipView = class("CCBFortEquipView", function()
	return CCBLoader("ccbi/shipView/CCBFortEquipView.ccbi")
end)

local nodeMoveX = 160;
local fortManageLeftPosX = 308;
local fortManageCenterPosX = 402;

local btnAllFortPos = cc.p(-202, 170);
local btnAttackFortPos = cc.p(-202, 40);
local btnDefFortPos = cc.p(-202, -90);
local btnSkillFortPos = cc.p(-202, -220);
local btnPosY = {[1] = 170, [2] = 40, [3] = -90, [4] = -220};

local manageState = 1;
local equipState = 2;
local itemIconPos = cc.p(58, 74);

function CCBFortEquipView:ctor(state, shipData, allData, atkFortData, defFortData, skillFortData)
	App:getRunningScene():addChild(self, display.Z_BLURLAYER, 150);
	self:setPosition(cc.p(display.cx, display.cy));

	if display.resolution >= 2 then
		self.m_ccbNodeEquipFort:setScale(display.reduce);
		self.m_ccbNodeCenterPart:setScale(display.reduce);
		self.m_ccbBtnClose:setScale(display.reduce);
	end

	self.m_loadFortData = {};  -- tableview加载的炮台列表

	self.m_ccbNodeEquipFort:setCascadeOpacityEnabled(true);
	for i = 1, 3 do 
		self.m_ccbNodeEquipFort:getChildByTag(i):setCascadeOpacityEnabled(true);
		self.m_ccbNodeEquipFort:getChildByTag(i):getChildByTag(1):setCascadeOpacityEnabled(true);
	end
	self.m_ccbNodeFortIcon1:setCascadeOpacityEnabled(true);
	self.m_ccbNodeFortIcon2:setCascadeOpacityEnabled(true);
	self.m_ccbNodeFortIcon3:setCascadeOpacityEnabled(true);

	self:createTouchEvent();
	self:createSwallowTouchEvent();

	self.m_state = state;
	self.m_buttonState = 0;
	self.m_shipData = shipData;
	-- 交换状态
	self.m_isFortChange = false;
	self.m_selectFortID = 0;
	FortDataMgr:setSelectedFort(0);

	self.m_allFortData = allData;
	self:sortTableSuitData();
	self.m_atkFortData = atkFortData;
	table.sort(self.m_atkFortData, function(a, b)
		return a.id < b.id;
	end);

	self.m_defFortData = defFortData;
	table.sort(self.m_defFortData, function(a, b)
		return a.id < b.id;
	end);

	self.m_skillFortData = skillFortData;
	table.sort(self.m_skillFortData, function(a, b)
		return a.id < b.id;
	end);
	self:getUnlockFortData();

	self.m_fortSkillDesc = "";
	self.m_fortAdvanceItemID = 0;
	self.m_itemPosInTableNode = cc.p(0, 0);  -- 点击的itemNode在tableview里面node的位置。

	-- 创建炮台信息介绍中的进阶材料进度条
	local barSprite = cc.Sprite:create(ResourceMgr:getFortAdvanceMaterialBar());
	-- barSprite:setScale(0.8);
	self.m_advanceMaterialBar = cc.ProgressTimer:create(barSprite);
	self.m_advanceMaterialBar:setType(cc.PROGRESS_TIMER_TYPE_BAR);
	self.m_advanceMaterialBar:setPercentage(0);
	self.m_advanceMaterialBar:setBarChangeRate(cc.p(1, 0));
	self.m_advanceMaterialBar:setMidpoint(cc.p(0, 0));
	self.m_ccbNodeProgressTimer:addChild(self.m_advanceMaterialBar);
	self.m_advanceMaterialBar:setScale(0.8);

	if self.m_state == manageState then
		self.m_ccbNodeEquipFort:setVisible(false);
		self.m_ccbNodeCenterPart:setPositionX(display.center.x - nodeMoveX);
		self.m_ccbSpriteTipEquip:setVisible(false);
		self.m_loadFortData = self.m_allFortData;
		self:setFortDetailData(self.m_loadFortData[1].id);
		FortDataMgr:setSelectedFort(self.m_loadFortData[1].id);
		
		-- self.m_ccbNodeToManageBtn:setVisible(false);
	elseif self.m_state == equipState then
		self:detailBackToEquipOriginail();
		self.m_loadFortData = self.m_unlockFort;
		FortDataMgr:setSelectedFort(0);
	end

	

	self:setButton(1);
	self:setEquipFort();

	self:createTableView();

	local offset = self.m_fortTableView:getContentOffset();
	if self.m_state == manageState then
		self.m_itemPosInTableNode = cc.p(0 + itemIconPos.x - offset.x, 10 + itemIconPos.y + self.m_tableSize.height - 145 - offset.y);  -- 145  是cell height  10 为item在cell里面的坐标
	end
end

function CCBFortEquipView:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(false);
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event); end, cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event); end, cc.Handler.EVENT_TOUCH_MOVED);
	listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event); end, cc.Handler.EVENT_TOUCH_ENDED);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbNodeTouch);
end

function CCBFortEquipView:onTouchBegan(touch, event)
	self.m_touchBegin = touch:getLocation();
	return true;
end

function CCBFortEquipView:onTouchMoved(touch, event)
end

function CCBFortEquipView:onTouchEnded(touch, event)
end

function CCBFortEquipView:createSwallowTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return self:onSwallowTouchBegan(touch, event); end, cc.Handler.EVENT_TOUCH_BEGAN);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerColor);
end

function CCBFortEquipView:onSwallowTouchBegan(touch, event)
	return true;
end


function CCBFortEquipView:setEquipFort()
	local equipFortData = FortDataMgr:getEquipFortData();
		-- dump(equipFortData);
 --  "<var>" = {
 --     90002 = {
 --         "fort_id"  = 90002
 --         "isMe"     = true
 --         "level"    = 1
 --         "pos"      = 1
 --         "skill_id" = 50002
 --     }
 --     90003 = {
 --         "fort_id"  = 90003
 --         "isMe"     = true
 --         "level"    = 1
 --         "pos"      = 2
 --         "skill_id" = 50003
 --     }
 --     90007 = {
 --         "fort_id"  = 90007
 --         "isMe"     = true
 --         "level"    = 1
 --         "pos"      = 0
 --         "skill_id" = 50007
 --     }
 -- }
 	for k, v in pairs(equipFortData) do
 		self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):getChildByTag(1):removeAllChildren();
 		local quality = FortDataMgr:getUnlockFortQuality(v.fort_id);
 		local fortIconBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(quality));
 		local fortIcon = cc.Sprite:create(ResourceMgr:getFortIconByID(v.fort_id));
 		local fortIconFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(quality));
 		local fortIconQuality = cc.Sprite:create(ResourceMgr:getFortQualitySpriteByQualityNumber(quality));
 		self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):getChildByTag(1):addChild(fortIconBg);
 		self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):getChildByTag(1):addChild(fortIcon);
 		self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):getChildByTag(1):addChild(fortIconFrame);
 		self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):getChildByTag(1):addChild(fortIconQuality);
 		fortIconQuality:setPosition(cc.p(-38, 38));
 		for i = 1, 3 do 
 			local suitFort = "fort_id" .. i;
 			if self.m_shipData[suitFort] == v.fort_id then
 				local fortIconSuit = cc.Sprite:create(ResourceMgr:getFortSuitLogo());
 				self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):getChildByTag(1):addChild(fortIconSuit);
 				fortIconSuit:setPosition(cc.p(-15, -1));
 				break;
 			end
 		end
 		local levelLabel = cc.LabelTTF:create();
 		levelLabel:setString("Lv." .. v.level);
 		levelLabel:setFontSize(16);
 		levelLabel:setPosition(cc.p(0, -38));
 		self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):getChildByTag(1):addChild(levelLabel, 1, 3);

 		local changeSign = cc.Sprite:create(ResourceMgr:getChangeSign());
 		self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):getChildByTag(1):addChild(changeSign, 1, 1);
 		changeSign:setVisible(false);

 		local selectFrame = cc.Sprite:create(ResourceMgr:getItemSelectFrame());
 		self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):getChildByTag(1):addChild(selectFrame, 2, 2);
 		selectFrame:setVisible(false);
 	end
end

function CCBFortEquipView:getUnlockFortData()
	local unlockFort = table.clone(FortDataMgr:getUnlockFortData());
	self.m_unlockFort = {};
	self.m_unlockAtkFort = {};
	self.m_unlockDefFort = {};
	self.m_unlockSkillFort = {};
	    -- 90001 = {
     --     "exp"         = 0
     --     "id"          = 90001
     --     "level"       = 1
     --     "quality"     = 1
     --     "skill_id"    = 50001
     --     "skill_level" = 1
     -- }

	for k, v in pairs(unlockFort) do 
		table.insert(self.m_unlockFort, v);
		local fortType = FortDataMgr:getFortBaseType(v.id);
		if fortType == 1 then
			table.insert(self.m_unlockAtkFort, v);
		elseif fortType == 2 then
			table.insert(self.m_unlockDefFort, v);
		elseif fortType == 3 then
			table.insert(self.m_unlockSkillFort, v);
		end
	end
	self:sortUnlockAllFort();
	table.sort(self.m_unlockAtkFort, function(a, b)
		return a.id < b.id;
	end);
	table.sort(self.m_unlockDefFort, function(a, b)
		return a.id < b.id;
	end);
	table.sort(self.m_unlockSkillFort, function(a, b)
		return a.id < b.id;
	end);
end

function CCBFortEquipView:sortUnlockAllFort()
	local equipForts = FortDataMgr:getEquipFortData();
	-- dump(equipForts);
	for k, v in pairs(self.m_unlockFort) do
		self.m_unlockFort[k].sort = 0;
		if v.id == self.m_shipData.fort_id1 
			or v.id == self.m_shipData.fort_id2 
			or v.id == self.m_shipData.fort_id3 then
			self.m_unlockFort[k].sort = 100 + v.id;
		else
			self.m_unlockFort[k].sort = 300 + v.id;
			if equipForts[v.id] then
				self.m_unlockFort[k].sort = self.m_unlockFort[k].sort - 100;
			end
		end
	end
	table.sort(self.m_unlockFort, function(a, b) return a.sort < b.sort; end);
end

function CCBFortEquipView:createTableView()
	self.m_tableSize = self.m_ccbNodeFortTableView:getContentSize();
	self.m_fortTableView = cc.TableView:create(self.m_tableSize);
	self.m_fortTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	self.m_fortTableView:setDelegate();
	self.m_fortTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN);
	self.m_ccbNodeFortTableView:addChild(self.m_fortTableView);

	self.m_fortTableView:registerScriptHandler(function (table, cell) self:tableCellTouched(table, cell); end, cc.TABLECELL_TOUCHED);
	self.m_fortTableView:registerScriptHandler(function (table, idx) return self:cellSizeForTable(table, idx); end, cc.TABLECELL_SIZE_FOR_INDEX);
	self.m_fortTableView:registerScriptHandler(function (table, idx) return self:tableCellAtIndex(table, idx); end, cc.TABLECELL_SIZE_AT_INDEX);
	self.m_fortTableView:registerScriptHandler(function (table) return self:numberOfCellsInTableView(table); end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);
	self.m_fortTableView:reloadData();
end

function CCBFortEquipView:tableCellTouched(table, cell)
	local cellPos = cell:convertToNodeSpace(self.m_touchBegin);

	local listItem1 = cell:getChildByTag(100);
	local listItem2 = cell:getChildByTag(101);

	local  itemNode = nil;
	local fortID = 0;

	if listItem1:isVisible() and cc.rectContainsPoint(listItem1:getBoundingBox(), cellPos) then
		itemNode = listItem1;
		fortID = listItem1:getFortID();
	elseif listItem2:isVisible() and cc.rectContainsPoint(listItem2:getBoundingBox(), cellPos) then
		itemNode = listItem2;
		fortID = listItem2:getFortID();
	else
		return;
	end 

	local posX = itemNode:getPositionX();
	local posY = itemNode:getPositionY();
	local spacePos = cell:convertToWorldSpace(cc.p(posX, posY));
	local nodePos = self.m_ccbNodeFortTableView:convertToNodeSpace(spacePos);
	local touchItemPos = cc.p(nodePos.x + itemNode.m_ccbNodeFortIcon:getPositionX(), nodePos.y + itemNode.m_ccbNodeFortIcon:getPositionY());

	if fortID == FortDataMgr:getSelectedFort() then
		return;
	end

	if self.m_state == equipState then
		if not self.m_ccbNodeDetailContent:isVisible() then
			self.m_ccbNodeDetailContent:setVisible(true);
		end
		if self.m_ccbSpriteTipEquip:isVisible() then
			self.m_ccbSpriteTipEquip:setVisible(false);
		end

		self:showFortChangeSign(fortID);
	end

	self:setFortDetailData(fortID);
	FortDataMgr:setSelectedFort(fortID);

	local offset = table:getContentOffset();
	self.m_tableOffset = offset;

	self.m_itemPosInTableNode = cc.p(touchItemPos.x - self.m_tableOffset.x, touchItemPos.y - self.m_tableOffset.y);
	table:reloadData();
	table:setContentOffset(offset);
end

function CCBFortEquipView:cellSizeForTable(table, idx)
	return self.m_tableSize.width, 145;
end

function CCBFortEquipView:tableCellAtIndex(table, idx)
	local listItem1 = nil;
	local listItem2 = nil;
	local cell = table:dequeueCell();
	if cell == nil then
		cell = cc.TableViewCell:new();
		listItem1 = CCBFortMainCell:create();
		cell:addChild(listItem1);
		listItem1:setPosition(cc.p(0, 10));
		listItem1:setTag(100);
		listItem1:setData(self.m_loadFortData[idx * 2 + 1], self.m_shipData);

		listItem2 = CCBFortMainCell:create();
		cell:addChild(listItem2);
		listItem2:setPosition(cc.p(135, 10));
		listItem2:setTag(101);
		if self.m_loadFortData[idx * 2 + 2] ~= nil then
			listItem2:setData(self.m_loadFortData[idx * 2 + 2], self.m_shipData);
		else
			listItem2:setVisible(false);
		end
	else
		listItem1 = cell:getChildByTag(100);
		listItem1:setData(self.m_loadFortData[idx * 2 + 1], self.m_shipData);

		listItem2 = cell:getChildByTag(101);
		if self.m_loadFortData[idx * 2 + 2] ~= nil then -- 不可以用这个 cell:getChildByTag(101)
			listItem2:setVisible(true);
			listItem2:setData(self.m_loadFortData[idx * 2 + 2], self.m_shipData);
		else
			listItem2:setVisible(false);
		end
	end
	return cell;
end

function CCBFortEquipView:numberOfCellsInTableView(table)
	return math.ceil(#self.m_loadFortData / 2);
end

function CCBFortEquipView:setButton(number)
	self.m_buttonState = number;
	for i = 1, 4 do
		if number == i then
			self.m_ccbNodeCenterPart:getChildByTag(i):setEnabled(false);
			self.m_ccbSpriteMarkType:setPositionY(btnPosY[i]);
		else
			self.m_ccbNodeCenterPart:getChildByTag(i):setEnabled(true);
		end
	end
	self:setFortListTitleSprite(number);
end

function CCBFortEquipView:setFortListTitleSprite(type)
	self.m_ccbNodeFortTypeTitle:removeAllChildren();
	local titleSprite = cc.Sprite:create(ResourceMgr:getFortListTitleSprite(type));
	self.m_ccbNodeFortTypeTitle:addChild(titleSprite);
end

function CCBFortEquipView:setFortDetailData(fortID)
	-- 按钮
	local isFortUnlock = FortDataMgr:isUnlockFort(fortID);
	if self.m_state == manageState then
		self.m_ccbNodeToManageBtn:setVisible(false);
		self.m_ccbNodeToEquipBtn:setVisible(true);
		if isFortUnlock then
			self.m_ccbNodeToStrongBtn:setVisible(true);
			self.m_ccbNodeToEquipBtn:setPositionX(fortManageLeftPosX);
		else
			self.m_ccbNodeToStrongBtn:setVisible(false);
			self.m_ccbNodeToEquipBtn:setPositionX(fortManageCenterPosX);
		end
	elseif self.m_state == equipState then
		self.m_ccbNodeToManageBtn:setVisible(true);
		self.m_ccbNodeToEquipBtn:setVisible(false);
		self.m_ccbNodeToManageBtn:setPositionX(fortManageLeftPosX);
		if not self.m_ccbNodeToStrongBtn:isVisible() then
			self.m_ccbNodeToStrongBtn:setVisible(true);
		end
	end
	if FortDataMgr:getSelectedFort() == fortID then
		return;
	end
	self:cleanDetailNode();
	local fortLevel = 1;
	local quality = 1;
	local skillID = FortDataMgr:getFortBaseInfo(fortID).skill_id;
	local skillLevel = 1;
	
	if isFortUnlock then
		fortLevel = FortDataMgr:getUnlockFortLevel(fortID);
		quality = FortDataMgr:getUnlockFortQuality(fortID);
		skillLevel = FortDataMgr:getUnlockFortSkillLevel(fortID);
	end
	-- 炮台名称
	self.m_ccbLabelFortName:setString(FortDataMgr:getFortBaseName(fortID));
	-- 图标
	local fortIconBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(quality));
	local fortIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(fortID));
	local fortIconFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(quality));
	self.m_ccbNodeDetailFortIcon:addChild(fortIconBg);
	self.m_ccbNodeDetailFortIcon:addChild(fortIcon);
	self.m_ccbNodeDetailFortIcon:addChild(fortIconFrame);

	for i = 1, 3 do 
		local suitFort = "fort_id" .. i;
		if self.m_shipData[suitFort] == fortID then
			local suitSprite = cc.Sprite:create(ResourceMgr:getFortSuitLogo());
			suitSprite:setPosition(cc.p(-15, -1));
			self.m_ccbNodeDetailFortIcon:addChild(suitSprite);
			break;
		end
	end
	local fortIconQuality = cc.Sprite:create(ResourceMgr:getFortQualitySpriteByQualityNumber(quality))
	fortIconQuality:setPosition(-38, 38);
	self.m_ccbNodeDetailFortIcon:addChild(fortIconQuality);

	local levelLabel = cc.LabelTTF:create();
	levelLabel:setFontSize(16);
	levelLabel:setString("Lv." .. fortLevel);
	levelLabel:setPosition(cc.p(0, -38));
	self.m_ccbNodeDetailFortIcon:addChild(levelLabel);

	-- 生命
	local hp = math.ceil(FortDataMgr:healthPoint(fortID, fortLevel));
	self.m_ccbLabelDetailHp:setString(hp);
	-- 攻击
	local atk = math.ceil(FortDataMgr:attack(fortID, fortLevel));
	self.m_ccbLabelDetailAck:setString(atk);
	-- 防御
	local defence = math.ceil(FortDataMgr:defence(fortID, fortLevel));
	self.m_ccbLabelDetailDefence:setString(defence);

	local skillData = FortDataMgr:getSkillInfoBySkillID(skillID);
	-- 技能类型
	local allTagSize = 0;
	local tagCount = 0;
	for k, v in pairs(skillData.skill_type) do 
		local tagSprite = cc.Sprite:create(ResourceMgr:getFortTalentTag(v));
		self.m_ccbNodeSkillType:addChild(tagSprite);
		local spriteSize = tagSprite:getContentSize();
		tagSprite:setPositionX(allTagSize + spriteSize.width * 0.5 + tagCount * 10);
		allTagSize = allTagSize + spriteSize.width + tagCount * 10;
		tagCount = tagCount + 1;
	end

	self:setDetailSkillDesc(skillID, skillLevel);

	local advanceItemID = FortDataMgr:getFortBaseInfo(fortID).advance_item;
	self.m_fortAdvanceItemID = advanceItemID;
	local advanceItemQuality = ItemDataMgr:getItemLevelByID(advanceItemID);
	local advanceItemBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(advanceItemQuality + 1));
	local advanceItemIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(advanceItemID));
	local advanceItemFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(advanceItemQuality + 1));
	self.m_ccbNodeMaterialIcon:addChild(advanceItemBg);
	self.m_ccbNodeMaterialIcon:addChild(advanceItemIcon);
	self.m_ccbNodeMaterialIcon:addChild(advanceItemFrame);
	local materialNeed = 0;
	local materialHave = ItemDataMgr:getItemCount(advanceItemID);
	local advanceData = FortDataMgr:getAdvanceInfo();

	self.m_isMaterialEnough = false;
	if isFortUnlock then
		if quality < 5 then
			materialNeed = advanceData[tostring(quality + 1)].consume_item;
			local strCount = materialHave .. "/" .. materialNeed;
			self.m_ccbLabelMaterialCount:setString(strCount);
			if materialNeed > materialHave then -- 不足
				self.m_advanceMaterialBar:setPercentage((materialHave / materialNeed) * 100);
				self.m_ccbBtnUnlockOrGain:setVisible(true);
				self.m_ccbBtnAdvance:setVisible(false);
				local gainTitle = cc.Sprite:create(ResourceMgr:getBtnGainTitle());
				self.m_ccbNodeBtnDesc:addChild(gainTitle);
			else
				self.m_isMaterialEnough = true;
				self.m_advanceMaterialBar:setPercentage(100);
				self.m_ccbBtnUnlockOrGain:setVisible(false);
				self.m_ccbBtnAdvance:setVisible(true);
				local advanceTitle = cc.Sprite:create(ResourceMgr:getBtnAdvanceTitle());
				self.m_ccbNodeBtnDesc:addChild(advanceTitle);
			end
		else
			self.m_ccbLabelMaterialCount:setString("MAX");
			self.m_advanceMaterialBar:setPercentage(100);
			self.m_ccbBtnUnlockOrGain:setVisible(false);
			self.m_ccbBtnAdvance:setVisible(false);
		end
	else
		self.m_ccbBtnAdvance:setVisible(false);
		self.m_ccbBtnUnlockOrGain:setVisible(true);
		materialNeed = advanceData[tostring(1)].consume_item;
		self.m_ccbLabelMaterialCount:setString(materialHave .. "/" .. materialNeed);
		if materialNeed > materialHave then
			self.m_advanceMaterialBar:setPercentage((materialHave / materialNeed) * 100);
			local gainTitle = cc.Sprite:create(ResourceMgr:getBtnGainTitle());
			self.m_ccbNodeBtnDesc:addChild(gainTitle);
		else
			self.m_isMaterialEnough = true;
			self.m_advanceMaterialBar:setPercentage(100);
			local unlockTitle = cc.Sprite:create(ResourceMgr:getBtnUnlockTitle());
			self.m_ccbNodeBtnDesc:addChild(unlockTitle);
		end
	end
	
end

function CCBFortEquipView:setDetailSkillDesc(skillID, skillLevel)
	-- 技能名称
	local labelOriginalSize = self.m_ccbLabelFortSkillName:getContentSize();
	local skillData = FortDataMgr:getSkillInfoBySkillID(skillID);
	local skillName = skillData.name;
	self.m_ccbLabelFortSkillName:setString(skillName .. "（Lv." .. skillLevel .. "）");
	local labelNowSize = self.m_ccbLabelFortSkillName:getContentSize();
	local widthAdd = labelNowSize.width - labelOriginalSize.width;   -- 给节点右移的距离

	local talentNodePos = self.m_ccbNodeSkillType:getPositionX();
	self.m_ccbNodeSkillType:setPositionX(talentNodePos + widthAdd);

	local skillDesc = skillData.desc;
	local skillDescNum = {};
	local tableCount = {};
	local skillDamage = FortDataMgr:getSkillDamageDesc(skillID, skillLevel);
	-- 技能描述
	local buffHitRate = FortDataMgr:getSkillBuffHitRate(skillID, skillLevel);
	skillDescNum[1] = buffHitRate;
	local buffEffect = FortDataMgr:getSkillBuffEffect(skillID, skillLevel);
	skillDescNum[2] = buffEffect;
	local effectTime = FortDataMgr:getSkillEffectTime(skillID, skillLevel);
	skillDescNum[3] = effectTime;
	for i = 1, 3 do
		if skillDescNum[i] ~= nil then
			table.insert(tableCount, skillDescNum[i]); 
		end
	end
	local str;
	if #tableCount == 0 then
		str = string.format(skillDesc, skillDamage);
		self.m_ccbLabelSkillDesc:setString(str);
	elseif #tableCount == 1 then
		if buffHitRate == 100 then
			str = string.format(skillDesc, skillDamage, tableCount[2]);
		else
			str = string.format(skillDesc, skillDamage, tableCount[1]);
		end
		self.m_ccbLabelSkillDesc:setString(str);
	elseif #tableCount == 2 then
		if buffHitRate == 100 then
			str = string.format(skillDesc, skillDamage, tableCount[2], tableCount[3]);
		else
			str = string.format(skillDesc, skillDamage, tableCount[1], tableCount[2]);
		end
		self.m_ccbLabelSkillDesc:setString(str);
	elseif #tableCount == 3 then
		if buffHitRate == 100 then
			str = string.format(skillDesc, skillDamage, tableCount[2], tableCount[3]);
		else
			str = string.format(skillDesc, skillDamage, tableCount[1], tableCount[2], tableCount[3]);
		end
		self.m_ccbLabelSkillDesc:setString(str); 
	end
	self.m_fortSkillDesc = str;
end

function CCBFortEquipView:updataFortViewSkillDesc()
	if self:getChildByTag(150) then
		self:getChildByTag(150):setFortSkillDesc(self.m_fortSkillDesc);
	end
end

function CCBFortEquipView:updataFortData()
	self:reloadTableViewDataWithOffset();
	-- self:setEquipFort();
	if self.m_ccbNodeDetailContent:isVisible() then
		local fortID = FortDataMgr:getSelectedFort();
		FortDataMgr:setSelectedFort(0);
		self:setFortDetailData(fortID);
		FortDataMgr:setSelectedFort(fortID);
	end

	if self:getChildByTag(150) then
		print("update 更新 详细介绍区。");
		for k, v in pairs(self.m_allFortData) do 
			if v.id == FortDataMgr:getSelectedFort() then
				self:getChildByTag(150):setData(v, self.m_shipData, true);
				break;
			end
		end
	end
end

function CCBFortEquipView:updataEquipFortLevel(pos, level)
	self.m_ccbNodeEquipFort:getChildByTag(pos + 1):getChildByTag(1):getChildByTag(3):setString("Lv." .. level);
end

-- 清除介绍页面节点
function CCBFortEquipView:cleanDetailNode()
	self.m_ccbNodeDetailFortIcon:removeAllChildren();
	self.m_ccbNodeSkillType:removeAllChildren();
	self.m_ccbNodeMaterialIcon:removeAllChildren();
	self.m_ccbNodeBtnDesc:removeAllChildren();
end

-- 恢复详细页面提示装备炮台
function CCBFortEquipView:detailBackToEquipOriginail()
	self.m_ccbNodeDetailContent:setVisible(false);
	self.m_ccbSpriteTipEquip:setVisible(true);
	self.m_ccbNodeToManageBtn:setVisible(true);
	self.m_ccbNodeToManageBtn:setPositionX(fortManageCenterPosX);
end

-- 显示装备炮台替换标志
function CCBFortEquipView:showFortChangeSign(fortID)
	self.m_selectFortID = fortID;
	local equipFortData = FortDataMgr:getEquipFortData();
	for k, v in pairs(equipFortData) do
		if v.fort_id == fortID then
			-- 显示选中框
			self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):getChildByTag(1):getChildByTag(2):setVisible(true);
			self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):getChildByTag(1):getChildByTag(1):setVisible(false);
		else
			-- 显示交换标志 
			self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):getChildByTag(1):getChildByTag(1):setVisible(true);
			self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):getChildByTag(1):getChildByTag(2):setVisible(false);
		end
	end
end

-- 刷新交换后的炮台及页面状态
function CCBFortEquipView:refreshAfterChangeFort()
	self.m_selectFortID = 0;
	self:setEquipFort();
	if FortDataMgr:getSelectedFort() ~= 0 then
		FortDataMgr:setSelectedFort(0);
		self:detailBackToEquipOriginail();
		self:reloadTableViewDataWithOffset();
	end
end

-- 进入装备状态时恢复状态
function CCBFortEquipView:showEquipNormalState()
	self.m_selectFortID = 0;
	for i = 1, 3 do 
		if self.m_ccbNodeEquipFort:getChildByTag(i):getChildByTag(1):getChildByTag(1):isVisible() then
			self.m_ccbNodeEquipFort:getChildByTag(i):getChildByTag(1):getChildByTag(1):setVisible(false);
		end
		if self.m_ccbNodeEquipFort:getChildByTag(i):getChildByTag(1):getChildByTag(2):isVisible() then
			self.m_ccbNodeEquipFort:getChildByTag(i):getChildByTag(1):getChildByTag(2):setVisible(false);
		end
	end
end

function CCBFortEquipView:hideEquipState()
	for i = 1, 3 do 
		if self.m_ccbNodeEquipFort:getChildByTag(i):getChildByTag(1):getChildByTag(1):isVisible() then
			self.m_ccbNodeEquipFort:getChildByTag(i):getChildByTag(1):getChildByTag(1):setVisible(false);
		end
		if self.m_ccbNodeEquipFort:getChildByTag(i):getChildByTag(1):getChildByTag(2):isVisible() then
			self.m_ccbNodeEquipFort:getChildByTag(i):getChildByTag(1):getChildByTag(2):setVisible(false);
		end
	end
end

-- 炮台转换点击动画
function CCBFortEquipView:playFortChangeTouchAnim(pos)
	local fortChangeAnim = ResourceMgr:getIconChangeAnimTouch();
	self.m_ccbNodeEquipFort:getChildByTag(pos):addChild(fortChangeAnim);
	fortChangeAnim:getAnimation():play("anim01");
	fortChangeAnim:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			fortChangeAnim:removeSelf();
			fortChangeAnim = nil;
		end
	end)
end

-- 炮台转换框动画
function CCBFortEquipView:playFortChangeAnim(pos)
	local fortChangeAnim = ResourceMgr:getIconChangeAnim();
	self.m_ccbNodeEquipFort:getChildByTag(pos):addChild(fortChangeAnim);
	fortChangeAnim:getAnimation():play("anim01");
	fortChangeAnim:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			-- self.m_isFortChange = false;
			fortChangeAnim:removeSelf();
			fortChangeAnim = nil;
		end
	end)
	fortChangeAnim:getAnimation():setFrameEventCallFunc(function(bone, event, originFrameIndex, currentFrameIndex)
		if event == "change_item" then
			App:getRunningScene():getViewBase().m_ccbShipMainView:setEquipFort();
			self:refreshAfterChangeFort();	
		end
	end);
end

function CCBFortEquipView:touchEquipButtonSelect(fortID)
	if not self.m_ccbNodeDetailContent:isVisible() then
		self.m_ccbNodeDetailContent:setVisible(true);
	end
	if self.m_ccbSpriteTipEquip:isVisible() then
		self.m_ccbSpriteTipEquip:setVisible(false);
	end
	
	self:setFortDetailData(fortID);
	FortDataMgr:setSelectedFort(fortID);
	self:reloadTableViewDataWithOffset();
end

function CCBFortEquipView:reloadTableViewDataWithOffset()
	local offset = self.m_fortTableView:getContentOffset();
	self.m_fortTableView:reloadData();
	self.m_fortTableView:setContentOffset(offset);
end

function CCBFortEquipView:sortTableSuitData()
	local equipForts = FortDataMgr:getEquipFortData();
	-- dump(equipForts);
	for k, v in pairs(self.m_allFortData) do
		self.m_allFortData[k].sort = 0;
		if v.id == self.m_shipData.fort_id1 
			or v.id == self.m_shipData.fort_id2 
			or v.id == self.m_shipData.fort_id3 then
			self.m_allFortData[k].sort = 100 + v.id;
		else
			self.m_allFortData[k].sort = 300 + v.id;
			if equipForts[v.id] then
				self.m_allFortData[k].sort = self.m_allFortData[k].sort - 100;
			end
		end
	end
	table.sort(self.m_allFortData, function(a, b) return a.sort < b.sort; end);
end

function CCBFortEquipView:insertNewUnlockFort(data)
	table.insert(self.m_unlockFort, data);
	local fortType = FortDataMgr:getFortBaseType(data.id);
	if fortType == 1 then
		table.insert(self.m_unlockAtkFort, data);
		table.sort(self.m_unlockAtkFort, function(a, b)
			return a.id < b.id;
		end);
	elseif fortType == 2 then
		table.insert(self.m_unlockDefFort, data);
		table.sort(self.m_unlockDefFort, function(a, b)
			return a.id < b.id;
		end);
	elseif fortType == 3 then
		table.insert(self.m_unlockSkillFort, data);
		table.sort(self.m_unlockSkillFort, function(a, b)
			return a.id < b.id;
		end);
	end
	self:sortUnlockAllFort();
end

function CCBFortEquipView:playFortUnlockAnim()
	local unlockAnim = ResourceMgr:getUnlockFortAnim();
	self.m_fortTableView:addChild(unlockAnim, 10);
	unlockAnim:setPosition(cc.p(self.m_itemPosInTableNode.x, self.m_itemPosInTableNode.y));
	unlockAnim:getAnimation():play("anim01");
	unlockAnim:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			unlockAnim:removeSelf();
			unlockAnim = nil;
		end
	end)
	unlockAnim:getAnimation():setFrameEventCallFunc(function(bone, event, originFrameIndex, currentFrameIndex)
		if event == "disappear" then
			self:updataFortData();
		end
	end);
end

-- 装备炮台1按钮
function CCBFortEquipView:onBtnFortEquip1()
	print("fort1");
	self:touchEquipFortBtn(1);
end

-- 装备炮台2按钮
function CCBFortEquipView:onBtnFortEquip2()
	print("fort2");
	self:touchEquipFortBtn(2);
end

-- 装备炮台3按钮
function CCBFortEquipView:onBtnFortEquip3()
	print("fort3");
	self:touchEquipFortBtn(3);
end

function CCBFortEquipView:touchEquipFortBtn(index)
	local equipFortData = FortDataMgr:getEquipFortData();
	for k, v in pairs(equipFortData) do 
		if v.pos == index - 1 then
			if self.m_selectFortID == 0 then
				self.m_selectFortID = v.fort_id;
				self:touchEquipButtonSelect(v.fort_id);
			elseif v.fort_id == self.m_selectFortID then
				return;
			else
				-- 交换
				-- if self.m_isFortChange then
				-- 	Tips:create("炮台装换中");
				-- 	return;
				-- end
				-- self.m_isFortChange = true;
				self:playFortChangeTouchAnim(index);
				-- self.m_ccbNodeEquipFort:getChildByTag(index):getChildByTag(1):getChildByTag(1):setVisible(false);
				-- local changeSprite = cc.Sprite:create(ResourceMgr:getBlackChangeSign());
				-- self.m_ccbNodeEquipFort:getChildByTag(index):getChildByTag(1):addChild(changeSprite);
				Network:request("game.fortHandler.putonFort", {fort_id = self.m_selectFortID, pos = index - 1}, function (rc, receivedData)
					-- changeSprite:removeSelf();
					-- changeSprite = nil;
					self:hideEquipState();
					if receivedData["code"] ~= 1 then
						Tips:create(ServerCode[receivedData.code]);
						self.m_isFortChange = false;
						return;
					end
					print("请求变更炮台装备列表成功");

					self:sortTableSuitData();
					self:sortUnlockAllFort();
					if self.m_state == equipState and self.m_buttonState == 1 then
						self.m_loadFortData = self.m_unlockFort;
					end
					self:playFortChangeAnim(index);
				end)
				return;
			end
			break;
		end
	end
	for i = 1, 3 do 
		if i == index then
			self.m_ccbNodeEquipFort:getChildByTag(i):getChildByTag(1):getChildByTag(2):setVisible(true);
			self.m_ccbNodeEquipFort:getChildByTag(i):getChildByTag(1):getChildByTag(1):setVisible(false);	
		else
			self.m_ccbNodeEquipFort:getChildByTag(i):getChildByTag(1):getChildByTag(2):setVisible(false);
			self.m_ccbNodeEquipFort:getChildByTag(i):getChildByTag(1):getChildByTag(1):setVisible(true);
		end
	end
end

-- 所有炮台
function CCBFortEquipView:onBtnAllFort()
	self:setButton(1);

	if self.m_state == manageState then
		self.m_loadFortData = self.m_allFortData;
		self:setFortDetailData(self.m_loadFortData[1].id);
		FortDataMgr:setSelectedFort(self.m_loadFortData[1].id);
	elseif self.m_state == equipState then
		self.m_loadFortData = self.m_unlockFort;
		FortDataMgr:setSelectedFort(0);
		self:detailBackToEquipOriginail();
		self:showEquipNormalState();
	end
	self.m_fortTableView:reloadData();
end

-- 进攻型炮台
function CCBFortEquipView:onBtnAttackFort()
	self:setButton(2);

	if self.m_state == manageState then
		self.m_loadFortData = self.m_atkFortData;
		self:setFortDetailData(self.m_loadFortData[1].id);
		FortDataMgr:setSelectedFort(self.m_loadFortData[1].id);
	elseif self.m_state == equipState then
		self.m_loadFortData = self.m_unlockAtkFort;
		FortDataMgr:setSelectedFort(0);
		self:detailBackToEquipOriginail();
		self:showEquipNormalState();
	end
	self.m_fortTableView:reloadData();
end

-- 防御型炮台
function CCBFortEquipView:onBtnDefenceFort()
	self:setButton(3);

	if self.m_state == manageState then
		self.m_loadFortData = self.m_defFortData;
		self:setFortDetailData(self.m_loadFortData[1].id);
		FortDataMgr:setSelectedFort(self.m_loadFortData[1].id);
	elseif self.m_state == equipState then
		self.m_loadFortData = self.m_unlockDefFort;
		FortDataMgr:setSelectedFort(0);
		self:detailBackToEquipOriginail();
		self:showEquipNormalState();
	end

	self.m_fortTableView:reloadData();
end

-- 技能型炮台
function CCBFortEquipView:onBtnSkillFort()
	self:setButton(4);

	if self.m_state == manageState then
		self.m_loadFortData = self.m_skillFortData;
		self:setFortDetailData(self.m_loadFortData[1].id);
		FortDataMgr:setSelectedFort(self.m_loadFortData[1].id);
	elseif self.m_state == equipState then
		self.m_loadFortData = self.m_unlockSkillFort;
		FortDataMgr:setSelectedFort(0);
		self:detailBackToEquipOriginail();
		self:showEquipNormalState();
	end

	self.m_fortTableView:reloadData();
end

-- 强化按钮
function CCBFortEquipView:onBtnToStrong()
	local fortView = CCBFortView:create();
	for k, v in pairs(self.m_allFortData) do 
		if v.id == FortDataMgr:getSelectedFort() then
			fortView:setData(v, self.m_shipData, true);
			break;
		end
	end
	self:addChild(fortView, 10, 150);
	fortView:setFortSkillDesc(self.m_fortSkillDesc);
end

-- 装备炮台按钮
function CCBFortEquipView:onBtnToEquip()
	self.m_state = equipState;
	self:showEquipNormalState();
	local fadeIn = cc.FadeIn:create(0.3);
	local moveRight = cc.MoveBy:create(0.5, cc.p(nodeMoveX, 0));
	local fadeInCallback = cc.CallFunc:create(function()
		self.m_ccbNodeEquipFort:setVisible(true);
		self.m_ccbNodeEquipFort:setOpacity(0);

	end)
	local btnEnabledCall = cc.CallFunc:create(function()
		self.m_ccbBtnAlphaFort1:setEnabled(true);
		self.m_ccbBtnAlphaFort2:setEnabled(true);
		self.m_ccbBtnAlphaFort3:setEnabled(true);
	end)
	local fadeInSequence = cc.Sequence:create(cc.DelayTime:create(0.5), fadeInCallback, fadeIn, btnEnabledCall);
	self.m_ccbNodeCenterPart:runAction(moveRight);
	self.m_ccbNodeEquipFort:runAction(fadeInSequence);

	self.m_loadFortData = self.m_unlockFort;
	FortDataMgr:setSelectedFort(0);
	self:setButton(1);
	self:detailBackToEquipOriginail();
	self.m_fortTableView:reloadData();
end

-- 炮台管理按钮
function CCBFortEquipView:onBtnToManage()
	print("    炮台管理按钮。  ", self.m_state);
	self.m_state = manageState;
	local fadeOut = cc.FadeOut:create(0.3);
	local moveLeft = cc.MoveBy:create(0.5, cc.p(-nodeMoveX, 0));
	local btnUnenableCall = cc.CallFunc:create(function()
		self.m_ccbBtnAlphaFort1:setEnabled(false);
		self.m_ccbBtnAlphaFort2:setEnabled(false);
		self.m_ccbBtnAlphaFort3:setEnabled(false);
	end)
	local fadeOutCallback = cc.CallFunc:create(function()
		self.m_ccbNodeEquipFort:setVisible(fasle);
	end)
	local fadeOutSequence = cc.Sequence:create(btnUnenableCall, fadeOut);
	local moveLeftSequence = cc.Sequence:create(cc.DelayTime:create(0.3), moveLeft);
	self.m_ccbNodeEquipFort:runAction(fadeOutSequence);
	self.m_ccbNodeCenterPart:runAction(moveLeftSequence);

	self.m_loadFortData = self.m_allFortData;
	self:setButton(1);
	self:setFortDetailData(self.m_loadFortData[1].id);
	FortDataMgr:setSelectedFort(self.m_loadFortData[1].id);
	self.m_ccbNodeDetailContent:setVisible(true);
	self.m_ccbSpriteTipEquip:setVisible(false);
	self.m_fortTableView:reloadData();

	local offset = self.m_fortTableView:getContentOffset();
	self.m_itemPosInTableNode = cc.p(0 + itemIconPos.x - offset.x, 10 + itemIconPos.y + self.m_tableSize.height - 145 - offset.y);
end

-- 炮台描述的进阶按钮
function CCBFortEquipView:onBtnAdvance()
	local fortView = CCBFortView:create();
	for k, v in pairs(self.m_allFortData) do 
		if v.id == FortDataMgr:getSelectedFort() then
			fortView:setData(v, self.m_shipData, true);
		end
	end
	self:addChild(fortView, 10, 150);
	fortView:setFortSkillDesc(self.m_fortSkillDesc);
	fortView:selectButton(1);
end

-- 炮台描述的解锁和获取按钮
function CCBFortEquipView:onBtnUnlockOrGain()

	if self.m_isMaterialEnough then

		Network:request("game.fortHandler.unlockFort", {ref_id = FortDataMgr:getSelectedFort()}, function (rc, receivedData)
			print("------------------------请求解锁炮台-------------------")
			-- dump(receivedData);
			if receivedData["code"] ~= 1 then
				Tips:create(ServerCode[receivedData.code]);
				return
			end
			-- dump(receivedData.fort);
			-- dump(self.m_unlockFort);
			Tips:create(string.format(Str[7013], FortDataMgr:getFortBaseName(receivedData.fort.fort_id)));
			FortDataMgr:addUnlockFortData(receivedData.fort);
			
			local unlockFortData = FortDataMgr:getUnlockFortDataByID(receivedData.fort.fort_id);
			self:insertNewUnlockFort(unlockFortData);
			self:playFortUnlockAnim();
		end)		
	else
		CCBCommonGetPath:create(self.m_fortAdvanceItemID);
	end
end

-- 关闭按钮
function CCBFortEquipView:onBtnCloseSelf()
	self:removeSelf();
end

return CCBFortEquipView;