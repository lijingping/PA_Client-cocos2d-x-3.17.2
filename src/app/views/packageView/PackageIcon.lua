local ResourceMgr = require("app.utils.ResourceMgr")

local PackageIcon = class("PackageIcon", cc.Node)

local itemCountBgPos = cc.p(70, 22);
local itemEquipSuitPos = cc.p(70, 81);

function PackageIcon:ctor(itemID)
	-- print("create Item iconID:", itemID);

	self:setContentSize(114, 114);
	self:setAnchorPoint(0.5, 0.5);

	if itemID == nil then
		self.m_itemID = 0;
		local spriteIconBg = cc.Sprite:create(ResourceMgr:getItemNodeBg());
		self:addChild(spriteIconBg, ICON_Z_ORDER_BG, ICON_TAG_BG);
		spriteIconBg:setPosition(cc.p(57, 57));
	else
		self.m_itemID = itemID;
		local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
		local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);
		local itemCount = ItemDataMgr:getItemCount(itemID);

		local spriteIconBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(itemLevel + 1));
		local spriteIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(iconID));
		local spriteCountBg = cc.Sprite:create(ResourceMgr:getItemCountBg());
		local spriteIconFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(itemLevel + 1));
		local labelIconCount = cc.LabelTTF:create(itemCount, "", 20);

		local equipItemData = ItemDataMgr:getAllEquipSlot();
		for i = 1, #equipItemData do 
			if itemID == equipItemData[i] then
				local spriteIconSuit = cc.Sprite:create(ResourceMgr:getMarkEquipSprite());
				self:addChild(spriteIconSuit, ICON_Z_ORDER_EQUIPPED, ICON_TAG_EQUIPPED);
				spriteIconSuit:setPosition(itemEquipSuitPos);
				break;
			end
		end

		if spriteIcon == nil then 
			print("缺少icon资源", iconID);
			spriteIcon = cc.Sprite:create("res/itemIcon/99999.png");
		end

		self:addChild(spriteIconBg, ICON_Z_ORDER_BG, ICON_TAG_BG);
		self:addChild(spriteIcon, ICON_Z_ORDER_PIC, ICON_TAG_PIC);
		self:addChild(spriteCountBg, ICON_Z_ORDER_COUNT_BG, ICON_TAG_COUNT_BG);
		self:addChild(spriteIconFrame, ICON_Z_ORDER_FRAME, ICON_TAG_FRAME);
		self:addChild(labelIconCount, ICON_Z_ORDER_COUNT, ICON_TAG_COUNT);

		spriteIconBg:setPosition(cc.p(57, 57));
		spriteIcon:setPosition(cc.p(57, 57));
		spriteCountBg:setPosition(itemCountBgPos);
		spriteIconFrame:setPosition(cc.p(57, 57));
		labelIconCount:setPosition(cc.p(100, 22));
		labelIconCount:setAnchorPoint(cc.p(1, 0.5));
	end
end

function PackageIcon:getItemID()
	return self.m_itemID;
end

function PackageIcon:changeInfo(itemID)
	-- print("changeInfo:", itemID)
	self.m_itemID = itemID;

	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	local iconID = ItemDataMgr:getItemIconIDByItemID(itemID);
	local itemCount = ItemDataMgr:getItemCount(itemID);

	local spriteIconBg = self:getChildByTag(ICON_TAG_BG);
	if spriteIconBg then
		spriteIconBg:setTexture(ResourceMgr:getItemBGByQuality(itemLevel + 1));
	end

	local spriteIcon = self:getChildByTag(ICON_TAG_PIC);
	if spriteIcon == nil then
		spriteIcon = cc.Sprite:create();
		spriteIcon:setPosition(cc.p(57, 57));
		self:addChild(spriteIcon, ICON_Z_ORDER_PIC, ICON_TAG_PIC);
	end
	spriteIcon:setTexture(ResourceMgr:getItemIconByID(iconID));

	local spriteCountBg = self:getChildByTag(ICON_TAG_COUNT_BG);
	if spriteCountBg == nil then
		spriteCountBg = cc.Sprite:create();
		spriteCountBg:setPosition(itemCountBgPos);
		self:addChild(spriteCountBg, ICON_Z_ORDER_COUNT_BG, ICON_TAG_COUNT_BG);
	end
	spriteCountBg:setTexture(ResourceMgr:getItemCountBg());

	local spriteIconFrame = self:getChildByTag(ICON_TAG_FRAME);
	if spriteIconFrame == nil then
		spriteIconFrame = cc.Sprite:create();
		spriteIconFrame:setPosition(cc.p(57, 57));
		self:addChild(spriteIconFrame, ICON_Z_ORDER_FRAME, ICON_TAG_FRAME);
	end
	spriteIconFrame:setTexture(ResourceMgr:getItemBoxFrameByQuality(itemLevel + 1));

	local labelIconCount = self:getChildByTag(ICON_TAG_COUNT);
	if labelIconCount == nil then
		labelIconCount = cc.LabelTTF:create("", "", 20);
		labelIconCount:setPosition(cc.p(100, 22));
		labelIconCount:setAnchorPoint(cc.p(1, 0.5));
		self:addChild(labelIconCount, ICON_Z_ORDER_COUNT, ICON_TAG_COUNT);
	end
	labelIconCount:setString(itemCount);

	local spriteIconSuit = self:getChildByTag(ICON_TAG_EQUIPPED);
	local isSuit = false;
	local equipItemData = ItemDataMgr:getAllEquipSlot();
	for i = 1, #equipItemData do 
		if itemID == equipItemData[i] then
			isSuit = true;
			break;
		end
	end
	if isSuit then
		if spriteIconSuit == nil then
			local spriteIconSuit = cc.Sprite:create(ResourceMgr:getMarkEquipSprite());
			self:addChild(spriteIconSuit, ICON_Z_ORDER_EQUIPPED, ICON_TAG_EQUIPPED);
			spriteIconSuit:setPosition(itemEquipSuitPos);
		end
	else
		if spriteIconSuit then
			spriteIconSuit:removeFromParent();
			spriteIconSuit = nil;
		end
	end
end

function PackageIcon:changeToNone()
	self.m_itemID = 0;

	local spriteIconBg = self:getChildByTag(ICON_TAG_BG);
	if spriteIconBg then
		spriteIconBg:setTexture(ResourceMgr:getItemNodeBg());
	end
	local spriteIcon = self:getChildByTag(ICON_TAG_PIC);
	if spriteIcon then
		self:removeChildByTag(ICON_TAG_PIC);
		spriteIcon = nil;
	end
	local spriteCountBg = self:getChildByTag(ICON_TAG_COUNT_BG);
	if spriteCountBg then
		self:removeChildByTag(ICON_TAG_COUNT_BG);
		spriteCountBg = nil;
	end
	local spriteIconFrame = self:getChildByTag(ICON_TAG_FRAME);
	if spriteIconFrame then
		self:removeChildByTag(ICON_TAG_FRAME);
		spriteIconFrame = nil;
	end
	local labelIconCount = self:getChildByTag(ICON_TAG_COUNT);
	if labelIconCount then
		self:removeChildByTag(ICON_TAG_COUNT);
		labelIconCount = nil;
	end
	local spriteIconSuit = self:getChildByTag(ICON_TAG_EQUIPPED);
	if spriteIconSuit then
		self:removeChildByTag(ICON_TAG_EQUIPPED);
		spriteIconSuit = nil;
	end
end

function PackageIcon:setSelectState(isSelect)
	-- print("PackageIcon:setSelectState:", isSelect)
	if isSelect then
		local spriteSelect = self:getChildByTag(ICON_TAG_SELECTED)
		if spriteSelect == nil then
			spriteSelect = cc.Sprite:create(ResourceMgr:getItemSelectFrame());
			spriteSelect:setPosition(cc.p(57, 57));
			self:addChild(spriteSelect, ICON_Z_ORDER_SELECTED, ICON_TAG_SELECTED)
		end
	else
		local spriteSelect = self:getChildByTag(ICON_TAG_SELECTED)
		if spriteSelect then
			self:removeChildByTag(ICON_TAG_SELECTED)
			spriteSelect = nil;
		end
	end
end

function PackageIcon:isChild()
	if self:getChildByTag(ICON_TAG_SELECTED) then
		return true;
	else
		return false;
	end
end

return PackageIcon;