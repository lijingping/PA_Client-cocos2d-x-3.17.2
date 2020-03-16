local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");
local Tips = require("app.views.common.Tips");

local CCBExchangeDiamond = class("CCBExchangeDiamond", function (  )
	return CCBLoader("ccbi/commonCCB/CCBExchangeDiamond.ccbi");
end)

function CCBExchangeDiamond:ctor()
	print("  CCBExchangeDiamond:ctor()    ");
	App:getRunningScene():addChild(self, display.Z_UILAYER);
	self.m_shopData = table.clone(require("app.constants.shop"));
	self:createEventListener();
	self:init();
	
	if display.resolution >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end
end

function CCBExchangeDiamond:createEventListener()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerColor);
end

function CCBExchangeDiamond:init()
	for i = 1, 6 do 
		local exchangeData = self.m_shopData[tostring(18 + i)];
		self.m_ccbNodeCenter:getChildByTag(i):getChildByTag(1):setString(exchangeData.desc);
		self.m_ccbNodeCenter:getChildByTag(i):getChildByTag(2):setString("¥" .. exchangeData.items[1].count);
	end
end

function CCBExchangeDiamond:onTouchBegan(touch, event)
	return true;
end

function CCBExchangeDiamond:requestBuyCoin(id)
	Network:request("game.shopHandler.buyItem", {table_id = id, count = 1}, function (rc, receivedData)
		dump(receivedData);
			if receivedData.code ~= 1 then
				Tips:create(ServerCode[receivedData.code]);
				return
			end

			Tips:create(string.format(Str[16009], self.m_shopData[tostring(id)].desc));
	end)
end

function CCBExchangeDiamond:showMessageBox(id)
	-- 确认购买钻石
end

function CCBExchangeDiamond:onBtnExchange1()
	-- 19
	print("    有  ", self.m_shopData[tostring(19)].desc, "   您买吗？  ");
end

function CCBExchangeDiamond:onBtnExchange2()
	-- 20
	print("    有  ", self.m_shopData[tostring(20)].desc, "   您买吗？  ");
end

function CCBExchangeDiamond:onBtnExchange3()
	-- 21
	print("    有  ", self.m_shopData[tostring(21)].desc, "   您买吗？  ");
end

function CCBExchangeDiamond:onBtnExchange4()
	-- 22
	print("    有  ", self.m_shopData[tostring(22)].desc, "   您买吗？  ");
end

function CCBExchangeDiamond:onBtnExchange5()
	-- 23
	print("    有  ", self.m_shopData[tostring(23)].desc, "   您买吗？  ");
end

function CCBExchangeDiamond:onBtnExchange6()
	--24
	print("    有  ", self.m_shopData[tostring(24)].desc, "   您买吗？  ");
end

function CCBExchangeDiamond:onBtnClose()
	self:removeSelf();
end

return CCBExchangeDiamond;