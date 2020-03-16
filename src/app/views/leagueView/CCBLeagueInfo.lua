local ResourceMgr = require("app.utils.ResourceMgr");
local LeagueConsts = require("app.views.leagueView.LeagueConsts");
local league_build_desc = require("app.constants.league_build_desc");
-------------------
-- CCB主界面
-------------------
local CCBLeagueInfo = class("CCBLeagueInfo", function ()
	return CCBLoader("ccbi/leagueView/CCBLeagueInfo.ccbi")
end)

function CCBLeagueInfo:ctor(params)
	if display.resolution >= 2 then
		self.m_ccbLayerCenter:setScale(display.reduce);
    end

    self.m_params = params;

	local data = UserDataMgr.m_leagueData[UserDataMgr.m_leagueAid];
	self.m_ccbLabelName:setString(data.name)
	self.m_ccbLabelChairname:setString(data.chairman_name)
	self.m_ccbNodeHead:addChild(cc.Sprite:create(ResourceMgr:getLeagueBadgeByIconID(data.iconID)));
	self.m_ccbLabelID:setString(data.aid)

	self.m_ccbLabelMember:setString(data.member_count .. "/" .. data.member_limit);
	self.m_ccbLabelTotalLevel:setString(UserDataMgr:isLeagueBuildTotalLevel());
	self.m_ccbLabelMoney:setString(UserDataMgr:getLeagueMoney());

	local nodeName = {"m_ccbLabelBase", "m_ccbLabelFinance", "m_ccbLabelTraining", 
		"m_ccbLabelResearch", "m_ccbLabelExchange"}
	for i=1, LeagueConsts.MAX_BUILD do
		if league_build_desc[tostring(i)].unlock_level <= 0
		and UserDataMgr:isLeagueLeagueBuild()[i] == false then
			self[nodeName[i]]:setString(UserDataMgr:getLeagueBuildLevel()[i]);
		else
			self[nodeName[i]]:setString(Str[24022]);
		end
	end
end

function CCBLeagueInfo:onBtnClose()
	self:removeSelf();
end

return CCBLeagueInfo