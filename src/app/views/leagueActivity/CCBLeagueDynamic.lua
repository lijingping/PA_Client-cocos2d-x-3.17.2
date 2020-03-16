local CCBLeagueDynamicList = require("app.views.leagueActivity.CCBLeagueDynamicList");
local CCBLeagueDynamicMemberCell = require("app.views.leagueActivity.CCBLeagueDynamicMemberCell");
local CCBLeagueDynamicFightCell = require("app.views.leagueActivity.CCBLeagueDynamicFightCell");
-----------------------
local MEMBER_DYNAMIC = 1;
local FIGHT = 2;

local CCBLeagueDynamic = class("CCBLeagueDynamic", function ()
	return CCBLoader("ccbi/leagueActivity/CCBLeagueDynamic.ccbi")
end)

function CCBLeagueDynamic:ctor()
	self:enableNodeEvents();

    if display.resolution >= 2 then
        self.m_ccbLayerCenter:setScale(display.reduce);
    end

	self.m_list = {};
    self:onBtnMemberDynamic();
end

function CCBLeagueDynamic:onEnter()
end

function CCBLeagueDynamic:onExit()
end

function CCBLeagueDynamic:onBtnSlot(index)
	for i=1, FIGHT do
		self.m_ccbLayerCenter:getChildByTag(i):setEnabled(i ~= index);

		if self.m_list[i] then
			self.m_list[i]:setVisible(i == index);
			--self.m_list[i]:setTouchEnabled(i ~= index);
		end
	end
end

function CCBLeagueDynamic:onBtnMemberDynamic()
	local list = self.m_list[MEMBER_DYNAMIC];
	if list == nil then
		list = CCBLeagueDynamicList:create();
		local data = {}
		for i=1,10 do
	        data[i] = {nickname="超能陆战队".. 1, time="2018-06-0".. i, desc="任命为副会长" .. i}
	    end
	    list:setAnchorPoint(cc.p(0, 0));
		list:setData(data);
		list:setCell(CCBLeagueDynamicMemberCell);
		list:createTableView(self.m_ccbNodeTableView:getContentSize(), cc.size(720, 45));

		self.m_ccbNodeTableView:addChild(list);
		self.m_list[MEMBER_DYNAMIC] = list;
	else
		--list:
	end

	self:onBtnSlot(MEMBER_DYNAMIC);
end

function CCBLeagueDynamic:onBtnFight()
	local list = self.m_list[FIGHT];
	if list == nil then
		list = CCBLeagueDynamicList:create();
		local data = {}
		for i=1,10 do
	        data[i] = {nickname="超能陆战队".. 1, time="2018-06-0".. i, 
	        desc="本次殖民星争夺战共5人参与，联盟总积分20，联盟排名第100名，获得：联盟资金+3500" .. i}
	    end
	    list:setAnchorPoint(cc.p(0, 0));
		list:setData(data);
		list:setCell(CCBLeagueDynamicFightCell);
		list:createTableView(self.m_ccbNodeTableView:getContentSize(), cc.size(720, 78));

		self.m_ccbNodeTableView:addChild(list);
		self.m_list[FIGHT] = list;
	else
		--list:
	end

	self:onBtnSlot(FIGHT);
end

function CCBLeagueDynamic:onBtnClose()
	self:removeSelf();
end

return CCBLeagueDynamic