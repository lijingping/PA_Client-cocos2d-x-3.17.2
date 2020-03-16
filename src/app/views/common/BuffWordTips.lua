local BattleResourceMgr = require("app.utils.BattleResourceMgr");

local BuffWordTips = class("BuffWordTips", cc.Node);

---------------------------
---   buff类型文字提示
---------------------------
function BuffWordTips:ctor(buffID)
	-- body
	-- 动作描述:原地放大，之后，上移继续放大同时淡出
	local sprite = cc.Sprite:create(BattleResourceMgr:getBattleBuffWordByBuffID(buffID));
	if sprite == nil then
		self:removeSelf();
		return;
	end
	self:addChild(sprite);
	self:setCascadeOpacityEnabled(true); -- 設置可改變透明度
	local scaleTo = cc.ScaleTo:create(0.3, 1.2);

	local moveUp = cc.MoveBy:create(0.6, cc.p(0, 50));
	local scaleMoreBig = cc.ScaleTo:create(0.6, 1.4);
	local fadeOut = cc.FadeOut:create(0.6);
	local spawn = cc.Spawn:create(moveUp, scaleMoreBig, fadeOut);

	local callback = cc.CallFunc:create(function()
		self:removeSelf();
	end)

	local sequence = cc.Sequence:create(scaleTo, spawn, callback);
	self:runAction(sequence);
end


return BuffWordTips;