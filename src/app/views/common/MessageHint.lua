local ResourceMgr = require("app.utils.ResourceMgr");

local MessageHint = class("MessageHint", cc.Node)

local tipStayTime = 10;

function MessageHint:onEnter()

end

function MessageHint:onExit()   -- removeSelf 的时候都会进来。
	if self.m_scheduler then 
		self:getScheduler():unscheduleScriptEntry(self.m_scheduler);
		self.m_scheduler = nil;
		self.m_removeFromList(self.m_index);
	end
end

function MessageHint:ctor(pos, str, index)

	self.m_time = tipStayTime;
	self.m_index = index;
	self:enableNodeEvents();
	
	if display.resolution >= 2 then
		self:setScale(display.reduce);
	end

	self:setCascadeOpacityEnabled(true);
	-- dump(App:getRunningScene());
	self:addTo(App:getRunningScene(), display.Z_MESSAGE_HINT);
	self:setPosition(pos);

	self.m_node = cc.Node:create();
	self:addChild(self.m_node);
	local spriteBg = cc.Sprite:create(ResourceMgr:getRevengeTipBg());
	self.m_node:addChild(spriteBg);

	local bgSize = spriteBg:getContentSize();
	self.m_node:setPositionX(display.width - pos.x + bgSize.width / 2);

	local contentLabel = cc.LabelTTF:create();
	contentLabel:setPosition(-200, 15);
	self.m_node:addChild(contentLabel);
	contentLabel:setAnchorPoint(cc.p(0, 0.5));
	contentLabel:setFontSize(20);
	contentLabel:setString(str);

	local tip = cc.LabelTTF:create();
	tip:setPosition(contentLabel:getPositionX(), contentLabel:getPositionY()-35);
	tip:setAnchorPoint(cc.p(0, 0.5));
	tip:setFontSize(20);
	tip:setString(Str[4050]);
	tip:setColor(cc.c3b(254, 251, 0));
	tip:addTo(self.m_node);

	local ensureBtn = ccui.Button:create(ResourceMgr:getRevengeBtnAccaptNormal(), ResourceMgr:getRevengeBtnAccaptHigh(), ResourceMgr:getRevengeBtnAccaptHigh());
	self.m_node:addChild(ensureBtn);
	ensureBtn:setPositionX(78);
	-- ensureBtn:setTitleText(Str[1001]);
	-- ensureBtn:setTitleFontSize(20);
	ensureBtn:addClickEventListener(function()
		self.m_ensurefunc();
		if self.m_scheduler then
			self:getScheduler():unscheduleScriptEntry(self.m_scheduler);
			self.m_scheduler = nil;
		end
		self.m_removeFromList(self.m_index);
		self.m_moveUpMember(self.m_index);
		self:removeSelf();
	end)

	local cancelBtn = ccui.Button:create(ResourceMgr:getRevengeBtnRejectNormal(), ResourceMgr:getRevengeBtnRejectHigh(), ResourceMgr:getRevengeBtnRejectHigh());
	self.m_node:addChild(cancelBtn);
	cancelBtn:setPositionX(200);
	-- cancelBtn:setTitleText(Str[1002]);
	-- cancelBtn:setTitleFontSize(20);
	cancelBtn:addClickEventListener(function()
		self.m_cancelfunc();
		if self.m_scheduler then
			self:getScheduler():unscheduleScriptEntry(self.m_scheduler);
			self.m_scheduler = nil;
		end
		self.m_removeFromList(self.m_index);
		self.m_moveUpMember(self.m_index);
		self:removeSelf();
	end) 

	self.m_scheduler = self:getScheduler():scheduleScriptFunc(function(dt) self:countTime(dt); end, 1, false);

	self.m_node:setCascadeOpacityEnabled(true);
	self.m_node:setOpacity(0);
	local moveTo = cc.MoveTo:create(0.5, cc.p(0, 0));
	local fadeIn = cc.FadeIn:create(0.5);
	local spawnAction = cc.Spawn:create(moveTo, fadeIn);

	self.m_node:runAction(spawnAction);
end

function MessageHint:onBtnEnsure(callback)
	self.m_ensurefunc = callback;
end

function MessageHint:onBtnCancel(callback)
	self.m_cancelfunc = callback;
end

function MessageHint:countTime(dt)
	self.m_time = self.m_time - 1;
	if self.m_time <= 0 then
		self.m_cancelfunc();
		self:getScheduler():unscheduleScriptEntry(self.m_scheduler);
		self.m_scheduler = nil;
		self.m_removeFromList(self.m_index);
		self:removeSelf();
	end
end

-- 从复仇提示列表移除自己
function MessageHint:removeSelfFromListByIndex(callback)
	self.m_removeFromList = callback;
end

-- 移除了自己，向上移动下面的请求
function MessageHint:moveUpPreMember(callback)
	self.m_moveUpMember = callback;
end

return MessageHint;