local CCBDescripProp = class("CCBDescripProp", function()
	return CCBLoader("ccbi/domainBattleView/CCBDescripProp");
end)

local oneLineHeight = 25;

function CCBDescripProp:ctor(str)
	self.m_ccbLabelAwardTitle:setString(str);
end

function CCBDescripProp:setData(data)
	-- dump(data);
	self.m_ccbLabelDescContent:setString(data.item_desc);
	local contentSize = self.m_ccbLabelDescContent:getContentSize();
	local addHeight = contentSize.height - oneLineHeight;
	local lineTwoPosY = self.m_ccbLabelCountTitle:getPositionY();
	self.m_ccbLabelCountTitle:setPositionY(lineTwoPosY - addHeight);
	self.m_ccbLabelCount:setPositionY(lineTwoPosY - addHeight);
	self.m_ccbLabelCount:setString(data.items[1].count);
end

function CCBDescripProp:getScale9PicSize()
	return self.m_ccbScale9SpriteBg:getContentSize();
end

function CCBDescripProp:setRankAwardData(data)
	self.m_ccbLabelDescContent:setString(data.item_desc);
	local contentSize = self.m_ccbLabelDescContent:getContentSize();
	local addHeight = contentSize.height - oneLineHeight;
	local lineTwoPosY = self.m_ccbLabelCountTitle:getPositionY();
	self.m_ccbLabelCountTitle:setPositionY(lineTwoPosY - addHeight);
	self.m_ccbLabelCount:setPositionY(lineTwoPosY - addHeight);
	self.m_ccbLabelCount:setString("1");
end

return CCBDescripProp;