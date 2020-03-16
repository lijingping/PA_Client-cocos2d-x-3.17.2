local ResourceMgr = require("app.utils.ResourceMgr");

local DescripProp = class("DescripProp", cc.Node);

local oneLineHeight = 25;

local whiteColor = cc.c3b(255, 255, 255);
local goldColor = cc.c3b(255, 255, 0);
local pinkColor = cc.c3b(255, 102, 255);
local blueColor = cc.c3b(0, 204, 255);
local grayColor = cc.c3b(204, 204, 204);
local greenColor = cc.c3b(0, 255, 0);

local rankColor = cc.c3b(0, 204, 255);

local scale9Size = cc.size(283, 175);
local beginPos = cc.p(-110, -10);

local TYPE_DAMAGE = 1;
local TYPE_AWARD = 2;

DescripProp.TYPE_DAMAGE = TYPE_DAMAGE;
DescripProp.TYPE_AWARD = TYPE_AWARD;

function DescripProp:ctor(tipType)
	if display.resolution >= 2 then
		self:setScale(display.reduce);
	end
	self.m_tipType = tipType;
	self.m_viewSizeHeight = 0;
end

function DescripProp:setData(data)
	-- dump(data);
	-- self.m_ccbLabelDescContent:setString(data.item_desc);
	-- local contentSize = self.m_ccbLabelDescContent:getContentSize();
	-- local addHeight = contentSize.height - oneLineHeight;
	-- local lineTwoPosY = self.m_ccbLabelCountTitle:getPositionY();
	-- self.m_ccbLabelCountTitle:setPositionY(lineTwoPosY - addHeight);
	-- self.m_ccbLabelCount:setPositionY(lineTwoPosY - addHeight);
	-- self.m_ccbLabelCount:setString(data.items[1].count);

	local totalHeight = beginPos.y;

	self.m_scale9Sprite = cc.Scale9Sprite:create(ResourceMgr:getItemTipFrame());
	self.m_scale9Sprite:setCapInsets(cc.rect(50, 20, 183, 135));
	self.m_scale9Sprite:setAnchorPoint(cc.p(0.5, 1));
	self:addChild(self.m_scale9Sprite);
	-- title
	local titleLabel = cc.LabelTTF:create();
	titleLabel:setFontSize(20);
	titleLabel:setAnchorPoint(cc.p(0, 1));
	self:addChild(titleLabel);
	titleLabel:setPosition(beginPos);
	local itemID = 0;
	if self.m_tipType == TYPE_DAMAGE then
		itemID = data.items[1].item_id;
	elseif self.m_tipType == TYPE_AWARD then
		itemID = data.item_id;
	end
	local itemName = ItemDataMgr:getItemNameByID(itemID);
	local itemLevel = ItemDataMgr:getItemLevelByID(itemID);
	titleLabel:setString(itemName);
	if itemLevel == 0 then
		titleLabel:setColor(grayColor);
	elseif itemLevel == 1 then
		titleLabel:setColor(greenColor);
	elseif itemLevel == 2 then
		titleLabel:setColor(blueColor);
	elseif itemLevel == 3 then
		titleLabel:setColor(pinkColor);
	elseif itemLevel == 4 then
		titleLabel:setColor(goldColor);
	end
	local titleLabelSize = titleLabel:getContentSize();
	totalHeight = totalHeight - titleLabelSize.height - 10;

	local countTitleLabel = cc.LabelTTF:create();
	countTitleLabel:setColor(grayColor);
	countTitleLabel:setFontSize(16);
	countTitleLabel:setAnchorPoint(cc.p(0, 1));
	self:addChild(countTitleLabel);
	countTitleLabel:setPosition(cc.p(beginPos.x, totalHeight));
	countTitleLabel:setString(Str[10013] .. ": ");
	local countTitleLabelSize = countTitleLabel:getContentSize();

	local countLabel = cc.LabelTTF:create();
	countLabel:setColor(grayColor);
	countLabel:setFontSize(16);
	countLabel:setAnchorPoint(cc.p(0, 1));
	self:addChild(countLabel);
	countLabel:setPosition(cc.p(beginPos.x + countTitleLabelSize.width, totalHeight));
	local itemCount = 0;
	if self.m_tipType == TYPE_DAMAGE then
		itemCount = data.items[1].count;
	elseif self.m_tipType == TYPE_AWARD then
		itemCount = data.count or 1;
	end
	countLabel:setString(itemCount);

	totalHeight = totalHeight - countTitleLabelSize.height - 10;

	local descripTitle = cc.LabelTTF:create();
	descripTitle:setColor(grayColor);
	descripTitle:setFontSize(16);
	descripTitle:setAnchorPoint(cc.p(0, 1));
	self:addChild(descripTitle);
	descripTitle:setPosition(cc.p(beginPos.x, totalHeight));
	descripTitle:setString(Str[10014] .. ": ");
	local descripTitleSize = descripTitle:getContentSize();

	local descripLabel = cc.LabelTTF:create();
	descripLabel:setColor(grayColor);
	descripLabel:setFontSize(16);
	descripLabel:setAnchorPoint(cc.p(0, 1));
	self:addChild(descripLabel);
	descripLabel:setDimensions(cc.size(scale9Size.width - descripTitleSize.width - 20, 0));
	descripLabel:setPosition(cc.p(beginPos.x + descripTitleSize.width, totalHeight));
	descripLabel:setString(data.item_desc);
	local descripLabelSize = descripLabel:getContentSize();
	totalHeight = totalHeight - descripLabelSize.height - 10;
	self.m_scale9Sprite:setContentSize(cc.size(scale9Size.width, -totalHeight));
	self.m_viewSizeHeight = -totalHeight;
end

function DescripProp:setHeadData(data)
	scale9Size = cc.size(242, 146);

	local totalHeight = beginPos.y;

	self.m_scale9Sprite = cc.Scale9Sprite:create(ResourceMgr:getItemTipFrame());
	self.m_scale9Sprite:setCapInsets(cc.rect(50, 20, 183, 135));
	self.m_scale9Sprite:setAnchorPoint(cc.p(0.5, 1));
	self:addChild(self.m_scale9Sprite);

	-- 军衔
	local titleLabel = cc.LabelTTF:create();
	titleLabel:setFontSize(20);
	titleLabel:setAnchorPoint(cc.p(0, 1));
	titleLabel:setPosition(beginPos);
	titleLabel:setColor(rankColor);
	titleLabel:setString(Str[5010].."：["..UserDataMgr:getPlayerRankInfo().name.."]");
	self:addChild(titleLabel);

	totalHeight = totalHeight - titleLabel:getContentSize().height - 10;

	local levelLabel = cc.LabelTTF:create();
	levelLabel:setFontSize(16);
	levelLabel:setAnchorPoint(cc.p(0, 1));
	levelLabel:setPosition(cc.p(beginPos.x, totalHeight));
	levelLabel:setString(Str[8006] .. "："..UserDataMgr:getPlayerLevel());
	self:addChild(levelLabel);

	totalHeight = totalHeight - levelLabel:getContentSize().height - 10;

	local expLabel = cc.LabelTTF:create();
	expLabel:setFontSize(16);
	expLabel:setAnchorPoint(cc.p(0, 1));
	expLabel:setPosition(cc.p(beginPos.x, totalHeight));
	expLabel:setString(Str[8007] .. "："..UserDataMgr:getPlayerExp().."/"..UserDataMgr:getPlayerLvExp());
	self:addChild(expLabel);

	totalHeight = totalHeight - expLabel:getContentSize().height - 10;

	local famousLabel = cc.LabelTTF:create();
	famousLabel:setFontSize(16);
	famousLabel:setAnchorPoint(cc.p(0, 1));
	famousLabel:setPosition(cc.p(beginPos.x, totalHeight));

	local rankInfo = UserDataMgr:getPlayerRankInfo();
	famousLabel:setString(Str[8008] .. "："..rankInfo.curExp.."/"..rankInfo.levelUpExp);
	self:addChild(famousLabel);

	totalHeight = totalHeight - famousLabel:getContentSize().height - 10;

	self.m_scale9Sprite:setContentSize(cc.size(scale9Size.width, -totalHeight));
	self.m_viewSizeHeight = -totalHeight;
end

function DescripProp:getScale9PicSize()
	return cc.size(scale9Size.width, self.m_viewSizeHeight);
end

function DescripProp:flushPos(target)
	local posStart = target:getParent():convertToWorldSpace(cc.p(target:getPosition()));
	posStart.x = posStart.x + 137;
	local size = scale9Size;

	-- 设置位置
	local anchor = target:getAnchorPoint();
	local sizeTarget = target:getContentSize();
	local x = posStart.x + sizeTarget.width*(1-anchor.x);
	local y = posStart.y + sizeTarget.height*(1-anchor.y);
	local r = x + size.width;
	local t = y + size.height

	if r > display.width then
		x = posStart.x - (sizeTarget.width*anchor.x) - size.width+9;
	end
	if t > display.height  then
		y = posStart.y - (sizeTarget.height*anchor.y) - size.height;
	end

	self:setPosition(x, y);
end

function DescripProp:setBattleDesc(name, desc)
	self.m_scale9SpriteBattle = cc.Scale9Sprite:create(ResourceMgr:getItemTipFrame());
	self.m_scale9SpriteBattle:setCapInsets(cc.rect(50, 20, 183, 135));
	self.m_scale9SpriteBattle:setAnchorPoint(cc.p(0.5, 1));
	self:addChild(self.m_scale9SpriteBattle);

	local nameLabel = cc.LabelTTF:create();
	nameLabel:setFontSize(18);
	nameLabel:setAnchorPoint(cc.p(0, 1));
	self:addChild(nameLabel);
	nameLabel:setPosition(beginPos);
	nameLabel:setString(name .. ":  ");
	local nameLabelSize = nameLabel:getContentSize();

	local descLabel = cc.LabelTTF:create();
	descLabel:setFontSize(16);
	descLabel:setAnchorPoint(cc.p(0, 1));
	self:addChild(descLabel);
	descLabel:setPosition(cc.p(beginPos.x + nameLabelSize.width, beginPos.y));
	descLabel:setDimensions(cc.size(scale9Size.width - nameLabelSize.width - 20, 0));
	descLabel:setString(desc);
	descLabel:setColor(blueColor);
	local descLabelSize = descLabel:getContentSize();

	self.m_viewSizeHeight = -beginPos.y + descLabelSize.height + 10;

	self.m_scale9SpriteBattle:setContentSize(cc.size(scale9Size.width, self.m_viewSizeHeight));
end

return DescripProp;