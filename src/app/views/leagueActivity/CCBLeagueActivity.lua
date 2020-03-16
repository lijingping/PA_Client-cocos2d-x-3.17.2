local CCBLeagueInfoList = require("app.views.leagueActivity.CCBLeagueInfoList");
local CCBLeagueApplyList = require("app.views.leagueActivity.CCBLeagueApplyList");

local INFO = 1;
local APPLY = 2;

local CCBLeagueActivity = class("CCBLeagueActivity", function ()
	return CCBLoader("ccbi/leagueActivity/CCBLeagueActivity.ccbi")
end)

function CCBLeagueActivity:ctor()
	self:enableNodeEvents();

    if display.resolution >= 2 then
        self.m_ccbLayerCenter:setScale(display.reduce);
    end

	self.m_list = {};
    self:onBtnInfo();

	local data = UserDataMgr.m_leagueData[UserDataMgr.m_leagueAid];
    self.m_ccbLabelMember:setString(data.member_count .."/" .. data.member_limit)
end

function CCBLeagueActivity:onEnter()
end

function CCBLeagueActivity:onExit()
end

function CCBLeagueActivity:onBtnSlot(index)
	for i=1, APPLY do
		self.m_ccbLayerCenter:getChildByTag(i):setEnabled(i ~= index);

		if self.m_list[i] then
			self.m_list[i]:setVisible(i == index);
			--self.m_list[i]:setTouchEnabled(i ~= index);
		end
	end
end

function CCBLeagueActivity:onBtnInfo()
	if self.m_list[INFO] == nil then
		self.m_list[INFO] = CCBLeagueInfoList:create();
		self:addChild(self.m_list[INFO]);
	end

	self:onBtnSlot(INFO);
end

function CCBLeagueActivity:onBtnApply()
	if self.m_list[APPLY] == nil then
		self.m_list[APPLY] = CCBLeagueApplyList:create();
		self:addChild(self.m_list[APPLY]);
	end
	self:onBtnSlot(APPLY);
end

return CCBLeagueActivity