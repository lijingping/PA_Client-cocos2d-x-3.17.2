
local LeagueConsts = require("app.views.leagueView.LeagueConsts");

local CCBChangeBadgeScroll = class("CCBChangeBadgeScroll", function()
	return CCBLoader("ccbi/leagueView/CCBChangeBadgeScroll.ccbi")
end)

function CCBChangeBadgeScroll:ctor()
	self:createTouchEvent();
end

function CCBChangeBadgeScroll:setCallFunc(callFunc)
	self.m_callFunc = callFunc;
end

function CCBChangeBadgeScroll:createTouchEvent()
	local listener = cc.EventListenerTouchOneByOne:create();
	listener:registerScriptHandler(function (touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN);
	listener:registerScriptHandler(function (touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED);
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self);
end
function CCBChangeBadgeScroll:onTouchBegan(touch, event)
	self.m_beganPos = touch:getLocation();
	return true
end

function CCBChangeBadgeScroll:onTouchEnded(touch, event)
	local pos = touch:getLocation();
	--if self.m_beganPos.x == pos.x and self.m_beganPos.y == pos.y then
		local convertIconPos = self:convertToNodeSpace(pos);
		for i=1, LeagueConsts.MAX_BADGE do
			local node = self:getChildByTag(i);
			if node == nil then break end
			if cc.rectContainsPoint(node:getBoundingBox(), convertIconPos) then
				self:onBtn(node, i);
				return
			end
		end
	--end
end

function CCBChangeBadgeScroll:onBtn(node, index)
	if self.m_lastSeleted then
		self.m_lastSeleted:getChildByTag(1):setVisible(false)
	end
	self.m_lastSeleted = node
	self.m_lastSeleted:getChildByTag(1):setVisible(true)

	if self.m_callFunc then
		self.m_callFunc({iconID=i, iconTexture=node:getChildByTag(2):getTexture()});
	end
	
	local data = UserDataMgr.m_leagueData[UserDataMgr.m_leagueAid];
	if data then
		data.iconID = i;
	end
end

return CCBChangeBadgeScroll