--local ScrollView = require("app.views.common.ScrollView")
local CCBAddFriendCell = require("app.views.friendView.CCBAddFriendCell")
local Tips = require("app.views.common.Tips");

---------------------
-- 添加好友列表
---------------------
local CCBAddFriendView = class("CCBAddFriendView", function ()
	return CCBLoader("ccbi/friendView/CCBAddFriendView.ccbi")
end)

-- list view settings
local viewWidth = 1190
local viewHeight = 385
local cellWidth = 585
local cellHeight = 100
local paddingX = 20
local paddingY = 10
local colum = 2

function CCBAddFriendView:ctor()
	self.recommendCells = {}
	self.cellPoints = {}

	self.editBox = self:createEditBox():addTo(self.layer_editBox)
	self.listView = self:createListView():addTo(self.layer_recommend)
end

-- 创建输入框(搜索玩家)
function CCBAddFriendView:createEditBox()
	local size = self.layer_editBox:getContentSize()
	local bg = cc.Scale9Sprite:create("res/resources/common/ui_first_frame_bp01.png")
	bg:setContentSize(size)

	local editBox = cc.EditBox:create(size, bg)
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if kTargetIphone == targetPlatform or kTargetIpad == targetPlatform then
		editBox:setFontName("simhei")
	else
		editBox:setFontName("fonts/simhei.ttf")
	end

	editBox:setAnchorPoint(cc.p(0, 0))
	editBox:setFontSize(20)
	editBox:setFontColor(cc.c3b(255, 255, 255))
	editBox:setPlaceholderFontSize(20)
	editBox:setPlaceholderFontColor(cc.c3b(128, 128, 128))
    editBox:setPlaceHolder("    输入你想添加的玩家昵称")
	editBox:setMaxLength(32)
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)

    return editBox
end

--创建系统推荐玩家列表
function CCBAddFriendView:createListView()
	-- local listView = ScrollView:create(ScrollView.DIRECTION_VERTICAL)
	-- listView:setContentSize(cc.size(viewWidth, viewHeight))
	-- listView:setInnerContainerSize(cc.size(viewWidth, viewHeight))
	-- listView:setBounceEnabled(true)

	-- return listView
end

-- 根据数据更新列表
function CCBAddFriendView:setListViewData(data)
	for k,v in pairs(self.recommendCells) do
		v:removeSelf()
	end

	self.recommendCells = {}
	if data == nil then return end

	--TODO:update list view

	local containerHeight, row = self:setListViewContainerHeight(#data)
	self.cellPoints = self:calCellPoints(row, colum, containerHeight)
	self:createListViewCells(data)
end

-- 设置列表container高度
function CCBAddFriendView:setListViewContainerHeight(dataCount)
	local row = math.ceil(dataCount / colum)
	local width = viewWidth
	local height = (cellHeight + paddingY) * row - paddingY
	if height < viewHeight then height = viewHeight end

	self.listView:setInnerContainerSize(cc.size(width, height))

	return height, row
end

-- 计算列表子控件的位置
function CCBAddFriendView:calCellPoints(row, colum, containerHeight)
	local points = {}
	for i = 1, row do
		for j = 1, colum do
			local x = (j - 1) * (cellWidth + paddingX)
			local y = containerHeight - (i - 1) * (cellHeight + paddingY)
			table.insert(points, cc.p(x, y))
		end
	end

	return points
end

-- 创建子控件
function CCBAddFriendView:createListViewCells(data)
	for k, v in pairs(data) do
		local cell = CCBAddFriendCell:create()
		cell:setData(v)
		cell:setAnchorPoint(cc.p(0, 1))
		self.listView:add(cell)
		table.insert(self.recommendCells, cell)
	end

	self:sortListViewCells()
end

-- 排序
function CCBAddFriendView:sortListViewCells()
	-- TODO: sort 
	local idx = 1
	for k, v in pairs(self.recommendCells) do
		v:move(self.cellPoints[idx])
		idx = idx + 1
	end
end

function CCBAddFriendView:onSendTouched()
	if self.editBox:getText() == nil then
		Tips:create(Str[5012]);
		return 
	end
	App:getRunningScene():requestSearchFriend(self.editBox:getText());
	
end

function CCBAddFriendView:onRefreshTouched()
	App:getRunningScene():requestAdviceList();
end

return CCBAddFriendView