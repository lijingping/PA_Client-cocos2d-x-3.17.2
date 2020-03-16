local CCBReceiveItemCell = class("CCBReceiveItemCell", function()
	return CCBLoader("ccbi/commonCCB/CCBReceiveItemCell.ccbi")
end)

-- local friendPresentCount_4004 = 0;
-- local friendPresentCount_2999 = 0;
-- local friendPresentCount_2998 = 0;
-- local friendPresentCount_2997 = 0;

function CCBReceiveItemCell:ctor()

end

function CCBReceiveItemCell:setData(data)
	-- dump(data)
	self:cleanData()
	if data.count ~= 0 then
		self.data = data;
		self.m_ccbLabelItemCount:setString(data.count);
		self:getIconByData(data.item_id);
	end
	-- self:setReceiveCount(data);
end

function CCBReceiveItemCell:cleanData()
	self.m_ccbLabelItemCount:setString("")
	self.m_ccbNodeItemBg:removeAllChildren();
	self.m_ccbNodeItemImg:removeAllChildren();
end

function CCBReceiveItemCell:getIconByData(itemID)
	-- print("------------获取礼物图片")
	local itemData = ItemDataMgr:getItemBaseInfo(itemID)
	-- dump(itemData)
	if itemData ~= nil then
		local m_spriteItemIcon = cc.Sprite:create("res/itemIcon/" .. itemData.item_icon .. ".png")
		-- m_spriteItemIcon:setPreferredSize(cc.size(100,100));
		m_spriteItemIcon:setScale(0.77);
		self.m_ccbNodeItemImg:addChild(m_spriteItemIcon);
		 -- print("itemData.level", itemData.level)
		if itemData.level == 1 then 
			self.m_spriteItemIconBg = cc.Sprite:create("res/resources/common/item_bg_0.png");
		elseif itemData.level == 2 then 
			self.m_spriteItemIconBg = cc.Sprite:create("res/resources/common/item_bg_1.png")
		elseif itemData.level == 3 then
			self.m_spriteItemIconBg = cc.Sprite:create("res/resources/common/item_bg_2.png")
		elseif itemData.level == 4 then
			self.m_spriteItemIconBg = cc.Sprite:create("res/resources/common/item_bg_3.png");
		elseif itemData.level == 5 then
			self.m_spriteItemIconBg = cc.Sprite:create("res/resources/common/item_bg_4.png");
		end
		-- self.m_spriteItemIconBg:setPreferredSize(cc.size(100,100));
		self.m_spriteItemIconBg:setScale(0.77)
		self.m_ccbNodeItemBg:addChild(self.m_spriteItemIconBg);
	end
end

function CCBReceiveItemCell:setReceiveImgByState(state)
	if state == 4 then

	end
end

return CCBReceiveItemCell