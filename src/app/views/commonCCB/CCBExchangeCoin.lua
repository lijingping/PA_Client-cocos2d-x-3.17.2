local CCBMessageBox = require("app.views.commonCCB.CCBMessageBox");
local Tips = require("app.views.common.Tips");

local CCBExchangeCoin = class("CCBExchangeCoin", function (  )
	return CCBLoader("ccbi/commonCCB/CCBExchangeCoin.ccbi");
end)

function CCBExchangeCoin:ctor()
	print("  CCBExchangeCoin:ctor()    ");
	App:getRunningScene():addChild(self, display.Z_UILAYER);
	self.m_shopData = table.clone(require("app.constants.shop"));
	self:createEventListener();
	self:init();

	if display.resolution >= 2 then
		self.m_ccbNodeCenter:setScale(display.reduce);
	end

end

function CCBExchangeCoin:createEventListener()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_ccbLayerColor);
end

function CCBExchangeCoin:init()
	for i = 1, 6 do 
		local exchangeData = self.m_shopData[tostring(12 + i)];
		self.m_ccbNodeCenter:getChildByTag(i):getChildByTag(1):setString(exchangeData.desc);
		self.m_ccbNodeCenter:getChildByTag(i):getChildByTag(2):setString(exchangeData.items[1].count);
	end
end

function CCBExchangeCoin:onTouchBegan(touch, event)
	return true;
end

function CCBExchangeCoin:requestBuyCoin(id)
	Network:request("game.shopHandler.buyItem", {table_id = id, count = 1}, function (rc, receivedData)
		dump(receivedData);
			if receivedData.code ~= 1 then
				Tips:create(ServerCode[receivedData.code]);
				return
			end

			Tips:create(string.format(Str[16008], self.m_shopData[tostring(id)].desc));
	end)
end

function CCBExchangeCoin:showMessageBox(id)
	if UserDataMgr:getPlayerDiamond() >= self.m_shopData[tostring(id)].items[1].count then
		local boxContent = string.format(Str[4015], self.m_shopData[tostring(id)].items[1].count, self.m_shopData[tostring(id)].content[1].count);
		local ccbMessageBox = CCBMessageBox:create(Str[3004], boxContent, MB_YESNO);
		ccbMessageBox.onBtnOK = function ()
			self:requestBuyCoin(id);
			ccbMessageBox:removeSelf();
			self:removeSelf();
		end
		
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();	
		end
	else

		-- 钻石不够
		local ccbMessageBox = CCBMessageBox:create(Str[3016], Str[4004], MB_YESNO); --“购买钻石”，"钻石不足，是否前往充值页面？"
		ccbMessageBox.onBtnOK = function ()
			App:enterScene("ShopScene");
			ccbMessageBox:removeSelf();
		end
		ccbMessageBox.onBtnCancel = function ()
			ccbMessageBox:removeSelf();
		end
	end
end

function CCBExchangeCoin:onBtnExchange1()
	self:showMessageBox(13);
end

function CCBExchangeCoin:onBtnExchange2()
	self:showMessageBox(14);
end

function CCBExchangeCoin:onBtnExchange3()
	self:showMessageBox(15);
end

function CCBExchangeCoin:onBtnExchange4()
	self:showMessageBox(16);
end

function CCBExchangeCoin:onBtnExchange5()
	self:showMessageBox(17);
end

function CCBExchangeCoin:onBtnExchange6()
	self:showMessageBox(18);
end

function CCBExchangeCoin:onBtnClose()
	self:removeSelf();
end

return CCBExchangeCoin;