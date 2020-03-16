local PropDescPop = class("PorpDescPop", cc.Node);

local colorBlue = cc.c3b(42, 247, 247);
local colorWhite = cc.c3b(255, 255, 255);
local colorGreen = cc.c3b(0, 204, 51);

function PropDescPop:ctor()
	local scale9Bg = ccui.Scale9Sprite:create("res/resources/common/ui_interface_second_60_10_60_10.png");
	self:addChild(scale9Bg);
	scale9Bg:setAnchorPoint(cc.p(0.5, 0.5));

	self:setCascadeOpacityEnabled(true); -- 設置可改變透明度
	self:setOpacity(0);

	scale9Bg:setCapInsets(cc.rect(60, 10, 10, 50));
	scale9Bg:setContentSize(cc.size(300, 50));

	local richText = ccui.RichText:create();
	richText:ignoreContentAdaptWithSize(false);
	richText:setSize(cc.size(280, 45));
	local title = ccui.RichElementText:create(1, colorBlue, 255, "道具介绍：", "", 20);
	local strDesc = "这奇怪的导弹吧!";
	local content = ccui.RichElementText:create(2, colorWhite, 255, strDesc, "", 20);
	local content1 = ccui.RichElementText:create(3, colorGreen, 255, "攻击敌方单个炮台并附加燃烧效果", "", 20);
	richText:pushBackElement(title);
	richText:pushBackElement(content);
	richText:pushBackElement(content1);
	self:addChild(richText);
	richText:setPosition(0, -2);
	-- dump(richText:getContentSize());

	local fadeInAction = cc.FadeIn:create(0.5);
	self:runAction(fadeInAction);
end

return PropDescPop;