--------------------
-- 好友请求的物品ICON
--------------------

local ResourceMgr = require("app.utils.ResourceMgr");

local PresentIcon = class("PresentIcon", cc.Node)

function PresentIcon:ctor(itemID)
	self:setScale(0.8);
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);

	local spriteIconBg = cc.Sprite:create("res/resources/common/item_bg_" .. (itemLevel+1) .. ".png");
	local spriteIcon = cc.Sprite:create("res/resources/itemIcon/" .. iconID ..".png");
	local spriteIconFrame = cc.Sprite:create("res/resources/common/item_frame_" .. (itemLevel+1) .. ".png");

	if spriteIcon == nil then 
		print("缺少icon资源", iconID);
		spriteIcon = cc.Sprite:create("res/resources/itemIcon/99999.png");
	end

	self:addChild(spriteIconBg, ICON_Z_ORDER_BG, ICON_TAG_BG);
	self:addChild(spriteIcon, ICON_Z_ORDER_PIC, ICON_TAG_PIC);
	self:addChild(spriteIconFrame, ICON_Z_ORDER_FRAME, ICON_TAG_FRAME);
end

return PresentIcon