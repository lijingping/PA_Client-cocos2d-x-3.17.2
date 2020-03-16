----------------------
-- UI界面的标题栏控件
----------------------
local CCBHeadBar = class("CCBHeadBar", function ()
	return CCBLoader("ccbi/commonCCB/CCBHeadBar.ccbi")
end)

local g_pathSrpiteSceneName = {resourceView = "res/font/resourceView/ui_repository_font0009.png",

};

function CCBHeadBar:ctor(title, closeCallback, coinCallback, diamondCallback)
	if display.resolution >= 2 then
		self:setScale(display.reduce);
	end

	self.closeCallback = closeCallback
	self.coinCallback = coinCallback
	self.diamondCallback = diamondCallback


	self.data = nil;
	self.m_titleName = title;
	self:setData()
end

-- 根据数据更新
function CCBHeadBar:setData()


	local PlayerGoldCoin = UserDataMgr:getPlayerGoldCoin()
	local playerDiamond = UserDataMgr:getPlayerDiamond()

	if self.m_titleName ~= nil then
		self.m_ccbSpriteSceneName:setTexture("res/font/" .. self.m_titleName .. ".png");
	end

	if PlayerGoldCoin >= 1000000 then
		PlayerGoldCoin = string.format("%d万", math.floor(PlayerGoldCoin / 10000))
	end

	if playerDiamond >= 1000000 then
		playerDiamond = string.format("%d万", math.floor(playerDiamond / 10000))
	end
	self.m_ccbLabelCoin:setString(PlayerGoldCoin)
	self.m_ccbLabelDiamond:setString(playerDiamond)
end

function CCBHeadBar:movePos()
	-- print("headBar的heightPosition", self.m_ccbNodeTop:getPositionY())
	local TopY = self.m_ccbNodeTop:getPositionY();
	local BotY = self.m_ccbNodeBottom:getPositionY();
	local BotX = self.m_ccbNodeBottom:getPositionX();
	local RightX = self.m_ccbNodeRight:getPositionX();
	local LeftX = self.m_ccbNodeLeft:getPositionX();

	if display.resolution >= 2 then
		
		local offsetX = display.designResolutionWidth*(1-display.reduce)*0.5
		self.m_ccbNodeRight:setPositionX(RightX+offsetX);
		self.m_ccbNodeBottom:setPositionX(BotX+offsetX)
		self.m_ccbNodeLeft:setPositionX(LeftX-offsetX);
	else
		self.m_ccbNodeBottom:setPositionY(-display.offsetY)
		self.m_ccbNodeTop:setPositionY(display.offsetY)
		self.m_ccbNodeLeft:setPositionY(display.offsetY);
		self.m_ccbNodeRight:setPositionY(display.offsetY);
	end
end

function CCBHeadBar:onBtnClose()
	print("close")
	if self.closeCallback then self.closeCallback() end
end

function CCBHeadBar:onBtnAddCoin()
	print("coin")
	if self.coinCallback then self.coinCallback() end	
end

function CCBHeadBar:onBtnAddDiamond()
	print("diamond")

	if self.diamondCallback then self.diamondCallback() end	
end

function CCBHeadBar:updateDate()
	local coin = UserDataMgr:getPlayerGoldCoin();
	local diamond = UserDataMgr:getPlayerDiamond();

	if coin >= 1000000 then
		coin = string.format("%d万", math.floor(coin / 10000));
	end

	if diamond >= 1000000 then
		diamond = string.format("%d万", math.floor(diamond / 10000));
	end
	self.m_ccbLabelCoin:setString(coin);
	self.m_ccbLabelDiamond:setString(diamond);
end

return CCBHeadBar