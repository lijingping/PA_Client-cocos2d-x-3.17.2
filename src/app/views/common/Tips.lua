-------------------
--    新版本Tips
-------------------
local Tips = class("Tips", cc.Node);

function Tips:ctor(str)
	if str == nil then
		return;
	end

	if tostring(str) == "" then
		return;
	end

	if string.len(tostring(str)) == 0 then
		return;
	end

	local tipSprite = cc.Sprite:create("res/resources/common/ui_hint_frame2.png");
	tipSprite:setPosition(cc.p(0, 5));
	self:addChild(tipSprite);

	local tipLabel = cc.LabelTTF:create();
	tipLabel:setFontSize(20);
	tipLabel:setString(str);
	self:addChild(tipLabel);

	self:setCascadeOpacityEnabled(true);
	local moveByAction = cc.MoveBy:create(0.8, cc.p(0, 120));
	local fadeOutAction = cc.FadeOut:create(1.5);
	local removeSelfAction = cc.CallFunc:create(function() self:removeSelf() end);
	
	local spawnAction = cc.Spawn:create(moveByAction, fadeOutAction);
	local seqAction = cc.Sequence:create(spawnAction, removeSelfAction);
	self:runAction(seqAction);

	if display.resolution  >= 2 then
        self:setScale(display.reduce);
    end

	self:addTo(App:getRunningScene(), display.Z_STR_TIPS);
	self:setPosition(display.cx, display.cy + 70);
end

return Tips;