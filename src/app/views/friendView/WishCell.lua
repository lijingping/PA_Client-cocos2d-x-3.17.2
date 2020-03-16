---------------
 --  许愿  礼物
---------------
local ResourceMgr = require("app.utils.ResourceMgr");

local WishCell = class("WishCell", cc.Node)

function WishCell:ctor()

end

function WishCell:setIconInfo(info)
	--dump(info)

	--self:setScale(0.8);

	self:removeAllChildren();
	self.m_iconInfo = info;

	--self:addChild(ResourceMgr:createItemNodeJustIcon(info.item_icon));

	--if ItemDataMgr:getWishSelectCell() == data.id then		
		--self:setSelectFrame();
	--end
	local bg = cc.Sprite:create("res/resources/friendView/friend_bg_btn.png");
	self:addChild(bg);
	bg:setPosition(cc.p(69, 54));

	local spriteIconBg = cc.Sprite:create("res/resources/common/item_bg_" .. (info.level+1) ..".png");
	local spriteIcon = cc.Sprite:create("res/resources/itemIcon/"..info.item_icon..".png");
	local spriteIconFrame = cc.Sprite:create("res/resources/common/item_frame_".. (info.level+1) ..".png");
	--local labelIconCount = cc.LabelTTF:create(itemCount, "", 20);

	if spriteIcon == nil then 
		print("缺少icon资源", iconID);
		spriteIcon = cc.Sprite:create("res/resources/itemIcon/99999.png");
	end

	self:addChild(spriteIconBg, ICON_Z_ORDER_BG, ICON_TAG_BG);
	self:addChild(spriteIcon, ICON_Z_ORDER_PIC, ICON_TAG_PIC);
	self:addChild(spriteIconFrame, ICON_Z_ORDER_FRAME, ICON_TAG_FRAME);
	--self:addChild(labelIconCount, ICON_Z_ORDER_COUNT, ICON_TAG_COUNT);

	-- spriteIconBg:setScale(0.8);
	-- spriteIcon:setScale(0.8);
	-- spriteIconFrame:setScale(0.8);

	spriteIconBg:setPosition(cc.p(72, 65));
	spriteIcon:setPosition(cc.p(72, 65));
	spriteIconFrame:setPosition(cc.p(72, 65));
	-- labelIconCount:setPosition(cc.p(100, 8));
	-- labelIconCount:setAnchorPoint(cc.p(1, 0));

	-- 物品名称
	local spriteNameBg = cc.Sprite:create("res/resources/friendView/friend_bg_font.png");
	local labelName = cc.LabelTTF:create(info.name, "", 20);

	self:addChild(spriteNameBg, 10, 10);
	self:addChild(labelName, 11, 11);

	spriteNameBg:setPosition(cc.p(72, 31));
	labelName:setPosition(cc.p(72, 31));

	if UserDataMgr:getPlayerWishItemID() == info.id then
		self:setSelectState();
	end
end

function WishCell:setSelectState()	
	-- 许愿状态
	local spriteSelectTag = cc.Sprite:create("res/resources/friendView/friend_bg_btn1.png");
	self:addChild(spriteSelectTag, 12, 12);
	spriteSelectTag:setPosition(cc.p(72, 102))

	local armature = ResourceMgr:getAnimArmatureByNameOnOthers("fx_item_pitchon");
	armature:getAnimation():play("anim01");
	self:addChild(armature, 13, 13);
	armature:setPosition(cc.p(72, 65));
end

function WishCell:getIconInfo()
	return self.m_iconInfo;
end

return WishCell;