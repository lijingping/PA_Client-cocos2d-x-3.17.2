
local league_contribute = require("app.constants.league_contribute");

local CCBLeagueDonate = class("CCBLeagueDonate", function ()
	return CCBLoader("ccbi/leagueView/CCBLeagueDonate.ccbi")
end)

function CCBLeagueDonate:ctor(params)
	if display.resolution >= 2 then
		self.m_ccbLayerCenter:setScale(display.reduce);
    end

    self.m_data = league_contribute["1"]
	self.m_ccbLabelMoney:setString(UserDataMgr:getLeagueMoney());
	self.m_ccbLabelMoneyAwd:setString(self.m_data.money[1].count);
	self.m_ccbLabelCoinAwd:setString(self.m_data.coin[1].count);
	self.m_ccbLabelDonateAwd:setString(self.m_nameEditBoxcontribute);
	self.m_ccbLabelCount:setString(0 .."/".. self.m_data.day_limit);
	self.m_ccbLabelDonateMoney:setString(self.m_data.donate[1].count);
end

function CCBLeagueDonate:onBtnClose()
	self:removeSelf();
end

function CCBLeagueDonate:onBtn()
	UserDataMgr:setLeagueMoney(UserDataMgr:getLeagueMoney()+self.m_data.money[1].count);
	UserDataMgr:setPlayerUnionCoin(UserDataMgr:getPlayerUnionCoin()+self.m_data.coin[1].count);
	UserDataMgr.m_leagueContribute = UserDataMgr.m_leagueContribute + self.m_data.contribute;

	self:onBtnClose()
end

return CCBLeagueDonate