local ResourceMgr = require("app.utils.ResourceMgr");
local CCBRewardProp = require("app.views.leagueFight.CCBRewardProp");
local CCBFightRecordList = require("app.views.leagueFight.CCBFightRecordList");

local CCBLeagueFight = class("CCBLeagueFight", function ()
	return CCBLoader("ccbi/leagueFight/CCBLeagueFight.ccbi")
end)

function CCBLeagueFight:ctor()
	--if display.resolution >= 2 then
    	--self.m_ccbNodeLeft:setScale(display.reduce);
    	--self.m_ccbNodeRight:setScale(display.reduce);
    --end

	for i=1, 5 do
		self["m_ccbLabelRank".. i]:setString("第" .. i .."名名字")
	end

	local win = {"(0/2)", "(0/1)", "(0/5)"};
	for i=1, 3 do
		self["m_ccbLabelWin".. i]:setString(win[i]);
		self["m_ccbNodeIcon".. i]:addChild(ResourceMgr:createItemIcon(20000+i));
		self["m_ccbNodeIcon".. i]:addChild(cc.Sprite:create(ResourceMgr:getMailPresentReceiveLabelImg()));
	end

	self.m_ccbLabelScore:setString(99999)
	self.m_ccbLabelRank:setString(2500)

	self.m_ccbLabelCount:setString("1/5");
end

function CCBLeagueFight:onBtnCheckAwd()
	App:getRunningScene():addChild(CCBRewardProp:create());
end

function CCBLeagueFight:onBtnBattle()
end

function CCBLeagueFight:onBtnRecord()
	App:getRunningScene():addChild(CCBFightRecordList:create());
end

return CCBLeagueFight