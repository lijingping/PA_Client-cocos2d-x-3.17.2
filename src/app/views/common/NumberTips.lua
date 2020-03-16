------------------------------
--     伤害数值提示显示     --
------------------------------

local NumberTips = class("NumberTips", cc.Node);

-- 注释：str 要输入的文字；kind：number，显示数字的种类， 有三种，绿色（生命恢复）， 蓝色（能量恢复）， 红色（血量恢复）
function NumberTips:ctor(str, kind, side)
	self.m_labelBMFont = nil;
	if kind == 1 then
		self.m_labelBMFont = cc.LabelBMFont:create(str, "res/font/recovery.fnt");
	end
	if kind == 2 then
		self.m_labelBMFont = cc.LabelBMFont:create(str, "res/font/energy.fnt");
	end
	if kind == 3 then
		self.m_labelBMFont = cc.LabelBMFont:create(str, "res/font/damage.fnt");
	end
	if kind == 4 then
		self.m_labelBMFont = cc.LabelBMFont:create(str, "res/font/skill.fnt");
	end
	self:addChild(self.m_labelBMFont);
 -- 第一阶段
 	-- local moveValueX = math.random(0, 15);
 	-- local moveValueY = math.random(10, 15);
 -- 	local moveAction_stepOne = cc.MoveBy:create(0.2, cc.p(20, 60));

 -- 	-- local scaleValue = math.random(1, 5);
 -- 	local scaleAction_stepOne = cc.ScaleTo:create(0.2, 1.2);
 -- 	local spawnAction_stepOne = cc.Spawn:create(moveAction_stepOne, scaleAction_stepOne);
 -- -- 第二阶段
 -- 	local moveAction_stepTwo = cc.MoveBy:create(0.16, cc.p(0, 10));

 -- -- 第三阶段

 -- 	local fadeAction_stepThree = cc.FadeOut:create(0.16);
 -- 	local spawnAction_stepThree = cc.Spawn:create(moveAction_stepThree, fadeAction_stepThree);

 	self:setCascadeOpacityEnabled(true);
 	local moveAction = nil;
 	if side == 1 then
 		moveAction = cc.MoveBy:create(0.5, cc.p(-20, 45));
 	else
 		moveAction = cc.MoveBy:create(0.5, cc.p(20, 45));
 	end
 	local easeAction = cc.EaseSineOut:create(moveAction); -- slow to quick

 	-- local scaleValue = math.random(1, 4);
 	local scaleAction = cc.ScaleTo:create(0.5, 1.2); 

 	-- self.m_moveSchedule = nil;
 	-- local schduleToMove = function () 
 	-- 	if self.m_moveSchedule == nil then
 	-- 		self.m_moveSchedule = self:getSchedule():scheduleScriptFunc(function(dt) self:onUpdate(dt) end, 0, false);
 	-- 	end
 	-- end

 	local fadeOutAction = cc.FadeOut:create(0.3);
 	local sequenceAction1 = cc.Sequence:create(cc.DelayTime:create(0.2), fadeOutAction);
 	local spawnActionTwo = cc.Spawn:create(easeAction, scaleAction, sequenceAction1);

	local removeCallBack = cc.CallFunc:create(function ()
		self:removeSelf();
		end);
	local sequenceAction = cc.Sequence:create(spawnActionTwo, removeCallBack);
	self:runAction(sequenceAction);
end

-- function NumberTips:onUpdate(dt)

-- end

return NumberTips;