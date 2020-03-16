-----------------
-- 商品列表子控件
-----------------
local ResourceMgr = require("app.utils.ResourceMgr");

local CCBShopItemCell = class("CCBShopItemCell", function ()
	return CCBLoader("ccbi/shopView/CCBShopItemCell.ccbi")
end)

local orangeColor = cc.c3b(255, 124, 0);
local yellowColor = cc.c3b(255, 255, 51);

function CCBShopItemCell:ctor( ... )
	-- body
	self:init()
end

function CCBShopItemCell:init()
	-- local bg_sprite = cc.Scale9Sprite:create("resources/common/ui_btn_smallgreen_n.png")
	-- bg_sprite:setScaleY(1.5);
	
	-- local richText = ccui.RichText:create()

 --    local reimg = ccui.RichElementImage:create(2, cc.c3b(255, 255, 255), 255, "res/images/ui_gold01_button.png")
 --    local text = ccui.RichElementText:create(1, cc.c3b(255, 255, 255), 255, "0", "font/simhei.ttf", 25)

 --    richText:pushBackElement(reimg)
 --    richText:pushBackElement(text)
end

function CCBShopItemCell:setData(data)
	self.m_data = data
	self:cleanData();
	-- dump(data);
	-- "<var>" = {
	--     "count"   = 1
	--     "desc"    = "商城购买，对指定好友增加大量的亲密度"
	--     "double"  = 0
	--     "id"      = 40
	--     "item_id" = 4011
	--     "items" = {
	--         1 = {
	--             "count"   = 50
	--             "item_id" = 10002
	--         }
	--     }
	--     "name"    = "外交证书"
	--     "order"   = 5
	--     "type"    = "props"
	-- }
	print(" data.item_id ", data.item_id);
	self.m_ccbLabelTitle:setString(data.name)
	local item = ItemDataMgr:getItemBaseInfo(data.item_id)
	-- dump(item);
	-- "<var>" = {
	--     "button_type" = 2
	--     "cd"          = -1
	--     "desc"        = "商城购买，对指定好友增加大量的亲密度"
	--     "equipable"   = 0
	--     "id"          = 4011
	--     "item_icon"   = 4011
	--     "item_origin" = {
	--         "origin_1" = "8"
	--     }
	--     "level"       = 3
	--     "name"        = "外交证书"
	--     "type"        = 6
	--     "use_limit"   = -1
	-- }
	self:setIcon(item);
	local payIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(data.items[1].item_id));
	self.m_ccbNodeDiamondIcon:addChild(payIcon);
	payIcon:setScale(0.5);
	self.m_ccbLabelDiamondsCount:setString(data.items[1].count);
	self:setConditionLabel();
end

-- 设置炮台Icon
function CCBShopItemCell:setIcon(data)
	local spriteIconBg = cc.Sprite:create(ResourceMgr:getItemBGByQuality(data.level + 1));
	self.m_ccbNodeFortIcon:addChild(spriteIconBg);
	local spriteIcon = cc.Sprite:create(ResourceMgr:getItemIconByID(data.item_icon));
	if spriteIcon == nil then
		spriteIcon = cc.Sprite:create("res/itemIcon/xxx.png");
	end
	self.m_ccbNodeFortIcon:addChild(spriteIcon);
	local spriteIconFrame = cc.Sprite:create(ResourceMgr:getItemBoxFrameByQuality(data.level + 1));
	self.m_ccbNodeFortIcon:addChild(spriteIconFrame);
end

function CCBShopItemCell:setConditionLabel()
	if self.m_data.require_alliance_level ~= 0 and self.m_data.require_alliance_level > UserDataMgr:getPlayerUnionLevel() then
		self.m_ccbLabelBuyCondition:setString(Str[16001] .. self.m_data.require_alliance_level);
		self.m_ccbLabelBuyCondition:setColor(orangeColor);
	elseif self.m_data.contribution ~= 0 and self.m_data.contribution > UserDataMgr:getPlayerContribution() then
		self.m_ccbLabelBuyCondition:setString(Str[16002] .. self.m_data.contribution);
		self.m_ccbLabelBuyCondition:setColor(orangeColor);
	elseif self.m_data.day_limit ~= 0 then
		local itemBuyTimes = ItemDataMgr:getBuyTimes()[self.m_data.id];
		itemBuyTimes = (itemBuyTimes and itemBuyTimes or 0);
		self.m_ccbLabelBuyCondition:setString(Str[16003] .. itemBuyTimes .. "/" .. self.m_data.day_limit);
		self.m_ccbLabelBuyCondition:setColor(yellowColor);
	else
		self.m_ccbLabelBuyCondition:setString("");
	end
end

function CCBShopItemCell:onBtnBuyClicked()
	App:getRunningScene():getViewBase():showSetAmountPopup(self.m_data, self);
end

-- 清楚数据
function CCBShopItemCell:cleanData()
	self.m_ccbNodeFortIcon:removeAllChildren();
	self.m_ccbNodeDiamondIcon:removeAllChildren();
end

function CCBShopItemCell:getItemData()
	return self.m_data;
end

return CCBShopItemCell