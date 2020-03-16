local ResourceMgr = require("app.utils.ResourceMgr");
local FrameLayer = require("app.views.common.FrameLayer")

local EscortFloat = class("EscortFloat",cc.Node);


function EscortFloat:ctor()
	print("EscortFloat:ctor")
	self:createTouchEvent();
	
	self.m_frameLayer = FrameLayer:create();
	self:add(self.m_frameLayer)

	self.m_spriteNode = cc.Node:create();
	self.m_frameLayer:addChild(self.m_spriteNode);

	self.m_frameSize = self.m_frameLayer:getContentSize();
	-- dump(self.m_frameSize)

	self:createFloatSprite();
end

function EscortFloat:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(false);
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(function(touch, event) self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED);
	listener:registerScriptHandler(function(touch, event) self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function EscortFloat:onTouchBegan(touch,event)
	return true;
end

function EscortFloat:onTouchMoved(touch,event)	
end

function EscortFloat:onTouchEnded(touch,event)
	print("点击end")
	local touchEndedPos = touch:getLocation();
	-- dump(touchEndedPos)
	-- dump(self.m_spriteNode:getBoundingBox())
	-----------------mac-----------------
	-- "<var>" = {
	--     "x" = 1177.3737792969
	--     "y" = 246.24136352539
	-- }
	-- "<var>" = {
	--     "height" = 137.8275604248
	--     "width"  = 270.94882202148
	--     "x"      = 454.14151000977
	--     "y"      = -250.09063720703
	-- }
	--------------------------------------
	-------------ipad---------------------
	-- "<var>" = {
	--     "x" = 560.13031005859
	--     "y" = 202.95407104492
	-- }

	-- "<var>" = {
	--     "height" = 147.19366455078
	--     "width"  = 289.36117553711
	--     "x"      = -181.7752532959
	--     "y"      = -482.29211425781
	-- }
	---------------------------------------
	local TouchPos = cc.p(touchEndedPos.x - 640, touchEndedPos.y - 360 - display.offsetY)

	if cc.rectContainsPoint(self.m_spriteNode:getBoundingBox(), TouchPos) then
		print("碰撞")
		-- print("sprite X : ", self.m_spriteNode:getPositionX(), "sprite Y : ", self.m_spriteNode:getPositionY());
		-- local pos = self:convertToWorldSpace(cc.p(self.m_spriteNode:getPositionX(), self.m_spriteNode:getPositionY()));
		-- -- dump(pos);
		-- if self.m_floatingSprite then
		-- 	local floatSize = self.m_floatingSprite:getContentSize();
		-- 	pos.x = pos.x + floatSize.width / 2;
		-- 	pos.y = pos.y + floatSize.height / 2;
		-- end
		-- dump(pos);
		self:getParent():getParent():setFloatPos(touchEndedPos);
		App:getRunningScene():receiveFloat();

	end
end

function EscortFloat:createFloatSprite()
	local userLevel = UserDataMgr:getPlayerLevel();
	-- print("玩家等级", userLevel)
	local domain = math.ceil(userLevel / 20);
	
	self.m_floatingSprite = cc.Sprite:create("res/images/floater10"..domain..".png");
	self.m_spriteNode:addChild(self.m_floatingSprite);
	local spriteSize = self.m_floatingSprite:getContentSize();
	-- dump(spriteSize)

	self.m_floatingSprite:setPosition(spriteSize.width / 2, spriteSize.height / 2);
	self.m_spriteNode:setContentSize(spriteSize);

	local armature = ResourceMgr:getAnimArmatureByNameOnMain("anim_hint01");
	armature:getAnimation():play("anim01");
	armature:setScale(2.5)
	armature:setPosition(spriteSize.width / 2, spriteSize.height / 2);
	self.m_spriteNode:addChild(armature);

	self.m_startPos = self:getStartPos();
	self.m_spriteNode:setPosition(self.m_startPos);
	local startScale = self:getStartScale();
	self.m_spriteNode:setScale(startScale);

	local endPos = self:getEndPos();
	local endScale = self:getEndScale();
	local moveTime = self:getMoveTime();

	local moveToAction = cc.MoveTo:create(moveTime, endPos);
	local scaleToAction = cc.ScaleTo:create(moveTime, endScale);

	local spawnAction = cc.Spawn:create(moveToAction, scaleToAction);
	local callFunc = CCCallFunc:create(function () 
		self:getParent():getParent():releaseFloath();
		-- self:removeSelf();
	end);
	local seq = cc.Sequence:create(spawnAction, callFunc);
	self.m_spriteNode:runAction(seq);
end

function EscortFloat:getStartPos()
	local sideRandom = math.random(1, 2); --出现的方向
	if sideRandom == 1 then   -- 左边
		return cc.p(math.random(- self.m_frameSize.width/2+80, -150), self.m_frameSize.height/2 + 200);
	else                      -- 右边
		return cc.p(math.random(150, self.m_frameSize.width/2-80), self.m_frameSize.height/2 + 200);
	end
end

function EscortFloat:getStartScale()
	return math.random(50, 60) / 100;
end

function EscortFloat:getEndPos()
	if self.m_startPos.x < 0 then
		return cc.p(math.random(- self.m_frameSize.width/2+80, -150), - self.m_frameSize.height/2 - 200)
	else
		return cc.p(math.random(150, self.m_frameSize.width/2-80), - self.m_frameSize.height/2 - 200)
	end 
end

function EscortFloat:getEndScale()
	return math.random(70, 80) / 100;
end

-- 获取随机时间
function EscortFloat:getMoveTime()
	return math.random(3, 4);
end

return EscortFloat