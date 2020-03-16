

local CPlanet = class("CPlanet", cc.Node)
local resPath = "res/sceneMain/"

function CPlanet:onExit()
	if self.m_delayScheduler then
		self:getScheduler():unscheduleScriptEntry(self.m_delayScheduler);
		self.m_delayScheduler = nil;
	end
end

function CPlanet:ctor()
	self.m_planetSprite = nil;
	self.m_moveTime = math.random(150, 180);
	self.m_angle = 0;
	self.m_posEnd = cc.p(0,0);
	self.m_opacity = 255;
	self.m_planetSprite2 = nil;

	self:enableNodeEvents();

 	self:crateTexture();

 	self:runAction(cc.Spawn:create(self:moveAction(), self:scaleAction()));
 	--self.m_planetSprite:runAction(self:fadeOutAction());
 	self:retain()
 	self:setVisible(false);
 	self.m_delayScheduler = self:getScheduler():scheduleScriptFunc(function() self:setVisible(true) end, self.m_moveTime*0.05, false);

end

function CPlanet:crateTexture()
	local num = math.random(2);
	num = math.random(2);
	self.scale = math.random(3);
	self.m_planetSprite = cc.Sprite:create(resPath .. "planet" .. num ..".png");
	self.m_planetSprite:setScale(0.1 * self.scale);
	self.m_planetSprite:setCascadeOpacityEnabled(true);
	self:add(self.m_planetSprite);

	local spriteWhite = cc.Sprite:create(resPath .. "planet" .. num .. "_1.png");
	spriteWhite:addTo(self.m_planetSprite);
	spriteWhite:setPosition(self.m_planetSprite:getContentSize().width / 2, 
		self.m_planetSprite:getContentSize().height / 2);

	spriteWhite:setCascadeOpacityEnabled(true);
	spriteWhite:setOpacity(125);
	spriteWhite:runAction(self:fadeOutAction());
end

function CPlanet:moveAction()
	local posStart = cc.p(display.cx + 110, display.cy + 50);
	local directionX = math.random(display.width)
	local directionY = math.random(display.height)

	if posStart.x == directionX and posStart.y == directionY then
		directionX = directionX + 100;
	end

	local len_y = directionY - posStart.y;
	local len_x = directionX - posStart.x;

	local tan_yx = math.abs(len_y) / math.abs(len_x);

	if len_x > 0 and len_y < 0  then
		self.m_angle = math.atan(tan_yx)*180 / math.pi;
		self.m_posEnd.x = display.width+100;
		self.m_posEnd.y = display.cy - (display.width+100) * 0.5 * tan_yx;
	elseif len_x < 0 and len_y < 0 then
		self.m_angle = 180 - math.atan(tan_yx)*180 / math.pi;
		self.m_posEnd.x = 0-100;
		self.m_posEnd.y = display.cy - (display.width+100) * 0.5 * tan_yx;
	elseif len_x < 0 and len_y > 0 then
		self.m_angle = 180 + math.atan(tan_yx)*180 / math.pi ;
		self.m_posEnd.x = 0-100;
		self.m_posEnd.y = display.cy + (display.width+100) * 0.5 * tan_yx;
	elseif len_x > 0 and len_y > 0 then
		self.m_angle = - math.atan(tan_yx)*180 / math.pi;
		self.m_posEnd.x = display.width+100;
		self.m_posEnd.y = display.cy + (display.width+100) * 0.5 * tan_yx;
	end

	self:setRotation(self.m_angle);
	--local action = cc.MoveTo:create(self.m_moveTime, self.m_posEnd)
	local function actionCallBack(node)
		self:endAction();
	end
	return cc.Sequence:create(cc.MoveTo:create(self.m_moveTime, self.m_posEnd), cc.CallFunc:create(actionCallBack));
end

function CPlanet:fadeOutAction()
	return  cc.FadeOut:create(self.m_moveTime * 0.3);
end

function CPlanet:scaleAction()
	return cc.ScaleTo:create(self.m_moveTime, math.random(40, 50) / self.scale);
end

function CPlanet:endAction()
	-- if self.m_delayScheduler then
	-- 	self:getScheduler():unscheduleScriptEntry(self.m_delayScheduler);
	-- 	self.m_delayScheduler = nil;
	-- end
	--cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_delayScheduler);
	self:removeAllChildren();
	self:removeSelf();
end

return CPlanet;