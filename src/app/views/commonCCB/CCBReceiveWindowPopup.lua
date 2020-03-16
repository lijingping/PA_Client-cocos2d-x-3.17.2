local CCBReceiveItemCell = require("app/views/commonCCB/CCBReceiveItemCell")
local Tips = require("app.views.common.Tips")

local CCBReceiveWindowPopup = class("CCBReceiveWindowPopup",function()
	return CCBLoader("ccbi/commonCCB/CCBReceiveWindowPopup.ccbi")
end)


function CCBReceiveWindowPopup:ctor()
	--遮蔽

	self.m_viewWidth = 450;
	self.m_viewHeight = 110;
	self.m_giftTable = {};

 	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(event, touch) return true end, cc.Handler.EVENT_TOUCH_BEGAN)
	local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);

    self:createAllPresentTableView();
end

--点击接收删除窗口
function CCBReceiveWindowPopup:onBtnReceive()
	self:tipsAcceptAllPresent();
	self:removeSelf()
end

function CCBReceiveWindowPopup:tipsAcceptAllPresent()
	local tipsAcceptPresent = Tips:create(Str[4037]);
end

function CCBReceiveWindowPopup:createAllPresentTableView()
	-- print("CCBReceiveWindowPopup:createAllPresentTableView");
	local layerSize = self.m_ccbLayerReceiveAllPresent:getContentSize()
	self.m_tableViewAllPresent = cc.TableView:create(layerSize);
	self.m_tableViewAllPresent:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	self.m_tableViewAllPresent:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)--从上自下填充（默认是从左往右填充）
	self.m_tableViewAllPresent:setDelegate();
	self.m_ccbLayerReceiveAllPresent:addChild(self.m_tableViewAllPresent);

	self.m_tableViewAllPresent:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table, idx) end, cc.TABLECELL_SIZE_FOR_INDEX);
	self.m_tableViewAllPresent:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end, cc.TABLECELL_SIZE_AT_INDEX);
	self.m_tableViewAllPresent:registerScriptHandler(function(table, idx) return self:numberOfCellsInTableView(table) end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW);
	self.m_tableViewAllPresent:reloadData();
end

function CCBReceiveWindowPopup:cellSizeForTable(table, idx)
	return self.m_viewWidth, self.m_viewHeight;
end

function CCBReceiveWindowPopup:tableCellAtIndex(table, idx)
	-- print("CCBReceiveWindowPopup:tableCellAtIndex", idx)
	local cell = table:dequeueCell();

	if cell == nil then
		cell = cc.TableViewCell:new();
		for i = 1, 4 do
			local presentItem = CCBReceiveItemCell:create();
			local itemSzie = presentItem.m_ccbSprite9PresentFrame:getContentSize();
			presentItem:setPosition(cc.p(itemSzie.width*(i-1) + 20, 0));
			presentItem:setTag(110+i);
			cell:addChild(presentItem)			
			if self.m_giftTable[idx*4+i] then
				presentItem:setVisible(true);
				presentItem:setData(self.m_giftTable[idx*4+i]);
			else
				presentItem:setVisible(false);
			end
		end
	else
		for i = 1, 4 do
			local presentItem = cell:getChildByTag(110+i);
			if presentItem then
				if self.m_giftTable[idx*4+i] then
					presentItem:setVisible(true);
					presentItem:setData(self.m_giftTable[idx*4+i]);
				else
					presentItem:setVisible(false);
				end				
			end
		end
	end
	return cell
end

function CCBReceiveWindowPopup:numberOfCellsInTableView(table)
	if #self.m_giftTable ~= 0 then
		-- print("@@@@giftTable:", math.ceil(#self.m_giftTable/4));
		return math.ceil(#self.m_giftTable/4);
	else 
		return 0;
	end
end

function CCBReceiveWindowPopup:setAllPresentData(data)
	-- print("------------CCBReceiveWindowPopup:setAllPresentData---弹窗的设置所有礼物数据----")
	self.m_giftTable = data;
	self.m_tableViewAllPresent:reloadData();
end

function CCBReceiveWindowPopup:setGiftCount(data)
	-- print("CCBReceiveWindowPopup:setGiftCount");
	local friendPresentCount_2906 = 0;
	local friendPresentCount_2907 = 0;
	local friendPresentCount_2908 = 0;
	self.m_giftTable = {};
	for k, v in pairs(data) do

		if v.item_id == 2906 then
			friendPresentCount_2906 = friendPresentCount_2906 + 1;
		
		elseif v.item_id == 2907 then 
			friendPresentCount_2907 = friendPresentCount_2907 + 1;
				
		elseif v.item_id == 2908 then 
			friendPresentCount_2908 = friendPresentCount_2908 + 1;				
		end
	end

	if friendPresentCount_2906 > 0 then
		table.insert(self.m_giftTable, {item_id = 2906, count = friendPresentCount_2906})
	end
	if friendPresentCount_2907 > 0 then
		table.insert(self.m_giftTable, {item_id = 2907, count = friendPresentCount_2907})
	end
	if friendPresentCount_2908> 0 then
		table.insert(self.m_giftTable, {item_id = 2908, count = friendPresentCount_2908})
	end

	self.m_tableViewAllPresent:reloadData();
end

return CCBReceiveWindowPopup