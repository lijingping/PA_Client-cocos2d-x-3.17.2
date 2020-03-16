local ResourceMgr = require("app.utils.ResourceMgr");
local Tips = require("app.views.common.Tips");

local CCBCommonGetPath = class("CCBCommonGetPath", function()
	return CCBLoader("ccbi/commonCCB/CCBCommonGetPath.ccbi")
end)

local btnDistance = 110;

function CCBCommonGetPath:ctor(itemID)
	if display.resolution >= 2 then
        self.m_ccbNodeCenter:setScale(display.reduce);
    end
	App:getRunningScene():addChild(self, display.Z_BLURLAYER);
	self:createTouchEvent();
	local pathCount = 0;

	local itemData = ItemDataMgr:getItemBaseInfo(itemID);
	for k, v in pairs(itemData.item_origin) do 
		self:createButtonWithType(v, pathCount);
		pathCount = pathCount + 1;
	end
	for i = pathCount + 1, 3 do
		local noPathSprite = cc.Sprite:create(ResourceMgr:getNoItemPath());
		self.m_ccbNodeBtn:addChild(noPathSprite);
		noPathSprite:setPositionY(-btnDistance * pathCount);
		pathCount = pathCount + 1;
	end
end

function CCBCommonGetPath:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:setSwallowTouches(true);
	listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event); end, cc.Handler.EVENT_TOUCH_BEGAN);
	local eventDispatcher = self:getEventDispatcher();
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self);
end

function CCBCommonGetPath:onTouchBegan(touch, event)
	return true;
end

function CCBCommonGetPath:createButtonWithType(nType, index)
	local isNormalState = true;
	local button = ccui.Button:create(ResourceMgr:getItemPathBtn(isNormalState, nType), ResourceMgr:getItemPathBtn(not isNormalState, nType),
		ResourceMgr:getItemPathBtn(isNormalState, nType));
	button:setAnchorPoint(cc.p(0.5, 0.5));
	button:setPositionY(-btnDistance * index);
	self.m_ccbNodeBtn:addChild(button);
	button:setTitleText("");
	button:addClickEventListener(function()
		self:btnCall(tonumber(nType));
	end)
end

function CCBCommonGetPath:btnCall(nType)
	if nType == 1 then
		App:enterScene("ProduceScene1");
	elseif nType == 2 or nType == 3 or nType == 4 or nType == 5 or nType == 6 or nType == 7 then
		App:enterScene("MainScene");
		App:getRunningScene():getViewBase().m_ccbMainView:onBtnSearchExplore();
	elseif nType == 8 then
		Tips:create("道具商城, 敬请期待……    " .. nType);
		App:enterScene("ShopScene");
	elseif nType == 9 then
		Tips:create("联盟商城, 敬请期待……    " .. nType);
	elseif nType == 10 then
		Tips:create("友情商城, 敬请期待……    " .. nType);
	elseif nType == 11 then
		App:enterScene("FriendScene");
		App:getRunningScene():getViewBase().m_ccbFriendView:changeTab(3);
	elseif nType == 12 then
		Tips:create("抽奖能赢, 敬请期待……    " .. nType);
		App:enterScene("LotteryScene");
	elseif nType == 13 then
		Tips:create("任务成就, 敬请期待……    " .. nType);
		App:enterScene("TaskScene");
	end
end

function CCBCommonGetPath:onBtnOK()
	self:removeSelf();
end

return CCBCommonGetPath;