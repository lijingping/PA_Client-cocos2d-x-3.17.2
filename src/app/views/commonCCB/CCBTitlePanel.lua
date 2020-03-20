-- 标题栏

VIEW_RESOURCE = 1;
VIEW_SHOP = 2;
VIEW_PRODUCE = 3;
VIEW_MAIL = 4;
local ITEM_KEY_ID = 4009;

local CCBExchangeCoin = require("app.views.commonCCB.CCBExchangeCoin");
local CCBExchangeDiamond = require("app.views.commonCCB.CCBExchangeDiamond");

local CCBTitlePanel = class("CCBTitlePanel", function ()
	return CCBLoader("ccbi/commonCCB/CCBTitlePanel.ccbi")
end)

function CCBTitlePanel:ctor(title)
	if title then
		local titleSprite = cc.Sprite:create("res/font/" .. title .. ".png");
		self.m_ccbNodeTitleSprite:addChild(titleSprite);
	end
	self.m_ccbNodeFriendship:setVisible(false);
	self:setInfo();

	self.m_ccbScale9SpriteBg:setPositionX(self.m_ccbScale9SpriteBg:getInsetLeft()*0.5)
end

function CCBTitlePanel:setInfo()
	local playerGoldCoin = UserDataMgr:getPlayerGoldCoin();
	local playerDiamond = UserDataMgr:getPlayerDiamond();
	local playerFriendship = UserDataMgr:getFriendshipPoint();
	local decomposeCoin = UserDataMgr:getPlayerDecomposeCoin();
	local leagueCoin = UserDataMgr:getPlayerUnionCoin();

	if playerGoldCoin >= 100000 then
		self.m_ccbLabelGold:setString(string.format("%d万", math.floor(playerGoldCoin / 10000)));
	else
		self.m_ccbLabelGold:setString(playerGoldCoin);
	end

	if playerDiamond >= 100000 then
		self.m_ccbLabelDiamond:setString(string.format("%d万", math.floor(playerDiamond / 10000)));
	else
		self.m_ccbLabelDiamond:setString(playerDiamond);
	end

	if playerFriendship >= 100000 then
		self.m_ccbLabelFriendship:setString(string.format("%d万", math.floor(playerFriendship / 10000)));
	else
		self.m_ccbLabelFriendship:setString(playerFriendship);
	end

	if decomposeCoin >= 100000 then
		self.m_ccbLabelResolvePoint:setString(string.format("%d万", math.floor(decomposeCoin / 10000)));
	else
		self.m_ccbLabelResolvePoint:setString(decomposeCoin);
	end
	
	local keyItemCount = ItemDataMgr:getItemCount(ITEM_KEY_ID);
	if keyItemCount >= 100000 then
		self.m_ccbLabelKey:setString(string.format("%d万", math.floor(keyItemCount / 10000)));
	else
		self.m_ccbLabelKey:setString(keyItemCount);
	end

	if leagueCoin >= 100000 then
		self.m_ccbLabelLeague:setString(string.format("%d万", math.floor(leagueCoin / 10000)));
	else
		self.m_ccbLabelLeague:setString(leagueCoin);
	end
end

function CCBTitlePanel:updateInfo()
	self:setInfo();
end

function CCBTitlePanel:onBtnBack()
	--实现写在外部，此函数当做虚函数，不在这实现
end

function CCBTitlePanel:onBtnAddGold()
	print("兑换去");
	CCBExchangeCoin:create();
end

function CCBTitlePanel:onBtnAddDiamond()
	print("充值去");
	CCBExchangeDiamond:create();
end

function CCBTitlePanel:onBtnKey()
	App:enterScene("ShopScene"):getViewBase():setLastSceneName(self.m_strLastSceneName);
end

function CCBTitlePanel:onBtnLeague()
	App:enterScene("ShopScene"):getViewBase():setLastSceneName(self.m_strLastSceneName);
end

function CCBTitlePanel:showNodeFriendship()
	self.m_ccbNodeFriendship:setVisible(true);
end

function CCBTitlePanel:hideNodeFriendship()
	self.m_ccbNodeFriendship:setVisible(false);
end

function CCBTitlePanel:showNodeResolvePoint()
	self.m_ccbNodeResolvePoint:setVisible(true);
end

function CCBTitlePanel:hideNodeResolvePoint()
	self.m_ccbNodeResolvePoint:setVisible(false);
end

function CCBTitlePanel:showNodeKey()
	self.m_ccbNodeKey:setVisible(true);
end

function CCBTitlePanel:hideNodeKey()
	self.m_ccbNodeKey:setVisible(false);
end

function CCBTitlePanel:setLastSceneName(name)
	self.m_strLastSceneName = name;
end

function CCBTitlePanel:getLastSceneName()
	return self.m_strLastSceneName;
end

function CCBTitlePanel:showNodeLeague()
	self.m_ccbNodeLeague:setVisible(true);
end

function CCBTitlePanel:hideNodeLeague()
	self.m_ccbNodeLeague:setVisible(false);
end

return CCBTitlePanel