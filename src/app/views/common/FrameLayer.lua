----------------------------
-- 自适应分辨率层，用于UI自适应
----------------------------
local  FrameLayer = class("FrameLayer", function()
	return cc.LayerColor:create(cc.c4b(255, 0, 0, 0))
end)

function FrameLayer:ctor(...)
	local visibleSize = cc.Director:getInstance():getVisibleSize()
	local width = visibleSize.width--/ display.scale
	local height = visibleSize.height--/ display.scale

	local configHeight = height/display.scale;
	local heightDown = configHeight - height

	self:setContentSize(cc.size(width, height))

	self:ignoreAnchorPointForPosition(false)
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:move(display.center)
	
	
	self.bottom = 0 - heightDown*0.5
    self.top = height + heightDown*0.5


	self.height = height
	self.width = width
end

return FrameLayer