local ResourceMgr = require("app.utils.ResourceMgr");
local Tips = require("app.views.common.Tips");
-- local SpriteBlur = require("app.views.common.SpriteBlur");
local CCBPopupProperty = require("app.views.shipView.CCBPopupProperty");
local CCBFortEquipView = require("app.views.shipView.CCBFortEquipView");

local CCBShipMainView = class("CCBShipMainView", function ()
	return CCBLoader("ccbi/shipView/CCBShipMainView.ccbi")
end)

local g_tableSize = cc.size(1280, 720);
local tableCellSize = cc.size(140, 155);
local shipBgSize = cc.size(1560, 960);

-- cc.RED = cc.c3b(255,0,0)
-- cc.GREEN = cc.c3b(0,255,0)
-- cc.BLUE = cc.c3b(0,0,255)
-- cc.BLACK = cc.c3b(0,0,0)
-- cc.WHITE = cc.c3b(255,255,255)
-- cc.YELLOW = cc.c3b(255,255,0)
-- local btnLeftPosX = -80;
-- local btnRightPosX = 80;
-- local btnCenterPosX = 0;

local stayBack = 0;
local leftDirection = 1;
local rightDirection = 2;

local domianTextTable = {Str[7005], Str[7006], Str[7007], Str[7008]};

function CCBShipMainView:ctor()
	-- print("CCBShipMainView:ctor")

	self:enableNodeEvents();
	self:createTouchEvent();
	self.m_currentPage = ShipDataMgr:getUseShipID() - 70001;

	self.m_isNetworkCall = false; -- 网络请求
	self.m_isTouching = false; -- 点击
	self.m_isTableViewScroll = false; -- tableview滚动
	self.m_isUnlockShip = false;

	self:setCascadeOpacityEnabled(true);
	self.m_ccbNodeCenterPart:setCascadeOpacityEnabled(true);
	self.m_ccbNodeEquipFort:setCascadeOpacityEnabled(true);
	self.m_ccbNodeShipLock:setCascadeOpacityEnabled(true);
	self.m_ccbNodeFortManager:setCascadeOpacityEnabled(true);
	self.m_ccbNodeBtnEquipFort:setCascadeOpacityEnabled(true);
	self.m_ccbNodeShipName:setCascadeOpacityEnabled(true);
	for i = 1, 3 do 
		self.m_ccbNodeEquipFort:getChildByTag(i):setCascadeOpacityEnabled(true);
	end
	self.m_ccbNodeMaterialLabel:setCascadeOpacityEnabled(true);
	self.m_ccbNodeBtnAnimation:setCascadeOpacityEnabled(true);
	self.m_ccbNodeMaterialIcon:setCascadeOpacityEnabled(true);

-- 获取皮肤数据
	self:getSkinData();
	-- dump(self.m_tableWarship);--读取的是这个皮肤里面的信息。比如套装属性
	-- "<var>" = {
     -- 1 = {
     --     "fort_id1"               = 90001
     --     "fort_id2"               = 90002
     --     "fort_id3"               = 90003
     --     "id"                     = 70001
     --     "last_time"              = 5
     --     "quality"                = 1
     --     "ship_name"              = "探险者"
     --     "skill_base_value_per"   = 15
     --     "skill_desc"             = "全体炮台开启火力增幅状态【伤害+%4.1f%%】，持续%4.1f秒"
     --     "skill_name"             = "孤注一掷"
     --     "suite_attri_per"        = 15
     --     "target"                 = 1
     --     "time"                   = 0
     --     "unlock_item_count"      = 0
     --     "unlock_item_id"         = 0
     --     "unlock_level"           = 1
     --     "upgrade_base_value_per" = 1
     --     "upgrade_last_time"      = 0.5
     -- }
-- 获取炮台数据
	self:getFortsData();
	
-- 初始设置读取当前皮肤页面后刷新总炮台列表
	-- self:sortTableSuitData();

	self.m_unlockSkinList = ShipDataMgr:getUnlockShipSkinData(); -- 解锁战舰皮肤
	-- dump(self.m_unlockSkinList[70001]);
	-- "<var>" = {
 --     "ship_id"     = 70001
 --     "skill_level" = 1
 -- }

	self.m_shipBgRectPointX = (shipBgSize.width - display.size.width) * 0.5;
	self.m_shipBgRectPointY = (shipBgSize.height - display.size.height) * 0.5;
	-- print(" ...self.m_shipBgRectPointX", self.m_shipBgRectPointX)
	-- print(" ...self.m_shipBgRectPointY, ", self.m_shipBgRectPointY)
	-- 战舰皮肤 tableview
	self:createTableView();

	self:createUnlockFightBtnAnim();
	self:setShipData();
	self:setEquipFort();
	--如果分辨率长宽比大于2(全面屏)设置适配
	if display.resolution >= 2 then
		self:resolution();
	end

	-- dump(display.size);
end

function CCBShipMainView:resolution()
	print("CCBShipMainView:resolution")
	self.m_ccbNodeCenterPart:setScale(display.reduce);
end


function CCBShipMainView:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)--设为false向下传递触摸
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbTouchLayer)
end


function CCBShipMainView:onTouchBegan(touch, event)
	-- print("  begin .  . .  ")
	if self.m_isNetworkCall or self.m_isTouching or self.m_isTableViewScroll or self.m_isUnlockShip then
		return false;
	end

	self.m_isTouching = true;
	self.m_beginPos = touch:getLocation();
	self.m_beginTime = os.time();
	self.m_tableCurOffset = self.m_tableView:getContentOffset();
	self.m_haveChangePage = false; -- 是否有翻页
	self.m_isTableMove = false; -- table滑动
	return true
end

function CCBShipMainView:onTouchMoved(touch, event)
	self.m_movePos = touch:getLocation();
	if self.m_preMovePos then
		local moveDistance = self.m_movePos.x - self.m_preMovePos.x;
		local tableOffset = self.m_tableView:getContentOffset();

		if not (self.m_currentPage == 9 and self.m_movePos.x <= self.m_beginPos.x)
		 and not (self.m_currentPage == 0 and self.m_movePos.x >= self.m_beginPos.x) then
			self.m_tableView:setContentOffset(cc.p(tableOffset.x + moveDistance, 0));
			if not self.m_isTableMove then
				self.m_isTableMove = true;
				self:btnSetEnabled(false);
			end		 
		end
	end
	self.m_preMovePos = self.m_movePos;

end

function CCBShipMainView:onTouchEnded(touch, event)
	self.m_isTouching = false;
	self.m_preMovePos = nil;
	self.m_endTime = os.time();
	self.m_endPos = touch:getLocation();

	local direction = stayBack;
	-- 划过屏幕一半距离
	if math.abs(self.m_endPos.x - self.m_beginPos.x) > display.width * 0.5 then
		self.m_haveChangePage = true;
		if self.m_endPos.x > self.m_beginPos.x then
			direction = leftDirection;
		else
			direction = rightDirection;
		end
	else
		-- 滑动的速度快
		if self.m_endTime - self.m_beginTime < 2 and math.abs(self.m_endPos.x - self.m_beginPos.x) > 100 then
		self.m_haveChangePage = true;
			if self.m_endPos.x > self.m_beginPos.x then
				direction = leftDirection;
			else
				direction = rightDirection;
			end
		end
	end
	-- table 滑动了
	if self.m_isTableMove then
		self:adjustTableViewByDirection(direction);
	end
end

function CCBShipMainView:adjustTableViewByDirection(direction)
	if direction == stayBack then

	elseif direction == leftDirection then
		self.m_currentPage = self.m_currentPage - 1;
		if self.m_currentPage <= 0 then
			self.m_currentPage = 0;
			if self.m_ccbBtnArrowLeft:isVisible() then
				self.m_ccbBtnArrowLeft:setVisible(false);
			end
		else
			if not self.m_ccbBtnArrowRight:isVisible() then
				self.m_ccbBtnArrowRight:setVisible(true);
			end
		end
	elseif direction == rightDirection then
		self.m_currentPage = self.m_currentPage + 1;
		if self.m_currentPage >= 9 then
			self.m_currentPage = 9;
			if self.m_ccbBtnArrowRight:isVisible() then
				self.m_ccbBtnArrowRight:setVisible(false);
			end
		else
			if not self.m_ccbBtnArrowLeft:isVisible() then
				self.m_ccbBtnArrowLeft:setVisible(true);
			end
		end
	end
	-- self:sortTableSuitData();
	self.m_tableView:setContentOffset(cc.p(-(g_tableSize.width * self.m_currentPage), 0), true);
	self.m_isTableViewScroll = true;
	-- if self.m_haveChangePage then
	-- 	self:setShipData();
	-- end
end

-- 对获取到的战舰皮肤再进行排列以得到正确的  表  长度。
function CCBShipMainView:getSkinData()

	self.m_tableWarship = {};
	local shipList = ShipDataMgr:getShipList();

	for k, v in pairs(shipList) do
		table.insert(self.m_tableWarship, v);
	end
	
	table.sort(self.m_tableWarship,function(a, b) 
		return a.id < b.id;
		end)
end

function CCBShipMainView:createTableView()
	-- print("CCBShipMainView:createTableView")

	g_tableSize = self.m_ccbLayerViewSize:getContentSize();
	self.m_tableView = cc.TableView:create(g_tableSize);
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self.m_tableView:setTouchEnabled(false);
    self.m_tableView:setDelegate()
    -- self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)--从上自下
    self.m_ccbLayerViewSize:addChild(self.m_tableView)

    self.m_tableView:registerScriptHandler(function (table, idx) return self:cellSizeForTable(table, idx) end, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_tableView:registerScriptHandler(function (table, idx) return self:tableCellAtIndex(table, idx) end, cc.TABLECELL_SIZE_AT_INDEX)
    self.m_tableView:registerScriptHandler(function (table) return self:numberOfCellsInTableView(table) end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.m_tableView:registerScriptHandler(function (table) return self:scrollViewDidScroll(table) end, cc.SCROLLVIEW_SCRIPT_SCROLL)

    self.m_tableView:reloadData()
    
    self.m_tableView:setContentOffset(cc.p(-display.width * self.m_currentPage, 0));

end


function CCBShipMainView:cellSizeForTable(table, idx)
	-- print("CCBShipMainView:cellSizeForTable", idx)
	return display.size.width, display.size.height;--display.sizeInPixels.height * display.scaleY;
end

function CCBShipMainView:tableCellAtIndex(table, idx)
	-- print("CCBShipMainView:tableCellAtIndex", idx)

	local cell = table:dequeueCell();
	
	if nil == cell then
		cell = cc.TableViewCell:new()
		local item = self:createShipCell(self.m_tableWarship[idx + 1].id);
		item:setPosition(g_tableSize.width / 2, g_tableSize.height / 2);
		item:setTag(100);
		cell:addChild(item)
	else
		local item = cell:getChildByTag(100);
		self:setDataByNode(item, self.m_tableWarship[idx + 1].id);

	end
	return cell;
end

function CCBShipMainView:numberOfCellsInTableView(table)
	-- print("CCBShipMainView:numberOfCellsInTableView")
	return #self.m_tableWarship;
end

function CCBShipMainView:scrollViewDidScroll(table)
	-- print("  table scroll function: offset : ", table:getContentOffset().x, "   page：", self.m_currentPage);
	if self.m_tableCurOffset then
		local moveOffsetNum = math.abs(self.m_tableCurOffset.x - table:getContentOffset().x);
		local opacityNum = 255 - moveOffsetNum * 0.8;
		if opacityNum < 0 then
			opacityNum = 0;
		end
		self.m_ccbNodeCenterPart:setOpacity(opacityNum);
	end
	if table:getContentOffset().x == -display.width * self.m_currentPage then
		self.m_isTableViewScroll = false;
		if self.m_haveChangePage then
			self:setShipData();			
		end
		self:showCenterNodeOfFadeIn();
		self:btnSetEnabled(true);
	end
end

function CCBShipMainView:createShipCell(shipID)
	local node = cc.Node:create();
	local spriteBg = cc.Sprite:create(ResourceMgr:getShipSkinByID(shipID), cc.rect(self.m_shipBgRectPointX, self.m_shipBgRectPointY, display.size.width, display.size.height));
	node:addChild(spriteBg);
	if self.m_unlockSkinList[shipID] == nil then
		display.setGray(spriteBg);
	end

	return node;
end

function CCBShipMainView:setDataByNode(node, shipID)
	node:removeAllChildren();
	local sprite = cc.Sprite:create(ResourceMgr:getShipSkinByID(shipID), cc.rect(self.m_shipBgRectPointX, self.m_shipBgRectPointY, display.size.width, display.size.height));
	node:addChild(sprite);
	if self.m_unlockSkinList[shipID] == nil then
		display.setGray(sprite);
	end
end

function CCBShipMainView:showFortNode(isUnlock)
	if isUnlock then
		if not self.m_ccbNodeEquipFort:isVisible() then
			self.m_ccbNodeEquipFort:setVisible(true);
		end
		if self.m_ccbNodeShipLock:isVisible() then
			self.m_ccbNodeShipLock:setVisible(false);
		end
		if not self.m_ccbNodeFortManager:isVisible() then
			self.m_ccbNodeFortManager:setVisible(true);
		end
		if not self.m_ccbNodeBtnEquipFort:isVisible() then
			self.m_ccbNodeBtnEquipFort:setVisible(true);
		end
	else
		if self.m_ccbNodeEquipFort:isVisible() then
			self.m_ccbNodeEquipFort:setVisible(false);
		end
		if not self.m_ccbNodeShipLock:isVisible() then
			self.m_ccbNodeShipLock:setVisible(true);
		end
		if self.m_ccbNodeFortManager:isVisible() then
			self.m_ccbNodeFortManager:setVisible(false);
		end
		if self.m_ccbNodeBtnEquipFort:isVisible() then
			self.m_ccbNodeBtnEquipFort:setVisible(false);
		end
	end
end

function CCBShipMainView:btnSetEnabled(is)
	self.m_ccbBtnAlphaFort1:setEnabled(is);
	self.m_ccbBtnAlphaFort2:setEnabled(is);
	self.m_ccbBtnAlphaFort3:setEnabled(is);
	self.m_ccbBtnArrowLeft:setEnabled(is);
	self.m_ccbBtnArrowRight:setEnabled(is);
	self.m_ccbBtnFortManager:setEnabled(is);
	self.m_ccbBtnShipAttribute:setEnabled(is);
	self.m_ccbBtnUnlockAndFight:setEnabled(is);
	self.m_ccbBtnEquipFort:setEnabled(is);
end

function CCBShipMainView:showCenterNodeOfFadeIn()
	local fadeIn = cc.FadeIn:create(0.5);
	local btnEnabledCallBack = cc.CallFunc:create(function()
		-- 提到外面直接执行
	end)
	local sequence = cc.Sequence:create(fadeIn, btnEnabledCallBack);
	self.m_ccbNodeCenterPart:runAction(sequence);
	-- self:btnSetEnabled(true);
end

function CCBShipMainView:setShipData()
	-- print("   添加 战舰 名称 图片  ");
	self.m_ccbNodeShipName:removeAllChildren()
	local shipID = self.m_tableWarship[self.m_currentPage + 1].id;
	local spriteName = cc.Sprite:create(ResourceMgr:getShipNameByIndex(self.m_currentPage + 1));
	self.m_ccbNodeShipName:addChild(spriteName);

	-- 未解锁
	local isUnlock = false;
	if self.m_unlockSkinList[shipID] == nil then
		self:showFortNode(isUnlock);
		self:setLockShipLabel();
		self.m_animUnlockFightBtn:getAnimation():play("unlock");
	else
		isUnlock = true;
		self:showFortNode(isUnlock);
		if shipID == ShipDataMgr:getUseShipID() then
			self.m_animUnlockFightBtn:getAnimation():play("attacking");
		else
			self.m_animUnlockFightBtn:getAnimation():play("attack");
		end
	end
end

function CCBShipMainView:setLockShipLabel()
	-- print(" 设置 未解锁 战舰的材料需求 文本 ");
	self.m_ccbNodeMaterialLabel:removeAllChildren();
	self.m_ccbNodeMaterialIcon:removeAllChildren();
	local richText = ccui.RichText:create();

	local playerLevel = UserDataMgr:getPlayerLevel();
	local playerDomain = math.ceil(playerLevel * 0.05); -- 二十分之一
	local curShipDomain = math.floor(self.m_currentPage * 0.5) + 1; -- 二分之一
	-- if playerDomain >= curShipDomain then
	-- 	-- 解锁这个战舰需要的等级够了
		local materialID = self.m_tableWarship[self.m_currentPage + 1].unlock_item_id;
		-- local materialIcon = ccui.RichElementImage:create(1, cc.WHITE, 255, ResourceMgr:getItemIconByID(materialID));-- "res/resources/common/icon_gold_small.png"
		-- materialIcon:setScale(0.27);
		-- richText:pushBackElement(materialIcon);
		local iconSprite = cc.Sprite:create(ResourceMgr:getItemIconByID(materialID));
		self.m_ccbNodeMaterialIcon:addChild(iconSprite);
		iconSprite:setScale(0.5);

		local materialNeed = self.m_tableWarship[self.m_currentPage + 1].unlock_item_count;
		local materialCur = ItemDataMgr:getItemCount(materialID);
		if materialNeed <= materialCur then
			local text = ccui.RichElementText:create(2, cc.WHITE, 255, "   " .. materialCur .. "/" .. materialNeed, "", 20);
			richText:pushBackElement(text);
		else
			local playerMaterialCountText = ccui.RichElementText:create(2, cc.RED, 255, "   " .. materialCur, "", 20);
			local needMaterialCountText = ccui.RichElementText:create(3, cc.WHITE, 255, "/" .. materialNeed, "", 20);
			richText:pushBackElement(playerMaterialCountText);
			richText:pushBackElement(needMaterialCountText);
		end
	-- else
	-- 	-- 等级不够 domianText[curShipDomain]
	-- 	local text = ccui.RichElementText:create(1, cc.WHITE, 255, domianTextTable[curShipDomain - 1], "", 20);
	-- 	richText:pushBackElement(text);
	-- end
	self.m_ccbNodeMaterialLabel:addChild(richText);
end

function CCBShipMainView:setEquipFort()
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
 -- pos 0, 1 ,2 
 	for k, v in pairs(equipFortData) do
 		self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):removeAllChildren();
 		local quality = FortDataMgr:getUnlockFortQuality(v.fort_id);
 		local fortIconBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(quality));
 		local fortIcon = cc.Sprite:create(ResourceMgr:getFortIconByID(v.fort_id));
 		local fortIconFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(quality));
 		self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):addChild(fortIconBg, 1, 1);
 		self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):addChild(fortIcon, 2, 2);
 		self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):addChild(fortIconFrame, 3, 3);
 		local fortIconQuality = cc.Sprite:create(ResourceMgr:getFortQualitySpriteByQualityNumber(quality));
 		self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):addChild(fortIconQuality, 4, 4);
 		fortIconQuality:setPosition(cc.p(-38, 38));
 		local shipData = self.m_tableWarship[self.m_currentPage + 1];
 		-- 套装标识
 		for i = 1, 3 do
 			local suitFort = "fort_id" .. i;
 			if shipData[suitFort] == v.fort_id then
 				local fortIconSuit = cc.Sprite:create(ResourceMgr:getFortSuitLogo());
 				self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):addChild(fortIconSuit, 5, 5);
 				fortIconSuit:setPosition(cc.p(-15, -1));
 				break;
 			end
 		end
 		local fortLevel = FortDataMgr:getUnlockFortLevel(v.fort_id);
 		local levelLabel = cc.LabelTTF:create();
 		levelLabel:setString("Lv." .. fortLevel);
 		levelLabel:setFontSize(16);
 		levelLabel:setPosition(cc.p(0, -38));
 		self.m_ccbNodeEquipFort:getChildByTag(v.pos + 1):addChild(levelLabel, 6, 6);
 	end
end

function CCBShipMainView:updateEquipFort(fortID)
	local equipFortData = FortDataMgr:getEquipFortData();
	if equipFortData[fortID] ~= nil then
		self:setEquipFort();
	end
end

-- 更新装备的炮台套装属性（出战战舰的套装）（出战后更新）
function CCBShipMainView:updateSuitTarget()
	for i = 1, 3 do 
		local node = self.m_ccbNodeEquipFort:getChildByTag(i);
		if node:getChildByTag(5) then
			node:removeChildByTag(5);
		end
	end
	local equipForts = FortDataMgr:getEquipFortData();
	local curUseShipID = ShipDataMgr:getUseShipID();

	local curUseShipData = self.m_tableWarship[curUseShipID - 70001 + 1];
	for i = 1, 3 do 
		local fortID = curUseShipData["fort_id" .. i];
		if equipForts[fortID] ~= nil then
			local node = self.m_ccbNodeEquipFort:getChildByTag(equipForts[fortID].pos + 1);
			local fortIconSuit = cc.Sprite:create(ResourceMgr:getFortSuitLogo());
			node:addChild(fortIconSuit, 5, 5);
			fortIconSuit:setPosition(cc.p(-15, -1));
		end
	end
end

function CCBShipMainView:reloadTableViewWithOffset()
	local offset = self.m_tableView:getContentOffset();
	self.m_tableView:reloadData();
	self.m_tableView:setContentOffset(offset);
end

function CCBShipMainView:onBtnArrowLeft()
	self.m_haveChangePage = true;
	self:adjustTableViewByDirection(leftDirection);
end

function CCBShipMainView:onBtnArrowRight()
	self.m_haveChangePage = true;
	self:adjustTableViewByDirection(rightDirection);
end

function CCBShipMainView:onBtnFortEquip1()
	local equipView = CCBFortEquipView:create(2, self.m_tableWarship[ShipDataMgr:getUseShipID() - 70000], 
		self.m_fortData, self.m_atkFortData, self.m_defFortData, self.m_skillFortData);

end

function CCBShipMainView:onBtnFortEquip2()
	local equipView = CCBFortEquipView:create(2, self.m_tableWarship[ShipDataMgr:getUseShipID() - 70000], 
		self.m_fortData, self.m_atkFortData, self.m_defFortData, self.m_skillFortData);
end

function CCBShipMainView:onBtnFortEquip3()
	local equipView = CCBFortEquipView:create(2, self.m_tableWarship[ShipDataMgr:getUseShipID() - 70000], 
		self.m_fortData, self.m_atkFortData, self.m_defFortData, self.m_skillFortData);
end

function CCBShipMainView:onBtnEquipFort()
	local equipView = CCBFortEquipView:create(2, self.m_tableWarship[ShipDataMgr:getUseShipID() - 70000], 
		self.m_fortData, self.m_atkFortData, self.m_defFortData, self.m_skillFortData);
end

function CCBShipMainView:onBtnFortManager()
	print(" fort manager btn ");
	local equipView = CCBFortEquipView:create(1, self.m_tableWarship[ShipDataMgr:getUseShipID() - 70000], 
		self.m_fortData, self.m_atkFortData, self.m_defFortData, self.m_skillFortData);
end

function CCBShipMainView:onBtnShipAttribute()
	print("  ship attribute btn " );
	local popupProperty = CCBPopupProperty:create(self.m_tableWarship[self.m_currentPage + 1], self.m_fortData);
end

function CCBShipMainView:onBtnUnlockAndFight()

	local shipID = self.m_tableWarship[self.m_currentPage + 1].id;
	
	if self.m_unlockSkinList[shipID] == nil then

		local playerLevel = UserDataMgr:getPlayerLevel();
		-- local curShipNeedLevel = math.floor(self.m_currentPage * 0.5) * 20 + 1;
		-- if playerLevel < curShipNeedLevel then
		-- 	Tips:create(string.format(Str[7009], curShipNeedLevel));
		-- 	self.m_animUnlockFightBtn:getAnimation():play("idle_unlock");
		-- 	return;
		-- end
		local materialID = self.m_tableWarship[self.m_currentPage + 1].unlock_item_id;
		local materialNeed = self.m_tableWarship[self.m_currentPage + 1].unlock_item_count;
		local playerHaveMaterial = ItemDataMgr:getItemCount(materialID);
		if playerHaveMaterial < materialNeed then
			Tips:create(string.format(Str[7010], ItemDataMgr:getItemNameByID(materialID)));
			self.m_animUnlockFightBtn:getAnimation():play("idle_unlock");
			return;
		end
		-- 解锁
		self.m_ccbBtnUnlockAndFight:setEnabled(false);
		self.m_isNetworkCall = true;
		local shipName = self.m_tableWarship[self.m_currentPage + 1].ship_name;
		Network:request("game.shipHandler.unlockShip", {ship_id = shipID}, function (rc, receivedData)
			print("请求解锁皮肤")
			self.m_isNetworkCall = false;
			if receivedData["code"] ~= 1 then
				Tips:create(ServerCode[receivedData.code]);
				self.m_ccbBtnUnlockAndFight:setEnabled(true);
				return;
			end
			-- dump(receivedData);
			self.m_animUnlockFightBtn:getAnimation():play("unlock_to_attack");
			Tips:create(string.format(Str[7011], shipName));  -- ShipDataMgr:getShipName(shipID)
			self.m_unlockSkinList = ShipDataMgr:getUnlockShipSkinData();
			self:playUnlockShipAnim();
		end)		

	else 
		if shipID == ShipDataMgr:getUseShipID() then
			self.m_animUnlockFightBtn:getAnimation():play("idle_attacking");
		else
			-- 出战
			print("出战");
			self.m_ccbBtnUnlockAndFight:setEnabled(false);
			self.m_isNetworkCall = true;
			Network:request("game.shipHandler.activeShip", {ship_id = shipID}, function (rc, receivedData)
				self.m_isNetworkCall = false;
				if receivedData["code"] ~= 1 then
					Tips:create(GameData:get("code_map", receivedData.code)["desc"]);
					self.m_ccbBtnUnlockAndFight:setEnabled(true);
					return;
				end

				ShipDataMgr:setUsingShipSkinID(shipID);
				if self.m_tableWarship[self.m_currentPage + 1].id == shipID then  -- 在网络传输中切换战舰（延迟）
					self.m_animUnlockFightBtn:getAnimation():play("attack_to_attacking");
				end
				self:updateSuitTarget();
			end)
		end
	end
end

-- 解锁时的动画
function CCBShipMainView:playUnlockShipAnim()
	self.m_isUnlockShip = true;
	self.m_unlockSkinArmature = ResourceMgr:getAnimArmatureByNameOnOthers("ui_ship_unlock1");
	self.m_ccbTouchLayer:addChild(self.m_unlockSkinArmature);
	self.m_unlockSkinArmature:setPosition(cc.p(display.width / 2, display.height / 2 - 100));
	self.m_unlockSkinArmature:getAnimation():play("anim01");
	-- 帧事件
	self.m_unlockSkinArmature:getAnimation():setFrameEventCallFunc(function(bone, eventFrameName, originFraIdx, currentFraIdx)
		if eventFrameName == "changeColor" then
			self:reloadTableViewWithOffset();
			self:showFortNode(true);
		end
	end)
	self.m_unlockSkinArmature:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			self.m_isUnlockShip = false;
			self.m_unlockSkinArmature:removeSelf();
			self.m_unlockSkinArmature = nil;
		end
	end)
end

-- 解锁出战按钮动画
function CCBShipMainView:createUnlockFightBtnAnim()
	self.m_animUnlockFightBtn = ResourceMgr:getShipUnlockFightAnim()
	self.m_ccbNodeBtnAnimation:addChild(self.m_animUnlockFightBtn);
	self.m_animUnlockFightBtn:getAnimation():setFrameEventCallFunc(function(bone, eventFrameName, originFraIdx, currentFraIdx)

	end)
	self.m_animUnlockFightBtn:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.complete then
			if movementID == "unlock_to_attack" or movementID == "attack_to_attacking" then
				self.m_ccbBtnUnlockAndFight:setEnabled(true);
				-- self.m_animUnlockFightBtn:getAnimation():play("attack");
				-- self.m_animUnlockFightBtn:getAnimation():play("attacking");
			end
		end
	end)
end


-- 获取炮台数据
function CCBShipMainView:getFortsData()
	-- print("ccbshipMainView:getFortsData--------------------------------");

	self.m_atkFortData = table.clone(FortDataMgr:getAtkFortData());
	self.m_defFortData = table.clone(FortDataMgr:getDefFortData());
	self.m_skillFortData = table.clone(FortDataMgr:getSkillFortData());

	-- 把炮台数据加到皮肤细胞当中
	self.m_fortData = {};
	for k, v in pairs(self.m_atkFortData) do
		table.insert(self.m_fortData, v);
	end
	for k, v in pairs(self.m_defFortData) do
		table.insert(self.m_fortData, v);
	end
	for k, v in pairs(self.m_skillFortData) do
		table.insert(self.m_fortData, v);
	end
	table.sort(self.m_fortData, function(info1, info2) 
			return info1.id < info2.id;
		 end);
	-- self:sortTableSuitData();

	self.m_fortLoadList = {};
	self.m_fortLoadList = self.m_fortData;

	FortDataMgr:setSelectedFort(self.m_fortLoadList[1]); -- 默认选中炮台
end

-- 更新已解锁战舰皮肤
-- function CCBShipMainView:updateUnlockSkin()
-- 	self.m_unlockSkinList = ShipDataMgr:getUnlockShipSkinData();
-- 	-- dump(self.m_unlockSkinList)
-- end

-- 排序 已装备和套装 靠前（全部按钮炮台）
function CCBShipMainView:sortTableSuitData()
	local equipForts = FortDataMgr:getEquipFortData();
	-- dump(equipForts);
	for k, v in pairs(self.m_fortData) do
		self.m_fortData[k].sort = 0;
		if v.id == self.m_tableWarship[self.m_currentPage + 1].fort_id1 
			or v.id == self.m_tableWarship[self.m_currentPage + 1].fort_id2 
			or v.id == self.m_tableWarship[self.m_currentPage + 1].fort_id3 then
			self.m_fortData[k].sort = 100 + v.id;
		else
			self.m_fortData[k].sort = 300 + v.id;
			if equipForts[v.id] then
				self.m_fortData[k].sort = self.m_fortData[k].sort - 100;
			end
		end
	end
	table.sort(self.m_fortData, function(a, b) return a.sort < b.sort; end);
end



return CCBShipMainView