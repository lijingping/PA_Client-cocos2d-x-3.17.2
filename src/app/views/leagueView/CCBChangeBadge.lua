
local CCBChangeBadgeScroll = require("app.views.leagueView.CCBChangeBadgeScroll");

local CCBChangeBadge = class("CCBChangeBadge", function ()
	return CCBLoader("ccbi/leagueView/CCBChangeBadge.ccbi")
end)

function CCBChangeBadge:ctor()
	if display.resolution >= 2 then
    	self.m_ccbLayerCenter:setScale(display.reduce);
    end

	local scroll = CCBChangeBadgeScroll:create();
	scroll:setCallFunc(function(params)
		self.m_ccbSpriteBadge:setTexture(params.iconTexture);
		--self.iconID = params.iconID;
		if self.m_callFunc then
			self.m_callFunc(params);
		end
	end);
	self.m_ccbScrollView:setContainer(scroll);

	local data = UserDataMgr.m_leagueData[UserDataMgr.m_leagueAid];
	if data then
		self.m_ccbLabelName:setString(data.name);
	end
end

function CCBChangeBadge:setCallFunc(callFunc)
	self.m_callFunc = callFunc;
end

function CCBChangeBadge:setLeagueName(name)
	self.m_ccbLabelName:setString(name);
end

function CCBChangeBadge:onBtnClose()
	self:removeSelf();
end

function CCBChangeBadge:onBtnUse()
end

return CCBChangeBadge