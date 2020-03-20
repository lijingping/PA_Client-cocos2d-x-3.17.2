local ResourceMgr = require("app.utils.ResourceMgr");
local Tips = require("app.views.common.Tips");

--加载ccbi文件
local CCBCheckAward = class("CCBCheckAward", function()
	return CCBLoader("ccbi/rankView/CCBCheckAward.ccbi")
end)

function CCBCheckAward:onExit()
end

function CCBCheckAward:onEnter()
end

function CCBCheckAward:ctor()
	if display.resolution >= 2 then
		self.m_ccbLayerPopupWindow:setScale(display.reduce);
	end
	
	self:enableNodeEvents();

	self:createCoverLayer();

	--屏蔽其他层操作
	--[[
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbNodeTouch);
	]]

	local rankInfo = UserDataMgr:getPlayerRankInfo();
	self.m_ccbLabelRank:setString(rankInfo.name);
	self.m_ccbLabelFamous:setString(rankInfo.curExp.."/"..rankInfo.levelUpExp);

	--设置滑动条
    self.m_itemCountSlider = ccui.Slider:create()    
    self.m_itemCountSlider:setScale9Enabled(true)
    self.m_itemCountSlider:setTouchEnabled(false)
    self.m_itemCountSlider:setContentSize(self.m_ccbNodeSlider:getContentSize());
    self.m_itemCountSlider:setAnchorPoint(0, 0);
    self.m_itemCountSlider:loadBarTexture(ResourceMgr:getSliderBarBg());
    self.m_itemCountSlider:loadProgressBarTexture(ResourceMgr:getSliderBar());
    --self.m_itemCountSlider:loadSlidBallTextures(ResourceMgr:getSliderBall(), ResourceMgr:getSliderBall(), ResourceMgr:getSliderBall());
	self.m_itemCountSlider:setPercent((rankInfo.curExp/rankInfo.levelUpExp)*100)
        :setCapInsets(cc.rect(18, 0, 18, 0));
    self.m_ccbNodeSlider:addChild(self.m_itemCountSlider);

	local action1 = cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(-5, 0)), cc.MoveBy:create(0.5, cc.p(5, 0))));
    self.m_ccbBtnLeft:runAction(action1);
    local action2 = cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(5, 0)), cc.MoveBy:create(0.5, cc.p(-5, 0))));
    self.m_ccbBtnRight:runAction(action2);

    self.m_daily_rank_award = table.clone(require("app.constants.daily_rank_award"));
    self.m_daily_rank_award_count = self:table_nums(self.m_daily_rank_award);

	local index = 1;
	while true do
		local node = self.m_ccbLayerPopupWindow:getChildByTag(index);
		if node == nil then
			break;
		end

		local size = node:getContentSize();
	    local btn = ccui.Button:create(ResourceMgr:getAlpha0Sprite(), ResourceMgr:getAlpha0Sprite(), ResourceMgr:getAlpha0Sprite());
	    btn:setTag(3);
		btn:setPosition(cc.p(size.width*0.5, size.height*0.5));
		btn:setScale9Enabled(true);
		btn:setRotation(45);
		btn:setContentSize(cc.size(size.width*0.72, size.height*0.72));
		btn:addTouchEventListener(function(sender, event)
			if event == ccui.TouchEventType.ended and btn.nTableViewPage > 0 then
				self.m_nTableViewPage = clone(btn.nTableViewPage);
				self:turnPage(0);
			end
		end);

		node:addChild(btn);

		index = index + 1;
	end

    self:createTableView();
    self.m_nTableViewPage = rankInfo.level;
    self:turnPage(0);
end

function CCBCheckAward:createCoverLayer()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
    listener:registerScriptHandler(function(touch, event) return true end, cc.Handler.EVENT_TOUCH_BEGAN);

    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerColor);
end

function CCBCheckAward:table_nums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function CCBCheckAward:createTableView()
	self.m_tableView = cc.TableView:create(self.m_ccbNodeView:getContentSize());
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL);
    self.m_tableView:setBounceable(false);
    self.m_tableView:setTouchEnabled(false);
    self.m_ccbNodeView:addChild(self.m_tableView);

   	self.m_tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx) end, cc.TABLECELL_SIZE_FOR_INDEX);
    self.m_tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end, cc.TABLECELL_SIZE_AT_INDEX);
    self.m_tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);
    self.m_tableView:reloadData()
end

function CCBCheckAward:cellSizeForTable(table, idx)
	return self.m_ccbNodeView:getContentSize().width, self.m_ccbNodeView:getContentSize().height;
end

function CCBCheckAward:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell();
	local data = self.m_daily_rank_award["".. (idx + 1)].award;
	local posx = 0;
	local distance = 127;
	local node;
	if cell == nil then
		cell = cc.TableViewCell:new();

		node = cc.Node:create();
		node:setTag(1);
		node:addTo(cell);
		node:setPositionY(self.m_ccbNodeView:getContentSize().height*0.5);
		for j, k in pairs(data) do
			local itemIconGroup = ResourceMgr:createRankAwardIcon(k.item_id, k.count);
			itemIconGroup:setPositionX(posx);
			itemIconGroup:setTag(j);
			node:addChild(itemIconGroup);

			posx = posx + distance;
		end
	else
		node = cell:getChildByTag(1);
		for j, k in pairs(data) do
			local itemIconGroup = node:getChildByTag(j);
			if itemIconGroup == nil then
				itemIconGroup = ResourceMgr:createRankAwardIcon(k.item_id, k.count);
				itemIconGroup:setPositionX(posx);
				itemIconGroup:setTag(j);
				node:addChild(itemIconGroup);
			else
				ResourceMgr:changeRankAwardIcon(itemIconGroup, k.item_id, k.count);
			end
			posx = posx + distance;
		end

		local itemIconGroup = node:getChildByTag(7);
		if itemIconGroup then	
			itemIconGroup:setVisible(#data >=7);
		end
	end

	local width = (#data-1)*distance;
	local size = cell:getContentSize();
	node:setContentSize(cc.size(width, 0));
	node:setPositionX(self.m_ccbNodeView:getContentSize().width*0.5-width*0.5);

	return cell;
end

function CCBCheckAward:numberOfCellsInTableView(table)
	return self.m_daily_rank_award_count;
end

function CCBCheckAward:setRank(page)
	local index = 1;
	while true do
		local node = self.m_ccbLayerPopupWindow:getChildByTag(index);
		if node == nil then
			break;
		end

		local level = page + (index - 3);
		if self.m_daily_rank_award["".. level] then
			node:getChildByTag(1):setTexture(ResourceMgr:getRankBigIconByLevel(level)):setVisible(true);
			node:getChildByTag(2):setTexture(ResourceMgr:getRankTextByLevel(level)):setVisible(true);
			node:getChildByTag(3).nTableViewPage = clone(level);
		else
			node:getChildByTag(1):setVisible(false);
			node:getChildByTag(2):setVisible(false);
			node:getChildByTag(3).nTableViewPage = 0;
		end

		index = index + 1;
	end
end
--[[
function CCBCheckAward:onTouchBegan(touch, event)
	self.m_lastMovePos = cc.p(0, 0);
	local touchPos = touch:getLocation();
	self.m_touchTableViewBeginPos = self.m_ccbNodeView:convertToNodeSpace(touchPos);
	if self.m_touchTableViewBeginPos.x < 0		
		or self.m_touchTableViewBeginPos.x > self.m_ccbNodeView:getContentSize().width 
		or self.m_touchTableViewBeginPos.y < 0
		or self.m_touchTableViewBeginPos.y > self.m_ccbNodeView:getContentSize().height then
		return false;
	end

	return true;
end

function CCBCheckAward:onTouchMoved(touch, event)
	local touchPos = touch:getLocation();
	self.m_touchTableViewMovePos = self.m_ccbNodeView:convertToNodeSpace(touchPos);
	if self.m_lastMovePos.x ~= 0 then
		local offsetX = self.m_tableView:getContentOffset().x + (self.m_touchTableViewMovePos.x - self.m_lastMovePos.x)*1.3;
		self.m_tableView:setContentOffset(cc.p(offsetX, 0));
	end
	self.m_lastMovePos = self.m_touchTableViewMovePos;
end

function CCBCheckAward:onTouchEnded(touch, event)
	self.m_lastMovePos = cc.p(0, 0);
	local touchPos = touch:getLocation();
	local endPos = self.m_ccbNodeView:convertToNodeSpace(touchPos);

	local offsetX = (endPos.x - self.m_touchTableViewBeginPos.x) * 1.3;
	if math.abs(offsetX) > self.m_ccbNodeView:getContentSize().width * 0.3 then
		if offsetX < 0 then
			self:turnPage(1);
		else 
			self:turnPage(-1);
		end
	else
		self:turnPage(0);
	end	
end
]]
function CCBCheckAward:turnPage(param)
	self.m_nTableViewPage = self.m_nTableViewPage + param;
	if self.m_nTableViewPage <= 0 then
		self.m_nTableViewPage = 1;
	end
	if self.m_nTableViewPage > self.m_daily_rank_award_count then
		self.m_nTableViewPage = self.m_daily_rank_award_count;
	end

	self.m_tableView:setContentOffset(cc.p((self.m_nTableViewPage-1) * (-self.m_ccbNodeView:getContentSize().width), 0), true);

	self:setArrowShow();
	self:setRank(self.m_nTableViewPage);
end

function CCBCheckAward:setArrowShow()
	self.m_ccbBtnLeft:setVisible(not(self.m_nTableViewPage == 1));
	self.m_ccbBtnRight:setVisible(not(self.m_nTableViewPage == self.m_daily_rank_award_count));
end

function CCBCheckAward:onBtnLeft()
	self:turnPage(-1);
end

function CCBCheckAward:onBtnRight()
	self:turnPage(1);
end

function CCBCheckAward:onBtnClose()
	self:removeSelf();

	if App:getRunningScene():getViewBase().m_ccbMainView then
		App:getRunningScene():getViewBase().m_ccbMainView:onBtnRankAward();
	end
end

return CCBCheckAward